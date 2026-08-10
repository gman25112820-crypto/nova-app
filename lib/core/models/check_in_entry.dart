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
    this.mobilityScore,
    this.walkingTolerance,
    this.sittingTolerance,
    this.standingTolerance,
    this.helped,
    this.safeNextStep,
    this.flareNotes,
    this.medicationNotes,
    this.sleepNotes,
    this.gpNotes,
    this.evidenceNotes,
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

  /// Back Pain module fields — all optional, all nullable.
  final int? mobilityScore;
  final int? walkingTolerance;
  final int? sittingTolerance;
  final int? standingTolerance;
  final List<String>? helped;
  final String? safeNextStep;
  final String? flareNotes;
  final String? medicationNotes;
  final String? sleepNotes;
  final String? gpNotes;
  final String? evidenceNotes;

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
      if (mobilityScore != null) 'mobilityScore': mobilityScore,
      if (walkingTolerance != null) 'walkingTolerance': walkingTolerance,
      if (sittingTolerance != null) 'sittingTolerance': sittingTolerance,
      if (standingTolerance != null) 'standingTolerance': standingTolerance,
      if (helped != null) 'helped': helped,
      if (safeNextStep != null) 'safeNextStep': safeNextStep,
      if (flareNotes != null) 'flareNotes': flareNotes,
      if (medicationNotes != null) 'medicationNotes': medicationNotes,
      if (sleepNotes != null) 'sleepNotes': sleepNotes,
      if (gpNotes != null) 'gpNotes': gpNotes,
      if (evidenceNotes != null) 'evidenceNotes': evidenceNotes,
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
      mobilityScore: json['mobilityScore'] as int?,
      walkingTolerance: json['walkingTolerance'] as int?,
      sittingTolerance: json['sittingTolerance'] as int?,
      standingTolerance: json['standingTolerance'] as int?,
      helped: json['helped'] != null
          ? List<String>.from(json['helped'] as List)
          : null,
      safeNextStep: json['safeNextStep'] as String?,
      flareNotes: json['flareNotes'] as String?,
      medicationNotes: json['medicationNotes'] as String?,
      sleepNotes: json['sleepNotes'] as String?,
      gpNotes: json['gpNotes'] as String?,
      evidenceNotes: json['evidenceNotes'] as String?,
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
    int? mobilityScore,
    int? walkingTolerance,
    int? sittingTolerance,
    int? standingTolerance,
    List<String>? helped,
    String? safeNextStep,
    String? flareNotes,
    String? medicationNotes,
    String? sleepNotes,
    String? gpNotes,
    String? evidenceNotes,
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
      mobilityScore: mobilityScore ?? this.mobilityScore,
      walkingTolerance: walkingTolerance ?? this.walkingTolerance,
      sittingTolerance: sittingTolerance ?? this.sittingTolerance,
      standingTolerance: standingTolerance ?? this.standingTolerance,
      helped: helped ?? this.helped,
      safeNextStep: safeNextStep ?? this.safeNextStep,
      flareNotes: flareNotes ?? this.flareNotes,
      medicationNotes: medicationNotes ?? this.medicationNotes,
      sleepNotes: sleepNotes ?? this.sleepNotes,
      gpNotes: gpNotes ?? this.gpNotes,
      evidenceNotes: evidenceNotes ?? this.evidenceNotes,
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
        'medicationTaken: $medicationTaken, '
        'mobilityScore: $mobilityScore, walkingTolerance: $walkingTolerance, '
        'sittingTolerance: $sittingTolerance, '
        'standingTolerance: $standingTolerance, helped: $helped, '
        'safeNextStep: $safeNextStep, flareNotes: $flareNotes, '
        'medicationNotes: $medicationNotes, sleepNotes: $sleepNotes, '
        'gpNotes: $gpNotes, evidenceNotes: $evidenceNotes)';
  }
}
