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
  static const _panel = Color(0xFF1A1040);
  static const _panelAlt = Color(0xFF241052);
  static const _text = Color(0xFFF0D6FF);
  static const _muted = Color(0xFFC0A0E0);
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
    final personalRoomName = _personalRoomName();
    return [
    _LivingHouseRoom(
      label: 'Main Bedroom',
      hint: 'Rest and check in',
      icon: Icons.bedtime_rounded,
      accent: _pink,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailScreen(
            backgroundImage: 'assets/images/rooms/giraffe/main_bedroom_bg.png',
            roomEmoji: '\u{1F6CF}\u{FE0F}',
            roomName: 'Main Bedroom',
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
      label: personalRoomName,
      hint: 'Energy, worries and quiet notes',
      icon: Icons.auto_awesome_rounded,
      accent: _purple,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailScreen(
            backgroundImage:
                'assets/images/rooms/underground/spare_room_bg.png',
            roomEmoji: '\u{2B50}',
            roomName: personalRoomName,
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
                  MaterialPageRoute(builder: (_) => const KitchenMealPicker()),
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
      label: 'Games Room',
      hint: 'Games to play',
      icon: Icons.sports_esports_rounded,
      accent: const Color(0xFF7C6AF5),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailScreen(
            backgroundImage: 'assets/images/rooms/giraffe/games_room_bg.png',
            roomEmoji: '\u{1F4FA}',
            roomName: 'Games Room',
            objects: [
              RoomObject(
                emoji: '\u{1FAC1}',
                label: 'Breathing game',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalmBreathingGame()),
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
      label: 'Safe Corner',
      hint: 'A calm space',
      icon: Icons.favorite_rounded,
      accent: const Color(0xFF7C6AF5),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SafeCornerLivingRoom()),
      ),
    ),
    _LivingHouseRoom(
      label: 'Study',
      hint: 'Focus helper',
      icon: Icons.menu_book_rounded,
      accent: _amber,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailScreen(
            backgroundImage: 'assets/images/rooms/underground/study_bg.png',
            roomEmoji: '\u{1F4DA}',
            roomName: 'Study',
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
      hint: 'Sounds to explore',
      icon: Icons.music_note_rounded,
      accent: _amber,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailScreen(
            backgroundImage:
                'assets/images/rooms/underground/music_corner_bg.png',
            roomEmoji: '\u{1F3B5}',
            roomName: 'Music Corner',
            objects: [
              RoomObject(
                emoji: '\u{1F3B9}',
                label: 'Sound explorer',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MusicCornerScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
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

  String _personalRoomName() {
    final child =
        SelectedChildService.current ?? SelectedChildService.selectDefault();
    final name = child?.name.trim() ?? '';
    if (name.isEmpty) return 'My Room';
    final suffix = name.toLowerCase().endsWith('s')
        ? String.fromCharCode(0x2019)
        : '${String.fromCharCode(0x2019)}s';
    return '$name$suffix Room';
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

// ── Little Ones placeholder ───────────────────────────────────
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

// ── Teen Space placeholder ─────────────────────────────────────

class _TeenSpacePlaceholder extends StatelessWidget {
  const _TeenSpacePlaceholder();

  static const _bg = Color(0xFF0F0520);
  static const _teal = Color(0xFF00C9A7);

  static const _comingRooms = [
    ('⭐', 'My Journal', 'Private space, just for you'),
    ('💜', 'How I\'m feeling', 'Mood, energy, sleep check-in'),
    ('🎯', 'My Goals', 'Track what matters to you'),
    ('🔒', 'Safe Corner', 'Calm-down tools and breathing'),
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
  final VoidCallback onTap;

  const _LivingHouseRoom({
    required this.label,
    required this.hint,
    required this.icon,
    required this.accent,
    required this.onTap,
  });
}

class _LivingHouseNavigation extends StatelessWidget {
  final List<_LivingHouseRoom> rooms;
  final VoidCallback onBackToGarden;

  const _LivingHouseNavigation({
    required this.rooms,
    required this.onBackToGarden,
  });

  static const _sceneAspect = 16 / 9;
  static const _exteriorGroundRatio = 0.78;
  static const _centralDoorLeft = 0.45;
  static const _centralDoorTop = 0.36;
  static const _centralDoorWidth = 0.10;
  static const _centralDoorHeight = 0.18;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final narrow = availableWidth < 560;
        final tablet = availableWidth < 900;
        final safetyPadding = narrow ? 16.0 : 24.0;
        final houseWidth = math.min(availableWidth - safetyPadding * 2, 760.0);
        final undergroundFraction = narrow ? 1.0 : (tablet ? 0.92 : 0.94);
        final undergroundWidth = math.max(
          0.0,
          availableWidth * undergroundFraction - safetyPadding,
        );
        final controlsWidth = math.min(undergroundWidth, 760.0);
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            safetyPadding / 2,
            16,
            safetyPadding / 2,
            28,
          ),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: houseWidth,
                  child: _HouseCutaway(
                    height: math.min(
                      houseWidth / _sceneAspect * _exteriorGroundRatio,
                      narrow ? 236.0 : 292.0,
                    ),
                    narrow: narrow,
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: undergroundWidth,
                  child: Column(
                    children: [
                      _GroundLine(narrow: narrow),
                      _UndergroundCutaway(
                        narrow: narrow,
                        wide: !narrow,
                        bands: [
                          _DepthBandRooms(_room('Main Bedroom'), _room('Kitchen')),
                          _DepthBandRooms(_room('Games Room'), _room('Living Room')),
                          _DepthBandRooms(_room('Music Corner'), _room('Nursery')),
                          _DepthBandRooms(_personalRoom(), _room('Study')),
                          _DepthBandRooms(_room('Safe Corner'), null),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
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

  _LivingHouseRoom _room(String label) =>
      rooms.firstWhere((room) => room.label == label);

  _LivingHouseRoom _personalRoom() => rooms.firstWhere(
        (room) => ![
          'Main Bedroom',
          'Kitchen',
          'Living Room',
          'Games Room',
          'Safe Corner',
          'Study',
          'Music Corner',
          'Nursery',
        ].contains(room.label),
      );
}

class _DepthBandRooms {
  final _LivingHouseRoom? left;
  final _LivingHouseRoom? right;

  const _DepthBandRooms(this.left, this.right);
}

class _HouseCutaway extends StatelessWidget {
  final double height;
  final bool narrow;

  const _HouseCutaway({required this.height, required this.narrow});

  @override
  Widget build(BuildContext context) {
    final bodyTop = height * (_LivingHouseNavigation._centralDoorTop /
        _LivingHouseNavigation._exteriorGroundRatio);
    final doorCenter = _LivingHouseNavigation._centralDoorLeft +
        _LivingHouseNavigation._centralDoorWidth / 2;
    final doorAlignment = (doorCenter - 0.5) * 2;
    final doorHeight = (height * (_LivingHouseNavigation._centralDoorHeight /
            _LivingHouseNavigation._exteriorGroundRatio))
        .clamp(58.0, 68.0);
    final doorWidth = (doorHeight * (_LivingHouseNavigation._centralDoorWidth /
            _LivingHouseNavigation._centralDoorHeight))
        .clamp(46.0, 54.0);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(child: _HouseRoof()),
          Positioned.fill(
            top: math.max(narrow ? 76 : 94, bodyTop),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: narrow ? 34 : 58),
              padding: EdgeInsets.fromLTRB(
                narrow ? 14 : 22,
                narrow ? 16 : 22,
                narrow ? 14 : 22,
                0,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    HouseInteriorScreen._panelAlt,
                    HouseInteriorScreen._panel,
                  ],
                ),
                border: Border.all(
                  color: HouseInteriorScreen._amber.withValues(alpha: 0.22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: HouseInteriorScreen._pink.withValues(alpha: 0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: const [
                        Expanded(
                          child: _HouseWindow(
                            icon: Icons.weekend_rounded,
                            label: 'Living Room',
                            accent: HouseInteriorScreen._pink,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: _HouseWindow(
                            icon: Icons.restaurant_rounded,
                            label: 'Kitchen',
                            accent: HouseInteriorScreen._amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment(doorAlignment, 1),
                    child: _CentralHouseDoor(
                      width: doorWidth,
                      height: doorHeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HouseWindow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _HouseWindow({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: HouseInteriorScreen._text,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}

class _CentralHouseDoor extends StatelessWidget {
  final double width;
  final double height;

  const _CentralHouseDoor({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7B2FBE), Color(0xFF170D2A)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border.all(
          color: HouseInteriorScreen._amber.withValues(alpha: 0.48),
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(right: 11),
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: HouseInteriorScreen._amber.withValues(alpha: 0.78),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _GroundLine extends StatelessWidget {
  final bool narrow;

  const _GroundLine({required this.narrow});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: narrow ? 28 : 34,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF274A24), Color(0xFF4B311C)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: HouseInteriorScreen._green.withValues(alpha: 0.36),
          ),
        ),
      ),
      child: Center(
        child: Container(
          width: narrow ? 64 : 84,
          height: narrow ? 18 : 22,
          decoration: BoxDecoration(
            color: const Color(0xFF170D2A),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            border: Border.all(
              color: HouseInteriorScreen._amber.withValues(alpha: 0.24),
            ),
          ),
        ),
      ),
    );
  }
}

class _UndergroundCutaway extends StatelessWidget {
  final bool narrow;
  final bool wide;
  final List<_DepthBandRooms> bands;

  const _UndergroundCutaway({
    required this.narrow,
    required this.wide,
    required this.bands,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        narrow ? 12 : 24,
        narrow ? 24 : 32,
        narrow ? 12 : 24,
        narrow ? 24 : 32,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D1C2B), Color(0xFF24182A), Color(0xFF17131F)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        border: Border.all(
          color: const Color(0xFF6A4A32).withValues(alpha: 0.38),
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _TunnelPainter())),
          Column(
            children: [
              for (var i = 0; i < bands.length; i++)
                _DepthBand(
                  band: bands[i],
                  depth: i,
                  narrow: narrow,
                  wide: wide,
                ),
              _DepthBand(
                band: null,
                depth: bands.length,
                narrow: narrow,
                wide: wide,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TunnelPainter extends CustomPainter {
  const _TunnelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final corridorWidth = math.max(44.0, size.width * 0.12);
    final corridorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: corridorWidth,
        height: size.height,
      ),
      const Radius.circular(28),
    );
    canvas.drawRRect(
      corridorRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A2450), Color(0xFF211832)],
        ).createShader(corridorRect.outerRect),
    );
    canvas.drawRRect(
      corridorRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = HouseInteriorScreen._amber.withValues(alpha: 0.18),
    );
    final rootPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8B6E47).withValues(alpha: 0.22);
    for (var i = 0; i < 7; i++) {
      final y = size.height * (0.12 + i * 0.12);
      canvas.drawPath(
        Path()
          ..moveTo(size.width * 0.45, y)
          ..quadraticBezierTo(
            size.width * 0.31,
            y + 18,
            size.width * 0.20,
            y + 2,
          ),
        rootPaint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(size.width * 0.55, y + 22)
          ..quadraticBezierTo(
            size.width * 0.70,
            y + 4,
            size.width * 0.82,
            y + 20,
          ),
        rootPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DepthBand extends StatelessWidget {
  final _DepthBandRooms? band;
  final int depth;
  final bool narrow;
  final bool wide;

  const _DepthBand({
    required this.band,
    required this.depth,
    required this.narrow,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    final tone = (0.16 + depth * 0.04).clamp(0.16, 0.36).toDouble();
    final left = band?.left;
    final right = band?.right;
    if (narrow) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          children: [
            _TunnelStem(depth: depth, wide: wide),
            if (left == null)
              _ClosedHouseDoor(depthTone: tone)
            else
              _LivingRoomButton(room: left, depthTone: tone),
            const SizedBox(height: 12),
            if (right == null)
              _ClosedHouseDoor(depthTone: tone)
            else
              _LivingRoomButton(room: right, depthTone: tone),
          ],
        ),
      );
    }
    final alcoveMaxWidth = wide ? 430.0 : 345.0;
    final sidePadding = wide ? 44.0 : 18.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: sidePadding),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: alcoveMaxWidth),
                  child: left == null
                      ? const SizedBox(height: 126)
                      : _LivingRoomButton(room: left, depthTone: tone),
                ),
              ),
            ),
          ),
          _TunnelStem(depth: depth, wide: wide),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: sidePadding),
              child: Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: alcoveMaxWidth),
                  child: right == null
                      ? _ClosedHouseDoor(depthTone: tone)
                      : _LivingRoomButton(room: right, depthTone: tone),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TunnelStem extends StatelessWidget {
  final int depth;
  final bool wide;

  const _TunnelStem({required this.depth, required this.wide});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wide ? 132 : 92,
      height: 126,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 2,
            height: 30,
            color: HouseInteriorScreen._amber.withValues(alpha: 0.18),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HouseInteriorScreen._amber.withValues(
                alpha: 0.22 + depth * 0.035,
              ),
              boxShadow: [
                BoxShadow(
                  color: HouseInteriorScreen._amber.withValues(alpha: 0.18),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 30,
            color: HouseInteriorScreen._amber.withValues(alpha: 0.18),
          ),
        ],
      ),
    );
  }
}
class _HouseRoof extends StatelessWidget {
  const _HouseRoof();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'The Living House',
      excludeSemantics: true,
      child: CustomPaint(
        size: const Size(double.infinity, 96),
        painter: _HouseRoofPainter(),
        child: const SizedBox(height: 96, width: double.infinity),
      ),
    );
  }
}

class _HouseRoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roof = Path()
      ..moveTo(size.width * 0.08, size.height)
      ..lineTo(size.width * 0.50, 4)
      ..lineTo(size.width * 0.92, size.height)
      ..close();
    final chimney = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.68, 20, 36, 58),
      const Radius.circular(5),
    );
    final roofPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE91E8C), Color(0xFF7B2FBE)],
      ).createShader(Offset.zero & size);
    final glowPaint = Paint()
      ..color = HouseInteriorScreen._pink.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final chimneyPaint = Paint()..color = const Color(0xFF2D1556);

    canvas.drawPath(roof, glowPaint);
    canvas.drawRRect(chimney, chimneyPaint);
    canvas.drawPath(roof, roofPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LivingRoomButton extends StatefulWidget {
  final _LivingHouseRoom room;
  final double depthTone;

  const _LivingRoomButton({required this.room, required this.depthTone});

  @override
  State<_LivingRoomButton> createState() => _LivingRoomButtonState();
}

class _LivingRoomButtonState extends State<_LivingRoomButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return Semantics(
      button: true,
      label: 'Open ${room.label}. ${room.hint}.',
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          onShowHoverHighlight: (value) => setState(() => _hovered = value),
          child: AnimatedScale(
            scale: _hovered ? 1.025 : 1,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: room.onTap,
                borderRadius: BorderRadius.circular(8),
                hoverColor: room.accent.withValues(alpha: 0.10),
                splashColor: room.accent.withValues(alpha: 0.18),
                highlightColor: room.accent.withValues(alpha: 0.08),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        room.accent.withValues(alpha: _hovered ? 0.25 : 0.16),
                        const Color(0xFF3B2A30).withValues(
                          alpha: widget.depthTone,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: room.accent.withValues(
                        alpha: _hovered ? 0.82 : 0.54,
                      ),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: room.accent.withValues(
                          alpha: _hovered ? 0.28 : 0.18,
                        ),
                        blurRadius: _hovered ? 20 : 12,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: HouseInteriorScreen._amber.withValues(
                          alpha: _hovered ? 0.12 : 0.06,
                        ),
                        blurRadius: _hovered ? 18 : 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(room.icon, color: room.accent, size: 26),
                        const SizedBox(height: 8),
                        Text(
                          room.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: HouseInteriorScreen._text,
                            fontSize: 13.5,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room.hint,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: HouseInteriorScreen._muted.withValues(
                              alpha: 0.78,
                            ),
                            fontSize: 11.5,
                            height: 1.15,
                            fontFamily: 'DM Sans',
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

class _ClosedHouseDoor extends StatelessWidget {
  final double depthTone;

  const _ClosedHouseDoor({required this.depthTone});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Not open yet',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 112),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2A2130).withValues(alpha: 0.78),
              const Color(0xFF16111D).withValues(alpha: depthTone + 0.42),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: HouseInteriorScreen._muted.withValues(alpha: 0.45),
                size: 22,
              ),
              const SizedBox(height: 8),
              Text(
                'Not open yet',
                style: TextStyle(
                  color: HouseInteriorScreen._muted.withValues(alpha: 0.68),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
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
