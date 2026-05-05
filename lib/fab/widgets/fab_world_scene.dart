import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  FAB WORLD SCENE — Calm World  v4.0
//
//  Fixed-width parallax depth scene — no scrolling
//  Layers back→front:
//    1. Teal twilight sky + stars + moon
//    2. Distant misty mountains
//    3. Deep forest (small, desaturated)
//    4. Mid forest (medium, glowing)
//    5. Two storybook houses + garden gate
//    6. Near forest edges (large, vivid)
//    7. Foreground grass + fireflies
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
  late AnimationController _fireCtrl;

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);
    _swayCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _fireCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    _swayCtrl.dispose();
    _fireCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_starCtrl, _glowCtrl, _floatCtrl, _swayCtrl, _fireCtrl]),
        builder: (context, _) {
          return CustomPaint(
            painter: _WorldPainter(
              starPhase: _starCtrl.value,
              glowPhase: _glowCtrl.value,
              floatPhase: _floatCtrl.value,
              swayPhase: _swayCtrl.value,
              firePhase: _fireCtrl.value,
            ),
            child: LayoutBuilder(builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              // Each character gets unique float/sway rhythm for 3D life
              final floatA = (_floatCtrl.value - 0.5) * 6;        // Mum — base
              final floatB = (_floatCtrl.value - 0.5) * 4.5;      // D9 — slower
              final floatC = (_floatCtrl.value - 0.5) * 8;        // D7 — bouncier
              final floatD = (_floatCtrl.value - 0.5) * 3;        // Teds — subtle
              final floatE = (_floatCtrl.value - 0.5) * 5;        // Cats — gentle
              final swayA = (_swayCtrl.value - 0.5) * 0.035;
              final swayB = (_swayCtrl.value - 0.5) * -0.028;     // opposite D9
              final swayC = (_swayCtrl.value - 0.5) * 0.050;      // wider D7
              final swayD = (_swayCtrl.value - 0.5) * 0.020;      // Teds tiny

              return Stack(children: [

                // ── Cat 1 — left house left window ────────────
                Positioned(
                  left: w * 0.095,
                  bottom: h * 0.525,
                  child: Transform.translate(
                    offset: Offset(0, floatE),
                    child: Image.asset(
                      'assets/images/characters/cat1.png',
                      width: w * 0.048,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),

                // ── Cat 2 — left house right window ───────────
                Positioned(
                  left: w * 0.185,
                  bottom: h * 0.525,
                  child: Transform.translate(
                    offset: Offset(0, -floatE),  // opposite phase = alive
                    child: Image.asset(
                      'assets/images/characters/cat2.png',
                      width: w * 0.048,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),

                // ── Teds (Shih Tzu) — at feet, left ──────────
                Positioned(
                  left: w * 0.205,
                  bottom: h * 0.185,
                  child: Transform.rotate(
                    angle: swayD,
                    child: Transform.translate(
                      offset: Offset(0, floatD),
                      child: Image.asset(
                        'assets/images/characters/teds.png',
                        width: w * 0.058,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),

                // ── Daughter age 7 — front, smallest ─────────
                Positioned(
                  left: w * 0.255,
                  bottom: h * 0.190,
                  child: Transform.rotate(
                    angle: swayC,
                    child: Transform.translate(
                      offset: Offset(0, floatC),
                      child: Image.asset(
                        'assets/images/characters/daughter_7.png',
                        width: w * 0.072,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),

                // ── Daughter age 9 — beside mum ──────────────
                Positioned(
                  left: w * 0.310,
                  bottom: h * 0.195,
                  child: Transform.rotate(
                    angle: swayB,
                    child: Transform.translate(
                      offset: Offset(0, floatB),
                      child: Image.asset(
                        'assets/images/characters/daughter_9.png',
                        width: w * 0.082,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),

                // ── Miss Chicken Lips — mum, front left ───────
                Positioned(
                  left: w * 0.220,
                  bottom: h * 0.200,
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

              ]);
            }),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  WORLD PAINTER — all layers in one CustomPainter
// ─────────────────────────────────────────────────────────────
class _WorldPainter extends CustomPainter {
  final double starPhase;
  final double glowPhase;
  final double floatPhase;
  final double swayPhase;
  final double firePhase;

  _WorldPainter({
    required this.starPhase,
    required this.glowPhase,
    required this.floatPhase,
    required this.swayPhase,
    required this.firePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawSky(canvas, w, h);
    _drawMountains(canvas, w, h);
    _drawForestFar(canvas, w, h);
    _drawForestMid(canvas, w, h);
    _drawGround(canvas, w, h);
    _drawHouses(canvas, w, h);
    _drawGardenGate(canvas, w, h);
    _drawGarden(canvas, w, h);
    _drawForestNear(canvas, w, h);
    _drawForeground(canvas, w, h);
    _drawFireflies(canvas, w, h);
  }

  // ── LAYER 1: Sky ──────────────────────────────────────────
  void _drawSky(Canvas canvas, double w, double h) {
    canvas.drawRect(
      Offset.zero & Size(w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF020C14),
            Color(0xFF041E2E),
            Color(0xFF063D3A),
            Color(0xFF0A4A3A),
          ],
          stops: const [0.0, 0.30, 0.60, 1.0],
        ).createShader(Offset.zero & Size(w, h)),
    );

    // Stars
    final rng = Random(42);
    final sp = Paint();
    for (int i = 0; i < 90; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.58;
      final t = (sin(starPhase * pi * 2 + i * 0.7) + 1) / 2;
      sp.color = Colors.white.withOpacity(0.2 + t * 0.65);
      canvas.drawCircle(Offset(x, y), 0.6 + t * 1.2, sp);
    }

    // Nebula wisps
    final nr = Random(77);
    for (int i = 0; i < 5; i++) {
      final x = nr.nextDouble() * w;
      final y = nr.nextDouble() * h * 0.38;
      final t = (sin(glowPhase * pi * 2 + i * 1.1) + 1) / 2;
      canvas.drawCircle(Offset(x, y), 50 + t * 35,
          Paint()
            ..color = const Color(0xFF00BFA5).withOpacity(0.035 + t * 0.03)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28));
    }

    // Moon
    final mx = w * 0.80;
    final my = h * 0.14;
    canvas.drawCircle(Offset(mx, my), w * 0.055,
        Paint()
          ..color = const Color(0xFF80DEEA).withOpacity(0.07 + glowPhase * 0.05)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    canvas.drawCircle(Offset(mx, my), w * 0.038,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFE0F7FA),
            const Color(0xFF80DEEA),
          ]).createShader(Rect.fromCircle(center: Offset(mx, my), radius: w * 0.038)));
    canvas.drawCircle(Offset(mx - w * 0.012, my - h * 0.02), w * 0.008,
        Paint()..color = const Color(0xFF80DEEA).withOpacity(0.28));
    canvas.drawCircle(Offset(mx + w * 0.018, my + h * 0.025), w * 0.005,
        Paint()..color = const Color(0xFF80DEEA).withOpacity(0.22));
  }

  // ── LAYER 2: Mountains ────────────────────────────────────
  void _drawMountains(Canvas canvas, double w, double h) {
    _mountainRange(canvas, w, h, h * 0.50, h * 0.20,
        const Color(0xFF082828), 0.9, 9, 30);
    _mountainRange(canvas, w, h, h * 0.55, h * 0.16,
        const Color(0xFF0A3535), 0.8, 13, 50);

    // Mist band
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.48, w, h * 0.10),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF00BFA5).withOpacity(0.0),
            const Color(0xFF00BFA5).withOpacity(0.08),
            const Color(0xFF00BFA5).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.48, w, h * 0.10)),
    );
  }

  void _mountainRange(Canvas canvas, double w, double h, double baseY,
      double peakH, Color color, double opacity, int peaks, int seed) {
    final rng = Random(seed);
    final path = Path()..moveTo(0, baseY);
    final step = w / (peaks - 1);
    for (int i = 0; i < peaks; i++) {
      final px = i * step + (rng.nextDouble() - 0.5) * step * 0.3;
      final py = baseY - peakH * (0.4 + rng.nextDouble() * 0.6);
      if (i == 0) {
        path.lineTo(px, py);
      } else {
        path.cubicTo(
          (i - 1) * step + step * 0.4, baseY,
          px - step * 0.3, py,
          px, py,
        );
      }
    }
    path.lineTo(w, baseY);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));

    // Glowing peak caps
    final rng2 = Random(seed + 1);
    for (int i = 0; i < peaks; i++) {
      final px = i * step + (rng2.nextDouble() - 0.5) * step * 0.3;
      final py = baseY - peakH * (0.4 + rng2.nextDouble() * 0.6);
      canvas.drawCircle(Offset(px, py), 14,
          Paint()
            ..color = const Color(0xFF80DEEA).withOpacity(0.10)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }
  }

  // ── LAYER 3: Far forest ───────────────────────────────────
  void _drawForestFar(Canvas canvas, double w, double h) {
    _forestLayer(
      canvas, w, h,
      groundY: h * 0.62,
      treeH: h * 0.20,
      treeW: 22,
      count: 32,
      seed: 10,
      trunk: const Color(0xFF062820),
      canopy: const Color(0xFF0A4035),
      glow: const Color(0xFF00BFA5),
      glowAlpha: 0.08,
      swayAmt: 0.008,
    );
  }

  // ── LAYER 4: Mid forest ───────────────────────────────────
  void _drawForestMid(Canvas canvas, double w, double h) {
    _forestLayer(
      canvas, w, h,
      groundY: h * 0.70,
      treeH: h * 0.30,
      treeW: 36,
      count: 22,
      seed: 20,
      trunk: const Color(0xFF063D2D),
      canopy: const Color(0xFF00695C),
      glow: const Color(0xFF1DE9B6),
      glowAlpha: 0.16,
      swayAmt: 0.014,
    );
  }

  // ── LAYER 6: Near forest (edges only) ────────────────────
  void _drawForestNear(Canvas canvas, double w, double h) {
    // Left edge trees
    _forestEdge(canvas, w, h, leftEdge: true);
    // Right edge trees
    _forestEdge(canvas, w, h, leftEdge: false);
  }

  void _forestEdge(Canvas canvas, double w, double h, {required bool leftEdge}) {
    final rng = Random(leftEdge ? 88 : 99);
    final count = 5;
    for (int i = 0; i < count; i++) {
      final frac = leftEdge
          ? (i / (count - 1)) * 0.18
          : 0.82 + (i / (count - 1)) * 0.18;
      final x = frac * w;
      final treeH = h * (0.55 + rng.nextDouble() * 0.25);
      final treeW = w * (0.06 + rng.nextDouble() * 0.04);
      final t = (sin(glowPhase * pi * 2 + i * 0.9) + 1) / 2;
      final sway = sin(swayPhase * pi * 2 + i * 0.5) * treeW * 0.018;

      canvas.save();
      canvas.translate(x, h * 0.78);

      // Trunk
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-treeW * 0.09 + sway * 0.3, -treeH * 0.38,
              treeW * 0.18, treeH * 0.40),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF041E14),
      );

      // Glow halo
      canvas.drawCircle(
        Offset(sway, -treeH * 0.65),
        treeW * 0.62,
        Paint()
          ..color = const Color(0xFF1DE9B6).withOpacity(0.18 * (0.6 + t * 0.4))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, treeW * 0.5),
      );

      // Canopy layers
      for (int l = 0; l < 3; l++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(sway * (1 + l * 0.15),
                -treeH * (0.52 + l * 0.10)),
            width: treeW * (1.0 - l * 0.10),
            height: treeH * (0.36 - l * 0.04),
          ),
          Paint()
            ..color = const Color(0xFF00695C)
                .withOpacity(0.80 + l * 0.06),
        );
      }

      // Sparkle dots
      final dr = Random(leftEdge ? 88 + i : 99 + i);
      for (int d = 0; d < 6; d++) {
        final dx = (dr.nextDouble() - 0.5) * treeW * 0.8 + sway;
        final dy = -treeH * 0.44 - dr.nextDouble() * treeH * 0.28;
        final dt = (sin(glowPhase * pi * 2 + d * 1.7 + i * 0.3) + 1) / 2;
        canvas.drawCircle(
          Offset(dx, dy),
          1.2 + dt * 1.6,
          Paint()
            ..color = const Color(0xFF1DE9B6).withOpacity(0.5 + dt * 0.5),
        );
      }

      canvas.restore();
    }
  }

  void _forestLayer(
    Canvas canvas,
    double w,
    double h, {
    required double groundY,
    required double treeH,
    required double treeW,
    required int count,
    required int seed,
    required Color trunk,
    required Color canopy,
    required Color glow,
    required double glowAlpha,
    required double swayAmt,
  }) {
    final rng = Random(seed);
    final spacing = w / count;
    for (int i = 0; i < count; i++) {
      final x = i * spacing + rng.nextDouble() * spacing * 0.7;
      final hv = 0.65 + rng.nextDouble() * 0.7;
      final th = treeH * hv;
      final tw = treeW * (0.7 + rng.nextDouble() * 0.6);
      final sway = sin(swayPhase * pi * 2 + i * 0.4) * swayAmt * tw;
      final t = (sin(glowPhase * pi * 2 + i * 0.9) + 1) / 2;

      canvas.save();
      canvas.translate(x, groundY);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-tw * 0.09 + sway * 0.3, -th * 0.36, tw * 0.18, th * 0.38),
          const Radius.circular(2),
        ),
        Paint()..color = trunk,
      );

      canvas.drawCircle(
        Offset(sway, -th * 0.60),
        tw * 0.52,
        Paint()
          ..color = glow.withOpacity(glowAlpha * (0.55 + t * 0.45))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, tw * 0.38),
      );

      for (int l = 0; l < 3; l++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(sway * (1 + l * 0.18), -th * (0.54 + l * 0.10)),
            width: tw * (1.0 - l * 0.12),
            height: th * (0.36 - l * 0.04),
          ),
          Paint()..color = canopy.withOpacity(0.72 + l * 0.08),
        );
      }

      final dr = Random(seed + i);
      for (int d = 0; d < 4; d++) {
        final dx = (dr.nextDouble() - 0.5) * tw * 0.75 + sway;
        final dy = -th * 0.44 - dr.nextDouble() * th * 0.22;
        final dt = (sin(glowPhase * pi * 2 + d * 1.7 + i * 0.3) + 1) / 2;
        canvas.drawCircle(
          Offset(dx, dy),
          0.9 + dt * 1.4,
          Paint()..color = glow.withOpacity(0.45 + dt * 0.45),
        );
      }

      canvas.restore();
    }
  }

  // ── LAYER 5: Ground + houses ──────────────────────────────
  void _drawGround(Canvas canvas, double w, double h) {
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.78, w, h * 0.22),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF1B4332), Color(0xFF0D2B1E)],
        ).createShader(Rect.fromLTWH(0, h * 0.78, w, h * 0.22)),
    );

    // Bio-glow on ground edge
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.775, w, h * 0.022),
      Paint()
        ..color = const Color(0xFF1DE9B6)
            .withOpacity(0.09 + glowPhase * 0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
  }

  void _drawHouses(Canvas canvas, double w, double h) {
    // LEFT — Chicken family (purple/pink)
    _house(
      canvas, w, h,
      left: w * 0.06,
      width: w * 0.22,
      bottom: h * 0.78,
      height: h * 0.55,
      roof: const Color(0xFF7C4FBC),
      wall: const Color(0xFF2D1B69),
      accent: const Color(0xFFFF80AB),
      winGlow: const Color(0xFFFFE082),
    );

    // RIGHT — Giraffe family (teal/gold)
    _house(
      canvas, w, h,
      left: w * 0.72,
      width: w * 0.24,
      bottom: h * 0.78,
      height: h * 0.60,
      roof: const Color(0xFF0F6E56),
      wall: const Color(0xFF0A3D2D),
      accent: const Color(0xFFFFD700),
      winGlow: const Color(0xFFB2EBF2),
    );
  }

  void _house(
    Canvas canvas,
    double w,
    double h, {
    required double left,
    required double width,
    required double bottom,
    required double height,
    required Color roof,
    required Color wall,
    required Color accent,
    required Color winGlow,
  }) {
    final top = bottom - height;
    final roofH = height * 0.30;
    final wallTop = top + roofH * 0.52;
    final wallH = bottom - wallTop;

    // Ambient glow
    canvas.drawRect(
      Rect.fromLTWH(left - 8, top - 4, width + 16, height + 8),
      Paint()
        ..color = accent.withOpacity(0.04 + glowPhase * 0.03)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Wall
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(left, wallTop, width, wallH),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [wall.withOpacity(0.96), wall],
        ).createShader(Rect.fromLTWH(left, wallTop, width, wallH)),
    );

    // Roof
    final rp = Path()
      ..moveTo(left - width * 0.05, top + roofH * 0.54)
      ..lineTo(left + width / 2, top)
      ..lineTo(left + width * 1.05, top + roofH * 0.54)
      ..close();
    canvas.drawPath(rp, Paint()..color = roof);
    canvas.drawPath(rp,
        Paint()
          ..color = accent.withOpacity(0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);

    // Chimney
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + width * 0.70, top - height * 0.07,
            width * 0.09, height * 0.10),
        const Radius.circular(2),
      ),
      Paint()..color = roof.withOpacity(0.85),
    );
    // Smoke puffs
    for (int s = 0; s < 3; s++) {
      canvas.drawCircle(
        Offset(left + width * 0.745, top - height * (0.08 + s * 0.055)),
        width * (0.028 + s * 0.012),
        Paint()
          ..color = Colors.white
              .withOpacity((0.12 - s * 0.03) + glowPhase * 0.05)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // Windows
    final wy = wallTop + wallH * 0.07;
    final wh2 = wallH * 0.26;
    final ww = width * 0.21;
    _window(canvas, left + width * 0.09, wy, ww, wh2, winGlow, accent);
    _window(canvas, left + width * 0.68, wy, ww, wh2, winGlow, accent);

    // Door
    _door(canvas, left + width * 0.375, bottom - wallH * 0.40,
        width * 0.25, wallH * 0.40, accent);
  }

  void _window(Canvas canvas, double x, double y, double ww, double wh,
      Color glow, Color accent) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 3, y - 3, ww + 6, wh + 6),
          const Radius.circular(6)),
      Paint()
        ..color = glow.withOpacity(0.20 + glowPhase * 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, ww, wh), const Radius.circular(4)),
      Paint()..color = accent.withOpacity(0.65),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 2, y + 2, ww - 4, wh - 4),
          const Radius.circular(3)),
      Paint()
        ..shader = RadialGradient(
          colors: [glow.withOpacity(0.82), glow.withOpacity(0.36)],
        ).createShader(Rect.fromLTWH(x, y, ww, wh)),
    );
    final dp = Paint()
      ..color = accent.withOpacity(0.4)
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(x + ww / 2, y + 2), Offset(x + ww / 2, y + wh - 2), dp);
    canvas.drawLine(
        Offset(x + 2, y + wh / 2), Offset(x + ww - 2, y + wh / 2), dp);
  }

  void _door(Canvas canvas, double x, double y, double dw, double dh,
      Color accent) {
    final dp = Path()
      ..moveTo(x, y + dh)
      ..lineTo(x, y + dh * 0.30)
      ..arcToPoint(Offset(x + dw, y + dh * 0.30),
          radius: Radius.circular(dw / 2), clockwise: false)
      ..lineTo(x + dw, y + dh)
      ..close();
    canvas.drawPath(dp, Paint()..color = accent.withOpacity(0.20));
    canvas.drawPath(dp,
        Paint()
          ..color = accent.withOpacity(0.82)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(
        Offset(x + dw * 0.76, y + dh * 0.57),
        dw * 0.07,
        Paint()..color = const Color(0xFFFFD700));
  }

  // ── Garden gate ───────────────────────────────────────────
  void _drawGardenGate(Canvas canvas, double w, double h) {
    final gx = w * 0.42;
    final gy = h * 0.48;
    final gw = w * 0.16;
    final gh = h * 0.32;

    // Glow
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(gx + gw / 2, gy + gh / 2),
          width: gw * 2.2, height: gh * 1.4),
      Paint()
        ..color = const Color(0xFFFFD700)
            .withOpacity(0.06 + glowPhase * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    final post = Paint()..color = const Color(0xFF8B6914);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(gx - w * 0.008, gy, w * 0.012, gh),
            const Radius.circular(2)),
        post);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(gx + gw - w * 0.004, gy, w * 0.012, gh),
            const Radius.circular(2)),
        post);

    canvas.drawArc(
      Rect.fromLTWH(gx - w * 0.008, gy - gh * 0.28, gw + w * 0.016, gh * 0.56),
      pi, pi, false,
      Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final bar = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.85)
      ..strokeWidth = 2.5;
    for (int i = 0; i < 5; i++) {
      final bx = gx + gw * (i + 0.5) / 5;
      canvas.drawLine(Offset(bx, gy + gh * 0.10), Offset(bx, gy + gh), bar);
    }

    final tp = TextPainter(
      text: TextSpan(
        text: '✿ Garden ✿',
        style: TextStyle(
          color: const Color(0xFFFFD700).withOpacity(0.95),
          fontSize: w * 0.022,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas,
        Offset(gx + gw / 2 - tp.width / 2, gy - gh * 0.46));
  }

  // ── Garden flowers + bushes ───────────────────────────────
  void _drawGarden(Canvas canvas, double w, double h) {
    _flowerBed(canvas, w * 0.285, h * 0.762, w, h,
        const Color(0xFFFF80AB), const Color(0xFFFF4081));
    _flowerBed(canvas, w * 0.385, h * 0.762, w, h,
        const Color(0xFF1DE9B6), const Color(0xFF00BFA5));
    _flowerBed(canvas, w * 0.585, h * 0.762, w, h,
        const Color(0xFFFFD700), const Color(0xFFFFAB00));
    _flowerBed(canvas, w * 0.685, h * 0.762, w, h,
        const Color(0xFFB2EBF2), const Color(0xFF80DEEA));

    _glowBush(canvas, w * 0.055, h * 0.770, w * 0.055, h * 0.065,
        const Color(0xFF00695C), const Color(0xFF1DE9B6));
    _glowBush(canvas, w * 0.270, h * 0.770, w * 0.045, h * 0.055,
        const Color(0xFF00796B), const Color(0xFF1DE9B6));
    _glowBush(canvas, w * 0.710, h * 0.770, w * 0.055, h * 0.065,
        const Color(0xFF00695C), const Color(0xFFB2EBF2));
    _glowBush(canvas, w * 0.940, h * 0.770, w * 0.045, h * 0.055,
        const Color(0xFF00796B), const Color(0xFFB2EBF2));
  }

  void _flowerBed(Canvas canvas, double x, double y, double w, double h,
      Color petal, Color glow) {
    final rng = Random(x.toInt());
    for (int i = 0; i < 7; i++) {
      final fx = x + rng.nextDouble() * w * 0.06;
      final fy = y + rng.nextDouble() * h * 0.015;
      final sway = sin(swayPhase * pi * 2 + i * 0.8) * 0.07;
      final t = (sin(glowPhase * pi * 2 + i * 1.4) + 1) / 2;
      canvas.save();
      canvas.translate(fx, fy);
      canvas.rotate(sway);
      canvas.drawCircle(Offset(0, -h * 0.046), w * 0.007,
          Paint()
            ..color = glow.withOpacity(0.28 + t * 0.40)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawLine(Offset.zero, Offset(0, -h * 0.044),
          Paint()
            ..color = const Color(0xFF2D6A4F)
            ..strokeWidth = 1.5);
      canvas.drawCircle(Offset(0, -h * 0.046), w * 0.0055,
          Paint()..color = petal.withOpacity(0.95));
      canvas.restore();
    }
  }

  void _glowBush(Canvas canvas, double x, double y, double bw, double bh,
      Color color, Color glow) {
    final t = (sin(glowPhase * pi * 2 + x * 0.01) + 1) / 2;
    canvas.drawCircle(Offset(x + bw / 2, y - bh / 2), bw * 0.85,
        Paint()
          ..color = glow.withOpacity(0.07 + t * 0.07)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    final p = Paint()..color = color;
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
          Offset(x + bw * i / 3, y - bh * (i % 2 == 0 ? 0.30 : 0.65)),
          bw * 0.32, p);
    }
  }

  // ── LAYER 7: Foreground ───────────────────────────────────
  void _drawForeground(Canvas canvas, double w, double h) {
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.88, w, h * 0.12),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF1B4332), Color(0xFF0D2B1E)],
        ).createShader(Rect.fromLTWH(0, h * 0.88, w, h * 0.12)),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.875, w, h * 0.020),
      Paint()
        ..color = const Color(0xFF1DE9B6)
            .withOpacity(0.08 + glowPhase * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final rng = Random(77);
    final bp = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;
    for (int i = 0; i < 70; i++) {
      final x = rng.nextDouble() * w;
      final by = h * 0.88 + rng.nextDouble() * h * 0.018;
      final bh = h * 0.030 + rng.nextDouble() * h * 0.028;
      final sway = sin(swayPhase * pi * 2 + i * 0.5) * 5;
      bp.color = i % 8 == 0
          ? const Color(0xFF1DE9B6).withOpacity(0.48)
          : const Color(0xFF52B788).withOpacity(0.62);
      canvas.drawLine(Offset(x, by), Offset(x + sway, by - bh), bp);
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
        canvas.drawCircle(Offset(x, y), 3 + ft * 3,
            Paint()
              ..color = color.withOpacity(0.10 + t * 0.12)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
        canvas.drawCircle(Offset(x, y), 1.2 + ft * 1.0,
            Paint()..color = color.withOpacity(0.65 + t * 0.30));
      }
    }
  }

  @override
  bool shouldRepaint(_WorldPainter old) =>
      old.starPhase != starPhase ||
      old.glowPhase != glowPhase ||
      old.floatPhase != floatPhase ||
      old.swayPhase != swayPhase ||
      old.firePhase != firePhase;
}
