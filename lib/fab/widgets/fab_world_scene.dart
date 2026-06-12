import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
// CHARACTER IMPORTS — commented out for MVP (restore when character assets land)
// import 'living_world_character.dart';
// import 'fab_interaction_system.dart';
// import 'fab_world_theme.dart'; // restored with character system
import 'fab_world_audio.dart';
import 'fab_world_painter.dart';
import 'character_sprite.dart';

// ─────────────────────────────────────────────────────────────
// PATH WAYPOINTS — scene-fraction coordinates (0-1).
// Tune by eye on localhost; connections follow the stone path only.
//
// Full graph (for future characters):
//   leftDoor      → leftPathJoin
//   leftPathJoin  → leftDoor, centreFront, gate
//   centreFront   → leftPathJoin, rightPathJoin
//   gate          → leftPathJoin, rightPathJoin
//   rightPathJoin → centreFront, gate, rightDoor
//   rightDoor     → rightPathJoin
// ─────────────────────────────────────────────────────────────

// Chicken Lips path: leftDoor ↔ centreFront ↔ gate (left side of scene).
const _chickenLipsWaypoints = <PathWaypoint>[
  PathWaypoint(
    id: 'leftDoor',
    fraction: Offset(0.18, 0.78),
    connections: ['leftPathJoin'],
  ),
  PathWaypoint(
    id: 'leftPathJoin',
    fraction: Offset(0.30, 0.86),
    connections: ['leftDoor', 'centreFront', 'gate'],
  ),
  PathWaypoint(
    id: 'centreFront',
    fraction: Offset(0.50, 0.92),
    connections: ['leftPathJoin'],
  ),
  PathWaypoint(
    id: 'gate',
    fraction: Offset(0.50, 0.70),
    connections: ['leftPathJoin'],
  ),
];

// ─────────────────────────────────────────────────────────────
// FAB WORLD SCENE — Parallax 3D + Seasons v6.0
//
// Architecture:
//   Layer 0  Sky gradient / background video  (parallax 0.00)
//   Layer 1  Stars / moon                     (parallax 0.02)
//   Layer 2  Distant mountains                (parallax 0.06)
//   Layer 3  Back forest                      (parallax 0.12)
//   Layer 4  Mid forest                       (parallax 0.20)
//   Layer 5  Houses + gate                    (parallax 0.32)
//   Layer 6  Path / ground                    (parallax 0.42)
//   Layer 7  Characters (back row)  ← HIDDEN  (parallax 0.50)
//   Layer 8  Characters (front row) ← HIDDEN  (parallax 0.62)
//   Layer 9  Season particles                 (parallax 0.70)
//   Layer 10 Foreground vignette              (parallax 1.00)
//
// Characters are temporarily commented out for MVP.
// Restore the CHARACTER IMPORTS above and the commented
// Layer 7 / Layer 8 blocks in build() to bring them back.
//
// Parallax is driven by mouse position on web (auto-drift
// fallback on touch devices). Atmospheric haze is applied
// per layer depth using FabWorldTheme.hazeForDepth().
// ─────────────────────────────────────────────────────────────

class FabWorldScene extends StatefulWidget {
  final FabWorldAudio? audio;
  final Alignment alignment;
  const FabWorldScene({
    super.key,
    this.audio,
    this.alignment = Alignment.topCenter,
  });

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

  // ── Season / theme — used by character system (commented out for MVP) ──
  // late final FabWorldTheme _theme;

  // ── CHARACTER STATE — commented out for MVP ─────────────────
  // Restore these when character assets are ready.
  //
  // late final FabInteractionSystem _interactions;
  // double _lastFrameTime = 0.0;
  //
  // // Cat window state
  // // 0 = left window, 1 = right window, -1 = absent
  // int _cat1Window = 0;
  // int _cat2Window = 1;
  // double _catOpacity1 = 1.0;
  // double _catOpacity2 = 1.0;
  // double _lastCatSwap = 0.0;
  // double _nextCatSwap = 25.0;
  // final _catRng = Random(42);

