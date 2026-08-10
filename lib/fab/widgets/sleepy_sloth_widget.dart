import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// SleepySlothWidget
//
// Sleepy the sloth and Saffi the fox, tucked up in bed together,
// snoring Zzz bubbles rising. 10-second repeating loop animation.
// Reached via BedtimeSceneScreen from Sleep Den's AppBar.
// ─────────────────────────────────────────────────────────────

class SleepySlothWidget extends StatefulWidget {
  final bool showBackground;

  const SleepySlothWidget({super.key, this.showBackground = true});

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
      final end = (start + 0.28).clamp(0.0, 1.0);
      return TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 70),
      ]).animate(
        CurvedAnimation(
          parent: _loop,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });

    _zSlide = List.generate(6, (i) {
      final start = (i ~/ 3) * 0.5 + (i % 3) * 0.13;
      final end = (start + 0.28).clamp(0.0, 1.0);
      return Tween(begin: 0.0, end: -28.0 - (i % 3) * 10).animate(
        CurvedAnimation(
          parent: _loop,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _bedBob = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _loop, curve: Curves.linear));
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
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = math.min(constraints.maxWidth, 900.0);
          final h = constraints.maxHeight;
          final bedHeight = (h * 0.12).clamp(56.0, 100.0);
          final portraitWidth = math.min(96.0, w * 0.18);

          return SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                // Underground cave-wall background for the Sleepy & Saffi nest.
                if (widget.showBackground) const _SleepNestCaveBackground(),
                // Soft cave-star glimmers
                ...List.generate(18, (i) {
                  final rng = math.Random(i * 137);
                  return Positioned(
                    left: rng.nextDouble() * w,
                    top: rng.nextDouble() * h * 0.55,
                    child: AnimatedBuilder(
                      animation: _bedBob,
                      builder: (_, __) => Opacity(
                        opacity:
                            (0.3 +
                                    0.5 *
                                        math.sin(
                                          (_bedBob.value * math.pi * 2) +
                                              i * 0.7,
                                        ))
                                .clamp(0.0, 1.0),
                        child: Container(
                          width: 2,
                          height: 2,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF7EA),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Lantern-lit crystal niche set into the cave wall.
                Positioned(
                  top: h * 0.03,
                  right: w * 0.035,
                  child: const _SleepCrystalNiche(),
                ),
                // Bed frame
                Positioned(
                  bottom: h * 0.08,
                  left: w * 0.05,
                  right: w * 0.05,
                  child: AnimatedBuilder(
                    animation: _bedBob,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(
                        0,
                        math.sin(_bedBob.value * math.pi * 2) * 2,
                      ),
                      child: child,
                    ),
                    child: _BedPainting(width: w * 0.90, height: bedHeight),
                  ),
                ),
                // Sleepy the sloth
                Positioned(
                  bottom: h * 0.18,
                  left: w * 0.06,
                  child: Image.asset(
                    'assets/images/characters/sloth.png',
                    width: portraitWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                // Saffi the fox
                Positioned(
                  bottom: h * 0.18,
                  right: w * 0.06,
                  child: Image.asset(
                    'assets/images/characters/fox.png',
                    width: portraitWidth,
                    fit: BoxFit.contain,
                  ),
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
                  left: 0,
                  right: 0,
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
            ),
          );
        },
      ),
    );
  }
}

class _SleepNestCaveBackground extends StatelessWidget {
  const _SleepNestCaveBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF211334), Color(0xFF130D24), Color(0xFF090817)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.72, -0.52),
              radius: 0.82,
              colors: [
                const Color(0xFF8FCBFF).withValues(alpha: 0.18),
                const Color(0xFF7C6AF5).withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Positioned(
          left: -60,
          right: -60,
          top: -36,
          height: 156,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF2A1A38).withValues(alpha: 0.72),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(110),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          top: -8,
          left: 70,
          child: _RootStrand(height: 92, tilt: -0.20),
        ),
        const Positioned(
          top: -10,
          right: 330,
          child: _RootStrand(height: 78, tilt: 0.16),
        ),
        const Positioned(
          top: -6,
          right: 150,
          child: _RootStrand(height: 112, tilt: -0.08),
        ),
        Positioned(
          left: 34,
          top: 80,
          child: _MoonstonePebble(size: 34, color: const Color(0xFF3A2D4A)),
        ),
        Positioned(
          right: 78,
          top: 74,
          child: _MoonstonePebble(size: 28, color: const Color(0xFF4A365D)),
        ),
        Positioned(
          right: 210,
          top: 132,
          child: _MoonstonePebble(size: 18, color: const Color(0xFF5F4A78)),
        ),
      ],
    );
  }
}

