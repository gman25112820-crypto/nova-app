import 'package:flutter/material.dart';
import 'dart:math';
import "../fab_theme.dart";

// ── Easing ────────────────────────────────────────────────
double _easeInOut(double t) => t < 0.5 ? 2*t*t : -1+(4-2*t)*t;

class FabWorldPainter extends CustomPainter {
  final double animationValue;

  FabWorldPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Layer order: sky → moon/aurora → stars → far trees →
    // clouds → mid trees → ground → homes → garden → flowers →
    // mushrooms → foreground → fireflies
    _drawSky(canvas, size);
    _drawMoon(canvas, size);
    _drawAurora(canvas, size);
    _drawStars(canvas, size);
    _drawFarTrees(canvas, size);
    _drawClouds(canvas, size);
    _drawMidTrees(canvas, size);
    _drawGround(canvas, size);
    _drawHomes(canvas, size);
    _drawGardenCentre(canvas, size);
    _drawFlowers(canvas, size);
    _drawMushrooms(canvas, size);
    _drawFloatingStars(canvas, size);
    _drawForeground(canvas, size);
    _drawFireflies(canvas, size);
  }

  // ── SKY — deep purple gradient ─────────────────────────
  void _drawSky(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF060318),
          FabColors.bg,
          FabColors.mid,
          const Color(0xFF3d1580),
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  // ── MOON ──────────────────────────────────────────────
  void _drawMoon(Canvas canvas, Size size) {
    final moonX = size.width * 0.82;
    final moonY = size.height * 0.12;
    final moonR = size.width * 0.048;
    final pulse = 0.92 + sin(animationValue * 2 * pi * 0.3) * 0.08;

    // Outer glow
    for (int i = 3; i >= 1; i--) {
      canvas.drawCircle(
        Offset(moonX, moonY),
        moonR * (1 + i * 0.5) * pulse,
        Paint()..color = const Color(0xFFE8D5FF).withValues(alpha: 0.04 * i),
      );
    }

    // Moon body
    canvas.drawCircle(
      Offset(moonX, moonY),
      moonR * pulse,
      Paint()..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          const Color(0xFFFFF8E7),
          const Color(0xFFE8D5A3),
          const Color(0xFFD4B896),
        ],
      ).createShader(Rect.fromCircle(center: Offset(moonX, moonY), radius: moonR)),
    );

    // Crater details
    final craterPaint = Paint()..color = const Color(0xFFD4B896).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(moonX - moonR*0.3, moonY - moonR*0.1), moonR*0.18, craterPaint);
    canvas.drawCircle(Offset(moonX + moonR*0.2, moonY + moonR*0.3), moonR*0.12, craterPaint);
    canvas.drawCircle(Offset(moonX - moonR*0.1, moonY + moonR*0.1), moonR*0.08, craterPaint);
  }

  // ── AURORA ─────────────────────────────────────────────
  void _drawAurora(Canvas canvas, Size size) {
    final t = animationValue * 2 * pi;
    for (int i = 0; i < 3; i++) {
      final phase = t + i * 1.2;
      final yBase = size.height * (0.15 + i * 0.04);
      final amp = size.height * 0.04;
      final col = [
        const Color(0xFF00C9A7),
        const Color(0xFF7B4FFF),
        const Color(0xFFFF8FAB),
      ][i];

      final path = Path();
      path.moveTo(0, yBase);
      for (double x = 0; x <= size.width; x += 8) {
        final y = yBase + sin(x * 0.008 + phase) * amp +
            cos(x * 0.005 + phase * 0.7) * amp * 0.5;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
      path.close();

      canvas.drawPath(
        path,
        Paint()..color = col.withValues(alpha: 0.06 + sin(phase * 0.5).abs() * 0.04),
      );
    }
  }

  // ── STARS ─────────────────────────────────────────────
  void _drawStars(Canvas canvas, Size size) {
    final rng = Random(42);
    for (int i = 0; i < 120; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.6;
      final twinkle = sin(animationValue * 2 * pi + i * 0.73);
      final opacity = 0.25 + (twinkle * 0.35).abs();
      final r = rng.nextDouble() * 1.6 + 0.4;

      // Some stars have a cross sparkle
      if (i % 12 == 0) {
        final sp = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.6)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(x, y - r*2.5), Offset(x, y + r*2.5), sp);
        canvas.drawLine(Offset(x - r*2.5, y), Offset(x + r*2.5, y), sp);
      }

      canvas.drawCircle(
        Offset(x, y), r,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
  }

  // ── FAR TREES (layer 1 — darkest, smallest) ───────────
  void _drawFarTrees(Canvas canvas, Size size) {
    final gY = size.height * 0.78;
    final treePaint = Paint()..color = const Color(0xFF160640).withValues(alpha: 0.7);
    final positions = [0.03, 0.09, 0.38, 0.46, 0.54, 0.62, 0.70, 0.89, 0.96];
    final heights = [52.0, 38.0, 48.0, 34.0, 58.0, 36.0, 42.0, 46.0, 32.0];

    for (int i = 0; i < positions.length; i++) {
      final x = size.width * positions[i];
      final h = heights[i];
      // Trunk
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 3, gY - h*0.3, 6, h*0.3), const Radius.circular(2)),
        Paint()..color = const Color(0xFF0e0328).withValues(alpha: 0.6),
      );
      // Canopy — layered for depth
      canvas.drawPath(
        Path()
          ..moveTo(x - h*0.36, gY - h*0.28)
          ..lineTo(x, gY - h)
          ..lineTo(x + h*0.36, gY - h*0.28)
          ..close(),
        treePaint,
      );
      // Second layer of canopy
      canvas.drawPath(
        Path()
          ..moveTo(x - h*0.28, gY - h*0.5)
          ..lineTo(x, gY - h*1.22)
          ..lineTo(x + h*0.28, gY - h*0.5)
          ..close(),
        treePaint,
      );
    }
  }

  // ── MID TREES (layer 2 — slightly lighter) ─────────────
  void _drawMidTrees(Canvas canvas, Size size) {
    final gY = size.height * 0.78;
    final treePaint = Paint()..color = const Color(0xFF220a50).withValues(alpha: 0.65);
    final positions = [0.01, 0.15, 0.42, 0.58, 0.75, 0.93, 0.99];
    final heights = [70.0, 55.0, 42.0, 38.0, 60.0, 45.0, 50.0];

    for (int i = 0; i < positions.length; i++) {
      final x = size.width * positions[i];
      final h = heights[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 4, gY - h*0.32, 8, h*0.32), const Radius.circular(3)),
        Paint()..color = const Color(0xFF160640).withValues(alpha: 0.55),
      );
      canvas.drawPath(
        Path()
          ..moveTo(x - h*0.4, gY - h*0.3)
          ..lineTo(x, gY - h)
          ..lineTo(x + h*0.4, gY - h*0.3)
          ..close(),
        treePaint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(x - h*0.3, gY - h*0.52)
          ..lineTo(x, gY - h*1.25)
          ..lineTo(x + h*0.3, gY - h*0.52)
          ..close(),
        treePaint,
      );
    }
  }

  // ── CLOUDS ────────────────────────────────────────────
  void _drawClouds(Canvas canvas, Size size) {
    // Layer 1 — far, slow, small, transparent
    final far = Paint()..color = const Color(0xFF4a1a8a).withValues(alpha: 0.3);
    for (int i = 0; i < 4; i++) {
      final x = ((animationValue * 0.18 + i * 0.25) % 1.0) * (size.width + 240) - 120;
      _drawCloud(canvas, far, Offset(x, size.height * (0.07 + i * 0.025)), 28.0 + i * 6);
    }
    // Layer 2 — mid
    final mid = Paint()..color = const Color(0xFF5a2a9a).withValues(alpha: 0.5);
    for (int i = 0; i < 3; i++) {
      final x = ((animationValue * 0.35 + i * 0.33) % 1.0) * (size.width + 200) - 100;
      _drawCloud(canvas, mid, Offset(x, size.height * (0.12 + i * 0.04)), 48.0 + i * 12);
    }
    // Layer 3 — near, fast, large
    final near = Paint()..color = const Color(0xFF5a2a9a).withValues(alpha: 0.65);
    for (int i = 0; i < 2; i++) {
      final x = ((animationValue * 0.62 + i * 0.5) % 1.0) * (size.width + 200) - 100;
      _drawCloud(canvas, near, Offset(x, size.height * (0.17 + i * 0.03)), 72.0 + i * 18);
    }
  }

  void _drawCloud(Canvas canvas, Paint p, Offset pos, double scale) {
    canvas.drawCircle(pos, scale * 0.4, p);
    canvas.drawCircle(pos.translate(scale*0.42, scale*0.08), scale*0.34, p);
    canvas.drawCircle(pos.translate(-scale*0.38, scale*0.1), scale*0.30, p);
    canvas.drawCircle(pos.translate(scale*0.14, scale*0.26), scale*0.38, p);
    canvas.drawCircle(pos.translate(-scale*0.18, scale*0.24), scale*0.28, p);
  }

  // ── GROUND ────────────────────────────────────────────
  void _drawGround(Canvas canvas, Size size) {
    final gY = size.height * 0.78;

    // Main ground
    canvas.drawPath(
      Path()
        ..moveTo(0, gY)
        ..quadraticBezierTo(size.width*0.25, gY-22, size.width*0.5, gY)
        ..quadraticBezierTo(size.width*0.75, gY+22, size.width, gY)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [FabColors.panel, const Color(0xFF1A0A2E)],
      ).createShader(Rect.fromLTWH(0, gY, size.width, size.height - gY)),
    );

    // Ground glow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, gY + 8),
        width: size.width * 0.85, height: 28,
      ),
      Paint()..color = FabColors.pink.withValues(alpha: 0.08),
    );

    // Grass ripple
    final gOff = animationValue * 22;
    final gP = Paint()
      ..color = const Color(0xFF3d6b2a).withValues(alpha: 0.45)
      ..strokeWidth = 2.0 ..style = PaintingStyle.stroke;
    for (double x = -22 + gOff % 22; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, gY + 5), Offset(x + 9, gY - 5), gP);
    }

    _drawStonePath(canvas, size, gY);
  }

  void _drawStonePath(Canvas canvas, Size size, double gY) {
    const count = 10;
    final startX = size.width * 0.30;
    final endX = size.width * 0.64;
    for (int i = 0; i < count; i++) {
      final t = i / (count - 1);
      final x = startX + (endX - startX) * t;
      final wobble = sin(i * 1.4) * 7;
      final stonePulse = 0.85 + sin(animationValue * 2 * pi + i * 0.8) * 0.15;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, gY + 9 + wobble),
          width: 20 * stonePulse, height: 9,
        ),
        Paint()..color = const Color(0xFF5a2a90).withValues(alpha: 0.65),
      );
    }
  }

  // ── HOMES ─────────────────────────────────────────────
  void _drawHomes(Canvas canvas, Size size) {
    _drawChickenHome(canvas, size);
    _drawGiraffeHome(canvas, size);
  }

  void _drawChickenHome(Canvas canvas, Size size) {
    final gY = size.height * 0.78;
    final cx = size.width * 0.22;

    // Wall with gradient
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 58, gY - 96, 116, 96), const Radius.circular(10)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [const Color(0xFF4a1a90), const Color(0xFF2d0d60)],
      ).createShader(Rect.fromLTWH(cx - 58, gY - 96, 116, 96)),
    );

    // Roof with gradient
    canvas.drawPath(
      Path()
        ..moveTo(cx - 68, gY - 96)
        ..lineTo(cx, gY - 155)
        ..lineTo(cx + 68, gY - 96)
        ..close(),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFFFF6B9D), FabColors.pink],
      ).createShader(Rect.fromLTWH(cx - 68, gY - 155, 136, 59)),
    );

    // Roof shadow underside
    canvas.drawPath(
      Path()
        ..moveTo(cx - 68, gY - 96)
        ..lineTo(cx + 68, gY - 96)
        ..lineTo(cx + 62, gY - 108)
        ..lineTo(cx - 62, gY - 108)
        ..close(),
      Paint()..color = const Color(0xFF1A0A2E).withValues(alpha: 0.3),
    );

    // Door
    canvas.drawPath(
      Path()..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - 17, gY - 54, 34, 54),
        topLeft: const Radius.circular(17), topRight: const Radius.circular(17),
      )),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [FabColors.gold, const Color(0xFFD4A800)],
      ).createShader(Rect.fromLTWH(cx - 17, gY - 54, 34, 54)),
    );
    // Door knob
    canvas.drawCircle(Offset(cx + 8, gY - 22), 2.5,
      Paint()..color = const Color(0xFF8B6914));

    // Windows with animated glow
    final winGlow = 0.10 + sin(animationValue * 2 * pi) * 0.06;
    for (final wx in [cx - 50.0, cx + 26.0]) {
      // Glow behind window
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx - 2, gY - 79, 28, 24), const Radius.circular(5)),
        Paint()..color = FabColors.gold.withValues(alpha: winGlow * 1.5),
      );
      // Window frame
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx, gY - 77, 24, 20), const Radius.circular(4)),
        Paint()..color = FabColors.gold.withValues(alpha: winGlow),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx, gY - 77, 24, 20), const Radius.circular(4)),
        Paint()..color = Colors.white.withValues(alpha: 0.15),
      );
      // Window cross
      final wP = Paint()..color = const Color(0xFF4a1a90).withValues(alpha: 0.4)..strokeWidth = 1.5;
      canvas.drawLine(Offset(wx + 12, gY - 77), Offset(wx + 12, gY - 57), wP);
      canvas.drawLine(Offset(wx, gY - 67), Offset(wx + 24, gY - 67), wP);
    }

    // Light beam from windows
    for (final wx in [cx - 38.0, cx + 38.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(wx - 8, gY - 70)
          ..lineTo(wx + 8, gY - 70)
          ..lineTo(wx + 25, gY - 20)
          ..lineTo(wx - 25, gY - 20)
          ..close(),
        Paint()..color = FabColors.gold.withValues(
            alpha: (0.03 + sin(animationValue * 2 * pi) * 0.015).clamp(0, 0.06)),
      );
    }

    // House number / detail
    canvas.drawCircle(Offset(cx, gY - 108),
      4, Paint()..color = FabColors.gold.withValues(alpha: 0.7));
  }

  void _drawGiraffeHome(Canvas canvas, Size size) {
    final gY = size.height * 0.78;
    final cx = size.width * 0.78;

    // Tall wall
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 58, gY - 168, 116, 168), const Radius.circular(8)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [const Color(0xFF3a1278), const Color(0xFF22094a)],
      ).createShader(Rect.fromLTWH(cx - 58, gY - 168, 116, 168)),
    );

    // Pointed roof
    canvas.drawPath(
      Path()
        ..moveTo(cx - 68, gY - 168)
        ..lineTo(cx, gY - 235)
        ..lineTo(cx + 68, gY - 168)
        ..close(),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFF9B6FFF), FabColors.panel2],
      ).createShader(Rect.fromLTWH(cx - 68, gY - 235, 136, 67)),
    );

    // Roof shadow
    canvas.drawPath(
      Path()
        ..moveTo(cx - 68, gY - 168)
        ..lineTo(cx + 68, gY - 168)
        ..lineTo(cx + 62, gY - 180)
        ..lineTo(cx - 62, gY - 180)
        ..close(),
      Paint()..color = const Color(0xFF1A0A2E).withValues(alpha: 0.3),
    );

    // Tall door
    canvas.drawPath(
      Path()..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - 19, gY - 96, 38, 96),
        topLeft: const Radius.circular(19), topRight: const Radius.circular(19),
      )),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [FabColors.duckOrange, const Color(0xFFB07020)],
      ).createShader(Rect.fromLTWH(cx - 19, gY - 96, 38, 96)),
    );
    canvas.drawCircle(Offset(cx + 9, gY - 38), 2.5,
      Paint()..color = const Color(0xFF6B4410));

    // High windows (giraffe eye level)
    final winGlow = 0.10 + sin(animationValue * 2 * pi + 1.2) * 0.06;
    for (final wx in [cx - 50.0, cx + 26.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx - 2, gY - 147, 28, 26), const Radius.circular(5)),
        Paint()..color = FabColors.duckOrange.withValues(alpha: winGlow * 1.5),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx, gY - 145, 24, 22), const Radius.circular(4)),
        Paint()..color = FabColors.duckOrange.withValues(alpha: winGlow),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx, gY - 145, 24, 22), const Radius.circular(4)),
        Paint()..color = Colors.white.withValues(alpha: 0.15),
      );
      final wP = Paint()..color = const Color(0xFF3a1278).withValues(alpha: 0.4)..strokeWidth = 1.5;
      canvas.drawLine(Offset(wx + 12, gY - 145), Offset(wx + 12, gY - 123), wP);
      canvas.drawLine(Offset(wx, gY - 134), Offset(wx + 24, gY - 134), wP);
    }
  }

  // ── GARDEN CENTRE ─────────────────────────────────────
  void _drawGardenCentre(Canvas canvas, Size size) {
    final gY = size.height * 0.78;
    final cx = size.width * 0.50;

    // Cobblestone area
    final cobble = Paint()..color = const Color(0xFF3d1a70).withValues(alpha: 0.4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, gY + 2), width: 95, height: 18),
      cobble,
    );

    // Gate posts
    final gateP = Paint()
      ..color = FabColors.gold.withValues(alpha: 0.9)
      ..strokeWidth = 3.2 ..style = PaintingStyle.stroke;
    const gateTopY_offset = 55.0;
    final gateTopY = gY - gateTopY_offset;

    canvas.drawLine(Offset(cx - 15, gY), Offset(cx - 15, gateTopY), gateP);
    canvas.drawLine(Offset(cx + 15, gY), Offset(cx + 15, gateTopY), gateP);

    // Arch
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, gateTopY), width: 30, height: 24),
      pi, pi, false, gateP,
    );

    // Gate bars
    canvas.drawLine(Offset(cx - 15, gateTopY + 15), Offset(cx + 15, gateTopY + 15), gateP);
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(cx + i * 7, gateTopY + 15),
        Offset(cx + i * 7, gY),
        Paint()
          ..color = FabColors.gold.withValues(alpha: 0.6)
          ..strokeWidth = 1.8 ..style = PaintingStyle.stroke,
      );
    }

    // Gate finials (top decorations)
    for (final gx in [cx - 15.0, cx + 15.0]) {
      canvas.drawCircle(Offset(gx, gateTopY), 3.5,
        Paint()..color = FabColors.gold);
      canvas.drawCircle(Offset(gx, gateTopY), 1.8,
        Paint()..color = FabColors.rose);
    }

    // Sign above gate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, gateTopY - 16), width: 58, height: 18),
        const Radius.circular(5)),
      Paint()..color = const Color(0xFF3d1a80).withValues(alpha: 0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, gateTopY - 16), width: 58, height: 18),
        const Radius.circular(5)),
      Paint()
        ..color = FabColors.gold.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke ..strokeWidth = 0.8,
    );
    // Dots on sign representing text
    final dotP = Paint()..color = FabColors.gold.withValues(alpha: 0.8);
    for (int i = 0; i < 6; i++) {
      canvas.drawCircle(Offset(cx - 18 + i * 7.0, gateTopY - 16), 1.8, dotP);
    }

    // Planters
    _drawPlanter(canvas, Offset(cx - 42, gY - 20), 0);
    _drawPlanter(canvas, Offset(cx + 30, gY - 20), 1);

    // Extra small planters
    _drawSmallPlanter(canvas, Offset(cx - 56, gY - 14), 2);
    _drawSmallPlanter(canvas, Offset(cx + 44, gY - 14), 3);
  }

  void _drawPlanter(Canvas canvas, Offset pos, int v) {
    final sway = sin(animationValue * 2 * pi + v * 1.6) * 3.5;
    final col = [FabColors.pink, FabColors.rose, FabColors.gold, FabColors.teal][v % 4];

    // Pot
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx, pos.dy, 22, 20), const Radius.circular(4)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [const Color(0xFF6a30a0), const Color(0xFF3d1a70)],
      ).createShader(Rect.fromLTWH(pos.dx, pos.dy, 22, 20)),
    );
    // Soil
    canvas.drawOval(
      Rect.fromLTWH(pos.dx + 1, pos.dy, 20, 7),
      Paint()..color = const Color(0xFF2a0e45).withValues(alpha: 0.7),
    );
    // Stem
    canvas.drawLine(
      Offset(pos.dx + 11, pos.dy + 2),
      Offset(pos.dx + 11 + sway, pos.dy - 22),
      Paint()..color = const Color(0xFF3d6b2a)..strokeWidth = 2.2..style = PaintingStyle.stroke,
    );
    // Flower
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * pi / 5;
      canvas.drawCircle(
        Offset(pos.dx + 11 + sway + cos(a) * 5, pos.dy - 22 + sin(a) * 5),
        3.5, Paint()..color = col.withValues(alpha: 0.9),
      );
    }
    canvas.drawCircle(
      Offset(pos.dx + 11 + sway, pos.dy - 22),
      4, Paint()..color = FabColors.gold,
    );
  }

  void _drawSmallPlanter(Canvas canvas, Offset pos, int v) {
    final sway = sin(animationValue * 2 * pi + v * 2.1) * 2.5;
    final col = [FabColors.teal, FabColors.rose][v % 2];

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx, pos.dy, 14, 13), const Radius.circular(3)),
      Paint()..color = const Color(0xFF5a2090).withValues(alpha: 0.75),
    );
    canvas.drawLine(
      Offset(pos.dx + 7, pos.dy + 1),
      Offset(pos.dx + 7 + sway, pos.dy - 14),
      Paint()..color = const Color(0xFF3d6b2a)..strokeWidth = 1.8..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(pos.dx + 7 + sway, pos.dy - 14),
      5, Paint()..color = col.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(pos.dx + 7 + sway, pos.dy - 14),
      2.5, Paint()..color = FabColors.gold,
    );
  }

  // ── FLOWERS ───────────────────────────────────────────
  void _drawFlowers(Canvas canvas, Size size) {
    final sway = sin(animationValue * 2 * pi);
    final gY = size.height * 0.78;

    final flowers = [
      [0.19, 0.0, FabColors.pink, 1.0],
      [0.74, 0.0, FabColors.panel2, -1.0],
      [0.84, 2.0, FabColors.rose, 0.7],
      [0.43, -4.0, FabColors.gold, 0.8],
      [0.49, -2.0, FabColors.pink, -0.6],
      [0.55, -4.0, FabColors.rose, 0.9],
      [0.13, 0.0, FabColors.teal, -0.8],
      [0.87, 1.0, FabColors.gold, 0.6],
    ];

    for (final f in flowers) {
      final x = size.width * (f[0] as double);
      final yOff = f[1] as double;
      final col = f[2] as Color;
      final mult = f[3] as double;
      _drawFlower(canvas, x, gY + yOff, col, sway * mult * 4);
    }
  }

  void _drawFlower(Canvas canvas, double x, double gY, Color col, double sway) {
    final stemTop = Offset(x + sway, gY - 85);

    // Stem
    canvas.drawLine(
      Offset(x, gY), stemTop,
      Paint()
        ..color = const Color(0xFF3d6b2a)
        ..strokeWidth = 2.8 ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke,
    );

    // Leaf
    canvas.drawPath(
      Path()
        ..moveTo(x + sway*0.5, gY - 40)
        ..quadraticBezierTo(x + 14 + sway, gY - 52, x + 8 + sway*0.7, gY - 58)
        ..quadraticBezierTo(x + sway*0.5, gY - 50, x + sway*0.5, gY - 40),
      Paint()..color = const Color(0xFF3d6b2a).withValues(alpha: 0.7),
    );

    // Petals
    for (int i = 0; i < 6; i++) {
      final a = i * pi / 3;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(stemTop.dx + cos(a) * 11, stemTop.dy + sin(a) * 11),
          width: 10, height: 14,
        ),
        Paint()..color = col.withValues(alpha: 0.88),
      );
    }
    // Centre
    canvas.drawCircle(stemTop, 7,
      Paint()..color = FabColors.gold);
    canvas.drawCircle(stemTop, 3.5,
      Paint()..color = const Color(0xFFD4A800));
    // Pollen dots
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * pi / 5;
      canvas.drawCircle(
        Offset(stemTop.dx + cos(a)*4.5, stemTop.dy + sin(a)*4.5),
        1.2, Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }
  }

  // ── MUSHROOMS ─────────────────────────────────────────
  void _drawMushrooms(Canvas canvas, Size size) {
    _drawMushroom(canvas, size, size.width*0.05, size.height*0.72, 0.9);
    _drawMushroom(canvas, size, size.width*0.87, size.height*0.73, 0.75);
    _drawMushroom(canvas, size, size.width*0.94, size.height*0.70, 0.55);
    _drawMushroom(canvas, size, size.width*0.41, size.height*0.765, 0.42);
    _drawMushroom(canvas, size, size.width*0.58, size.height*0.755, 0.36);
    _drawMushroom(canvas, size, size.width*0.10, size.height*0.74, 0.48);
  }

  void _drawMushroom(Canvas canvas, Size size, double x, double y, double scale) {
    // Subtle glow pulse
    final pulse = 0.85 + sin(animationValue * 2 * pi + x) * 0.15;
    final stemH = 45.0 * scale;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 22*scale, height: stemH),
        const Radius.circular(6)),
      Paint()..color = const Color(0xFF4a1070),
    );

    // Cap with gradient
    canvas.drawPath(
      Path()
        ..moveTo(x - 38*scale, y - stemH*0.38)
        ..quadraticBezierTo(x, y - 75*scale*pulse, x + 38*scale, y - stemH*0.38)
        ..close(),
      Paint()..shader = RadialGradient(
        center: const Alignment(0, -0.6), radius: 0.8,
        colors: [const Color(0xFF9c4acd), const Color(0xFF6a1a9a)],
      ).createShader(Rect.fromCenter(
        center: Offset(x, y - stemH*0.6), width: 76*scale, height: 60*scale)),
    );

    // Dots
    for (final d in [
      [-0.22, -1.1], [0.12, -1.25], [0.38, -1.05], [-0.05, -0.9],
    ]) {
      canvas.drawCircle(
        Offset(x + d[0]*stemH, y + d[1]*stemH*0.5),
        (2.5 + d[0].abs())*scale,
        Paint()..color = FabColors.rose.withValues(alpha: 0.65 * pulse),
      );
    }

    // Glow under cap
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y - stemH*0.35),
        width: 42*scale, height: 8*scale,
      ),
      Paint()..color = const Color(0xFF9c4acd).withValues(alpha: 0.12 * pulse),
    );
  }

  // ── FLOATING STARS ────────────────────────────────────
  void _drawFloatingStars(Canvas canvas, Size size) {
    final colours = [FabColors.gold, FabColors.pink, FabColors.gold, FabColors.rose, FabColors.teal];
    final positions = [0.14, 0.38, 0.62, 0.78, 0.52];

    for (int i = 0; i < positions.length; i++) {
      final x = size.width * positions[i];
      final drift = sin(animationValue * 2 * pi + i * 1.6) * 9;
      final y = size.height * 0.52 - (animationValue * 90 + i * 22) % 130 + drift;
      final opacity = (1.0 - ((animationValue + i * 0.2) % 1.0)).clamp(0.0, 1.0);

      _drawStar(canvas,
        Paint()..color = colours[i].withValues(alpha: opacity * 0.85),
        Offset(x, y), 7 + (i % 3) * 2.0,
      );
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset centre, double size) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final oA = (i * 4 * pi / 5) - pi / 2;
      final iA = oA + pi / 5;
      final o = Offset(centre.dx + size * cos(oA), centre.dy + size * sin(oA));
      final inn = Offset(centre.dx + size*0.4 * cos(iA), centre.dy + size*0.4 * sin(iA));
      if (i == 0) path.moveTo(o.dx, o.dy);
      else path.lineTo(o.dx, o.dy);
      path.lineTo(inn.dx, inn.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // ── FOREGROUND ────────────────────────────────────────
  void _drawForeground(Canvas canvas, Size size) {
    final gY = size.height * 0.78;

    // Dark gradient bottom
    canvas.drawRect(
      Rect.fromLTWH(0, gY + 4, size.width, size.height - gY - 4),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1a0840).withValues(alpha: 0.0),
          const Color(0xFF1a0840).withValues(alpha: 0.6),
          const Color(0xFF0a0320).withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, gY + 4, size.width, size.height - gY - 4)),
    );

    // Foreground grass tufts — bigger, darker, closer
    final tOff = animationValue * 32;
    final tP = Paint()
      ..color = const Color(0xFF2a4d1a).withValues(alpha: 0.75)
      ..strokeWidth = 3.2 ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    for (double x = -32 + tOff % 32; x < size.width + 32; x += 32) {
      final sw = sin(animationValue * 2 * pi + x * 0.06) * 5.5;
      canvas.drawLine(Offset(x, gY + 20), Offset(x + 7 + sw, gY + 4), tP);
      canvas.drawLine(Offset(x + 13, gY + 20), Offset(x + 20 + sw*0.7, gY + 5), tP);
      canvas.drawLine(Offset(x + 6, gY + 20), Offset(x + 10 + sw*0.5, gY + 6), tP);
    }

    // Bottom vignette
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 32, size.width, 32),
      Paint()..color = const Color(0xFF060318).withValues(alpha: 0.5),
    );
  }

  // ── FIREFLIES ─────────────────────────────────────────
  void _drawFireflies(Canvas canvas, Size size) {
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

      // Outer glow
      canvas.drawCircle(
        Offset(x, y), 5 * glow,
        Paint()..color = col.withValues(alpha: glow * 0.15),
      );
      // Core
      canvas.drawCircle(
        Offset(x, y), 2 * glow,
        Paint()..color = col.withValues(alpha: glow * 0.85),
      );
      // Bright centre
      canvas.drawCircle(
        Offset(x, y), 0.8 * glow,
        Paint()..color = Colors.white.withValues(alpha: glow * 0.9),
      );

      // Trail
      canvas.drawLine(
        Offset(x, y),
        Offset(x - sin(t * 0.7 + i) * 6, y - cos(t * 0.5 + i * 0.6) * 4),
        Paint()
          ..color = col.withValues(alpha: glow * 0.2)
          ..strokeWidth = 1.0 ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(FabWorldPainter old) =>
    old.animationValue != animationValue;
}
