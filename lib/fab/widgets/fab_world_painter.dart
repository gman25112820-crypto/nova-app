import 'package:flutter/material.dart';
import 'dart:math';
import "../fab_theme.dart";

class FabWorldPainter extends CustomPainter {
  final double animationValue;

  FabWorldPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawStars(canvas, size);
    _drawDistantTrees(canvas, size);
    _drawClouds(canvas, size);
    _drawMushrooms(canvas, size);
    _drawFlowers(canvas, size);
    _drawGround(canvas, size);
    _drawHomes(canvas, size);
    _drawGardenCentre(canvas, size);
    _drawFloatingStars(canvas, size);
    _drawForeground(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [FabColors.bg, FabColors.mid, const Color(0xFF3d1580)],
    ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint();
    final random = Random(42);
    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.55;
      final twinkle = sin((animationValue * 2 * pi) + (i * 0.7));
      final opacity = 0.3 + (twinkle * 0.3).abs();
      final radius = random.nextDouble() * 1.8 + 0.5;
      paint.color = FabColors.text.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawDistantTrees(Canvas canvas, Size size) {
    final treePaint = Paint()..color = const Color(0xFF2a0e60).withValues(alpha: 0.6);
    final trunkPaint = Paint()..color = const Color(0xFF1e0a45).withValues(alpha: 0.5);
    final groundY = size.height * 0.78;
    final positions = [0.05, 0.12, 0.40, 0.48, 0.58, 0.68, 0.90, 0.97];
    final heights = [60.0, 45.0, 55.0, 40.0, 65.0, 42.0, 52.0, 38.0];

    for (int i = 0; i < positions.length; i++) {
      final x = size.width * positions[i];
      final h = heights[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 4, groundY - h * 0.35, 8, h * 0.35),
          const Radius.circular(3),
        ),
        trunkPaint,
      );
      final path = Path()
        ..moveTo(x - h * 0.38, groundY - h * 0.3)
        ..lineTo(x, groundY - h)
        ..lineTo(x + h * 0.38, groundY - h * 0.3)
        ..close();
      canvas.drawPath(path, treePaint);
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final farPaint = Paint()..color = const Color(0xFF4a1a8a).withValues(alpha: 0.35);
    for (int i = 0; i < 3; i++) {
      final x = ((animationValue * 0.2 + i * 0.33) % 1.0) * (size.width + 200) - 100;
      _drawCloud(canvas, farPaint, Offset(x, size.height * (0.08 + i * 0.04)), 35.0 + i * 8);
    }
    final midPaint = Paint()..color = const Color(0xFF4a1a8a).withValues(alpha: 0.55);
    for (int i = 0; i < 2; i++) {
      final x = ((animationValue * 0.4 + i * 0.5) % 1.0) * (size.width + 200) - 100;
      _drawCloud(canvas, midPaint, Offset(x, size.height * (0.14 + i * 0.05)), 55.0 + i * 15);
    }
    final nearPaint = Paint()..color = const Color(0xFF4a1a8a).withValues(alpha: 0.7);
    final x = ((animationValue * 0.7) % 1.0) * (size.width + 200) - 100;
    _drawCloud(canvas, nearPaint, Offset(x, size.height * 0.18), 80.0);
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset pos, double scale) {
    canvas.drawCircle(pos, scale * 0.4, paint);
    canvas.drawCircle(pos.translate(scale * 0.4, scale * 0.1), scale * 0.35, paint);
    canvas.drawCircle(pos.translate(-scale * 0.35, scale * 0.1), scale * 0.3, paint);
    canvas.drawCircle(pos.translate(scale * 0.15, scale * 0.25), scale * 0.38, paint);
  }

