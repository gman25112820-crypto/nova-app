import 'package:flutter/foundation.dart';

/// A single Sleep / Fatigue check-in entry for local storage.
/// Separate model and box from [CheckInEntry] — sleep/fatigue fields don't
/// share meaning with a pain check-in row and this keeps each module's
/// storage independently evolvable (see docs/session_notes/SESSION_2026-07-27_nova_core.md).
/// All data stays on-device. No external transmission.
@immutable
class SleepFatigueEntry {
  const SleepFatigueEntry({
    required this.id,
    required this.date,
    required this.sleepQuality,
    required this.hoursSlept,
    required this.fatigueLevel,
    required this.restBreaksNeeded,
    required this.wokeInNight,
    required this.painDisturbed,
    required this.helped,
    required this.notes,
  });

  final String id;
  final DateTime date;

  /// How well the user slept, 0–10.
  final int sleepQuality;

  /// Approximate hours slept, 0–12.
  final int hoursSlept;

  /// Fatigue level today, 0–10.
  final int fatigueLevel;

  /// Number of rest breaks needed, 0–10.
  final int restBreaksNeeded;

  /// One of: 'No', 'Sometimes', 'Yes — often'.
  final String wokeInNight;

  /// One of: 'No', 'Somewhat', 'Yes — a lot'.
  final String painDisturbed;

  /// What helped sleep or rest — free selection from the screen's chip list.
  final List<String> helped;

  /// Free-text notes on patterns, in the user's own words.
  final String notes;

  // ── Serialization ───────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date.toIso8601String(),
      'sleepQuality': sleepQuality,
      'hoursSlept': hoursSlept,
      'fatigueLevel': fatigueLevel,
      'restBreaksNeeded': restBreaksNeeded,
      'wokeInNight': wokeInNight,
      'painDisturbed': painDisturbed,
      'helped': helped,
      'notes': notes,
    };
  }

  factory SleepFatigueEntry.fromJson(Map<String, dynamic> json) {
    return SleepFatigueEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      sleepQuality: json['sleepQuality'] as int,
      hoursSlept: json['hoursSlept'] as int,
      fatigueLevel: json['fatigueLevel'] as int,
      restBreaksNeeded: json['restBreaksNeeded'] as int,
      wokeInNight: json['wokeInNight'] as String,
      painDisturbed: json['painDisturbed'] as String,
      helped: List<String>.from(json['helped'] as List? ?? const []),
      notes: json['notes'] as String? ?? '',
    );
  }

  SleepFatigueEntry copyWith({
    String? id,
    DateTime? date,
    int? sleepQuality,
    int? hoursSlept,
    int? fatigueLevel,
    int? restBreaksNeeded,
    String? wokeInNight,
    String? painDisturbed,
    List<String>? helped,
    String? notes,
  }) {
    return SleepFatigueEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      hoursSlept: hoursSlept ?? this.hoursSlept,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      restBreaksNeeded: restBreaksNeeded ?? this.restBreaksNeeded,
      wokeInNight: wokeInNight ?? this.wokeInNight,
      painDisturbed: painDisturbed ?? this.painDisturbed,
      helped: helped ?? this.helped,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SleepFatigueEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SleepFatigueEntry(id: $id, date: $date, sleepQuality: $sleepQuality, '
        'hoursSlept: $hoursSlept, fatigueLevel: $fatigueLevel, '
        'restBreaksNeeded: $restBreaksNeeded, wokeInNight: $wokeInNight, '
        'painDisturbed: $painDisturbed, helped: $helped, notes: $notes)';
  }
}
