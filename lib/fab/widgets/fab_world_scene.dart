import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  FAB WORLD SCENE — Calm World  v3.0
//
//  Scrollable panorama — 2400px wide × 600px tall
//  Teal twilight enchanted forest with bioluminescent trees
//  Two storybook houses in the foreground
//  LEFT  — Chicken family  (purple/pink)
//  RIGHT — Giraffe family  (teal/gold)
//  MIDDLE — Garden gate
// ─────────────────────────────────────────────────────────────

const double _kSceneWidth = 2400.0;
const double _kSceneHeight = 600.0;

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
  late ScrollController _scrollCtrl;

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
    _scrollCtrl = ScrollController();

    // Auto-scroll slowly to hint at panorama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            300,
            duration: const Duration(seconds: 6),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    _swayCtrl.dispose();
    _fireCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: _kSceneHeight,
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: AnimatedBuilder(
            animation: Listenable.merge(
                [_starCtrl, _glowCtrl, _floatCtrl, _swayCtrl, _fireCtrl]),
            builder: (context, _) {
              return SizedBox(
                width: _kSceneWidth,
                height: _kSceneHeight,
                child: Stack(
                  children: [
                    // Sky + forest background
                    CustomPaint(
                      painter: _SkyForestPainter(
                        starPhase: _starCtrl.value,
                        glowPhase: _glowCtrl.value,
                        swayPhase: _swayCtrl.value,
                        firePhase: _fireCtrl.value,
                      ),
                      child: const SizedBox.expand(),
                    ),

                    // Ground + houses
                    CustomPaint(
                      painter: _GroundPainter(
                        glowPhase: _glowCtrl.value,
                        swayPhase: _swayCtrl.value,
                      ),
                      child: const SizedBox.expand(),
                    ),

                    // Characters
                    _buildCharacters(),

                    // Foreground grass + fireflies
                    CustomPaint(
                      painter: _ForegroundPainter(
                        swayPhase: _swayCtrl.value,
                        firePhase: _fireCtrl.value,
                        glowPhase: _glowCtrl.value,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCharacters() {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _swayCtrl]),
      builder: (context, _) {
        final floatOffset = (_floatCtrl.value - 0.5) * 6;
        final swayAngle = (_swayCtrl.value - 0.5) * 0.04;
        const w = _kSceneWidth;
        const h = _kSceneHeight;

        return Stack(children: [
          // Miss Chicken Lips — left house front
          _CharacterSlot(
            imagePath: 'assets/images/chicken_lips.png',
            width: w * 0.055,
            left: w * 0.28,
            bottom: h * 0.22,
            floatOffset: floatOffset,
            swayAngle: swayAngle,
          ),

          // Daughter age 9 — uncomment when asset ready
          // _CharacterSlot(
          //   imagePath: 'assets/images/characters/daughter_9.jpg',
          //   width: w * 0.042,
          //   left: w * 0.175,
          //   bottom: h * 0.21,
          //   floatOffset: floatOffset * 0.8,
          //   swayAngle: -swayAngle,
          // ),

          // Daughter age 7
          // _CharacterSlot(
          //   imagePath: 'assets/images/characters/daughter_7.jpg',
          //   width: w * 0.036,
          //   left: w * 0.150,
          //   bottom: h * 0.24,
          //   floatOffset: floatOffset * 1.1,
          //   swayAngle: swayAngle * 1.2,
          // ),

          // Shih Tzu
          // _CharacterSlot(
          //   imagePath: 'assets/images/characters/teds.jpg',
          //   width: w * 0.030,
          //   left: w * 0.095,
          //   bottom: h * 0.19,
          //   floatOffset: 0,
          //   swayAngle: swayAngle,
          // ),

          // Cat 1 — left house window
          // _CharacterSlot(
          //   imagePath: 'assets/images/characters/cat1.jpg',
          //   width: w * 0.022,
          //   left: w * 0.105,
          //   bottom: h * 0.52,
          //   floatOffset: floatOffset * 0.3,
          //   swayAngle: 0,
          // ),

          // Cat 2 — left house other window
          // _CharacterSlot(
          //   imagePath: 'assets/images/characters/cat2.jpg',
          //   width: w * 0.022,
          //   left: w * 0.155,
          //   bottom: h * 0.52,
          //   floatOffset: floatOffset * 0.4,
          //   swayAngle: 0,
          // ),

          // Dad Giraffe
          // _CharacterSlot(
          //   imagePath: 'assets/images/characters/dad_giraffe.jpg',
          //   width: w * 0.062,
          //   left: w * 0.700,
          //   bottom: h * 0.24,
          //   floatOffset: floatOffset * 0.6,
          //   swayAngle: -swayAngle * 0.8,
          // ),

          // Son Giraffe 1
          // _CharacterSlot(
          //   imagePath: 'assets/images/characters/son_giraffe_1.jpg',
          //   width: w * 0.048,
          //   left: w * 0.655,
          //   bottom: h * 0.24,
          //   floatOffset: floatOffset * 0.7,
          //   swayAngle: swayAngle,
          // ),

          // Son Giraffe 2
          // _CharacterSlot(
          //   imagePath: 'assets/images/characters/son_giraffe_2.jpg',
          //   width: w * 0.042,
          //   left: w * 0.740,
          //   bottom: h * 0.24,
          //   floatOffset: floatOffset * 0.9,
          //   swayAngle: -swayAngle * 1.1,
          // ),

          // Jack Russell
          // _CharacterSlot(
          //   imagePath: 'assets/images/characters/jack_russell.jpg',
          //   width: w * 0.028,
          //   left: w * 0.760,
          //   bottom: h * 0.19,
          //   floatOffset: 0,
          //   swayAngle: swayAngle,
          // ),
        ]);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CHARACTER SLOT
// ─────────────────────────────────────────────────────────────
class _CharacterSlot extends StatelessWidget {
  final String imagePath;
  final double width;
  final double? left;
  final double? right;
  final double bottom;
  final double floatOffset;
  final double swayAngle;

  const _CharacterSlot({
    required this.imagePath,
    required this.width,
    this.left,
    this.right,
    required this.bottom,
    required this.floatOffset,
    required this.swayAngle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      bottom: bottom + floatOffset,
      child: Transform.rotate(
        angle: swayAngle,
        child: Image.asset(
          imagePath,
          width: width,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SKY + ENCHANTED FOREST PAINTER
//  Layers (back to front):
//    1. Teal twilight sky gradient
//    2. Stars + twin moons
//    3. Distant misty mountains
//    4. Deep forest — large glowing trees (far)
//    5. Mid forest — bioluminescent trunks
//    6. Floating light orbs + firefly wisps
// ─────────────────────────────────────────────────────────────
class _SkyForestPainter extends CustomPainter {
  final double starPhase;
  final double glowPhase;
  final double swayPhase;
  final double firePhase;

  _SkyForestPainter({
    required this.starPhase,
    required this.glowPhase,
    required this.swayPhase,
    required this.firePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Sky gradient ────────────────────────────────────
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF020C14), // near-black top
            Color(0xFF041E2E), // deep teal-navy
            Color(0xFF063D3A), // teal mid
            Color(0xFF0A5C4A), // forest teal low sky
            Color(0xFF0D3D2A), // dark forest floor sky
          ],
          stops: const [0.0, 0.25, 0.50, 0.72, 1.0],
        ).createShader(Offset.zero & size),
    );

    // ── 2. Stars ───────────────────────────────────────────
    final rng = Random(42);
    final starPaint = Paint();
    for (int i = 0; i < 120; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.55;
      final t = (sin(starPhase * pi * 2 + i * 0.7) + 1) / 2;
      final r = 0.6 + t * 1.3;
      starPaint.color = Colors.white.withOpacity(0.25 + t * 0.6);
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }

    // Teal nebula wisps
    final nRng = Random(77);
    for (int i = 0; i < 6; i++) {
      final x = nRng.nextDouble() * w;
      final y = nRng.nextDouble() * h * 0.4;
      final t = (sin(glowPhase * pi * 2 + i * 1.1) + 1) / 2;
      canvas.drawCircle(
        Offset(x, y),
        60 + t * 40,
        Paint()
          ..color = const Color(0xFF00BFA5).withOpacity(0.04 + t * 0.04)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      );
    }

    // Moon — large, teal-tinted
    final moonX = w * 0.78;
    final moonY = h * 0.13;
    // Outer glow
    canvas.drawCircle(
      Offset(moonX, moonY),
      55,
      Paint()
        ..color = const Color(0xFF80DEEA).withOpacity(0.08 + glowPhase * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    // Moon body
    canvas.drawCircle(
      Offset(moonX, moonY),
      38,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE0F7FA),
            const Color(0xFF80DEEA),
          ],
        ).createShader(Rect.fromCircle(center: Offset(moonX, moonY), radius: 38)),
    );
    // Moon crater detail
    canvas.drawCircle(Offset(moonX - 10, moonY - 8), 7,
        Paint()..color = const Color(0xFF80DEEA).withOpacity(0.3));
    canvas.drawCircle(Offset(moonX + 14, moonY + 10), 4,
        Paint()..color = const Color(0xFF80DEEA).withOpacity(0.25));

    // ── 3. Distant misty mountains ─────────────────────────
    _drawMountainRange(canvas, w, h, h * 0.48, h * 0.22,
        const Color(0xFF0A4040), 0.6, 11);
    _drawMountainRange(canvas, w, h, h * 0.54, h * 0.18,
        const Color(0xFF0D5050), 0.4, 17);

    // Mountain mist
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.46, w, h * 0.12),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF00BFA5).withOpacity(0.0),
            const Color(0xFF00BFA5).withOpacity(0.10),
            const Color(0xFF00BFA5).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.46, w, h * 0.12)),
    );

    // ── 4. Deep forest — far trees ─────────────────────────
    _drawForestLayer(canvas, w, h,
        groundY: h * 0.62,
        treeHeight: h * 0.28,
        treeWidth: 38,
        count: 38,
        seed: 10,
        trunkColor: const Color(0xFF0A3D2D),
        canopyColor: const Color(0xFF00695C),
        glowColor: const Color(0xFF00BFA5),
        glowPhase: glowPhase,
        swayPhase: swayPhase,
        swayAmt: 0.012,
        glowIntensity: 0.12);

    // ── 5. Mid forest — closer, brighter glow ──────────────
    _drawForestLayer(canvas, w, h,
        groundY: h * 0.70,
        treeHeight: h * 0.36,
        treeWidth: 52,
        count: 26,
        seed: 20,
        trunkColor: const Color(0xFF063D2D),
        canopyColor: const Color(0xFF00796B),
        glowColor: const Color(0xFF1DE9B6),
        glowPhase: glowPhase,
        swayPhase: swayPhase,
        swayAmt: 0.018,
        glowIntensity: 0.20);

    // ── 6. Floating light orbs ─────────────────────────────
    _drawLightOrbs(canvas, w, h, glowPhase, firePhase);
  }

  void _drawMountainRange(Canvas canvas, double w, double h,
      double baseY, double peakH, Color color, double opacity, int peaks) {
    final path = Path()..moveTo(0, baseY);
    final rng = Random(peaks);
    final step = w / (peaks - 1);
    for (int i = 0; i < peaks; i++) {
      final px = i * step + (rng.nextDouble() - 0.5) * step * 0.4;
      final py = baseY - peakH * (0.5 + rng.nextDouble() * 0.5);
      if (i == 0) {
        path.lineTo(px, py);
      } else {
        final prevX = (i - 1) * step;
        path.cubicTo(
            prevX + step * 0.5, baseY,
            px - step * 0.3, py,
            px, py);
      }
    }
    path.lineTo(w, baseY);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));

    // Snow/glow caps on mountains
    final capPaint = Paint()
      ..color = const Color(0xFF80DEEA).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final rng2 = Random(peaks + 1);
    final step2 = w / (peaks - 1);
    for (int i = 0; i < peaks; i++) {
      final px = i * step2 + (rng2.nextDouble() - 0.5) * step2 * 0.4;
      final py = baseY - peakH * (0.5 + rng2.nextDouble() * 0.5);
      canvas.drawCircle(Offset(px, py), 18, capPaint);
    }
  }

  void _drawForestLayer(
    Canvas canvas,
    double w,
    double h, {
    required double groundY,
    required double treeHeight,
    required double treeWidth,
    required int count,
    required int seed,
    required Color trunkColor,
    required Color canopyColor,
    required Color glowColor,
    required double glowPhase,
    required double swayPhase,
    required double swayAmt,
    required double glowIntensity,
  }) {
    final rng = Random(seed);
    final spacing = w / count;

    for (int i = 0; i < count; i++) {
      final x = i * spacing + rng.nextDouble() * spacing * 0.6;
      final heightVar = 0.7 + rng.nextDouble() * 0.6;
      final th = treeHeight * heightVar;
      final tw = treeWidth * (0.7 + rng.nextDouble() * 0.6);
      final sway = sin(swayPhase * pi * 2 + i * 0.4) * swayAmt * tw;
      final t = (sin(glowPhase * pi * 2 + i * 0.9) + 1) / 2;

      canvas.save();
      canvas.translate(x, groundY);

      // Trunk
      final trunkW = tw * 0.18;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-trunkW / 2 + sway * 0.3, -th * 0.35, trunkW, th * 0.38),
          const Radius.circular(3),
        ),
        Paint()..color = trunkColor,
      );

      // Canopy glow
      canvas.drawCircle(
        Offset(sway, -th * 0.62),
        tw * 0.55,
        Paint()
          ..color = glowColor.withOpacity(glowIntensity * (0.6 + t * 0.4))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, tw * 0.4),
      );

      // Canopy body — layered circles for volume
      for (int layer = 0; layer < 3; layer++) {
        final lOffset = (layer - 1) * th * 0.08;
        final lScale = 1.0 - layer * 0.12;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(sway * (1 + layer * 0.2), -th * (0.55 + layer * 0.12) + lOffset),
            width: tw * lScale,
            height: th * 0.38 * lScale,
          ),
          Paint()
            ..color = canopyColor.withOpacity(0.75 + layer * 0.08),
        );
      }

      // Bioluminescent sparkle dots on canopy
      final dRng = Random(seed + i);
      for (int d = 0; d < 5; d++) {
        final dx = (dRng.nextDouble() - 0.5) * tw * 0.8 + sway;
        final dy = -th * 0.45 - dRng.nextDouble() * th * 0.25;
        final dt = (sin(glowPhase * pi * 2 + d * 1.7 + i * 0.3) + 1) / 2;
        canvas.drawCircle(
          Offset(dx, dy),
          1.2 + dt * 1.8,
          Paint()..color = glowColor.withOpacity(0.6 + dt * 0.4),
        );
      }

      canvas.restore();
    }
  }

  void _drawLightOrbs(
      Canvas canvas, double w, double h, double glowPhase, double firePhase) {
    final rng = Random(55);
    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * w;
      final y = h * 0.35 + rng.nextDouble() * h * 0.35;
      final t = (sin(glowPhase * pi * 2 + i * 0.8) + 1) / 2;
      final ft = (sin(firePhase * pi * 2 + i * 1.2) + 1) / 2;
      final color = i % 3 == 0
          ? const Color(0xFF1DE9B6)
          : i % 3 == 1
              ? const Color(0xFF80DEEA)
              : const Color(0xFFB2EBF2);
      // Orb glow
      canvas.drawCircle(
        Offset(x, y),
        8 + ft * 10,
        Paint()
          ..color = color.withOpacity(0.06 + t * 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      // Orb core
      canvas.drawCircle(
        Offset(x, y),
        2.0 + ft * 2.0,
        Paint()..color = color.withOpacity(0.5 + t * 0.4),
      );
    }
  }

  @override
  bool shouldRepaint(_SkyForestPainter old) =>
      old.starPhase != starPhase ||
      old.glowPhase != glowPhase ||
      old.swayPhase != swayPhase ||
      old.firePhase != firePhase;
}

