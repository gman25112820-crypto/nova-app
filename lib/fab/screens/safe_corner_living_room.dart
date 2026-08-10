import 'package:flutter/material.dart';

import '../widgets/read_aloud_button.dart';

// SafeCornerLivingRoom
// Underground Calm Room destination with the same Safe Corner interactions.

class SafeCornerLivingRoom extends StatefulWidget {
  const SafeCornerLivingRoom({super.key});

  @override
  State<SafeCornerLivingRoom> createState() => _SafeCornerLivingRoomState();
}

class _SafeCornerLivingRoomState extends State<SafeCornerLivingRoom>
    with SingleTickerProviderStateMixin {
  String? _activeMessage;
  late final AnimationController _twinkle;

  static const _background =
      'assets/images/rooms/underground/calm_room_chamber_bg.png';

  static const _openingGuidance =
      'Tap anything in the room to hear a kind word \u{1F338}';

  static const _items = [
    _ComfortItem(
      emoji: '\u{1F6CB}\u{FE0F}',
      label: 'Sofa',
      message: 'Curl up on the sofa. You are safe here. \u{1F49C}',
    ),
    _ComfortItem(
      emoji: '\u{1F4FA}',
      label: 'Quiet rest',
      message: 'Resting quietly is okay.',
    ),
    _ComfortItem(
      emoji: '\u{1F33F}',
      label: 'Plants',
      message: 'The plants are happy you are here.',
    ),
    _ComfortItem(
      emoji: '\u{2615}',
      label: 'Warm drink',
      message: 'A warm drink can help some bodies feel cosy.',
    ),
    _ComfortItem(
      emoji: '\u{1F9F8}',
      label: 'Bear',
      message: 'Hug your bear. You do not have to explain anything.',
    ),
    _ComfortItem(
      emoji: '\u{1F56F}\u{FE0F}',
      label: 'Light',
      message: 'This gentle light is just for you.',
    ),
    _ComfortItem(
      emoji: '\u{1F3B5}',
      label: 'Listening',
      message: 'Close your eyes and listen. Breathe slowly.',
    ),
    _ComfortItem(
      emoji: '\u{1F49C}',
      label: 'Kind heart',
      message: 'You are not alone. Someone cares about you. \u{1F49C}',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071C20),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 700;
          final sceneHeight = narrow
              ? constraints.maxHeight.clamp(760.0, 1040.0)
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
                    _background,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF0B3033), Color(0xFF061419)],
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
                          Colors.black.withValues(alpha: 0.22),
                          Colors.transparent,
                          const Color(0xFF061419).withValues(alpha: 0.42),
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
                            child: _CalmHeaderPlaque(),
                          ),
                          Positioned(
                            left: narrow ? 14 : 24,
                            right: narrow ? 14 : null,
                            top: narrow ? 76 : 82,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: _MessagePlaque(
                                key: ValueKey(_activeMessage ?? 'empty'),
                                id: _activeMessage == null
                                    ? 'calm-room-opening'
                                    : 'calm-room-active-message',
                                text: _activeMessage ?? _openingGuidance,
                                active: _activeMessage != null,
                                narrow: narrow,
                              ),
                            ),
                          ),
                          ...List.generate(_items.length, (index) {
                            final item = _items[index];
                            final active = _activeMessage == item.message;
                            return _PositionedComfortObject(
                              item: item,
                              active: active,
                              spot: _comfortSpot(index, narrow),
                              narrow: narrow,
                              onTap: () => setState(
                                () => _activeMessage = active
                                    ? null
                                    : item.message,
                              ),
                            );
                          }),
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: narrow ? 18 : 20,
                            child: _FairyLightsStrip(twinkle: _twinkle),
                          ),
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

class _ComfortItem {
  final String emoji;
  final String label;
  final String message;

  const _ComfortItem({
    required this.emoji,
    required this.label,
    required this.message,
  });
}

class _ComfortSpot {
  final double x;
  final double y;

  const _ComfortSpot(this.x, this.y);
}

_ComfortSpot _comfortSpot(int index, bool narrow) {
  final mobile = <_ComfortSpot>[
    const _ComfortSpot(0.27, 0.31),
    const _ComfortSpot(0.70, 0.34),
    const _ComfortSpot(0.25, 0.47),
    const _ComfortSpot(0.72, 0.50),
    const _ComfortSpot(0.28, 0.64),
    const _ComfortSpot(0.70, 0.66),
    const _ComfortSpot(0.30, 0.80),
    const _ComfortSpot(0.70, 0.82),
  ];
  final desktop = <_ComfortSpot>[
    const _ComfortSpot(0.18, 0.67),
    const _ComfortSpot(0.73, 0.40),
    const _ComfortSpot(0.34, 0.38),
    const _ComfortSpot(0.76, 0.78),
    const _ComfortSpot(0.62, 0.39),
    const _ComfortSpot(0.48, 0.57),
    const _ComfortSpot(0.30, 0.72),
    const _ComfortSpot(0.82, 0.62),
  ];
  return (narrow ? mobile : desktop)[index];
}

