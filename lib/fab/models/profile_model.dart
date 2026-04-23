import '../fab_theme.dart';
import 'package:flutter/material.dart';

class ProfileModel {
  String id;
  String name;
  int age;
  List<FabCondition> conditions;
  String? medication;
  int fabStars;
  int currentStreak;
  int longestStreak;
  List<String> ownedDuckIds;
  List<RedeemableReward> rewards;
  DateTime? lastCheckIn;

  ProfileModel({
    required this.id,
    required this.name,
    required this.age,
    required this.conditions,
    this.medication,
    this.fabStars = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    List<String>? ownedDuckIds,
    List<RedeemableReward>? rewards,
    this.lastCheckIn,
  })  : ownedDuckIds = ownedDuckIds ?? ['classic', 'blush'],
        rewards = rewards ?? _defaultRewards();

  static List<RedeemableReward> _defaultRewards() => [
    RedeemableReward(id: 'screen30', label: 'Extra screen time', description: '30 minutes', cost: 100),
    RedeemableReward(id: 'dinner', label: 'Choose dinner', description: 'Pick tonight\'s meal', cost: 200),
    RedeemableReward(id: 'stayup', label: 'Stay up 30 mins late', description: 'Friday only', cost: 300),
    RedeemableReward(id: 'treat', label: 'Pick a treat', description: 'From the shops', cost: 250),
  ];

  bool get checkedInToday {
    if (lastCheckIn == null) return false;
    final now = DateTime.now();
    return lastCheckIn!.year == now.year &&
        lastCheckIn!.month == now.month &&
        lastCheckIn!.day == now.day;
  }
}

class RedeemableReward {
  final String id;
  final String label;
  final String description;
  final int cost;
  RedeemableReward({required this.id, required this.label, required this.description, required this.cost});
}

class CheckInModel {
  final String id;
  final String profileId;
  final DateTime date;
  final int moodScore;
  final double? sleepHours;
  final TimeOfDay? bedTime;
  final TimeOfDay? wakeTime;
  final int? sleepQuality;
  final int? wakeUps;
  final int? focusScore;
  final int? energyScore;
  final int? hyperactivityScore;
  final bool? medicationTaken;
  final List<String> sleepTriggers;
  final List<String> sleepHelpers;
  final String? notes;
  final List<String> toolsUsed;

  CheckInModel({
    required this.id,
    required this.profileId,
    required this.date,
    required this.moodScore,
    this.sleepHours,
    this.bedTime,
    this.wakeTime,
    this.sleepQuality,
    this.wakeUps,
    this.focusScore,
    this.energyScore,
    this.hyperactivityScore,
    this.medicationTaken,
    this.sleepTriggers = const [],
    this.sleepHelpers = const [],
    this.notes,
    this.toolsUsed = const [],
  });

  int get starsEarned {
    int stars = 5;
    if (medicationTaken == true) stars += 3;
    if (sleepHours != null) stars += 2;
    if (notes != null && notes!.isNotEmpty) stars += 2;
    if (toolsUsed.isNotEmpty) stars += toolsUsed.length * 2;
    return stars;
  }
}

class SleepFactors {
  static const List<String> triggers = [
    'Screen time late', 'Anxiety / racing thoughts', 'Noise',
    'Light sensitivity', 'Caffeine', 'Late meal',
    'Stress / difficult day', 'Medication timing',
    'Sensory overload earlier', 'Too hot', 'Too cold', 'Nightmares',
  ];
  static const List<String> helpers = [
    'Calm bedtime routine', 'Weighted blanket', 'White noise',
    'Dark room', 'Breathing exercise', 'Melatonin',
    'Reading', 'Cool temperature', 'Lavender',
    'Bath before bed', 'No screens 1h before', 'Familiar music',
  ];
}

class MoodData {
  static const List<String> emojis = ['😢', '😕', '😐', '🙂', '😄'];
  static const List<String> labels = ['sad', 'down', 'okay', 'good', 'fab'];
  static String emoji(int score) => emojis[score.clamp(1, 5) - 1];
  static String label(int score) => labels[score.clamp(1, 5) - 1];
}