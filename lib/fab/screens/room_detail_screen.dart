import 'package:flutter/material.dart';

// Generic room detail screen: illustrated cave chamber + tappable object plaques.
// Used for all new house interior rooms across Eddie's and Giraffe houses.

class RoomObject {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const RoomObject({
    required this.emoji,
    required this.label,
    required this.onTap,
  });
}

class RoomDetailScreen extends StatelessWidget {
  final String backgroundImage;
  final String roomEmoji;
  final String roomName;
  final List<RoomObject> objects;

  const RoomDetailScreen({
    super.key,
    required this.backgroundImage,
    required this.roomEmoji,
    required this.roomName,
    required this.objects,
  });

  @override
  Widget build(BuildContext context) {
    final scene = _RoomSceneSpec.forName(roomName);

    return Scaffold(
      backgroundColor: scene.base,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 700;
          final sceneHeight = narrow
              ? constraints.maxHeight.clamp(720.0, 980.0)
              : constraints.maxHeight;

          return SingleChildScrollView(
            physics: narrow
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: constraints.maxWidth,
              height: sceneHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    backgroundImage,
                    fit: BoxFit.cover,
                    alignment: narrow ? scene.mobileAlignment : scene.alignment,
                    errorBuilder: (_, __, ___) => DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            scene.base,
                            scene.glow.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.28),
                          Colors.transparent,
                          scene.base.withValues(alpha: narrow ? 0.50 : 0.34),
                        ],
                        stops: const [0.0, 0.46, 1.0],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: SafeArea(
                      child: Stack(
                        children: [
                          Positioned(
                            left: narrow ? 12 : 18,
                            top: narrow ? 10 : 14,
                            right: narrow ? 12 : 18,
                            child: _RoomHeaderPlaque(
                              roomEmoji: roomEmoji,
                              roomName: roomName,
                              accent: scene.glow,
                            ),
                          ),
                          Positioned(
                            left: narrow ? 18 : 30,
                            bottom: narrow ? 26 : 34,
                            child: _HintPlaque(accent: scene.glow),
                          ),
                          ...List.generate(objects.length, (index) {
                            final spot = _plaqueSpot(
                              index,
                              objects.length,
                              narrow,
                            );
                            return _PositionedActionPlaque(
                              obj: objects[index],
                              spot: spot,
                              accent: scene.glow,
                              narrow: narrow,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoomSceneSpec {
  final Color base;
  final Color glow;
  final Alignment alignment;
  final Alignment mobileAlignment;

  const _RoomSceneSpec({
    required this.base,
    required this.glow,
    required this.alignment,
    required this.mobileAlignment,
  });

  static _RoomSceneSpec forName(String name) {
    switch (name) {
      case 'Sleep Room':
        return const _RoomSceneSpec(
          base: Color(0xFF160B2B),
          glow: Color(0xFFC7A0FF),
          alignment: Alignment.center,
          mobileAlignment: Alignment.center,
        );
      case 'Sensory Room':
        return const _RoomSceneSpec(
          base: Color(0xFF221406),
          glow: Color(0xFF7CE8FF),
          alignment: Alignment.center,
          mobileAlignment: Alignment.center,
        );
      case 'School Room':
        return const _RoomSceneSpec(
          base: Color(0xFF241509),
          glow: Color(0xFFFFD27A),
          alignment: Alignment.center,
          mobileAlignment: Alignment.centerLeft,
        );
      case 'Big Feelings Room':
        return const _RoomSceneSpec(
          base: Color(0xFF190B25),
          glow: Color(0xFFDCA7FF),
          alignment: Alignment.center,
          mobileAlignment: Alignment.center,
        );
      case 'Boys’ Room':
        return const _RoomSceneSpec(
          base: Color(0xFF1F1408),
          glow: Color(0xFF72E8E2),
          alignment: Alignment.center,
          mobileAlignment: Alignment.center,
        );
      default:
        return const _RoomSceneSpec(
          base: Color(0xFF12091F),
          glow: Color(0xFFF0D6FF),
          alignment: Alignment.topCenter,
          mobileAlignment: Alignment.center,
        );
    }
  }
}

class _PlaqueSpot {
  final double x;
  final double y;
  final Alignment anchor;

  const _PlaqueSpot(this.x, this.y, this.anchor);
}

_PlaqueSpot _plaqueSpot(int index, int count, bool narrow) {
  final mobile = <_PlaqueSpot>[
    const _PlaqueSpot(0.50, 0.30, Alignment.center),
    const _PlaqueSpot(0.50, 0.45, Alignment.center),
    const _PlaqueSpot(0.50, 0.60, Alignment.center),
    const _PlaqueSpot(0.50, 0.75, Alignment.center),
  ];
  final desktop = <_PlaqueSpot>[
    const _PlaqueSpot(0.22, 0.34, Alignment.center),
    const _PlaqueSpot(0.72, 0.36, Alignment.center),
    const _PlaqueSpot(0.28, 0.68, Alignment.center),
    const _PlaqueSpot(0.68, 0.70, Alignment.center),
  ];

  final spots = narrow ? mobile : desktop;
  if (count == 1) {
    return narrow ? mobile[1] : desktop[1];
  }
  if (count == 2) {
    return (narrow ? [mobile[1], mobile[2]] : [desktop[0], desktop[1]])[index];
  }
  if (count == 3) {
    return (narrow
        ? [mobile[0], mobile[1], mobile[2]]
        : [desktop[0], desktop[1], desktop[2]])[index];
  }
  return spots[index.clamp(0, spots.length - 1)];
}

class _PositionedActionPlaque extends StatelessWidget {
  final RoomObject obj;
  final _PlaqueSpot spot;
  final Color accent;
  final bool narrow;

  const _PositionedActionPlaque({
    required this.obj,
    required this.spot,
    required this.accent,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = narrow ? 260.0 : 300.0;

    return Positioned.fill(
      child: Align(
        alignment: Alignment(spot.x * 2 - 1, spot.y * 2 - 1),
        child: Padding(
          padding: EdgeInsets.all(narrow ? 8 : 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, minHeight: 48),
            child: _ActionPlaque(obj: obj, accent: accent, narrow: narrow),
          ),
        ),
      ),
    );
  }
}

class _RoomHeaderPlaque extends StatelessWidget {
  final String roomEmoji;
  final String roomName;
  final Color accent;

  const _RoomHeaderPlaque({
    required this.roomEmoji,
    required this.roomName,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.26),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.36)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFFFF7EA),
              size: 21,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent.withValues(alpha: 0.32)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.14),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Text(
              '$roomEmoji  $roomName',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFF7EA),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HintPlaque extends StatelessWidget {
  final Color accent;

  const _HintPlaque({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Text(
        'What would you like to do?',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.78),
          fontSize: 12,
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionPlaque extends StatelessWidget {
  final RoomObject obj;
  final Color accent;
  final bool narrow;

  const _ActionPlaque({
    required this.obj,
    required this.accent,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: obj.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: narrow ? 13 : 15,
            vertical: narrow ? 10 : 11,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.38)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(color: accent.withValues(alpha: 0.13), blurRadius: 18),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(obj.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  obj.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFF7EA),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.58),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