class _CalmHeaderPlaque extends StatelessWidget {
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
              border: Border.all(
                color: const Color(0xFF86F3E6).withValues(alpha: 0.36),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF86F3E6).withValues(alpha: 0.16),
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
              border: Border.all(
                color: const Color(0xFF86F3E6).withValues(alpha: 0.32),
              ),
            ),
            child: const Text(
              '\u{1F917}  Calm Room \u{00B7} Safe Corner',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
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

class _MessagePlaque extends StatelessWidget {
  final String id;
  final String text;
  final bool active;
  final bool narrow;

  const _MessagePlaque({
    super.key,
    required this.id,
    required this.text,
    required this.active,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: narrow ? double.infinity : 430),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: active ? 0.30 : 0.20),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(
                0xFF86F3E6,
              ).withValues(alpha: active ? 0.42 : 0.22),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF86F3E6).withValues(alpha: 0.16),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: active
                      ? const Color(0xFFFFF7EA)
                      : Colors.white.withValues(alpha: 0.76),
                  fontSize: narrow ? (active ? 16 : 15) : (active ? 14 : 13),
                  fontFamily: 'DM Sans',
                  height: 1.45,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              FabReadAloudButton(
                id: id,
                text: text,
                margin: const EdgeInsets.only(top: 8),
                color: const Color(0xFF86F3E6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionedComfortObject extends StatefulWidget {
  final _ComfortItem item;
  final bool active;
  final _ComfortSpot spot;
  final bool narrow;
  final VoidCallback onTap;

  const _PositionedComfortObject({
    required this.item,
    required this.active,
    required this.spot,
    required this.narrow,
    required this.onTap,
  });

  @override
  State<_PositionedComfortObject> createState() =>
      _PositionedComfortObjectState();
}

class _PositionedComfortObjectState extends State<_PositionedComfortObject> {
  bool _hovered = false;
  bool _focused = false;
  bool _showTappedLabel = false;

  void _handleTap() {
    widget.onTap();
    setState(() => _showTappedLabel = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showTappedLabel = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final showLabel = _hovered || _focused || _showTappedLabel;

    return Positioned.fill(
      child: Align(
        alignment: Alignment(widget.spot.x * 2 - 1, widget.spot.y * 2 - 1),
        child: FocusableActionDetector(
          onShowFocusHighlight: (value) => setState(() => _focused = value),
          onShowHoverHighlight: (value) => setState(() => _hovered = value),
          child: Padding(
            padding: EdgeInsets.all(widget.narrow ? 8 : 10),
            child: Semantics(
              button: true,
              enabled: true,
              label: '${widget.item.label}. Tap for a kind calming message.',
              onTap: _handleTap,
              child: GestureDetector(
                onTap: _handleTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: widget.narrow ? 56 : 62,
                      height: widget.narrow ? 56 : 62,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: widget.active ? 0.34 : 0.22,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(
                            0xFF86F3E6,
                          ).withValues(alpha: widget.active ? 0.58 : 0.28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: const Color(
                              0xFF86F3E6,
                            ).withValues(alpha: widget.active ? 0.24 : 0.10),
                            blurRadius: widget.active ? 22 : 14,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.item.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    Positioned(
                      top: -26,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: showLabel ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.42),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(
                                  0xFF86F3E6,
                                ).withValues(alpha: 0.30),
                              ),
                            ),
                            child: Text(
                              widget.item.label,
                              style: const TextStyle(
                                color: Color(0xFFFFF7EA),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FairyLightsStrip extends StatelessWidget {
  final Animation<double> twinkle;

  const _FairyLightsStrip({required this.twinkle});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: twinkle,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(12, (i) {
          const colours = [
            Color(0xFFFFC66D),
            Color(0xFF86F3E6),
            Color(0xFFD8B5FF),
            Color(0xFFFF89B3),
          ];
          return Opacity(
            opacity: 0.32 + 0.42 * (((twinkle.value + i * 0.09) % 1.0)),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colours[i % colours.length],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colours[i % colours.length].withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
