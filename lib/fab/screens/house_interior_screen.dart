import 'package:flutter/material.dart';
import '../games/calm_breathing_game.dart';
import '../games/noughts_and_crosses.dart';
import '../models/child_profile.dart';
import '../models/family_account.dart';
import '../screens/recipe_screen.dart';
import '../screens/what_helps_screen.dart';
import '../widgets/calm_lagoon_scene.dart';
import '../screens/dino_garden_screen.dart';
import '../widgets/safe_corner_scene.dart';
import '../screens/sleep_nest_screen.dart';
// New rooms
import '../screens/safe_corner_living_room.dart';
import '../screens/kitchen_meal_picker.dart';
import '../screens/giraffe_sleep_nest_screen.dart';
import '../screens/lynsey_house_screen.dart';
import '../widgets/snoring_chickens_widget.dart';
// Garden activity screens (also used in games sheet)
import '../screens/shared_garden_screen.dart'
    show CreateTogetherScreen, MusicCornerScreen;

// ─────────────────────────────────────────────────────────────
// HouseInteriorScreen
//
// Slide-in screen shown when the player taps a house in the
// world scene. Rich gradient room tiles, fade+scale zone entry.
// ─────────────────────────────────────────────────────────────

enum HouseType { chicken, giraffe, lynsey }

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

  // Fade + scale route for entering a zone world.
  static Route<void> _zoneRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, anim, __) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 320),
      );

  @override
  Widget build(BuildContext context) {
    final isChicken = house == HouseType.chicken;
    final isLynsey  = house == HouseType.lynsey;
    // Lynsey's house gets its own dedicated screen
    if (isLynsey) {
      return const LynseyHouseScreen();
    }
    final accent = isChicken
        ? const Color(0xFF7B2FBE)
        : const Color(0xFF4ECDC4);
    return Scaffold(
      backgroundColor: const Color(0xFF0F0520),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
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
                    isChicken ? '🐔  Chicken House' : '🦒  Giraffe House',
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
            // ── Welcome banner ───────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  Text(
                    isChicken ? '🐔' : '🦒',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isChicken
                          ? 'Where would you like to go?'
                          : 'Which room shall we visit?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontSize: 13,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Room grid ────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 180,
                ),
                itemCount: isChicken ? 5 : 5,
                itemBuilder: (_, i) {
                  final rooms = isChicken
                      ? _chickenRooms(context)
                      : _giraffeRooms(context);
                  if (i >= rooms.length) return const SizedBox.shrink();
                  return rooms[i];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _chickenRooms(BuildContext context) => [
        _RoomTile(
          emoji: '🛋️',
          characterEmoji: '🐔',
          label: 'Safe Corner',
          sublabel: 'Cosy Living Room',
          accent: const Color(0xFFE91E8C),
          gradient: [const Color(0xFF3D1020), const Color(0xFF2D1040)],
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SafeCornerLivingRoom())),
        ),
        _RoomTile(
          emoji: '🌙',
          characterEmoji: '😴',
          label: 'Sleep Nest',
          sublabel: 'Two chickens snoozing',
          accent: const Color(0xFF7C6AF5),
          gradient: [const Color(0xFF0A0A2E), const Color(0xFF05051A)],
          onTap: () => _goScene(context,
              const SnoringChickensWidget(), const Color(0xFF050C1A)),
        ),
        _RoomTile(
          emoji: '🍳',
          characterEmoji: '🐔',
          label: 'Kitchen',
          sublabel: 'Pick your meal',
          accent: const Color(0xFFFFD700),
          gradient: [const Color(0xFF2E1A0A), const Color(0xFF1A0D06)],
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const KitchenMealPicker())),
        ),
        _RoomTile(
          emoji: '🎮',
          characterEmoji: '🐔',
          label: 'Games Room',
          sublabel: 'Play a game',
          accent: const Color(0xFFFF6B8A),
          gradient: [const Color(0xFF2A0A3A), const Color(0xFF150820)],
          onTap: () => _showGamesSheet(context),
        ),
        _RoomTile(
          emoji: '🌿',
          characterEmoji: '',
          label: 'Garden Door',
          sublabel: 'Back outside',
          accent: const Color(0xFF4ECDC4),
          gradient: [const Color(0xFF0A2E1A), const Color(0xFF061A10)],
          onTap: () => Navigator.pop(context),
        ),
      ];

  List<Widget> _giraffeRooms(BuildContext context) => [
        _RoomTile(
          emoji: '🐢',
          characterEmoji: '🦒',
          label: 'Calm Lagoon',
          sublabel: 'Living Room',
          accent: const Color(0xFF4ECDC4),
          gradient: [const Color(0xFF0A2E35), const Color(0xFF061820)],
          onTap: () => _goCalmLagoon(context),
        ),
        _RoomTile(
          emoji: '🌙',
          characterEmoji: '🦒',
          label: 'Sleep Nest',
          sublabel: 'Giraffe Bedroom',
          accent: const Color(0xFF7C6AF5),
          gradient: [const Color(0xFF08082E), const Color(0xFF05051A)],
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const GiraffeSleepNestScreen())),
        ),
        _RoomTile(
          emoji: '🦕',
          characterEmoji: '',
          label: 'Dino Garden',
          sublabel: 'Garden',
          accent: const Color(0xFF4CAF50),
          gradient: [const Color(0xFF0A2E12), const Color(0xFF06180A)],
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DinoGardenScreen())),
        ),
        _RoomTile(
          emoji: '📚',
          characterEmoji: '🦒',
          label: 'Study',
          sublabel: 'What Helps',
          accent: const Color(0xFFFFD700),
          gradient: [const Color(0xFF2E2A0A), const Color(0xFF1A1806)],
          onTap: () =>
              _goChildScreen(context, (c) => WhatHelpsScreen(child: c)),
        ),
        _RoomTile(
          emoji: '🚪',
          characterEmoji: '',
          label: 'Garden Door',
          sublabel: 'Back outside',
          accent: const Color(0xFFF0D6FF),
          gradient: [const Color(0xFF0A1A2E), const Color(0xFF060E1A)],
          onTap: () => Navigator.pop(context),
        ),
      ];

  // ── Navigation helpers ────────────────────────────────────────

  static Widget _backButtonOverlay(BuildContext context) => Positioned(
        top: 12,
        left: 12,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2D1556).withValues(alpha: 0.70),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 8),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFF0D6FF),
              size: 20,
            ),
          ),
        ),
      );

  void _goScene(BuildContext context, Widget scene, Color bg) {
    Navigator.push(
      context,
      HouseInteriorScreen._zoneRoute(
        Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(child: scene),
                _backButtonOverlay(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goCalmLagoon(BuildContext context) {
    Navigator.push(
      context,
      HouseInteriorScreen._zoneRoute(
        Scaffold(
          backgroundColor: const Color(0xFF021A24),
          body: SafeArea(
            child: Stack(
              children: [
                const Positioned.fill(child: CalmLagoonScene()),
                _backButtonOverlay(context),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CalmBreathingGame()));
              },
            ),
            const SizedBox(height: 12),
            _GameSheetTile(
              emoji: '🎨',
              title: 'Draw Together',
              subtitle: 'Free drawing — no rules, just colour',
              accent: const Color(0xFFFF8C00),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CreateTogetherScreen()));
              },
            ),
            const SizedBox(height: 12),
            _GameSheetTile(
              emoji: '🎵',
              title: 'Music Corner',
              subtitle: 'Tap the instruments and make some noise',
              accent: const Color(0xFF6C63FF),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MusicCornerScreen()));
              },
            ),
          ],
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
  final String emoji;
  final String characterEmoji;
  final String label;
  final String sublabel;
  final Color accent;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _RoomTile({
    required this.emoji,
    required this.characterEmoji,
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
          border: Border.all(color: accent.withValues(alpha: 0.60), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.20),
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
                  Text(emoji, style: const TextStyle(fontSize: 48)),
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
            if (characterEmoji.isNotEmpty)
              Positioned(
                bottom: 8,
                right: 10,
                child: Text(
                  characterEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