// ─────────────────────────────────────────────────────────────
//  GROUND PAINTER — two houses + garden gate + ground
// ─────────────────────────────────────────────────────────────
class _GroundPainter extends CustomPainter {
  final double glowPhase;
  final double swayPhase;

  _GroundPainter({required this.glowPhase, required this.swayPhase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ground layers
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.78, w, h * 0.22),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF1B4332),
            Color(0xFF0D2B1E),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.78, w, h * 0.22)),
    );

    // Ground glow strip (bioluminescent moss)
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.77, w, h * 0.03),
      Paint()
        ..color = const Color(0xFF1DE9B6).withOpacity(0.10 + glowPhase * 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Cobblestone path between houses
    _drawPath(canvas, w, h);

    // LEFT HOUSE — chicken family (purple/pink)
    // Centred in left third of panorama
    _drawHouse(
      canvas, w, h,
      houseLeft: w * 0.22,
      houseWidth: w * 0.14,
      houseBottom: h * 0.78,
      houseHeight: h * 0.58,
      roofColor: const Color(0xFF7C4FBC),
      wallColor: const Color(0xFF2D1B69),
      accentColor: const Color(0xFFFF80AB),
      glowPhase: glowPhase,
      windowGlow: const Color(0xFFFFE082),
    );

    // RIGHT HOUSE — giraffe family (teal/gold) — slightly taller
    _drawHouse(
      canvas, w, h,
      houseLeft: w * 0.60,
      houseWidth: w * 0.16,
      houseBottom: h * 0.78,
      houseHeight: h * 0.64,
      roofColor: const Color(0xFF0F6E56),
      wallColor: const Color(0xFF0A3D2D),
      accentColor: const Color(0xFFFFD700),
      glowPhase: glowPhase,
      windowGlow: const Color(0xFFB2EBF2),
    );

    // Garden gate — between houses
    _drawGardenGate(canvas, w, h, glowPhase);

    // Flowers + glowing bushes
    _drawGarden(canvas, w, h, swayPhase, glowPhase);
  }

  void _drawPath(Canvas canvas, double w, double h) {
    final pathPaint = Paint()
      ..color = const Color(0xFF2A1F14).withOpacity(0.7);
    final path = Path()
      ..moveTo(w * 0.34, h * 0.78)
      ..lineTo(w * 0.44, h * 0.78)
      ..lineTo(w * 0.48, h)
      ..lineTo(w * 0.30, h)
      ..close();
    canvas.drawPath(path, pathPaint);

    final stonePaint = Paint()
      ..color = const Color(0xFF4A3728).withOpacity(0.5);
    final rng = Random(7);
    for (int i = 0; i < 14; i++) {
      final px = w * 0.31 + rng.nextDouble() * w * 0.16;
      final py = h * 0.80 + rng.nextDouble() * h * 0.18;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(px, py),
            width: w * 0.012,
            height: h * 0.016),
        stonePaint,
      );
    }
  }

  void _drawHouse(
    Canvas canvas,
    double w,
    double h, {
    required double houseLeft,
    required double houseWidth,
    required double houseBottom,
    required double houseHeight,
    required Color roofColor,
    required Color wallColor,
    required Color accentColor,
    required double glowPhase,
    required Color windowGlow,
  }) {
    final houseTop = houseBottom - houseHeight;
    final roofH = houseHeight * 0.30;
    final wallTop = houseTop + roofH * 0.52;
    final wallH = houseBottom - wallTop;

    // Ambient glow around house
    canvas.drawRect(
      Rect.fromLTWH(houseLeft - 10, houseTop - 5, houseWidth + 20, houseHeight + 10),
      Paint()
        ..color = accentColor.withOpacity(0.04 + glowPhase * 0.035)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    // Walls
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(houseLeft, wallTop, houseWidth, wallH),
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [wallColor.withOpacity(0.96), wallColor],
        ).createShader(Rect.fromLTWH(houseLeft, wallTop, houseWidth, wallH)),
    );

    // Roof
    final roofPath = Path()
      ..moveTo(houseLeft - houseWidth * 0.05, houseTop + roofH * 0.56)
      ..lineTo(houseLeft + houseWidth / 2, houseTop)
      ..lineTo(houseLeft + houseWidth * 1.05, houseTop + roofH * 0.56)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = roofColor);
    canvas.drawPath(
      roofPath,
      Paint()
        ..color = accentColor.withOpacity(0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Chimney
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            houseLeft + houseWidth * 0.70,
            houseTop - houseHeight * 0.07,
            houseWidth * 0.09,
            houseHeight * 0.10),
        const Radius.circular(2),
      ),
      Paint()..color = roofColor.withOpacity(0.85),
    );
    // Smoke
    for (int s = 0; s < 3; s++) {
      canvas.drawCircle(
        Offset(
          houseLeft + houseWidth * 0.745,
          houseTop - houseHeight * (0.08 + s * 0.05),
        ),
        houseWidth * (0.028 + s * 0.012),
        Paint()
          ..color = Colors.white.withOpacity((0.14 - s * 0.04) + glowPhase * 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // Windows (2 upper)
    final winY = wallTop + wallH * 0.07;
    final winH = wallH * 0.26;
    final winW = houseWidth * 0.22;
    _drawWindow(canvas, houseLeft + houseWidth * 0.10, winY, winW, winH,
        windowGlow, accentColor, glowPhase);
    _drawWindow(canvas, houseLeft + houseWidth * 0.67, winY, winW, winH,
        windowGlow, accentColor, glowPhase);

    // Door
    _drawDoor(
      canvas,
      houseLeft + houseWidth * 0.375,
      houseBottom - wallH * 0.40,
      houseWidth * 0.25,
      wallH * 0.40,
      accentColor,
    );
  }

  void _drawWindow(Canvas canvas, double x, double y, double ww, double wh,
      Color glow, Color accent, double glowPhase) {
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
          colors: [glow.withOpacity(0.80), glow.withOpacity(0.38)],
        ).createShader(Rect.fromLTWH(x, y, ww, wh)),
    );
    final divPaint = Paint()
      ..color = accent.withOpacity(0.4)
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(x + ww / 2, y + 2), Offset(x + ww / 2, y + wh - 2), divPaint);
    canvas.drawLine(
        Offset(x + 2, y + wh / 2), Offset(x + ww - 2, y + wh / 2), divPaint);
  }

  void _drawDoor(Canvas canvas, double x, double y, double dw, double dh,
      Color accent) {
    final doorPath = Path()
      ..moveTo(x, y + dh)
      ..lineTo(x, y + dh * 0.30)
      ..arcToPoint(Offset(x + dw, y + dh * 0.30),
          radius: Radius.circular(dw / 2), clockwise: false)
      ..lineTo(x + dw, y + dh)
      ..close();
    canvas.drawPath(doorPath, Paint()..color = accent.withOpacity(0.22));
    canvas.drawPath(
        doorPath,
        Paint()
          ..color = accent.withOpacity(0.80)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(
        Offset(x + dw * 0.75, y + dh * 0.58),
        dw * 0.07,
        Paint()..color = const Color(0xFFFFD700));
  }

  void _drawGardenGate(Canvas canvas, double w, double h, double glowPhase) {
    // Gate centred between the two houses
    final gx = w * 0.375;
    final gy = h * 0.50;
    final gw = w * 0.060;
    final gh = h * 0.30;

    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(gx + gw / 2, gy + gh / 2),
          width: gw * 2.5,
          height: gh * 1.5),
      Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.07 + glowPhase * 0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    final postPaint = Paint()..color = const Color(0xFF8B6914);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(gx - w * 0.007, gy, w * 0.010, gh),
            const Radius.circular(2)),
        postPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(gx + gw - w * 0.003, gy, w * 0.010, gh),
            const Radius.circular(2)),
        postPaint);

    final archPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(
        Rect.fromLTWH(gx - w * 0.007, gy - gh * 0.28, gw + w * 0.014, gh * 0.56),
        pi, pi, false, archPaint);

    final barPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.85)
      ..strokeWidth = 2.5;
    for (int i = 0; i < 5; i++) {
      final bx = gx + gw * (i + 0.5) / 5;
      canvas.drawLine(
          Offset(bx, gy + gh * 0.10), Offset(bx, gy + gh), barPaint);
    }

    final tp = TextPainter(
      text: TextSpan(
        text: '✿ Garden ✿',
        style: TextStyle(
          color: const Color(0xFFFFD700).withOpacity(0.95),
          fontSize: w * 0.010,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(gx + gw / 2 - tp.width / 2, gy - gh * 0.46));
  }

  void _drawGarden(
      Canvas canvas, double w, double h, double swayPhase, double glowPhase) {
    // Glowing flower beds
    _drawFlowerBed(canvas, w * 0.22, h * 0.76, w, h, swayPhase, glowPhase,
        const Color(0xFFFF80AB), const Color(0xFFFF4081));
    _drawFlowerBed(canvas, w * 0.44, h * 0.76, w, h, swayPhase, glowPhase,
        const Color(0xFF1DE9B6), const Color(0xFF00BFA5));
    _drawFlowerBed(canvas, w * 0.54, h * 0.76, w, h, swayPhase, glowPhase,
        const Color(0xFFFFD700), const Color(0xFFFFAB00));
    _drawFlowerBed(canvas, w * 0.76, h * 0.76, w, h, swayPhase, glowPhase,
        const Color(0xFFB2EBF2), const Color(0xFF80DEEA));

    // Glowing bushes along houses
    _drawGlowBush(canvas, w * 0.07, h * 0.77, w * 0.04, h * 0.06,
        const Color(0xFF00695C), const Color(0xFF1DE9B6), glowPhase);
    _drawGlowBush(canvas, w * 0.21, h * 0.77, w * 0.035, h * 0.05,
        const Color(0xFF00796B), const Color(0xFF1DE9B6), glowPhase);
    _drawGlowBush(canvas, w * 0.59, h * 0.77, w * 0.04, h * 0.06,
        const Color(0xFF00695C), const Color(0xFFB2EBF2), glowPhase);
    _drawGlowBush(canvas, w * 0.75, h * 0.77, w * 0.035, h * 0.05,
        const Color(0xFF00796B), const Color(0xFFB2EBF2), glowPhase);
  }

  void _drawFlowerBed(Canvas canvas, double x, double y, double w, double h,
      double swayPhase, double glowPhase, Color petalColor, Color glowColor) {
    final rng = Random(x.toInt());
    for (int i = 0; i < 8; i++) {
      final fx = x + rng.nextDouble() * w * 0.055;
      final fy = y + rng.nextDouble() * h * 0.018;
      final sway = sin(swayPhase * pi * 2 + i * 0.8) * 0.07;
      final t = (sin(glowPhase * pi * 2 + i * 1.4) + 1) / 2;
      canvas.save();
      canvas.translate(fx, fy);
      canvas.rotate(sway);
      // Glow
      canvas.drawCircle(Offset(0, -h * 0.048), w * 0.006,
          Paint()
            ..color = glowColor.withOpacity(0.3 + t * 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      // Stem
      canvas.drawLine(Offset.zero, Offset(0, -h * 0.046),
          Paint()
            ..color = const Color(0xFF2D6A4F)
            ..strokeWidth = 1.5);
      // Petal
      canvas.drawCircle(Offset(0, -h * 0.048), w * 0.005,
          Paint()..color = petalColor.withOpacity(0.95));
      canvas.restore();
    }
  }

  void _drawGlowBush(Canvas canvas, double x, double y, double bw, double bh,
      Color color, Color glowColor, double glowPhase) {
    final t = (sin(glowPhase * pi * 2 + x) + 1) / 2;
    // Glow
    canvas.drawCircle(
      Offset(x + bw / 2, y - bh / 2),
      bw * 0.8,
      Paint()
        ..color = glowColor.withOpacity(0.08 + t * 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    final paint = Paint()..color = color;
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
          Offset(x + bw * i / 3, y - bh * (i % 2 == 0 ? 0.3 : 0.65)),
          bw * 0.32,
          paint);
    }
  }

  @override
  bool shouldRepaint(_GroundPainter old) =>
      old.glowPhase != glowPhase || old.swayPhase != swayPhase;
}

// ─────────────────────────────────────────────────────────────
//  FOREGROUND PAINTER — grass + fireflies
// ─────────────────────────────────────────────────────────────
class _ForegroundPainter extends CustomPainter {
  final double swayPhase;
  final double firePhase;
  final double glowPhase;

  _ForegroundPainter({
    required this.swayPhase,
    required this.firePhase,
    required this.glowPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Foreground grass
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.88, w, h * 0.12),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF1B4332), Color(0xFF0D2B1E)],
        ).createShader(Rect.fromLTWH(0, h * 0.88, w, h * 0.12)),
    );

    // Bioluminescent ground glow
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.87, w, h * 0.025),
      Paint()
        ..color = const Color(0xFF1DE9B6).withOpacity(0.08 + glowPhase * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Grass blades
    final rng = Random(77);
    final bladePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * w;
      final baseY = h * 0.88 + rng.nextDouble() * h * 0.02;
      final bladeH = h * 0.032 + rng.nextDouble() * h * 0.028;
      final sway = sin(swayPhase * pi * 2 + i * 0.5) * 5;
      final isGlow = i % 7 == 0;
      bladePaint.color = isGlow
          ? const Color(0xFF1DE9B6).withOpacity(0.5)
          : const Color(0xFF52B788).withOpacity(0.65);
      canvas.drawLine(
          Offset(x, baseY), Offset(x + sway, baseY - bladeH), bladePaint);
    }

    // Fireflies
    final fRng = Random(33);
    for (int i = 0; i < 30; i++) {
      final x = fRng.nextDouble() * w;
      final y = h * 0.45 + fRng.nextDouble() * h * 0.42;
      final t = (sin(firePhase * pi * 2 + i * 0.9) + 1) / 2;
      final ft = (sin(glowPhase * pi * 2 + i * 1.5) + 1) / 2;
      if (t > 0.3) {
        final color = i % 2 == 0
            ? const Color(0xFF1DE9B6)
            : const Color(0xFFB2EBF2);
        canvas.drawCircle(
          Offset(x, y),
          3 + ft * 3,
          Paint()
            ..color = color.withOpacity(0.12 + t * 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(
          Offset(x, y),
          1.2 + ft * 1.0,
          Paint()..color = color.withOpacity(0.7 + t * 0.3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ForegroundPainter old) =>
      old.swayPhase != swayPhase ||
      old.firePhase != firePhase ||
      old.glowPhase != glowPhase;
}
