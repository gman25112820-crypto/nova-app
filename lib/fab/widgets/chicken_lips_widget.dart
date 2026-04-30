import 'package:flutter/material.dart';
import '../fab_theme.dart';

enum ChickenLipsMood { happy, sad, neutral, excited, sleepy, crowned }
enum ChickenLipsSize { small, medium, large }

class ChickenLipsWidget extends StatelessWidget {
  final ChickenLipsMood mood;
  final ChickenLipsSize size;
  final bool showSparkles;

  const ChickenLipsWidget({
    super.key,
    this.mood = ChickenLipsMood.happy,
    this.size = ChickenLipsSize.medium,
    this.showSparkles = false,
  });

  double get _dimension {
    switch (size) {
      case ChickenLipsSize.small: return 40;
      case ChickenLipsSize.medium: return 80;
      case ChickenLipsSize.large: return 140;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _dimension,
      height: _dimension * 1.25,
      child: CustomPaint(
        painter: _ChickenLipsPainter(mood: mood, showSparkles: showSparkles),
      ),
    );
  }
}

class _ChickenLipsPainter extends CustomPainter {
  final ChickenLipsMood mood;
  final bool showSparkles;
  _ChickenLipsPainter({required this.mood, required this.showSparkles});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // ── Paints ──────────────────────────────────────────────────────────────
    final bodyPaint = Paint()..color = FabColors.yellow;
    final bodyShade = Paint()..color = const Color(0xFFF0A020);
    final bodyStroke = Paint()..color = FabColors.duckOrange..style = PaintingStyle.stroke..strokeWidth = w * 0.025;
    final darkPaint = Paint()..color = const Color(0xFF1F0A2E);
    final whitePaint = Paint()..color = Colors.white;
    final blushPaint = Paint()..color = FabColors.blush.withOpacity(0.65);
    final crestPaint = Paint()..color = FabColors.pink;
    final crestStroke = Paint()..color = FabColors.deepRose..style = PaintingStyle.stroke..strokeWidth = w * 0.02;
    final lipPaint = Paint()..color = FabColors.deepRose;
    final lipHighlight = Paint()..color = FabColors.pink..style = PaintingStyle.stroke..strokeWidth = w * 0.025..strokeCap = StrokeCap.round;
    final wattlePaint = Paint()..color = FabColors.blush;
    final outfitPaint = Paint()..color = const Color(0xFF7B3FB5);
    final outfitLight = Paint()..color = const Color(0xFF9B5FD5);
    final collarPaint = Paint()..color = Colors.white.withOpacity(0.9);
    final badgePaint = Paint()..color = Colors.white.withOpacity(0.9);
    final stethPaint = Paint()..color = const Color(0xFF888888)..style = PaintingStyle.stroke..strokeWidth = w * 0.03..strokeCap = StrokeCap.round;

