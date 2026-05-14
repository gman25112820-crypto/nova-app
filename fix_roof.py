scene_path = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_scene.dart"
with open(scene_path, 'r', encoding='utf-8') as f:
    scene = f.read()

# Exact strings read from the repr() output in the screenshot
OLD = "// Roof planes\n    final ridgeX = wallL + wallW / 2;\n    final ridgeY = wallBot - wallH - roofH;\n    canvas.drawPath(\n      Path()\n        ..moveTo(wallL - w * 0.016, wallBot - wallH)\n        ..lineTo(ridgeX, ridgeY)\n        ..lineTo(ridgeX, ridgeY + h * 0.008)\n        ..lineTo(wallL - w * 0.016, wallBot - wallH + h * 0.006)\n        ..close(),\n      Paint()..color = const Color(0xFF9060CC),\n    );\n    canvas.drawPath(\n      Path()\n        ..moveTo(ridgeX, ridgeY)\n        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH)\n        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH + h * 0.006)\n        ..lineTo(ridgeX, ridgeY + h * 0.008)\n        ..close(),\n      Paint()..color = const Color(0xFF6038A0),"

NEW = "// Roof planes — solid triangles\n    final ridgeX = wallL + wallW / 2;\n    final ridgeY = wallBot - wallH - roofH;\n    // Left slope: left eave -> ridge apex -> centre-bottom\n    canvas.drawPath(\n      Path()\n        ..moveTo(wallL - w * 0.016, wallBot - wallH)\n        ..lineTo(ridgeX, ridgeY)\n        ..lineTo(ridgeX, wallBot - wallH)\n        ..close(),\n      Paint()..color = const Color(0xFFB060FF),\n    );\n    // Right slope: ridge apex -> right eave -> centre-bottom\n    canvas.drawPath(\n      Path()\n        ..moveTo(ridgeX, ridgeY)\n        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH)\n        ..lineTo(ridgeX, wallBot - wallH)\n        ..close(),\n      Paint()..color = const Color(0xFF8040D0),"

if OLD in scene:
    scene = scene.replace(OLD, NEW)
    print("SUCCESS: roof triangles fixed")
else:
    print("FAIL: string not matched")
    idx = scene.find('// Roof planes')
    print("idx=", idx)
    print(repr(scene[idx:idx+700]))

# Also fix left house wall colour to be more distinct from sky
scene = scene.replace(
    "Paint()..color = const Color(0xFF2D1B69),\n    );",
    "Paint()..color = const Color(0xFF3A20A0),\n    );",
    1
)

with open(scene_path, 'w', encoding='utf-8') as f:
    f.write(scene)
print("scene saved")
