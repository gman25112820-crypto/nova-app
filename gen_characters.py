#!/usr/bin/env python3
"""
Generate scene-matched Chicken Lips sprites via FLUX.1 Kontext [pro].

Usage:
    python gen_characters.py               # generate 4 candidates
    python gen_characters.py --pick 2      # after review: promote candidate 2
"""

import os
import sys
import argparse
import urllib.request
import fal_client  # pip install fal-client

# ── Reference image ────────────────────────────────────────────────────────────
REFERENCE_IMAGE = "assets/images/characters/chicken_lips.png"

# ── Output folder ──────────────────────────────────────────────────────────────
OUT_DIR = "assets/characters_v2"

# ── Generation prompt ──────────────────────────────────────────────────────────
# Kontext takes a reference image + an editing instruction.
# We preserve the full design and only change lighting + background.
PROMPT = (
    "this exact character, unchanged design - round fluffy yellow chick, "
    "purple nurse outfit, white collar, stethoscope, gold crown on nurse hat, "
    "big purple eyes with lashes, pouty lips - "
    "full body standing pose, front-facing, "
    "lit by warm lantern glow from below and soft cool moonlight from above, "
    "night garden colour palette, warm glowy 3D Pixar style, "
    "flat solid lime green background, "
    "no cast shadow in the image"
)

NUM_CANDIDATES = 4
MODEL = "fal-ai/flux-pro/kontext"  # $0.04 per image, character-consistent editing


def upload_reference(path: str) -> str:
    """Upload local PNG to fal storage and return the URL."""
    with open(path, "rb") as f:
        data = f.read()
    url = fal_client.upload(data, content_type="image/png")
    print(f"  Reference uploaded: {url}")
    return url


def generate_candidates(ref_url: str) -> list[str]:
    """Generate NUM_CANDIDATES images and save to OUT_DIR. Returns saved paths."""
    os.makedirs(OUT_DIR, exist_ok=True)
    paths = []

    for i in range(1, NUM_CANDIDATES + 1):
        out_path = os.path.join(OUT_DIR, f"chicken_lips_v2_{i}.png")
        if os.path.exists(out_path):
            print(f"Candidate {i} already exists, skipping generation.")
            paths.append(out_path)
            continue
        print(f"\nGenerating candidate {i}/{NUM_CANDIDATES}...")
        result = fal_client.subscribe(
            MODEL,
            arguments={
                "prompt": PROMPT,
                "image_url": ref_url,
                "num_images": 1,
                "image_size": "portrait_4_3",
                "guidance_scale": 3.5,
            },
            with_logs=False,
        )
        img_url = result["images"][0]["url"]
        urllib.request.urlretrieve(img_url, out_path)
        print(f"  Saved -> {out_path}")
        paths.append(out_path)

    return paths


def remove_bg(paths: list[str]) -> list[str]:
    """Run rembg on each candidate to produce transparent PNG."""
    try:
        from rembg import remove  # pip install rembg
        from PIL import Image
    except ImportError:
        print("\n[WARN] rembg not installed - skipping background removal.")
        print("       Run: pip install rembg Pillow")
        return paths

    out_paths = []
    for p in paths:
        img = Image.open(p)
        result = remove(img)
        out_path = p.replace(".png", "_nobg.png")
        result.save(out_path)
        print(f"  rembg -> {out_path}")
        out_paths.append(out_path)
    return out_paths


def pick_candidate(n: int) -> None:
    """Promote candidate N to the active character asset."""
    src = os.path.join(OUT_DIR, f"chicken_lips_v2_{n}_nobg.png")
    if not os.path.exists(src):
        src = os.path.join(OUT_DIR, f"chicken_lips_v2_{n}.png")
    if not os.path.exists(src):
        print(f"Candidate {n} not found at {src}")
        sys.exit(1)

    dst = "assets/images/characters/chicken_lips.png"
    # Back up original if not already done
    bak = dst + ".bak"
    if not os.path.exists(bak):
        import shutil
        shutil.copy(dst, bak)
        print(f"Original backed up to {bak}")

    import shutil
    shutil.copy(src, dst)
    print(f"Promoted candidate {n} -> {dst}")
    print("Hot-reload on localhost:8080 to see the change.")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pick", type=int, help="Promote candidate N after review")
    args = parser.parse_args()

    if args.pick:
        pick_candidate(args.pick)
        return

    print(f"Model : {MODEL}")
    print(f"Cost  : $0.04 x {NUM_CANDIDATES} candidates = ${0.04 * NUM_CANDIDATES:.2f}")
    print(f"Output: {OUT_DIR}/")
    print()

    ref_url = upload_reference(REFERENCE_IMAGE)
    paths = generate_candidates(ref_url)
    final_paths = remove_bg(paths)

    print("\n── Candidates ready ──────────────────────────────────────────")
    for p in final_paths:
        print(f"  {p}")
    print("\nReview the 4 PNGs above, then run:")
    print("  python gen_characters.py --pick <1-4>")
    print("to promote your chosen one to assets/images/characters/chicken_lips.png")


if __name__ == "__main__":
    main()
