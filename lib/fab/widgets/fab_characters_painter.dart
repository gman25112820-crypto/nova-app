import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import "../fab_theme.dart";

enum ChickenMood { happy, grumpy, sleepy, excited }

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  FabCharactersWidget
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class FabCharactersWidget extends StatefulWidget {
  const FabCharactersWidget({super.key});

  @override
  State<FabCharactersWidget> createState() => _FabCharactersWidgetState();
}

class _FabCharactersWidgetState extends State<FabCharactersWidget>
    with TickerProviderStateMixin {
  late final AnimationController _idleCtrl;
  late final AnimationController _blinkCtrl;
  Timer? _blinkTimer;
  final _rng = Random();
  late final AnimationController _dartCtrl;
  Offset _dartTarget = Offset.zero;
  Timer? _dartTimer;
  ChickenMood _mood = ChickenMood.happy;
  late final AnimationController _moodCtrl;
  late final AnimationController _reactCtrl;
  bool _isReacting = false;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scheduleBlink();
    _dartCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scheduleDart();
    _moodCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..value = 1.0;
    _reactCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 2000 + _rng.nextInt(4000)), () async {
      await _blinkCtrl.forward();
      await _blinkCtrl.reverse();
      if (mounted) _scheduleBlink();
    });
  }

  void _scheduleDart() {
    _dartTimer = Timer(Duration(milliseconds: 3000 + _rng.nextInt(5000)), () async {
      setState(() {
        _dartTarget = Offset((_rng.nextDouble() - 0.5) * 4, (_rng.nextDouble() - 0.5) * 3);
      });
      await _dartCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _dartTarget = Offset.zero);
      await _dartCtrl.reverse();
      if (mounted) _scheduleDart();
    });
  }

  void setMood(ChickenMood mood) {
    setState(() => _mood = mood);
    _moodCtrl.forward(from: 0);
  }

  void triggerReaction() {
    if (_isReacting) return;
    setState(() => _isReacting = true);
    _reactCtrl.forward(from: 0).then((_) {
      _reactCtrl.reverse().then((_) {
        if (mounted) setState(() => _isReacting = false);
      });
    });
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _blinkCtrl.dispose();
    _blinkTimer?.cancel();
    _dartCtrl.dispose();
    _dartTimer?.cancel();
    _moodCtrl.dispose();
    _reactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: triggerReaction,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleCtrl, _blinkCtrl, _dartCtrl, _moodCtrl, _reactCtrl]),
        builder: (context, _) {
          return CustomPaint(
            painter: FabCharactersPainter(
              animationValue: _idleCtrl.value,
              blinkValue: _blinkCtrl.value,
              dartOffset: _dartTarget * _dartCtrl.value,
              mood: _mood,
              moodValue: _moodCtrl.value,
              reactValue: _reactCtrl.value,
              isReacting: _isReacting,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  FabCharactersPainter
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class FabCharactersPainter extends CustomPainter {
  final double animationValue;
  final double blinkValue;
  final Offset dartOffset;
  final ChickenMood mood;
  final double moodValue;
  final double reactValue;
  final bool isReacting;

  FabCharactersPainter({
    required this.animationValue,
    this.blinkValue = 0,
    this.dartOffset = Offset.zero,
    this.mood = ChickenMood.happy,
    this.moodValue = 1,
    this.reactValue = 0,
    this.isReacting = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height * 0.78;
    _drawChickenLips(canvas, size, groundY);
    _drawDaughterNine(canvas, size, groundY);
    _drawDaughterSeven(canvas, size, groundY);
    _drawShihTzu(canvas, size, groundY);
    _drawCatsInWindows(canvas, size, groundY);
    _drawDadGiraffe(canvas, size, groundY);
    _drawSonGiraffeOne(canvas, size, groundY);
    _drawSonGiraffeTwo(canvas, size, groundY);
    _drawJackRussell(canvas, size, groundY);
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  CHICKEN FAMILY
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  void _drawChickenLips(Canvas canvas, Size size, double groundY) {
    final reactBounce = isReacting ? -sin(reactValue * pi) * 22 : 0.0;
    final bob = sin(animationValue * 2 * pi) * 3;
    final walkX = size.width * 0.28 + sin(animationValue * 2 * pi * 0.3) * size.width * 0.05;
    _paintChicken(
      canvas: canvas, cx: walkX, cy: groundY - 2 + bob + reactBounce,
      scale: 1.4, hasCrown: true, blushColour: FabColors.pink,
      blinkValue: blinkValue, dartOffset: dartOffset,
      mood: mood, moodValue: moodValue,
      footPhase: animationValue * 2 * pi,
      isReacting: isReacting, reactValue: reactValue,
    );
  }

  void _drawDaughterNine(Canvas canvas, Size size, double groundY) {
    final bob = sin((animationValue * 2 * pi) + 0.8) * 2.5;
    final walkX = size.width * 0.17 + sin((animationValue * 2 * pi * 0.25) + 1.0) * size.width * 0.03;
    _paintChicken(
      canvas: canvas, cx: walkX, cy: groundY - 2 + bob,
      scale: 1.05, hasCrown: false, blushColour: FabColors.rose,
      footPhase: animationValue * 2 * pi + 1.2,
    );
  }

  void _drawDaughterSeven(Canvas canvas, Size size, double groundY) {
    final bob = sin((animationValue * 2 * pi) + 1.6) * 2;
    final walkX = size.width * 0.36 + sin((animationValue * 2 * pi * 0.2) + 2.0) * size.width * 0.025;
    _paintChicken(
      canvas: canvas, cx: walkX, cy: groundY - 2 + bob,
      scale: 0.88, hasCrown: false, blushColour: FabColors.pink,
      footPhase: animationValue * 2 * pi + 2.4,
    );
  }

  void _paintChicken({
    required Canvas canvas,
    required double cx,
    required double cy,
    required double scale,
    required bool hasCrown,
    required Color blushColour,
    double blinkValue = 0,
    Offset dartOffset = Offset.zero,
    ChickenMood mood = ChickenMood.happy,
    double moodValue = 1,
    double footPhase = 0,
    bool isReacting = false,
    double reactValue = 0,
  }) {
    final squash = 1.0 + sin(animationValue * 2 * pi) * 0.08;
    final stretch = 1.0 - sin(animationValue * 2 * pi) * 0.08;
    final bodyR = 22.0 * scale;
    final headR = 16.0 * scale;
    final headCY = cy - bodyR - headR * 0.7;

    // Body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - bodyR * 0.5),
        width: bodyR * 2 * squash, height: bodyR * 2 * stretch,
      ),
      Paint()..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4), radius: 0.9,
        colors: [const Color(0xFFFFF5A0), FabColors.duckYellow, const Color(0xFFD4A800)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy - bodyR * 0.5), radius: bodyR)),
    );

    // Wings
    final wingPaint = Paint()..color = FabColors.gold;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - bodyR * 0.85, cy - bodyR * 0.5), width: bodyR * 1.1, height: bodyR * 0.65), wingPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + bodyR * 0.85, cy - bodyR * 0.5), width: bodyR * 1.1, height: bodyR * 0.65), wingPaint);

    // Head
    canvas.drawCircle(Offset(cx, headCY), headR, Paint()..color = FabColors.duckYellow);

    // Crest
    for (int i = -1; i <= 1; i++) {
      final crestLag = sin((animationValue * 2 * pi) + i * 0.4) * 2.5 * scale;
      final crestSway = sin((animationValue * 2 * pi) * 0.7 + i * 0.6) * 1.5 * scale;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + i * headR * 0.45 + crestSway, headCY - headR * 0.75 - (i == 0 ? 2 * scale : 0) + crestLag),
          width: headR * 0.45, height: headR * 0.8 + crestLag * 0.3,
        ),
        Paint()..color = FabColors.pink,
      );
    }

    // Crown
    if (hasCrown) {
      final crownPaint = Paint()..color = FabColors.gold;
      final crownY = headCY - headR * 0.85;
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, crownY), width: headR * 1.1, height: headR * 0.45), crownPaint);
      for (int i = -1; i <= 1; i++) {
        canvas.drawPath(
          Path()
            ..moveTo(cx + i * headR * 0.38 - headR * 0.18, crownY - headR * 0.22)
            ..lineTo(cx + i * headR * 0.38, crownY - headR * 0.55)
            ..lineTo(cx + i * headR * 0.38 + headR * 0.18, crownY - headR * 0.22)
            ..close(),
          crownPaint,
        );
        canvas.drawCircle(Offset(cx + i * headR * 0.38, crownY - headR * 0.55), 2.5 * scale, Paint()..color = FabColors.pink);
      }
    }

    // Eyes
    final eyeLX = cx - headR * 0.35;
    final eyeRX = cx + headR * 0.35;
    final eyeBaseY = headCY - headR * 0.05;
    final eyeRadius = headR * 0.28;
    final eyeWhite = Paint()..color = Colors.white;
    final eyeDark = Paint()..color = const Color(0xFF1a0a2e);

    canvas.drawCircle(Offset(eyeLX, eyeBaseY), eyeRadius, eyeWhite);
    canvas.drawCircle(Offset(eyeRX, eyeBaseY), eyeRadius, eyeWhite);
    canvas.drawCircle(Offset(cx - headR * 0.32 + dartOffset.dx * scale, headCY - headR * 0.02 + dartOffset.dy * scale), headR * 0.16, eyeDark);
    canvas.drawCircle(Offset(cx + headR * 0.38 + dartOffset.dx * scale, headCY - headR * 0.02 + dartOffset.dy * scale), headR * 0.16, eyeDark);
    canvas.drawCircle(Offset(cx - headR * 0.28, headCY - headR * 0.06), headR * 0.07, eyeWhite);
    canvas.drawCircle(Offset(cx + headR * 0.42, headCY - headR * 0.06), headR * 0.07, eyeWhite);

    // Blink lid
    if (blinkValue > 0) {
      final lidH = eyeRadius * 2.2 * blinkValue;
      final lidPaint = Paint()..color = FabColors.duckYellow;
      canvas.drawRect(Rect.fromLTWH(eyeLX - eyeRadius, eyeBaseY - eyeRadius, eyeRadius * 2, lidH), lidPaint);
      canvas.drawRect(Rect.fromLTWH(eyeRX - eyeRadius, eyeBaseY - eyeRadius, eyeRadius * 2, lidH), lidPaint);
    }

    // Lashes
    final lashPaint = Paint()
      ..color = const Color(0xFF1a0a2e)
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final la = mood == ChickenMood.grumpy ? 0.3 * moodValue : mood == ChickenMood.excited ? -0.2 * moodValue : 0.0;
    canvas.drawLine(Offset(cx - headR * 0.45, headCY - headR * 0.25), Offset(cx - headR * 0.55 + la * headR, headCY - headR * 0.42), lashPaint);
    canvas.drawLine(Offset(cx - headR * 0.32, headCY - headR * 0.30), Offset(cx - headR * 0.35 + la * headR * 0.5, headCY - headR * 0.48), lashPaint);
    canvas.drawLine(Offset(cx + headR * 0.32, headCY - headR * 0.30), Offset(cx + headR * 0.35 - la * headR * 0.5, headCY - headR * 0.48), lashPaint);
    canvas.drawLine(Offset(cx + headR * 0.45, headCY - headR * 0.25), Offset(cx + headR * 0.55 - la * headR, headCY - headR * 0.42), lashPaint);

    // Sleepy lid
    if (mood == ChickenMood.sleepy && moodValue > 0) {
      final lidPaint = Paint()..color = FabColors.duckYellow;
      final sleepLid = eyeRadius * 1.1 * moodValue;
      canvas.drawRect(Rect.fromLTWH(eyeLX - eyeRadius, eyeBaseY - eyeRadius, eyeRadius * 2, sleepLid), lidPaint);
      canvas.drawRect(Rect.fromLTWH(eyeRX - eyeRadius, eyeBaseY - eyeRadius, eyeRadius * 2, sleepLid), lidPaint);
    }

    // Blush
    final blushPaint = Paint()..color = blushColour.withValues(alpha: 0.4);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - headR * 0.55, headCY + headR * 0.1), width: headR * 0.55, height: headR * 0.28), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + headR * 0.55, headCY + headR * 0.1), width: headR * 0.55, height: headR * 0.28), blushPaint);

    // Beak
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, headCY + headR * 0.38), width: headR * 0.55,
          height: mood == ChickenMood.excited ? headR * 0.38 * (1 + 0.3 * moodValue) : headR * 0.32),
      Paint()..color = FabColors.duckOrange,
    );

    // Feet
    final footY = cy - bodyR * 0.1;
    final footPaint = Paint()..color = FabColors.duckOrange..strokeWidth = 2.5 * scale..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 6 * scale, footY), Offset(cx - 9 * scale, footY + 12 * scale - max(0.0, sin(footPhase) * 5 * scale)), footPaint);
    canvas.drawLine(Offset(cx + 6 * scale, footY), Offset(cx + 9 * scale, footY + 12 * scale - max(0.0, sin(footPhase + pi) * 5 * scale)), footPaint);

    // Reaction sparkles
    if (isReacting && reactValue > 0) {
      final sparklePaint = Paint()..color = FabColors.gold.withValues(alpha: 1 - reactValue)..strokeWidth = 1.5..style = PaintingStyle.stroke;
      for (int i = 0; i < 6; i++) {
        final angle = (i / 6) * 2 * pi;
        final dist = 28 * scale * reactValue;
        final sx = cx + cos(angle) * dist;
        final sy = (headCY - headR) + sin(angle) * dist;
        canvas.drawLine(Offset(sx, sy), Offset(sx + cos(angle) * 7 * scale, sy + sin(angle) * 7 * scale), sparklePaint);
      }
    }
  }

  // â”€â”€ SHIH TZU â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _drawShihTzu(Canvas canvas, Size size, double groundY) {
    final trot = sin(animationValue * 2 * pi * 0.4) * 3;
    final x = size.width * 0.10 + sin(animationValue * 2 * pi * 0.15) * size.width * 0.025;
    final y = groundY + trot;
    const s = 0.95;

    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 12 * s), width: 34 * s, height: 22 * s), Paint()..color = const Color(0xFFf5f0e8));
    canvas.drawCircle(Offset(x + 14 * s, y - 16 * s), 12 * s, Paint()..color = const Color(0xFFf5f0e8));
    canvas.drawCircle(Offset(x + 14 * s, y - 14 * s), 8 * s, Paint()..color = const Color(0xFFd4a96a));
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 8 * s, y - 24 * s), width: 8 * s, height: 14 * s), Paint()..color = const Color(0xFFd4a96a));
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 20 * s, y - 24 * s), width: 8 * s, height: 14 * s), Paint()..color = const Color(0xFFd4a96a));
    canvas.drawCircle(Offset(x + 11 * s, y - 16 * s), 2.5 * s, Paint()..color = const Color(0xFF1a0a2e));
    canvas.drawCircle(Offset(x + 18 * s, y - 16 * s), 2.5 * s, Paint()..color = const Color(0xFF1a0a2e));
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 14 * s, y - 11 * s), width: 5 * s, height: 3 * s), Paint()..color = const Color(0xFF333333));

    final legPaint = Paint()..color = const Color(0xFFf5f0e8)..strokeWidth = 4 * s..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final phase = animationValue * 2 * pi;
    canvas.drawLine(Offset(x - 6 * s, y - 4 * s), Offset(x - 7 * s + sin(phase) * 4 * s, y + 8 * s), legPaint);
    canvas.drawLine(Offset(x + 2 * s, y - 4 * s), Offset(x + 3 * s + sin(phase + pi) * 4 * s, y + 8 * s), legPaint);
    canvas.drawLine(Offset(x + 10 * s, y - 4 * s), Offset(x + 11 * s + sin(phase) * 4 * s, y + 8 * s), legPaint);
  }

  // â”€â”€ CATS IN WINDOWS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _drawCatsInWindows(Canvas canvas, Size size, double groundY) {
    final cx = size.width * 0.22;
    _drawCat(canvas, Offset(cx - 36, groundY - 65), true);
    _drawCat(canvas, Offset(cx + 24, groundY - 65), false);
  }

  void _drawCat(Canvas canvas, Offset windowPos, bool lookingLeft) {
    final x = windowPos.dx + 12;
    final y = windowPos.dy + 10;
    const s = 0.55;

    canvas.drawOval(Rect.fromCenter(center: Offset(x, y + 6 * s), width: 18 * s, height: 14 * s), Paint()..color = const Color(0xFF1a1a2e));
    canvas.drawCircle(Offset(x, y - 4 * s), 9 * s, Paint()..color = const Color(0xFF1a1a2e));
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y + 4 * s), width: 8 * s, height: 7 * s), Paint()..color = const Color(0xFFf0f0f0));

    for (final ear in [
      Path()..moveTo(x - 7*s, y - 10*s)..lineTo(x - 10*s, y - 17*s)..lineTo(x - 3*s, y - 12*s)..close(),
      Path()..moveTo(x + 7*s, y - 10*s)..lineTo(x + 10*s, y - 17*s)..lineTo(x + 3*s, y - 12*s)..close(),
    ]) canvas.drawPath(ear, Paint()..color = const Color(0xFF1a1a2e));

    for (final ex in [-3.5 * s, 3.5 * s]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x + ex, y - 4 * s), width: 5 * s, height: 4 * s), Paint()..color = const Color(0xFF7FDD77));
      canvas.drawOval(Rect.fromCenter(center: Offset(x + ex, y - 4 * s), width: 2 * s, height: 3.5 * s), Paint()..color = const Color(0xFF1a0a2e));
    }
    canvas.drawCircle(Offset(x, y - 1 * s), 1.5 * s, Paint()..color = FabColors.pink);

    canvas.drawPath(
      Path()
        ..moveTo(x + (lookingLeft ? -8 : 8) * s, y + 8 * s)
        ..quadraticBezierTo(x + (lookingLeft ? -18 : 18) * s, y + 12 * s, x + (lookingLeft ? -14 : 14) * s, y + 2 * s),
      Paint()..color = const Color(0xFF1a1a2e)..strokeWidth = 3 * s..strokeCap = StrokeCap.round..style = PaintingStyle.stroke,
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  GIRAFFE FAMILY
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  void _drawDadGiraffe(Canvas canvas, Size size, double groundY) {
    final bob = sin(animationValue * 2 * pi * 0.4) * 2;
    final walkX = size.width * 0.72 + sin(animationValue * 2 * pi * 0.22) * size.width * 0.04;
    _paintGiraffe(canvas: canvas, cx: walkX, cy: groundY + bob, scale: 1.3, footPhase: animationValue * 2 * pi);
  }

  void _drawSonGiraffeOne(Canvas canvas, Size size, double groundY) {
    final bob = sin((animationValue * 2 * pi * 0.35) + 1.0) * 2;
    final walkX = size.width * 0.84 + sin((animationValue * 2 * pi * 0.18) + 0.5) * size.width * 0.03;
    _paintGiraffe(canvas: canvas, cx: walkX, cy: groundY + bob, scale: 0.95, footPhase: animationValue * 2 * pi + 1.0);
  }

  void _drawSonGiraffeTwo(Canvas canvas, Size size, double groundY) {
    final bob = sin((animationValue * 2 * pi * 0.3) + 2.0) * 1.5;
    final walkX = size.width * 0.91 + sin((animationValue * 2 * pi * 0.15) + 1.5) * size.width * 0.025;
    _paintGiraffe(canvas: canvas, cx: walkX, cy: groundY + bob, scale: 0.78, footPhase: animationValue * 2 * pi + 2.0);
  }

  void _paintGiraffe({
    required Canvas canvas,
    required double cx,
    required double cy,
    required double scale,
    double footPhase = 0,
  }) {
    const bodyColour = Color(0xFFe8b84b);
    const patchColour = Color(0xFF8b5e1a);
    const hornColour = Color(0xFFc4952a);

    final bodyPaint = Paint()..color = bodyColour;
    final patchPaint = Paint()..color = patchColour.withValues(alpha: 0.7);
    final legPaint = Paint()..color = bodyColour..strokeWidth = 7 * scale..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final hoofPaint = Paint()..color = const Color(0xFF5a3a0a)..strokeWidth = 7 * scale..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;

    final legSwing = sin(footPhase) * 6 * scale;
    final legSwingB = sin(footPhase + pi) * 6 * scale;
    final legBaseY = cy - 8 * scale;
    final legBottomY = cy + 38 * scale;

    // Legs
    for (final pair in [
      [cx + 10 * scale, legSwingB],
      [cx + 2 * scale, legSwing],
      [cx - 10 * scale, legSwing],
      [cx - 2 * scale, legSwingB],
    ]) {
      final lx = pair[0];
      final sw = pair[1];
      canvas.drawLine(Offset(lx, legBaseY), Offset(lx + sw, legBottomY), legPaint);
      canvas.drawLine(Offset(lx, legBaseY), Offset(lx + sw, legBottomY + 4 * scale), hoofPaint);
    }

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 20 * scale), width: 36 * scale, height: 28 * scale), bodyPaint);
    for (int i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + (i - 1) * 10 * scale, cy - 18 * scale + (i % 2) * 6 * scale), width: 8 * scale, height: 6 * scale),
        patchPaint,
      );
    }

    // Neck
    canvas.drawPath(
      Path()
        ..moveTo(cx - 5 * scale, cy - 32 * scale)
        ..lineTo(cx + 5 * scale, cy - 32 * scale)
        ..lineTo(cx + 3 * scale, cy - 65 * scale)
        ..lineTo(cx - 3 * scale, cy - 65 * scale)
        ..close(),
      bodyPaint,
    );
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 45 * scale), width: 6 * scale, height: 5 * scale), patchPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 1 * scale, cy - 56 * scale), width: 5 * scale, height: 4 * scale), patchPaint);

    // Head
    final headR = 10.0 * scale;
    final headCY = cy - 72 * scale;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, headCY), width: headR * 2.2, height: headR * 1.8), bodyPaint);

    // Ossicones
    final hornPaint = Paint()..color = hornColour;
    for (final hx in [cx - headR * 0.4, cx + headR * 0.4]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(hx, headCY - headR * 0.8), width: 4 * scale, height: 9 * scale), hornPaint);
      canvas.drawCircle(Offset(hx, headCY - headR * 1.2), 3 * scale, hornPaint);
    }

    // Eyes
    final eyeWhite = Paint()..color = Colors.white;
    final eyeDark = Paint()..color = const Color(0xFF1a0a2e);
    for (final ex in [cx - headR * 0.35, cx + headR * 0.35]) {
      canvas.drawCircle(Offset(ex, headCY - headR * 0.1), headR * 0.22, eyeWhite);
    }
    canvas.drawCircle(Offset(cx - headR * 0.32, headCY - headR * 0.08), headR * 0.13, eyeDark);
    canvas.drawCircle(Offset(cx + headR * 0.38, headCY - headR * 0.08), headR * 0.13, eyeDark);
    canvas.drawCircle(Offset(cx - headR * 0.28, headCY - headR * 0.12), headR * 0.05, eyeWhite);
    canvas.drawCircle(Offset(cx + headR * 0.42, headCY - headR * 0.12), headR * 0.05, eyeWhite);

    // Snout
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, headCY + headR * 0.4), width: headR * 0.9, height: headR * 0.45), Paint()..color = const Color(0xFFd4a060));
    for (final nx in [cx - headR * 0.2, cx + headR * 0.2]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(nx, headCY + headR * 0.42), width: headR * 0.16, height: headR * 0.1), Paint()..color = patchColour.withValues(alpha: 0.5));
    }

    // Mane
    final manePaint = Paint()..color = patchColour.withValues(alpha: 0.8)..strokeWidth = 3 * scale..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    for (int i = 0; i < 4; i++) {
      final maneY = cy - 37 * scale - i * 8 * scale;
      final sway = sin(animationValue * 2 * pi + i * 0.5) * 2 * scale;
      canvas.drawLine(Offset(cx - 2 * scale, maneY), Offset(cx - 6 * scale + sway, maneY - 7 * scale), manePaint);
    }

    // Tail
    final tailSwing = sin(animationValue * 2 * pi * 0.6) * 8 * scale;
    canvas.drawPath(
      Path()
        ..moveTo(cx + 16 * scale, cy - 22 * scale)
        ..quadraticBezierTo(cx + 28 * scale, cy - 10 * scale, cx + 22 * scale + tailSwing, cy + 5 * scale),
      Paint()..color = bodyColour..strokeWidth = 3 * scale..strokeCap = StrokeCap.round..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(Offset(cx + 22 * scale + tailSwing, cy + 5 * scale), 4 * scale, Paint()..color = patchColour.withValues(alpha: 0.8));
  }

  // â”€â”€ JACK RUSSELL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _drawJackRussell(Canvas canvas, Size size, double groundY) {
    final trot = sin(animationValue * 2 * pi * 0.5) * 3;
    final x = size.width * 0.96 + sin(animationValue * 2 * pi * 0.2) * size.width * 0.02;
    final y = groundY + trot;
    const s = 0.85;

    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 10 * s), width: 28 * s, height: 18 * s), Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 5 * s, y - 12 * s), width: 14 * s, height: 10 * s), Paint()..color = const Color(0xFF8b5e1a));
    canvas.drawCircle(Offset(x + 12 * s, y - 16 * s), 10 * s, Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 14 * s, y - 19 * s), width: 10 * s, height: 8 * s), Paint()..color = const Color(0xFF8b5e1a));
    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 6 * s, y - 22 * s), width: 7 * s, height: 11 * s), Paint()..color = const Color(0xFF8b5e1a));
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 17 * s, y - 22 * s), width: 6 * s, height: 10 * s), Paint()..color = const Color(0xFF8b5e1a));
    // Eyes
    canvas.drawCircle(Offset(x + 10 * s, y - 16 * s), 2 * s, Paint()..color = const Color(0xFF1a0a2e));
    canvas.drawCircle(Offset(x + 15 * s, y - 16 * s), 2 * s, Paint()..color = const Color(0xFF1a0a2e));
    canvas.drawCircle(Offset(x + 10.5 * s, y - 16.5 * s), 0.7 * s, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(x + 15.5 * s, y - 16.5 * s), 0.7 * s, Paint()..color = Colors.white);
    // Nose
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 12 * s, y - 11 * s), width: 4 * s, height: 3 * s), Paint()..color = const Color(0xFF333333));

    // Legs
    final legPaint = Paint()..color = Colors.white..strokeWidth = 3.5 * s..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final phase = animationValue * 2 * pi;
    canvas.drawLine(Offset(x - 4 * s, y - 2 * s), Offset(x - 5 * s + sin(phase) * 4 * s, y + 8 * s), legPaint);
    canvas.drawLine(Offset(x + 4 * s, y - 2 * s), Offset(x + 5 * s + sin(phase + pi) * 4 * s, y + 8 * s), legPaint);
    canvas.drawLine(Offset(x + 10 * s, y - 2 * s), Offset(x + 11 * s + sin(phase) * 4 * s, y + 8 * s), legPaint);

    // Wagging tail
    final tailWag = sin(animationValue * 2 * pi * 3) * 8 * s;
    canvas.drawLine(
      Offset(x - 8 * s, y - 10 * s), Offset(x - 14 * s + tailWag, y - 20 * s),
      Paint()..color = Colors.white..strokeWidth = 3 * s..strokeCap = StrokeCap.round..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(FabCharactersPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.blinkValue != blinkValue ||
      oldDelegate.dartOffset != dartOffset ||
      oldDelegate.mood != mood ||
      oldDelegate.moodValue != moodValue ||
      oldDelegate.reactValue != reactValue ||
      oldDelegate.isReacting != isReacting;
}

