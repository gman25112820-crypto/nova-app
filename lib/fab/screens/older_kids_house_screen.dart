import 'package:flutter/material.dart';

import 'fab_insights_screen.dart';
import 'mood_calendar_screen.dart';

// ─────────────────────────────────────────────────────────────
// OlderKidsHouseScreen
//
// A house for older kids (teens/pre-teens) — progress and
// recovery focused. Warmer purple-indigo palette. Less playful,
// more empowering.
//
// Rooms:
//   Progress Board  — goals set, goals met, streaks
//   Mood History    — mood calendar and trends
//   My Toolkit      — what helps me / coping strategies
//   Back Outside    — garden door
// ─────────────────────────────────────────────────────────────

class OlderKidsHouseScreen extends StatelessWidget {
  const OlderKidsHouseScreen({super.key});

  static const _accent = Color(0xFF9B59B6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0A20),
      body: SafeArea(
        child: Column(
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
                        color: _accent.withValues(alpha: 0.18),
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
                  const Text(
                    "💜  Older Kids' Space",
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
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accent.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  const Text('💜', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your progress matters. Every single step.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 160,
                ),
                itemCount: 4,
                itemBuilder: (_, i) => _olderKidsRooms(context)[i],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _olderKidsRooms(BuildContext context) => [
    _LRoom(
      emoji: '📈',
      character: '💜',
      label: 'Progress Board',
      sublabel: 'Goals & Streaks',
      accent: const Color(0xFF9B59B6),
      gradient: [const Color(0xFF2C1A4E), const Color(0xFF1A0D30)],
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FabInsightsScreen()),
      ),
    ),
    _LRoom(
      emoji: '📅',
      character: '🌈',
      label: 'Mood History',
      sublabel: '30-day calendar',
      accent: const Color(0xFF6C63FF),
      gradient: [const Color(0xFF1A1240), const Color(0xFF0D0820)],
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MoodCalendarScreen()),
      ),
    ),
    _LRoom(
      emoji: '🧰',
      character: '🛠️',
      label: 'My Toolkit',
      sublabel: 'What helps me',
      accent: const Color(0xFFFF6B8A),
      gradient: [const Color(0xFF2E1020), const Color(0xFF1A0812)],
      onTap: () {},
    ),
    _LRoom(
      emoji: '🚪',
      character: '',
      label: 'Garden Door',
      sublabel: 'Back outside',
      accent: const Color(0xFF4ECDC4),
      gradient: [const Color(0xFF0A2E1A), const Color(0xFF061A10)],
      onTap: () => Navigator.pop(context),
    ),
  ];
}

class _LRoom extends StatelessWidget {
  final String emoji;
  final String character;
  final String label;
  final String sublabel;
  final Color accent;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _LRoom({
    required this.emoji,
    required this.character,
    required this.label,
    required this.sublabel,
    required this.accent,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 46)),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF0D6FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            if (character.isNotEmpty)
              Positioned(
                bottom: 8,
                right: 10,
                child: Text(character, style: const TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}
