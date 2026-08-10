import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/check_in_entry.dart';

/// Local-only persistence for [CheckInEntry] records.
/// All data is stored on-device via Hive. Nothing is transmitted.
class CheckInRepository {
  static const String _boxName = 'checkins';

  Box<Map> get _box => Hive.box<Map>(_boxName);

  // ── Public API ──────────────────────────────────────────────────────────

  /// Saves [entry] to local storage, keyed by [CheckInEntry.id].
  /// Returns `true` on success, `false` if the write failed.
  Future<bool> saveEntry(CheckInEntry entry) async {
    try {
      await _box.put(entry.id, entry.toJson());
      return true;
    } catch (e, s) {
      debugPrint('CheckInRepository.saveEntry failed: $e\n$s');
      return false;
    }
  }

  /// Returns all stored entries sorted chronologically (oldest first).
  Future<List<CheckInEntry>> getAllEntries() async {
    try {
      final entries = _box.values
          .map((m) => CheckInEntry.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      entries.sort((a, b) => a.date.compareTo(b.date));
      return entries;
    } catch (e, s) {
      debugPrint('CheckInRepository.getAllEntries failed: $e\n$s');
      return [];
    }
  }

  /// Returns the entry matching [id], or `null` if not found.
  Future<CheckInEntry?> getEntryById(String id) async {
    try {
      final m = _box.get(id);
      if (m == null) return null;
      return CheckInEntry.fromJson(Map<String, dynamic>.from(m));
    } catch (e, s) {
      debugPrint('CheckInRepository.getEntryById failed: $e\n$s');
      return null;
    }
  }

  /// Permanently removes the entry matching [id].
  Future<void> deleteEntry(String id) async {
    try {
      await _box.delete(id);
    } catch (e, s) {
      debugPrint('CheckInRepository.deleteEntry failed: $e\n$s');
    }
  }
}
