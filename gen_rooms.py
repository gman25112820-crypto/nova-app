#!/usr/bin/env python3
"""
Batch-generate Fabulously Me room backgrounds via fal.ai FLUX.

Usage:
    python gen_rooms.py                          # all rooms, 4 candidates each (text mode)
    python gen_rooms.py --room spare_room        # single room only
    python gen_rooms.py --pick spare_room 2      # promote candidate 2 to live asset
    python gen_rooms.py --mode kontext           # use FLUX Kontext (needs reference per room)

Modes:
    text     (default) fal-ai/flux-pro         text-to-image, no reference needed
    kontext            fal-ai/flux-pro/kontext  image+text, needs reference path in ROOMS entry
"""

import os
import sys
import argparse
import urllib.request
import fal_client  # pip install fal-client

# ---------------------------------------------------------------------------
# API key
# ---------------------------------------------------------------------------

_key_file = os.path.join(os.path.dirname(__file__), "fal_key.txt")
if os.path.exists(_key_file):
    os.environ.setdefault("FAL_KEY", open(_key_file).read().strip())
else:
    print(f"[WARN] fal_key.txt not found at {_key_file}")
    print("       Create it with your fal API key as the only content.")

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

OUT_DIR          = "assets/images/rooms/underground"
NUM_CANDIDATES   = 4
MODEL_TEXT       = "fal-ai/flux-pro"           # $0.05/image (no reference)
MODEL_KONTEXT    = "fal-ai/flux-pro/kontext"   # $0.04/image (reference + prompt)
COST_TEXT        = 0.05
COST_KONTEXT     = 0.04

# Shared style suffix appended to every room prompt.
_STYLE = (
    "interior room, warm cosy lighting, soft shadows, "
    "illustrated 3D Pixar style, slightly magical, "
    "child-friendly, no people, no text, landscape orientation"
)

# ---------------------------------------------------------------------------
# Room definitions
# ---------------------------------------------------------------------------
# Each entry:
#   name        str   — slug used for file names and --room / --pick
#   prompt      str   — full text prompt (style suffix appended automatically)
#   live_asset  str   — path written to when --pick is used (relative to project root)
#   reference   str   — only needed for --mode kontext; path to reference image
# ---------------------------------------------------------------------------

ROOMS = [
    {
        "name": "spare_room",
        "prompt": (
            "A cozy children's bedroom in warm glowy 3D cartoon style, soft rounded shapes, "
            "gentle ambient lighting. Lavender and cream colour palette with soft peach accents. "
            "A neat single bed with a star-print duvet against the back wall, a small bookshelf "
            "with colourful books, a soft reading nook with floor cushions, and warm fairy lights "
            "strung along the wall. A leafy potted plant in the corner. Cosy, calm, inviting "
            "atmosphere. Neutral and unisex — no specific gender theming, no logos, no text. "
            "Storybook illustration quality, soft focus, warm golden hour glow. "
            "Landscape composition, full room background view."
        ),
        "live_asset": "assets/images/rooms/underground/spare_room_bg.png",
        # "reference": "assets/images/rooms/...",  # uncomment for --mode kontext
    },
]

# ---------------------------------------------------------------------------
# Core functions
# ---------------------------------------------------------------------------

def upload_reference(path: str) -> str:
    with open(path, "rb") as f:
        data = f.read()
    url = fal_client.upload(data, content_type="image/png")
    print(f"    ref uploaded: {url}")
    return url