  void _drawGround(Canvas canvas, Size size) {
    final groundY = size.height * 0.78;
    final paint = Paint()..color = FabColors.panel;
    final path = Path()
      ..moveTo(0, groundY)
      ..quadraticBezierTo(size.width * 0.25, groundY - 20, size.width * 0.5, groundY)
      ..quadraticBezierTo(size.width * 0.75, groundY + 20, size.width, groundY)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, groundY + 10),
        width: size.width * 0.8, height: 30,
      ),
      Paint()..color = FabColors.pink.withValues(alpha: 0.15),
    );

    final grassPaint = Paint()
      ..color = const Color(0xFF3d6b2a).withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final grassOffset = animationValue * 20;
    for (double x = -20 + grassOffset % 20; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, groundY + 5), Offset(x + 8, groundY - 5), grassPaint);
    }

    _drawStonePath(canvas, size, groundY);
  }

  void _drawStonePath(Canvas canvas, Size size, double groundY) {
    final stonePaint = Paint()..color = const Color(0xFF4a2080).withValues(alpha: 0.6);
    const stoneCount = 8;
    final pathStartX = size.width * 0.32;
    final pathEndX = size.width * 0.62;
    for (int i = 0; i < stoneCount; i++) {
      final t = i / (stoneCount - 1);
      final x = pathStartX + (pathEndX - pathStartX) * t;
      final wobble = sin(i * 1.3) * 6;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, groundY + 8 + wobble), width: 22, height: 10),
        stonePaint,
      );
    }
  }

  void _drawMushrooms(Canvas canvas, Size size) {
    _drawMushroom(canvas, size, size.width * 0.06, size.height * 0.72, 0.9);
    _drawMushroom(canvas, size, size.width * 0.88, size.height * 0.73, 0.75);
    _drawMushroom(canvas, size, size.width * 0.95, size.height * 0.70, 0.55);
    _drawMushroom(canvas, size, size.width * 0.42, size.height * 0.76, 0.45);
    _drawMushroom(canvas, size, size.width * 0.57, size.height * 0.75, 0.38);
  }

  void _drawMushroom(Canvas canvas, Size size, double x, double y, double scale) {
    final stemPaint = Paint()..color = const Color(0xFF4a1070);
    final capPaint = Paint()..color = const Color(0xFF7c3aad);
    final dotPaint = Paint()..color = FabColors.rose.withValues(alpha: 0.6);
    final stemH = 45.0 * scale;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 22.0 * scale, height: stemH),
        const Radius.circular(6),
      ),
      stemPaint,
    );
    final capPath = Path()
      ..moveTo(x - 35 * scale, y - stemH * 0.4)
      ..quadraticBezierTo(x, y - 70 * scale, x + 35 * scale, y - stemH * 0.4)
      ..close();
    canvas.drawPath(capPath, capPaint);
    canvas.drawCircle(Offset(x - 8 * scale, y - 45 * scale), 3 * scale, dotPaint);
    canvas.drawCircle(Offset(x + 5 * scale, y - 50 * scale), 2.5 * scale, dotPaint);
    canvas.drawCircle(Offset(x + 15 * scale, y - 42 * scale), 2 * scale, dotPaint);
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final sway = sin(animationValue * 2 * pi) * 4;
    final groundY = size.height * 0.78;
    _drawFlower(canvas, size.width * 0.20, groundY, FabColors.pink, sway);
    _drawFlower(canvas, size.width * 0.75, groundY, const Color(0xFF7c4aad), -sway);
    _drawFlower(canvas, size.width * 0.85, groundY + 2, FabColors.rose, sway * 0.7);
    _drawFlower(canvas, size.width * 0.44, groundY - 4, FabColors.gold, sway * 0.8);
    _drawFlower(canvas, size.width * 0.50, groundY - 2, FabColors.pink, -sway * 0.6);
    _drawFlower(canvas, size.width * 0.56, groundY - 4, FabColors.rose, sway * 0.9);
  }

  void _drawFlower(Canvas canvas, double x, double groundY, Color color, double sway) {
    final stemPaint = Paint()
      ..color = const Color(0xFF3d6b2a)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stemTop = Offset(x + sway, groundY - 80);
    canvas.drawLine(Offset(x, groundY), stemTop, stemPaint);
    canvas.drawCircle(stemTop, 18, Paint()..color = color.withValues(alpha: 0.85));
    canvas.drawCircle(stemTop, 9, Paint()..color = FabColors.gold);
  }

  void _drawHomes(Canvas canvas, Size size) {
    _drawChickenHome(canvas, size);
    _drawGiraffeHome(canvas, size);
  }

  void _drawChickenHome(Canvas canvas, Size size) {
    final groundY = size.height * 0.78;
    final cx = size.width * 0.22;
    final wallPaint = Paint()..color = const Color(0xFF3d1580);
    final roofPaint = Paint()..color = FabColors.pink;
    final doorPaint = Paint()..color = FabColors.gold;
    final windowPaint = Paint()..color = FabColors.text.withValues(alpha: 0.3);
    final windowGlowPaint = Paint()
      ..color = FabColors.gold.withValues(
          alpha: 0.12 + sin(animationValue * 2 * pi) * 0.06);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 55, groundY - 90, 110, 90), const Radius.circular(8),
      ),
      wallPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - 65, groundY - 90)
        ..lineTo(cx, groundY - 145)
        ..lineTo(cx + 65, groundY - 90)
        ..close(),
      roofPaint,
    );
    canvas.drawPath(
      Path()
        ..addRRect(RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - 16, groundY - 50, 32, 50),
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
        )),
      doorPaint,
    );
    for (final wx in [cx - 48.0, cx + 24.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx, groundY - 75, 24, 20), const Radius.circular(4)),
        windowGlowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx, groundY - 75, 24, 20), const Radius.circular(4)),
        windowPaint,
      );
    }
  }

  void _drawGiraffeHome(Canvas canvas, Size size) {
    final groundY = size.height * 0.78;
    final cx = size.width * 0.78;
    final wallPaint = Paint()..color = const Color(0xFF2d1065);
    final roofPaint = Paint()..color = const Color(0xFF7c4aad);
    final doorPaint = Paint()..color = FabColors.duckOrange;
    final windowPaint = Paint()..color = FabColors.text.withValues(alpha: 0.3);
    final windowGlowPaint = Paint()
      ..color = FabColors.duckOrange.withValues(
          alpha: 0.12 + sin(animationValue * 2 * pi + 1.2) * 0.06);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 55, groundY - 160, 110, 160), const Radius.circular(6),
      ),
      wallPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - 65, groundY - 160)
        ..lineTo(cx, groundY - 220)
        ..lineTo(cx + 65, groundY - 160)
        ..close(),
      roofPaint,
    );
    canvas.drawPath(
      Path()
        ..addRRect(RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - 18, groundY - 90, 36, 90),
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
        )),
      doorPaint,
    );
    for (final wx in [cx - 48.0, cx + 24.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx, groundY - 140, 24, 22), const Radius.circular(4)),
        windowGlowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx, groundY - 140, 24, 22), const Radius.circular(4)),
        windowPaint,
      );
    }
  }

  void _drawGardenCentre(Canvas canvas, Size size) {
    final groundY = size.height * 0.78;
    final cx = size.width * 0.50;

    // Gate
    final gatePaint = Paint()
      ..color = FabColors.gold.withValues(alpha: 0.85)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final gateTopY = groundY - 52;
    canvas.drawLine(Offset(cx - 14, groundY), Offset(cx - 14, gateTopY), gatePaint);
    canvas.drawLine(Offset(cx + 14, groundY), Offset(cx + 14, gateTopY), gatePaint);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, gateTopY), width: 28, height: 22),
      pi, pi, false, gatePaint,
    );
    canvas.drawLine(Offset(cx - 14, gateTopY + 14), Offset(cx + 14, gateTopY + 14), gatePaint);

    // Planters
    _drawPlanter(canvas, Offset(cx - 38, groundY - 18), 0);
    _drawPlanter(canvas, Offset(cx + 28, groundY - 18), 1);

    // Sign
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, gateTopY - 14), width: 52, height: 16),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF4a1a8a).withValues(alpha: 0.8),
    );
    final dotP = Paint()..color = FabColors.gold.withValues(alpha: 0.9);
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(Offset(cx - 16 + i * 8.0, gateTopY - 14), 2, dotP);
    }
  }

  void _drawPlanter(Canvas canvas, Offset pos, int variant) {
    final sway = sin(animationValue * 2 * pi + variant * 1.5) * 3;
    final flowerColour = variant == 0 ? FabColors.pink : FabColors.rose;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx, pos.dy, 20, 18), const Radius.circular(3)),
      Paint()..color = const Color(0xFF5a2090).withValues(alpha: 0.75),
    );
    canvas.drawOval(
      Rect.fromLTWH(pos.dx + 1, pos.dy, 18, 6),
      Paint()..color = const Color(0xFF2a0e45).withValues(alpha: 0.6),
    );
    final stemBase = Offset(pos.dx + 10, pos.dy + 2);
    final stemTip = Offset(pos.dx + 10 + sway, pos.dy - 20);
    canvas.drawLine(stemBase, stemTip,
        Paint()
          ..color = const Color(0xFF3d6b2a)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(stemTip, 7, Paint()..color = flowerColour.withValues(alpha: 0.85));
    canvas.drawCircle(stemTip, 3.5, Paint()..color = FabColors.gold);
  }

  void _drawFloatingStars(Canvas canvas, Size size) {
    final paint = Paint();
    final positions = [0.15, 0.45, 0.65, 0.82];
    final colours = [FabColors.gold, FabColors.pink, FabColors.gold, FabColors.rose];
    for (int i = 0; i < positions.length; i++) {
      final x = size.width * positions[i];
      final drift = sin((animationValue * 2 * pi) + i * 1.5) * 8;
      final y = size.height * 0.55 - (animationValue * 80 + i * 25) % 120 + drift;
      final opacity = 1.0 - ((animationValue + i * 0.25) % 1.0);
      paint.color = colours[i].withValues(alpha: opacity * 0.8);
      _drawStar(canvas, paint, Offset(x, y), 8);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset centre, double size) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 4 * pi / 5) - pi / 2;
      final innerAngle = outerAngle + 2 * pi / 10;
      final outer = Offset(centre.dx + size * cos(outerAngle), centre.dy + size * sin(outerAngle));
      final inner = Offset(centre.dx + size * 0.4 * cos(innerAngle), centre.dy + size * 0.4 * sin(innerAngle));
      if (i == 0) path.moveTo(outer.dx, outer.dy);
      else path.lineTo(outer.dx, outer.dy);
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawForeground(Canvas canvas, Size size) {
    final groundY = size.height * 0.78;

    // Dark gradient band at bottom
    canvas.drawRect(
      Rect.fromLTWH(0, groundY + 5, size.width, size.height - groundY - 5),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1a0840).withValues(alpha: 0.0),
            const Color(0xFF1a0840).withValues(alpha: 0.55),
            const Color(0xFF0f0520).withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(
          Rect.fromLTWH(0, groundY + 5, size.width, size.height - groundY - 5),
        ),
    );

    // Foreground grass tufts
    final tuftPaint = Paint()
      ..color = const Color(0xFF2a4d1a).withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tuftOffset = animationValue * 30;
    for (double x = -30 + tuftOffset % 30; x < size.width + 30; x += 30) {
      final sway = sin(animationValue * 2 * pi + x * 0.05) * 5;
      canvas.drawLine(Offset(x, groundY + 18), Offset(x + 6 + sway, groundY + 4), tuftPaint);
      canvas.drawLine(Offset(x + 12, groundY + 18), Offset(x + 18 + sway * 0.7, groundY + 5), tuftPaint);
    }

    // Bottom edge shadow
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 28, size.width, 28),
      Paint()..color = const Color(0xFF0a0320).withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(FabWorldPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

