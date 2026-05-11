import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import "../fab_theme.dart";

// ── Easing helpers ────────────────────────────────────────
double _easeInOut(double t) => t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
double _easeOut(double t) => 1 - pow(1 - t, 3).toDouble();
double _easeIn(double t) => t * t * t;
double _spring(double t, {double freq = 8, double decay = 12}) =>
    exp(-decay * t) * cos(freq * pi * t);
double _bounce(double t) {
  if (t < 0.364) return 7.5625 * t * t;
  if (t < 0.727) { t -= 0.545; return 7.5625 * t * t + 0.75; }
  if (t < 0.909) { t -= 0.818; return 7.5625 * t * t + 0.9375; }
  t -= 0.955; return 7.5625 * t * t + 0.984375;
}

enum ChickenMood { happy, grumpy, sleepy, excited }

// ══════════════════════════════════════════════════════════
//  FabCharactersWidget
// ══════════════════════════════════════════════════════════
class FabCharactersWidget extends StatefulWidget {
  const FabCharactersWidget({super.key});
  @override
  State<FabCharactersWidget> createState() => _FabCharactersWidgetState();
}

class _FabCharactersWidgetState extends State<FabCharactersWidget>
    with TickerProviderStateMixin {

  // ── Core idle (3s loop) ──────────────────────────────
  late final AnimationController _idleCtrl;

  // ── Breathe (2s loop — subtle chest/body rise) ───────
  late final AnimationController _breathCtrl;

  // ── Blink ────────────────────────────────────────────
  late final AnimationController _blinkCtrl;
  Timer? _blinkTimer;

  // ── Eye dart ─────────────────────────────────────────
  late final AnimationController _dartCtrl;
  Offset _dartTarget = Offset.zero;
  Timer? _dartTimer;

  // ── Mood ─────────────────────────────────────────────
  ChickenMood _mood = ChickenMood.happy;
  late final AnimationController _moodCtrl;

  // ── Reaction (tap startle) ────────────────────────────
  late final AnimationController _reactCtrl;
  bool _isReacting = false;

  // ── Head nod (random idle gesture) ───────────────────
  late final AnimationController _nodCtrl;
  Timer? _nodTimer;

  // ── Wing flap (random) ────────────────────────────────
  late final AnimationController _flapCtrl;
  Timer? _flapTimer;

  final _rng = Random();

  @override
  void initState() {
    super.initState();

    _idleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat();

    _breathCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);

    _blinkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    _scheduleBlink();

    _dartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _scheduleDart();

    _moodCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))..value = 1.0;

    _reactCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _nodCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _scheduleNod();

    _flapCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _scheduleFlap();
  }

  // ── Blink: fast down, slower open ────────────────────
  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 2200 + _rng.nextInt(4500)), () async {
      await _blinkCtrl.animateTo(1.0,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeIn);
      await _blinkCtrl.animateTo(0.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut);
      // Occasional double blink
      if (_rng.nextDouble() < 0.2) {
        await Future.delayed(const Duration(milliseconds: 60));
        await _blinkCtrl.animateTo(1.0,
            duration: const Duration(milliseconds: 70), curve: Curves.easeIn);
        await _blinkCtrl.animateTo(0.0,
            duration: const Duration(milliseconds: 110), curve: Curves.easeOut);
      }
      if (mounted) _scheduleBlink();
    });
  }

  // ── Eye dart ─────────────────────────────────────────
  void _scheduleDart() {
    _dartTimer = Timer(Duration(milliseconds: 3500 + _rng.nextInt(6000)), () async {
      setState(() {
        _dartTarget = Offset(
          (_rng.nextDouble() - 0.5) * 5,
          (_rng.nextDouble() - 0.5) * 3,
        );
      });
      await _dartCtrl.animateTo(1.0, curve: Curves.easeOut);
      await Future.delayed(Duration(milliseconds: 400 + _rng.nextInt(500)));
      setState(() => _dartTarget = Offset.zero);
      await _dartCtrl.animateTo(0.0, curve: Curves.easeInOut);
      if (mounted) _scheduleDart();
    });
  }

  // ── Head nod ─────────────────────────────────────────
  void _scheduleNod() {
    _nodTimer = Timer(Duration(milliseconds: 5000 + _rng.nextInt(8000)), () async {
      await _nodCtrl.animateTo(1.0, curve: Curves.easeInOut);
      await _nodCtrl.animateTo(0.0, curve: Curves.elasticOut);
      if (mounted) _scheduleNod();
    });
  }

  // ── Wing flap ─────────────────────────────────────────
  void _scheduleFlap() {
    _flapTimer = Timer(Duration(milliseconds: 6000 + _rng.nextInt(10000)), () async {
      for (int i = 0; i < 2 + _rng.nextInt(2); i++) {
        await _flapCtrl.forward();
        await _flapCtrl.reverse();
      }
      if (mounted) _scheduleFlap();
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
    _breathCtrl.dispose();
    _blinkCtrl.dispose();
    _blinkTimer?.cancel();
    _dartCtrl.dispose();
    _dartTimer?.cancel();
    _moodCtrl.dispose();
    _reactCtrl.dispose();
    _nodCtrl.dispose();
    _nodTimer?.cancel();
    _flapCtrl.dispose();
    _flapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: triggerReaction,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _idleCtrl, _breathCtrl, _blinkCtrl, _dartCtrl,
          _moodCtrl, _reactCtrl, _nodCtrl, _flapCtrl,
        ]),
        builder: (context, _) {
          return CustomPaint(
            painter: FabCharactersPainter(
              idle: _idleCtrl.value,
              breath: _easeInOut(_breathCtrl.value),
              blink: _blinkCtrl.value,
              dartOffset: _dartTarget * _dartCtrl.value,
              mood: _mood,
              moodT: _moodCtrl.value,
              reactT: _reactCtrl.value,
              isReacting: _isReacting,
              nodT: _nodCtrl.value,
              flapT: _flapCtrl.value,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  FabCharactersPainter
// ══════════════════════════════════════════════════════════
class FabCharactersPainter extends CustomPainter {
  final double idle;
  final double breath;
  final double blink;
  final Offset dartOffset;
  final ChickenMood mood;
  final double moodT;
  final double reactT;
  final bool isReacting;
  final double nodT;
  final double flapT;

  const FabCharactersPainter({
    required this.idle,
    required this.breath,
    required this.blink,
    required this.dartOffset,
    required this.mood,
    required this.moodT,
    required this.reactT,
    required this.isReacting,
    required this.nodT,
    required this.flapT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gY = size.height * 0.78;

    // ── Chicken family (left) ──────────────────────────
    _drawChickenLips(canvas, size, gY);
    _drawDaughterNine(canvas, size, gY);
    _drawDaughterSeven(canvas, size, gY);
    _drawShihTzu(canvas, size, gY);
    _drawCatsInWindows(canvas, size, gY);

    // ── Giraffe family (right) ─────────────────────────
    _drawDadGiraffe(canvas, size, gY);
    _drawSonGiraffeOne(canvas, size, gY);
    _drawSonGiraffeTwo(canvas, size, gY);
    _drawJackRussell(canvas, size, gY);
  }

  // ════════════════════════════════════════════════════
  //  CHICKEN LIPS — star character, full Pixar treatment
  // ════════════════════════════════════════════════════
  void _drawChickenLips(Canvas canvas, Size size, double gY) {
    // Weighted walk: body shifts side-to-side with hip sway
    final walkPhase = idle * 2 * pi;
    final hipSway = sin(walkPhase) * 3.5;
    final bodySink = (1 - cos(walkPhase * 2).abs()) * 2; // dips on each step

    // Reaction bounce with proper arc
    final reactBounce = isReacting
        ? -_easeOut(sin(reactT * pi).clamp(0.0, 1.0)) * 26
        : 0.0;

    // Breathing: subtle vertical shift
    final breathShift = breath * 1.8;

    // Wander position
    final cx = size.width * 0.28 +
        sin(idle * 2 * pi * 0.3) * size.width * 0.05 + hipSway;
    final cy = gY - 2 + bodySink + reactBounce - breathShift;

    _paintChickenLips(canvas, cx: cx, cy: cy, scale: 1.4,
      footPhase: walkPhase, hipSway: hipSway,
      isMain: true);
  }

  void _drawDaughterNine(Canvas canvas, Size size, double gY) {
    final phase = idle * 2 * pi + 0.8;
    final bob = sin(phase) * 2.5;
    final cx = size.width * 0.17 + sin(idle * 2 * pi * 0.25 + 1.0) * size.width * 0.03;
    _paintChicken(canvas, cx: cx, cy: gY - 2 + bob, scale: 1.05,
      hasCrown: false, blush: FabColors.blush,
      footPhase: phase, isMain: false);
  }

  void _drawDaughterSeven(Canvas canvas, Size size, double gY) {
    final phase = idle * 2 * pi + 1.6;
    final bob = sin(phase) * 2;
    final cx = size.width * 0.36 + sin(idle * 2 * pi * 0.2 + 2.0) * size.width * 0.025;
    _paintChicken(canvas, cx: cx, cy: gY - 2 + bob, scale: 0.88,
      hasCrown: false, blush: FabColors.pink,
      footPhase: phase, isMain: false);
  }

  // ── Main character painter (Chicken Lips, full detail) ──
  void _paintChickenLips(Canvas canvas, {
    required double cx, required double cy, required double scale,
    required double footPhase, required double hipSway, required bool isMain,
  }) {
    _paintChicken(canvas,
      cx: cx, cy: cy, scale: scale,
      hasCrown: true, blush: FabColors.pink,
      footPhase: footPhase, isMain: true,
      blinkV: blink,
      dartOff: dartOffset,
      mood: mood, moodT: moodT,
      nodT: nodT, flapT: flapT,
      reactT: reactT, isReacting: isReacting,
    );
  }

  // ── Shared chicken painter ─────────────────────────────
  void _paintChicken(Canvas canvas, {
    required double cx, required double cy, required double scale,
    required bool hasCrown, required Color blush,
    required double footPhase, required bool isMain,
    double blinkV = 0,
    Offset dartOff = Offset.zero,
    ChickenMood mood = ChickenMood.happy,
    double moodT = 1,
    double nodT = 0,
    double flapT = 0,
    double reactT = 0,
    bool isReacting = false,
  }) {
    // ── Squash & stretch (Pixar rule #1) ────────────────
    // More squash on step plant, more stretch on lift
    final stepCycle = sin(footPhase * 2);
    final squash = 1.0 + sin(idle * 2 * pi) * 0.06 + stepCycle * 0.04;
    final stretch = 1.0 / squash; // volume preservation

    final bodyR = 22.0 * scale;
    final headR = 16.0 * scale;

    // Head nod: slight forward tilt on nod
    final nodAngle = nodT * 0.15;
    final headOffX = sin(nodAngle) * headR * 0.3;
    final headOffY = (1 - cos(nodAngle)) * headR * 0.2;
    final headCY = cy - bodyR - headR * 0.7 + headOffY - breath * scale;

    // ── Body ─────────────────────────────────────────────
    final bodyShader = RadialGradient(
      center: const Alignment(-0.3, -0.5),
      radius: 0.85,
      colors: [
        const Color(0xFFFFF9C4),
        FabColors.duckYellow,
        const Color(0xFFE6A800),
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(
      center: Offset(cx, cy - bodyR * 0.5), radius: bodyR,
    ));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - bodyR * 0.5),
        width: bodyR * 2 * squash,
        height: bodyR * 2 * stretch,
      ),
      Paint()..shader = bodyShader,
    );

    // Body shadow (ground contact)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - bodyR * 0.08),
        width: bodyR * 1.6 * squash,
        height: bodyR * 0.18,
      ),
      Paint()..color = const Color(0xFF1a0840).withValues(alpha: 0.25),
    );

    // ── Wings ────────────────────────────────────────────
    // Wing flap: angle changes on flapT
    final leftFlapAngle = -0.1 - flapT * 0.5;
    final rightFlapAngle = 0.1 + flapT * 0.5;

    _drawWing(canvas, cx: cx - bodyR * 0.82, cy: cy - bodyR * 0.5,
      w: bodyR * 1.15, h: bodyR * 0.62,
      angle: leftFlapAngle, scale: scale);
    _drawWing(canvas, cx: cx + bodyR * 0.82, cy: cy - bodyR * 0.5,
      w: bodyR * 1.15, h: bodyR * 0.62,
      angle: rightFlapAngle, scale: scale);

    // ── Head ─────────────────────────────────────────────
    final headShader = RadialGradient(
      center: const Alignment(-0.2, -0.4),
      radius: 0.8,
      colors: [const Color(0xFFFFF9C4), FabColors.duckYellow],
    ).createShader(Rect.fromCircle(center: Offset(cx + headOffX, headCY), radius: headR));

    canvas.drawCircle(
      Offset(cx + headOffX, headCY),
      headR,
      Paint()..shader = headShader,
    );

    // ── Crest (secondary motion — lags behind head) ──────
    for (int i = -1; i <= 1; i++) {
      // Each tuft has different lag for organic feel
      final lag = sin(idle * 2 * pi + i * 0.5) * 2.8 * scale;
      final sway = sin(idle * 2 * pi * 0.7 + i * 0.7) * 1.8 * scale;
      // Extra crest bounce on reaction
      final reactLift = isReacting ? sin(reactT * pi) * 4 * scale : 0.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            cx + headOffX + i * headR * 0.44 + sway,
            headCY - headR * 0.78 - (i == 0 ? 2.5 * scale : 0) + lag - reactLift,
          ),
          width: headR * 0.44,
          height: headR * 0.82 + lag.abs() * 0.25,
        ),
        Paint()..color = FabColors.pink,
      );
    }

    // ── Crown ────────────────────────────────────────────
    if (hasCrown) {
      final crownY = headCY - headOffY - headR * 0.88;
      // Crown sways slightly with crest
      final crownSway = sin(idle * 2 * pi * 0.7) * 1.2 * scale;

      final crownPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [FabColors.gold, const Color(0xFFE6A800)],
        ).createShader(Rect.fromLTWH(
          cx - headR * 0.6 + crownSway, crownY - headR * 0.6,
          headR * 1.2, headR * 0.7,
        ));

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx + headOffX + crownSway, crownY),
          width: headR * 1.12, height: headR * 0.44,
        ),
        crownPaint,
      );
      for (int i = -1; i <= 1; i++) {
        final px = cx + headOffX + crownSway + i * headR * 0.38;
        canvas.drawPath(
          Path()
            ..moveTo(px - headR * 0.18, crownY - headR * 0.22)
            ..lineTo(px, crownY - headR * 0.58)
            ..lineTo(px + headR * 0.18, crownY - headR * 0.22)
            ..close(),
          crownPaint,
        );
        // Gem with sparkle
        canvas.drawCircle(
          Offset(px, crownY - headR * 0.58), 3.0 * scale,
          Paint()..color = FabColors.rose,
        );
        canvas.drawCircle(
          Offset(px - 0.8 * scale, crownY - headR * 0.62), 0.9 * scale,
          Paint()..color = Colors.white.withValues(alpha: 0.8),
        );
      }
    }

    // ── Eyes ─────────────────────────────────────────────
    final eyeLX = cx + headOffX - headR * 0.35;
    final eyeRX = cx + headOffX + headR * 0.35;
    final eyeY = headCY - headR * 0.05;
    final eyeR = headR * 0.28;
    final eyeWhite = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(eyeLX, eyeY), eyeR, eyeWhite);
    canvas.drawCircle(Offset(eyeRX, eyeY), eyeR, eyeWhite);

    // Pupils with dart offset + mood dilation
    final dilate = mood == ChickenMood.excited ? 1.25 * moodT : 1.0;
    final pupilR = headR * 0.17 * dilate;
    final pLX = eyeLX + dartOff.dx * scale;
    final pRX = eyeRX + dartOff.dx * scale;
    final pY = eyeY + dartOff.dy * scale;

    final pupilPaint = Paint()..color = const Color(0xFF1A0A2E);
    canvas.drawCircle(Offset(pLX, pY), pupilR, pupilPaint);
    canvas.drawCircle(Offset(pRX, pY), pupilR, pupilPaint);

    // Eye shine (two dots per eye for depth)
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(pLX - pupilR * 0.4, pY - pupilR * 0.4), pupilR * 0.32, shinePaint);
    canvas.drawCircle(Offset(pLX + pupilR * 0.3, pY + pupilR * 0.3), pupilR * 0.18, shinePaint);
    canvas.drawCircle(Offset(pRX - pupilR * 0.4, pY - pupilR * 0.4), pupilR * 0.32, shinePaint);
    canvas.drawCircle(Offset(pRX + pupilR * 0.3, pY + pupilR * 0.3), pupilR * 0.18, shinePaint);

    // ── Blink (upper lid drops faster than lower) ────────
    if (blinkV > 0) {
      // Upper lid: full speed
      final upperLid = eyeR * 2.1 * _easeIn(blinkV);
      // Lower lid: rises 30% as much, slower
      final lowerLid = eyeR * 0.6 * _easeOut(blinkV);
      final lidPaint = Paint()..color = FabColors.duckYellow;

      for (final ex in [eyeLX, eyeRX]) {
        // Upper
        canvas.drawRect(
          Rect.fromLTWH(ex - eyeR, eyeY - eyeR, eyeR * 2, upperLid),
          lidPaint,
        );
        // Lower
        canvas.drawRect(
          Rect.fromLTWH(ex - eyeR, eyeY + eyeR - lowerLid, eyeR * 2, lowerLid),
          lidPaint,
        );
      }
    }

    // Sleepy half-lid
    if (mood == ChickenMood.sleepy && moodT > 0) {
      final sleepLid = eyeR * 1.15 * _easeInOut(moodT);
      final sleepPaint = Paint()..color = FabColors.duckYellow;
      for (final ex in [eyeLX, eyeRX]) {
        canvas.drawRect(
          Rect.fromLTWH(ex - eyeR, eyeY - eyeR, eyeR * 2, sleepLid),
          sleepPaint,
        );
      }
    }

    // ── Lashes ───────────────────────────────────────────
    final lashPaint = Paint()
      ..color = const Color(0xFF1A0A2E)
      ..strokeWidth = 1.6 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Mood lash angle: grumpy = angled down-in, excited = wide up
    final la = mood == ChickenMood.grumpy
        ? 0.28 * moodT
        : mood == ChickenMood.excited ? -0.18 * moodT : 0.0;
    final hcx = cx + headOffX;

    canvas.drawLine(
      Offset(hcx - headR * 0.46, headCY - headR * 0.26),
      Offset(hcx - headR * 0.56 + la * headR, headCY - headR * 0.44), lashPaint);
    canvas.drawLine(
      Offset(hcx - headR * 0.32, headCY - headR * 0.31),
      Offset(hcx - headR * 0.36 + la * headR * 0.5, headCY - headR * 0.50), lashPaint);
    canvas.drawLine(
      Offset(hcx + headR * 0.32, headCY - headR * 0.31),
      Offset(hcx + headR * 0.36 - la * headR * 0.5, headCY - headR * 0.50), lashPaint);
    canvas.drawLine(
      Offset(hcx + headR * 0.46, headCY - headR * 0.26),
      Offset(hcx + headR * 0.56 - la * headR, headCY - headR * 0.44), lashPaint);

    // ── Blush ────────────────────────────────────────────
    final blushPaint = Paint()..color = blush.withValues(alpha: 0.42);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(hcx - headR * 0.56, headCY + headR * 0.12),
        width: headR * 0.52, height: headR * 0.26,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(hcx + headR * 0.56, headCY + headR * 0.12),
        width: headR * 0.52, height: headR * 0.26,
      ),
      blushPaint,
    );

    // ── Beak ─────────────────────────────────────────────
    // Excited = slightly open, grumpy = pursed
    final beakH = mood == ChickenMood.excited
        ? headR * 0.36 * (1 + 0.28 * moodT)
        : mood == ChickenMood.grumpy
            ? headR * 0.24
            : headR * 0.30;

    final beakShader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [FabColors.duckOrange, const Color(0xFFD4860A)],
    ).createShader(Rect.fromCenter(
      center: Offset(hcx, headCY + headR * 0.38),
      width: headR * 0.56, height: beakH,
    ));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(hcx, headCY + headR * 0.38),
        width: headR * 0.56, height: beakH,
      ),
      Paint()..shader = beakShader,
    );

    // Beak highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(hcx - headR * 0.06, headCY + headR * 0.32),
        width: headR * 0.22, height: headR * 0.08,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );

    // ── Feet (alternating with lift + squash on plant) ───
    final footY = cy - bodyR * 0.08;
    final leftLift = max(0.0, sin(footPhase) * 7 * scale);
    final rightLift = max(0.0, sin(footPhase + pi) * 7 * scale);

    // Foot squash when planted (wider, shorter)
    final leftSquash = leftLift < 0.5 ? 1.0 + (1 - leftLift / (7 * scale)).clamp(0, 1) * 0.3 : 1.0;
    final rightSquash = rightLift < 0.5 ? 1.0 + (1 - rightLift / (7 * scale)).clamp(0, 1) * 0.3 : 1.0;

    final footPaint = Paint()
      ..color = FabColors.duckOrange
      ..strokeWidth = 3.0 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left leg
    canvas.drawLine(
      Offset(cx - 6 * scale, footY),
      Offset(cx - 9 * scale * leftSquash, footY + 12 * scale - leftLift),
      footPaint,
    );
    // Right leg
    canvas.drawLine(
      Offset(cx + 6 * scale, footY),
      Offset(cx + 9 * scale * rightSquash, footY + 12 * scale - rightLift),
      footPaint,
    );

    // ── Reaction sparkles ────────────────────────────────
    if (isReacting && reactT > 0) {
      final fade = 1 - _easeOut(reactT);
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * pi - pi / 2;
        final dist = 32 * scale * _easeOut(reactT);
        final sx = cx + cos(angle) * dist;
        final sy = (headCY - headR * 1.1) + sin(angle) * dist;
        final starSize = (5 + (i % 3) * 2) * scale * fade;

        canvas.drawCircle(
          Offset(sx, sy),
          starSize,
          Paint()..color = (i % 2 == 0 ? FabColors.gold : FabColors.pink)
              .withValues(alpha: fade * 0.9),
        );
        // Star rays
        canvas.drawLine(
          Offset(sx, sy),
          Offset(sx + cos(angle) * starSize * 2, sy + sin(angle) * starSize * 2),
          Paint()
            ..color = FabColors.gold.withValues(alpha: fade * 0.6)
            ..strokeWidth = 1.5 * scale
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  // ── Wing helper ───────────────────────────────────────
  void _drawWing(Canvas canvas, {
    required double cx, required double cy,
    required double w, required double h,
    required double angle, required double scale,
  }) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      Paint()..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [FabColors.gold, const Color(0xFFD4A800)],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: w, height: h)),
    );
    canvas.restore();
  }

  // ════════════════════════════════════════════════════
  //  SHIH TZU
  // ════════════════════════════════════════════════════
  void _drawShihTzu(Canvas canvas, Size size, double gY) {
    final trot = sin(idle * 2 * pi * 0.4) * 3;
    final x = size.width * 0.10 + sin(idle * 2 * pi * 0.15) * size.width * 0.025;
    final y = gY + trot;
    const s = 0.95;

    final white = Paint()..color = const Color(0xFFf5f0e8);
    final tan = Paint()..color = const Color(0xFFd4a96a);

    canvas.drawOval(Rect.fromCenter(
      center: Offset(x, y - 12 * s), width: 34 * s, height: 22 * s), white);
    canvas.drawCircle(Offset(x + 14 * s, y - 16 * s), 12 * s, white);
    canvas.drawCircle(Offset(x + 14 * s, y - 14 * s), 8 * s, tan);
    canvas.drawOval(Rect.fromCenter(
      center: Offset(x + 8 * s, y - 24 * s), width: 8 * s, height: 14 * s), tan);
    canvas.drawOval(Rect.fromCenter(
      center: Offset(x + 20 * s, y - 24 * s), width: 8 * s, height: 14 * s), tan);
    canvas.drawCircle(Offset(x + 11 * s, y - 16 * s), 2.5 * s,
      Paint()..color = const Color(0xFF1a0a2e));
    canvas.drawCircle(Offset(x + 18 * s, y - 16 * s), 2.5 * s,
      Paint()..color = const Color(0xFF1a0a2e));
    canvas.drawOval(Rect.fromCenter(
      center: Offset(x + 14 * s, y - 11 * s), width: 5 * s, height: 3 * s),
      Paint()..color = const Color(0xFF333333));

    final legP = Paint()
      ..color = const Color(0xFFf5f0e8)
      ..strokeWidth = 4 * s ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    final phase = idle * 2 * pi;
    canvas.drawLine(Offset(x - 6 * s, y - 4 * s),
      Offset(x - 7 * s + sin(phase) * 4 * s, y + 8 * s), legP);
    canvas.drawLine(Offset(x + 2 * s, y - 4 * s),
      Offset(x + 3 * s + sin(phase + pi) * 4 * s, y + 8 * s), legP);
    canvas.drawLine(Offset(x + 10 * s, y - 4 * s),
      Offset(x + 11 * s + sin(phase) * 4 * s, y + 8 * s), legP);
  }

  // ════════════════════════════════════════════════════
  //  CATS IN WINDOWS
  // ════════════════════════════════════════════════════
  void _drawCatsInWindows(Canvas canvas, Size size, double gY) {
    final cx = size.width * 0.22;
    _drawCat(canvas, Offset(cx - 36, gY - 65), true);
    _drawCat(canvas, Offset(cx + 24, gY - 65), false);
  }

  void _drawCat(Canvas canvas, Offset wp, bool left) {
    final x = wp.dx + 12;
    final y = wp.dy + 10;
    const s = 0.55;

    // Slow tail sway
    final tailSway = sin(idle * 2 * pi * 0.4 + (left ? 0 : 1.2)) * 6 * s;
    // Occasional slow blink (independent of chicken blink)
    final catBlink = (sin(idle * 2 * pi * 0.15 + (left ? 0 : 2.0)) > 0.92) ? 0.7 : 0.0;

    final dark = Paint()..color = const Color(0xFF1a1a2e);
    final white = Paint()..color = const Color(0xFFf0f0f0);

    canvas.drawOval(Rect.fromCenter(
      center: Offset(x, y + 6 * s), width: 18 * s, height: 14 * s), dark);
    canvas.drawCircle(Offset(x, y - 4 * s), 9 * s, dark);
    canvas.drawOval(Rect.fromCenter(
      center: Offset(x, y + 4 * s), width: 8 * s, height: 7 * s), white);

    for (final ear in [
      Path()..moveTo(x-7*s,y-10*s)..lineTo(x-10*s,y-17*s)..lineTo(x-3*s,y-12*s)..close(),
      Path()..moveTo(x+7*s,y-10*s)..lineTo(x+10*s,y-17*s)..lineTo(x+3*s,y-12*s)..close(),
    ]) {
      canvas.drawPath(ear, dark);
    }

    // Eyes (with cat blink)
    if (catBlink < 0.5) {
      for (final ex in [-3.5*s, 3.5*s]) {
        canvas.drawOval(Rect.fromCenter(
          center: Offset(x + ex, y - 4 * s), width: 5 * s, height: 4 * s),
          Paint()..color = const Color(0xFF7FDD77));
        canvas.drawOval(Rect.fromCenter(
          center: Offset(x + ex, y - 4 * s), width: 2 * s, height: 3.5 * s),
          Paint()..color = const Color(0xFF1a0a2e));
      }
    } else {
      // Blink line
      final blinkP = Paint()
        ..color = const Color(0xFF1a1a2e)
        ..strokeWidth = 1.5 * s ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(x - 6*s, y - 4*s), Offset(x - 1*s, y - 4*s), blinkP);
      canvas.drawLine(Offset(x + 1*s, y - 4*s), Offset(x + 6*s, y - 4*s), blinkP);
    }

    canvas.drawCircle(Offset(x, y - 1*s), 1.5*s, Paint()..color = FabColors.pink);

    // Tail with physics sway
    canvas.drawPath(
      Path()
        ..moveTo(x + (left ? -8 : 8)*s, y + 8*s)
        ..quadraticBezierTo(
          x + (left ? -18 : 18)*s + tailSway, y + 12*s,
          x + (left ? -14 : 14)*s + tailSway * 0.5, y + 2*s,
        ),
      Paint()
        ..color = const Color(0xFF1a1a2e)
        ..strokeWidth = 3*s ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke,
    );
  }

  // ════════════════════════════════════════════════════
  //  GIRAFFE FAMILY
  // ════════════════════════════════════════════════════
  void _drawDadGiraffe(Canvas canvas, Size size, double gY) {
    final bob = sin(idle * 2 * pi * 0.4) * 2;
    final cx = size.width * 0.72 + sin(idle * 2 * pi * 0.22) * size.width * 0.04;
    _paintGiraffe(canvas, cx: cx, cy: gY + bob, scale: 1.3,
      footPhase: idle * 2 * pi);
  }

  void _drawSonGiraffeOne(Canvas canvas, Size size, double gY) {
    final bob = sin(idle * 2 * pi * 0.35 + 1.0) * 2;
    final cx = size.width * 0.84 + sin(idle * 2 * pi * 0.18 + 0.5) * size.width * 0.03;
    _paintGiraffe(canvas, cx: cx, cy: gY + bob, scale: 0.95,
      footPhase: idle * 2 * pi + 1.0);
  }

  void _drawSonGiraffeTwo(Canvas canvas, Size size, double gY) {
    final bob = sin(idle * 2 * pi * 0.3 + 2.0) * 1.5;
    final cx = size.width * 0.91 + sin(idle * 2 * pi * 0.15 + 1.5) * size.width * 0.025;
    _paintGiraffe(canvas, cx: cx, cy: gY + bob, scale: 0.78,
      footPhase: idle * 2 * pi + 2.0);
  }

  void _paintGiraffe(Canvas canvas, {
    required double cx, required double cy,
    required double scale, required double footPhase,
  }) {
    const bodyC = Color(0xFFe8b84b);
    const patchC = Color(0xFF8b5e1a);

    final bodyP = Paint()..color = bodyC;
    final patchP = Paint()..color = patchC.withValues(alpha: 0.72);
    final legP = Paint()
      ..color = bodyC ..strokeWidth = 7*scale ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    final hoofP = Paint()
      ..color = const Color(0xFF5a3a0a) ..strokeWidth = 7*scale ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;

    final sw = sin(footPhase) * 6 * scale;
    final swB = sin(footPhase + pi) * 6 * scale;
    final legBaseY = cy - 8 * scale;
    final legBotY = cy + 38 * scale;

    // Legs
    for (final pair in [
      [cx + 10*scale, swB], [cx + 2*scale, sw],
      [cx - 10*scale, sw], [cx - 2*scale, swB],
    ]) {
      final lx = pair[0]; final s = pair[1];
      canvas.drawLine(Offset(lx, legBaseY), Offset(lx + s, legBotY), legP);
      canvas.drawLine(Offset(lx, legBaseY), Offset(lx + s, legBotY + 4*scale), hoofP);
    }

    // Body
    canvas.drawOval(Rect.fromCenter(
      center: Offset(cx, cy - 20*scale), width: 36*scale, height: 28*scale), bodyP);
    for (int i = 0; i < 3; i++) {
      canvas.drawOval(Rect.fromCenter(
        center: Offset(cx + (i-1)*10*scale, cy - 18*scale + (i%2)*6*scale),
        width: 8*scale, height: 6*scale), patchP);
    }

    // Neck with gentle sway
    final neckSway = sin(idle * 2 * pi * 0.5) * 2 * scale;
    canvas.drawPath(
      Path()
        ..moveTo(cx - 5*scale, cy - 32*scale)
        ..lineTo(cx + 5*scale, cy - 32*scale)
        ..lineTo(cx + 3*scale + neckSway, cy - 65*scale)
        ..lineTo(cx - 3*scale + neckSway, cy - 65*scale)
        ..close(),
      bodyP,
    );

    // Neck patches
    canvas.drawOval(Rect.fromCenter(
      center: Offset(cx + neckSway*0.5, cy - 45*scale), width: 6*scale, height: 5*scale), patchP);
    canvas.drawOval(Rect.fromCenter(
      center: Offset(cx + neckSway*0.8, cy - 56*scale), width: 5*scale, height: 4*scale), patchP);

    // Head
    final headR = 10.0 * scale;
    final headCY = cy - 72*scale;
    final headCX = cx + neckSway;
    canvas.drawOval(Rect.fromCenter(
      center: Offset(headCX, headCY), width: headR*2.2, height: headR*1.8), bodyP);

    // Ossicones
    final hornP = Paint()..color = const Color(0xFFc4952a);
    for (final hx in [headCX - headR*0.4, headCX + headR*0.4]) {
      canvas.drawOval(Rect.fromCenter(
        center: Offset(hx, headCY - headR*0.8), width: 4*scale, height: 9*scale), hornP);
      canvas.drawCircle(Offset(hx, headCY - headR*1.2), 3*scale, hornP);
    }

    // Eyes
    for (final ex in [headCX - headR*0.35, headCX + headR*0.35]) {
      canvas.drawCircle(Offset(ex, headCY - headR*0.1), headR*0.22,
        Paint()..color = Colors.white);
    }
    canvas.drawCircle(Offset(headCX - headR*0.32, headCY - headR*0.08), headR*0.13,
      Paint()..color = const Color(0xFF1a0a2e));
    canvas.drawCircle(Offset(headCX + headR*0.38, headCY - headR*0.08), headR*0.13,
      Paint()..color = const Color(0xFF1a0a2e));
    // Shine
    canvas.drawCircle(Offset(headCX - headR*0.28, headCY - headR*0.12), headR*0.05,
      Paint()..color = Colors.white);
    canvas.drawCircle(Offset(headCX + headR*0.42, headCY - headR*0.12), headR*0.05,
      Paint()..color = Colors.white);

    // Snout
    canvas.drawOval(Rect.fromCenter(
      center: Offset(headCX, headCY + headR*0.4), width: headR*0.9, height: headR*0.45),
      Paint()..color = const Color(0xFFd4a060));
    for (final nx in [headCX - headR*0.2, headCX + headR*0.2]) {
      canvas.drawOval(Rect.fromCenter(
        center: Offset(nx, headCY + headR*0.42), width: headR*0.16, height: headR*0.1),
        Paint()..color = patchC.withValues(alpha: 0.5));
    }

    // Mane
    final maneP = Paint()
      ..color = patchC.withValues(alpha: 0.85)
      ..strokeWidth = 3*scale ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    for (int i = 0; i < 4; i++) {
      final mY = cy - 37*scale - i*8*scale;
      final ms = sin(idle * 2 * pi + i * 0.6) * 2.5 * scale;
      canvas.drawLine(
        Offset(cx - 2*scale + neckSway*0.6, mY),
        Offset(cx - 7*scale + ms + neckSway*0.4, mY - 8*scale), maneP);
    }

    // Tail with spring physics
    final tailSwing = sin(idle * 2 * pi * 0.6) * 9 * scale;
    canvas.drawPath(
      Path()
        ..moveTo(cx + 16*scale, cy - 22*scale)
        ..quadraticBezierTo(
          cx + 30*scale, cy - 8*scale,
          cx + 24*scale + tailSwing, cy + 6*scale),
      Paint()
        ..color = bodyC ..strokeWidth = 3*scale ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(cx + 24*scale + tailSwing, cy + 6*scale),
      4.5*scale, patchP);
  }

  // ════════════════════════════════════════════════════
  //  JACK RUSSELL
  // ════════════════════════════════════════════════════
  void _drawJackRussell(Canvas canvas, Size size, double gY) {
    final trot = sin(idle * 2 * pi * 0.5) * 3;
    final x = size.width * 0.96 + sin(idle * 2 * pi * 0.2) * size.width * 0.02;
    final y = gY + trot;
    const s = 0.85;

    canvas.drawOval(Rect.fromCenter(
      center: Offset(x, y - 10*s), width: 28*s, height: 18*s),
      Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(
      center: Offset(x + 5*s, y - 12*s), width: 14*s, height: 10*s),
      Paint()..color = const Color(0xFF8b5e1a));
    canvas.drawCircle(Offset(x + 12*s, y - 16*s), 10*s, Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(
      center: Offset(x + 14*s, y - 19*s), width: 10*s, height: 8*s),
      Paint()..color = const Color(0xFF8b5e1a));

    // Ears with flop physics
    final earFlop = sin(idle * 2 * pi * 0.5) * 2 * s;
    canvas.drawOval(Rect.fromCenter(
      center: Offset(x + 6*s, y - 22*s + earFlop), width: 7*s, height: 11*s),
      Paint()..color = const Color(0xFF8b5e1a));
    canvas.drawOval(Rect.fromCenter(
      center: Offset(x + 17*s, y - 22*s + earFlop*0.7), width: 6*s, height: 10*s),
      Paint()..color = const Color(0xFF8b5e1a));

    // Eyes with shine
    canvas.drawCircle(Offset(x + 10*s, y - 16*s), 2*s, Paint()..color = const Color(0xFF1a0a2e));
    canvas.drawCircle(Offset(x + 15*s, y - 16*s), 2*s, Paint()..color = const Color(0xFF1a0a2e));
    canvas.drawCircle(Offset(x + 10.6*s, y - 16.6*s), 0.7*s, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(x + 15.6*s, y - 16.6*s), 0.7*s, Paint()..color = Colors.white);

    canvas.drawOval(Rect.fromCenter(
      center: Offset(x + 12*s, y - 11*s), width: 4*s, height: 3*s),
      Paint()..color = const Color(0xFF333333));

    final legP = Paint()
      ..color = Colors.white ..strokeWidth = 3.5*s ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    final phase = idle * 2 * pi;
    canvas.drawLine(Offset(x - 4*s, y - 2*s),
      Offset(x - 5*s + sin(phase)*4*s, y + 8*s), legP);
    canvas.drawLine(Offset(x + 4*s, y - 2*s),
      Offset(x + 5*s + sin(phase + pi)*4*s, y + 8*s), legP);
    canvas.drawLine(Offset(x + 10*s, y - 2*s),
      Offset(x + 11*s + sin(phase)*4*s, y + 8*s), legP);

    // Fast wagging tail (spring physics)
    final tailWag = sin(idle * 2 * pi * 3.5) * 10 * s +
        sin(idle * 2 * pi * 7) * 3 * s; // harmonic for organic feel
    canvas.drawLine(
      Offset(x - 8*s, y - 10*s),
      Offset(x - 15*s + tailWag, y - 21*s),
      Paint()..color = Colors.white ..strokeWidth = 3*s ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(FabCharactersPainter old) =>
    old.idle != idle || old.breath != breath ||
    old.blink != blink || old.dartOffset != dartOffset ||
    old.mood != mood || old.moodT != moodT ||
    old.reactT != reactT || old.isReacting != isReacting ||
    old.nodT != nodT || old.flapT != flapT;
}