def generate_room(room: dict, mode: str) -> None:
    name     = room["name"]
    room_dir = os.path.join(OUT_DIR, name)
    os.makedirs(room_dir, exist_ok=True)

    all_done = all(
        os.path.exists(os.path.join(room_dir, f"{name}_{i}.png"))
        for i in range(1, NUM_CANDIDATES + 1)
    )
    if all_done:
        print(f"  {name}: all candidates exist — skipping")
        return

    print(f"\n  {name}  [{mode}]")

    ref_url = None
    if mode == "kontext":
        ref_path = room.get("reference")
        if not ref_path:
            print(f"  [ERROR] --mode kontext requires a 'reference' path in the ROOMS entry for '{name}'")
            sys.exit(1)
        ref_url = upload_reference(ref_path)

    prompt = room["prompt"]

    for i in range(1, NUM_CANDIDATES + 1):
        raw_path = os.path.join(room_dir, f"{name}_{i}.png")
        if os.path.exists(raw_path):
            print(f"    candidate {i}: exists — skipping")
            continue

        print(f"    candidate {i}/{NUM_CANDIDATES} generating...")

        if mode == "kontext":
            result = fal_client.subscribe(
                MODEL_KONTEXT,
                arguments={
                    "prompt": prompt,
                    "image_url": ref_url,
                    "num_images": 1,
                    "image_size": "landscape_16_9",
                    "guidance_scale": 3.5,
                },
                with_logs=False,
            )
        else:
            result = fal_client.subscribe(
                MODEL_TEXT,
                arguments={
                    "prompt": prompt,
                    "num_images": 1,
                    "image_size": "landscape_16_9",
                    "guidance_scale": 3.5,
                    "num_inference_steps": 28,
                },
                with_logs=False,
            )

        img_url = result["images"][0]["url"]
        urllib.request.urlretrieve(img_url, raw_path)
        print(f"    saved -> {raw_path}")


def pick_candidate(room_name: str, n: int) -> None:
    import shutil

    room_dir = os.path.join(OUT_DIR, room_name)
    src = os.path.join(room_dir, f"{room_name}_{n}.png")
    if not os.path.exists(src):
        print(f"Candidate {n} for '{room_name}' not found at {src}")
        sys.exit(1)

    room = next((r for r in ROOMS if r["name"] == room_name), None)
    if not room:
        print(f"Unknown room '{room_name}'. Valid names: {[r['name'] for r in ROOMS]}")
        sys.exit(1)

    dst = room["live_asset"]
    bak = dst + ".bak"
    if not os.path.exists(bak) and os.path.exists(dst):
        shutil.copy(dst, bak)
        print(f"  backed up original -> {bak}")

    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy(src, dst)
    print(f"  promoted {room_name} candidate {n} -> {dst}")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--room", help="Generate a single room by name")
    parser.add_argument(
        "--pick", nargs=2, metavar=("ROOM", "N"),
        help="Promote candidate N for ROOM to the live asset path",
    )
    parser.add_argument(
        "--mode", choices=["text", "kontext"], default="text",
        help="text = FLUX text-to-image (default); kontext = FLUX Kontext with reference image",
    )
    args = parser.parse_args()

    if args.pick:
        pick_candidate(args.pick[0], int(args.pick[1]))
        return

    rooms = ROOMS
    if args.room:
        rooms = [r for r in ROOMS if r["name"] == args.room]
        if not rooms:
            valid = [r["name"] for r in ROOMS]
            print(f"Unknown room '{args.room}'. Valid names: {valid}")
            sys.exit(1)

    cost_per = COST_KONTEXT if args.mode == "kontext" else COST_TEXT
    total_images = len(rooms) * NUM_CANDIDATES
    total_cost   = total_images * cost_per

    print("-" * 60)
    print(f"Rooms      : {len(rooms)}")
    print(f"Candidates : {NUM_CANDIDATES} each  ({total_images} images total)")
    print(f"Mode       : {args.mode}  ({MODEL_KONTEXT if args.mode == 'kontext' else MODEL_TEXT})")
    print(f"Cost est.  : ${total_cost:.2f}  (@ ${cost_per} per image)")
    print(f"Output     : {OUT_DIR}/<room>/")
    print("-" * 60)

    for room in rooms:
        generate_room(room, args.mode)

    print("\n-- Generation complete ------------------------------------------")
    print(f"Review candidates in:  {OUT_DIR}/<room>/<room>_1.png  …  _{NUM_CANDIDATES}.png")
    print("Promote a pick:")
    print("  python gen_rooms.py --pick <room> <1-4>")


if __name__ == "__main__":
    main()
