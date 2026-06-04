import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// SafeCornerLivingRoom
//
// Chicken House — Safe Corner — a full warm living room.
// Comfy sofa, TV, plants, fairy lights. Tap items for comfort
// messages. Cosy palette, child-friendly.
// ─────────────────────────────────────────────────────────────

class SafeCornerLivingRoom extends StatefulWidget {
  const SafeCornerLivingRoom({super.key});

  @override
  State<SafeCornerLivingRoom> createState() => _SafeCornerLivingRoomState();
}

class _SafeCornerLivingRoomState extends State<SafeCornerLivingRoom>
    with SingleTickerProviderStateMixin {
  String? _activeMessage;
  late final AnimationController _twinkle;

  static const _items = {
    '🛋️': 'Curl up on the sofa. You are safe here. 💜',
    '📺': 'Pick your favourite show. Rest is okay.',
    '🌿': 'The plants are happy you are here.',
    '☕': 'A warm drink helps everything feel better.',
    '🧸': 'Hug your bear. You do not have to explain anything.',
    '🕯️': 'This gentle light is just for you.',
    '🎵': 'Close your eyes and listen. Breathe slowly.',
    '🐔': 'Chicken Lips is right here with you. 🤍',
  };

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
      backgroundColor: const Color(0xFF1A0D30),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E8C).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFFF0D6FF), size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '🤗  Safe Corner',
                    style: TextStyle(
                      color: Color(0xFFF0D6FF),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            // Comfort message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _activeMessage != null
                  ? Container(
                      key: ValueKey(_activeMessage),
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E8C).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFE91E8C)
                                .withValues(alpha: 0.30)),
                      ),
                      child: Text(
                        _activeMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFF0D6FF),
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          height: 1.5,
                        ),
                      ),
                    )
                  : Container(
                      key: const ValueKey('empty'),
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Tap anything in the room to hear a kind word 🌸',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 13,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
            ),
            // Room grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 80,
                ),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final entry = _items.entries.elementAt(i);
                  final active = _activeMessage == entry.value;
                  return GestureDetector(
                    onTap: () => setState(() =>
                        _activeMessage = active ? null : entry.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFE91E8C)
                                .withValues(alpha: 0.20)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: active
                              ? const Color(0xFFE91E8C)
                                  .withValues(alpha: 0.55)
                              : Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 34),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Fairy lights strip at bottom
            AnimatedBuilder(
              animation: _twinkle,
              builder: (_, __) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(12, (i) {
                    const colours = [
                      Color(0xFFFF6B8A),
                      Color(0xFFFFD700),
                      Color(0xFF6C63FF),
                      Color(0xFF00C9A7),
                    ];
                    return Opacity(
                      opacity: 0.4 +
                          0.6 *
                              (((_twinkle.value + i * 0.09) % 1.0)),
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: colours[i % colours.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
