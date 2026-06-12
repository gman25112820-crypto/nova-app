import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Toggle to overlay a blue dot at the placement coord — calibrate by eye.
const bool kDebugWaypoints = false;

// ── Path waypoint system — parked, not wired in current build ─────────────
// Keep for future walking system. Pass [waypoints] to get red debug dots.
class PathWaypoint {
  final String id;
  final Offset fraction;
  final List<String> connections;
  const PathWaypoint({
    required this.id,
    required this.fraction,
    required this.connections,
  });
}
// Walking state that was here:
//   _CharState { idle, walking }
//   _currentId, _targetId, _state, _idleTimer, _idleDuration
//   _walkPhase, _pos, _targetPos, _flipped
//   _walkSpeed = 0.09
//   _beginWalk(), _advanceToTarget(dt)
// All preserved in git history — restore when walking system is reactivated.

/// Static resident character: fixed scene position, idle breathe, shadow.
///
/// Feet land exactly on [sceneFraction] × scene size.
/// Place as [Positioned.fill] inside the scene [Stack].
class CharacterSprite extends StatefulWidget {
  final String assetPath;

  /// Feet land here (scene fractions 0–1).
  final Offset sceneFraction;

  /// Character width as fraction of scene width (before [scale]).
  final double baseWidth;

  /// Uniform scale multiplier — tune per character.
  final double scale;

  /// Parked waypoints: only used for red debug dots when [kDebugWaypoints].
  final List<PathWaypoint> waypoints;

  const CharacterSprite({
    super.key,
    required this.assetPath,
    required this.sceneFraction,
    required this.baseWidth,
    this.scale = 1.0,
    this.waypoints = const [],
  });

  @override
  State<CharacterSprite> createState() => _CharacterSpriteState();
}

class _CharacterSpriteState extends State<CharacterSprite>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration? _lastTick;
  double _idlePhase = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final dt = _lastTick == null
        ? 0.0
        : (elapsed - _lastTick!).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0 || dt > 0.5) return;
    setState(() => _idlePhase += dt);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final sw = constraints.maxWidth;
      final sh = constraints.maxHeight;

      final charW = sw * widget.baseWidth * widget.scale;
      final charH = charW * 1.5; // portrait sprite ratio

      // Slow breathe: ±1.2 % scale + ±2 px vertical bob
      final breatheScale = 1.0 + sin(_idlePhase * 0.8) * 0.012;
      final bobY = sin(_idlePhase * 0.5) * 2.0;

      final cx = widget.sceneFraction.dx * sw;
      final cy = widget.sceneFraction.dy * sh;

      final shadowW = charW * 0.72;
      final shadowH = charW * 0.08;

      return Stack(
        clipBehavior: Clip.none,
        children: [

          // ── Character: feet pinned to (cx, cy + bobY) ───────────────
          // Box bottom edge = cy + bobY; image is bottom-aligned inside.
          Positioned(
            left: cx - charW / 2,
            top: cy - charH + bobY,
            width: charW,
            height: charH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Shadow behind sprite at foot level
                Positioned(
                  bottom: 0,
                  left: (charW - shadowW) / 2,
                  child: Container(
                    width: shadowW,
                    height: shadowH,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                // Sprite — feet sit at box's bottom edge
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.scale(
                    scaleX: breatheScale,
                    scaleY: breatheScale,
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      widget.assetPath,
                      width: charW,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Debug overlay ────────────────────────────────────────────
          if (kDebugWaypoints) ...[
            // Blue dot = active placement (feet target)
            Positioned(
              left: cx - 5,
              top: cy - 5,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Red dots = parked waypoints
            for (final wp in widget.waypoints)
              Positioned(
                left: wp.fraction.dx * sw - 4,
                top: wp.fraction.dy * sh - 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],

        ],
      );
    });
  }
}
