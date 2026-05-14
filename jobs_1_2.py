scene_path = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_scene.dart"
with open(scene_path, "r", encoding="utf-8") as f:
    scene = f.read()

# JOB 1: Tone down door colours
# 0xFFFF8040D0 is roof (keep), 0xFFFB3890 / 0xFFFA3890 / 0xFFF3A2060 are door pinks
replacements = [
    # Door stroke/highlight (bright pink outline)
    ("const Color(0xFFF5A3890)", "const Color(0xFFA03060)"),
    ("const Color(0xFFFF5A3890)", "const Color(0xFFA03060)"),
    # Door fill (main pink body) - line 1586
    ("const Color(0xFFFFA3890)", "const Color(0xFFB04070)"),
    # Door panel
    ("const Color(0xFFF3A2060)", "const Color(0xFF903050)"),
    # Also catch the actual hex values visible in screenshot
    ("const Color(0xFFF5A3890)", "const Color(0xFFA03060)"),
]

count = 0
for old, new in replacements:
    if old in scene:
        scene = scene.replace(old, new)
        print(f"Replaced {old} -> {new}")
        count += 1

# More targeted: replace all pinks in door range using line numbers approach
# From screenshot: lines 1579, 1586, 1591, 1603
lines = scene.split("\n")
changes = {
    # (line_number, old_colour, new_colour)
    # Bright pink door colours identified from screenshot
}

# Direct hex replacements from screenshot output
door_fixes = [
    ("0xFFF5A3890", "0xFF903058"),   # door stroke
    ("0xFFFA3890",  "0xFF903058"),   # door stroke variant  
    ("0xFFF3A2060", "0xFF7A2848"),   # door panel
    ("0xFF402878",  "0xFF402878"),   # chimney - keep as is
]

for old_hex, new_hex in door_fixes:
    old = f"Color({old_hex})"
    new = f"Color({new_hex})"
    if old in scene:
        scene = scene.replace(old, new)
        print(f"Fixed door: {old_hex} -> {new_hex}")
        count += 1

# Print all remaining pinks for verification
print("\nRemaining bright pinks after fix:")
import re
for m in re.finditer(r"0xFF[A-F][A-F0-9]{5}", scene):
    r = int(m.group()[4:6], 16)
    g = int(m.group()[6:8], 16)
    b = int(m.group()[8:10], 16)
    if r > 200 and g < 100 and b > 100:
        idx = m.start()
        print(f"  {m.group()} at {idx}: {repr(scene[idx-40:idx+20])}")

print(f"\nTotal replacements: {count}")
with open(scene_path, "w", encoding="utf-8") as f:
    f.write(scene)
print("Saved.")