  @override
  void initState() {
    super.initState();

    // _theme = FabWorldTheme.fromCalendar(); // restored with characters

    _videoCtrl = VideoPlayerController.asset('assets/videos/background_scene.mp4')
      ..initialize().then((_) {
        _videoCtrl!.setVolume(0);
        _videoCtrl!.setLooping(true);
        _videoCtrl!.play();
        if (mounted) setState(() => _videoReady = true);
      });

    // ── CHARACTER SYSTEM INIT — commented out for MVP ──────────
    // _interactions = FabInteractionSystem(theme: _theme);
    // _interactions.initEpisodes();
    // _interactions.onCatStateChange = (c1, c2, o1, o2) {
    //   if (!mounted) return;
    //   setState(() {
    //     _cat1Window = c1;
    //     _cat2Window = c2;
    //     _catOpacity1 = o1;
    //     _catOpacity2 = o2;
    //   });
    // };

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
      // Gentle parallax drift
      final drift = (_parallaxDriftCtrl.value - 0.5) * 2.0; // -1..1
      _targetParallaxX = drift * 0.35;
      _targetParallaxY = sin(drift * pi) * 0.12;

      // ── CHARACTER SYSTEM UPDATE — commented out for MVP ──────
      // final now = _parallaxDriftCtrl.value * 14.0;
      // final dt = (now - _lastFrameTime).abs().clamp(0.0, 0.5);
      // _lastFrameTime = now;
      // _interactions.update(_worldCtrl.value, dt);
      // _interactions.updateEpisodes(dt);

      // ── CHARACTER SOUND CUES — commented out for MVP ─────────
      // Occasional audio cues tied to character world phase.
      // final wp = _worldCtrl.value;
      // if (wp > 0.124 && wp < 0.126) widget.audio?.onCharacterEvent('chicken_lips');
      // if (wp > 0.374 && wp < 0.376) widget.audio?.onCharacterEvent('jack_russell');
      // if (wp > 0.624 && wp < 0.626) widget.audio?.onCharacterEvent('daughter_9');
      // if (wp > 0.874 && wp < 0.876) widget.audio?.onCharacterEvent('dad_giraffe');

      // ── CAT WINDOW SWAP — commented out for MVP ──────────────
      // _lastCatSwap += dt;
      // if (_lastCatSwap >= _nextCatSwap) {
      //   _lastCatSwap = 0;
      //   _nextCatSwap = 20 + _catRng.nextDouble() * 35;
      //   _doSwapCats();
      // }
      // // Fade cats in/out
      // if (_catOpacity1 < 1.0) _catOpacity1 = (_catOpacity1 + dt * 1.5).clamp(0, 1);
      // if (_catOpacity2 < 1.0) _catOpacity2 = (_catOpacity2 + dt * 1.5).clamp(0, 1);

      setState(() {
        _parallaxX += (_targetParallaxX - _parallaxX) * 0.04;
        _parallaxY += (_targetParallaxY - _parallaxY) * 0.04;
      });
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // ── Parallax offsets per layer (used by character layers) ──
            // double px(double factor) => _parallaxX * w * 0.04 * factor;
            // double py(double factor) => _parallaxY * h * 0.02 * factor;

            return MouseRegion(
              onHover: (e) => _onMouseMove(e, Size(w, h)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [

                  // ────────────────────────────────────────────
                  // LAYER 0: Background video (full coverage)
                  // Sky, scenery, houses, trees, garden, path,
                  // seasonal effects — all rendered by the video.
                  // ────────────────────────────────────────────
                  Positioned.fill(
                    child: _videoReady && _videoCtrl != null
                        ? ClipRect(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              alignment: widget.alignment,
                              child: SizedBox(
                                width: _videoCtrl!.value.size.width,
                                height: _videoCtrl!.value.size.height,
                                child: VideoPlayer(_videoCtrl!),
                              ),
                            ),
                          )
                        : CustomPaint(
                            painter: FabWorldPainter(
                              animationValue: _worldCtrl.value,
                            ),
                          ),
                  ),

                  // ────────────────────────────────────────────
                  // LAYER 8 – CHARACTERS (static residents)
                  // Sorted by dy (back → front) when more than one.
                  // Tune sceneFraction by eye with kDebugWaypoints=true.
                  // ────────────────────────────────────────────

                  // Chicken Lips — left house front door
                  Positioned.fill(
                    child: CharacterSprite(
                      assetPath: 'assets/images/characters/chicken_lips.png',
                      sceneFraction: const Offset(0.29, 0.88),
                      baseWidth: 0.108,
                      waypoints: _chickenLipsWaypoints, // red dots only
                    ),
                  ),

                  // Teds — left house porch
                  Positioned.fill(
                    child: CharacterSprite(
                      assetPath: 'assets/images/characters/teds.png',
                      sceneFraction: const Offset(0.345, 0.88),
                      baseWidth: 0.054,
                    ),
                  ),

                  // Daughter 9 — flowerbed left of house front
                  Positioned.fill(
                    child: CharacterSprite(
                      assetPath: 'assets/images/characters/daughter_9.png',
                      sceneFraction: const Offset(0.22, 0.90),
                      baseWidth: 0.081,
                    ),
                  ),

                  // Daughter 7 — flowerbed left of house front
                  Positioned.fill(
                    child: CharacterSprite(
                      assetPath: 'assets/images/characters/daughter_7.png',
                      sceneFraction: const Offset(0.16, 0.91),
                      baseWidth: 0.068,
                    ),
                  ),

                  // Cat1 — left house porch beneath lantern
                  Positioned.fill(
                    child: CharacterSprite(
                      assetPath: 'assets/images/characters/cat1.png',
                      sceneFraction: const Offset(0.365, 0.73),
                      baseWidth: 0.024,
                    ),
                  ),

                  // Cat2 — on the barrel, left side of left house
                  Positioned.fill(
                    child: CharacterSprite(
                      assetPath: 'assets/images/characters/cat2.png',
                      sceneFraction: const Offset(0.105, 0.77),
                      baseWidth: 0.024,
                    ),
                  ),

                  // ────────────────────────────────────────────
                  // LAYER 7 – WINDOW CATS — commented out for MVP
                  // ────────────────────────────────────────────
                  //
                  // Cat 1 — sits in house left or right upper window.
                  // if (_cat1Window >= 0 && _catOpacity1 > 0)
                  //   Positioned(
                  //     left: (_cat1Window == 0
                  //             ? w * 0.116
                  //             : _cat1Window == 1
                  //                 ? w * 0.192
                  //                 : w * 0.116) +
                  //         px(0.35),
                  //     bottom: h * 0.490 + py(0.35),
                  //     child: Transform.scale(
                  //       scale: 0.78,
                  //       alignment: Alignment.bottomCenter,
                  //       child: LivingWorldCharacter(
                  //         assetPath: 'assets/images/characters/cat1.png',
                  //         width: w * 0.058,
                  //         phase: worldP + 0.10,
                  //         motion: LivingCharacterMotion.curious,
                  //         shadowStrength: 0.0,
                  //         depth: 0.68,
                  //         interactionPull: sin(worldP * pi * 2) * 0.4,
                  //       ),
                  //     ),
                  //   ),
                  //
                  // Cat 2 — opposite window from cat 1.
                  // if (_cat2Window >= 0 && _catOpacity2 > 0)
                  //   Positioned(
                  //     left: (_cat2Window == 0
                  //             ? w * 0.130
                  //             : _cat2Window == 1
                  //                 ? w * 0.206
                  //                 : w * 0.206) +
                  //         px(0.35),
                  //     bottom: h * 0.490 + py(0.35),
                  //     child: Transform.scale(
                  //       scale: 0.78,
                  //       alignment: Alignment.bottomCenter,
                  //       child: LivingWorldCharacter(
                  //         assetPath: 'assets/images/characters/cat2.png',
                  //         width: w * 0.058,
                  //         phase: worldP + 0.42,
                  //         motion: LivingCharacterMotion.sleepy,
                  //         shadowStrength: 0.0,
                  //         depth: 0.68,
                  //         flipped: _cat2Window != _cat1Window,
                  //         interactionPull: -sin(worldP * pi * 2) * 0.4,
                  //       ),
                  //     ),
                  //   ),

                  // ────────────────────────────────────────────
                  // LAYER 8 – GROUND CHARACTERS — commented out for MVP
                  //
                  // Restore by un-commenting each _buildChar block
                  // and the imports at the top of this file.
                  // ────────────────────────────────────────────
                  //
                  // Teds (shih tzu)
                  // ..._buildChar(
                  //   w: w, h: h, px: px, py: py, worldP: worldP,
                  //   id: FabCharacterId.teds,
                  //   assetPath: 'assets/images/characters/teds.png',
                  //   baseWidth: 0.064,
                  //   phase: worldP + 0.22,
                  //   motion: LivingCharacterMotion.sleepy,
                  //   shadowStrength: 0.22,
                  // ),
                  //
                  // Daughter 7
                  // ..._buildChar(
                  //   w: w, h: h, px: px, py: py, worldP: worldP,
                  //   id: FabCharacterId.daughter7,
                  //   assetPath: 'assets/images/characters/daughter_7.png',
                  //   baseWidth: 0.068,
                  //   phase: worldP + 0.35,
                  //   motion: LivingCharacterMotion.playful,
                  //   shadowStrength: 0.22,
                  // ),
                  //
                  // Daughter 9
                  // ..._buildChar(
                  //   w: w, h: h, px: px, py: py, worldP: worldP,
                  //   id: FabCharacterId.daughter9,
                  //   assetPath: 'assets/images/characters/daughter_9.png',
                  //   baseWidth: 0.076,
                  //   phase: worldP + 0.55,
                  //   motion: LivingCharacterMotion.curious,
                  //   shadowStrength: 0.26,
                  // ),
                  //
                  // Miss Chicken Lips
                  // ..._buildChar(
                  //   w: w, h: h, px: px, py: py, worldP: worldP,
                  //   id: FabCharacterId.chickenLips,
                  //   assetPath: 'assets/images/chicken_lips.png',
                  //   baseWidth: 0.096,
                  //   phase: worldP + 0.74,
                  //   motion: LivingCharacterMotion.protective,
                  //   shadowStrength: 0.32,
                  // ),
                  //
                  // Eddie (Jack Russell)
                  // ..._buildChar(
                  //   w: w, h: h, px: px, py: py, worldP: worldP,
                  //   id: FabCharacterId.eddie,
                  //   assetPath: 'assets/images/characters/jack_russell.png',
                  //   baseWidth: 0.064,
                  //   phase: worldP + 0.16,
                  //   motion: LivingCharacterMotion.playful,
                  //   shadowStrength: 0.24,
                  // ),
                  //
                  // Ollie (son giraffe 2)
                  // ..._buildChar(
                  //   w: w, h: h, px: px, py: py, worldP: worldP,
                  //   id: FabCharacterId.ollie,
                  //   assetPath: 'assets/images/characters/son_giraffe_2.png',
                  //   baseWidth: 0.090,
                  //   phase: worldP + 0.48,
                  //   motion: LivingCharacterMotion.curious,
                  //   shadowStrength: 0.24,
                  // ),
                  //
                  // Theo (son giraffe 1)
                  // ..._buildChar(
                  //   w: w, h: h, px: px, py: py, worldP: worldP,
                  //   id: FabCharacterId.theo,
                  //   assetPath: 'assets/images/characters/son_giraffe_1.png',
                  //   baseWidth: 0.090,
                  //   phase: worldP + 0.68,
                  //   motion: LivingCharacterMotion.calm,
                  //   shadowStrength: 0.26,
                  // ),
                  //
                  // Dad Giraffe (1.3× bigger than sons)
                  // ..._buildChar(
                  //   w: w, h: h, px: px, py: py, worldP: worldP,
                  //   id: FabCharacterId.dadGiraffe,
                  //   assetPath: 'assets/images/characters/dad_giraffe.png',
                  //   baseWidth: 0.152,
                  //   phase: worldP + 0.86,
                  //   motion: LivingCharacterMotion.protective,
                  //   shadowStrength: 0.36,
                  // ),

                  // ── Debug grid — fraction labels every 0.05 ──────────
                  if (kDebugWaypoints)
                    Positioned.fill(
                      child: CustomPaint(painter: _DebugGridPainter()),
                    ),

                ],
              ),
            );
          },
        );
      },
    );
  }


  // ── Cat window swap — commented out for MVP ──────────────────
  // void _doSwapCats() {
  //   final roll = _catRng.nextDouble();
  //   int new1, new2;
  //   if (roll < 0.30) {
  //     new1 = 0; new2 = 1;
  //   } else if (roll < 0.55) {
  //     new1 = 1; new2 = 0;
  //   } else if (roll < 0.68) {
  //     new1 = 0; new2 = 0;
  //   } else if (roll < 0.78) {
  //     new1 = 1; new2 = 1;
  //   } else if (roll < 0.88) {
  //     new1 = -1; new2 = _catRng.nextBool() ? 0 : 1;
  //   } else if (roll < 0.95) {
  //     new1 = _catRng.nextBool() ? 0 : 1; new2 = -1;
  //   } else {
  //     new1 = -1; new2 = -1;
  //   }
  //   if (new1 != _cat1Window) { _catOpacity1 = 0.0; _cat1Window = new1; }
  //   if (new2 != _cat2Window) { _catOpacity2 = 0.0; _cat2Window = new2; }
  // }

  // ── Build interaction-driven character widget — commented out for MVP
  // List<Widget> _buildChar({
  //   required double w,
  //   required double h,
  //   required double Function(double) px,
  //   required double Function(double) py,
  //   required double worldP,
  //   required FabCharacterId id,
  //   required String assetPath,
  //   required double baseWidth,
  //   required double phase,
  //   required LivingCharacterMotion motion,
  //   required double shadowStrength,
  // }) {
  //   final charX = _interactions.xOf(id);
  //   final flipped = _interactions.flippedOf(id);
  //   final isMoving = _interactions.isMovingOf(id);
  //   final distFromCenter = (charX - 0.5).abs();
  //   final depthScale = 0.82 + distFromCenter * 0.36;
  //   final depth = 0.85 + distFromCenter * 0.30;
  //   final walkBob = isMoving
  //       ? sin(worldP * pi * 16) * h * 0.004
  //       : 0.0;
  //   final Widget char = LivingWorldCharacter(
  //     assetPath: assetPath,
  //     width: w * baseWidth * depthScale,
  //     phase: phase,
  //     motion: isMoving ? LivingCharacterMotion.playful : motion,
  //     shadowStrength: shadowStrength * depthScale,
  //     depth: depth,
  //     interactionPull: 0,
  //     flipped: flipped,
  //   );
  //   return [
  //     Positioned(
  //       left: charX * w + px(0.55),
  //       bottom: h * 0.182 + py(0.55) + walkBob,
  //       child: char,
  //     ),
  //   ];
  // }

}

// ── Debug grid painter ────────────────────────────────────────────────────
// Draws faint lines + fraction labels every 0.05 of scene size.
// Toggled by kDebugWaypoints in character_sprite.dart.
class _DebugGridPainter extends CustomPainter {
  static const _step = 0.05;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0x44FFFFFF)
      ..strokeWidth = 0.5;

    for (var i = 1; i < 20; i++) {
      final f = i * _step;
      final label = f.toStringAsFixed(2);

      // Vertical line + label along the top edge
      final x = f * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      _label(canvas, label, Offset(x + 2, 2));

      // Horizontal line + label along the left edge
      final y = f * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      _label(canvas, label, Offset(2, y + 2));
    }
  }

  void _label(Canvas canvas, String text, Offset offset) {
    (TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xCCFFFF00),
          fontSize: 9,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_DebugGridPainter old) => false;
}
