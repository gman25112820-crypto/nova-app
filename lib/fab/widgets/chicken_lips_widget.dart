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
      height: _dimension * 1.15,
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

    final bodyPaint = Paint()..color = FabColors.yellow;
    final bodyStroke = Paint()..color = FabColors.duckOrange..style = PaintingStyle.stroke..strokeWidth = w * 0.025;
    final darkPaint = Paint()..color = const Color(0xFF1A0A2E);
    final whitePaint = Paint()..color = Colors.white;
    final blushPaint = Paint()..color = FabColors.blush.withOpacity(0.65);
    final crestPaint = Paint()..color = FabColors.pink;
    final crestStroke = Paint()..color = FabColors.deepRose..style = PaintingStyle.stroke..strokeWidth = w * 0.02;
    final lipPaint = Paint()..color = FabColors.deepRose;
    final lipHighlight = Paint()..color = FabColors.pink..style = PaintingStyle.stroke..strokeWidth = w * 0.025..strokeCap = StrokeCap.round;
    final wattlePaint = Paint()..color = FabColors.blush;

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.78), width: w * 0.85, height: h * 0.44), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.78), width: w * 0.85, height: h * 0.44), bodyStroke);

    // Wings
    _drawWing(canvas, Offset(w * 0.12, h * 0.76), w * 0.22, h * 0.32, -0.28, bodyPaint, bodyStroke);
    _drawWing(canvas, Offset(w * 0.88, h * 0.76), w * 0.22, h * 0.32, 0.28, bodyPaint, bodyStroke);

    // Head
    canvas.drawCircle(Offset(cx, h * 0.38), w * 0.46, bodyPaint);
    canvas.drawCircle(Offset(cx, h * 0.38), w * 0.46, bodyStroke);

    // Crest
    _drawCrest(canvas, cx, h * 0.14, w, crestPaint, crestStroke);

    // Blush
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.26, h * 0.42), width: w * 0.24, height: h * 0.13), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.26, h * 0.42), width: w * 0.24, height: h * 0.13), blushPaint);

    // Eyes
    if (mood == ChickenLipsMood.sleepy) {
      _drawSleepyEyes(canvas, cx, h * 0.33, w, darkPaint);
    } else {
      _drawEyes(canvas, cx, h * 0.33, w, darkPaint, whitePaint);
      _drawLashes(canvas, cx, h * 0.33, w, darkPaint);
    }

    // Wattle
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.56), width: w * 0.15, height: h * 0.1), wattlePaint);

    // Lips
    _drawLips(canvas, cx, h * 0.47, w, h, lipPaint, lipHighlight);

    // Crown
    if (mood == ChickenLipsMood.crowned) {
      _drawCrown(canvas, cx, h * 0.08, w);
    }

    // Feet
    final feetPaint = Paint()..color = FabColors.duckOrange;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - w * 0.14, h * 0.955), width: w * 0.16, height: h * 0.1), const Radius.circular(8)), feetPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + w * 0.14, h * 0.955), width: w * 0.16, height: h * 0.1), const Radius.circular(8)), feetPaint);

    // Sparkles
    if (showSparkles) {
      final sp = Paint()..color = FabColors.gold..strokeWidth = w * 0.025..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      void sparkle(double x, double y, double r) {
        canvas.drawLine(Offset(x, y - r), Offset(x, y + r), sp);
        canvas.drawLine(Offset(x - r, y), Offset(x + r, y), sp);
      }
      sparkle(w * 0.06, h * 0.25, w * 0.04);
      sparkle(w * 0.92, h * 0.2, w * 0.03);
    }
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
    canvas.drawCircle(Offset(cx - w * 0.18, cy), w * 0.1, dark);
    canvas.drawCircle(Offset(cx + w * 0.18, cy), w * 0.1, dark);
    canvas.drawCircle(Offset(cx - w * 0.16, cy - w * 0.04), w * 0.045, white);
    canvas.drawCircle(Offset(cx + w * 0.2, cy - w * 0.04), w * 0.045, white);
  }

  void _drawSleepyEyes(Canvas canvas, double cx, double cy, double w, Paint dark) {
    final p = Paint()..color = const Color(0xFF1A0A2E)..style = PaintingStyle.stroke..strokeWidth = w * 0.04..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx - w * 0.18, cy), width: w * 0.2, height: w * 0.14), 0, 3.14, false, p);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx + w * 0.18, cy), width: w * 0.2, height: w * 0.14), 0, 3.14, false, p);
  }

  void _drawLashes(Canvas canvas, double cx, double cy, double w, Paint dark) {
    final lash = Paint()..color = const Color(0xFF1A0A2E)..strokeWidth = w * 0.03..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - w * 0.26, cy - w * 0.07), Offset(cx - w * 0.32, cy - w * 0.15), lash);
    canvas.drawLine(Offset(cx - w * 0.2, cy - w * 0.09), Offset(cx - w * 0.22, cy - w * 0.17), lash);
    canvas.drawLine(Offset(cx - w * 0.14, cy - w * 0.09), Offset(cx - w * 0.13, cy - w * 0.17), lash);
    canvas.drawLine(Offset(cx + w * 0.14, cy - w * 0.09), Offset(cx + w * 0.13, cy - w * 0.17), lash);
    canvas.drawLine(Offset(cx + w * 0.2, cy - w * 0.09), Offset(cx + w * 0.22, cy - w * 0.17), lash);
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
    final shinePaint = Paint()..color = Colors.white.withOpacity(0.25);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.12, ly + h * 0.025), width: w * 0.18, height: h * 0.025), shinePaint);
  }

  void _drawCrown(Canvas canvas, double cx, double cy, double w) {
    final cp = Paint()..color = FabColors.gold;
    final cs = Paint()..color = const Color(0xFFC8A000)..style = PaintingStyle.stroke..strokeWidth = w * 0.015;
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
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - w * 0.28, cy + w * 0.08, w * 0.56, w * 0.08), const Radius.circular(3)), cp);
    canvas.drawCircle(Offset(cx - w * 0.14, cy), w * 0.045, Paint()..color = FabColors.rose);
    canvas.drawCircle(Offset(cx, cy - w * 0.06), w * 0.055, Paint()..color = FabColors.deepRose);
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
        color: const Color(0xFF1A0A2E),
        border: Border.all(color: FabColors.pink, width: 1.5),
      ),
      child: ClipOval(
        child: ChickenLipsWidget(mood: mood, size: ChickenLipsSize.small),
      ),
    );
  }
}