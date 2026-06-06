import 'package:flutter/material.dart';
import '../games/calm_breathing_game.dart';
import '../games/noughts_and_crosses.dart';
import '../models/child_profile.dart';
import '../models/family_account.dart';
import '../screens/recipe_screen.dart';
import '../screens/what_helps_screen.dart';
import '../widgets/calm_lagoon_scene.dart';
import '../screens/dino_garden_screen.dart';
// New rooms
import '../screens/kitchen_meal_picker.dart';
import '../screens/giraffe_sleep_nest_screen.dart';
import '../screens/lynsey_house_screen.dart';
// Garden activity screens (also used in games sheet)
import '../screens/shared_garden_screen.dart'
    show CreateTogetherScreen, MusicCornerScreen;
// Generic room detail screen + health tracker screens
import '../screens/room_detail_screen.dart';
import '../screens/mood_screen.dart';
import '../screens/sleep_screen.dart';
import '../screens/energy_screen.dart';
import '../screens/worry_zone_screen.dart';
import '../screens/cooking_screen.dart';

// ─────────────────────────────────────────────────────────────
// HouseInteriorScreen
//
// Slide-in screen shown when the player taps a house in the
// world scene. Rich gradient room tiles, fade+scale zone entry.
// ─────────────────────────────────────────────────────────────

enum HouseType { chicken, giraffe, lynsey, teen, littleOnes }

