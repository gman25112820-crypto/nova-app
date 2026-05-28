import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// ─────────────────────────────────────────────────────────────
// CalmLagoonScreen
//
// Full-screen experience: animated MP4 background with Flutter
// bubble + turtle overlays and a back button.
// Fallback to painted gradient if video fails to load.
// ─────────────────────────────────────────────────────────────

class CalmLagoonScreen extends StatefulWidget {
  const CalmLagoonScreen({super.key});

  @override
  State<CalmLagoonScreen> createState() => _CalmLagoonScreenState();
}

class _CalmLagoonScreenState extends State<CalmLagoonScreen>
    with TickerProviderStateMixin {

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  late final AnimationController _waveCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _turtleCtrl;

  static const _teal   = Color(0xFF4ECDC4);
  static const _text   = Color(0xFFF0F8FF);
  static const _muted  = Color(0xFF8ECFCA);

  // Bubble positions (fractional x, fractional y start)
  static const _bubbleBases = [
    (0.12, 0.90), (0.28, 0.85), (0.45, 0.92), (0.62, 0.88),
    (0.78, 0.91), (0.35, 0.70), (0.55, 0.75), (0.82, 0.78),
  ];

  @override
  void initState() {
    super.initState();
    _waveCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _turtleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _videoCtrl = VideoPlayerController.asset('assets/videos/calm_lagoon_bg.mp4');
      await _videoCtrl!.initialize();
      if (mounted) {
        _videoCtrl!.setLooping(true);
        _videoCtrl!.setVolume(0);
        _videoCtrl!.play();
        setState(() => _videoReady = true);
      }
    } catch (_) {
      if (mounted) setState(() => _videoReady = false);
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _waveCtrl.dispose();
    _glowCtrl.dispose();
    _turtleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021A24),
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

              // ── Subtle dark vignette so UI is readable ────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.25),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.30),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Animated bubbles ──────────────────────────────
              ..._bubbles(w, h),

              // ── Swimming turtle emoji ─────────────────────────
              _turtle(w, h),

              // ── Glowing orb ──────────────────────────────────
              _glowOrb(w, h),

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
                            color: _teal.withValues(alpha: 0.45)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🐢', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 6),
                          Text(
                            'Calm Lagoon',
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
                              color: _teal.withValues(alpha: 0.30)),
                        ),
                        child: const Text(
                          'Breathe in… and out 🌊\nLet the water hold you.',
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
        colors: [Color(0xFF0A1628), Color(0xFF0D3B6E), Color(0xFF1A6B8A)],
      ),
    ),
  );

  List<Widget> _bubbles(double w, double h) {
    return List.generate(_bubbleBases.length, (i) {
      return AnimatedBuilder(
        animation: _waveCtrl,
        builder: (_, __) {
          final phase = i * pi / 4.0;
          final t = _waveCtrl.value;
          final rise = (t + i * 0.12) % 1.0;
          final bx = _bubbleBases[i].$1 * w + sin(t * 2 * pi + phase) * 10;
          final by = _bubbleBases[i].$2 * h - rise * h * 0.35;
          final opacity = (1.0 - rise) * 0.55;
          final size = 4.0 + (i % 3) * 2.0 + rise * 3;
          return Positioned(
            left: bx - size / 2,
            top: by - size / 2,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.60),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30),
                      width: 0.5),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _turtle(double w, double h) {
    return AnimatedBuilder(
      animation: _turtleCtrl,
      builder: (_, __) {
        final t = _turtleCtrl.value;
        final tx = w * 0.05 + t * w * 0.90;
        final ty = h * 0.60 + sin(t * pi * 4) * 8;
        return Positioned(
          left: tx - 18,
          top: ty - 12,
          child: const Text('🐢', style: TextStyle(fontSize: 28)),
        );
      },
    );
  }

  Widget _glowOrb(double w, double h) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) => Positioned(
        left: w * 0.72 - 20,
        top: h * 0.18 - 20,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFE066).withValues(alpha: 0.70),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFE066)
                    .withValues(alpha: 0.25 + _glowCtrl.value * 0.25),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
