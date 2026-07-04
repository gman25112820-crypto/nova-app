import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// SleepySlothWidget
//
// Two sloths tucked up in bed, snoring Zzz bubbles rising.
// 10-second repeating loop animation. Pure Flutter, no assets.
// ─────────────────────────────────────────────────────────────

class SleepySlothWidget extends StatefulWidget {
  const SleepySlothWidget({super.key});

  @override
  State<SleepySlothWidget> createState() => _SleepySlothWidgetState();
}

class _SleepySlothWidgetState extends State<SleepySlothWidget>
    with TickerProviderStateMixin {
  late final AnimationController _loop;
  // Z bubbles for left sloth (offset 0) and right sloth (offset 0.5)
  late final List<Animation<double>> _zOpacity;
  late final List<Animation<double>> _zSlide;
  late final Animation<double> _bedBob;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Three Z bubbles per sloth, staggered
    _zOpacity = List.generate(6, (i) {
      final start = (i ~/ 3) * 0.5 + (i % 3) * 0.13;
      final end   = (start + 0.28).clamp(0.0, 1.0);
      return TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 70),
      ]).animate(CurvedAnimation(
        parent: _loop,
        curve: Interval(start, end, curve: Curves.easeInOut),
      ));
    });

    _zSlide = List.generate(6, (i) {
      final start = (i ~/ 3) * 0.5 + (i % 3) * 0.13;
      final end   = (start + 0.28).clamp(0.0, 1.0);
      return Tween(begin: 0.0, end: -28.0 - (i % 3) * 10).animate(
        CurvedAnimation(
          parent: _loop,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _bedBob = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loop, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  Widget _zBubble(int zIdx, double left, double baseTop, String letter) {
    return AnimatedBuilder(
      animation: _loop,
      builder: (_, __) => Positioned(
        left: left,
        top: baseTop + _zSlide[zIdx].value,
        child: Opacity(
          opacity: _zOpacity[zIdx].value.clamp(0.0, 1.0),
          child: Text(
            letter,
            style: TextStyle(
              color: const Color(0xFF9B8FFF),
              fontSize: 14.0 + (zIdx % 3) * 3,
              fontWeight: FontWeight.w800,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      return Stack(
        children: [
          // Night-sky background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF050C2E), Color(0xFF0A0A1A)],
              ),
            ),
          ),
          // Stars
          ...List.generate(18, (i) {
            final rng = math.Random(i * 137);
            return Positioned(
              left: rng.nextDouble() * w,
              top: rng.nextDouble() * h * 0.55,
              child: AnimatedBuilder(
                animation: _bedBob,
                builder: (_, __) => Opacity(
                  opacity: 0.3 +
                      0.5 *
                          math.sin((_bedBob.value * math.pi * 2) +
                              i * 0.7),
                  child: Container(
                    width: 2, height: 2,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
          // Moon
          Positioned(
            top: h * 0.05,
            right: w * 0.12,
            child: const Text('🌙', style: TextStyle(fontSize: 36)),
          ),
          // Bed frame
          Positioned(
            bottom: h * 0.08,
            left: w * 0.05,
            right: w * 0.05,
            child: AnimatedBuilder(
              animation: _bedBob,
              builder: (_, child) => Transform.translate(
                offset: Offset(0,
                    math.sin(_bedBob.value * math.pi * 2) * 2),
                child: child,
              ),
              child: _BedPainting(width: w * 0.90),
            ),
          ),
          // Left sloth
          Positioned(
            bottom: h * 0.22,
            left: w * 0.14,
            child: const Text('🦥', style: TextStyle(fontSize: 44)),
          ),
          // Right sloth
          Positioned(
            bottom: h * 0.22,
            right: w * 0.14,
            child: const Text('🦥', style: TextStyle(fontSize: 44)),
          ),
          // Z bubbles — left sloth
          _zBubble(0, w * 0.20, h * 0.40, 'z'),
          _zBubble(1, w * 0.25, h * 0.32, 'Z'),
          _zBubble(2, w * 0.30, h * 0.24, 'Z'),
          // Z bubbles — right sloth
          _zBubble(3, w * 0.60, h * 0.40, 'z'),
          _zBubble(4, w * 0.66, h * 0.32, 'Z'),
          _zBubble(5, w * 0.72, h * 0.24, 'Z'),
          // Label
          Positioned(
            bottom: h * 0.02,
            left: 0, right: 0,
            child: const Text(
              '💤  Sweet dreams, sleepyhead…',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9B8FFF),
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ── Bed painting ───────────────────────────────────────────────

class _BedPainting extends StatelessWidget {
  final double width;
  const _BedPainting({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3D2B6E), Color(0xFF251840)],
        ),
        border: Border.all(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.50),
            width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.30),
            blurRadius: 20,
          ),
        ],
      ),
      child: const Center(
        child: Text('🛏️', style: TextStyle(fontSize: 48)),
      ),
    );
  }
}
