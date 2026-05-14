scene_path = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_scene.dart"
with open(scene_path, "r", encoding="utf-8") as f:
    scene = f.read()

lines = scene.split("\n")
func_start = next(i for i,l in enumerate(lines) if "void _drawLeftHouse" in l)
func_end = next(i for i,l in enumerate(lines) if "void _drawRightHouse" in l)

print("=== ALL COLOURS IN LEFT HOUSE ===")
for i, l in enumerate(lines[func_start:func_end], start=func_start):
    if "0xFF" in l:
        print(i, repr(l.strip()))
