import 'package:flutter/material.dart';

class SleepNestScreen extends StatefulWidget {
  const SleepNestScreen({super.key});

  @override
  State<SleepNestScreen> createState() => _SleepNestScreenState();
}

class _SleepNestScreenState extends State<SleepNestScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;

  static const _backgroundAsset =
      'assets/images/rooms/garden/rest_nest_garden_hideaway_bg.png';
  static const _purple = Color(0xFF7C6AF5);
  static const _text = Color(0xFFE8D8FF);
  static const _muted = Color(0xFF9B8EC4);

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100B24),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final narrow = w < 650;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned.fill(child: _RestNestIllustratedBackground()),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.04),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.16),
                      ],
                      stops: const [0.0, 0.52, 1.0],
                    ),
                  ),
                ),
              ),
              _characters(w, h, narrow),
              _backButton(),
              _titlePill(),
              _calmingPrompt(),
            ],
          );
        },
      ),
    );
  }

  Widget _backButton() {
    return Positioned(
      top: 12,
      left: 12,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(color: _purple.withValues(alpha: 0.22)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _text,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _titlePill() {
    return Positioned(
      top: 16,
      left: 64,
      right: 64,
      child: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _purple.withValues(alpha: 0.32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Text(
              'Rest Nest',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _calmingPrompt() {
    return Positioned(
      bottom: 34,
      left: 20,
      right: 20,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.38),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _purple.withValues(
                      alpha: 0.24 + _glowCtrl.value * 0.06,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Text(
                  'Close your eyes...\nLet your body get heavy and still.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 18,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _characters(double w, double h, bool narrow) {
    final characterWidth = (w * (narrow ? 0.25 : 0.112)).clamp(74.0, 126.0);
    final top = h * (narrow ? 0.50 : 0.525);
    final overlapGap = characterWidth * (narrow ? 0.44 : 0.48);
    final centerX = w * 0.50;
    return Stack(
      children: [
        Positioned(
          left: centerX - overlapGap - characterWidth / 2,
          top: top,
          child: Image.asset(
            'assets/images/characters/sloth.png',
            width: characterWidth,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          left: centerX + overlapGap - characterWidth / 2,
          top: top + (narrow ? 4 : 6),
          child: Image.asset(
            'assets/images/characters/fox.png',
            width: characterWidth,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _RestNestIllustratedBackground extends StatelessWidget {
  const _RestNestIllustratedBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _SleepNestScreenState._backgroundAsset,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    );
  }
}
