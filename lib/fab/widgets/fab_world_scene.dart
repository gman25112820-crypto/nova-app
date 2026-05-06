import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// FAB WORLD SCENE — Calm World v4.1
//
// Fixed-width parallax depth scene — no scrolling
// Layers back→front:
//   1. Teal twilight sky + stars + moon
//   2. Distant misty mountains
//   3. Deep forest (small, desaturated)
//   4. Mid forest (medium, glowing)
//   5. Two storybook houses + garden gate
//   6. Near forest edges (large, vivid)
//   7. Characters (PNG assets)
//   8. Foreground depth strip
// ─────────────────────────────────────────────────────────────

class FabWorldScene extends StatefulWidget {
  const FabWorldScene({super.key});

  @override
  State<FabWorldScene> createState() => _FabWorldSceneState();
}

class _FabWorldSceneState extends State<FabWorldScene>
    with TickerProviderStateMixin {
  late AnimationController _starCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _swayCtrl;
  late AnimationController _bounceCtrl;
  late AnimationController _fireCtrl;
  late AnimationController _winCtrl;

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _swayCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _fireCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _winCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    _swayCtrl.dispose();
    _bounceCtrl.dispose();
    _fireCtrl.dispose();
    _winCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _starCtrl, _glowCtrl, _floatCtrl, _swayCtrl,
        _bounceCtrl, _fireCtrl, _winCtrl,
      ]),
      builder: (context, _) {
        final starP  = _starCtrl.value;
        final glowP  = _glowCtrl.value;
        final floatP = _floatCtrl.value;
        final swayP  = _swayCtrl.value;
        final bounceP= _bounceCtrl.value;
        final fireP  = _fireCtrl.value;
        final winP   = _winCtrl.value;

        return LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          // ── Animation values ───────────────────────────
          final floatA = sin(floatP * pi * 2) * 3.0;
          final floatB = sin(floatP * pi * 2 + 0.8) * 2.5;
          final floatC = sin(floatP * pi * 2 + 1.6) * 2.0;
          final floatD = sin(floatP * pi * 2 + 2.4) * 2.8;
          final floatE = sin(floatP * pi * 2 + 0.4) * 1.5;
          final floatF = sin(floatP * pi * 2 + 1.2) * 2.2;
          final floatG = sin(floatP * pi * 2 + 2.0) * 1.8;
          final floatH = sin(floatP * pi * 2 + 3.0) * 2.0;

          final swayA = sin(swayP * pi * 2) * 0.018;
          final swayB = sin(swayP * pi * 2 + 1.0) * 0.015;
          final swayC = sin(swayP * pi * 2 + 2.0) * 0.020;
          final swayD = sin(swayP * pi * 2 + 0.5) * 0.022;
          final swayF = sin(swayP * pi * 2 + 1.5) * 0.014;
          final swayG = sin(swayP * pi * 2 + 2.5) * 0.016;

          return Stack(children: [

            // ══════════════════════════════════════════
            // LAYER 1 — Sky + Stars + Moon
            // ══════════════════════════════════════════
            Positioned.fill(
              child: CustomPaint(
                painter: _SkyPainter(
                  starPhase: starP,
                  glowPhase: glowP,
                  floatPhase: floatP,
                  swayPhase: swayP,
                  firePhase: fireP,
                  winPhase: winP,
                ),
              ),
            ),

            // ══════════════════════════════════════════
            // CHARACTERS
            // ══════════════════════════════════════════

            // ── Cat 1 — left house LEFT window ────────
            // Fixed: bottom: h * 0.440 puts them inside the windows
            Positioned(
              left: w * 0.118,
              bottom: h * 0.440,
              child: Transform.translate(
                offset: Offset(0, floatE),
                child: Image.asset(
                  'assets/images/characters/cat1.png',
                  width: w * 0.050,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

            // ── Cat 2 — left house RIGHT window ───────
            Positioned(
              left: w * 0.210,
              bottom: h * 0.440,
              child: Transform.translate(
                offset: Offset(0, -floatE),
                child: Image.asset(
                  'assets/images/characters/cat2.png',
                  width: w * 0.050,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

            // ── Teds (Shih Tzu) — far left ground ─────
            Positioned(
              left: w * 0.085,
              bottom: h * 0.185,
              child: Transform.rotate(
                angle: swayD,
                child: Transform.translate(
                  offset: Offset(0, floatD),
                  child: Image.asset(
                    'assets/images/characters/teds.png',
                    width: w * 0.062,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            // ── Daughter age 7 — front left ───────────
            Positioned(
              left: w * 0.155,
              bottom: h * 0.185,
              child: Transform.rotate(
                angle: swayC,
                child: Transform.translate(
                  offset: Offset(0, floatC),
                  child: Image.asset(
                    'assets/images/characters/daughter_7.png',
                    width: w * 0.068,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            // ── Daughter age 9 — mid left ─────────────
            Positioned(
              left: w * 0.218,
              bottom: h * 0.190,
              child: Transform.rotate(
                angle: swayB,
                child: Transform.translate(
                  offset: Offset(0, floatB),
                  child: Image.asset(
                    'assets/images/characters/daughter_9.png',
                    width: w * 0.078,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            // ── Mum (Chicken Lips) — centre-left ──────
            Positioned(
              left: w * 0.285,
              bottom: h * 0.188,
              child: Transform.rotate(
                angle: swayA,
                child: Transform.translate(
                  offset: Offset(0, floatA),
                  child: Image.asset(
                    'assets/images/chicken_lips.png',
                    width: w * 0.095,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            // ── Eddie (Jack Russell) — right side, small
            Positioned(
              left: w * 0.660,
              bottom: h * 0.186,
              child: Transform.rotate(
                angle: swayD,
                child: Transform.translate(
                  offset: Offset(0, floatH),
                  child: Image.asset(
                    'assets/images/characters/jack_russell.png',
                    width: w * 0.058,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            // ── Ollie / Son 2 (younger, tan hoodie) ───
            // Positioned in front of Theo, closer to gate
            Positioned(
              left: w * 0.710,
              bottom: h * 0.190,
              child: Transform.rotate(
                angle: swayG,
                child: Transform.translate(
                  offset: Offset(0, floatG),
                  child: Image.asset(
                    'assets/images/characters/son_giraffe_2.png',
                    width: w * 0.082,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            // ── Theo / Son 1 (older, red tracksuit) ───
            Positioned(
              left: w * 0.775,
              bottom: h * 0.192,
              child: Transform.rotate(
                angle: swayG,
                child: Transform.translate(
                  offset: Offset(0, floatG),
                  child: Image.asset(
                    'assets/images/characters/son_giraffe_1.png',
                    width: w * 0.098,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            // ── Dad Giraffe — tallest, clear of house ─
            // Fixed: left: w * 0.842 keeps him fully visible
            Positioned(
              left: w * 0.842,
              bottom: h * 0.195,
              child: Transform.rotate(
                angle: swayF,
                child: Transform.translate(
                  offset: Offset(0, floatF),
                  child: Image.asset(
                    'assets/images/characters/dad_giraffe.png',
                    width: w * 0.118,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            // ══════════════════════════════════════════
            // FOREGROUND DEPTH STRIP
            // ══════════════════════════════════════════
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: h * 0.095,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0D1B2A).withOpacity(0.55),
                      const Color(0xFF0D1B2A).withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),
          ]);
        });
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SKY PAINTER — all painted layers (sky, mountains, forest, houses, gate)
// ─────────────────────────────────────────────────────────────
class _SkyPainter extends CustomPainter {
  final double starPhase;
  final double glowPhase;
  final double floatPhase;
  final double swayPhase;
  final double firePhase;
  final double winPhase;

  const _SkyPainter({
    required this.starPhase,
    required this.glowPhase,
    required this.floatPhase,
    required this.swayPhase,
    required this.firePhase,
    required this.winPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawSky(canvas, w, h);
    _drawStars(canvas, w, h);
    _drawMoon(canvas, w, h);
    _drawMountains(canvas, w, h);
    _drawDeepForest(canvas, w, h);
    _drawMidForest(canvas, w, h);
    _drawGround(canvas, w, h);
    _drawHouseLeft(canvas, w, h);
    _drawHouseRight(canvas, w, h);
    _drawGate(canvas, w, h);
    _drawNearForestEdges(canvas, w, h);
    _drawFireflies(canvas, w, h);
  }

  void _drawSky(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF0A0E2A),
          Color(0xFF0E1B3A),
          Color(0xFF122040),
          Color(0xFF1A2A4A),
          Color(0xFF243550),
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
  }

  void _drawStars(Canvas canvas, double w, double h) {
    final rng = Random(42);
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.55;
      final t = (sin(starPhase * pi * 2 + i * 0.7) + 1) / 2;
      final r = 0.6 + rng.nextDouble() * 1.2;
      canvas.drawCircle(
        Offset(x, y),
        r * (0.5 + t * 0.5),
        Paint()..color = Colors.white.withOpacity(0.3 + t * 0.6),
      );
    }
  }

  void _drawMoon(Canvas canvas, double w, double h) {
    final cx = w * 0.82;
    final cy = h * 0.10;
    final t = (sin(glowPhase * pi * 2) + 1) / 2;
    // Outer glow
    canvas.drawCircle(
      Offset(cx, cy), 28,
      Paint()
        ..color = const Color(0xFFE8F4FD).withOpacity(0.06 + t * 0.04)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      Offset(cx, cy), 18,
      Paint()
        ..color = const Color(0xFFE8F4FD).withOpacity(0.12 + t * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Moon body
    canvas.drawCircle(
      Offset(cx, cy), 13,
      Paint()
        ..color = const Color(0xFFF0F8FF).withOpacity(0.88),
    );
    // Crescent shadow
    canvas.drawCircle(
      Offset(cx + 5, cy - 2), 11,
      Paint()..color = const Color(0xFF0E1B3A).withOpacity(0.75),
    );
  }

  void _drawMountains(Canvas canvas, double w, double h) {
    // Far mountains — misty blue-grey
    final far = Paint()
      ..color = const Color(0xFF1E3050).withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final pathFar = Path();
    pathFar.moveTo(0, h * 0.48);
    pathFar.lineTo(w * 0.08, h * 0.28);
    pathFar.lineTo(w * 0.18, h * 0.40);
    pathFar.lineTo(w * 0.28, h * 0.22);
    pathFar.lineTo(w * 0.40, h * 0.38);
    pathFar.lineTo(w * 0.52, h * 0.26);
    pathFar.lineTo(w * 0.64, h * 0.42);
    pathFar.lineTo(w * 0.74, h * 0.30);
    pathFar.lineTo(w * 0.84, h * 0.44);
    pathFar.lineTo(w * 0.92, h * 0.32);
    pathFar.lineTo(w, h * 0.45);
    pathFar.lineTo(w, h * 0.55);
    pathFar.lineTo(0, h * 0.55);
    pathFar.close();
    canvas.drawPath(pathFar, far);

    // Near mountains — slightly more defined
    final near = Paint()
      ..color = const Color(0xFF162840).withOpacity(0.70);
    final pathNear = Path();
    pathNear.moveTo(0, h * 0.52);
    pathNear.lineTo(w * 0.12, h * 0.36);
    pathNear.lineTo(w * 0.24, h * 0.46);
    pathNear.lineTo(w * 0.35, h * 0.30);
    pathNear.lineTo(w * 0.46, h * 0.44);
    pathNear.lineTo(w * 0.58, h * 0.32);
    pathNear.lineTo(w * 0.70, h * 0.46);
    pathNear.lineTo(w * 0.82, h * 0.34);
    pathNear.lineTo(w * 0.92, h * 0.48);
    pathNear.lineTo(w, h * 0.38);
    pathNear.lineTo(w, h * 0.58);
    pathNear.lineTo(0, h * 0.58);
    pathNear.close();
    canvas.drawPath(pathNear, near);
  }

  void _drawDeepForest(Canvas canvas, double w, double h) {
    final rng = Random(77);
    final p = Paint()..color = const Color(0xFF1A3548).withOpacity(0.60);
    for (int i = 0; i < 24; i++) {
      final x = (i / 24.0) * w * 1.05 - w * 0.02;
      final bh = h * (0.14 + rng.nextDouble() * 0.10);
      final by = h * 0.66;
      final bw = w * (0.022 + rng.nextDouble() * 0.014);
      final sway = sin(swayPhase * pi * 2 + i * 0.6) * 2.0;
      final path = Path()
        ..moveTo(x - bw / 2, by)
        ..lineTo(x + sway, by - bh)
        ..lineTo(x + bw / 2, by)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  void _drawMidForest(Canvas canvas, double w, double h) {
    final rng = Random(55);
    final t = (sin(glowPhase * pi * 2) + 1) / 2;
    for (int i = 0; i < 18; i++) {
      final x = (i / 18.0) * w * 1.1 - w * 0.05;
      final bh = h * (0.20 + rng.nextDouble() * 0.12);
      final by = h * 0.72;
      final bw = w * (0.030 + rng.nextDouble() * 0.018);
      final sway = sin(swayPhase * pi * 2 + i * 0.8) * 3.0;
      final isGlow = i % 3 == 0;
      final col = isGlow
          ? const Color(0xFF1DE9B6).withOpacity(0.28 + t * 0.14)
          : const Color(0xFF1A4A3A).withOpacity(0.72);
      final bp = Paint()..color = col;
      if (isGlow) {
        bp.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      }
      final path = Path()
        ..moveTo(x - bw / 2, by)
        ..lineTo(x + sway, by - bh)
        ..lineTo(x + bw / 2, by)
        ..close();
      canvas.drawPath(path, bp);
    }
  }

  void _drawGround(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF1A3A28),
          Color(0xFF122A1E),
          Color(0xFF0D1E16),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.72, w, h * 0.28));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.28), paint);

    // Ground highlight line
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.72, w, 1.5),
      Paint()..color = const Color(0xFF2A5A3A).withOpacity(0.5),
    );
  }

  void _drawHouseLeft(Canvas canvas, double w, double h) {
    // Left house — chicken family — purple/pink
    final wallL   = w * 0.085;
    final wallW   = w * 0.220;
    final wallBot = h * 0.740;
    final wallH   = h * 0.320;
    final roofH   = h * 0.120;

    // Wall
    final wallPaint = Paint()
      ..color = const Color(0xFF2D1B69);
    canvas.drawRect(Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH), wallPaint);

    // Roof
    final roofPaint = Paint()..color = const Color(0xFF7C4FBC);
    final roofPath = Path()
      ..moveTo(wallL - w * 0.012, wallBot - wallH)
      ..lineTo(wallL + wallW / 2, wallBot - wallH - roofH)
      ..lineTo(wallL + wallW + w * 0.012, wallBot - wallH)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Chimney
    canvas.drawRect(
      Rect.fromLTWH(wallL + wallW * 0.72, wallBot - wallH - roofH * 0.75,
          w * 0.020, roofH * 0.60),
      Paint()..color = const Color(0xFF5A3890),
    );

    // Windows (2) with glow pulse
    final winGlow = (sin(winPhase * pi * 2) + 1) / 2;
    final winCol = Color.lerp(
      const Color(0xFFFFE082).withOpacity(0.55),
      const Color(0xFFFFB300).withOpacity(0.85),
      winGlow,
    )!;

    // Left window
    _window(canvas, wallL + wallW * 0.18, wallBot - wallH * 0.62,
        w * 0.055, h * 0.075, winCol);
    // Right window
    _window(canvas, wallL + wallW * 0.58, wallBot - wallH * 0.62,
        w * 0.055, h * 0.075, winCol);

    // Door
    _door(canvas, wallL + wallW * 0.37, wallBot,
        w * 0.050, h * 0.115, const Color(0xFFFF80AB));

    // Wall outline
    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()
        ..color = const Color(0xFFFF80AB).withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawHouseRight(Canvas canvas, double w, double h) {
    // Right house — giraffe family — green/teal
    // Fixed: right edge at w * 0.970 so Dad Giraffe isn't hidden
    final wallL   = w * 0.640;
    final wallW   = w * 0.230;
    final wallBot = h * 0.740;
    final wallH   = h * 0.310;
    final roofH   = h * 0.115;

    // Wall
    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()..color = const Color(0xFF1B3828),
    );

    // Roof
    final roofPath = Path()
      ..moveTo(wallL - w * 0.012, wallBot - wallH)
      ..lineTo(wallL + wallW / 2, wallBot - wallH - roofH)
      ..lineTo(wallL + wallW + w * 0.012, wallBot - wallH)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFF2E6B4A));

    // Chimney
    canvas.drawRect(
      Rect.fromLTWH(wallL + wallW * 0.26, wallBot - wallH - roofH * 0.72,
          w * 0.020, roofH * 0.58),
      Paint()..color = const Color(0xFF1E5238),
    );

    // Windows with glow
    final winGlow = (sin(winPhase * pi * 2 + pi) + 1) / 2;
    final winCol = Color.lerp(
      const Color(0xFFB2DFDB).withOpacity(0.45),
      const Color(0xFF80CBC4).withOpacity(0.80),
      winGlow,
    )!;

    _window(canvas, wallL + wallW * 0.14, wallBot - wallH * 0.60,
        w * 0.055, h * 0.072, winCol);
    _window(canvas, wallL + wallW * 0.56, wallBot - wallH * 0.60,
        w * 0.055, h * 0.072, winCol);

    // Door
    _door(canvas, wallL + wallW * 0.36, wallBot,
        w * 0.050, h * 0.110, const Color(0xFF4DB6AC));

    // Wall outline
    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()
        ..color = const Color(0xFF4DB6AC).withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _window(Canvas canvas, double x, double y, double ww, double wh, Color glow) {
    // Glow behind
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 3, y - 3, ww + 6, wh + 6),
        const Radius.circular(4),
      ),
      Paint()
        ..color = glow.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Window fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, ww, wh),
        const Radius.circular(3),
      ),
      Paint()..color = glow,
    );
    // Cross bar
    canvas.drawLine(Offset(x + ww / 2, y), Offset(x + ww / 2, y + wh),
        Paint()..color = Colors.black.withOpacity(0.25)..strokeWidth = 0.8);
    canvas.drawLine(Offset(x, y + wh / 2), Offset(x + ww, y + wh / 2),
        Paint()..color = Colors.black.withOpacity(0.25)..strokeWidth = 0.8);
  }

  void _door(Canvas canvas, double x, double bottom, double dw, double dh, Color col) {
    final rect = Rect.fromLTWH(x - dw / 2, bottom - dh, dw, dh);
    canvas.drawRRect(
      RRect.fromRectAndCorners(rect,
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4)),
      Paint()..color = col.withOpacity(0.90),
    );
    // Door knob
    canvas.drawCircle(
      Offset(x + dw * 0.28, bottom - dh * 0.38),
      dw * 0.10,
      Paint()..color = Colors.white.withOpacity(0.60),
    );
  }

  void _drawGate(Canvas canvas, double w, double h) {
    // Garden gate — centred between the two houses
    final gx = w * 0.478;
    final gBot = h * 0.740;
    final gH = h * 0.125;
    final gW = w * 0.064;
    final paint = Paint()
      ..color = const Color(0xFFE8D5B0).withOpacity(0.80)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    // Posts
    canvas.drawLine(Offset(gx, gBot), Offset(gx, gBot - gH), paint);
    canvas.drawLine(Offset(gx + gW, gBot), Offset(gx + gW, gBot - gH), paint);

    // Horizontal rails
    canvas.drawLine(Offset(gx, gBot - gH * 0.25), Offset(gx + gW, gBot - gH * 0.25), paint);
    canvas.drawLine(Offset(gx, gBot - gH * 0.65), Offset(gx + gW, gBot - gH * 0.65), paint);

    // Picket tops
    final picketP = Paint()
      ..color = const Color(0xFFE8D5B0).withOpacity(0.65)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (int i = 0; i <= 3; i++) {
      final px = gx + (gW / 3) * i;
      canvas.drawLine(Offset(px, gBot - gH * 0.25), Offset(px, gBot - gH), picketP);
      canvas.drawLine(Offset(px, gBot - gH),
          Offset(px, gBot - gH - h * 0.018), picketP);
    }

    // Path stones
    final stoneP = Paint()..color = const Color(0xFF3A4A3A).withOpacity(0.50);
    for (int i = 0; i < 4; i++) {
      final sy = gBot + h * 0.022 + i * h * 0.030;
      final sw = gW * (0.9 - i * 0.08);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(gx + gW / 2, sy),
          width: sw,
          height: h * 0.012,
        ),
        stoneP,
      );
    }
  }

  void _drawNearForestEdges(Canvas canvas, double w, double h) {
    final rng = Random(11);
    final t = (sin(glowPhase * pi * 2) + 1) / 2;

    // Left edge trees
    for (int i = 0; i < 7; i++) {
      final x = w * (0.005 + i * 0.028);
      final bh = h * (0.30 + rng.nextDouble() * 0.18);
      final by = h * 0.76;
      final bw = w * (0.035 + rng.nextDouble() * 0.022);
      final sway = sin(swayPhase * pi * 2 + i * 0.9) * 3.5;
      final isGlow = i % 2 == 0;
      final col = isGlow
          ? const Color(0xFF1DE9B6).withOpacity(0.35 + t * 0.18)
          : const Color(0xFF52B788).withOpacity(0.62);
      final bp = Paint()..color = col;
      if (isGlow) bp.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      final path = Path()
        ..moveTo(x - bw / 2, by)
        ..lineTo(x + sway, by - bh)
        ..lineTo(x + bw / 2, by)
        ..close();
      canvas.drawPath(path, bp);
    }

    // Right edge trees
    for (int i = 0; i < 7; i++) {
      final x = w * (0.997 - i * 0.028);
      final bh = h * (0.28 + rng.nextDouble() * 0.20);
      final by = h * 0.76;
      final bw = w * (0.032 + rng.nextDouble() * 0.020);
      final sway = sin(swayPhase * pi * 2 + i * 1.1 + 0.5) * 3.5;
      final isGlow = i % 2 == 1;
      final col = isGlow
          ? const Color(0xFF1DE9B6).withOpacity(0.32 + t * 0.16)
          : const Color(0xFF52B788).withOpacity(0.58);
      final bp = Paint()..color = col;
      if (isGlow) bp.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      final path = Path()
        ..moveTo(x - bw / 2, by)
        ..lineTo(x + sway, by - bh)
        ..lineTo(x + bw / 2, by)
        ..close();
      canvas.drawPath(path, bp);
    }
  }

  void _drawFireflies(Canvas canvas, double w, double h) {
    final rng = Random(33);
    for (int i = 0; i < 28; i++) {
      final x = rng.nextDouble() * w;
      final y = h * 0.42 + rng.nextDouble() * h * 0.44;
      final t = (sin(firePhase * pi * 2 + i * 0.9) + 1) / 2;
      final ft = (sin(glowPhase * pi * 2 + i * 1.5) + 1) / 2;
      if (t > 0.28) {
        final color = i % 2 == 0
            ? const Color(0xFF1DE9B6)
            : const Color(0xFFB2EBF2);
        canvas.drawCircle(
          Offset(x, y), 3 + ft * 3,
          Paint()
            ..color = color.withOpacity(0.10 + t * 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(
          Offset(x, y), 1.2 + ft * 1.0,
          Paint()..color = color.withOpacity(0.65 + t * 0.30),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SkyPainter old) =>
      old.starPhase != starPhase ||
      old.glowPhase != glowPhase ||
      old.floatPhase != floatPhase ||
      old.swayPhase != swayPhase ||
      old.firePhase != firePhase ||
      old.winPhase  != winPhase;
}
