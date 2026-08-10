import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../games/calm_breathing_game.dart';
import '../games/noughts_and_crosses.dart';
import '../models/child_profile.dart';
import '../services/selected_child_service.dart';
import '../screens/recipe_screen.dart';
import '../screens/safe_corner_living_room.dart';
import '../screens/what_helps_screen.dart';
// New rooms
import '../screens/kitchen_meal_picker.dart';
import '../screens/lynsey_house_screen.dart';
// Garden activity screens
import '../screens/shared_garden_screen.dart' show CreateTogetherScreen;
// Generic room detail screen + health tracker screens
import '../screens/room_detail_screen.dart';
import '../screens/mood_screen.dart';
import '../screens/sleep_screen.dart';
import '../screens/energy_screen.dart';
import '../screens/worry_zone_screen.dart';
import '../screens/cooking_screen.dart';

// -----------------------------------------------------------------------------
// HouseInteriorScreen
//
// Slide-in screen shown when the player taps a house in the
// world scene. Rich gradient room tiles, fade+scale zone entry.
// -----------------------------------------------------------------------------

enum HouseType { chicken, giraffe, lynsey, teen, littleOnes }

/// Map a child's AgeMode to the appropriate HouseType.
HouseType houseTypeForAge(int age) {
  if (age <= 3) return HouseType.littleOnes;
  if (age <= 6) return HouseType.giraffe;
  if (age <= 9) return HouseType.chicken;
  if (age <= 12) return HouseType.lynsey;
  return HouseType.teen;
}

class HouseInteriorScreen extends StatelessWidget {
  final HouseType house;
  const HouseInteriorScreen({super.key, required this.house});

