import os

theme_path = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_theme.dart"
with open(theme_path, 'r', encoding='utf-8') as f:
    theme = f.read()

old = "          Color(0xFF0D0A2E),\n          Color(0xFF1A1045),\n          Color(0xFF2D1B5E),\n          Color(0xFF3D2E6B),"
new = "          Color(0xFF1A0F4A),\n          Color(0xFF2A1870),\n          Color(0xFF3D2490),\n          Color(0xFF4E3580),"
if old in theme:
    theme = theme.replace(old, new)
    print("spring sky patched")
else:
    print("spring sky NOT found")

old2 = "          Color(0xFF070A24),\n          Color(0xFF0B1733),\n          Color(0xFF142A45),\n          Color(0xFF203A52),"
new2 = "          Color(0xFF071A38),\n          Color(0xFF0D2850),\n          Color(0xFF143868),\n          Color(0xFF1E4A78),"
if old2 in theme:
    theme = theme.replace(old2, new2)
    print("summer sky patched")
else:
    print("summer sky NOT found")

with open(theme_path, 'w', encoding='utf-8') as f:
    f.write(theme)
print("theme saved")

scene_path = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_scene.dart"
with open(scene_path, 'r', encoding='utf-8') as f:
    scene = f.read()

idx = scene.find('// Roof planes')
print("Roof planes at char:", idx)
if idx >= 0:
    print(repr(scene[idx:idx+600]))
