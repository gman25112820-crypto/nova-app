import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// ─────────────────────────────────────────────────────────────
// SleepNestScreen
//
// Full-screen experience: animated MP4 background with Flutter
// star + breathing-orb overlays and a back button.
// Fallback to painted gradient if video fails to load.
// ─────────────────────────────────────────────────────────────

class SleepNestScreen extends StatefulWidget {
  const SleepNestScreen({super.key});

  @override
  State<SleepNestScreen> createState() => _SleepNestScreenState();
}

class _SleepNestScreenState extends State<SleepNestScreen>
    with TickerProviderStateMixin {

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  late final AnimationController _starCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _breathCtrl;

  static const _purple = Color(0xFF7C6AF5);
  static const _text   = Color(0xFFE8D8FF);
  static const _muted  = Color(0xFF9B8EC4);

  static final _rng = Random(77);
  static final _starPositions = List.generate(
    40,
    (_) => (_rng.nextDouble(), _rng.nextDouble() * 0.65),
  );

  @override
  void initState() {
    super.initState();
    _starCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _breathCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _initVideo();
  }

  void _initVideo() {
    _videoCtrl = VideoPlayerController.asset('assets/videos/sleep_nest_bg.mp4')
      ..initialize().then((_) {
        _videoCtrl!.setVolume(0);
        _videoCtrl!.setLooping(true);
        _videoCtrl!.play();
        if (mounted) setState(() => _videoReady = true);
      }).catchError((_) {});
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _starCtrl.dispose();
    _glowCtrl.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050C1A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ── Background video / fallback ───────────────────
              Positioned.fill(
                child: _videoReady && _videoCtrl != null
                    ? ClipRect(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: _videoCtrl!.value.size.width,
                            height: _videoCtrl!.value.size.height,
                            child: VideoPlayer(_videoCtrl!),
                          ),
                        ),
                      )
                    : _fallbackGradient(),
              ),

              // ── Dark vignette for readability ─────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.30),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.40),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Twinkling star particles ──────────────────────
              ..._stars(w, h),

              // ── Breathing orb ─────────────────────────────────
              _breathingOrb(w, h),

              // ── Moon glow ─────────────────────────────────────
              _moonGlow(w, h),

              // ── Back button ───────────────────────────────────
              Positioned(
                top: 12,
                left: 12,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: _text, size: 18),
                    ),
                  ),
                ),
              ),

              // ── Title pill ────────────────────────────────────
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _purple.withValues(alpha: 0.45)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🌙', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 6),
                          Text(
                            'Sleep Nest',
                            style: TextStyle(
                              color: _text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Calming prompt ────────────────────────────────
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: SafeArea(
                  child: AnimatedBuilder(
                    animation: _glowCtrl,
                    builder: (_, __) => Opacity(
                      opacity: 0.55 + _glowCtrl.value * 0.30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.40),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: _purple.withValues(alpha: 0.30)),
                        ),
                        child: const Text(
                          'Close your eyes… 🌙\nLet your body get heavy and still.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 14,
                            height: 1.6,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _fallbackGradient() => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF050312), Color(0xFF0D0820), Color(0xFF1A0E3A)],
      ),
    ),
  );

  List<Widget> _stars(double w, double h) {
    return List.generate(_starPositions.length, (i) {
      return AnimatedBuilder(
        animation: _starCtrl,
        builder: (_, __) {
          final phase = i * pi / 5.0;
          final opacity = (0.25 + 0.55 * ((sin(_starCtrl.value * pi * 2 + phase) + 1) / 2))
              .clamp(0.0, 1.0);
          final size = 1.5 + (i % 3) * 1.0;
          return Positioned(
            left: _starPositions[i].$1 * w - size / 2,
            top: _starPositions[i].$2 * h - size / 2,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _breathingOrb(double w, double h) {
    return AnimatedBuilder(
      animation: _breathCtrl,
      builder: (_, __) {
        final scale = 1.0 + _breathCtrl.value * 0.08;
        final radius = 36.0 * scale;
        return Positioned(
          left: w * 0.38 - radius,
          top: h * 0.75 - radius,
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C6AF5).withValues(alpha: 0.18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C6AF5)
                      .withValues(alpha: 0.10 + _breathCtrl.value * 0.12),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Center(
              child: Text('🐣', style: TextStyle(fontSize: 32)),
            ),
          ),
        );
      },
    );
  }

  Widget _moonGlow(double w, double h) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) => Positioned(
        right: w * 0.25 - 24,
        top: h * 0.20 - 24,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFE8A0).withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFE066)
                    .withValues(alpha: 0.12 + _glowCtrl.value * 0.14),
                blurRadius: 24,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.only(left: 10, top: 4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0D0820),
            ),
          ),
        ),
      ),
    );
  }
}
