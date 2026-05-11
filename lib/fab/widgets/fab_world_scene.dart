import 'dart:math';
import 'package:flutter/material.dart';
import 'living_world_character.dart';

// ─────────────────────────────────────────────────────────────
// FAB WORLD SCENE — Living Calm World v5.2
//
// Updates:
// - Characters use LivingWorldCharacter for depth, shadows and soft movement.
// - Left chicken family slimmed down and better spaced.
// - Ollie giraffe is taller/wider.
// - Theo giraffe is shorter/leaner.
// - Labels removed for a cleaner professional scene.
// ─────────────────────────────────────────────────────────────

class FabWorldScene extends StatefulWidget {
  const FabWorldScene({super.key});

  @override
  State<FabWorldScene> createState() => _FabWorldSceneState();
}

class _FabWorldSceneState extends State<FabWorldScene>
    with TickerProviderStateMixin {
  late final AnimationController _worldCtrl;
  late final AnimationController _starCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _windowCtrl;

  @override
  void initState() {
    super.initState();

    _worldCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _windowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _worldCtrl.dispose();
    _starCtrl.dispose();
    _glowCtrl.dispose();
    _windowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _worldCtrl,
        _starCtrl,
        _glowCtrl,
        _windowCtrl,
      ]),
      builder: (context, _) {
        final worldP = _worldCtrl.value;
        final starP = _starCtrl.value;
        final glowP = _glowCtrl.value;
        final winP = _windowCtrl.value;

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            final familyPull = sin(worldP * pi * 2) * 1.8;
            final dogPull = sin(worldP * pi * 2 + 1.4) * 2.2;
            final chickenPull = sin(worldP * pi * 2 + 2.1) * 1.4;
            final giraffeProtectiveLean = sin(worldP * pi * 2 + 0.9) * 1.6;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LivingWorldPainter(
                      starPhase: starP,
                      glowPhase: glowP,
                      windowPhase: winP,
                      worldPhase: worldP,
                    ),
                  ),
                ),

                // ─────────────────────────────────────
                // Window cats — small background life
                // ─────────────────────────────────────

                Positioned(
                  left: w * 0.118,
                  bottom: h * 0.440,
                  child: LivingWorldCharacter(
                    assetPath: 'assets/images/characters/cat1.png',
                    width: w * 0.050,
                    phase: worldP + 0.10,
                    motion: LivingCharacterMotion.curious,
                    shadowStrength: 0.10,
                    depth: 0.76,
                    interactionPull: sin(worldP * pi * 2) * 0.8,
                  ),
                ),

                Positioned(
                  left: w * 0.210,
                  bottom: h * 0.440,
                  child: LivingWorldCharacter(
                    assetPath: 'assets/images/characters/cat2.png',
                    width: w * 0.050,
                    phase: worldP + 0.42,
                    motion: LivingCharacterMotion.sleepy,
                    shadowStrength: 0.10,
                    depth: 0.76,
                    flipped: true,
                    interactionPull: -sin(worldP * pi * 2) * 0.8,
                  ),
                ),

                // ─────────────────────────────────────
                // Left family / Chicken Lips side
                // Slimmed and rebalanced
                // ─────────────────────────────────────

                Positioned(
                  left: w * 0.080,
                  bottom: h * 0.176,
                  child: Transform.scale(
                    scaleX: 0.96,
                    scaleY: 0.96,
                    alignment: Alignment.bottomCenter,
                    child: LivingWorldCharacter(
                      assetPath: 'assets/images/characters/teds.png',
                      width: w * 0.062,
                      phase: worldP + 0.22,
                      motion: LivingCharacterMotion.sleepy,
                      shadowStrength: 0.24,
                      depth: 1.00,
                      interactionPull: dogPull * 0.30,
                    ),
                  ),
                ),

                Positioned(
                  left: w * 0.148,
                  bottom: h * 0.181,
                  child: Transform.scale(
                    scaleX: 0.94,
                    scaleY: 0.97,
                    alignment: Alignment.bottomCenter,
                    child: LivingWorldCharacter(
                      assetPath: 'assets/images/characters/daughter_7.png',
                      width: w * 0.066,
                      phase: worldP + 0.35,
                      motion: LivingCharacterMotion.playful,
                      shadowStrength: 0.23,
                      depth: 1.00,
                      interactionPull: familyPull * 0.70,
                    ),
                  ),
                ),

                Positioned(
                  left: w * 0.214,
                  bottom: h * 0.184,
                  child: Transform.scale(
                    scaleX: 0.93,
                    scaleY: 1.00,
                    alignment: Alignment.bottomCenter,
                    child: LivingWorldCharacter(
                      assetPath: 'assets/images/characters/daughter_9.png',
                      width: w * 0.072,
                      phase: worldP + 0.55,
                      motion: LivingCharacterMotion.curious,
                      shadowStrength: 0.24,
                      depth: 1.02,
                      interactionPull: -familyPull * 0.40,
                    ),
                  ),
                ),

                Positioned(
                  left: w * 0.292,
                  bottom: h * 0.183,
                  child: Transform.scale(
                    scaleX: 0.92,
                    scaleY: 0.98,
                    alignment: Alignment.bottomCenter,
                    child: LivingWorldCharacter(
                      assetPath: 'assets/images/chicken_lips.png',
                      width: w * 0.089,
                      phase: worldP + 0.74,
                      motion: LivingCharacterMotion.protective,
                      shadowStrength: 0.28,
                      depth: 1.04,
                      interactionPull: chickenPull * 0.9,
                    ),
                  ),
                ),

                // ─────────────────────────────────────
                // Right family / giraffe side
                // Ollie elder = taller/wider
                // Theo younger = shorter/leaner
                // ─────────────────────────────────────

                Positioned(
                  left: w * 0.658,
                  bottom: h * 0.176,
                  child: LivingWorldCharacter(
                    assetPath: 'assets/images/characters/jack_russell.png',
                    width: w * 0.060,
                    phase: worldP + 0.16,
                    motion: LivingCharacterMotion.playful,
                    shadowStrength: 0.26,
                    depth: 1.02,
                    flipped: true,
                    interactionPull: -dogPull * 0.5,
                  ),
                ),

                Positioned(
                  left: w * 0.700,
                  bottom: h * 0.188,
                  child: Transform.scale(
                    scaleX: 1.08,
                    scaleY: 1.10,
                    alignment: Alignment.bottomCenter,
                    child: LivingWorldCharacter(
                      assetPath: 'assets/images/characters/son_giraffe_2.png',
                      width: w * 0.090,
                      phase: worldP + 0.48,
                      motion: LivingCharacterMotion.curious,
                      shadowStrength: 0.27,
                      depth: 1.06,
                      interactionPull: familyPull * 0.55,
                    ),
                  ),
                ),

                Positioned(
                  left: w * 0.782,
                  bottom: h * 0.186,
                  child: Transform.scale(
                    scaleX: 0.92,
                    scaleY: 0.96,
                    alignment: Alignment.bottomCenter,
                    child: LivingWorldCharacter(
                      assetPath: 'assets/images/characters/son_giraffe_1.png',
                      width: w * 0.090,
                      phase: worldP + 0.68,
                      motion: LivingCharacterMotion.calm,
                      shadowStrength: 0.26,
                      depth: 1.00,
                      interactionPull: -familyPull * 0.35,
                    ),
                  ),
                ),

                Positioned(
                  left: w * 0.842,
                  bottom: h * 0.192,
                  child: LivingWorldCharacter(
                    assetPath: 'assets/images/characters/dad_giraffe.png',
                    width: w * 0.120,
                    phase: worldP + 0.86,
                    motion: LivingCharacterMotion.protective,
                    shadowStrength: 0.34,
                    depth: 1.08,
                    interactionPull: giraffeProtectiveLean,
                  ),
                ),

                // ─────────────────────────────────────
                // Foreground depth strip
                // ─────────────────────────────────────

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: h * 0.105,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0D1B2A).withValues(alpha: 0.50),
                            const Color(0xFF0D1B2A).withValues(alpha: 0.88),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PAINTER
