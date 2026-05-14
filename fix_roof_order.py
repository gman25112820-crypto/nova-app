scene_path = r"C:\Users\Garet\nova_app\lib\fab\widgets\fab_world_scene.dart"
with open(scene_path, 'r', encoding='utf-8') as f:
    scene = f.read()

# The left slope triangle needs a slightly different geometry.
# Currently: left=(wallL-0.016w, wallBot-wallH), apex=(ridgeX,ridgeY), base=(ridgeX,wallBot-wallH)
# The base point (ridgeX, wallBot-wallH) is at the TOP of the wall, centre.
# The wall rect covers wallL to wallL+wallW from wallBot-wallH DOWN to wallBot.
# So the triangle base sits exactly ON TOP of the wall — it should be visible.
# The real issue: left slope colour 0xFFB060FF may be rendering UNDER right slope.
# Fix: make left slope a full triangle from left-eave to apex to RIGHT-eave (full gable)
# and right slope a darker overlay on just the right half. OR simply reorder: draw right FIRST then left.

# Current NEW roof (from last fix):
OLD = """    // Left slope: left eave -> ridge apex -> centre-bottom
    canvas.drawPath(
      Path()
        ..moveTo(wallL - w * 0.016, wallBot - wallH)
        ..lineTo(ridgeX, ridgeY)
        ..lineTo(ridgeX, wallBot - wallH)
        ..close(),
      Paint()..color = const Color(0xFFB060FF),
    );
    // Right slope: ridge apex -> right eave -> centre-bottom
    canvas.drawPath(
      Path()
        ..moveTo(ridgeX, ridgeY)
        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH)
        ..lineTo(ridgeX, wallBot - wallH)
        ..close(),
      Paint()..color = const Color(0xFF8040D0),"""

# Replace with: full gable triangle first (whole roof shape), then right-slope darker overlay
NEW = """    // Full gable: one solid triangle covering entire roof footprint
    canvas.drawPath(
      Path()
        ..moveTo(wallL - w * 0.016, wallBot - wallH)
        ..lineTo(ridgeX, ridgeY)
        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH)
        ..close(),
      Paint()..color = const Color(0xFFB060FF),
    );
    // Right slope darker overlay for 3D effect
    canvas.drawPath(
      Path()
        ..moveTo(ridgeX, ridgeY)
        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH)
        ..lineTo(ridgeX, wallBot - wallH)
        ..close(),
      Paint()..color = const Color(0xFF8040D0),"""

if OLD in scene:
    scene = scene.replace(OLD, NEW)
    print("SUCCESS: full gable triangle applied")
else:
    print("FAIL: not matched")
    idx = scene.find('// Left slope:')
    if idx >= 0:
        print(repr(scene[idx:idx+500]))
    else:
        idx2 = scene.find('// Roof planes')
        print("Roof planes idx:", idx2)
        if idx2 >= 0:
            print(repr(scene[idx2:idx2+600]))

with open(scene_path, 'w', encoding='utf-8') as f:
    f.write(scene)
print("saved")
