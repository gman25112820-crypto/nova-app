import 'dart:math';
import 'package:flutter/material.dart';
import 'living_world_character.dart';
import 'fab_world_theme.dart';
import 'fab_world_audio.dart';
import 'fab_season_particles.dart';
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
  late final AnimationController _starCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _windowCtrl;
  late final AnimationController _meetingCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _parallaxDriftCtrl;

  // ── Parallax offset (mouse or auto-drift) ───────────────────
  double _parallaxX = 0.0; // -1..1  (left..right)
  double _parallaxY = 0.0; // -1..1  (up..down)
  double _targetParallaxX = 0.0;
  double _targetParallaxY = 0.0;

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

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _windowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _meetingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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
    _worldCtrl.dispose();
    _starCtrl.dispose();
    _glowCtrl.dispose();
    _windowCtrl.dispose();
    _meetingCtrl.dispose();
    _particleCtrl.dispose();
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
      animation: Listenable.merge([
        _worldCtrl,
        _starCtrl,
        _glowCtrl,
        _windowCtrl,
        _meetingCtrl,
        _particleCtrl,
      ]),
      builder: (context, _) {
        final worldP   = _worldCtrl.value;
        final starP    = _starCtrl.value;
        final glowP    = _glowCtrl.value;
        final winP     = _windowCtrl.value;
        final particleP = _particleCtrl.value;

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // ── Parallax offsets per layer ──────────────────────
            // px() = horizontal pixel shift for a given factor
            // py() = vertical pixel shift for a given factor
            double px(double factor) => _parallaxX * w * 0.04 * factor;
            double py(double factor) => _parallaxY * h * 0.02 * factor;

            // ── Character physics ───────────────────────────────
            final familyPull   = sin(worldP * pi * 2) * 1.8;
            final dogPull      = sin(worldP * pi * 2 + 1.4) * 2.2;
            final chickenPull  = sin(worldP * pi * 2 + 2.1) * 1.4;
            final giraffeProtectiveLean = sin(worldP * pi * 2 + 0.9) * 1.6;

            // ── Depth scale helper for characters ───────────────
            // Characters placed at the back of the scene are
            // rendered smaller to enforce perspective scale.
            // frontScale=1.0 at the front, backScale at the back.
            const backCharScale  = 0.72;
            const frontCharScale = 1.00;

            return MouseRegion(
              onHover: (e) => _onMouseMove(e, Size(w, h)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [

                  // ──────────────────────────────────────────────
                  // LAYER 0 + 1: Sky, stars, moon (factor 0.00–0.02)
                  // ──────────────────────────────────────────────
                  Positioned(
                    left: px(0.02),
                    top:  py(0.02),
                    right: -px(0.02),
                    bottom: -py(0.02),
                    child: CustomPaint(
                      painter: _SkyPainter(
                        theme: _theme,
                        starPhase: starP,
                        glowPhase: glowP,
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // LAYER 2: Distant mountains (factor 0.06)
                  // Hazy, barely moves
                  // ──────────────────────────────────────────────
                  Positioned(
                    left: px(0.06),
                    top:  py(0.06),
                    right: -px(0.06),
                    bottom: -py(0.06),
                    child: CustomPaint(
                      painter: _MountainPainter(
                        theme: _theme,
                        worldPhase: worldP,
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // LAYER 3: Back forest (factor 0.12)
                  // ──────────────────────────────────────────────
                  Positioned(
                    left: px(0.12),
                    top:  py(0.12),
                    right: -px(0.12),
                    bottom: -py(0.12),
                    child: CustomPaint(
                      painter: _ForestBackPainter(
                        theme: _theme,
                        worldPhase: worldP,
                        glowPhase: glowP,
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // LAYER 4: Mid forest + ground (factor 0.20)
                  // ──────────────────────────────────────────────
                  Positioned(
                    left: px(0.20),
                    top:  py(0.20),
                    right: -px(0.20),
                    bottom: -py(0.20),
                    child: CustomPaint(
                      painter: _ForestMidAndGroundPainter(
                        theme: _theme,
                        worldPhase: worldP,
                        glowPhase: glowP,
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // LAYER 5: Houses + gate (factor 0.32)
                  // ──────────────────────────────────────────────
                  Positioned(
                    left: px(0.32),
                    top:  py(0.32),
                    right: -px(0.32),
                    bottom: -py(0.32),
                    child: CustomPaint(
                      painter: _HousesPainter(
                        theme: _theme,
                        windowPhase: winP,
                        worldPhase: worldP,
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // LAYER 6: Path + near trees (factor 0.42)
                  // ──────────────────────────────────────────────
                  Positioned(
                    left: px(0.42),
                    top:  py(0.42),
                    right: -px(0.42),
                    bottom: -py(0.42),
                    child: CustomPaint(
                      painter: _PathAndNearTreesPainter(
                        theme: _theme,
                        worldPhase: worldP,
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // LAYER 7 – WINDOW CATS (inside left house windows)
                  // Left upper window: x≈w*0.1045, bottom from ground≈h*0.228
                  // Right upper window: x≈w*0.190, bottom from ground≈h*0.228
                  // Cats sit on the window sill — centred in each window
                  // ──────────────────────────────────────────────
                  // ── CATS — dynamic window positions ──────────
                  if (_cat1Window >= 0)
                    Positioned(
                      left: (_cat1Window == 0
                              ? w * 0.112
                              : _cat1Window == 1
                                  ? w * 0.188
                                  : w * 0.112) +
                          px(0.35),
                      bottom: h * 0.422 + py(0.35),
                      child: Opacity(
                        opacity: _catOpacity1,
                        child: Transform.scale(
                          scale: 0.42,
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
                    ),

                  if (_cat2Window >= 0)
                    Positioned(
                      left: (_cat2Window == 0
                              ? w * 0.124  // slight offset if both in left
                              : _cat2Window == 1
                                  ? w * 0.200
                                  : w * 0.200) +
                          px(0.35),
                      bottom: h * 0.422 + py(0.35),
                      child: Opacity(
                        opacity: _catOpacity2,
                        child: Transform.scale(
                          scale: 0.42,
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
                    baseWidth: 0.062,
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
                    baseWidth: 0.060,
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

                  // Dad Giraffe
                  ..._buildChar(
                    w: w, h: h, px: px, py: py, worldP: worldP,
                    id: FabCharacterId.dadGiraffe,
                    assetPath: 'assets/images/characters/dad_giraffe.png',
                    baseWidth: 0.118,
                    phase: worldP + 0.86,
                    motion: LivingCharacterMotion.protective,
                    shadowStrength: 0.36,
                  ),

                  // ──────────────────────────────────────────────
                  // LAYER 9: Season particles (factor 0.70)
                  // ──────────────────────────────────────────────
                  Positioned(
                    left: px(0.70),
                    top: py(0.70),
                    right: -px(0.70),
                    bottom: -py(0.70),
                    child: FabSeasonParticles(
                      theme: _theme,
                      phase: particleP,
                      worldP: worldP,
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // LAYER 10: Foreground depth + vignette (static)
                  // ──────────────────────────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _ForegroundPainter(theme: _theme),
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      ),
                    ),
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

    // Haze for depth
    final haze = _theme.hazeForDepth(depth * 0.7);

    Widget char = LivingWorldCharacter(
      assetPath: assetPath,
      width: w * baseWidth * depthScale,
      phase: phase,
      motion: isMoving ? LivingCharacterMotion.playful : motion,
      shadowStrength: shadowStrength * depthScale,
      depth: depth,
      interactionPull: 0,
      flipped: flipped,
    );

    if (haze > 0.01) {
      char = ColorFiltered(
        colorFilter: ColorFilter.matrix(_hazeMatrix(haze)),
        child: char,
      );
    }

    return [
      Positioned(
        left: charX * w + px(0.55),
        bottom: h * 0.182 + py(0.55) + walkBob,
        child: char,
      ),
    ];
  }

  // ── Atmospheric haze wrapper ──────────────────────────────────
  // Applies a colour-tinted opacity overlay to simulate
  // aerial perspective for distant characters.
  Widget _hazeWrap({required double depth, required Widget child}) {
    final haze = _theme.hazeForDepth(depth);
    if (haze < 0.01) return child;
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(_hazeMatrix(haze)),
      child: child,
    );
  }

  // Desaturate + darken toward sky haze colour
  List<double> _hazeMatrix(double amount) {
    final a = amount.clamp(0.0, 0.85);
    // Simple desaturate + fade toward dark
    return [
      1 - a * 0.4, 0, 0, 0, -a * 20,
      0, 1 - a * 0.4, 0, 0, -a * 20,
      0, 0, 1 - a * 0.2, 0, -a * 10,
      0, 0, 0, 1 - a * 0.25, 0,
    ];
  }
}

// ─────────────────────────────────────────────────────────────
// PAINTERS — one per layer group
// ─────────────────────────────────────────────────────────────

// ── Layer 0+1: Sky, stars, moon ──────────────────────────────
class _SkyPainter extends CustomPainter {
  final FabWorldTheme theme;
  final double starPhase;
  final double glowPhase;

  const _SkyPainter({
    required this.theme,
    required this.starPhase,
    required this.glowPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky
    final colors = theme.skyColors;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0.0, 0.32, 0.70, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Stars
    final rng = Random(44);
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.52;
      final twinkle = (sin(starPhase * pi * 2 + i * 0.68) + 1) / 2;
      final r = 0.5 + rng.nextDouble() * 1.1;
      canvas.drawCircle(
        Offset(x, y),
        r * (0.62 + twinkle * 0.45),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22 + twinkle * 0.58),
      );
    }

    // Moon
    final t = (sin(glowPhase * pi * 2) + 1) / 2;
    final cx = w * 0.82;
    final cy = h * 0.105;
    final moonCol = theme.moonColor;

    canvas.drawCircle(
      Offset(cx, cy),
      42,
      Paint()
        ..color = moonCol.withValues(alpha: 0.06 + t * 0.04)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      19,
      Paint()..color = moonCol.withValues(alpha: 0.92),
    );
    canvas.drawCircle(
      Offset(cx + 6, cy - 2),
      15,
      Paint()..color = theme.skyColors[1].withValues(alpha: 0.80),
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) =>
      old.starPhase != starPhase || old.glowPhase != glowPhase;
}

// ── Layer 2: Mountains ────────────────────────────────────────
class _MountainPainter extends CustomPainter {
  final FabWorldTheme theme;
  final double worldPhase;

  const _MountainPainter({required this.theme, required this.worldPhase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Far mountains
    final farPath = Path()
      ..moveTo(0, h * 0.50)
      ..lineTo(w * 0.10, h * 0.30)
      ..lineTo(w * 0.21, h * 0.43)
      ..lineTo(w * 0.33, h * 0.24)
      ..lineTo(w * 0.47, h * 0.44)
      ..lineTo(w * 0.60, h * 0.28)
      ..lineTo(w * 0.74, h * 0.45)
      ..lineTo(w * 0.88, h * 0.31)
      ..lineTo(w, h * 0.48)
      ..lineTo(w, h * 0.58)
      ..lineTo(0, h * 0.58)
      ..close();

    canvas.drawPath(
      farPath,
      Paint()
        ..color = theme.mountainFarColor.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Near mountains
    final nearPath = Path()
      ..moveTo(0, h * 0.56)
      ..lineTo(w * 0.12, h * 0.39)
      ..lineTo(w * 0.25, h * 0.50)
      ..lineTo(w * 0.38, h * 0.33)
      ..lineTo(w * 0.52, h * 0.49)
      ..lineTo(w * 0.66, h * 0.34)
      ..lineTo(w * 0.80, h * 0.50)
      ..lineTo(w * 0.94, h * 0.38)
      ..lineTo(w, h * 0.48)
      ..lineTo(w, h * 0.62)
      ..lineTo(0, h * 0.62)
      ..close();

    canvas.drawPath(
      nearPath,
      Paint()..color = theme.mountainNearColor.withValues(alpha: 0.75),
    );

    // Winter snow caps
    if (theme.showSnowOnRoof) {
      _drawSnowCap(canvas, w * 0.33, h * 0.24, w * 0.08, h * 0.04);
      _drawSnowCap(canvas, w * 0.60, h * 0.28, w * 0.07, h * 0.035);
      _drawSnowCap(canvas, w * 0.88, h * 0.31, w * 0.065, h * 0.03);
    }
  }

  void _drawSnowCap(Canvas canvas, double cx, double cy, double capW, double capH) {
    final path = Path()
      ..moveTo(cx - capW, cy + capH)
      ..quadraticBezierTo(cx, cy - capH * 0.5, cx + capW, cy + capH)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFFD8E8F5).withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _MountainPainter old) =>
      old.worldPhase != worldPhase;
}

// ── Layer 3: Back forest ──────────────────────────────────────
class _ForestBackPainter extends CustomPainter {
  final FabWorldTheme theme;
  final double worldPhase;
  final double glowPhase;

  const _ForestBackPainter({
    required this.theme,
    required this.worldPhase,
    required this.glowPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rng = Random(71);

    for (int i = 0; i < 30; i++) {
      final x = (i / 29) * w;
      final treeH = h * (0.13 + rng.nextDouble() * 0.10);
      final treeW = w * (0.020 + rng.nextDouble() * 0.012);
      final baseY = h * 0.68;
      final sway = sin(worldPhase * pi * 2 + i * 0.4) * 1.5;

      final path = Path()
        ..moveTo(x - treeW, baseY)
        ..lineTo(x + sway, baseY - treeH)
        ..lineTo(x + treeW, baseY)
        ..close();

      canvas.drawPath(
        path,
        Paint()..color = theme.forestBackColor.withValues(alpha: 0.52),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ForestBackPainter old) =>
      old.worldPhase != worldPhase || old.glowPhase != glowPhase;
}

// ── Layer 4: Mid forest + ground ─────────────────────────────
class _ForestMidAndGroundPainter extends CustomPainter {
  final FabWorldTheme theme;
  final double worldPhase;
  final double glowPhase;

  const _ForestMidAndGroundPainter({
    required this.theme,
    required this.worldPhase,
    required this.glowPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rng = Random(93);
    final t = (sin(glowPhase * pi * 2) + 1) / 2;

    // Mid forest trees
    for (int i = 0; i < 24; i++) {
      final x = (i / 23) * w;
      final treeH = h * (0.18 + rng.nextDouble() * 0.13);
      final treeW = w * (0.028 + rng.nextDouble() * 0.018);
      final baseY = h * 0.735;
      final sway = sin(worldPhase * pi * 2 + i * 0.55) * 2.3;

      final isGlowTree = i % 4 == 0;
      final paint = Paint()
        ..color = isGlowTree
            ? theme.forestGlowColor.withValues(alpha: 0.22 + t * 0.12)
            : theme.forestMidColor.withValues(alpha: 0.72);

      if (isGlowTree) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      }

      final path = Path()
        ..moveTo(x - treeW, baseY)
        ..lineTo(x + sway, baseY - treeH)
        ..lineTo(x + treeW, baseY)
        ..close();

      canvas.drawPath(path, paint);
    }

    // Ground
    final groundRect = Rect.fromLTWH(0, h * 0.70, w, h * 0.30);
    canvas.drawRect(
      groundRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.groundColors,
        ).createShader(groundRect),
    );

    // Ground edge highlight
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.70, w, 2),
      Paint()..color = theme.groundLineColor.withValues(alpha: 0.20),
    );

    // Autumn leaf litter on ground
    if (theme.season == FabSeason.autumn) {
      final leafRng = Random(201);
      for (int i = 0; i < 20; i++) {
        final lx = leafRng.nextDouble() * w;
        final ly = h * (0.72 + leafRng.nextDouble() * 0.15);
        final lr = 2 + leafRng.nextDouble() * 3;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(lx, ly), width: lr * 2, height: lr),
          Paint()..color = const Color(0xFFCC5500).withValues(alpha: 0.35),
        );
      }
    }

    // Winter snow on ground
    if (theme.season == FabSeason.winter) {
      final snowRect = Rect.fromLTWH(0, h * 0.70, w, h * 0.04);
      canvas.drawRect(
        snowRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFCCDDEE).withValues(alpha: 0.0),
              const Color(0xFFCCDDEE).withValues(alpha: 0.60),
            ],
          ).createShader(snowRect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ForestMidAndGroundPainter old) =>
      old.worldPhase != worldPhase || old.glowPhase != glowPhase;
}

// ── Layer 5: Houses + gate ────────────────────────────────────
class _HousesPainter extends CustomPainter {
  final FabWorldTheme theme;
  final double windowPhase;
  final double worldPhase;

  const _HousesPainter({
    required this.theme,
    required this.windowPhase,
    required this.worldPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw gardens FIRST (behind characters)
    _drawPool(canvas, w, h);
    _drawPlayArea(canvas, w, h);
    _drawLeftHouse(canvas, w, h);
    _drawRightHouse(canvas, w, h);
    _drawGate(canvas, w, h);
    _drawPlantPots(canvas, w, h);
    _drawCars(canvas, w, h);
  }


  // ── Plant pots scattered around both houses ───────────────
  void _drawPlantPots(Canvas canvas, double w, double h) {
    final groundY = h * 0.735;

    // Pot colour by season
    final plantColor = theme.season == FabSeason.winter
        ? const Color(0xFFAABBCC)  // bare/snowy
        : theme.season == FabSeason.autumn
            ? const Color(0xFFCC6622)  // rusty autumn
            : const Color(0xFF44AA55); // green spring/summer

    final potColor = const Color(0xFFC1784A);

    // Left house pots
    _pot(canvas, w * 0.082, groundY, w * 0.018, h * 0.040, potColor, plantColor);
    _pot(canvas, w * 0.098, groundY, w * 0.014, h * 0.032, potColor, plantColor);
    _pot(canvas, w * 0.300, groundY, w * 0.016, h * 0.036, potColor, plantColor);
    _pot(canvas, w * 0.316, groundY, w * 0.013, h * 0.028, potColor, plantColor);

    // Right house pots
    _pot(canvas, w * 0.636, groundY, w * 0.016, h * 0.036, potColor, plantColor);
    _pot(canvas, w * 0.620, groundY, w * 0.013, h * 0.028, potColor, plantColor);
    _pot(canvas, w * 0.868, groundY, w * 0.018, h * 0.040, potColor, plantColor);
    _pot(canvas, w * 0.886, groundY, w * 0.014, h * 0.032, potColor, plantColor);

    // Gate area pots
    _pot(canvas, w * 0.462, groundY, w * 0.013, h * 0.030, potColor, plantColor);
    _pot(canvas, w * 0.548, groundY, w * 0.013, h * 0.030, potColor, plantColor);
  }

  void _pot(Canvas canvas, double x, double groundY, double potW, double potH,
      Color potColor, Color plantColor) {
    // Pot body — trapezoid
    final potPath = Path()
      ..moveTo(x, groundY)
      ..lineTo(x + potW, groundY)
      ..lineTo(x + potW * 0.85, groundY - potH)
      ..lineTo(x + potW * 0.15, groundY - potH)
      ..close();
    canvas.drawPath(potPath, Paint()..color = potColor.withValues(alpha: 0.85));

    // Rim
    canvas.drawRect(
      Rect.fromLTWH(x - potW * 0.05, groundY - potH, potW * 1.10, potH * 0.12),
      Paint()..color = potColor.withValues(alpha: 0.95),
    );

    // Plant
    if (theme.season == FabSeason.winter) {
      // Bare twig
      canvas.drawLine(
        Offset(x + potW * 0.5, groundY - potH),
        Offset(x + potW * 0.5, groundY - potH - potH * 0.8),
        Paint()..color = const Color(0xFF664433).withValues(alpha: 0.70)..strokeWidth = 1.5,
      );
    } else {
      // Leafy bush
      canvas.drawCircle(
        Offset(x + potW * 0.5, groundY - potH - potH * 0.55),
        potW * 0.55,
        Paint()..color = plantColor.withValues(alpha: 0.80),
      );
      // Flower dot on spring/summer
      if (theme.season != FabSeason.autumn) {
        canvas.drawCircle(
          Offset(x + potW * 0.5, groundY - potH - potH * 0.55),
          potW * 0.22,
          Paint()..color = theme.leftHouseAccent.withValues(alpha: 0.70),
        );
      }
    }
  }

  // ── Cars — parked beside each house ──────────────────────
  void _drawCars(Canvas canvas, double w, double h) {
    final groundY = h * 0.735;

    // Miss Chicken Lips' Kia SUV — purple/rose, left side
    _drawKiaSUV(canvas, w * 0.008, groundY, w, h);

    // Gareth's Renault Clio — silver grey, right side
    _drawClio(canvas, w * 0.900, groundY, w, h);
  }

  void _drawKiaSUV(Canvas canvas, double x, double groundY, double w, double h) {
    final carW = w * 0.130;
    final carH = h * 0.075;
    final wheelR = h * 0.018;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + carW * 0.5, groundY + 2),
        width: carW * 0.85,
        height: h * 0.012,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Body — chunky SUV shape
    final bodyPath = Path()
      ..moveTo(x + carW * 0.05, groundY - wheelR * 1.1)
      ..lineTo(x + carW * 0.12, groundY - carH)
      ..lineTo(x + carW * 0.88, groundY - carH)
      ..lineTo(x + carW * 0.95, groundY - wheelR * 1.1)
      ..close();
    canvas.drawPath(
      bodyPath,
      Paint()..color = const Color(0xFF1B4F8A),  // Kia metallic blue
    );

    // Roof — rounded
    final roofPath = Path()
      ..moveTo(x + carW * 0.18, groundY - carH)
      ..lineTo(x + carW * 0.22, groundY - carH * 1.45)
      ..lineTo(x + carW * 0.78, groundY - carH * 1.45)
      ..lineTo(x + carW * 0.82, groundY - carH)
      ..close();
    canvas.drawPath(
      roofPath,
      Paint()..color = const Color(0xFF2260A8),  // Kia roof metallic blue lighter
    );

    // Windows
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + carW * 0.24, groundY - carH * 1.40,
            carW * 0.22, carH * 0.40),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF88CCFF).withValues(alpha: 0.70),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + carW * 0.50, groundY - carH * 1.40,
            carW * 0.24, carH * 0.40),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF88CCFF).withValues(alpha: 0.70),
    );

    // Side detail stripe
    canvas.drawLine(
      Offset(x + carW * 0.10, groundY - carH * 0.55),
      Offset(x + carW * 0.90, groundY - carH * 0.55),
      Paint()..color = const Color(0xFF44AAFF).withValues(alpha: 0.35)..strokeWidth = 2,  // blue highlight
    );

    // Wheels
    _wheel(canvas, x + carW * 0.22, groundY, wheelR);
    _wheel(canvas, x + carW * 0.78, groundY, wheelR);

    // Headlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + carW * 0.88, groundY - carH * 0.65,
            carW * 0.06, carH * 0.18),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFFFF88).withValues(alpha: 0.80),
    );

    // Number plate
    canvas.drawRect(
      Rect.fromLTWH(x + carW * 0.30, groundY - wheelR * 1.4,
          carW * 0.20, h * 0.014),
      Paint()..color = const Color(0xFFFFFF00).withValues(alpha: 0.60),
    );
  }

  void _drawClio(Canvas canvas, double x, double groundY, double w, double h) {
    final carW = w * 0.095;
    final carH = h * 0.062;
    final wheelR = h * 0.015;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + carW * 0.5, groundY + 2),
        width: carW * 0.85,
        height: h * 0.010,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Body — compact hatchback
    final bodyPath = Path()
      ..moveTo(x + carW * 0.04, groundY - wheelR * 1.1)
      ..lineTo(x + carW * 0.10, groundY - carH)
      ..lineTo(x + carW * 0.90, groundY - carH)
      ..lineTo(x + carW * 0.96, groundY - wheelR * 1.1)
      ..close();
    canvas.drawPath(
      bodyPath,
      Paint()..color = const Color(0xFF8899AA),
    );

    // Roof
    final roofPath = Path()
      ..moveTo(x + carW * 0.16, groundY - carH)
      ..lineTo(x + carW * 0.22, groundY - carH * 1.50)
      ..lineTo(x + carW * 0.80, groundY - carH * 1.50)
      ..lineTo(x + carW * 0.88, groundY - carH)
      ..close();
    canvas.drawPath(
      roofPath,
      Paint()..color = const Color(0xFF99AABB),
    );

    // Windows
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + carW * 0.24, groundY - carH * 1.44,
            carW * 0.24, carH * 0.40),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF88CCFF).withValues(alpha: 0.65),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + carW * 0.52, groundY - carH * 1.44,
            carW * 0.22, carH * 0.40),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF88CCFF).withValues(alpha: 0.65),
    );

    // Wheels
    _wheel(canvas, x + carW * 0.22, groundY, wheelR);
    _wheel(canvas, x + carW * 0.78, groundY, wheelR);

    // Headlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, groundY - carH * 0.60,
            carW * 0.06, carH * 0.16),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFFFF88).withValues(alpha: 0.75),
    );

    // Number plate
    canvas.drawRect(
      Rect.fromLTWH(x + carW * 0.28, groundY - wheelR * 1.3,
          carW * 0.22, h * 0.012),
      Paint()..color = const Color(0xFFFFFF00).withValues(alpha: 0.55),
    );
  }

  void _wheel(Canvas canvas, double cx, double groundY, double r) {
    // Tyre
    canvas.drawCircle(
      Offset(cx, groundY - r),
      r,
      Paint()..color = const Color(0xFF222222),
    );
    // Hub
    canvas.drawCircle(
      Offset(cx, groundY - r),
      r * 0.50,
      Paint()..color = const Color(0xFFAAAAAA),
    );
    // Spokes
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * pi * 2;
      canvas.drawLine(
        Offset(cx, groundY - r),
        Offset(cx + cos(angle) * r * 0.45, groundY - r + sin(angle) * r * 0.45),
        Paint()..color = const Color(0xFF888888)..strokeWidth = 1,
      );
    }
  }

  // ── LEFT GARDEN: Swimming pool + diving board ─────────────
  void _drawPool(Canvas canvas, double w, double h) {
    final groundY = h * 0.735;

    // Pool surround / deck — perspective trapezoid
    final deckPath = Path()
      ..moveTo(w * 0.300, groundY - h * 0.018)
      ..lineTo(w * 0.455, groundY - h * 0.018)
      ..lineTo(w * 0.448, groundY - h * 0.072)
      ..lineTo(w * 0.308, groundY - h * 0.072)
      ..close();
    canvas.drawPath(
      deckPath,
      Paint()..color = const Color(0xFFD4C4A8).withValues(alpha: 0.70),
    );

    // Pool water — inner trapezoid
    final poolPath = Path()
      ..moveTo(w * 0.312, groundY - h * 0.024)
      ..lineTo(w * 0.444, groundY - h * 0.024)
      ..lineTo(w * 0.438, groundY - h * 0.066)
      ..lineTo(w * 0.318, groundY - h * 0.066)
      ..close();

    // Water shimmer animation
    final shimmer = (sin(worldPhase * pi * 2) + 1) / 2;
    final waterCol = Color.lerp(
      const Color(0xFF0099CC),
      const Color(0xFF00CCFF),
      shimmer,
    )!;

    canvas.drawPath(poolPath, Paint()..color = waterCol.withValues(alpha: 0.85));

    // Pool lane lines
    final lanePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(w * 0.350, groundY - h * 0.024),
      Offset(w * 0.346, groundY - h * 0.066),
      lanePaint,
    );
    canvas.drawLine(
      Offset(w * 0.395, groundY - h * 0.024),
      Offset(w * 0.390, groundY - h * 0.066),
      lanePaint,
    );

    // Water shimmer highlights
    for (int i = 0; i < 4; i++) {
      final sx = w * (0.320 + i * 0.028);
      final sy = groundY - h * (0.034 + sin(worldPhase * pi * 2 + i) * 0.008);
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx + w * 0.018, sy),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15 + shimmer * 0.18)
          ..strokeWidth = 1.5,
      );
    }

    // Pool tile border
    canvas.drawPath(
      poolPath,
      Paint()
        ..color = const Color(0xFF66CCFF).withValues(alpha: 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Diving board — perspective plank
    // Post
    canvas.drawRect(
      Rect.fromLTWH(w * 0.438, groundY - h * 0.072, w * 0.008, h * 0.025),
      Paint()..color = const Color(0xFF888888).withValues(alpha: 0.80),
    );
    // Board
    final boardPath = Path()
      ..moveTo(w * 0.430, groundY - h * 0.072)
      ..lineTo(w * 0.468, groundY - h * 0.074)
      ..lineTo(w * 0.468, groundY - h * 0.068)
      ..lineTo(w * 0.430, groundY - h * 0.066)
      ..close();
    canvas.drawPath(
      boardPath,
      Paint()..color = const Color(0xFFFFCC44).withValues(alpha: 0.90),
    );
    // Spring bounce animation on board tip
    final bounce = sin(worldPhase * pi * 4) * h * 0.003;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.468, groundY - h * 0.071 + bounce),
        width: w * 0.006,
        height: h * 0.004,
      ),
      Paint()..color = const Color(0xFFFFDD88).withValues(alpha: 0.60),
    );

    // Season variations
    if (theme.season == FabSeason.winter) {
      // Frozen pool — ice blue overlay
      canvas.drawPath(
        poolPath,
        Paint()..color = const Color(0xFFCCEEFF).withValues(alpha: 0.55),
      );
      canvas.drawPath(
        poolPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  // ── RIGHT GARDEN: Swing + slide play area ─────────────────
  void _drawPlayArea(Canvas canvas, double w, double h) {
    final groundY = h * 0.735;

    // Grass patch
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.560, groundY - h * 0.008),
        width: w * 0.140,
        height: h * 0.018,
      ),
      Paint()..color = const Color(0xFF2A6B30).withValues(alpha: 0.45),
    );

    // ── SLIDE ───────────────────────────────────────────────
    // Platform post left
    canvas.drawRect(
      Rect.fromLTWH(w * 0.508, groundY - h * 0.090, w * 0.007, h * 0.090),
      Paint()..color = const Color(0xFFCC4422).withValues(alpha: 0.85),
    );
    // Platform post right
    canvas.drawRect(
      Rect.fromLTWH(w * 0.532, groundY - h * 0.090, w * 0.007, h * 0.090),
      Paint()..color = const Color(0xFFCC4422).withValues(alpha: 0.85),
    );
    // Platform top
    canvas.drawRect(
      Rect.fromLTWH(w * 0.506, groundY - h * 0.092, w * 0.036, h * 0.010),
      Paint()..color = const Color(0xFFFF6644).withValues(alpha: 0.90),
    );
    // Slide ramp — perspective diagonal
    final slidePath = Path()
      ..moveTo(w * 0.506, groundY - h * 0.082)
      ..lineTo(w * 0.542, groundY - h * 0.082)
      ..lineTo(w * 0.570, groundY - h * 0.010)
      ..lineTo(w * 0.558, groundY - h * 0.010)
      ..close();
    canvas.drawPath(
      slidePath,
      Paint()..color = const Color(0xFFFF8844).withValues(alpha: 0.88),
    );
    // Slide shine
    canvas.drawLine(
      Offset(w * 0.522, groundY - h * 0.080),
      Offset(w * 0.548, groundY - h * 0.012),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..strokeWidth = 2,
    );
    // Ladder rungs
    for (int i = 0; i < 4; i++) {
      final ry = groundY - h * (0.025 + i * 0.018);
      canvas.drawLine(
        Offset(w * 0.508, ry),
        Offset(w * 0.539, ry),
        Paint()
          ..color = const Color(0xFFCC4422).withValues(alpha: 0.70)
          ..strokeWidth = 1.5,
      );
    }

    // ── SWING SET ───────────────────────────────────────────
    // A-frame left post
    canvas.drawLine(
      Offset(w * 0.558, groundY),
      Offset(w * 0.572, groundY - h * 0.095),
      Paint()
        ..color = const Color(0xFF886622).withValues(alpha: 0.85)
        ..strokeWidth = 3,
    );
    // A-frame right post
    canvas.drawLine(
      Offset(w * 0.622, groundY),
      Offset(w * 0.608, groundY - h * 0.095),
      Paint()
        ..color = const Color(0xFF886622).withValues(alpha: 0.85)
        ..strokeWidth = 3,
    );
    // Cross bar
    canvas.drawLine(
      Offset(w * 0.572, groundY - h * 0.095),
      Offset(w * 0.608, groundY - h * 0.095),
      Paint()
        ..color = const Color(0xFF886622).withValues(alpha: 0.85)
        ..strokeWidth = 3,
    );

    // Swing 1 — animated
    final swingAngle = sin(worldPhase * pi * 2 * 0.8) * 0.22;
    _drawSwing(canvas, w * 0.582, groundY - h * 0.095, h * 0.058, swingAngle,
        const Color(0xFF6C63FF), w);

    // Swing 2 — offset phase
    final swingAngle2 = sin(worldPhase * pi * 2 * 0.8 + pi * 0.6) * 0.18;
    _drawSwing(canvas, w * 0.598, groundY - h * 0.095, h * 0.055, swingAngle2,
        const Color(0xFFFF6B8A), w);
  }

  void _drawSwing(Canvas canvas, double pivotX, double pivotY, double ropeLen,
      double angle, Color seatColor, double w) {
    final seatX = pivotX + sin(angle) * ropeLen;
    final seatY = pivotY + cos(angle) * ropeLen;

    // Rope left
    canvas.drawLine(
      Offset(pivotX - w * 0.006, pivotY),
      Offset(seatX - w * 0.008, seatY),
      Paint()
        ..color = const Color(0xFFAA8844).withValues(alpha: 0.75)
        ..strokeWidth = 1.2,
    );
    // Rope right
    canvas.drawLine(
      Offset(pivotX + w * 0.006, pivotY),
      Offset(seatX + w * 0.008, seatY),
      Paint()
        ..color = const Color(0xFFAA8844).withValues(alpha: 0.75)
        ..strokeWidth = 1.2,
    );
    // Seat plank
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(seatX, seatY + 3),
          width: w * 0.022,
          height: 5,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = seatColor.withValues(alpha: 0.88),
    );
  }

  // ── 3D LEFT HOUSE (Chicken Lips — purple) ──────────────────
  // Layout: door RIGHT, 2 upper windows, 1 large lower-right window
  void _drawLeftHouse(Canvas canvas, double w, double h) {
    final wallL    = w * 0.082;
    final wallW    = w * 0.225;
    final wallBot  = h * 0.735;
    final wallH    = h * 0.315;
    final roofH    = h * 0.130;
    final sideD    = w * 0.050;
    final sideTopY = wallBot - wallH + h * 0.022;
    final ridgeX   = wallL + wallW / 2;
    final ridgeY   = wallBot - wallH - roofH;
    final sideR    = wallL + wallW;

    // Ground shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(wallL - w*0.010, wallBot - 6, wallW + sideD + w*0.020, 12),
        const Radius.circular(8),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // 3D side face (right) — drawn first so front wall covers left edge
    canvas.drawPath(
      Path()
        ..moveTo(sideR, wallBot - wallH)
        ..lineTo(sideR + sideD, sideTopY)
        ..lineTo(sideR + sideD, wallBot)
        ..lineTo(sideR, wallBot)
        ..close(),
      Paint()..color = const Color(0xFF8B2A1E),
    );

    // Front wall
    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()..color = const Color(0xFFB03A2A),
    );

    // Roof front - left lighter
    canvas.drawPath(
      Path()
        ..moveTo(wallL - w*0.016, wallBot - wallH)
        ..lineTo(ridgeX, ridgeY)
        ..lineTo(sideR + w*0.016, wallBot - wallH)
        ..close(),
      Paint()..color = const Color(0xFF9060CC),
    );
    // Roof front - right darker
    canvas.drawPath(
      Path()
        ..moveTo(ridgeX, ridgeY)
        ..lineTo(sideR + w*0.016, wallBot - wallH)
        ..lineTo(ridgeX, wallBot - wallH)
        ..close(),
      Paint()..color = const Color(0xFF6B44A0),
    );
    // Roof tile courses — horizontal rows clipped to front face
    {
      final tileClip = Path()
        ..moveTo(wallL - w * 0.016, wallBot - wallH)
        ..lineTo(ridgeX, ridgeY)
        ..lineTo(sideR + w * 0.016, wallBot - wallH)
        ..close();
      canvas.save();
      canvas.clipPath(tileClip);
      const rows = 7;
      for (int i = 1; i < rows; i++) {
        final ty = ridgeY + (wallBot - wallH - ridgeY) * i / rows;
        canvas.drawLine(
          Offset(wallL - w * 0.020, ty),
          Offset(sideR + w * 0.020, ty),
          Paint()
            ..color = const Color(0xFF1A0830).withValues(alpha: 0.80)
            ..strokeWidth = 2.0,
        );
        canvas.drawLine(
          Offset(wallL - w * 0.020, ty - 2),
          Offset(sideR + w * 0.020, ty - 2),
          Paint()
            ..color = const Color(0xFFE8CEFF).withValues(alpha: 0.40)
            ..strokeWidth = 1.0,
        );
      }
      canvas.restore();
    }
    // Roof 3D side face
    canvas.drawPath(
      Path()
        ..moveTo(sideR + w*0.016, wallBot - wallH)
        ..lineTo(sideR + sideD + w*0.016, sideTopY)
        ..lineTo(ridgeX + sideD*0.85, ridgeY + h*0.022)
        ..lineTo(ridgeX, ridgeY)
        ..close(),
      Paint()..color = const Color(0xFF200E40),
    );
    // Ridge cap
    canvas.drawLine(
      Offset(ridgeX, ridgeY),
      Offset(ridgeX + sideD*0.85, ridgeY + h*0.022),
      Paint()..color = const Color(0xFF9B6AC0).withValues(alpha: 0.80)..strokeWidth = 2,
    );
    // Chimney
    canvas.drawRect(
      Rect.fromLTWH(wallL + wallW*0.60, wallBot - wallH - roofH*0.72, w*0.018, roofH*0.58),
      Paint()..color = const Color(0xFF6A4080),
    );

    if (theme.showSnowOnRoof) {
      canvas.drawPath(
        Path()
          ..moveTo(wallL - w*0.016, wallBot - wallH)
          ..lineTo(ridgeX, ridgeY)
          ..lineTo(ridgeX, ridgeY + h*0.015)
          ..lineTo(wallL - w*0.016, wallBot - wallH + h*0.018)
          ..close(),
        Paint()..color = const Color(0xFFDDEEFF).withValues(alpha: 0.65),
      );
    }

    final winGlow = (sin(windowPhase * pi * 2) + 1) / 2;
    final winCol = Color.lerp(
      theme.leftWindowGlow.withValues(alpha: 0.58),
      theme.leftWindowGlow.withValues(alpha: 0.90),
      winGlow,
    )!;

    // TWO UPPER WINDOWS — large, well spaced
    final winW = wallW * 0.28;
    final winH = wallH * 0.22;
    final winY = wallBot - wallH + wallH * 0.08;
    final win1X = wallL + wallW * 0.06;
    final win2X = wallL + wallW * 0.62;
    _window3d(canvas, win1X, winY, winW, winH, winCol, sideD * 0.3);
    _window3d(canvas, win2X, winY, winW, winH, winCol, sideD * 0.3);

    if (theme.showFlowerBoxes) {
      _flowerBox(canvas, win1X, winY + winH + 1, winW, theme.leftHouseAccent);
      _flowerBox(canvas, win2X, winY + winH + 1, winW, theme.leftHouseAccent);
    }

    // BAY WINDOW — large, lower front, between the two upper windows
    final bayX = wallL + wallW * 0.10;
    final bayW = wallW * 0.55;
    final bayH = wallH * 0.26;
    final bayY = wallBot - wallH * 0.42;
    // Bay glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(bayX - 4, bayY - 4, bayW + 8, bayH + 4), const Radius.circular(5)),
      Paint()..color = winCol.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Bay frame
    canvas.drawRect(Rect.fromLTWH(bayX - 5, bayY - 5, bayW + 10, bayH + 5), Paint()..color = const Color(0xFF8B2A1E));
    // Bay glass
    canvas.drawRect(Rect.fromLTWH(bayX, bayY, bayW, bayH), Paint()..color = winCol.withValues(alpha: 0.75));
    // Bay dividers (3 panes)
    canvas.drawLine(Offset(bayX + bayW/3, bayY + 2), Offset(bayX + bayW/3, bayY + bayH - 2),
        Paint()..color = Colors.white.withValues(alpha: 0.30)..strokeWidth = 2);
    canvas.drawLine(Offset(bayX + bayW*2/3, bayY + 2), Offset(bayX + bayW*2/3, bayY + bayH - 2),
        Paint()..color = Colors.white.withValues(alpha: 0.30)..strokeWidth = 2);
    canvas.drawLine(Offset(bayX + 2, bayY + bayH/2), Offset(bayX + bayW - 2, bayY + bayH/2),
        Paint()..color = Colors.white.withValues(alpha: 0.20)..strokeWidth = 1.5);
    // Bay border
    canvas.drawRect(Rect.fromLTWH(bayX, bayY, bayW, bayH),
        Paint()..color = Colors.white.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 2);

    // ENTRANCE DOOR — right side, clearly separated from bay window
    _door3d(canvas, sideR - w*0.068, wallBot, w*0.050, h*0.112,
        theme.leftHouseAccent, sideD*0.3);
    _porch(canvas, sideR - w*0.068, wallBot - h*0.112,
        w*0.075, h*0.026, theme.leftHouseAccent);

    // SIDE FACE FEATURES — garage + side door + side window
    // All drawn as perspective parallelograms following the side face angle
    // Side face: x goes from sideR to sideR+sideD, y goes from wallBot-wallH to wallBot
    // Skew factor: for every unit down, x shifts right by sideD/(wallH)
    final skew = sideD / wallH;

    // Helper: convert side-face local coords (sx=0..1, sy=0..1) to canvas
    // sx=0 = front edge, sx=1 = back edge; sy=0 = top of wall, sy=1 = bottom
    Offset sidePoint(double sx, double sy) {
      final x = sideR + sx * sideD;
      final y = (wallBot - wallH) + sy * wallH + sx * (sideTopY - (wallBot - wallH));
      return Offset(x, y);
    }

    // Garage door on side face — lower portion
    final g1 = sidePoint(0.05, 0.52);
    final g2 = sidePoint(0.92, 0.52);
    final g3 = sidePoint(0.92, 1.00);
    final g4 = sidePoint(0.05, 1.00);
    canvas.drawPath(
      Path()..moveTo(g1.dx, g1.dy)..lineTo(g2.dx, g2.dy)..lineTo(g3.dx, g3.dy)..lineTo(g4.dx, g4.dy)..close(),
      Paint()..color = const Color(0xFF2A1A30),
    );
    canvas.drawPath(
      Path()..moveTo(g1.dx, g1.dy)..lineTo(g2.dx, g2.dy)..lineTo(g3.dx, g3.dy)..lineTo(g4.dx, g4.dy)..close(),
      Paint()..color = winCol.withValues(alpha: 0.22),
    );
    // Garage panel lines
    for (int i = 1; i < 4; i++) {
      final p1 = sidePoint(0.05, 0.52 + i * 0.12);
      final p2 = sidePoint(0.92, 0.52 + i * 0.12);
      canvas.drawLine(p1, p2, Paint()..color = const Color(0xFF6A4080).withValues(alpha: 0.5)..strokeWidth = 1.5);
    }
    // Vertical centre split
    final gMid1 = sidePoint(0.485, 0.52);
    final gMid2 = sidePoint(0.485, 1.00);
    canvas.drawLine(gMid1, gMid2, Paint()..color = const Color(0xFF6A4080).withValues(alpha: 0.35)..strokeWidth = 1);
    // Garage border
    canvas.drawPath(
      Path()..moveTo(g1.dx, g1.dy)..lineTo(g2.dx, g2.dy)..lineTo(g3.dx, g3.dy)..lineTo(g4.dx, g4.dy)..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.18)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
    // Garage handle
    final gH = sidePoint(0.48, 0.96);
    canvas.drawOval(Rect.fromCenter(center: gH, width: sideD*0.18, height: h*0.012),
        Paint()..color = Colors.white.withValues(alpha: 0.45));

    // Side window — upper portion of side face
    final sw1 = sidePoint(0.12, 0.10);
    final sw2 = sidePoint(0.85, 0.10);
    final sw3 = sidePoint(0.85, 0.42);
    final sw4 = sidePoint(0.12, 0.42);
    canvas.drawPath(
      Path()..moveTo(sw1.dx, sw1.dy)..lineTo(sw2.dx, sw2.dy)..lineTo(sw3.dx, sw3.dy)..lineTo(sw4.dx, sw4.dy)..close(),
      Paint()..color = winCol.withValues(alpha: 0.70),
    );
    // Side window cross divider
    final swMidH1 = sidePoint(0.12, 0.26);
    final swMidH2 = sidePoint(0.85, 0.26);
    canvas.drawLine(swMidH1, swMidH2, Paint()..color = Colors.white.withValues(alpha: 0.28)..strokeWidth = 1.5);
    final swMidV1 = sidePoint(0.485, 0.10);
    final swMidV2 = sidePoint(0.485, 0.42);
    canvas.drawLine(swMidV1, swMidV2, Paint()..color = Colors.white.withValues(alpha: 0.28)..strokeWidth = 1.5);
    canvas.drawPath(
      Path()..moveTo(sw1.dx, sw1.dy)..lineTo(sw2.dx, sw2.dy)..lineTo(sw3.dx, sw3.dy)..lineTo(sw4.dx, sw4.dy)..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.20)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    if (theme.showPumpkins) {
      _pumpkin(canvas, wallL + wallW*0.78, wallBot, w*0.022);
    }
    if (theme.showChristmasLights) {
      _christmasLights(canvas, wallL - w*0.016, wallBot - wallH,
          wallW + w*0.032, theme.leftHouseAccent);
    }

    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()
        ..color = theme.leftHouseAccent.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawRightHouse(Canvas canvas, double w, double h) {
    final wallL    = w * 0.635;
    final wallW    = w * 0.235;
    final wallBot  = h * 0.735;
    final wallH    = h * 0.305;
    final roofH    = h * 0.116;
    final sideD    = w * 0.050;
    final sideTopY = wallBot - wallH + h * 0.020;
    final ridgeX   = wallL + wallW / 2;
    final ridgeY   = wallBot - wallH - roofH;

    // Ground shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(wallL - sideD - w*0.010, wallBot - 6, wallW + sideD + w*0.020, 12),
        const Radius.circular(8),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // 3D side face (left)
    canvas.drawPath(
      Path()
        ..moveTo(wallL, wallBot - wallH)
        ..lineTo(wallL - sideD, sideTopY)
        ..lineTo(wallL - sideD, wallBot)
        ..lineTo(wallL, wallBot)
        ..close(),
      Paint()..color = const Color(0xFF7A2018),
    );

    // Front wall
    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()..color = const Color(0xFFB03A2A),
    );

    // Roof front face
    canvas.drawPath(
      Path()
        ..moveTo(wallL - w*0.004, wallBot - wallH + h * 0.010)
        ..lineTo(ridgeX, ridgeY)
        ..lineTo(wallL + wallW + w*0.016, wallBot - wallH + h * 0.010)
        ..close(),
      Paint()..color = const Color(0xFF1A5E24),
    );
    canvas.drawPath(
      Path()
        ..moveTo(ridgeX, ridgeY)
        ..lineTo(wallL + wallW + w*0.016, wallBot - wallH + h * 0.010)
        ..lineTo(ridgeX, wallBot - wallH + h * 0.010)
        ..close(),
      Paint()..color = const Color(0xFF0E3A18),
    );
    // Roof tile courses — horizontal rows clipped to front face
    {
      final tileClip = Path()
        ..moveTo(wallL - w * 0.004, wallBot - wallH + h * 0.010)
        ..lineTo(ridgeX, ridgeY)
        ..lineTo(wallL + wallW + w * 0.016, wallBot - wallH + h * 0.010)
        ..close();
      canvas.save();
      canvas.clipPath(tileClip);
      const rows = 7;
      for (int i = 1; i < rows; i++) {
        final ty = ridgeY + (wallBot - wallH + h * 0.010 - ridgeY) * i / rows;
        canvas.drawLine(
          Offset(wallL - w * 0.020, ty),
          Offset(wallL + wallW + w * 0.020, ty),
          Paint()
            ..color = const Color(0xFF0A2010).withValues(alpha: 0.20)
            ..strokeWidth = 1.5,
        );
        canvas.drawLine(
          Offset(wallL - w * 0.020, ty - 2),
          Offset(wallL + wallW + w * 0.020, ty - 2),
          Paint()
            ..color = const Color(0xFF5AAA70).withValues(alpha: 0.08)
            ..strokeWidth = 1.0,
        );
      }
      canvas.restore();
    }
    // Roof 3D side face (right)
    canvas.drawPath(
      Path()
        ..moveTo(wallL + wallW + w*0.016, wallBot - wallH + h * 0.010)
        ..lineTo(wallL + wallW + sideD + w*0.016, sideTopY)
        ..lineTo(ridgeX + sideD*0.85, ridgeY + h*0.022)
        ..lineTo(ridgeX, ridgeY)
        ..close(),
      Paint()..color = const Color(0xFF0E3018),
    );
    canvas.drawLine(
      Offset(ridgeX, ridgeY),
      Offset(ridgeX + sideD*0.85, ridgeY + h*0.022),
      Paint()..color = const Color(0xFF5A9060).withValues(alpha: 0.38)..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTWH(wallL + wallW*0.60, wallBot - wallH - roofH*0.72, w*0.018, roofH*0.58),
      Paint()..color = const Color(0xFF4A7050),
    );

    if (theme.showSnowOnRoof) {
      canvas.drawPath(
        Path()
          ..moveTo(wallL - w*0.004, wallBot - wallH + h * 0.010)
          ..lineTo(ridgeX, ridgeY)
          ..lineTo(ridgeX, ridgeY + h*0.015)
          ..lineTo(wallL - w*0.004, wallBot - wallH + h*0.028)
          ..close(),
        Paint()..color = const Color(0xFFDDEEFF).withValues(alpha: 0.65),
      );
    }

    final winGlow = (sin(windowPhase * pi * 2) + 1) / 2;
    final winCol = Color.lerp(
      theme.rightWindowGlow.withValues(alpha: 0.58),
      theme.rightWindowGlow.withValues(alpha: 0.90),
      winGlow,
    )!;

    // TWO UPPER WINDOWS — large, well spaced
    final winW = wallW * 0.28;
    final winH = wallH * 0.22;
    final winY = wallBot - wallH + wallH * 0.08;
    final win1X = wallL + wallW * 0.06;
    final win2X = wallL + wallW * 0.62;
    _window3d(canvas, win1X, winY, winW, winH, winCol, sideD * 0.3);
    _window3d(canvas, win2X, winY, winW, winH, winCol, sideD * 0.3);

    if (theme.showFlowerBoxes) {
      _flowerBox(canvas, win1X, winY + winH + 1, winW, theme.rightHouseAccent);
      _flowerBox(canvas, win2X, winY + winH + 1, winW, theme.rightHouseAccent);
    }

    // BAY WINDOW — large lower front
    final bayX = wallL + wallW * 0.10;
    final bayW = wallW * 0.55;
    final bayH = wallH * 0.26;
    final bayY = wallBot - wallH * 0.42;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(bayX - 4, bayY - 4, bayW + 8, bayH + 4), const Radius.circular(5)),
      Paint()..color = winCol.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRect(Rect.fromLTWH(bayX - 5, bayY - 5, bayW + 10, bayH + 5), Paint()..color = const Color(0xFF7A2018));
    canvas.drawRect(Rect.fromLTWH(bayX, bayY, bayW, bayH), Paint()..color = winCol.withValues(alpha: 0.75));
    canvas.drawLine(Offset(bayX + bayW/3, bayY + 2), Offset(bayX + bayW/3, bayY + bayH - 2),
        Paint()..color = Colors.white.withValues(alpha: 0.30)..strokeWidth = 2);
    canvas.drawLine(Offset(bayX + bayW*2/3, bayY + 2), Offset(bayX + bayW*2/3, bayY + bayH - 2),
        Paint()..color = Colors.white.withValues(alpha: 0.30)..strokeWidth = 2);
    canvas.drawLine(Offset(bayX + 2, bayY + bayH/2), Offset(bayX + bayW - 2, bayY + bayH/2),
        Paint()..color = Colors.white.withValues(alpha: 0.20)..strokeWidth = 1.5);
    canvas.drawRect(Rect.fromLTWH(bayX, bayY, bayW, bayH),
        Paint()..color = Colors.white.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 2);

    // ENTRANCE DOOR — left side
    _door3d(canvas, wallL + w*0.018, wallBot, w*0.050, h*0.112,
        theme.rightHouseAccent, sideD*0.3);
    _porch(canvas, wallL + w*0.018, wallBot - h*0.112,
        w*0.075, h*0.026, theme.rightHouseAccent);

    // SIDE FACE FEATURES — garage + side window (left face)
    Offset sidePoint(double sx, double sy) {
      final x = wallL - sx * sideD;
      final y = (wallBot - wallH) + sy * wallH + sx * (sideTopY - (wallBot - wallH));
      return Offset(x, y);
    }

    // Garage door on left side face
    final g1 = sidePoint(0.05, 0.52);
    final g2 = sidePoint(0.92, 0.52);
    final g3 = sidePoint(0.92, 1.00);
    final g4 = sidePoint(0.05, 1.00);
    canvas.drawPath(
      Path()..moveTo(g1.dx, g1.dy)..lineTo(g2.dx, g2.dy)..lineTo(g3.dx, g3.dy)..lineTo(g4.dx, g4.dy)..close(),
      Paint()..color = const Color(0xFF0A1A10),
    );
    canvas.drawPath(
      Path()..moveTo(g1.dx, g1.dy)..lineTo(g2.dx, g2.dy)..lineTo(g3.dx, g3.dy)..lineTo(g4.dx, g4.dy)..close(),
      Paint()..color = winCol.withValues(alpha: 0.22),
    );
    for (int i = 1; i < 4; i++) {
      final p1 = sidePoint(0.05, 0.52 + i * 0.12);
      final p2 = sidePoint(0.92, 0.52 + i * 0.12);
      canvas.drawLine(p1, p2, Paint()..color = const Color(0xFF4A8050).withValues(alpha: 0.5)..strokeWidth = 1.5);
    }
    final gMid1 = sidePoint(0.485, 0.52);
    final gMid2 = sidePoint(0.485, 1.00);
    canvas.drawLine(gMid1, gMid2, Paint()..color = const Color(0xFF4A8050).withValues(alpha: 0.35)..strokeWidth = 1);
    canvas.drawPath(
      Path()..moveTo(g1.dx, g1.dy)..lineTo(g2.dx, g2.dy)..lineTo(g3.dx, g3.dy)..lineTo(g4.dx, g4.dy)..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.18)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
    final gH = sidePoint(0.48, 0.96);
    canvas.drawOval(Rect.fromCenter(center: gH, width: sideD*0.18, height: h*0.012),
        Paint()..color = Colors.white.withValues(alpha: 0.45));

    // Side window
    final sw1 = sidePoint(0.12, 0.10);
    final sw2 = sidePoint(0.85, 0.10);
    final sw3 = sidePoint(0.85, 0.42);
    final sw4 = sidePoint(0.12, 0.42);
    canvas.drawPath(
      Path()..moveTo(sw1.dx, sw1.dy)..lineTo(sw2.dx, sw2.dy)..lineTo(sw3.dx, sw3.dy)..lineTo(sw4.dx, sw4.dy)..close(),
      Paint()..color = winCol.withValues(alpha: 0.70),
    );
    final swMidH1 = sidePoint(0.12, 0.26);
    final swMidH2 = sidePoint(0.85, 0.26);
    canvas.drawLine(swMidH1, swMidH2, Paint()..color = Colors.white.withValues(alpha: 0.28)..strokeWidth = 1.5);
    final swMidV1 = sidePoint(0.485, 0.10);
    final swMidV2 = sidePoint(0.485, 0.42);
    canvas.drawLine(swMidV1, swMidV2, Paint()..color = Colors.white.withValues(alpha: 0.28)..strokeWidth = 1.5);
    canvas.drawPath(
      Path()..moveTo(sw1.dx, sw1.dy)..lineTo(sw2.dx, sw2.dy)..lineTo(sw3.dx, sw3.dy)..lineTo(sw4.dx, sw4.dy)..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.20)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    if (theme.showPumpkins) {
      _pumpkin(canvas, wallL + wallW*0.78, wallBot, w*0.022);
    }
    if (theme.showChristmasLights) {
      _christmasLights(canvas, wallL - w*0.016, wallBot - wallH,
          wallW + w*0.032, theme.rightHouseAccent);
    }

    canvas.drawRect(
      Rect.fromLTWH(wallL, wallBot - wallH, wallW, wallH),
      Paint()
        ..color = theme.rightHouseAccent.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _window3d(Canvas canvas, double x, double y, double ww, double wh,
      Color glow, double depth) {
    // Outer frame (stone/plaster surround)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 5, y - 5, ww + 10, wh + 10),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.14),
    );

    // Window reveal depth (side face)
    if (depth.abs() > 1) {
      final reveal = Path()
        ..moveTo(x, y)
        ..lineTo(x + depth, y + 2)
        ..lineTo(x + depth, y + wh - 2)
        ..lineTo(x, y + wh)
        ..close();
      canvas.drawPath(
        reveal,
        Paint()..color = Colors.black.withValues(alpha: 0.30),
      );
    }

    // Glow bloom behind glass
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 3, y - 3, ww + 6, wh + 6),
          const Radius.circular(5)),
      Paint()
        ..color = glow.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Glass background (warm glow)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, ww, wh),
        const Radius.circular(3),
      ),
      Paint()..color = glow.withValues(alpha: 0.82),
    );

    // Window frame — thick outer border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, ww, wh),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Frame dividers — cross
    final framePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(x + ww / 2, y + 2),
      Offset(x + ww / 2, y + wh - 2),
      framePaint,
    );
    canvas.drawLine(
      Offset(x + 2, y + wh / 2),
      Offset(x + ww - 2, y + wh / 2),
      framePaint,
    );

    // Glass reflection — diagonal highlight
    final reflectPath = Path()
      ..moveTo(x + ww * 0.12, y + 4)
      ..lineTo(x + ww * 0.38, y + 4)
      ..lineTo(x + ww * 0.22, y + wh * 0.45)
      ..lineTo(x + ww * 0.06, y + wh * 0.45)
      ..close();
    canvas.drawPath(
      reflectPath,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );

    // Small reflection top-right pane
    canvas.drawRect(
      Rect.fromLTWH(x + ww * 0.58, y + 4, ww * 0.18, wh * 0.18),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );

    // Sill — 3D ledge
    canvas.drawRect(
      Rect.fromLTWH(x - 4, y + wh, ww + 8, 4),
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );
    // Sill underside shadow
    canvas.drawRect(
      Rect.fromLTWH(x - 4, y + wh + 4, ww + 8, 2),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
  }

  // ── Door with frame + step ────────────────────────────────
  void _door3d(Canvas canvas, double x, double bottom, double dw, double dh,
      Color color, double depth) {
    // Door frame
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x - dw / 2 - 3, bottom - dh - 3, dw + 6, dh + 3),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      Paint()..color = color.withValues(alpha: 0.40),
    );
    // Door panel
    final rect = Rect.fromLTWH(x - dw / 2, bottom - dh, dw, dh);
    canvas.drawRRect(
      RRect.fromRectAndCorners(rect,
          topLeft: const Radius.circular(7),
          topRight: const Radius.circular(7)),
      Paint()..color = color.withValues(alpha: 0.92),
    );
    // Door panels detail
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - dw / 2 + 4, bottom - dh + 4, dw - 8, dh * 0.38),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            x - dw / 2 + 4, bottom - dh + dh * 0.44, dw - 8, dh * 0.42),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Handle
    canvas.drawCircle(
      Offset(x + dw * 0.26, bottom - dh * 0.40),
      dw * 0.09,
      Paint()..color = Colors.white.withValues(alpha: 0.62),
    );
    // Step
    canvas.drawRect(
      Rect.fromLTWH(x - dw / 2 - 4, bottom - 5, dw + 8, 5),
      Paint()..color = color.withValues(alpha: 0.35),
    );
  }

  // ── Porch canopy over door ────────────────────────────────
  void _porch(Canvas canvas, double cx, double doorTopY,
      double porchW, double porchH, Color color) {
    final px = cx - porchW / 2;

    // Canopy shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px - 2, doorTopY - porchH - 2, porchW + 4, porchH + 4),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Pitched canopy roof
    final roofPath = Path()
      ..moveTo(px - 6, doorTopY - porchH * 0.4)
      ..lineTo(cx, doorTopY - porchH)
      ..lineTo(px + porchW + 6, doorTopY - porchH * 0.4)
      ..close();
    canvas.drawPath(
      roofPath,
      Paint()..color = color.withValues(alpha: 0.80),
    );

    // Canopy underside shadow
    canvas.drawRect(
      Rect.fromLTWH(px, doorTopY - porchH * 0.4, porchW, 3),
      Paint()..color = Colors.black.withValues(alpha: 0.20),
    );

    // Left post
    canvas.drawRect(
      Rect.fromLTWH(px + 4, doorTopY - porchH * 0.38, 4, porchH * 0.38),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    // Right post
    canvas.drawRect(
      Rect.fromLTWH(px + porchW - 8, doorTopY - porchH * 0.38, 4, porchH * 0.38),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
  }

  void _flowerBox(Canvas canvas, double x, double y, double bw, Color color) {
    canvas.drawRect(
      Rect.fromLTWH(x, y, bw, 4),
      Paint()..color = const Color(0xFF8B5E3C).withValues(alpha: 0.70),
    );
    final rng = Random(x.toInt());
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(x + bw * (0.1 + i * 0.2), y - 3 - rng.nextDouble() * 3),
        2.5,
        Paint()..color = color.withValues(alpha: 0.80),
      );
    }
  }

  void _pumpkin(Canvas canvas, double cx, double bottom, double r) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, bottom - r), width: r * 2.2, height: r * 1.8),
      Paint()..color = const Color(0xFFFF7700).withValues(alpha: 0.85),
    );
    canvas.drawLine(
      Offset(cx, bottom - r * 2),
      Offset(cx, bottom - r * 1.8),
      Paint()
        ..color = const Color(0xFF336600).withValues(alpha: 0.80)
        ..strokeWidth = 1.5,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx - r * 0.5, bottom - r * 1.2, r * 0.25, r * 0.22),
      Paint()..color = Colors.black.withValues(alpha: 0.70),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx + r * 0.22, bottom - r * 1.2, r * 0.25, r * 0.22),
      Paint()..color = Colors.black.withValues(alpha: 0.70),
    );
  }

  void _christmasLights(
      Canvas canvas, double x, double roofY, double totalW, Color baseColor) {
    final colors = [
      const Color(0xFFFF4444),
      const Color(0xFF44FF44),
      baseColor,
      const Color(0xFFFFFF44),
      const Color(0xFFFF44FF),
    ];
    const count = 14;
    for (int i = 0; i < count; i++) {
      final lx = x + (totalW / (count - 1)) * i;
      final sag = sin(i / (count - 1) * pi) * 6;
      canvas.drawCircle(
        Offset(lx, roofY + sag + 4),
        3.5,
        Paint()
          ..color = colors[i % colors.length].withValues(alpha: 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    final wirePath = Path()..moveTo(x, roofY + 4);
    for (int i = 1; i <= count; i++) {
      wirePath.lineTo(x + (totalW / count) * i, roofY + sin(i / count * pi) * 6 + 4);
    }
    canvas.drawPath(
      wirePath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..strokeWidth = 0.7
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawGate(Canvas canvas, double w, double h) {
    final gx = w * 0.474;
    final gBot = h * 0.735;
    final gH = h * 0.122;
    final gW = w * 0.068;

    final paint = Paint()
      ..color = const Color(0xFFE8D5B0).withValues(alpha: 0.80)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(gx, gBot), Offset(gx, gBot - gH), paint);
    canvas.drawLine(
        Offset(gx + gW, gBot), Offset(gx + gW, gBot - gH), paint);
    canvas.drawLine(
        Offset(gx, gBot - gH * 0.25), Offset(gx + gW, gBot - gH * 0.25), paint);
    canvas.drawLine(
        Offset(gx, gBot - gH * 0.65), Offset(gx + gW, gBot - gH * 0.65), paint);

    for (int i = 0; i <= 3; i++) {
      final px = gx + (gW / 3) * i;
      canvas.drawLine(
          Offset(px, gBot - gH * 0.25), Offset(px, gBot - gH), paint);
    }

    if (theme.showSnowOnRoof) {
      canvas.drawCircle(Offset(gx, gBot - gH), 3,
          Paint()..color = const Color(0xFFDDEEFF).withValues(alpha: 0.70));
      canvas.drawCircle(Offset(gx + gW, gBot - gH), 3,
          Paint()..color = const Color(0xFFDDEEFF).withValues(alpha: 0.70));
    }
  }

  @override
  bool shouldRepaint(covariant _HousesPainter old) =>
      old.windowPhase != windowPhase || old.worldPhase != worldPhase;
}

// ── Layer 6: Path + near trees ────────────────────────────────
class _PathAndNearTreesPainter extends CustomPainter {
  final FabWorldTheme theme;
  final double worldPhase;

  const _PathAndNearTreesPainter({required this.theme, required this.worldPhase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Path
    final pathColor = theme.season == FabSeason.winter
        ? const Color(0xFFCCDDEE).withValues(alpha: 0.18)
        : const Color(0xFFBCA77B).withValues(alpha: 0.14);

    final path = Path()
      ..moveTo(w * 0.47, h * 0.735)
      ..quadraticBezierTo(w * 0.50, h * 0.82, w * 0.48, h)
      ..lineTo(w * 0.58, h)
      ..quadraticBezierTo(w * 0.54, h * 0.82, w * 0.54, h * 0.735)
      ..close();

    canvas.drawPath(path, Paint()..color = pathColor);

    // Stepping stones
    final stoneColor = theme.season == FabSeason.winter
        ? const Color(0xFFDDEEFF).withValues(alpha: 0.30)
        : const Color(0xFFE8D5B0).withValues(alpha: 0.20);

    for (int i = 0; i < 5; i++) {
      final y = h * (0.765 + i * 0.042);
      final x = w * (0.505 + sin(i * 1.7) * 0.018);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: w * 0.040, height: h * 0.016),
        Paint()..color = stoneColor,
      );
    }

    // Near frame trees
    final treePaint = Paint()
      ..color = const Color(0xFF082218).withValues(alpha: 0.74)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    _largeTree(canvas, w * 0.015, h * 0.765, w * 0.085, h * 0.360, treePaint, worldPhase, 0);
    _largeTree(canvas, w * 0.960, h * 0.765, w * 0.095, h * 0.390, treePaint, worldPhase, 1.2);
  }

  void _largeTree(Canvas canvas, double x, double base, double treeW, double treeH, Paint paint, double phase, double offset) {
    final sway = sin(phase * pi * 2 + offset) * 2.5;
    final trunk = Paint()..color = const Color(0xFF2A180C).withValues(alpha: 0.66);

    canvas.drawRect(
      Rect.fromLTWH(x - treeW * 0.08, base - treeH * 0.45, treeW * 0.16, treeH * 0.45),
      trunk,
    );

    canvas.drawPath(
      Path()
        ..moveTo(x - treeW * 0.55, base - treeH * 0.05)
        ..lineTo(x + sway, base - treeH)
        ..lineTo(x + treeW * 0.55, base - treeH * 0.05)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(x - treeW * 0.50, base - treeH * 0.28)
        ..lineTo(x + sway * 0.7, base - treeH * 0.92)
        ..lineTo(x + treeW * 0.50, base - treeH * 0.28)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PathAndNearTreesPainter old) =>
      old.worldPhase != worldPhase;
}

// ── Layer 10: Foreground depth vignette ──────────────────────
class _ForegroundPainter extends CustomPainter {
  final FabWorldTheme theme;

  const _ForegroundPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bottom depth strip
    final stripRect = Rect.fromLTWH(0, h * 0.895, w, h * 0.105);
    canvas.drawRect(
      stripRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF0D1B2A).withValues(alpha: 0.50),
            const Color(0xFF0D1B2A).withValues(alpha: 0.90),
          ],
        ).createShader(stripRect),
    );

    // Radial vignette
    final rect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 1.1,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.10),
            Colors.black.withValues(alpha: 0.28),
          ],
          stops: const [0.0, 0.68, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _ForegroundPainter old) => false;
}