    // ── Outfit / body base ───────────────────────────────────────────────────
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.80), width: w * 0.85, height: h * 0.38), outfitPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.78), width: w * 0.80, height: h * 0.34), outfitLight);

    // ── White collar ─────────────────────────────────────────────────────────
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.62), width: w * 0.55, height: h * 0.09), collarPaint);
    final collarPath = Path()
      ..moveTo(cx - w * 0.27, h * 0.62)
      ..quadraticBezierTo(cx, h * 0.70, cx + w * 0.27, h * 0.62);
    canvas.drawPath(collarPath, collarPaint);

    // ── Name badge ───────────────────────────────────────────────────────────
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.72), width: w * 0.38, height: h * 0.09),
      const Radius.circular(3)), badgePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.70), width: w * 0.30, height: h * 0.015),
      const Radius.circular(2)), outfitPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - w * 0.02, h * 0.725), width: w * 0.26, height: h * 0.012),
      const Radius.circular(2)), Paint()..color = Colors.grey.withOpacity(0.4));
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.742), width: w * 0.28, height: h * 0.012),
      const Radius.circular(2)), Paint()..color = Colors.grey.withOpacity(0.4));

    // ── Stethoscope ──────────────────────────────────────────────────────────
    final stethPath = Path();
    stethPath.moveTo(cx - w * 0.22, h * 0.63);
    stethPath.quadraticBezierTo(cx - w * 0.32, h * 0.72, cx - w * 0.28, h * 0.82);
    stethPath.quadraticBezierTo(cx - w * 0.24, h * 0.88, cx - w * 0.16, h * 0.88);
    canvas.drawPath(stethPath, stethPaint);
    canvas.drawCircle(Offset(cx - w * 0.16, h * 0.88), w * 0.04, Paint()..color = const Color(0xFF666666));
    canvas.drawCircle(Offset(cx - w * 0.16, h * 0.88), w * 0.025, Paint()..color = const Color(0xFF999999));
    // ── Wings ────────────────────────────────────────────────────────────────
    _drawWing(canvas, Offset(w * 0.12, h * 0.74), w * 0.22, h * 0.30, -0.28, bodyPaint, bodyStroke);
    _drawWing(canvas, Offset(w * 0.88, h * 0.74), w * 0.22, h * 0.30, 0.28, bodyPaint, bodyStroke);

    // ── Body (yellow over outfit) ─────────────────────────────────────────────
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.64), width: w * 0.82, height: h * 0.42), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.64), width: w * 0.82, height: h * 0.42), bodyStroke);
    // Body shading
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.15, h * 0.68), width: w * 0.35, height: h * 0.20), bodyShade..color = FabColors.duckOrange.withOpacity(0.25));

    // ── Head ─────────────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(cx, h * 0.34), w * 0.46, bodyPaint);
    canvas.drawCircle(Offset(cx, h * 0.34), w * 0.46, bodyStroke);
    // Head shading
    canvas.drawCircle(Offset(cx + w * 0.12, h * 0.38), w * 0.28, Paint()..color = FabColors.duckOrange.withOpacity(0.2));

    // ── Crest ─────────────────────────────────────────────────────────────────
    _drawCrest(canvas, cx, h * 0.10, w, crestPaint, crestStroke);

    // ── Crown (crowned mood) ──────────────────────────────────────────────────
    if (mood == ChickenLipsMood.crowned || mood == ChickenLipsMood.excited) {
      _drawCrown(canvas, cx, h * 0.08, w);
    }

    // ── Blush ─────────────────────────────────────────────────────────────────
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.26, h * 0.39), width: w * 0.24, height: h * 0.10), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.26, h * 0.39), width: w * 0.24, height: h * 0.10), blushPaint);

    // ── Eyes ──────────────────────────────────────────────────────────────────
    if (mood == ChickenLipsMood.sleepy) {
      _drawSleepyEyes(canvas, cx, h * 0.32, w, darkPaint);
    } else {
      _drawEyes(canvas, cx, h * 0.32, w, darkPaint, whitePaint);
      _drawLashes(canvas, cx, h * 0.32, w, darkPaint);
    }

    // ── Wattle ────────────────────────────────────────────────────────────────
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.50), width: w * 0.15, height: h * 0.06), wattlePaint);

    // ── Beak ──────────────────────────────────────────────────────────────────
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.44), width: w * 0.22, height: h * 0.07), Paint()..color = FabColors.duckOrange);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.44), width: w * 0.18, height: h * 0.05), Paint()..color = const Color(0xFFFFA040));

    // ── Lips ──────────────────────────────────────────────────────────────────
    _drawLips(canvas, cx, h * 0.47, w, h * 0.06, lipPaint, lipHighlight);

    // ── Sparkles ──────────────────────────────────────────────────────────────
    if (showSparkles) {
      _sparkle(canvas, w * 0.06, h * 0.22, w * 0.04);
      _sparkle(canvas, w * 0.92, h * 0.18, w * 0.03);
      _sparkle(canvas, w * 0.88, h * 0.42, w * 0.025);
      _sparkle(canvas, w * 0.08, h * 0.45, w * 0.02);
    }
  }
  void _sparkle(Canvas canvas, double x, double y, double r) {
    final sp = Paint()..color = FabColors.gold;
    canvas.drawLine(Offset(x, y - r), Offset(x, y + r), sp..strokeWidth = r * 0.4..style = PaintingStyle.stroke);
    canvas.drawLine(Offset(x - r, y), Offset(x + r, y), sp);
    canvas.drawLine(Offset(x - r * 0.7, y - r * 0.7), Offset(x + r * 0.7, y + r * 0.7), sp..strokeWidth = r * 0.3);
    canvas.drawLine(Offset(x + r * 0.7, y - r * 0.7), Offset(x - r * 0.7, y + r * 0.7), sp);
  }

  void _drawWing(Canvas canvas, Offset center, double width, double height, double angle, Paint fill, Paint stroke) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: width, height: height), fill);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: width, height: height), stroke);
    canvas.restore();
  }

  void _drawCrest(Canvas canvas, double cx, double cy, double w, Paint fill, Paint stroke) {
    canvas.drawCircle(Offset(cx - w * 0.17, cy), w * 0.12, fill);
    canvas.drawCircle(Offset(cx - w * 0.17, cy), w * 0.12, stroke);
    canvas.drawCircle(Offset(cx, cy - w * 0.04), w * 0.15, fill);
    canvas.drawCircle(Offset(cx, cy - w * 0.04), w * 0.15, stroke);
    canvas.drawCircle(Offset(cx + w * 0.17, cy), w * 0.12, fill);
    canvas.drawCircle(Offset(cx + w * 0.17, cy), w * 0.12, stroke);
  }

  void _drawEyes(Canvas canvas, double cx, double cy, double w, Paint dark, Paint white) {
    canvas.drawCircle(Offset(cx - w * 0.18, cy), w * 0.13, white);
    canvas.drawCircle(Offset(cx + w * 0.18, cy), w * 0.13, white);
    canvas.drawCircle(Offset(cx - w * 0.16, cy - w * 0.02), w * 0.08, dark);
    canvas.drawCircle(Offset(cx + w * 0.20, cy - w * 0.02), w * 0.08, dark);
    canvas.drawCircle(Offset(cx - w * 0.13, cy - w * 0.05), w * 0.035, white);
    canvas.drawCircle(Offset(cx + w * 0.23, cy - w * 0.05), w * 0.035, white);
  }

  void _drawSleepyEyes(Canvas canvas, double cx, double cy, double w, Paint dark) {
    final p = Paint()..color = const Color(0xFF1F0A2E)..style = PaintingStyle.stroke..strokeWidth = w * 0.04..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx - w * 0.18, cy), width: w * 0.2, height: w * 0.14), 0, 3.14159, false, p);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx + w * 0.18, cy), width: w * 0.2, height: w * 0.14), 0, 3.14159, false, p);
  }

  void _drawLashes(Canvas canvas, double cx, double cy, double w, Paint dark) {
    final lash = Paint()..color = const Color(0xFF1F0A2E)..strokeWidth = w * 0.03..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - w * 0.26, cy - w * 0.07), Offset(cx - w * 0.32, cy - w * 0.15), lash);
    canvas.drawLine(Offset(cx - w * 0.20, cy - w * 0.09), Offset(cx - w * 0.22, cy - w * 0.17), lash);
    canvas.drawLine(Offset(cx - w * 0.14, cy - w * 0.09), Offset(cx - w * 0.13, cy - w * 0.17), lash);
    canvas.drawLine(Offset(cx + w * 0.14, cy - w * 0.09), Offset(cx + w * 0.13, cy - w * 0.17), lash);
    canvas.drawLine(Offset(cx + w * 0.20, cy - w * 0.09), Offset(cx + w * 0.22, cy - w * 0.17), lash);
    canvas.drawLine(Offset(cx + w * 0.26, cy - w * 0.07), Offset(cx + w * 0.32, cy - w * 0.15), lash);
  }

  void _drawLips(Canvas canvas, double cx, double ly, double w, double h, Paint lip, Paint highlight) {
    final lw = w * 0.65;
    final path = Path();
    path.moveTo(cx - lw / 2, ly);
    path.quadraticBezierTo(cx - lw * 0.2, ly - h * 0.04, cx, ly - h * 0.015);
    path.quadraticBezierTo(cx + lw * 0.2, ly - h * 0.04, cx + lw / 2, ly);
    path.quadraticBezierTo(cx + lw * 0.35, ly + h * 0.06, cx, ly + h * 0.075);
    path.quadraticBezierTo(cx - lw * 0.35, ly + h * 0.06, cx - lw / 2, ly);
    path.close();
    canvas.drawPath(path, lip);
    final topLine = Path();
    topLine.moveTo(cx - lw / 2, ly);
    topLine.quadraticBezierTo(cx - lw * 0.2, ly - h * 0.04, cx, ly - h * 0.015);
    topLine.quadraticBezierTo(cx + lw * 0.2, ly - h * 0.04, cx + lw / 2, ly);
    canvas.drawPath(topLine, highlight);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.12, ly + h * 0.025), width: w * 0.18, height: h * 0.025),
      Paint()..color = Colors.white.withOpacity(0.25));
  }

  void _drawCrown(Canvas canvas, double cx, double cy, double w) {
    final cp = Paint()..color = FabColors.gold;
    final cs = Paint()..color = const Color(0xFFFFC800)..style = PaintingStyle.stroke..strokeWidth = w * 0.015;
    final crown = Path();
    crown.moveTo(cx - w * 0.28, cy + w * 0.1);
    crown.lineTo(cx - w * 0.22, cy - w * 0.06);
    crown.lineTo(cx - w * 0.14, cy + w * 0.02);
    crown.lineTo(cx, cy - w * 0.1);
    crown.lineTo(cx + w * 0.14, cy + w * 0.02);
    crown.lineTo(cx + w * 0.22, cy - w * 0.06);
    crown.lineTo(cx + w * 0.28, cy + w * 0.1);
    crown.close();
    canvas.drawPath(crown, cp);
    canvas.drawPath(crown, cs);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.28, cy + w * 0.08, w * 0.56, w * 0.08), const Radius.circular(3)), cp);
    canvas.drawCircle(Offset(cx - w * 0.14, cy), w * 0.045, Paint()..color = FabColors.rose);
    canvas.drawCircle(Offset(cx, cy - w * 0.06), w * 0.055, Paint()..color = const Color(0xFF4488FF));
    canvas.drawCircle(Offset(cx + w * 0.14, cy), w * 0.045, Paint()..color = FabColors.rose);
  }

  @override
  bool shouldRepaint(_ChickenLipsPainter old) => old.mood != mood || old.showSparkles != showSparkles;
}

class ChickenLipsAvatar extends StatelessWidget {
  final double radius;
  final ChickenLipsMood mood;
  const ChickenLipsAvatar({super.key, this.radius = 18, this.mood = ChickenLipsMood.happy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1F0A2E),
        border: Border.all(color: FabColors.pink, width: 1.5),
      ),
      child: ClipOval(
        child: ChickenLipsWidget(mood: mood, size: ChickenLipsSize.small),
      ),
    );
  }
}