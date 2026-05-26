import 'package:flutter/foundation.dart';

/// A single adult health check-in entry for local storage.
/// All data stays on-device. No external transmission.
@immutable
class CheckInEntry {
  const CheckInEntry({
    required this.id,
    required this.date,
    required this.painRating,
    required this.nerveSymptomRating,
    required this.painLocations,
    required this.symptoms,
    required this.triggers,
    required this.notes,
    this.focusScore,
    this.hyperactivityScore,
    this.medicationTaken,
  });

  final String id;
  final DateTime date;

  /// Overall pain intensity 0–10.
  final int painRating;

  /// Nerve symptom intensity 0–10 (sciatica, pins and needles, numbness, etc.).
  final int nerveSymptomRating;

  /// Body regions selected by the user.
  /// Valid values match the location list used in NovaBackPainModuleScreen:
  /// 'Lower back', 'Middle back', 'Upper back', 'Hip',
  /// 'Left leg', 'Right leg', 'Both legs', 'Neck/shoulder'.
  /// General locations from PainScreen are also accepted:
  /// 'Head', 'Neck', 'Shoulders', 'Chest', 'Back',
  /// 'Arms', 'Hands', 'Stomach', 'Hips', 'Legs', 'Feet'.
  final List<String> painLocations;

  /// Symptom descriptors selected by the user.
  /// Sourced from NovaBackPainModuleScreen symptom options:
  /// 'Sciatica', 'Nerve pain', 'Sharp pain', 'Dull ache', 'Burning',
  /// 'Pins and needles', 'Numbness', 'Stiffness', 'Weakness', 'Spasm'.
  /// General descriptors from PainScreen also accepted:
  /// 'Throbbing', 'Tightness', 'Tingling', 'Pressure'.
  final List<String> symptoms;

  /// Triggers identified by the user.
  /// Sourced from NovaBackPainModuleScreen trigger options:
  /// 'Sitting too long', 'Standing too long', 'Walking', 'Bending',
  /// 'Lifting', 'Poor sleep', 'Stress', 'Cold weather',
  /// 'Overdoing it', 'Unknown'.
  final List<String> triggers;

  /// Free-text notes in the user's own words.
  final String notes;
  final int? focusScore;
  final int? hyperactivityScore;
  final bool? medicationTaken;

  // ── Canonical vocabulary ────────────────────────────────────────────────

  /// Back-specific pain locations (from NovaBackPainModuleScreen).
  static const List<String> backLocations = [
    'Lower back',
    'Middle back',
    'Upper back',
    'Hip',
    'Left leg',
    'Right leg',
    'Both legs',
    'Neck/shoulder',
  ];

  /// General body locations (from PainScreen).
  static const List<String> generalLocations = [
    'Head',
    'Neck',
    'Shoulders',
    'Chest',
    'Back',
    'Arms',
    'Hands',
    'Stomach',
    'Hips',
    'Legs',
    'Feet',
  ];

  /// Symptom descriptors (merged from both screens, deduplicated).
  static const List<String> knownSymptoms = [
    'Sciatica',
    'Nerve pain',
    'Sharp pain',
    'Dull ache',
    'Burning',
    'Pins and needles',
    'Numbness',
    'Stiffness',
    'Weakness',
    'Spasm',
    'Throbbing',
    'Tightness',
    'Tingling',
    'Pressure',
  ];

  /// Triggers (from NovaBackPainModuleScreen).
  static const List<String> knownTriggers = [
    'Sitting too long',
    'Standing too long',
    'Walking',
    'Bending',
    'Lifting',
    'Poor sleep',
    'Stress',
    'Cold weather',
    'Overdoing it',
    'Unknown',
  ];

  // ── Serialization ───────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date.toIso8601String(),
      'painRating': painRating,
      'nerveSymptomRating': nerveSymptomRating,
      'painLocations': painLocations,
      'symptoms': symptoms,
      'triggers': triggers,
      'notes': notes,
      if (focusScore != null) 'focusScore': focusScore,
      if (hyperactivityScore != null) 'hyperactivityScore': hyperactivityScore,
      if (medicationTaken != null) 'medicationTaken': medicationTaken,
    };
  }

  factory CheckInEntry.fromJson(Map<String, dynamic> json) {
    return CheckInEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      painRating: json['painRating'] as int,
      nerveSymptomRating: json['nerveSymptomRating'] as int,
      painLocations: List<String>.from(json['painLocations'] as List),
      symptoms: List<String>.from(json['symptoms'] as List),
      triggers: List<String>.from(json['triggers'] as List),
      notes: json['notes'] as String,
      focusScore: json['focusScore'] as int?,
      hyperactivityScore: json['hyperactivityScore'] as int?,
      medicationTaken: json['medicationTaken'] as bool?,
    );
  }

  // ── Value equality ──────────────────────────────────────────────────────

  CheckInEntry copyWith({
    String? id,
    DateTime? date,
    int? painRating,
    int? nerveSymptomRating,
    List<String>? painLocations,
    List<String>? symptoms,
    List<String>? triggers,
    String? notes,
    int? focusScore,
    int? hyperactivityScore,
    bool? medicationTaken,
  }) {
    return CheckInEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      painRating: painRating ?? this.painRating,
      nerveSymptomRating: nerveSymptomRating ?? this.nerveSymptomRating,
      painLocations: painLocations ?? this.painLocations,
      symptoms: symptoms ?? this.symptoms,
      triggers: triggers ?? this.triggers,
      notes: notes ?? this.notes,
      focusScore: focusScore ?? this.focusScore,
      hyperactivityScore: hyperactivityScore ?? this.hyperactivityScore,
      medicationTaken: medicationTaken ?? this.medicationTaken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckInEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CheckInEntry(id: $id, date: $date, painRating: $painRating, '
        'nerveSymptomRating: $nerveSymptomRating, '
        'painLocations: $painLocations, symptoms: $symptoms, '
        'triggers: $triggers, notes: $notes, '
        'focusScore: $focusScore, hyperactivityScore: $hyperactivityScore, '
        'medicationTaken: $medicationTaken)';
  }
}
