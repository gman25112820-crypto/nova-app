import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../fab_theme.dart';

// ─────────────────────────────────────────────────────────────
// Age mode — derived from DOB, never stored directly.
// 0–4   → Little Ones  (parent observation log, no PIN)
// 5–11  → Growing Up   (child-facing, optional PIN)
// 12+   → Finding Me   (child-facing, PIN encouraged)
// ─────────────────────────────────────────────────────────────

enum AgeMode { littleOnes, growingUp, findingMe }

extension AgeModeLabel on AgeMode {
  String get label {
    switch (this) {
      case AgeMode.littleOnes: return 'Little Ones';
      case AgeMode.growingUp:  return 'Growing Up';
      case AgeMode.findingMe:  return 'Finding Me';
    }
  }

  String get emoji {
    switch (this) {
      case AgeMode.littleOnes: return '🐣';
      case AgeMode.growingUp:  return '🌱';
      case AgeMode.findingMe:  return '⭐';
    }
  }
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
    if (a <= 4)  return AgeMode.littleOnes;
    if (a <= 11) return AgeMode.growingUp;
    return AgeMode.findingMe;
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
