scene_path = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_scene.dart"
with open(scene_path, "r", encoding='utf-8') as f:
    scene = f.read()

lines = scene.split("\n")

for i in range(1570, 1610):
    if i < len(lines) and "0xFF" in lines[i]:
        print(i, repr(lines[i]))