/// Map a child's AgeMode to the appropriate HouseType.
HouseType houseTypeForAge(int age) {
  if (age <= 3)  return HouseType.littleOnes;
  if (age <= 6)  return HouseType.giraffe;
  if (age <= 9)  return HouseType.chicken;
  if (age <= 12) return HouseType.lynsey;
  return HouseType.teen;
}

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
    if (house == HouseType.littleOnes) {
      return const _LittleOnesHousePlaceholder();
    }
    if (house == HouseType.teen) {
      return const _TeenSpacePlaceholder();
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
                itemCount: isChicken ? 11 : 6,
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
        // 1 — Chicken Lips Bedroom
        _RoomTile(
          emoji: '🛏️',
          characterEmoji: '🐔',
          label: 'CL Bedroom',
          sublabel: 'Main bedroom',
          accent: const Color(0xFFE91E8C),
          gradient: [const Color(0xFF3D1020), const Color(0xFF2D1040)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/chicken_lips_bedroom_bg.png',
              roomEmoji: '🛏️',
              roomName: 'Chicken Lips Bedroom',
              objects: [
                RoomObject(emoji: '🌙', label: 'Sleep tracker',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepScreen()))),
                RoomObject(emoji: '🪞', label: 'Mood check-in',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodScreen()))),
                RoomObject(emoji: '👗', label: 'Outfit gallery',
                  onTap: () => showComingSoon(context, 'Outfit Gallery')),
              ],
            ))),
        ),
        // 2 — Girl 1 Bedroom
        _RoomTile(
          emoji: '⭐',
          characterEmoji: '🐔',
          label: 'Girl 1 Room',
          sublabel: 'Trophies & desk',
          accent: const Color(0xFF9C27B0),
          gradient: [const Color(0xFF2A0A3A), const Color(0xFF1A0628)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/girl1_bedroom_bg.png',
              roomEmoji: '⭐',
              roomName: 'Girl 1 Bedroom',
              objects: [
                RoomObject(emoji: '⚡', label: 'Energy log',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnergyScreen()))),
                RoomObject(emoji: '🎨', label: 'Creative journal',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTogetherScreen()))),
                RoomObject(emoji: '🏆', label: 'Achievements',
                  onTap: () => showComingSoon(context, 'Achievements')),
              ],
            ))),
        ),
        // 3 — Girl 2 Bedroom
        _RoomTile(
          emoji: '🌿',
          characterEmoji: '🐔',
          label: 'Girl 2 Room',
          sublabel: 'Art & music',
          accent: const Color(0xFF4CAF50),
          gradient: [const Color(0xFF0A2E12), const Color(0xFF061A0A)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/girl2_bedroom_bg.png',
              roomEmoji: '🌿',
              roomName: 'Girl 2 Bedroom',
              objects: [
                RoomObject(emoji: '🌙', label: 'Sleep log',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepScreen()))),
                RoomObject(emoji: '🎵', label: 'Activity tracker',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnergyScreen()))),
                RoomObject(emoji: '💭', label: 'Worry corner',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorryZoneScreen()))),
              ],
            ))),
        ),
        // 4 — Bathroom
        _RoomTile(
          emoji: '🛁',
          characterEmoji: '🐔',
          label: 'Bathroom',
          sublabel: 'Self-care zone',
          accent: const Color(0xFF00BCD4),
          gradient: [const Color(0xFF042835), const Color(0xFF021520)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/bathroom_bg.png',
              roomEmoji: '🛁',
              roomName: 'Bathroom',
              objects: [
                RoomObject(emoji: '🪞', label: 'Self-care',
                  onTap: () => showComingSoon(context, 'Self-Care Log')),
                RoomObject(emoji: '💧', label: 'Hydration',
                  onTap: () => showComingSoon(context, 'Hydration Tracker')),
                RoomObject(emoji: '🫧', label: 'Relaxation',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalmBreathingGame()))),
              ],
            ))),
        ),
        // 5 — Kitchen + Dining
        _RoomTile(
          emoji: '🍳',
          characterEmoji: '🐔',
          label: 'Kitchen',
          sublabel: 'Meals & cooking',
          accent: const Color(0xFFFFD700),
          gradient: [const Color(0xFF2E1A0A), const Color(0xFF1A0D06)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/kitchen_dining_bg.png',
              roomEmoji: '🍳',
              roomName: 'Kitchen & Dining',
              objects: [
                RoomObject(emoji: '🥗', label: 'Recipes',
                  onTap: () => _goChildScreen(context, (c) => RecipeScreen(child: c))),
                RoomObject(emoji: '📅', label: 'Meal planner',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KitchenMealPicker()))),
                RoomObject(emoji: '👩‍🍳', label: 'Cooking activity',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CookingScreen()))),
              ],
            ))),
        ),
        // 6 — Living Room
        _RoomTile(
          emoji: '🛋️',
          characterEmoji: '🐔',
          label: 'Living Room',
          sublabel: 'Relax & games',
          accent: const Color(0xFFFF6B8A),
          gradient: [const Color(0xFF3D1020), const Color(0xFF2D1040)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/living_room_bg.png',
              roomEmoji: '🛋️',
              roomName: 'Living Room',
              objects: [
                RoomObject(emoji: '🫁', label: 'Breathing game',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalmBreathingGame()))),
                RoomObject(emoji: '🎮', label: 'Games',
                  onTap: () => _showGamesSheet(context)),
                RoomObject(emoji: '📚', label: 'What helps',
                  onTap: () => _goChildScreen(context, (c) => WhatHelpsScreen(child: c))),
              ],
            ))),
        ),
        // 7 — Hallway
        _RoomTile(
          emoji: '🖼️',
          characterEmoji: '🐔',
          label: 'Hallway',
          sublabel: 'Family photos',
          accent: const Color(0xFFFF9800),
          gradient: [const Color(0xFF2E1800), const Color(0xFF1A0E00)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/hallway_bg.png',
              roomEmoji: '🖼️',
              roomName: 'Hallway',
              objects: [
                RoomObject(emoji: '📷', label: 'Memory gallery',
                  onTap: () => showComingSoon(context, 'Memory Gallery')),
                RoomObject(emoji: '🚪', label: 'Explore rooms',
                  onTap: () => Navigator.pop(context)),
              ],
            ))),
        ),
        // 8 — Front Door
        _RoomTile(
          emoji: '🚪',
          characterEmoji: '🐔',
          label: 'Front Door',
          sublabel: 'Go outside',
          accent: const Color(0xFF009688),
          gradient: [const Color(0xFF002E28), const Color(0xFF001A18)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/front_door_bg.png',
              roomEmoji: '🚪',
              roomName: 'Front Door',
              objects: [
                RoomObject(emoji: '🦕', label: 'Dino Garden',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DinoGardenScreen()))),
                RoomObject(emoji: '🪞', label: 'Before-you-go check',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodScreen()))),
              ],
            ))),
        ),
        // 9 — Back Door
        _RoomTile(
          emoji: '🌱',
          characterEmoji: '🐔',
          label: 'Back Door',
          sublabel: 'Garden view',
          accent: const Color(0xFF8BC34A),
          gradient: [const Color(0xFF1A2E04), const Color(0xFF0E1A02)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/back_door_bg.png',
              roomEmoji: '🌱',
              roomName: 'Back Door',
              objects: [
                RoomObject(emoji: '🌿', label: 'Go to garden',
                  onTap: () => Navigator.pop(context)),
                RoomObject(emoji: '🌸', label: 'Nature activity',
                  onTap: () => showComingSoon(context, 'Nature Activity')),
              ],
            ))),
        ),
        // 10 — Safe Corner
        _RoomTile(
          emoji: '💜',
          characterEmoji: '🐔',
          label: 'Safe Corner',
          sublabel: 'Calm space',
          accent: const Color(0xFF7C6AF5),
          gradient: [const Color(0xFF1A0A3A), const Color(0xFF100522)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/safe_corner_bg.png',
              roomEmoji: '💜',
              roomName: 'Safe Corner',
              objects: [
                RoomObject(emoji: '🫙', label: 'Worry tracker',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorryZoneScreen()))),
                RoomObject(emoji: '🪨', label: 'Calm breathing',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalmBreathingGame()))),
              ],
            ))),
        ),
        // 11 — Music Corner
        _RoomTile(
          emoji: '🎵',
          characterEmoji: '🐔',
          label: 'Music Corner',
          sublabel: 'Make some noise',
          accent: const Color(0xFFFFEB3B),
          gradient: [const Color(0xFF2E2800), const Color(0xFF1A1800)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/chicken_lips/music_corner_bg.png',
              roomEmoji: '🎵',
              roomName: 'Music Corner',
              objects: [
                RoomObject(emoji: '🎹', label: 'Sound explorer',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicCornerScreen()))),
                RoomObject(emoji: '🎸', label: 'Music activity',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicCornerScreen()))),
              ],
            ))),
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
        // Giraffe House Attic
        _RoomTile(
          emoji: '🌙',
          characterEmoji: '🦒',
          label: 'Attic Room',
          sublabel: 'Bunk beds & stars',
          accent: const Color(0xFF5C6BC0),
          gradient: [const Color(0xFF0A0A2E), const Color(0xFF05051A)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/giraffe/attic_spare_bedroom_bg.png',
              roomEmoji: '🌙',
              roomName: 'Attic Spare Bedroom',
              objects: [
                RoomObject(emoji: '🛏️', label: 'Sleep tracker',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepScreen()))),
                RoomObject(emoji: '🌟', label: 'Night sky',
                  onTap: () => showComingSoon(context, 'Night Sky Activity')),
                RoomObject(emoji: '📦', label: 'Treasure hunt',
                  onTap: () => showComingSoon(context, 'Treasure Hunt')),
              ],
            ))),
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

