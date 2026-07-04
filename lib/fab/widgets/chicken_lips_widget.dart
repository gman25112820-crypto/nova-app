

import 'dart:math';
import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────
//  MISS CHICKEN LIPS — North Star Edition  v3.0
//  Reference-accurate 3D fluffy nurse chicken
//
//  Usage:
//    ChickenLipsWidget(mood: ChickenMood.happy, scale: 1.0)
//
//  Moods: happy · sad · worried · proud · crowned · sleeping · wink
// ──────────────────────────────────────────────────────────

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
