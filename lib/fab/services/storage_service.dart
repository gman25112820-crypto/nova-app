import 'package:hive_flutter/hive_flutter.dart';
import '../models/family_account.dart';

// ─────────────────────────────────────────────────────────────
// StorageService
//
// Central point for all per-child Hive box access.
//
// Box layout per child (id = ChildProfile.id):
//   child_<id>          → data box   — sleep, mood, health logs
//                         Skeleton key may read (not journal/safe)
//   child_<id>_journal  → journal box — diary + Safe Corner entries
//                         ALWAYS PRIVATE. Skeleton key blocked.
//
// Call StorageService.openChildBoxes(childId) before any box
// access. Idempotent — safe to call if already open.
// ─────────────────────────────────────────────────────────────

class StorageService {
  StorageService._();

  // ── Startup ──────────────────────────────────────────────────

  /// Opens all boxes for all currently-registered children.
  /// Called from main_fab.dart after FamilyAccount.init().
  static Future<void> init() async {
    final account = FamilyAccount.current;
    if (account == null) return;
    for (final child in account.children) {
      await openChildBoxes(child.id);
    }
  }

  // ── Box lifecycle ────────────────────────────────────────────

  /// Opens both boxes for a single child. Idempotent.
  static Future<void> openChildBoxes(String childId) async {
    if (!Hive.isBoxOpen(_dataKey(childId))) {
      await Hive.openBox<Map>(_dataKey(childId));
    }
    if (!Hive.isBoxOpen(_journalKey(childId))) {
      await Hive.openBox<Map>(_journalKey(childId));
    }
  }

  /// Closes and deletes all boxes for a child (used when removing
  /// a child profile — irreversible).
  static Future<void> deleteChildBoxes(String childId) async {
    await Hive.deleteBoxFromDisk(_dataKey(childId));
    await Hive.deleteBoxFromDisk(_journalKey(childId));
  }

  // ── Box accessors ─────────────────────────────────────────────

  /// Data box: sleep, mood, health, energy logs.
  /// Parent can request access via skeleton key (restricted).
  static Box<Map> dataBox(String childId) => Hive.box<Map>(_dataKey(childId));

  /// Journal box: diary entries, Safe Corner content.
  /// Always private — skeleton key access is hard-blocked here.
  static Box<Map> journalBox(String childId) =>
      Hive.box<Map>(_journalKey(childId));

  // ── Data helpers — typed wrappers ────────────────────────────

  static Future<void> writeData(
    String childId,
    String key,
    Map<String, dynamic> value,
  ) async {
    await dataBox(childId).put(key, value);
  }

  static Map<String, dynamic>? readData(String childId, String key) {
    final raw = dataBox(childId).get(key);
    return raw != null ? Map<String, dynamic>.from(raw) : null;
  }

  /// Returns all entries in the data box as an ordered list.
  static List<Map<String, dynamic>> allDataEntries(String childId) =>
      dataBox(childId)
          .values
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  static Future<void> writeJournal(
    String childId,
    String key,
    Map<String, dynamic> value,
  ) async {
    await journalBox(childId).put(key, value);
  }

  static List<Map<String, dynamic>> allJournalEntries(String childId) =>
      journalBox(childId)
          .values
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  // ── Key builders ─────────────────────────────────────────────

  static String _dataKey(String childId)    => 'child_$childId';
  static String _journalKey(String childId) => 'child_${childId}_journal';

  /// Generates a timestamped entry key (sortable).
  static String entryKey() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  // ── Skeleton key guard ────────────────────────────────────────

  /// Returns the data entries the skeleton key is permitted to
  /// expose: sleep, mood, and health keys only.
  /// Journal entries are never returned here — access must always
  /// go through journalBox() and be blocked at the UI layer.
  static List<Map<String, dynamic>> skeletonKeyDataEntries(
    String childId, {
    required List<String> allowedTypes,
  }) {
    return allDataEntries(childId).where((entry) {
      final type = entry['type'] as String? ?? '';
      return allowedTypes.contains(type);
    }).toList();
  }

  static const skeletonKeyAllowedTypes = ['sleep', 'mood', 'health'];
}
