import 'dart:math';
import 'package:flutter/material.dart';
import 'fab_world_theme.dart';

// ─────────────────────────────────────────────────────────────
// FAB SEASON PARTICLES
// Draws seasonal ambient particles as a CustomPainter layer.
// Spring  → butterflies (curved flutter paths)
// Summer  → fireflies   (glowing drifting dots)
// Autumn  → falling leaves (spinning ovals)
// Winter  → snow         (soft falling circles)
// ─────────────────────────────────────────────────────────────

class FabSeasonParticles extends StatelessWidget {
  final FabWorldTheme theme;
  final double phase;   // 0..1 from animation controller
  final double worldP;  // world phase for secondary drift

  const FabSeasonParticles({
    super.key,
    required this.theme,
    required this.phase,
    required this.worldP,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(
          theme: theme,
          phase: phase,
          worldP: worldP,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final FabWorldTheme theme;
  final double phase;
  final double worldP;

  static const int _count = 28;
  static final _rng = Random(77);
  static final _seeds = List.generate(
    _count,
    (i) => (
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: 0.5 + _rng.nextDouble(),
      speed: 0.4 + _rng.nextDouble() * 0.6,
      wobble: _rng.nextDouble() * pi * 2,
      spin: _rng.nextDouble() * pi * 2,
    ),
  );

  const _ParticlePainter({
    required this.theme,
    required this.phase,
    required this.worldP,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (theme.season) {
      case FabSeason.spring:
        _drawButterflies(canvas, size);
      case FabSeason.summer:
        _drawFireflies(canvas, size);
      case FabSeason.autumn:
        _drawLeaves(canvas, size);
      case FabSeason.winter:
        _drawSnow(canvas, size);
    }

    if (theme.showRain) _drawRain(canvas, size);
  }

  void _drawFireflies(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = (sin(phase * pi * 2) + 1) / 2;

    for (int i = 0; i < _count; i++) {
      final s = _seeds[i];
      final x = s.x * w + sin(worldP * pi * 2 + s.wobble) * w * 0.03;
      final y = h * (0.40 + s.y * 0.38) + sin(worldP * pi * 2 * s.speed + s.spin) * h * 0.02;
      final opacity = 0.08 + t * 0.22 + (sin(phase * pi * 2 * s.speed + s.wobble) + 1) / 2 * 0.18;

      canvas.drawCircle(
        Offset(x, y),
        1.2 + s.size * 1.2,
        Paint()
          ..color = theme.particleColor.withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  void _drawButterflies(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (int i = 0; i < _count ~/ 2; i++) {
      final s = _seeds[i];
      final progress = (phase * s.speed + s.x) % 1.0;
      final x = progress * w * 1.2 - w * 0.1;
      final y = h * (0.35 + s.y * 0.35) +
          sin(progress * pi * 6 + s.wobble) * h * 0.04;
      final flutter = sin(phase * pi * 8 * s.speed + s.spin);
      final opacity = 0.30 + (sin(progress * pi) * 0.50).clamp(0, 0.5);

      final paint = Paint()
        ..color = theme.particleColor.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Simple 2-oval butterfly
      final wingSpread = (3 + s.size * 3) * (0.6 + flutter.abs() * 0.4);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(sin(progress * pi * 2) * 0.15);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(-wingSpread * 0.6, -wingSpread * 0.2),
          width: wingSpread * 1.2,
          height: wingSpread * 0.7,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(wingSpread * 0.6, -wingSpread * 0.2),
          width: wingSpread * 1.2,
          height: wingSpread * 0.7,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawLeaves(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final leafColors = [
      const Color(0xFFCC4400),
      const Color(0xFFDD7700),
      const Color(0xFFBB3300),
      const Color(0xFFEE9900),
      const Color(0xFF993300),
    ];

    for (int i = 0; i < _count; i++) {
      final s = _seeds[i];
      final progress = (phase * s.speed * 0.4 + s.x) % 1.0;
      final x = s.x * w + sin(progress * pi * 4 + s.wobble) * w * 0.06;
      final y = (progress * h * 1.3) - h * 0.1;
      final rotation = s.spin + progress * pi * 4;
      final leafSize = 3 + s.size * 4;

      if (y < 0 || y > h) continue;

      final paint = Paint()
        ..color = leafColors[i % leafColors.length].withValues(alpha: 0.65);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Leaf oval
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: leafSize * 2,
          height: leafSize,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawSnow(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (int i = 0; i < _count + 20; i++) {
      final s = _seeds[i % _count];
      final progress = (phase * s.speed * 0.25 + s.x) % 1.0;
      final x = s.x * w +
          sin(progress * pi * 3 + s.wobble) * w * 0.04 +
          sin(worldP * pi * 2 * 0.3) * w * 0.02;
      final y = (progress * h * 1.2) - h * 0.1;

      if (y < 0 || y > h) continue;

      final r = 1.5 + s.size * 2.0;
      final opacity = 0.25 + s.y * 0.45;

      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = theme.particleColor.withValues(alpha: opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.6),
      );
    }
  }

  void _drawRain(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rng2 = Random(55);

    for (int i = 0; i < 60; i++) {
      final x = rng2.nextDouble() * w;
      final startY = (phase * h * 1.5 + rng2.nextDouble() * h) % (h * 1.1) - h * 0.05;
      final len = 6 + rng2.nextDouble() * 10;

      canvas.drawLine(
        Offset(x + startY * 0.15, startY),
        Offset(x + (startY + len) * 0.15, startY + len),
        Paint()
          ..color = const Color(0xFF88AACC).withValues(alpha: 0.22)
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.phase != phase || old.worldP != worldP;
}