class _SleepCrystalNiche extends StatelessWidget {
  const _SleepCrystalNiche();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 218,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(98),
                gradient: RadialGradient(
                  center: const Alignment(-0.06, -0.12),
                  radius: 0.76,
                  colors: [
                    const Color(0xFFDCD7FF).withValues(alpha: 0.28),
                    const Color(0xFF6F63C8).withValues(alpha: 0.24),
                    const Color(0xFF1B1430).withValues(alpha: 0.92),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9B8FFF).withValues(alpha: 0.24),
                    blurRadius: 38,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.34),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 12,
            top: 10,
            bottom: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF261C3A).withValues(alpha: 0.96),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(92),
                  topRight: Radius.circular(84),
                  bottomLeft: Radius.circular(44),
                  bottomRight: Radius.circular(48),
                ),
                border: Border.all(
                  color: const Color(0xFFC7A0FF).withValues(alpha: 0.36),
                  width: 3,
                ),
              ),
            ),
          ),
          Positioned(
            left: 38,
            right: 36,
            top: 34,
            bottom: 26,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(66),
                gradient: RadialGradient(
                  center: const Alignment(0.05, -0.20),
                  radius: 0.70,
                  colors: [
                    const Color(0xFFE5E0FF).withValues(alpha: 0.34),
                    const Color(0xFF88C9FF).withValues(alpha: 0.16),
                    const Color(0xFF181226).withValues(alpha: 0.90),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 48,
            child: _RootStrand(height: 72, tilt: -0.20),
          ),
          const Positioned(
            top: -2,
            left: 118,
            child: _RootStrand(height: 90, tilt: 0.06),
          ),
          const Positioned(
            top: 4,
            right: 42,
            child: _RootStrand(height: 78, tilt: 0.20),
          ),
          Positioned(
            left: 18,
            top: 54,
            child: _MoonstonePebble(size: 22, color: const Color(0xFF554169)),
          ),
          Positioned(
            right: 20,
            top: 74,
            child: _MoonstonePebble(size: 18, color: const Color(0xFF6D5681)),
          ),
          Positioned(
            left: 32,
            bottom: 34,
            child: _MoonstonePebble(size: 28, color: const Color(0xFF3C2F52)),
          ),
          Positioned(
            right: 36,
            bottom: 28,
            child: _MoonstonePebble(size: 24, color: const Color(0xFF4A3B62)),
          ),
          Positioned(
            bottom: 34,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _CrystalShard(height: 70, width: 30, color: Color(0xFF86E8FF)),
                SizedBox(width: 5),
                _CrystalShard(height: 106, width: 38, color: Color(0xFFE1D9FF)),
                SizedBox(width: 5),
                _CrystalShard(height: 82, width: 32, color: Color(0xFF9B8FFF)),
                SizedBox(width: 5),
                _CrystalShard(height: 58, width: 24, color: Color(0xFFFFD68A)),
              ],
            ),
          ),
          const Positioned(
            left: 44,
            top: 92,
            child: _WarmLight(size: 8, opacity: 0.70),
          ),
          const Positioned(
            right: 48,
            top: 82,
            child: _WarmLight(size: 9, opacity: 0.76),
          ),
          const Positioned(
            right: 68,
            bottom: 58,
            child: _WarmLight(size: 6, opacity: 0.58),
          ),
          const Positioned(
            left: 84,
            bottom: 70,
            child: _WarmLight(size: 5, opacity: 0.50),
          ),
          const Positioned(left: 70, top: 44, child: _CrystalSpeck()),
          const Positioned(right: 76, top: 48, child: _CrystalSpeck()),
          const Positioned(left: 58, bottom: 86, child: _CrystalSpeck()),
          const Positioned(right: 92, bottom: 42, child: _CrystalSpeck()),
        ],
      ),
    );
  }
}

class _MoonstonePebble extends StatelessWidget {
  final double size;
  final Color color;

  const _MoonstonePebble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(
          color: const Color(0xFFDCCFFF).withValues(alpha: 0.16),
        ),
      ),
    );
  }
}

class _CrystalSpeck extends StatelessWidget {
  const _CrystalSpeck();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.78,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E0FF).withValues(alpha: 0.72),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF86E8FF).withValues(alpha: 0.32),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _RootStrand extends StatelessWidget {
  final double height;
  final double tilt;

  const _RootStrand({required this.height, required this.tilt});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt,
      child: Container(
        width: 3,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF6E5237).withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _CrystalShard extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const _CrystalShard({
    required this.height,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.36), blurRadius: 16),
        ],
      ),
    );
  }
}

class _WarmLight extends StatelessWidget {
  final double size;
  final double opacity;

  const _WarmLight({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD68A).withValues(alpha: opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD68A).withValues(alpha: opacity * 0.55),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}
// ── Bed painting ───────────────────────────────────────────────

class _BedPainting extends StatelessWidget {
  final double width;
  final double height;
  const _BedPainting({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6E529C), Color(0xFF30204F)],
        ),
        border: Border.all(
          color: const Color(0xFFC7A0FF).withValues(alpha: 0.48),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC7A0FF).withValues(alpha: 0.26),
            blurRadius: 20,
          ),
        ],
      ),
      child: const Center(child: Text('🛏️', style: TextStyle(fontSize: 48))),
    );
  }
}
