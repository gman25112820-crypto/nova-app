
scene_path = r'C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_scene.dart'
with open(scene_path, 'r', encoding='utf-8') as f:
    scene = f.read()

lines = scene.split('\n')
func_start = next(i for i,l in enumerate(lines) if 'void _drawRightHouse' in l)
print('_drawRightHouse starts at line', func_start)
for i, l in enumerate(lines[func_start:func_start+160], start=func_start):
    if any(k in l for k in ['roof','Roof','ridge','Ridge','moveTo','lineTo','drawPath','Paint','0xFF','gable','slope','garage','Garage','0xF']):
        print(i, repr(l))
