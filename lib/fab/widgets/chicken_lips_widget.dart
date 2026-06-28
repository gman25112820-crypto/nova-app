

import 'dart:math';
import 'package:flutter/material.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  MISS CHICKEN LIPS â€” North Star Edition  v3.0
//  Reference-accurate 3D fluffy nurse chicken
//
//  Usage:
//    ChickenLipsWidget(mood: ChickenMood.happy, scale: 1.0)
//    MissChickenLipsPanel(mood: ChickenMood.happy, message: "Feeling Fab!")
//
//  Moods: happy Â· sad Â· worried Â· proud Â· crowned Â· sleeping Â· wink
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

enum ChickenMood { happy, sad, worried, proud, crowned, sleeping, wink }

class ChickenLipsWidget extends StatefulWidget {
  final ChickenMood mood;
  final double scale;
  final bool enableAnimations;

  const ChickenLipsWidget({
    super.key,
    this.mood = ChickenMood.happy,
    this.scale = 1.0,
    this.enableAnimations = true,
  });

  @override
  State<ChickenLipsWidget> createState() => _ChickenLipsWidgetState();
}

class _ChickenLipsWidgetState extends State<ChickenLipsWidget>
    with TickerProviderStateMixin {
  late AnimationController _blinkCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _swayCtrl;
  late AnimationController _bounceCtrl;

  late Animation<double> _blinkAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _swayAnim;
  late Animation<double> _bounceAnim;

  double _dartX = 0;
  double _dartY = 0;
  final _rng = Random();

  @override
  void initState() {
    super.initState();

    _blinkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 130));
    _blinkAnim = CurvedAnimation(parent: _blinkCtrl, curve: Curves.easeInOut);

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _glowAnim = Tween(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _swayCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _swayAnim = Tween(begin: -0.018, end: 0.018)
        .animate(CurvedAnimation(parent: _swayCtrl, curve: Curves.easeInOut));

    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _bounceAnim = Tween(begin: 0.0, end: -5.0)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));

    if (widget.enableAnimations) {
      _scheduleBlink();
      _scheduleDart();
    }
  }

  void _scheduleBlink() {
    Future.delayed(
        Duration(milliseconds: 2800 + _rng.nextInt(4000)), () {
      if (!mounted) return;
      _blinkCtrl.forward().then((_) =>
          _blinkCtrl.reverse().then((_) => _scheduleBlink()));
    });
  }

  void _scheduleDart() {
    Future.delayed(
        Duration(milliseconds: 3500 + _rng.nextInt(5000)), () {
      if (!mounted) return;
      setState(() {
        _dartX = (_rng.nextDouble() - 0.5) * 5;
        _dartY = (_rng.nextDouble() - 0.5) * 3;
      });
      _scheduleDart();
    });
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    _glowCtrl.dispose();
    _swayCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = 180.0 * widget.scale;
    final h = 220.0 * widget.scale;
    // Nurse Chicken Lips sprite — replaces CustomPainter visual.
    // To revert: delete the SizedBox return and uncomment the AnimatedBuilder below.
    return SizedBox(
      width: w,
      height: h,
      child: Image.asset(
        'assets/images/characters/chicken_lips.png',
        fit: BoxFit.contain,
      ),
    );
    // return AnimatedBuilder(
    //   animation: Listenable.merge([_blinkAnim, _glowAnim, _swayAnim, _bounceAnim]),
    //   builder: (ctx, _) => Transform.rotate(
    //     angle: widget.enableAnimations ? _swayAnim.value : 0,
    //     child: SizedBox(
    //       width: w,
    //       height: h,
    //       child: CustomPaint(
    //         painter: _ChickenPainter(
    //           mood: widget.mood,
    //           blink: _blinkAnim.value,
    //           glow: _glowAnim.value,
    //           dartX: _dartX,
    //           dartY: _dartY,
    //           bounce: (widget.mood == ChickenMood.crowned ||
    //                   widget.mood == ChickenMood.proud)
    //               ? _bounceAnim.value
    //               : 0,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  CORE PAINTER  â€” all design at 180Ã—220 virtual units
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ChickenPainter extends CustomPainter {
  final ChickenMood mood;
  final double blink;
  final double glow;
  final double dartX;
  final double dartY;
  final double bounce;

  _ChickenPainter({
    required this.mood,
    required this.blink,
    required this.glow,
    required this.dartX,
    required this.dartY,
    required this.bounce,
  });

  late double _sx, _sy;
  double _x(double v) => v * _sx;
  double _y(double v) => v * _sy;
  double _r(double v) => v * _sx;

  @override
  void paint(Canvas canvas, Size size) {
    _sx = size.width / 180;
    _sy = size.height / 220;

    _drawGroundShadow(canvas);
    _drawBodyGlow(canvas);
    _drawBody(canvas);
    _drawNurseUniform(canvas);
    _drawWings(canvas);
    _drawCrest(canvas);
    _drawNurseHat(canvas);
    _drawEyes(canvas);
    _drawBrows(canvas);
    _drawBeak(canvas);
    _drawBlush(canvas);
    _drawStethoscope(canvas);
    _drawFeet(canvas);
    if (mood == ChickenMood.crowned || mood == ChickenMood.proud) {
      _drawCrown(canvas);
    }
  }

  void _drawGroundShadow(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(_x(90), _y(213)),
          width: _r(100),
          height: _r(10)),
      Paint()
        ..color = const Color(0xFF2D1B69).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _drawBodyGlow(Canvas canvas) {
    final center = Offset(_x(90), _y(110));
    canvas.drawCircle(
      center,
      _r(84),
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFE082).withValues(alpha: 0.55 * glow),
          const Color(0xFFFF8F00).withValues(alpha: 0.20 * glow),
          Colors.transparent,
        ], stops: const [0.0, 0.6, 1.0])
            .createShader(Rect.fromCircle(center: center, radius: _r(84))),
    );
  }

  void _drawBody(Canvas canvas) {
    final center = Offset(_x(90), _y(115));
    final radius = _r(80);

    // Outer soft shadow / fur edge
    canvas.drawCircle(
      center, radius + _r(3),
      Paint()
        ..color = const Color(0xFFE65100).withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Main body
    canvas.drawCircle(
      center, radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.32, -0.38),
          colors: const [
            Color(0xFFFFFBE7),
            Color(0xFFFFCE00),
            Color(0xFFFF8C00),
          ],
          stops: const [0.0, 0.52, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Fur texture ring
    canvas.drawCircle(center, radius,
      Paint()
        ..color = const Color(0xFFFFC107).withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _r(10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Specular top-left highlight
    canvas.drawCircle(Offset(_x(64), _y(72)), _r(24),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.36)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(Offset(_x(60), _y(67)), _r(11),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.52)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  void _drawNurseUniform(Canvas canvas) {
    final bodyCenter = Offset(_x(90), _y(115));
    final bodyR = _r(80);
    final dressTop = _y(148);

    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(center: bodyCenter, radius: bodyR)));

    final dressRect = Rect.fromLTRB(
        bodyCenter.dx - bodyR, dressTop, bodyCenter.dx + bodyR, _y(205));
    canvas.drawRect(
      dressRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFFB39DDB),
            Color(0xFF7C6BC4),
            Color(0xFF5E35B1),
          ],
        ).createShader(dressRect),
    );

    // Dress buttons
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(_x(90), _y(162 + i * 12.0)), _r(2.8),
          Paint()..color = Colors.white.withValues(alpha: 0.88));
      canvas.drawCircle(Offset(_x(90), _y(162 + i * 12.0)), _r(2.8),
          Paint()
            ..color = const Color(0xFF9575CD).withValues(alpha: 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = _r(0.8));
    }

    canvas.restore();
    _drawCollar(canvas);
    _drawHeartBadge(canvas);
  }

  void _drawCollar(Canvas canvas) {
    final cy = _y(145.0);
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.6),
        colors: const [Colors.white, Color(0xFFEDE7F6)],
      ).createShader(Rect.fromCenter(
          center: Offset(_x(90), cy + _r(9)), width: _r(90), height: _r(22)));
    final shadow = Paint()
      ..color = const Color(0xFF7C6BC4).withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final side in [-1, 1]) {
      final path = Path()
        ..moveTo(_x(90), cy)
        ..quadraticBezierTo(_x(90 + side * 35), cy + _r(4),
            _x(90 + side * 38), cy + _r(15))
        ..quadraticBezierTo(
            _x(90 + side * 32), cy + _r(20), _x(90), cy + _r(13))
        ..close();
      canvas.drawPath(path, shadow);
      canvas.drawPath(path, paint);
    }
  }

  void _drawHeartBadge(Canvas canvas) {
    final hx = _x(90.0);
    final hy = _y(154.0);
    final hr = _r(6.5);

    final path = Path()
      ..moveTo(hx, hy + hr * 0.65)
      ..cubicTo(hx, hy, hx - hr * 1.2, hy, hx - hr * 1.2, hy - hr * 0.4)
      ..cubicTo(hx - hr * 1.2, hy - hr * 1.1, hx, hy - hr * 1.1, hx, hy - hr * 0.4)
      ..cubicTo(hx, hy - hr * 1.1, hx + hr * 1.2, hy - hr * 1.1, hx + hr * 1.2, hy - hr * 0.4)
      ..cubicTo(hx + hr * 1.2, hy, hx, hy, hx, hy + hr * 0.65);

    canvas.drawPath(path,
        Paint()..color = const Color(0xFFFF4081).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF4081));

    final cp = Paint()
      ..color = Colors.white
      ..strokeWidth = _r(1.6)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(hx - _r(2.8), hy - _r(0.2)),
        Offset(hx + _r(2.8), hy - _r(0.2)), cp);
    canvas.drawLine(Offset(hx, hy - _r(3.0)), Offset(hx, hy + _r(2.4)), cp);
  }

  void _drawWings(Canvas canvas) {
    for (final left in [true, false]) {
      final cx = left ? _x(18.0) : _x(162.0);
      final cy = _y(158.0);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(left ? 0.4 : -0.4);
      final rect = Rect.fromCenter(
          center: Offset.zero, width: _r(38), height: _r(30));
      canvas.drawOval(rect,
          Paint()
            ..shader = RadialGradient(
              center: Alignment(left ? -0.4 : 0.4, -0.4),
              colors: const [
                Color(0xFFFFF9C4),
                Color(0xFFFFCE00),
                Color(0xFFFF8F00),
              ],
              stops: const [0.0, 0.55, 1.0],
            ).createShader(rect));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(left ? -_r(6) : _r(6), -_r(5)),
              width: _r(20),
              height: _r(13)),
          Paint()..color = Colors.white.withValues(alpha: 0.28));
      canvas.restore();
    }
  }

  void _drawCrest(Canvas canvas) {
    final cx = _x(90.0);
    final cy = _y(36.0) + bounce;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + _r(2), cy + _r(4)),
            width: _r(46),
            height: _r(30)),
        Paint()
          ..color = const Color(0xFFAD1457).withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: _r(46), height: _r(30)),
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: const [
              Color(0xFFFF80AB),
              Color(0xFFE91E8C),
              Color(0xFFC2185B),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCenter(
              center: Offset(cx, cy), width: _r(46), height: _r(30))));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx - _r(9), cy - _r(7)),
            width: _r(20),
            height: _r(12)),
        Paint()..color = Colors.white.withValues(alpha: 0.32));
  }

  void _drawNurseHat(Canvas canvas) {
    final cy = _y(19.0) + bounce;
    final hatRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(_x(90), cy), width: _r(52), height: _r(24)),
        Radius.circular(_r(5)));

    canvas.drawRRect(hatRect,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    canvas.drawRRect(
        hatRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [Colors.white, Color(0xFFEDE7F6)],
          ).createShader(hatRect.outerRect));

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(_x(66), cy + _r(7), _x(114), cy + _r(13)),
            Radius.circular(_r(2))),
        Paint()..color = const Color(0xFFD1C4E9).withValues(alpha: 0.65));

    _drawMiniCrown(canvas, _x(90), cy - _r(12));
  }

  void _drawMiniCrown(Canvas canvas, double cx, double cy) {
    canvas.drawCircle(Offset(cx, cy + _r(3)), _r(10),
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.4 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    final path = Path()
      ..moveTo(cx - _r(9), cy + _r(7))
      ..lineTo(cx - _r(9), cy + _r(1))
      ..lineTo(cx - _r(4), cy + _r(4))
      ..lineTo(cx, cy - _r(7))
      ..lineTo(cx + _r(4), cy + _r(4))
      ..lineTo(cx + _r(9), cy + _r(1))
      ..lineTo(cx + _r(9), cy + _r(7))
      ..close();

    canvas.drawPath(path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Color(0xFFFFF9C4),
              Color(0xFFFFD700),
              Color(0xFFFFA000)
            ],
          ).createShader(Rect.fromCenter(
              center: Offset(cx, cy), width: _r(18), height: _r(14))));

    canvas.drawPath(path,
        Paint()
          ..color = const Color(0xFFFF8F00).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _r(0.9)
          ..strokeJoin = StrokeJoin.round);
  }

  void _drawEyes(Canvas canvas) {
    _drawEye(canvas, left: true);
    _drawEye(canvas, left: false);
  }

  void _drawEye(Canvas canvas, {required bool left}) {
    final cx = left ? _x(64.0) : _x(116.0);
    final cy = _y(100.0);
    final rx = _r(17.5);
    final ry = _r(20.0);
    final eyeRect = Rect.fromCenter(
        center: Offset(cx, cy), width: rx * 2, height: ry * 2);

    // Dark outer ring
    canvas.drawOval(eyeRect.inflate(_r(2.8)),
        Paint()
          ..color = const Color(0xFF1A0033).withValues(alpha: 0.82)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));

    // Eye white
    canvas.drawOval(eyeRect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.25, -0.3),
            colors: const [Colors.white, Color(0xFFEEE8FF)],
          ).createShader(eyeRect));

    // Iris
    final irisR = _r(14.0);
    final io = Offset(cx + dartX * 0.5, cy + dartY * 0.4);
    canvas.drawOval(
        Rect.fromCircle(center: io, radius: irisR),
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.2, -0.3),
            colors: const [
              Color(0xFFCE93D8),
              Color(0xFF9C27B0),
              Color(0xFF4A148C),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: io, radius: irisR)));

    // Pupil
    canvas.drawCircle(io, _r(8),
        Paint()..color = const Color(0xFF0D0020));

    // Main sparkle
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(io.dx - _r(4.5), io.dy - _r(5.5)),
            width: _r(7.5),
            height: _r(10)),
        Paint()..color = Colors.white.withValues(alpha: 0.95));

    // Secondary sparkle
    canvas.drawCircle(Offset(io.dx + _r(3.5), io.dy + _r(3.5)), _r(2.8),
        Paint()..color = Colors.white.withValues(alpha: 0.55));

    // Blink
    if (blink > 0 &&
        mood != ChickenMood.sleeping &&
        !(mood == ChickenMood.wink && left)) {
      canvas.drawOval(
          Rect.fromLTWH(cx - rx, cy - ry, rx * 2, ry * 2 * blink),
          Paint()
            ..color = const Color(0xFFFFCE00)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1));
    }

    if (mood == ChickenMood.sleeping) _drawClosedLine(canvas, cx, cy, rx);
    if (mood == ChickenMood.wink && left) _drawWinkLine(canvas, cx, cy, rx);

    _drawLashes(canvas, cx, cy, rx, ry);
  }

  void _drawClosedLine(Canvas canvas, double cx, double cy, double rx) {
    canvas.drawPath(
        Path()
          ..moveTo(cx - rx, cy)
          ..quadraticBezierTo(cx, cy + _r(7), cx + rx, cy),
        Paint()
          ..color = const Color(0xFF2D1B6B)
          ..strokeWidth = _r(2.5)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }

  void _drawWinkLine(Canvas canvas, double cx, double cy, double rx) {
    canvas.drawLine(Offset(cx - rx + _r(2), cy), Offset(cx + rx - _r(2), cy),
        Paint()
          ..color = const Color(0xFF2D1B6B)
          ..strokeWidth = _r(3)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }

  void _drawLashes(
      Canvas canvas, double cx, double cy, double rx, double ry) {
    final paint = Paint()
      ..color = const Color(0xFF2D1533)
      ..strokeWidth = _r(2.5)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const angles = [-0.78, -0.48, -0.18, 0.15, 0.45, 0.75];
    const lengths = [1.0, 1.15, 1.25, 1.28, 1.18, 1.02];
    const tilts = [0.55, 0.28, 0.08, -0.08, -0.28, -0.52];

    for (int i = 0; i < angles.length; i++) {
      final a = angles[i];
      final sx = cx + rx * sin(a);
      final sy = cy - ry * cos(a).abs();
      final len = lengths[i] * _r(11);
      final ex = sx + (sin(a) * 0.45 + tilts[i]) * len * 0.85;
      final ey = sy - len;
      canvas.drawLine(Offset(sx, sy), Offset(ex, ey), paint);
    }
  }

  void _drawBrows(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF2D1533)
      ..strokeWidth = _r(2.3)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final lift = _getBrowLift();
    for (final left in [true, false]) {
      final cx = left ? _x(64.0) : _x(116.0);
      final by = _y(77.0) + lift;
      canvas.drawPath(
          Path()
            ..moveTo(cx - _r(13), by + _r(2.5))
            ..quadraticBezierTo(cx, by - _r(3.5), cx + _r(13), by + _r(2.5)),
          paint);
    }
  }

  double _getBrowLift() {
    switch (mood) {
      case ChickenMood.worried:
        return -_r(3.5);
      case ChickenMood.sad:
        return _r(2.5);
      case ChickenMood.proud:
      case ChickenMood.crowned:
        return -_r(4);
      default:
        return 0;
    }
  }

  void _drawBeak(Canvas canvas) {
    final bx = _x(90.0);
    final by = _y(124.0);

    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(bx, by - _r(2)), width: _r(24), height: _r(14)),
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: const [Color(0xFFFFB74D), Color(0xFFFF6D00)],
          ).createShader(Rect.fromCenter(
              center: Offset(bx, by - _r(2)),
              width: _r(24),
              height: _r(14))));

    final depth = _getMouthDepth();
    final lip = Path()
      ..moveTo(bx - _r(11), by + _r(2))
      ..quadraticBezierTo(bx, by + _r(2) + depth, bx + _r(11), by + _r(2));

    canvas.drawPath(lip,
        Paint()
          ..color = const Color(0xFFFFCCBC).withValues(alpha: 0.8)
          ..style = PaintingStyle.fill);
    canvas.drawPath(lip,
        Paint()
          ..color = const Color(0xFFBF360C).withValues(alpha: 0.6)
          ..strokeWidth = _r(2)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);

    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(bx, by + _r(5.5)), width: _r(15), height: _r(8)),
        Paint()
          ..color = const Color(0xFFFF8A65).withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  double _getMouthDepth() {
    switch (mood) {
      case ChickenMood.happy:
      case ChickenMood.proud:
      case ChickenMood.crowned:
      case ChickenMood.wink:
        return _r(7);
      case ChickenMood.sad:
        return -_r(6);
      case ChickenMood.worried:
        return -_r(3.5);
      case ChickenMood.sleeping:
        return _r(2);
    }
  }

  void _drawBlush(Canvas canvas) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    for (final left in [true, false]) {
      paint.color = const Color(0xFFFF4081).withValues(alpha: 0.44);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(left ? _x(44) : _x(136), _y(114)),
              width: _r(22),
              height: _r(15)),
          paint);
    }
  }

  void _drawStethoscope(Canvas canvas) {
    final tube = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = _r(3.5)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left tube from collar down and around
    canvas.drawPath(
        Path()
          ..moveTo(_x(80), _y(150))
          ..quadraticBezierTo(_x(68), _y(158), _x(56), _y(170))
          ..quadraticBezierTo(_x(38), _y(188), _x(35), _y(178)),
        tube);

    // Right tube leading to disc
    canvas.drawPath(
        Path()
          ..moveTo(_x(80), _y(150))
          ..quadraticBezierTo(_x(98), _y(145), _x(110), _y(150)),
        tube);

    // Gold-rimmed disc
    final dc = Offset(_x(116), _y(158));
    canvas.drawCircle(dc, _r(10),
        Paint()
          ..shader = RadialGradient(
            colors: const [Color(0xFFFFE57F), Color(0xFFFFD700), Color(0xFFFFA000)],
          ).createShader(Rect.fromCircle(center: dc, radius: _r(10))));
    canvas.drawCircle(dc, _r(7.5),
        Paint()..color = const Color(0xFF37474F));
    canvas.drawCircle(
        Offset(dc.dx - _r(2.8), dc.dy - _r(2.8)),
        _r(2.8),
        Paint()..color = Colors.white.withValues(alpha: 0.45));

    _drawIdBadge(canvas);
  }

  void _drawIdBadge(Canvas canvas) {
    final bx = _x(66.0);
    final by = _y(164.0);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(bx, by), width: _r(22), height: _r(14)),
            Radius.circular(_r(2))),
        Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawRect(
        Rect.fromLTWH(bx - _r(10), by - _r(5.5), _r(7), _r(3.5)),
        Paint()..color = const Color(0xFFE53935).withValues(alpha: 0.8));
    canvas.drawRect(
        Rect.fromLTWH(bx - _r(10), by - _r(0.5), _r(16), _r(2.5)),
        Paint()..color = const Color(0xFF9575CD).withValues(alpha: 0.55));
    canvas.drawRect(
        Rect.fromLTWH(bx - _r(10), by + _r(3), _r(12), _r(2)),
        Paint()..color = const Color(0xFF9575CD).withValues(alpha: 0.35));
  }

  void _drawCrown(Canvas canvas) {
    final cx = _x(90.0);
    final cy = _y(8.0) + bounce;

    canvas.drawCircle(Offset(cx, cy + _r(7)), _r(20),
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.5 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));

    final path = Path()
      ..moveTo(cx - _r(18), cy + _r(13))
      ..lineTo(cx - _r(18), cy + _r(1))
      ..lineTo(cx - _r(8), cy + _r(7))
      ..lineTo(cx, cy - _r(13))
      ..lineTo(cx + _r(8), cy + _r(7))
      ..lineTo(cx + _r(18), cy + _r(1))
      ..lineTo(cx + _r(18), cy + _r(13))
      ..close();

    canvas.drawPath(path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Color(0xFFFFF9C4),
              Color(0xFFFFD700),
              Color(0xFFFF8F00),
            ],
          ).createShader(Rect.fromCenter(
              center: Offset(cx, cy), width: _r(36), height: _r(26))));
    canvas.drawPath(path,
        Paint()
          ..color = const Color(0xFFFF6F00).withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _r(1.3)
          ..strokeJoin = StrokeJoin.round);

    for (final g in [
      [cx - _r(9), cy + _r(11), 0xFFFF4081],
      [cx, cy + _r(10), 0xFF69F0AE],
      [cx + _r(9), cy + _r(11), 0xFF40C4FF],
    ]) {
      canvas.drawCircle(Offset(g[0] as double, g[1] as double), _r(3.2),
          Paint()..color = Color(g[2] as int));
      canvas.drawCircle(
          Offset((g[0] as double) - _r(1.1), (g[1] as double) - _r(1.1)),
          _r(1.3),
          Paint()..color = Colors.white.withValues(alpha: 0.7));
    }
  }

  void _drawFeet(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFF8F00)
      ..strokeWidth = _r(4.5)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final left in [true, false]) {
      final fx = left ? _x(74.0) : _x(106.0);
      final fy = _y(202.0);
      canvas.drawLine(Offset(fx, _y(190)), Offset(fx, fy), paint);
      canvas.drawLine(Offset(fx, fy), Offset(fx - _r(9), fy + _r(9)), paint);
      canvas.drawLine(Offset(fx, fy), Offset(fx, fy + _r(10)), paint);
      canvas.drawLine(Offset(fx, fy), Offset(fx + _r(9), fy + _r(9)), paint);
    }
  }

  @override
  bool shouldRepaint(_ChickenPainter old) =>
      old.mood != mood ||
      old.blink != blink ||
      old.glow != glow ||
      old.dartX != dartX ||
      old.dartY != dartY ||
      old.bounce != bounce;
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  PANEL WIDGET
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class MissChickenLipsPanel extends StatelessWidget {
  final ChickenMood mood;
  final String message;
  final double chickenScale;

  const MissChickenLipsPanel({
    super.key,
    this.mood = ChickenMood.happy,
    this.message = "Feeling Fab today! ðŸ’œ",
    this.chickenScale = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF311B92), Color(0xFF1A0050)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4FBC).withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF7C6BC4).withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
            child: ChickenLipsWidget(mood: mood, scale: chickenScale),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MISS CHICKEN LIPS',
                    style: TextStyle(
                      color: Color(0xFFB39DDB),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Text(
                      'âœ¦  FEELING FAB',
                      style: TextStyle(
                        color: Color(0xFFFFE57F),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ChickenLipsMood {
  happy,
  sleepy,
  curious,
  calm,
  protective,
  playful,
  neutral,
  sad,
  excited,
  crowned,
}
