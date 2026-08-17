import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../fab_theme.dart';

// ─────────────────────────────────────────────────────────────
// AgeMode — five age bands, derived from DOB, never stored.
//
// 0–3    → littleOnes    Parent observation tools. No PIN.
// 4–6    → earlyYears    Giraffe House — gentle, playful.
// 7–9    → middleYears   Eddie's House — active, exploratory.
// 10–12  → preteen       Older Kids' Space — progress focus.
// 13–18  → teen          Teen Space — privacy, goals, self-advocacy.
// ─────────────────────────────────────────────────────────────

enum AgeMode { littleOnes, earlyYears, middleYears, preteen, teen }

extension AgeModeLabel on AgeMode {
  String get label {
    switch (this) {
      case AgeMode.littleOnes:  return 'Little Ones';
      case AgeMode.earlyYears:  return 'Early Years';
      case AgeMode.middleYears: return 'Growing Up';
      case AgeMode.preteen:     return 'Finding Strength';
      case AgeMode.teen:        return 'My Space';
    }
  }

  String get emoji {
    switch (this) {
      case AgeMode.littleOnes:  return '🐣';
      case AgeMode.earlyYears:  return '🦒';
      case AgeMode.middleYears: return '🐕';
      case AgeMode.preteen:     return '💜';
      case AgeMode.teen:        return '⭐';
    }
  }

  String get character {
    switch (this) {
      case AgeMode.littleOnes:  return 'parent';
      case AgeMode.earlyYears:  return 'Giraffe Family';
      case AgeMode.middleYears: return 'Eddie';
      case AgeMode.preteen:     return "Older Kids' Space";
      case AgeMode.teen:        return 'Teen Space';
    }
  }

  String get ageRange {
    switch (this) {
      case AgeMode.littleOnes:  return '0–3 yrs';
      case AgeMode.earlyYears:  return '4–6 yrs';
      case AgeMode.middleYears: return '7–9 yrs';
      case AgeMode.preteen:     return '10–12 yrs';
      case AgeMode.teen:        return '13–18 yrs';
    }
  }

  bool get pinRecommended {
    switch (this) {
      case AgeMode.littleOnes:  return false;
      case AgeMode.earlyYears:  return false;
      case AgeMode.middleYears: return true;
      case AgeMode.preteen:     return true;
      case AgeMode.teen:        return true;
    }
  }

  // Backward compat: the 3-way ageMode used in older screens
  // maps coarsely. Callers that only need 3 bands can use this.
  bool get isParentFacing => this == AgeMode.littleOnes;
  bool get isChildFacing  => this != AgeMode.littleOnes;
}

// ─────────────────────────────────────────────────────────────
// ChildProfile
// ─────────────────────────────────────────────────────────────

class ChildProfile {
  final String id;
  String name;
  DateTime dob;
  List<FabCondition> conditions;

  // PIN stored as SHA-256 hex. Null = no PIN set.
  String? pinHash;

  ChildProfile({
    required this.id,
    required this.name,
    required this.dob,
    List<FabCondition>? conditions,
    this.pinHash,
  }) : conditions = conditions ?? [];

  // ── Age & mode ──────────────────────────────────────────────

  int get age {
    final today = DateTime.now();
    int years = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) { years--; }
    return years;
  }

  AgeMode get ageMode {
    final a = age;
    if (a <= 3)  return AgeMode.littleOnes;
    if (a <= 6)  return AgeMode.earlyYears;
    if (a <= 9)  return AgeMode.middleYears;
    if (a <= 12) return AgeMode.preteen;
    return AgeMode.teen;
  }

  bool get pinEnabled => pinHash != null;

  // ── Hive box keys ────────────────────────────────────────────
  // dataBoxKey    → sleep, mood, health logs (skeleton key can access these with restrictions)
  // journalBoxKey → diary/safe-corner entries — permanently private, skeleton key blocked

  String get dataBoxKey    => 'child_$id';
  String get journalBoxKey => 'child_${id}_journal';

  // ── PIN helpers ──────────────────────────────────────────────

  void setPin(String fourDigits) {
    pinHash = sha256.convert(utf8.encode(fourDigits)).toString();
  }

  void clearPin() => pinHash = null;

  bool checkPin(String fourDigits) {
    if (pinHash == null) return false;
    return pinHash == sha256.convert(utf8.encode(fourDigits)).toString();
  }

  // ── Serialisation ─────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id':         id,
    'name':       name,
    'dob':        dob.toIso8601String(),
    'conditions': conditions.map((c) => c.name).toList(),
    'pinHash':    pinHash,
  };

  factory ChildProfile.fromJson(Map<String, dynamic> j) => ChildProfile(
    id:   j['id']   as String,
    name: j['name'] as String,
    dob:  DateTime.parse(j['dob'] as String),
    conditions: (j['conditions'] as List? ?? [])
        .map((s) => FabCondition.values.firstWhere(
              (e) => e.name == s,
              orElse: () => FabCondition.adhd,
            ))
        .toList(),
    pinHash: j['pinHash'] as String?,
  );
}
