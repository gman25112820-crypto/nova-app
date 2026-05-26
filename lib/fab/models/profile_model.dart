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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'conditions': conditions.map((c) => c.name).toList(),
    'medication': medication,
    'fabStars': fabStars,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'ownedDuckIds': ownedDuckIds,
    'lastCheckIn': lastCheckIn?.toIso8601String(),
  };

  factory ProfileModel.fromJson(Map<String, dynamic> j) => ProfileModel(
    id: j['id'] as String,
    name: j['name'] as String,
    age: (j['age'] as num).toInt(),
    conditions: (j['conditions'] as List? ?? [])
        .map((s) => FabCondition.values.firstWhere(
              (e) => e.name == s,
              orElse: () => FabCondition.adhd,
            ))
        .toList(),
    medication: j['medication'] as String?,
    fabStars: (j['fabStars'] as num?)?.toInt() ?? 0,
    currentStreak: (j['currentStreak'] as num?)?.toInt() ?? 0,
    longestStreak: (j['longestStreak'] as num?)?.toInt() ?? 0,
    ownedDuckIds: (j['ownedDuckIds'] as List? ?? ['classic', 'blush']).cast<String>(),
    lastCheckIn: j['lastCheckIn'] != null
        ? DateTime.tryParse(j['lastCheckIn'] as String)
        : null,
  );
}

class RedeemableReward {
  final String id;
  final String label;
  final String description;
  final int cost;
  RedeemableReward({required this.id, required this.label, required this.description, required this.cost});
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