  static Route<void> route(HouseType house) => PageRouteBuilder(
    pageBuilder: (_, anim, __) => HouseInteriorScreen(house: house),
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 340),
  );

  static const _bg = Color(0xFF0F0520);
  static const _text = Color(0xFFF0D6FF);
  static const _purple = Color(0xFF7B2FBE);
  static const _pink = Color(0xFFE91E8C);
  static const _teal = Color(0xFF4ECDC4);
  static const _amber = Color(0xFFFFB830);
  static const _green = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final isLynsey = house == HouseType.lynsey;
    // Lynsey's house gets its own dedicated screen.
    if (isLynsey) {
      return const LynseyHouseScreen();
    }
    if (house == HouseType.littleOnes) {
      return const _LittleOnesHousePlaceholder();
    }
    if (house == HouseType.teen) {
      return const _TeenSpacePlaceholder();
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: _text,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF2D1556,
                      ).withValues(alpha: 0.70),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'My House',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _LivingHouseNavigation(
                rooms: _livingRooms(context),
                onBackToGarden: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_LivingHouseRoom> _livingRooms(BuildContext context) {
    return [
      _LivingHouseRoom(
        label: 'Sleep Room',
        hint: 'Rest and check in',
        icon: Icons.bedtime_rounded,
        accent: _pink,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailScreen(
              backgroundImage:
                  'assets/images/rooms/underground/sleep_room_chamber_bg.png',
              roomEmoji: '\u{1F6CF}\u{FE0F}',
              roomName: 'Sleep Room',
              objects: [
                RoomObject(
                  emoji: '\u{1F319}',
                  label: 'Sleep tracker',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SleepScreen()),
                  ),
                ),
                RoomObject(
                  emoji: '\u{1FA9E}',
                  label: 'Mood check-in',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MoodScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      _LivingHouseRoom(
        label: 'Big Feelings Room',
        hint: 'Energy, worries and quiet notes',
        icon: Icons.auto_awesome_rounded,
        accent: _purple,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailScreen(
              backgroundImage:
                  'assets/images/rooms/underground/big_feelings_room_chamber_bg.png',
              roomEmoji: '\u{2B50}',
              roomName: 'Big Feelings Room',
              objects: [
                RoomObject(
                  emoji: '\u{26A1}',
                  label: 'Energy log',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EnergyScreen()),
                  ),
                ),
                RoomObject(
                  emoji: '\u{1F3A8}',
                  label: 'Creative journal',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateTogetherScreen(),
                    ),
                  ),
                ),
                RoomObject(
                  emoji: '\u{1F4AD}',
                  label: 'Worry tracker',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WorryZoneScreen()),
                  ),
                ),
                RoomObject(
                  emoji: '\u{1F319}',
                  label: 'Sleep log',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SleepScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      _LivingHouseRoom(
        label: 'Boys’ Room',
        hint: 'Rest, play and check-ins',
        icon: Icons.bed_rounded,
        accent: _teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailScreen(
              backgroundImage:
                  'assets/images/rooms/underground/boys_room_chamber_bg.png',
              roomEmoji: '\u{1F6CF}\u{FE0F}',
              roomName: 'Boys’ Room',
              objects: [
                RoomObject(
                  emoji: '\u{1F319}',
                  label: 'Sleep tracker',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SleepScreen()),
                  ),
                ),
                RoomObject(
                  emoji: '\u{26A1}',
                  label: 'Energy log',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EnergyScreen()),
                  ),
                ),
                RoomObject(
                  emoji: '\u{1FA9E}',
                  label: 'Mood check-in',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MoodScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      _LivingHouseRoom(
        label: 'Kitchen',
        hint: 'Food ideas and cooking',
        icon: Icons.restaurant_rounded,
        accent: _amber,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/underground/kitchen_bg.png',
              roomEmoji: '\u{1F373}',
              roomName: 'Kitchen',
              objects: [
                RoomObject(
                  emoji: '\u{1F957}',
                  label: 'Recipes',
                  onTap: () =>
                      _goChildScreen(context, (c) => RecipeScreen(child: c)),
                ),
                RoomObject(
                  emoji: '\u{1F4C5}',
                  label: 'Meal planner',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KitchenMealPicker(),
                    ),
                  ),
                ),
                RoomObject(
                  emoji: '\u{1F468}\u{200D}\u{1F373}',
                  label: 'Cooking activity',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CookingScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      _LivingHouseRoom(
        label: 'Living Room',
        hint: 'A soft place to look around',
        icon: Icons.weekend_rounded,
        accent: _pink,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailScreen(
              backgroundImage:
                  'assets/images/rooms/underground/living_room_bg.png',
              roomEmoji: '\u{1F6CB}\u{FE0F}',
              roomName: 'Living Room',
              objects: [
                RoomObject(
                  emoji: '\u{1F4DA}',
                  label: 'What helps',
                  onTap: () =>
                      _goChildScreen(context, (c) => WhatHelpsScreen(child: c)),
                ),
              ],
            ),
          ),
        ),
      ),
      _LivingHouseRoom(
        label: 'Sensory Room',
        hint: 'Games to play',
        icon: Icons.sports_esports_rounded,
        accent: const Color(0xFF7C6AF5),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailScreen(
              backgroundImage:
                  'assets/images/rooms/underground/sensory_room_chamber_bg.png',
              roomEmoji: '\u{1F4FA}',
              roomName: 'Sensory Room',
              objects: [
                RoomObject(
                  emoji: '\u{1FAC1}',
                  label: 'Breathing game',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CalmBreathingGame(),
                    ),
                  ),
                ),
                RoomObject(
                  emoji: '\u{2B55}',
                  label: 'Noughts & Crosses',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NoughtsAndCrossesGame(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      _LivingHouseRoom(
        label: 'Calm Room',
        hint: 'A calm space',
        icon: Icons.favorite_rounded,
        accent: const Color(0xFF7C6AF5),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SafeCornerLivingRoom()),
        ),
      ),
      _LivingHouseRoom(
        label: 'School Room',
        hint: 'Focus helper',
        icon: Icons.menu_book_rounded,
        accent: _amber,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailScreen(
              backgroundImage:
                  'assets/images/rooms/underground/school_room_chamber_bg.png',
              roomEmoji: '\u{1F4DA}',
              roomName: 'School Room',
              objects: [
                RoomObject(
                  emoji: '\u{1F4BB}',
                  label: 'Focus helper',
                  onTap: () =>
                      _goChildScreen(context, (c) => WhatHelpsScreen(child: c)),
                ),
              ],
            ),
          ),
        ),
      ),
      _LivingHouseRoom(
        label: 'Music Corner',
        hint: 'Not open yet',
        icon: Icons.music_note_rounded,
        accent: _amber,
        isDisabled: true,
        onTap: null,
      ),
      _LivingHouseRoom(
        label: 'Nursery',
        hint: 'Sleep and mood check-ins',
        icon: Icons.nightlight_round,
        accent: _teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailScreen(
              backgroundImage: 'assets/images/rooms/giraffe/attic_bg.png',
              roomEmoji: '\u{1F37C}',
              roomName: 'Nursery',
              objects: [
                RoomObject(
                  emoji: '\u{1F319}',
                  label: 'Sleep tracker',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SleepScreen()),
                  ),
                ),
                RoomObject(
                  emoji: '\u{1FA9E}',
                  label: 'Mood check-in',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MoodScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  void _goChildScreen(
    BuildContext context,
    Widget Function(ChildProfile) builder,
  ) {
    final child =
        SelectedChildService.current ?? SelectedChildService.selectDefault();
    if (child == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a child profile first in Family Settings.'),
          backgroundColor: Color(0xFF2D1B69),
        ),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => builder(child)));
  }
}

