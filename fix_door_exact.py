scene_path = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_scene.dart"
with open(scene_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

changes = 0
for i, line in enumerate(lines):
    if i == 1578 and "0xFFF5A3890" in line:
        lines[i] = line.replace("0xFFF5A3890", "0xFF7A2855")
        print(f"Fixed line 1579: door outline")
        changes += 1
    elif i == 1585 and "0xFFFA3890" in line:
        lines[i] = line.replace("0xFFFA3890", "0xFF8B3060")
        print(f"Fixed line 1586: door fill")
        changes += 1
    elif "0xFFF5A3890" in line:
        lines[i] = line.replace("0xFFF5A3890", "0xFF7A2855")
        print(f"Fixed door outline at line {i+1}")
        changes += 1
    elif "0xFFFA3890" in line and "roof" not in line.lower():
        lines[i] = line.replace("0xFFFA3890", "0xFF8B3060")
        print(f"Fixed door fill at line {i+1}")
        changes += 1

print(f"Total: {changes} changes")
with open(scene_path, "w", encoding="utf-8") as f:
    f.writelines(lines)
print("Saved")
