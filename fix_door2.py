"""
fix_door2.py - Tone down Chicken Home door in FabWorldPainter.

The old world-scene drawing code had a neon pink door (0xFFFA3890)
that was too saturated against the deep purple wall.  This script
updates FabWorldPainter._drawChickenHome to use a warm dusky rose
door gradient instead of gold, and softens the roof gradient tip so
the door area does not visually bleed.
"""

PAINTER = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_painter.dart"

with open(PAINTER, "r", encoding="utf-8") as f:
    src = f.read()

changes = 0

# Door: gold -> warm dusky rose
OLD_DOOR = (
    "      Paint()..shader = LinearGradient(\n"
    "        begin: Alignment.topCenter, end: Alignment.bottomCenter,\n"
    "        colors: [FabColors.gold, const Color(0xFFD4A800)],\n"
    "      ).createShader(Rect.fromLTWH(cx - 17, gY - 54, 34, 54)),"
)
NEW_DOOR = (
    "      Paint()..shader = LinearGradient(\n"
    "        begin: Alignment.topCenter, end: Alignment.bottomCenter,\n"
    "        colors: [const Color(0xFFB85070), const Color(0xFF8A3050)],\n"
    "      ).createShader(Rect.fromLTWH(cx - 17, gY - 54, 34, 54)),"
)
if OLD_DOOR in src:
    src = src.replace(OLD_DOOR, NEW_DOOR)
    print("door: gold -> dusky rose")
    changes += 1
else:
    print("WARN: door gradient not matched -- already changed?")

# Door knob: dark gold -> dark rose to match
OLD_KNOB = "Paint()..color = const Color(0xFF8B6914)"
NEW_KNOB = "Paint()..color = const Color(0xFF6B2030)"
if OLD_KNOB in src:
    src = src.replace(OLD_KNOB, NEW_KNOB)
    print("door knob: dark gold -> dark rose")
    changes += 1
else:
    print("WARN: door knob colour not matched")

# Roof tip: neon 0xFFFF6B9D -> muted 0xFFD06080
OLD_ROOF_TIP = "const Color(0xFFFF6B9D)"
NEW_ROOF_TIP = "const Color(0xFFD06080)"
if OLD_ROOF_TIP in src:
    src = src.replace(OLD_ROOF_TIP, NEW_ROOF_TIP)
    print("chicken-home roof tip: neon pink -> muted rose")
    changes += 1
else:
    print("WARN: roof tip 0xFFFF6B9D not found")

print("\nTotal changes:", changes)
with open(PAINTER, "w", encoding="utf-8") as f:
    f.write(src)
print("Saved:", PAINTER)
