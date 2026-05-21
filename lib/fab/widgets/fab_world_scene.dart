import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'living_world_character.dart';
import 'fab_world_theme.dart';
import 'fab_world_audio.dart';
import 'fab_interaction_system.dart';

// ─────────────────────────────────────────────────────────────
// FAB WORLD SCENE — Parallax 3D + Seasons v6.0
//
// Architecture:
//   Layer 0  Sky gradient                (parallax factor 0.00)
//   Layer 1  Stars / moon               (parallax factor 0.02)
//   Layer 2  Distant mountains          (parallax factor 0.06)
//   Layer 3  Back forest                (parallax factor 0.12)
//   Layer 4  Mid forest                 (parallax factor 0.20)
//   Layer 5  Houses + gate              (parallax factor 0.32)
//   Layer 6  Path / ground              (parallax factor 0.42)
//   Layer 7  Characters (back row)      (parallax factor 0.50)
//   Layer 8  Characters (front row)     (parallax factor 0.62)
//   Layer 9  Season particles           (parallax factor 0.70)
//   Layer 10 Foreground vignette        (parallax factor 1.00)
//
// Parallax is driven by mouse position on web (auto-drift
// fallback on touch devices).  Atmospheric haze is applied
// per layer depth using FabWorldTheme.hazeForDepth().
// ─────────────────────────────────────────────────────────────

class FabWorldScene extends StatefulWidget {
  final FabWorldAudio? audio;
  const FabWorldScene({super.key, this.audio});

  @override
  State<FabWorldScene> createState() => _FabWorldSceneState();
}

