import 'dart:math';
import 'package:flutter/material.dart';
import '../fab_theme.dart';

class FireflyOverlay extends StatefulWidget {
  const FireflyOverlay({super.key});

  @override
  State<FireflyOverlay> createState() => _FireflyOverlayState();
}

class _FireflyOverlayState extends State<FireflyOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: FireflyPainter(animationValue: _ctrl.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class FireflyPainter extends CustomPainter {
  final double animationValue;
  const FireflyPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final gY = size.height * 0.78;
    final rng = Random(99);

    for (int i = 0; i < 12; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = gY - 20 - rng.nextDouble() * size.height * 0.35;

      // Each firefly drifts on its own Lissajous path
      final t = animationValue * 2 * pi + i * 0.85;
      final x = baseX + sin(t * 0.7 + i) * 18 + cos(t * 0.4) * 12;
      final y = baseY + cos(t * 0.5 + i * 0.6) * 14 + sin(t * 0.3) * 10;

      // Glow pulse — each firefly has its own phase
      final glow = (sin(t * 2.2 + i * 1.3) * 0.5 + 0.5);
      if (glow < 0.3) continue; // off phase

      final col = i % 3 == 0 ? FabColors.gold
        : i % 3 == 1 ? FabColors.teal
        : FabColors.rose;

      canvas.drawCircle(Offset(x, y), 5 * glow,
        Paint()..color = col.withValues(alpha: glow * 0.15));
      canvas.drawCircle(Offset(x, y), 2 * glow,
        Paint()..color = col.withValues(alpha: glow * 0.85));
      canvas.drawCircle(Offset(x, y), 0.8 * glow,
        Paint()..color = Colors.white.withValues(alpha: glow * 0.9));
      canvas.drawLine(
        Offset(x, y),
        Offset(x - sin(t * 0.7 + i) * 6, y - cos(t * 0.5 + i * 0.6) * 4),
        Paint()
          ..color = col.withValues(alpha: glow * 0.2)
          ..strokeWidth = 1.0..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(FireflyPainter old) =>
      old.animationValue != animationValue;
}
