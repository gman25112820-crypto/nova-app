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

  List<_LivingHouseRoom> _livingRooms(BuildContext context) => [
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
      label: 'Girl 1 Room',
      hint: 'Energy and creative things',
      icon: Icons.auto_awesome_rounded,
      accent: _purple,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailScreen(
            backgroundImage:
                'assets/images/rooms/underground/spare_room_bg.png',
            roomEmoji: '\u{2B50}',
            roomName: 'Girl 1 Bedroom',
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
            ],
          ),
        ),
      ),
    ),
    _LivingHouseRoom(
      label: 'Boy 1 Room',
      hint: 'A place for notes',
      icon: Icons.edit_note_rounded,
      accent: _teal,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailScreen(
            backgroundImage: 'assets/images/rooms/giraffe/boy1_bedroom_bg.png',
            roomEmoji: '\u{1F579}\u{FE0F}',
            roomName: 'Boy 1 Bedroom',
            objects: [
              RoomObject(
                emoji: '\u{1F4AD}',
                label: 'Worry tracker',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorryZoneScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    _LivingHouseRoom(
      label: 'Boy 2 Room',
      hint: 'Sleep log',
      icon: Icons.rocket_launch_rounded,
      accent: const Color(0xFF9C27B0),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailScreen(
            backgroundImage: 'assets/images/rooms/giraffe/boy2_bedroom_bg.png',
            roomEmoji: '\u{1F680}',
            roomName: 'Boy 2 Bedroom',
            objects: [
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 560;
        final houseWidth = math.min(constraints.maxWidth - 32, 760.0);
        final columns = narrow ? 2 : 3;
        final roomExtent = narrow ? 96.0 : 112.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: houseWidth),
              child: Column(
                children: [
                  const _HouseRoof(),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      narrow ? 14 : 22,
                      narrow ? 16 : 22,
                      narrow ? 14 : 22,
                      22,
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
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      border: Border.all(
                        color: HouseInteriorScreen._purple.withValues(
                          alpha: 0.34,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: HouseInteriorScreen._purple.withValues(
                            alpha: 0.22,
                          ),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tap a lit room.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: HouseInteriorScreen._muted.withValues(
                              alpha: 0.88,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: rooms.length + 2,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: roomExtent,
                              ),
                          itemBuilder: (context, index) {
                            if (_isClosedDoorIndex(index, columns)) {
                              return const _ClosedHouseDoor();
                            }
                            final roomIndex = _roomIndexFor(index, columns);
                            if (roomIndex < 0 || roomIndex >= rooms.length) {
                              return const _ClosedHouseDoor();
                            }
                            return _LivingRoomButton(room: rooms[roomIndex]);
                          },
                        ),
                        const SizedBox(height: 18),
                        _GardenPathButton(onTap: onBackToGarden),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isClosedDoorIndex(int index, int columns) {
    if (columns == 2) {
      return index == 5 || index == 11;
    }
    return index == 5 || index == 11;
  }

  int _roomIndexFor(int index, int columns) {
    final closedBefore = List<int>.generate(
      index,
      (i) => i,
    ).where((i) => _isClosedDoorIndex(i, columns)).length;
    return index - closedBefore;
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

  const _LivingRoomButton({required this.room});

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
                    color: room.accent.withValues(
                      alpha: _hovered ? 0.22 : 0.14,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: room.accent.withValues(
                        alpha: _hovered ? 0.78 : 0.48,
                      ),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: room.accent.withValues(
                          alpha: _hovered ? 0.24 : 0.14,
                        ),
                        blurRadius: _hovered ? 18 : 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(room.icon, color: room.accent, size: 24),
                        const SizedBox(height: 8),
                        Text(
                          room.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: HouseInteriorScreen._text,
                            fontSize: 12.5,
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
                            fontSize: 10.5,
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
  const _ClosedHouseDoor();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Closed door',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Center(
          child: Container(
            width: 34,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF12091F).withValues(alpha: 0.78),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 7),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: HouseInteriorScreen._muted.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
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
