"""
fix_d7.py - Fix daughter_7.png grey-box artefact.

The PNG has binary alpha (0 or 255 only), giving it a hard silhouette
that looks like a grey box on dark backgrounds in CanvasKit Flutter web.
Applies a 1.5px Gaussian feather to the alpha channel so the character
blends smoothly against the scene.
"""

from PIL import Image, ImageFilter
import shutil

SRC = r"C:\Users\Garet\nova_app\assets\images\characters\daughter_7.png"

img = Image.open(SRC).convert("RGBA")
r, g, b, a = img.split()

# Blur the alpha channel - Gaussian spread of 0s and 255s produces a
# smooth 0..255 transition at each edge while leaving flat interior/exterior
# at their original values.
a_feathered = a.filter(ImageFilter.GaussianBlur(radius=1.5))

result = Image.merge("RGBA", (r, g, b, a_feathered))

shutil.copy(SRC, SRC + ".bak")
result.save(SRC, optimize=False)

import numpy as np
check = Image.open(SRC).convert("RGBA")
unique = len(set(list(check.split()[3].getdata())))
print("Saved:", SRC)
print("Unique alpha values after fix:", unique, "(was 2 - binary, now feathered)")
print("Backup:", SRC + ".bak")
