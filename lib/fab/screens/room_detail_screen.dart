import 'package:flutter/material.dart';

// Generic room detail screen: background image + tappable object pills.
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F0520),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A0D35)),
          ),
          // Top scrim
          Positioned(
            top: 0, left: 0, right: 0, height: 130,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F0520).withValues(alpha: 0.80),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom scrim
          Positioned(
            bottom: 0, left: 0, right: 0, height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF0F0520).withValues(alpha: 0.95),
                    const Color(0xFF0F0520).withValues(alpha: 0.60),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D1556).withValues(alpha: 0.70),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFFF0D6FF),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$roomEmoji  $roomName',
                        style: const TextStyle(
                          color: Color(0xFFF0D6FF),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What would you like to do?',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: objects
                            .map((o) => _ObjectPill(obj: o))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectPill extends StatelessWidget {
  final RoomObject obj;
  const _ObjectPill({required this.obj});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: obj.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF2D1556).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFF0D6FF).withValues(alpha: 0.22),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(obj.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              obj.label,
              style: const TextStyle(
                color: Color(0xFFF0D6FF),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: const Color(0xFFF0D6FF).withValues(alpha: 0.40),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper — shows a "coming soon" sheet for unbuilt features.
void showComingSoon(BuildContext context, String featureName) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF150D2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text('✨', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            featureName,
            style: const TextStyle(
              color: Color(0xFFF0D6FF),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon — this space is being built just for you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFF0D6FF).withValues(alpha: 0.55),
              fontSize: 13,
              fontFamily: 'DM Sans',
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}
