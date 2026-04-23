import 'package:flutter/material.dart';
import '../fab_theme.dart';

enum DuckRarity { common, rare, legendary }
enum DuckUnlockType { starter, stars, streak, activity, mystery }

class DuckModel {
  final String id;
  final String name;
  final String type;
  final String description;
  final int starCost;
  final DuckRarity rarity;
  final DuckUnlockType unlockType;
  final String unlockHint;
  final Color bodyColor;
  final Color accentColor;
  final String tagLabel;
  final Color tagColor;
  bool owned;
  bool revealed;

  DuckModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.starCost,
    required this.rarity,
    required this.unlockType,
    required this.unlockHint,
    required this.bodyColor,
    required this.accentColor,
    required this.tagLabel,
    required this.tagColor,
    this.owned = false,
    this.revealed = false,
  });
}

class DuckCollection {
  static List<DuckModel> get all => [
    DuckModel(id: 'classic', name: 'Classic', type: 'Original rubber duck',
      description: 'Your very first duck. Every flock starts here.',
      starCost: 0, rarity: DuckRarity.common, unlockType: DuckUnlockType.starter,
      unlockHint: 'Your starter duck', bodyColor: FabColors.yellow,
      accentColor: FabColors.duckOrange, tagLabel: 'starter', tagColor: FabColors.gold, owned: true),
    DuckModel(id: 'blush', name: 'Blush', type: 'Kawaii duck',
      description: 'Rosy cheeks, permanent smile.',
      starCost: 0, rarity: DuckRarity.common, unlockType: DuckUnlockType.starter,
      unlockHint: 'Log a happy mood', bodyColor: FabColors.blush,
      accentColor: FabColors.pink, tagLabel: 'mood', tagColor: FabColors.pink, owned: true),
    DuckModel(id: 'sleepy', name: 'Sleepy', type: 'Bedtime duck',
      description: 'Tiny sleep mask. Unlock after logging 7 nights of sleep.',
      starCost: 50, rarity: DuckRarity.common, unlockType: DuckUnlockType.activity,
      unlockHint: 'Log 7 nights of sleep', bodyColor: const Color(0xFFB5D4F4),
      accentColor: FabColors.ice, tagLabel: 'sleep', tagColor: FabColors.ice),
    DuckModel(id: 'focusy', name: 'Focusy', type: 'ADHD duck',
      description: 'Tiny headphones. Unlock after 5 focus timer sessions.',
      starCost: 75, rarity: DuckRarity.common, unlockType: DuckUnlockType.activity,
      unlockHint: 'Complete 5 focus sessions', bodyColor: const Color(0xFF9FE1CB),
      accentColor: FabColors.teal, tagLabel: 'ADHD', tagColor: FabColors.teal),
    DuckModel(id: 'bubbly', name: 'Bubbly', type: 'Sensory duck',
      description: 'Covered in bubbles. Pop bubble wrap 10 times to unlock.',
      starCost: 80, rarity: DuckRarity.common, unlockType: DuckUnlockType.activity,
      unlockHint: 'Use bubble wrap 10 times', bodyColor: const Color(0xFFC8E6F8),
      accentColor: FabColors.ice, tagLabel: 'sensory', tagColor: FabColors.pink),
    DuckModel(id: 'zen', name: 'Zen', type: 'Meditation duck',
      description: 'Tiny lotus. Unlock after 5 breathing exercises.',
      starCost: 120, rarity: DuckRarity.common, unlockType: DuckUnlockType.activity,
      unlockHint: 'Complete 5 breathing exercises', bodyColor: const Color(0xFF9FE1CB),
      accentColor: const Color(0xFF1D9E75), tagLabel: 'breathing', tagColor: FabColors.teal),
    DuckModel(id: 'punk', name: 'Punk', type: 'Mohawk duck',
      description: 'Pink mohawk, tiny leather jacket. Pure attitude.',
      starCost: 150, rarity: DuckRarity.common, unlockType: DuckUnlockType.stars,
      unlockHint: 'Purchase with 150 stars', bodyColor: const Color(0xFFFF6B6B),
      accentColor: FabColors.deepRose, tagLabel: 'bold', tagColor: FabColors.rose),
    DuckModel(id: 'artist', name: 'Artsy', type: 'Creative duck',
      description: 'Beret and paintbrush. Unlock after 5 colouring sessions.',
      starCost: 100, rarity: DuckRarity.common, unlockType: DuckUnlockType.activity,
      unlockHint: 'Complete 5 colouring sessions', bodyColor: const Color(0xFFED93B1),
      accentColor: const Color(0xFFD4537E), tagLabel: 'creative', tagColor: FabColors.pink),
    DuckModel(id: 'gamer', name: 'Gamer', type: 'Game duck',
      description: 'Tiny controller. Unlock after playing 10 games.',
      starCost: 175, rarity: DuckRarity.common, unlockType: DuckUnlockType.activity,
      unlockHint: 'Play 10 games', bodyColor: const Color(0xFFAFA9EC),
      accentColor: const Color(0xFF7F77DD), tagLabel: 'games', tagColor: const Color(0xFF7F77DD)),
    DuckModel(id: 'rainy', name: 'Rainy', type: 'Weather duck',
      description: 'Yellow raincoat and boots. Use rain sounds 5 times.',
      starCost: 80, rarity: DuckRarity.common, unlockType: DuckUnlockType.activity,
      unlockHint: 'Use rain sounds 5 times', bodyColor: FabColors.yellow,
      accentColor: FabColors.duckOrange, tagLabel: 'calm', tagColor: FabColors.ice),
    DuckModel(id: 'starlet', name: 'Starlet', type: 'Gold star duck',
      description: 'Crown and sparkles. Earn a 10-day streak.',
      starCost: 100, rarity: DuckRarity.rare, unlockType: DuckUnlockType.streak,
      unlockHint: 'Reach a 10-day streak', bodyColor: FabColors.gold,
      accentColor: const Color(0xFFC8A000), tagLabel: '10-day streak', tagColor: FabColors.gold),
    DuckModel(id: 'doctor', name: 'Doc', type: 'Doctor duck',
      description: 'Stethoscope and clipboard. Export your first doctor report.',
      starCost: 200, rarity: DuckRarity.rare, unlockType: DuckUnlockType.activity,
      unlockHint: 'Export a doctor report', bodyColor: const Color(0xFFE6F1FB),
      accentColor: const Color(0xFF2A9FD8), tagLabel: 'doctor', tagColor: FabColors.ice),
    DuckModel(id: 'moonbeam', name: 'Moonbeam', type: 'Night owl duck',
      description: 'Crescent moon crown. Log sleep 30 nights in a row.',
      starCost: 250, rarity: DuckRarity.rare, unlockType: DuckUnlockType.streak,
      unlockHint: 'Log sleep 30 nights in a row', bodyColor: const Color(0xFF1E3558),
      accentColor: FabColors.ice, tagLabel: 'sleep · rare', tagColor: FabColors.ice),
    DuckModel(id: 'therapist', name: 'Therapy', type: 'Calm toolkit duck',
      description: 'Notepad and crystal. Use 5 different calm tools.',
      starCost: 200, rarity: DuckRarity.rare, unlockType: DuckUnlockType.activity,
      unlockHint: 'Use 5 different calm toolkit tools', bodyColor: const Color(0xFF5DCAA5),
      accentColor: FabColors.teal, tagLabel: 'calm toolkit', tagColor: FabColors.teal),
    DuckModel(id: 'mystery1', name: '???', type: 'Mystery duck',
      description: 'Nobody knows what this duck looks like. 300 stars to reveal.',
      starCost: 300, rarity: DuckRarity.rare, unlockType: DuckUnlockType.mystery,
      unlockHint: 'Spend 300 stars to reveal', bodyColor: const Color(0xFF3D1A6E),
      accentColor: const Color(0xFF7F77DD), tagLabel: 'rare · mystery', tagColor: FabColors.gold),
    DuckModel(id: 'mystery2', name: '???', type: 'Mystery duck',
      description: 'Spotted by only a few. What could it be?',
      starCost: 400, rarity: DuckRarity.legendary, unlockType: DuckUnlockType.mystery,
      unlockHint: 'Spend 400 stars to reveal', bodyColor: const Color(0xFF3D1A6E),
      accentColor: FabColors.rose, tagLabel: 'ultra rare', tagColor: FabColors.rose),
    DuckModel(id: 'mystery3', name: '???', type: 'Mystery duck',
      description: 'The rarest duck. Legend has it Chicken Lips designed it herself.',
      starCost: 500, rarity: DuckRarity.legendary, unlockType: DuckUnlockType.mystery,
      unlockHint: 'Spend 500 stars to reveal', bodyColor: const Color(0xFF26103F),
      accentColor: FabColors.gold, tagLabel: 'legendary', tagColor: FabColors.gold),
  ];
}