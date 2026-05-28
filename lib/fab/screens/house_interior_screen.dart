import 'package:flutter/material.dart';
import '../games/calm_breathing_game.dart';
import '../games/noughts_and_crosses.dart';
import '../models/child_profile.dart';
import '../models/family_account.dart';
import '../screens/recipe_screen.dart';
import '../screens/what_helps_screen.dart';
import '../widgets/calm_lagoon_scene.dart';
import '../widgets/dino_garden_scene.dart';
import '../widgets/safe_corner_scene.dart';
import '../widgets/sleep_nest_scene.dart';

// ─────────────────────────────────────────────────────────────
// HouseInteriorScreen
//
// Slide-in screen shown when the player taps a house in the
// world scene. Presents four tappable room tiles per house,
// each navigating to an existing zone or screen.
//
// Chicken house: Living Room→Safe Corner, Bedroom→Sleep Nest,
//                Kitchen→Recipe, Garden→back
// Giraffe house: Living Room→Calm Lagoon, Garden→Dino Garden,
//                Study→What Helps, Garden Door→back
// ─────────────────────────────────────────────────────────────

enum HouseType { chicken, giraffe }

class HouseInteriorScreen extends StatelessWidget {
  final HouseType house;
  const HouseInteriorScreen({super.key, required this.house});