class _FabWorldSceneState extends State<FabWorldScene>
    with TickerProviderStateMixin {

  // ── Animation controllers ───────────────────────────────────
  late final AnimationController _worldCtrl;
  late final AnimationController _parallaxDriftCtrl;

  // ── Parallax offset (mouse or auto-drift) ───────────────────
  double _parallaxX = 0.0; // -1..1  (left..right)
  double _parallaxY = 0.0; // -1..1  (up..down)
  double _targetParallaxX = 0.0;
  double _targetParallaxY = 0.0;

  // ── Background video ────────────────────────────────────────
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  // ── Season / theme ──────────────────────────────────────────
  late final FabWorldTheme _theme;

  // ── Interaction system ───────────────────────────────────
  late final FabInteractionSystem _interactions;
  double _lastFrameTime = 0.0;

  // ── Cat window state ─────────────────────────────────────
  // 0 = left window, 1 = right window, 2 = both same window, 3 = absent
  int _cat1Window = 0;  // which window cat1 is in (0=left, 1=right, -1=absent)
  int _cat2Window = 1;  // which window cat2 is in
  double _catOpacity1 = 1.0;
  double _catOpacity2 = 1.0;
  double _lastCatSwap = 0.0;
  double _nextCatSwap = 25.0;
  final _catRng = Random(42);

  @override
  void initState() {
    super.initState();

    _theme = FabWorldTheme.fromCalendar();

    _videoCtrl = VideoPlayerController.asset('assets/videos/background_scene.mp4')
      ..initialize().then((_) {
        _videoCtrl!.setVolume(0);
        _videoCtrl!.setLooping(true);
        _videoCtrl!.play();
        if (mounted) setState(() => _videoReady = true);
      });

    _interactions = FabInteractionSystem(theme: _theme);
    _interactions.initEpisodes();
    _interactions.onCatStateChange = (c1, c2, o1, o2) {
      if (!mounted) return;
      setState(() {
        _cat1Window = c1;
        _cat2Window = c2;
        _catOpacity1 = o1;
        _catOpacity2 = o2;
      });
    };

    _worldCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Auto-drift parallax — slow gentle sway when no mouse input
    _parallaxDriftCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _parallaxDriftCtrl.addListener(() {
      if (!mounted) return;
      // Only drift if mouse hasn't moved recently
      final drift = (_parallaxDriftCtrl.value - 0.5) * 2.0; // -1..1
      _targetParallaxX = drift * 0.35;
      _targetParallaxY = sin(drift * pi) * 0.12;

      final now = _parallaxDriftCtrl.value * 14.0; // 14s loop
      final dt = (now - _lastFrameTime).abs().clamp(0.0, 0.5);
      _lastFrameTime = now;
      _interactions.update(_worldCtrl.value, dt);
      _interactions.updateEpisodes(dt);

      setState(() {
        _parallaxX += (_targetParallaxX - _parallaxX) * 0.04;
        _parallaxY += (_targetParallaxY - _parallaxY) * 0.04;
      });
      // Occasional character sound cues tied to world phase
      final wp = _worldCtrl.value;
      if (wp > 0.124 && wp < 0.126) widget.audio?.onCharacterEvent('chicken_lips');
      if (wp > 0.374 && wp < 0.376) widget.audio?.onCharacterEvent('jack_russell');
      if (wp > 0.624 && wp < 0.626) widget.audio?.onCharacterEvent('daughter_9');
      if (wp > 0.874 && wp < 0.876) widget.audio?.onCharacterEvent('dad_giraffe');

      // Cat window swap logic
      _lastCatSwap += dt;
      if (_lastCatSwap >= _nextCatSwap) {
        _lastCatSwap = 0;
        _nextCatSwap = 20 + _catRng.nextDouble() * 35;
        _doSwapCats();
      }
      // Fade cats in/out
      if (_catOpacity1 < 1.0) _catOpacity1 = (_catOpacity1 + dt * 1.5).clamp(0, 1);
      if (_catOpacity2 < 1.0) _catOpacity2 = (_catOpacity2 + dt * 1.5).clamp(0, 1);
    });
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _worldCtrl.dispose();
    _parallaxDriftCtrl.dispose();
    super.dispose();
  }

  void _onMouseMove(PointerEvent event, Size size) {
    final nx = (event.localPosition.dx / size.width) * 2.0 - 1.0;  // -1..1
    final ny = (event.localPosition.dy / size.height) * 2.0 - 1.0;
    _targetParallaxX = nx * 0.5;
    _targetParallaxY = ny * 0.2;
    widget.audio?.onParallaxUpdate(nx);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _worldCtrl,
      builder: (context, _) {
        final worldP = _worldCtrl.value;

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // ── Parallax offsets per layer ──────────────────────
            // px() = horizontal pixel shift for a given factor
            // py() = vertical pixel shift for a given factor
            double px(double factor) => _parallaxX * w * 0.04 * factor;
            double py(double factor) => _parallaxY * h * 0.02 * factor;

            return MouseRegion(
              onHover: (e) => _onMouseMove(e, Size(w, h)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [

                  // ──────────────────────────────────────────────
                  // LAYER 0: Background video (full coverage)
                  // ──────────────────────────────────────────────
                  Positioned.fill(
                    child: _videoReady && _videoCtrl != null
                        ? ClipRect(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              alignment: const Alignment(0.0, 0.3),
                              child: SizedBox(
                                width: _videoCtrl!.value.size.width,
                                height: _videoCtrl!.value.size.height,
                                child: VideoPlayer(_videoCtrl!),
                              ),
                            ),
                          )
                        : const ColoredBox(color: Color(0xFF0D0820)),
                  ),


                  // ──────────────────────────────────────────────
                  // LAYER 7 – WINDOW CATS (inside left house windows)
                  // Left upper window: x≈w*0.1045, bottom from ground≈h*0.228
                  // Right upper window: x≈w*0.190, bottom from ground≈h*0.228
                  // Cats sit on the window sill — centred in each window
                  // ──────────────────────────────────────────────
                  // ── CATS — dynamic window positions ──────────
                  // Cats sit inside the upper-left windows.
                  // Window sill from bottom ≈ h*(1 - (wallBot-wallH + winH*1.08)/h)
                  // wallBot=0.735, wallH=0.315, winY=wallBot-wallH+wallH*0.08=0.4452 from top
                  // winH=wallH*0.22=0.0693  → sill bottom = 0.4452+0.0693=0.5145 from top
                  //                         = 1-0.5145 = 0.4855 from screen bottom
                  // We want cat bottom edge just at the sill → bottom ≈ h*0.490
                  if (_cat1Window >= 0 && _catOpacity1 > 0)
                    Positioned(
                      left: (_cat1Window == 0
                              ? w * 0.116
                              : _cat1Window == 1
                                  ? w * 0.192
                                  : w * 0.116) +
                          px(0.35),
                      bottom: h * 0.490 + py(0.35),
                      child: Transform.scale(
                        scale: 0.78,
                        alignment: Alignment.bottomCenter,
                        child: LivingWorldCharacter(
                          assetPath: 'assets/images/characters/cat1.png',
                          width: w * 0.058,
                          phase: worldP + 0.10,
                          motion: LivingCharacterMotion.curious,
                          shadowStrength: 0.0,
                          depth: 0.68,
                          interactionPull: sin(worldP * pi * 2) * 0.4,
                        ),
                      ),
                    ),

                  if (_cat2Window >= 0 && _catOpacity2 > 0)
                    Positioned(
                      left: (_cat2Window == 0
                              ? w * 0.130
                              : _cat2Window == 1
                                  ? w * 0.206
                                  : w * 0.206) +
                          px(0.35),
                      bottom: h * 0.490 + py(0.35),
                      child: Transform.scale(
                        scale: 0.78,
                        alignment: Alignment.bottomCenter,
                        child: LivingWorldCharacter(
                          assetPath: 'assets/images/characters/cat2.png',
                          width: w * 0.058,
                          phase: worldP + 0.42,
                          motion: LivingCharacterMotion.sleepy,
                          shadowStrength: 0.0,
                          depth: 0.68,
                          flipped: _cat2Window != _cat1Window,
                          interactionPull: -sin(worldP * pi * 2) * 0.4,
                        ),
                      ),
                    ),

                  // ──────────────────────────────────────────────
                  // LAYER 8 – INTERACTION-DRIVEN CHARACTERS
                  // Positions come from FabInteractionSystem.
                  // Depth/scale based on x position (further = smaller).
                  // ──────────────────────────────────────────────

                  // Helper: depth scale from x (gate=smallest, edges=larger)
                  // Teds
                  ..._buildChar(
                    w: w, h: h, px: px, py: py, worldP: worldP,
                    id: FabCharacterId.teds,
                    assetPath: 'assets/images/characters/teds.png',
                    baseWidth: 0.064,
                    phase: worldP + 0.22,
                    motion: LivingCharacterMotion.sleepy,
                    shadowStrength: 0.22,
                  ),

                  // Daughter 7
                  ..._buildChar(
                    w: w, h: h, px: px, py: py, worldP: worldP,
                    id: FabCharacterId.daughter7,
                    assetPath: 'assets/images/characters/daughter_7.png',
                    baseWidth: 0.068,
                    phase: worldP + 0.35,
                    motion: LivingCharacterMotion.playful,
                    shadowStrength: 0.22,
                  ),

                  // Daughter 9
                  ..._buildChar(
                    w: w, h: h, px: px, py: py, worldP: worldP,
                    id: FabCharacterId.daughter9,
                    assetPath: 'assets/images/characters/daughter_9.png',
                    baseWidth: 0.076,
                    phase: worldP + 0.55,
                    motion: LivingCharacterMotion.curious,
                    shadowStrength: 0.26,
                  ),

                  // Miss Chicken Lips
                  ..._buildChar(
                    w: w, h: h, px: px, py: py, worldP: worldP,
                    id: FabCharacterId.chickenLips,
                    assetPath: 'assets/images/chicken_lips.png',
                    baseWidth: 0.096,
                    phase: worldP + 0.74,
                    motion: LivingCharacterMotion.protective,
                    shadowStrength: 0.32,
                  ),

                  // Eddie Jack Russell
                  ..._buildChar(
                    w: w, h: h, px: px, py: py, worldP: worldP,
                    id: FabCharacterId.eddie,
                    assetPath: 'assets/images/characters/jack_russell.png',
                    baseWidth: 0.064,
                    phase: worldP + 0.16,
                    motion: LivingCharacterMotion.playful,
                    shadowStrength: 0.24,
                  ),

                  // Ollie (son_giraffe_2)
                  ..._buildChar(
                    w: w, h: h, px: px, py: py, worldP: worldP,
                    id: FabCharacterId.ollie,
                    assetPath: 'assets/images/characters/son_giraffe_2.png',
                    baseWidth: 0.090,
                    phase: worldP + 0.48,
                    motion: LivingCharacterMotion.curious,
                    shadowStrength: 0.24,
                  ),

                  // Theo (son_giraffe_1)
                  ..._buildChar(
                    w: w, h: h, px: px, py: py, worldP: worldP,
                    id: FabCharacterId.theo,
                    assetPath: 'assets/images/characters/son_giraffe_1.png',
                    baseWidth: 0.090,
                    phase: worldP + 0.68,
                    motion: LivingCharacterMotion.calm,
                    shadowStrength: 0.26,
                  ),

                  // Dad Giraffe — deliberately 1.3× bigger than sons
                  ..._buildChar(
                    w: w, h: h, px: px, py: py, worldP: worldP,
                    id: FabCharacterId.dadGiraffe,
                    assetPath: 'assets/images/characters/dad_giraffe.png',
                    baseWidth: 0.152,
                    phase: worldP + 0.86,
                    motion: LivingCharacterMotion.protective,
                    shadowStrength: 0.36,
                  ),

                ],
              ),
            );
          },
        );
      },
    );
  }



  // ── Cat window swap ───────────────────────────────────────
  void _doSwapCats() {
    // Pick a new configuration
    final roll = _catRng.nextDouble();
    int new1, new2;

    if (roll < 0.30) {
      // Normal — cat1 left, cat2 right
      new1 = 0; new2 = 1;
    } else if (roll < 0.55) {
      // Swapped — cat1 right, cat2 left
      new1 = 1; new2 = 0;
    } else if (roll < 0.68) {
      // Both in left window
      new1 = 0; new2 = 0;
    } else if (roll < 0.78) {
      // Both in right window
      new1 = 1; new2 = 1;
    } else if (roll < 0.88) {
      // Cat1 absent
      new1 = -1; new2 = _catRng.nextBool() ? 0 : 1;
    } else if (roll < 0.95) {
      // Cat2 absent
      new1 = _catRng.nextBool() ? 0 : 1; new2 = -1;
    } else {
      // Both absent (rare)
      new1 = -1; new2 = -1;
    }

    if (new1 != _cat1Window) {
      _catOpacity1 = 0.0;
      _cat1Window = new1;
    }
    if (new2 != _cat2Window) {
      _catOpacity2 = 0.0;
      _cat2Window = new2;
    }
  }

  // ── Build interaction-driven character widget ─────────────
  List<Widget> _buildChar({
    required double w,
    required double h,
    required double Function(double) px,
    required double Function(double) py,
    required double worldP,
    required FabCharacterId id,
    required String assetPath,
    required double baseWidth,
    required double phase,
    required LivingCharacterMotion motion,
    required double shadowStrength,
  }) {
    final charX = _interactions.xOf(id);
    final flipped = _interactions.flippedOf(id);
    final isMoving = _interactions.isMovingOf(id);

    // Depth scale: characters near gate (x≈0.5) are slightly smaller
    // characters at edges (home) are full size
    final distFromCenter = (charX - 0.5).abs();
    final depthScale = 0.82 + distFromCenter * 0.36;
    final depth = 0.85 + distFromCenter * 0.30;

    // Walking bob when moving
    final walkBob = isMoving
        ? sin(worldP * pi * 16) * h * 0.004
        : 0.0;

    final Widget char = LivingWorldCharacter(
      assetPath: assetPath,
      width: w * baseWidth * depthScale,
      phase: phase,
      motion: isMoving ? LivingCharacterMotion.playful : motion,
      shadowStrength: shadowStrength * depthScale,
      depth: depth,
      interactionPull: 0,
      flipped: flipped,
    );

    return [
      Positioned(
        left: charX * w + px(0.55),
        bottom: h * 0.182 + py(0.55) + walkBob,
        child: char,
      ),
    ];
  }

}
