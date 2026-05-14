
scene_path = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_scene.dart"
with open(scene_path, "r", encoding="utf-8") as f:
    scene = f.read()

lines = scene.split("
")
# Find _drawRightHouse and show its roof section
func_start = next(i for i,l in enumerate(lines) if "void _drawRightHouse" in l)
print("_drawRightHouse starts at line", func_start)
# Show lines around the roof drawing
for i, l in enumerate(lines[func_start:func_start+120], start=func_start):
    if any(k in l for k in ["roof","Roof","ridge","Ridge","moveTo","lineTo","drawPath","Paint","0xFF","gable","slope","garage","Garage","pink","Pink"]):
        print(i, repr(l))
