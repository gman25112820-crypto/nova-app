#!/usr/bin/env python3
"""
Batch-generate all Fabulously Me characters via FLUX.1 Kontext [pro].

Usage:
    python gen_characters.py                       # all 9 characters, 4 candidates each
    python gen_characters.py --char daughter_9     # single character only
    python gen_characters.py --pick daughter_9 2   # promote candidate 2 to active asset
"""

import os
import sys
import argparse
import urllib.request
import fal_client  # pip install fal-client

# Load fal API key from fal_key.txt in project root (never committed).
_key_file = os.path.join(os.path.dirname(__file__), "fal_key.txt")
if os.path.exists(_key_file):
    os.environ.setdefault("FAL_KEY", open(_key_file).read().strip())
else:
    print(f"[WARN] fal_key.txt not found at {_key_file}")
    print("       Create it with your fal API key as the only content.")

OUT_DIR = "assets/characters_v2"
NUM_CANDIDATES = 4
MODEL = "fal-ai/flux-pro/kontext"  # $0.04 per image
COST_PER_IMAGE = 0.04

# Shared lighting/bg suffix applied to every prompt.
_SCENE = (
    "full body standing pose, front-facing, "
    "lit by warm lantern glow from below and soft cool moonlight from above, "
    "night garden colour palette, warm glowy 3D Pixar style, "
    "flat solid lime green background, no cast shadow in the image"
)

CHARACTERS = [
    {
        "name": "daughter_9",
        "reference": "assets/images/characters/daughter_9.png",
        "prompt": (
            "this exact character, unchanged design - "
            "young girl, pink gingham bow in hair, "
            + _SCENE
        ),
    },
    {
        "name": "daughter_7",
        "reference": "assets/images/characters/daughter_7.png",
        "prompt": (
            "this exact character, unchanged design - "
            "young girl, pigtails, frilly yellow dress, "
            + _SCENE
        ),
    },
    {
        "name": "teds",
        "reference": "assets/images/characters/teds.png",
        "prompt": (
            "this exact character, unchanged design - "
            "Shih Tzu dog, fluffy white and tan fur, blue bow tie, "
            + _SCENE
        ),
    },
    {
        "name": "cat1",
        "reference": "assets/images/characters/cat1.png",
        "prompt": (
            "this exact character, unchanged design - "
            "black cat with white chest, "
            + _SCENE
        ),
    },
    {
        "name": "cat2",
        "reference": "assets/images/characters/cat2.png",
        "prompt": (
            "this exact character, unchanged design - "
            "black cat with white chest, "
            + _SCENE
        ),
    },
    {
        "name": "dad_giraffe",
        "reference": "assets/images/characters/dad_giraffe.png",
        "prompt": (
            "this exact character, unchanged design - "
            "tall giraffe character, hoodie, jeans, "
            + _SCENE
        ),
    },
    {
        "name": "son_giraffe_1",
        "reference": "assets/images/characters/son_giraffe_1.png",
        "prompt": (
            "this exact character, unchanged design - "
            "young giraffe character, brown tracksuit, "
            + _SCENE
        ),
    },
    {
        "name": "son_giraffe_2",
        "reference": "assets/images/characters/son_giraffe_2.png",
        "prompt": (
            "this exact character, unchanged design - "
            "young giraffe character, red and white sports kit, "
            + _SCENE
        ),
    },
    {
        "name": "jack_russell",
        "reference": "assets/images/characters/jack_russell.png",
        "prompt": (
            "this exact character, unchanged design - "
            "Jack Russell terrier, white with brown and tan patches, "
            + _SCENE
        ),
    },
]


def upload_reference(path: str) -> str:
    with open(path, "rb") as f:
        data = f.read()
    url = fal_client.upload(data, content_type="image/png")
    print(f"    ref uploaded: {url}")
    return url