// ─────────────────────────────────────────────────────────────

class _LivingWorldPainter extends CustomPainter {
  final double starPhase;
  final double glowPhase;
  final double windowPhase;
  final double worldPhase;

  const _LivingWorldPainter({
    required this.starPhase,
    required this.glowPhase,
    required this.windowPhase,
    required this.worldPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawSky(canvas, w, h);
    _drawStars(canvas, w, h);
    _drawMoon(canvas, w, h);
    _drawMountains(canvas, w, h);
    _drawForestBack(canvas, w, h);
    _drawForestMid(canvas, w, h);
    _drawGround(canvas, w, h);
    _drawLeftHouse(canvas, w, h);
    _drawRightHouse(canvas, w, h);
    _drawGate(canvas, w, h);
    _drawPath(canvas, w, h);
    _drawNearTrees(canvas, w, h);
    _drawFireflies(canvas, w, h);
    _drawSoftVignette(canvas, w, h);
  }

  void _drawSky(Canvas canvas, double w, double h) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF070A24),
          Color(0xFF0B1733),
          Color(0xFF142A45),
          Color(0xFF203A52),
        ],
        stops: [0.0, 0.32, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), sky);
  }

  void _drawStars(Canvas canvas, double w, double h) {
    final rng = Random(44);

    for (int i = 0; i < 72; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.52;
      final twinkle = (sin(starPhase * pi * 2 + i * 0.68) + 1) / 2;
      final r = 0.6 + rng.nextDouble() * 1.1;

      canvas.drawCircle(
        Offset(x, y),
        r * (0.62 + twinkle * 0.45),
        Paint()..color = Colors.white.withValues(alpha: 0.24 + twinkle * 0.60),
      );
    }
  }

  void _drawMoon(Canvas canvas, double w, double h) {
    final t = (sin(glowPhase * pi * 2) + 1) / 2;
    final cx = w * 0.82;
    final cy = h * 0.105;

    canvas.drawCircle(
      Offset(cx, cy),
      40,
      Paint()
        ..color = const Color(0xFFE8F4FD).withValues(alpha: 0.055 + t * 0.035)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    canvas.drawCircle(
      Offset(cx, cy),
      18,
      Paint()..color = const Color(0xFFF3FAFF).withValues(alpha: 0.90),
    );

    canvas.drawCircle(
      Offset(cx + 6, cy - 2),
      15,
      Paint()..color = const Color(0xFF0B1733).withValues(alpha: 0.78),
    );
  }

  void _drawMountains(Canvas canvas, double w, double h) {
    final far = Paint()
      ..color = const Color(0xFF1B2E4A).withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final farPath = Path()
      ..moveTo(0, h * 0.50)
      ..lineTo(w * 0.10, h * 0.30)
      ..lineTo(w * 0.21, h * 0.43)
      ..lineTo(w * 0.33, h * 0.24)
      ..lineTo(w * 0.47, h * 0.44)
      ..lineTo(w * 0.60, h * 0.28)
      ..lineTo(w * 0.74, h * 0.45)
      ..lineTo(w * 0.88, h * 0.31)
      ..lineTo(w, h * 0.48)
      ..lineTo(w, h * 0.58)
      ..lineTo(0, h * 0.58)
      ..close();

    canvas.drawPath(farPath, far);

    final near = Paint()..color = const Color(0xFF14263E).withValues(alpha: 0.75);

    final nearPath = Path()
      ..moveTo(0, h * 0.56)
      ..lineTo(w * 0.12, h * 0.39)
      ..lineTo(w * 0.25, h * 0.50)
      ..lineTo(w * 0.38, h * 0.33)
      ..lineTo(w * 0.52, h * 0.49)
      ..lineTo(w * 0.66, h * 0.34)
      ..lineTo(w * 0.80, h * 0.50)
      ..lineTo(w * 0.94, h * 0.38)
      ..lineTo(w, h * 0.48)
      ..lineTo(w, h * 0.62)
      ..lineTo(0, h * 0.62)
      ..close();

    canvas.drawPath(nearPath, near);
  }

  void _drawForestBack(Canvas canvas, double w, double h) {
    final rng = Random(71);

    for (int i = 0; i < 28; i++) {
      final x = (i / 27) * w;
      final treeH = h * (0.13 + rng.nextDouble() * 0.10);
      final treeW = w * (0.020 + rng.nextDouble() * 0.012);
      final baseY = h * 0.68;
      final sway = sin(worldPhase * pi * 2 + i * 0.4) * 1.5;

      final path = Path()
        ..moveTo(x - treeW, baseY)
        ..lineTo(x + sway, baseY - treeH)
        ..lineTo(x + treeW, baseY)
        ..close();

      canvas.drawPath(
        path,
        Paint()..color = const Color(0xFF183A42).withValues(alpha: 0.52),
      );
    }
  }

  void _drawForestMid(Canvas canvas, double w, double h) {
    final rng = Random(93);
    final t = (sin(glowPhase * pi * 2) + 1) / 2;

    for (int i = 0; i < 22; i++) {
      final x = (i / 21) * w;
      final treeH = h * (0.18 + rng.nextDouble() * 0.13);
      final treeW = w * (0.028 + rng.nextDouble() * 0.018);
      final baseY = h * 0.735;
      final sway = sin(worldPhase * pi * 2 + i * 0.55) * 2.3;

      final isGlowTree = i % 4 == 0;
      final paint = Paint()
        ..color = isGlowTree
            ? const Color(0xFF1DE9B6).withValues(alpha: 0.22 + t * 0.12)
            : const Color(0xFF16482F).withValues(alpha: 0.72);

      if (isGlowTree) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      }

      final path = Path()
        ..moveTo(x - treeW, baseY)
        ..lineTo(x + sway, baseY - treeH)
        ..lineTo(x + treeW, baseY)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  void _drawGround(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(0, h * 0.70, w, h * 0.30);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF224429),
            Color(0xFF142B1E),
            Color(0xFF0C1C14),
          ],
        ).createShader(rect),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.70, w, 2),
      Paint()..color = const Color(0xFF6FD18A).withValues(alpha: 0.18),
    );
  }

  void _drawLeftHouse(Canvas canvas, double w, double h) {
    final wallL = w * 0.082;
    final wallW = w * 0.225;
    final wallBot = h * 0.735;
    final wallH = h * 0.315;
    final roofH = h * 0.120;

    final shadowRect = Rect.fromLTWH(
      wallL - w * 0.012,
      wallBot - wallH + 8,
      wallW + w * 0.024,
      wallH,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()..color = const Color(0xFF2D1B69),
    );

    final roof = Path()
      ..moveTo(wallL - w * 0.016, wallBot - wallH)
      ..lineTo(wallL + wallW / 2, wallBot - wallH - roofH)
      ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH)
      ..close();

    canvas.drawPath(
      roof,
      Paint()..color = const Color(0xFF7C4FBC),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        wallL + wallW * 0.72,
        wallBot - wallH - roofH * 0.72,
        w * 0.020,
        roofH * 0.58,
      ),
      Paint()..color = const Color(0xFF5A3890),
    );

    final winGlow = (sin(windowPhase * pi * 2) + 1) / 2;
    final winCol = Color.lerp(
      const Color(0xFFFFE082).withValues(alpha: 0.58),
      const Color(0xFFFFB300).withValues(alpha: 0.88),
      winGlow,
    )!;

    _window(
      canvas,
      wallL + wallW * 0.18,
      wallBot - wallH * 0.62,
      w * 0.055,
      h * 0.075,
      winCol,
    );

    _window(
      canvas,
      wallL + wallW * 0.58,
      wallBot - wallH * 0.62,
      w * 0.055,
      h * 0.075,
      winCol,
    );

    _door(
      canvas,
      wallL + wallW * 0.50,
      wallBot,
      w * 0.055,
      h * 0.116,
      const Color(0xFFFF80AB),
    );

    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()
        ..color = const Color(0xFFFF80AB).withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawRightHouse(Canvas canvas, double w, double h) {
    final wallL = w * 0.635;
    final wallW = w * 0.235;
    final wallBot = h * 0.735;
    final wallH = h * 0.305;
    final roofH = h * 0.116;

    final shadowRect = Rect.fromLTWH(
      wallL - w * 0.012,
      wallBot - wallH + 8,
      wallW + w * 0.024,
      wallH,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()..color = const Color(0xFF1B3828),
    );

    final roof = Path()
      ..moveTo(wallL - w * 0.016, wallBot - wallH)
      ..lineTo(wallL + wallW / 2, wallBot - wallH - roofH)
      ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH)
      ..close();

    canvas.drawPath(
      roof,
      Paint()..color = const Color(0xFF2E6B4A),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        wallL + wallW * 0.25,
        wallBot - wallH - roofH * 0.70,
        w * 0.020,
        roofH * 0.56,
      ),
      Paint()..color = const Color(0xFF1E5238),
    );

    final winGlow = (sin(windowPhase * pi * 2 + pi) + 1) / 2;
    final winCol = Color.lerp(
      const Color(0xFFB2DFDB).withValues(alpha: 0.48),
      const Color(0xFF80CBC4).withValues(alpha: 0.84),
      winGlow,
    )!;

    _window(
      canvas,
      wallL + wallW * 0.14,
      wallBot - wallH * 0.60,
      w * 0.055,
      h * 0.072,
      winCol,
    );

    _window(
      canvas,
      wallL + wallW * 0.56,
      wallBot - wallH * 0.60,
      w * 0.055,
      h * 0.072,
      winCol,
    );

    _door(
      canvas,
      wallL + wallW * 0.50,
      wallBot,
      w * 0.055,
      h * 0.112,
      const Color(0xFF4DB6AC),
    );

    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()
        ..color = const Color(0xFF4DB6AC).withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _window(
    Canvas canvas,
    double x,
    double y,
    double ww,
    double wh,
    Color glow,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 4, y - 4, ww + 8, wh + 8),
        const Radius.circular(6),
      ),
      Paint()
        ..color = glow.withValues(alpha: 0.36)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, ww, wh),
        const Radius.circular(5),
      ),
      Paint()..color = glow,
    );

    final line = Paint()
      ..color = Colors.black.withValues(alpha: 0.24)
      ..strokeWidth = 0.9;

    canvas.drawLine(Offset(x + ww / 2, y), Offset(x + ww / 2, y + wh), line);
    canvas.drawLine(Offset(x, y + wh / 2), Offset(x + ww, y + wh / 2), line);
  }

  void _door(
    Canvas canvas,
    double x,
    double bottom,
    double dw,
    double dh,
    Color color,
  ) {
    final rect = Rect.fromLTWH(x - dw / 2, bottom - dh, dw, dh);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(7),
        topRight: const Radius.circular(7),
      ),
      Paint()..color = color.withValues(alpha: 0.92),
    );

    canvas.drawCircle(
      Offset(x + dw * 0.28, bottom - dh * 0.40),
      dw * 0.10,
      Paint()..color = Colors.white.withValues(alpha: 0.62),
    );
  }

  void _drawGate(Canvas canvas, double w, double h) {
    final gx = w * 0.474;
    final gBot = h * 0.735;
    final gH = h * 0.122;
    final gW = w * 0.068;

    final paint = Paint()
      ..color = const Color(0xFFE8D5B0).withValues(alpha: 0.80)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(gx, gBot), Offset(gx, gBot - gH), paint);
    canvas.drawLine(Offset(gx + gW, gBot), Offset(gx + gW, gBot - gH), paint);

    canvas.drawLine(
      Offset(gx, gBot - gH * 0.25),
      Offset(gx + gW, gBot - gH * 0.25),
      paint,
    );

    canvas.drawLine(
      Offset(gx, gBot - gH * 0.65),
      Offset(gx + gW, gBot - gH * 0.65),
      paint,
    );

    for (int i = 0; i <= 3; i++) {
      final px = gx + (gW / 3) * i;
      canvas.drawLine(
        Offset(px, gBot - gH * 0.25),
        Offset(px, gBot - gH),
        paint,
      );
    }
  }

  void _drawPath(Canvas canvas, double w, double h) {
    final pathPaint = Paint()
      ..color = const Color(0xFFBCA77B).withValues(alpha: 0.12);

    final path = Path()
      ..moveTo(w * 0.47, h * 0.735)
      ..quadraticBezierTo(w * 0.50, h * 0.82, w * 0.48, h)
      ..lineTo(w * 0.58, h)
      ..quadraticBezierTo(w * 0.54, h * 0.82, w * 0.54, h * 0.735)
      ..close();

    canvas.drawPath(path, pathPaint);

    final stonePaint = Paint()
      ..color = const Color(0xFFE8D5B0).withValues(alpha: 0.18);

    for (int i = 0; i < 5; i++) {
      final y = h * (0.765 + i * 0.042);
      final x = w * (0.505 + sin(i * 1.7) * 0.018);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: w * 0.040,
          height: h * 0.016,
        ),
        stonePaint,
      );
    }
  }

  void _drawNearTrees(Canvas canvas, double w, double h) {
    final leftTree = Paint()
      ..color = const Color(0xFF082218).withValues(alpha: 0.74)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    final rightTree = Paint()
      ..color = const Color(0xFF082218).withValues(alpha: 0.70)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    _largeTree(canvas, w * 0.015, h * 0.765, w * 0.085, h * 0.360, leftTree);
    _largeTree(canvas, w * 0.960, h * 0.765, w * 0.095, h * 0.390, rightTree);
  }

  void _largeTree(
    Canvas canvas,
    double x,
    double base,
    double treeW,
    double treeH,
    Paint paint,
  ) {
    final trunk = Paint()..color = const Color(0xFF2A180C).withValues(alpha: 0.66);

    canvas.drawRect(
      Rect.fromLTWH(
        x - treeW * 0.08,
        base - treeH * 0.45,
        treeW * 0.16,
        treeH * 0.45,
      ),
      trunk,
    );

    final top = Path()
      ..moveTo(x - treeW * 0.55, base - treeH * 0.05)
      ..lineTo(x, base - treeH)
      ..lineTo(x + treeW * 0.55, base - treeH * 0.05)
      ..close();

    final mid = Path()
      ..moveTo(x - treeW * 0.50, base - treeH * 0.28)
      ..lineTo(x, base - treeH * 0.92)
      ..lineTo(x + treeW * 0.50, base - treeH * 0.28)
      ..close();

    canvas.drawPath(top, paint);
    canvas.drawPath(mid, paint);
  }

  void _drawFireflies(Canvas canvas, double w, double h) {
    final rng = Random(101);
    final t = (sin(glowPhase * pi * 2) + 1) / 2;

    for (int i = 0; i < 18; i++) {
      final x = rng.nextDouble() * w;
      final y = h * (0.50 + rng.nextDouble() * 0.28);
      final drift = sin(worldPhase * pi * 2 + i) * 4;
      final opacity = 0.10 + t * 0.20 + rng.nextDouble() * 0.10;

      canvas.drawCircle(
        Offset(x + drift, y),
        1.4 + rng.nextDouble() * 1.4,
        Paint()
          ..color = const Color(0xFFFFF59D).withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  void _drawSoftVignette(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(0, 0, w, h);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 1.1,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.32),
          ],
          stops: const [0.0, 0.68, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _LivingWorldPainter oldDelegate) {
    return oldDelegate.starPhase != starPhase ||
        oldDelegate.glowPhase != glowPhase ||
        oldDelegate.windowPhase != windowPhase ||
        oldDelegate.worldPhase != worldPhase;
  }
}