// ── Little Ones placeholder ───────────────────────────────────
//
// Shown when HouseType.littleOnes is used without a child profile.
// The real parent log (LittleOnesLogScreen) requires a ChildProfile
// and is accessed from the family dashboard.

class _LittleOnesHousePlaceholder extends StatelessWidget {
  const _LittleOnesHousePlaceholder();

  static const _bg     = Color(0xFF0F0520);
  static const _purple = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
                  const Text(
                    '🐣  Little Ones',
                    style: TextStyle(
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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Text('🐣', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 20),
                  const Text(
                    'Parent observation log',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF0D6FF),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Track sleep, mood, sensory, and communication\n'
                    'moments for your little one.\n\n'
                    'Open the family dashboard and tap your child\'s card to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFF0D6FF).withValues(alpha: 0.60),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _purple.withValues(alpha: 0.45)),
                      ),
                      child: const Text(
                        'Back to the world',
                        style: TextStyle(
                          color: Color(0xFFF0D6FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ── Teen Space placeholder ─────────────────────────────────────

class _TeenSpacePlaceholder extends StatelessWidget {
  const _TeenSpacePlaceholder();

  static const _bg   = Color(0xFF0F0520);
  static const _teal = Color(0xFF00C9A7);

  static const _comingRooms = [
    ('⭐', 'My Journal',      'Private space, just for you'),
    ('💜', 'How I\'m feeling', 'Mood, energy, sleep check-in'),
    ('🎯', 'My Goals',        'Track what matters to you'),
    ('🔒', 'Safe Corner',     'Calm-down tools and breathing'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
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
                  const Text(
                    '⭐  My Space',
                    style: TextStyle(
                      color: Color(0xFFF0D6FF),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _teal.withValues(alpha: 0.30)),
                    ),
                    child: Text(
                      'Coming next',
                      style: TextStyle(
                        color: _teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your space is being built.',
                    style: TextStyle(
                      color: Color(0xFFF0D6FF),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Private, calm, and just for you.',
                    style: TextStyle(
                      color: const Color(0xFFF0D6FF).withValues(alpha: 0.55),
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                itemCount: _comingRooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final room = _comingRooms[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(room.$1, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.$2,
                                style: TextStyle(
                                  color: const Color(0xFFF0D6FF).withValues(alpha: 0.80),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                room.$3,
                                style: TextStyle(
                                  color: const Color(0xFFF0D6FF).withValues(alpha: 0.40),
                                  fontSize: 12,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _teal.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'soon',
                            style: TextStyle(
                              color: _teal.withValues(alpha: 0.70),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
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