def rembg_and_crop(raw_path: str, out_path: str) -> None:
    """Remove background then autocrop transparent border with 4% padding."""
    try:
        from rembg import remove
        from PIL import Image
    except ImportError:
        print("    [WARN] rembg/Pillow not installed — skipping. Run: pip install rembg Pillow")
        return

    img = Image.open(raw_path).convert("RGBA")
    nobg = remove(img)

    bbox = nobg.split()[3].getbbox()
    if bbox:
        nobg = nobg.crop(bbox)
        pw = max(1, int(nobg.width * 0.04))
        ph = max(1, int(nobg.height * 0.04))
        canvas = Image.new("RGBA", (nobg.width + pw * 2, nobg.height + ph * 2), (0, 0, 0, 0))
        canvas.paste(nobg, (pw, ph))
        nobg = canvas

    nobg.save(out_path)
    print(f"    rembg+crop -> {out_path}")


def generate_character(char: dict) -> None:
    name = char["name"]
    char_dir = os.path.join(OUT_DIR, name)
    os.makedirs(char_dir, exist_ok=True)

    all_done = all(
        os.path.exists(os.path.join(char_dir, f"{name}_{i}_nobg.png"))
        for i in range(1, NUM_CANDIDATES + 1)
    )
    if all_done:
        print(f"  {name}: all candidates exist — skipping")
        return

    print(f"\n  {name}")
    ref_url = upload_reference(char["reference"])

    for i in range(1, NUM_CANDIDATES + 1):
        nobg_path = os.path.join(char_dir, f"{name}_{i}_nobg.png")
        raw_path = os.path.join(char_dir, f"{name}_{i}.png")

        if os.path.exists(nobg_path):
            print(f"    candidate {i}: exists — skipping")
            continue

        print(f"    candidate {i}/{NUM_CANDIDATES} generating...")
        result = fal_client.subscribe(
            MODEL,
            arguments={
                "prompt": char["prompt"],
                "image_url": ref_url,
                "num_images": 1,
                "image_size": "portrait_4_3",
                "guidance_scale": 3.5,
            },
            with_logs=False,
        )
        img_url = result["images"][0]["url"]
        urllib.request.urlretrieve(img_url, raw_path)
        print(f"    raw saved  -> {raw_path}")
        rembg_and_crop(raw_path, nobg_path)


def pick_candidate(char_name: str, n: int) -> None:
    char_dir = os.path.join(OUT_DIR, char_name)
    src = os.path.join(char_dir, f"{char_name}_{n}_nobg.png")
    if not os.path.exists(src):
        src = os.path.join(char_dir, f"{char_name}_{n}.png")
    if not os.path.exists(src):
        print(f"Candidate {n} for '{char_name}' not found in {char_dir}/")
        sys.exit(1)

    import shutil
    dst = f"assets/images/characters/{char_name}.png"
    bak = dst + ".bak"
    if not os.path.exists(bak) and os.path.exists(dst):
        shutil.copy(dst, bak)
        print(f"  backed up original -> {bak}")
    shutil.copy(src, dst)
    print(f"  promoted {char_name} candidate {n} -> {dst}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--char", help="Generate a single character by name")
    parser.add_argument(
        "--pick", nargs=2, metavar=("CHAR", "N"),
        help="Promote candidate N for CHAR to the active asset"
    )
    args = parser.parse_args()

    if args.pick:
        pick_candidate(args.pick[0], int(args.pick[1]))
        return

    chars = CHARACTERS
    if args.char:
        chars = [c for c in CHARACTERS if c["name"] == args.char]
        if not chars:
            valid = [c["name"] for c in CHARACTERS]
            print(f"Unknown character '{args.char}'. Valid names: {valid}")
            sys.exit(1)

    total_images = len(chars) * NUM_CANDIDATES
    total_cost = total_images * COST_PER_IMAGE
    print("-" * 60)
    print(f"Characters : {len(chars)}")
    print(f"Candidates : {NUM_CANDIDATES} each  ({total_images} images total)")
    print(f"Cost       : ${total_cost:.2f}  (@ ${COST_PER_IMAGE} per image)")
    print(f"Output     : {OUT_DIR}/<char>/")
    print("-" * 60)

    for char in chars:
        generate_character(char)

    print("\n-- Generation complete ------------------------------------------")
    print(f"Review: {OUT_DIR}/<char>/<char>_1_nobg.png  …  _4_nobg.png")
    print("Promote a pick:")
    print("  python gen_characters.py --pick <char> <1-4>")


if __name__ == "__main__":
    main()