// Little Ones placeholder
//
// Shown when HouseType.littleOnes is used without a child profile.
// The real parent log (LittleOnesLogScreen) requires a ChildProfile
// and is accessed from the family dashboard.

class _LittleOnesHousePlaceholder extends StatelessWidget {
  const _LittleOnesHousePlaceholder();

  static const _bg = Color(0xFF0F0520);
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
                    '\u{1F423}  Little Ones',
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
                  const Text('\u{1F423}', style: TextStyle(fontSize: 64)),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _purple.withValues(alpha: 0.45),
                        ),
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

// Teen Space placeholder

class _TeenSpacePlaceholder extends StatelessWidget {
  const _TeenSpacePlaceholder();

  static const _bg = Color(0xFF0F0520);
  static const _teal = Color(0xFF00C9A7);

  static const _comingRooms = [
    ('\u{2B50}', 'My Journal', 'Private space, just for you'),
    ('\u{1F49C}', 'How I\'m feeling', 'Mood, energy, sleep check-in'),
    ('\u{1F3AF}', 'My Goals', 'Track what matters to you'),
    ('\u{1F512}', 'Safe Corner', 'Calm-down tools and breathing'),
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
                    '\u{2B50}  My Space',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _teal.withValues(alpha: 0.30)),
                    ),
                    child: Text(
                      'Not open yet',
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
                    'Not open yet',
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
                                  color: const Color(
                                    0xFFF0D6FF,
                                  ).withValues(alpha: 0.80),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                room.$3,
                                style: TextStyle(
                                  color: const Color(
                                    0xFFF0D6FF,
                                  ).withValues(alpha: 0.40),
                                  fontSize: 12,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
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

// Living house navigation

class _LivingHouseRoom {
  final String label;
  final String hint;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _LivingHouseRoom({
    required this.label,
    required this.hint,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.isDisabled = false,
  });
}

class _LivingHouseNavigation extends StatelessWidget {
  final List<_LivingHouseRoom> rooms;
  final VoidCallback onBackToGarden;

  const _LivingHouseNavigation({
    required this.rooms,
    required this.onBackToGarden,
  });

  static const _worldBackground =
      'assets/images/rooms/underground/my_house_world_bg.png';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final narrow = availableWidth < 560;
        final safetyPadding = narrow ? 12.0 : 24.0;
        final worldWidth = math.min(
          availableWidth - safetyPadding * 2,
          narrow ? 760.0 : 1220.0,
        );
        final worldHeight = narrow
            ? math.max(620.0, math.min(760.0, worldWidth * 1.55))
            : worldWidth * 9 / 16;
        final controlsWidth = math.min(worldWidth, 760.0);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(safetyPadding, 12, safetyPadding, 28),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: worldWidth,
                  height: worldHeight,
                  child: _MyHouseArtWorld(rooms: rooms, narrow: narrow),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: SizedBox(
                  width: controlsWidth,
                  child: _GardenPathButton(onTap: onBackToGarden),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MyHouseArtWorld extends StatelessWidget {
  final List<_LivingHouseRoom> rooms;
  final bool narrow;

  const _MyHouseArtWorld({required this.rooms, required this.narrow});

  static const _desktopPositions = <String, _RoomPlaquePosition>{
    'Calm Room': _RoomPlaquePosition(0.18, 0.25),
    'Kitchen': _RoomPlaquePosition(0.50, 0.24),
    'Sleep Room': _RoomPlaquePosition(0.74, 0.24),
    'Boys’ Room': _RoomPlaquePosition(0.22, 0.46),
    'Living Room': _RoomPlaquePosition(0.50, 0.48),
    'School Room': _RoomPlaquePosition(0.74, 0.48),
    'Big Feelings Room': _RoomPlaquePosition(0.24, 0.72),
    'Sensory Room': _RoomPlaquePosition(0.56, 0.73),
    'Nursery': _RoomPlaquePosition(0.76, 0.74),
    'Music Corner': _RoomPlaquePosition(0.42, 0.86),
  };

  static const _mobilePositions = <String, _RoomPlaquePosition>{
    'Calm Room': _RoomPlaquePosition(0.24, 0.20),
    'Kitchen': _RoomPlaquePosition(0.50, 0.24),
    'Sleep Room': _RoomPlaquePosition(0.72, 0.28),
    'Boys’ Room': _RoomPlaquePosition(0.26, 0.43),
    'Living Room': _RoomPlaquePosition(0.50, 0.50),
    'School Room': _RoomPlaquePosition(0.72, 0.54),
    'Big Feelings Room': _RoomPlaquePosition(0.28, 0.70),
    'Sensory Room': _RoomPlaquePosition(0.52, 0.78),
    'Nursery': _RoomPlaquePosition(0.72, 0.84),
    'Music Corner': _RoomPlaquePosition(0.50, 0.92),
  };
  @override
  Widget build(BuildContext context) {
    final positions = narrow ? _mobilePositions : _desktopPositions;
    return ClipRRect(
      borderRadius: BorderRadius.circular(narrow ? 12 : 18),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF120D18)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _LivingHouseNavigation._worldBackground,
              fit: BoxFit.cover,
              alignment: narrow ? Alignment.topCenter : Alignment.center,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.00),
                      Colors.black.withValues(alpha: narrow ? 0.08 : 0.04),
                    ],
                  ),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final plaqueWidth = narrow ? 132.0 : 166.0;
                return Stack(
                  children: [
                    for (final room in rooms)
                      if (positions.containsKey(room.label))
                        _PositionedRoomPlaque(
                          room: room,
                          position: positions[room.label]!,
                          plaqueWidth: plaqueWidth,
                          narrow: narrow,
                          worldSize: constraints.biggest,
                        ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomPlaquePosition {
  final double x;
  final double y;

  const _RoomPlaquePosition(this.x, this.y);
}

class _PositionedRoomPlaque extends StatelessWidget {
  final _LivingHouseRoom room;
  final _RoomPlaquePosition position;
  final double plaqueWidth;
  final bool narrow;
  final Size worldSize;

  const _PositionedRoomPlaque({
    required this.room,
    required this.position,
    required this.plaqueWidth,
    required this.narrow,
    required this.worldSize,
  });

  @override
  Widget build(BuildContext context) {
    final plaqueHeight = narrow ? 44.0 : 46.0;
    final left = (worldSize.width * position.x - plaqueWidth / 2)
        .clamp(8.0, worldSize.width - plaqueWidth - 8.0)
        .toDouble();
    final top = (worldSize.height * position.y - plaqueHeight / 2)
        .clamp(8.0, worldSize.height - plaqueHeight - 8.0)
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: plaqueWidth,
      height: plaqueHeight,
      child: _ArtRoomPlaque(room: room, narrow: narrow),
    );
  }
}

class _ArtRoomPlaque extends StatefulWidget {
  final _LivingHouseRoom room;
  final bool narrow;

  const _ArtRoomPlaque({required this.room, required this.narrow});

  @override
  State<_ArtRoomPlaque> createState() => _ArtRoomPlaqueState();
}

class _ArtRoomPlaqueState extends State<_ArtRoomPlaque> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final disabled = room.isDisabled || room.onTap == null;
    final displayLabel = disabled ? '${room.label}\nNot open yet' : room.label;
    final colorAlpha = disabled ? 0.30 : (_hovered ? 0.78 : 0.48);
    final fillAlpha = disabled ? 0.24 : (_hovered ? 0.48 : 0.30);
    final glowAlpha = disabled ? 0.06 : (_hovered ? 0.28 : 0.14);
    return Semantics(
      button: !disabled,
      enabled: !disabled,
      label: disabled
          ? '${room.label}. Not open yet.'
          : 'Open ${room.label}. ${room.hint}.',
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          onShowHoverHighlight: (value) =>
              setState(() => _hovered = !disabled && value),
          child: AnimatedScale(
            scale: _hovered && !disabled ? 1.04 : 1,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: disabled ? null : room.onTap,
                borderRadius: BorderRadius.circular(999),
                hoverColor: disabled
                    ? Colors.transparent
                    : room.accent.withValues(alpha: 0.09),
                splashColor: disabled
                    ? Colors.transparent
                    : room.accent.withValues(alpha: 0.15),
                highlightColor: disabled
                    ? Colors.transparent
                    : room.accent.withValues(alpha: 0.07),
                child: Ink(
                  decoration: BoxDecoration(
                    color: const Color(0xFF100B18).withValues(alpha: fillAlpha),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: room.accent.withValues(alpha: colorAlpha),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: room.accent.withValues(alpha: glowAlpha),
                        blurRadius: _hovered ? 18 : 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          room.icon,
                          color: room.accent.withValues(
                            alpha: disabled ? 0.62 : 1,
                          ),
                          size: widget.narrow ? 15 : 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            displayLabel,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              color: HouseInteriorScreen._text.withValues(
                                alpha: disabled ? 0.72 : 1,
                              ),
                              fontSize: widget.narrow ? 11.2 : 12.2,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'DM Sans',
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
        ),
      ),
    );
  }
}

class _GardenPathButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GardenPathButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back to Garden. Return to the world.',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            hoverColor: HouseInteriorScreen._green.withValues(alpha: 0.10),
            splashColor: HouseInteriorScreen._green.withValues(alpha: 0.18),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: HouseInteriorScreen._green.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: HouseInteriorScreen._green.withValues(alpha: 0.42),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_florist_rounded,
                    color: HouseInteriorScreen._green,
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Back to Garden',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: HouseInteriorScreen._text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
