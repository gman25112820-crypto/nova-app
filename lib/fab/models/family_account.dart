import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'child_profile.dart';

// ─────────────────────────────────────────────────────────────
// FamilyAccount
//
// Stored in Hive box 'family_account' under key 'current'.
// Holds the ordered list of ChildProfiles and the parent
// password hash (used for skeleton key access).
//
// Password is never stored in plain text. SHA-256 hash only.
// ─────────────────────────────────────────────────────────────

class FamilyAccount {
  final String id;
  List<ChildProfile> children;

  // Parent password stored as SHA-256 hex. Null = not set.
  String? passwordHash;

  // 4-digit parent PIN hash (separate from full password). Null = no PIN set.
  String? parentPinHash;

  FamilyAccount({
    required this.id,
    List<ChildProfile>? children,
    this.passwordHash,
    this.parentPinHash,
  }) : children = children ?? [];

  // ── Password helpers ─────────────────────────────────────────

  void setPassword(String password) {
    passwordHash = sha256.convert(utf8.encode(password)).toString();
  }

  bool checkPassword(String password) {
    if (passwordHash == null) return false;
    return passwordHash == sha256.convert(utf8.encode(password)).toString();
  }

  // ── Parent PIN helpers ────────────────────────────────────────

  bool get hasParentPin => parentPinHash != null;

  void setParentPin(String pin) {
    parentPinHash = sha256.convert(utf8.encode(pin)).toString();
  }

  bool checkParentPin(String pin) {
    if (parentPinHash == null) return true; // no PIN set → allow through
    return parentPinHash == sha256.convert(utf8.encode(pin)).toString();
  }

  void clearParentPin() => parentPinHash = null;

  // ── Child helpers ─────────────────────────────────────────────

  void addChild(ChildProfile child) => children.add(child);

  void removeChild(String childId) =>
      children.removeWhere((c) => c.id == childId);

  ChildProfile? childById(String id) {
    try {
      return children.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Persistence ──────────────────────────────────────────────

  static const _boxKey  = 'family_account';
  static const _dataKey = 'current';

  static FamilyAccount? _cached;
  static FamilyAccount? get current => _cached;

  static Future<void> init() async {
    final box = Hive.box<Map>(_boxKey);
    final raw = box.get(_dataKey);
    if (raw != null) {
      _cached = FamilyAccount.fromJson(Map<String, dynamic>.from(raw));
    }
  }

  Future<void> save() async {
    _cached = this;
    await Hive.box<Map>(_boxKey).put(_dataKey, toJson());
  }

  // ── Serialisation ─────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id':            id,
    'children':      children.map((c) => c.toJson()).toList(),
    'passwordHash':  passwordHash,
    'parentPinHash': parentPinHash,
  };

  factory FamilyAccount.fromJson(Map<String, dynamic> j) => FamilyAccount(
    id: j['id'] as String,
    children: (j['children'] as List? ?? [])
        .map((e) => ChildProfile.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    passwordHash:  j['passwordHash']  as String?,
    parentPinHash: j['parentPinHash'] as String?,
  );

  factory FamilyAccount.create() => FamilyAccount(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
  );
}
