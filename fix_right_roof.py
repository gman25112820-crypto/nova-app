scene_path = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_scene.dart"
with open(scene_path, "r", encoding="utf-8") as f:
    scene = f.read()

OLD_ROOF = (
    "    // Roof planes\n"
    "    final ridgeX = wallL + wallW / 2;\n"
    "    final ridgeY = wallBot - wallH - roofH;\n"
    "    canvas.drawPath(\n"
    "      Path()\n"
    "        ..moveTo(wallL - w * 0.016, wallBot - wallH)\n"
    "        ..lineTo(ridgeX, ridgeY)\n"
    "        ..lineTo(ridgeX, ridgeY + h * 0.008)\n"
    "        ..lineTo(wallL - w * 0.016, wallBot - wallH + h * 0.006)\n"
    "        ..close(),\n"
    "      Paint()..color = const Color(0xFF3A8058),\n"
    "    );\n"
    "    canvas.drawPath(\n"
    "      Path()\n"
    "        ..moveTo(ridgeX, ridgeY)\n"
    "        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH)\n"
    "        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH + h * 0.006)\n"
    "        ..lineTo(ridgeX, ridgeY + h * 0.008)\n"
    "        ..close(),\n"
    "      Paint()..color = const Color(0xFF245038),"
)

NEW_ROOF = (
    "    // Roof planes - solid gable triangles\n"
    "    final ridgeX = wallL + wallW / 2;\n"
    "    final ridgeY = wallBot - wallH - roofH;\n"
    "    canvas.drawPath(\n"
    "      Path()\n"
    "        ..moveTo(wallL - w * 0.016, wallBot - wallH)\n"
    "        ..lineTo(ridgeX, ridgeY)\n"
    "        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH)\n"
    "        ..close(),\n"
    "      Paint()..color = const Color(0xFF2AB870),\n"
    "    );\n"
    "    canvas.drawPath(\n"
    "      Path()\n"
    "        ..moveTo(ridgeX, ridgeY)\n"
    "        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH)\n"
    "        ..lineTo(ridgeX, wallBot - wallH)\n"
    "        ..close(),\n"
    "      Paint()..color = const Color(0xFF1A8050),"
)

if OLD_ROOF in scene:
    scene = scene.replace(OLD_ROOF, NEW_ROOF)
    print("SUCCESS: right house roof fixed")
else:
    print("FAIL: right roof not matched - checking colours present:")
    print("3A8058 present:", "3A8058" in scene)
    print("245038 present:", "245038" in scene)
    idx = scene.find("3A8058")
    if idx >= 0:
        print(repr(scene[idx-400:idx+100]))

# Fix garage - tone down pink
# Bright pink garage door: replace neon pink with dusty rose
old_garage = "const Color(0xFFFFB3C6)"
new_garage = "const Color(0xFFD4788A)"
if old_garage in scene:
    scene = scene.replace(old_garage, new_garage)
    print("garage pink toned down (B3C6)")
else:
    # Try other pink candidates near garage drawing
    import re
    for m in re.finditer(r"0xFF[FE][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9]", scene):
        ctx = scene[m.start()-100:m.start()+30]
        if any(k in ctx for k in ["garage","Garage","door","Door","pink","Pink"]):
            print("Garage candidate:", m.group(), "at", m.start())
            print(repr(ctx))

with open(scene_path, "w", encoding="utf-8") as f:
    f.write(scene)
print("saved")
