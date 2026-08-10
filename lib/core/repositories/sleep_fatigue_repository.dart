import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/sleep_fatigue_entry.dart';

/// Local-only persistence for [SleepFatigueEntry] records.
/// All data is stored on-device via Hive. Nothing is transmitted.
/// Mirrors [CheckInRepository]'s shape exactly — same box-per-module pattern.
class SleepFatigueRepository {
  static const String _boxName = 'sleep_fatigue';

  Box<Map> get _box => Hive.box<Map>(_boxName);

  // ── Public API ──────────────────────────────────────────────────────────

  /// Saves [entry] to local storage, keyed by [SleepFatigueEntry.id].
  /// Returns `true` on success, `false` if the write failed.
  Future<bool> saveEntry(SleepFatigueEntry entry) async {
    try {
      await _box.put(entry.id, entry.toJson());
      return true;
    } catch (e, s) {
      debugPrint('SleepFatigueRepository.saveEntry failed: $e\n$s');
      return false;
    }
  }

  /// Returns all stored entries sorted chronologically (oldest first).
  Future<List<SleepFatigueEntry>> getAllEntries() async {
    try {
      final entries = _box.values
          .map((m) => SleepFatigueEntry.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      entries.sort((a, b) => a.date.compareTo(b.date));
      return entries;
    } catch (e, s) {
      debugPrint('SleepFatigueRepository.getAllEntries failed: $e\n$s');
      return [];
    }
  }

  /// Returns the entry matching [id], or `null` if not found.
  Future<SleepFatigueEntry?> getEntryById(String id) async {
    try {
      final m = _box.get(id);
      if (m == null) return null;
      return SleepFatigueEntry.fromJson(Map<String, dynamic>.from(m));
    } catch (e, s) {
      debugPrint('SleepFatigueRepository.getEntryById failed: $e\n$s');
      return null;
    }
  }

  /// Permanently removes the entry matching [id].
  Future<void> deleteEntry(String id) async {
    try {
      await _box.delete(id);
    } catch (e, s) {
      debugPrint('SleepFatigueRepository.deleteEntry failed: $e\n$s');
    }
  }
}