  static Route<void> route(HouseType house) => PageRouteBuilder(
        pageBuilder: (_, anim, __) => HouseInteriorScreen(house: house),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 340),
      );

  @override
  Widget build(BuildContext context) {
    final isChicken = house == HouseType.chicken;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0820),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isChicken ? '🐔  Chicken Family House' : '🦒  Giraffe Family House',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: _buildInterior(context, isChicken),
    );
  }

  Widget _buildInterior(BuildContext context, bool isChicken) {
    final accent =
        isChicken ? const Color(0xFF6C63FF) : const Color(0xFF00C9A7);
    return Column(
      children: [
        // ── Welcome banner ───────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Text(
                isChicken ? '🐔' : '🦒',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isChicken
                      ? 'Welcome to the Chicken family house!\nWhere would you like to go?'
                      : 'Welcome to the Giraffe family house!\nWhich room shall we visit?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 13,
                    fontFamily: 'DM Sans',
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Room grid ────────────────────────────────────────────
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            children: isChicken
                ? _chickenRooms(context)
                : _giraffeRooms(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _chickenRooms(BuildContext context) => [
        _RoomTile(
          roomEmoji: '🛋️',
          characterEmoji: '🐔',
          label: 'Living Room',
          sublabel: 'Safe Corner',
          accent: const Color(0xFF6C63FF),
          onTap: () => _goScene(context, const SafeCornerScene(),
              const Color(0xFF0D1B3E)),
        ),
        _RoomTile(
          roomEmoji: '🛏️',
          characterEmoji: '😴',
          label: 'Bedroom',
          sublabel: 'Sleep Nest',
          accent: const Color(0xFF3A2D6B),
          onTap: () => _goScene(context, const SleepNestScene(),
              const Color(0xFF050C1A)),
        ),
        _RoomTile(
          roomEmoji: '🍳',
          characterEmoji: '🐔',
          label: 'Kitchen',
          sublabel: 'Favourite Meals',
          accent: const Color(0xFFFFB830),
          onTap: () =>
              _goChildScreen(context, (c) => RecipeScreen(child: c)),
        ),
        _RoomTile(
          roomEmoji: '🎮',
          characterEmoji: '🐔',
          label: 'Games Room',
          sublabel: 'Play a game',
          accent: const Color(0xFFFF6B8A),
          onTap: () => _showGamesSheet(context),
        ),
        _RoomTile(
          roomEmoji: '🚪',
          characterEmoji: '🌿',
          label: 'Garden Door',
          sublabel: 'Back outside',
          accent: const Color(0xFF2E6B3A),
          onTap: () => Navigator.pop(context),
        ),
      ];

  List<Widget> _giraffeRooms(BuildContext context) => [
        _RoomTile(
          roomEmoji: '🌊',
          characterEmoji: '🦒',
          label: 'Living Room',
          sublabel: 'Calm Lagoon',
          accent: const Color(0xFF00C9A7),
          onTap: () => _goCalmLagoon(context),
        ),
        _RoomTile(
          roomEmoji: '🦕',
          characterEmoji: '🌿',
          label: 'Garden',
          sublabel: 'Dino Garden',
          accent: const Color(0xFF3A7B4A),
          onTap: () => _goScene(context, const DinoGardenScene(),
              const Color(0xFF0A1A0F)),
        ),
        _RoomTile(
          roomEmoji: '📚',
          characterEmoji: '🦒',
          label: 'Study',
          sublabel: 'What Helps',
          accent: const Color(0xFFFF6B8A),
          onTap: () =>
              _goChildScreen(context, (c) => WhatHelpsScreen(child: c)),
        ),
        _RoomTile(
          roomEmoji: '🚪',
          characterEmoji: '🌿',
          label: 'Garden Door',
          sublabel: 'Back outside',
          accent: const Color(0xFF2E6B3A),
          onTap: () => Navigator.pop(context),
        ),
      ];

  // ── Navigation helpers ────────────────────────────────────────

  // Calm Lagoon with a breathing-game shortcut button overlaid.
  void _goCalmLagoon(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFF021A24),
          body: SafeArea(
            child: Stack(
              children: [
                const Positioned.fill(child: CalmLagoonScene()),
                Positioned(
                  bottom: 24,
                  right: 20,
                  child: Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                            builder: (_) => const CalmBreathingGame()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C9A7).withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFF00C9A7)
                                  .withValues(alpha: 0.55)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🫁', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text(
                              'Calm breathing',
                              style: TextStyle(
                                color: Color(0xFF00C9A7),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ],
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
    );
  }

  // Games room bottom sheet — choose Noughts & Crosses or Calm Breathing.
  void _showGamesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF150D2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text(
              'Games Room 🎮',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 16),
            _GameSheetTile(
              emoji: '⭕',
              title: 'Noughts & Crosses',
              subtitle: 'Play vs Chicken Lips — win 5 stars!',
              accent: const Color(0xFFFF6B8A),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NoughtsAndCrossesGame()));
              },
            ),
            const SizedBox(height: 12),
            _GameSheetTile(
              emoji: '🫁',
              title: 'Calm Breathing',
              subtitle: '3 rounds of 4-2-6 breathing — earn 3 stars',
              accent: const Color(0xFF00C9A7),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CalmBreathingGame()));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _goScene(BuildContext context, Widget scene, Color bg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: bg,
          body: SafeArea(child: scene),
        ),
      ),
    );
  }

  void _goChildScreen(
      BuildContext context, Widget Function(ChildProfile) builder) {
    final children = FamilyAccount.current?.children ?? [];
    if (children.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a child profile first in Family Settings.'),
          backgroundColor: Color(0xFF2D1B69),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => builder(children.first)),
    );
  }
}

// ── Game Sheet Tile ───────────────────────────────────────────

class _GameSheetTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _GameSheetTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.50),
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: accent.withValues(alpha: 0.60), size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Room Tile ─────────────────────────────────────────────────

class _RoomTile extends StatelessWidget {
  final String roomEmoji;
  final String characterEmoji;
  final String label;
  final String sublabel;
  final Color accent;
  final VoidCallback onTap;

  const _RoomTile({
    required this.roomEmoji,
    required this.characterEmoji,
    required this.label,
    required this.sublabel,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF120C28),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.38), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon circle ──────────────────────────────────────
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(roomEmoji,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 5),
            // ── Character ────────────────────────────────────────
            Text(characterEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            // ── Labels ───────────────────────────────────────────
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 3),
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
    );
  }
}
