import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/check_in_entry.dart';

/// Local-only persistence for [CheckInEntry] records.
/// All data is stored on-device via SharedPreferences. Nothing is transmitted.
class CheckInRepository {
  static const String _storageKey = 'nova_check_in_entries';

  // ── Public API ──────────────────────────────────────────────────────────

  /// Saves [entry] to local storage.
  /// If a record with the same [CheckInEntry.id] already exists it is
  /// replaced in-place; otherwise the entry is appended.
  Future<void> saveEntry(CheckInEntry entry) async {
    try {
      final List<CheckInEntry> entries = await getAllEntries();
      final int index = entries.indexWhere((e) => e.id == entry.id);
      if (index >= 0) {
        entries[index] = entry;
      } else {
        entries.add(entry);
      }
      await _persist(entries);
    } catch (_) {
      // IO failure — entry is not saved but the app continues running.
    }
  }

  /// Returns all stored entries sorted chronologically (oldest first).
  Future<List<CheckInEntry>> getAllEntries() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> raw = prefs.getStringList(_storageKey) ?? [];
      final List<CheckInEntry> entries = raw
          .map((s) => CheckInEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
      entries.sort((a, b) => a.date.compareTo(b.date));
      return entries;
    } catch (_) {
      return [];
    }
  }

  /// Returns the entry matching [id], or `null` if not found.
  Future<CheckInEntry?> getEntryById(String id) async {
    try {
      final List<CheckInEntry> entries = await getAllEntries();
      final int index = entries.indexWhere((e) => e.id == id);
      return index >= 0 ? entries[index] : null;
    } catch (_) {
      return null;
    }
  }

  /// Permanently removes the entry matching [id].
  /// Silently succeeds if the id does not exist.
  Future<void> deleteEntry(String id) async {
    try {
      final List<CheckInEntry> entries = await getAllEntries();
      entries.removeWhere((e) => e.id == id);
      await _persist(entries);
    } catch (_) {
      // IO failure — entry is not deleted but the app continues running.
    }
  }

  // ── Seed data ───────────────────────────────────────────────────────────

  /// Clears existing entries and writes 14 days of realistic back-pain and
  /// sciatica tracking data for local storage validation and export testing.
  ///
  /// Week 1 (days 14–8 ago): persistent mechanical lower-back pain.
  /// Week 2 (days 7–1 ago): acute sciatic nerve flare with leg radiation.
  ///
  /// All location strings use canonical [CheckInEntry] vocabulary only.
  /// Spec terms 'Lumbar'/'Sacrum' map to 'Lower back'; 'Left knee' maps
  /// to 'Left leg' — the closest canonical equivalents.
  Future<void> inject14DaySeedData() async {
    try {
      final DateTime today = DateTime.now();

      // Build the date for day N ago (time-of-day zeroed for clean ISO strings)
      DateTime daysAgo(int n) =>
          DateTime(today.year, today.month, today.day - n);

      final List<CheckInEntry> seed = [
        // ── Week 1: mechanical lower-back pain ──────────────────────────

        CheckInEntry(
          id: 'seed_day_01',
          date: daysAgo(14),
          painRating: 7,
          nerveSymptomRating: 5,
          painLocations: const ['Lower back'],
          symptoms: const ['Dull ache', 'Stiffness'],
          triggers: const ['Sitting too long', 'Bending'],
          notes: 'Woke with a deep dull ache across the lower back. '
              'Stiffness made it difficult to stand upright for the first hour. '
              'Had been sitting at the desk for most of yesterday.',
        ),

        CheckInEntry(
          id: 'seed_day_02',
          date: daysAgo(13),
          painRating: 6,
          nerveSymptomRating: 4,
          painLocations: const ['Lower back'],
          symptoms: const ['Dull ache', 'Tightness'],
          triggers: const ['Bending'],
          notes: 'Moderate low back pain through the afternoon. '
              'Bending to pick up a bag from the floor caused a sharp '
              'spike that settled to a tight ache within a few minutes.',
        ),

        CheckInEntry(
          id: 'seed_day_03',
          date: daysAgo(12),
          painRating: 8,
          nerveSymptomRating: 6,
          painLocations: const ['Lower back', 'Hip'],
          symptoms: const ['Sharp pain', 'Stiffness', 'Tightness'],
          triggers: const ['Sitting too long', 'Bending'],
          notes: 'Worst day this week. Sharp pain radiating from the lumbar '
              'region into the right hip after two hours sitting. '
              'Had to lie down mid-afternoon with heat on the lower back.',
        ),

        CheckInEntry(
          id: 'seed_day_04',
          date: daysAgo(11),
          painRating: 6,
          nerveSymptomRating: 5,
          painLocations: const ['Lower back'],
          symptoms: const ['Dull ache', 'Stiffness'],
          triggers: const ['Bending', 'Poor sleep'],
          notes: 'Disrupted sleep due to pain when turning over. '
              'Morning stiffness lasted about 90 minutes. '
              'Ache eased slightly after a warm shower and gentle walking.',
        ),

        CheckInEntry(
          id: 'seed_day_05',
          date: daysAgo(10),
          painRating: 7,
          nerveSymptomRating: 4,
          painLocations: const ['Lower back', 'Middle back'],
          symptoms: const ['Dull ache', 'Tightness'],
          triggers: const ['Sitting too long'],
          notes: 'Pain spread upward into the mid-back by early evening '
              'after a long period sitting at a desk. '
              'Standing helped temporarily but the ache returned quickly on sitting.',
        ),

        CheckInEntry(
          id: 'seed_day_06',
          date: daysAgo(9),
          painRating: 8,
          nerveSymptomRating: 7,
          painLocations: const ['Lower back', 'Hip'],
          symptoms: const ['Sharp pain', 'Burning', 'Stiffness'],
          triggers: const ['Sitting too long', 'Bending'],
          notes: 'Burning sensation across the sacral region alongside sharp '
              'pain when bending. Hip involvement more noticeable today. '
              'Needed pain relief medication to get through the afternoon.',
        ),

        CheckInEntry(
          id: 'seed_day_07',
          date: daysAgo(8),
          painRating: 7,
          nerveSymptomRating: 6,
          painLocations: const ['Lower back'],
          symptoms: const ['Dull ache', 'Tightness', 'Stiffness'],
          triggers: const ['Bending', 'Poor sleep'],
          notes: 'End of week one. Persistent low-level ache all day '
              'with pronounced stiffness in the mornings. '
              'Mobility noticeably reduced — struggling to dress without sitting down first.',
        ),

        // ── Week 2: acute sciatic nerve flare ───────────────────────────

        CheckInEntry(
          id: 'seed_day_08',
          date: daysAgo(7),
          painRating: 8,
          nerveSymptomRating: 8,
          painLocations: const ['Lower back', 'Hip', 'Left leg'],
          symptoms: const ['Sciatica', 'Nerve pain', 'Sharp pain'],
          triggers: const ['Sitting too long', 'Bending'],
          notes: 'New symptom today: pain tracking down the left leg from '
              'the hip. Feels like a hot wire running through the back '
              'of the thigh. Sciatic nerve involvement now seems likely.',
        ),

        CheckInEntry(
          id: 'seed_day_09',
          date: daysAgo(6),
          painRating: 9,
          nerveSymptomRating: 9,
          painLocations: const ['Lower back', 'Hip', 'Left leg'],
          symptoms: const ['Sciatica', 'Pins and needles', 'Nerve pain'],
          triggers: const ['Sitting too long', 'Walking'],
          notes: 'Severe tingling running down left thigh after sitting at the desk. '
              'Pins and needles in the lower leg when walking more than a '
              'few minutes. Had to stop and rest twice crossing the house.',
        ),

        CheckInEntry(
          id: 'seed_day_10',
          date: daysAgo(5),
          painRating: 7,
          nerveSymptomRating: 8,
          painLocations: const ['Lower back', 'Hip', 'Left leg'],
          symptoms: const ['Nerve pain', 'Numbness', 'Dull ache'],
          triggers: const ['Sitting too long', 'Bending'],
          notes: 'Numbness in the left foot on waking — lasted around 20 minutes. '
              'Nerve pain along the left leg throughout the day. '
              'Dull lumbar ache constant in the background.',
        ),

        CheckInEntry(
          id: 'seed_day_11',
          date: daysAgo(4),
          painRating: 9,
          nerveSymptomRating: 10,
          painLocations: const ['Lower back', 'Hip', 'Left leg'],
          symptoms: const ['Sciatica', 'Nerve pain', 'Pins and needles'],
          triggers: const ['Sitting too long', 'Bending', 'Walking'],
          notes: 'Worst nerve pain so far. Electric shooting sensation from '
              'the lower back through the left hip and down to the calf. '
              'Unable to sit for more than five minutes. Mostly lying flat all day.',
        ),

        CheckInEntry(
          id: 'seed_day_12',
          date: daysAgo(3),
          painRating: 8,
          nerveSymptomRating: 9,
          painLocations: const ['Lower back', 'Hip', 'Left leg'],
          symptoms: const ['Sciatica', 'Numbness', 'Burning'],
          triggers: const ['Sitting too long', 'Poor sleep'],
          notes: 'Sleep severely disrupted — nerve pain when lying on either side. '
              'Could only manage short periods on the back with a pillow under the knees. '
              'Numbness and burning down the left leg persisting all day.',
        ),

        CheckInEntry(
          id: 'seed_day_13',
          date: daysAgo(2),
          painRating: 9,
          nerveSymptomRating: 8,
          painLocations: const ['Lower back', 'Hip', 'Left leg'],
          symptoms: const ['Nerve pain', 'Pins and needles', 'Weakness'],
          triggers: const ['Sitting too long', 'Walking', 'Bending'],
          notes: 'Left leg felt weak and unreliable when walking. '
              'Pins and needles constant below the knee. '
              'Had to use the wall for support getting up from a chair.',
        ),

        CheckInEntry(
          id: 'seed_day_14',
          date: daysAgo(1),
          painRating: 7,
          nerveSymptomRating: 9,
          painLocations: const ['Lower back', 'Hip', 'Left leg'],
          symptoms: const ['Sciatica', 'Nerve pain', 'Pins and needles'],
          triggers: const ['Sitting too long', 'Bending'],
          notes: 'Slight reduction in raw pain rating today but nerve symptoms '
              'remain severe. Sciatica still tracking from the lower back '
              'to the left calf. Preparing notes for GP appointment.',
        ),
      ];

      // Clear existing entries under this key, then write the full seed batch.
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await _persist(seed);
    } catch (_) {
      // IO failure — seed data not written but the app continues running.
    }
  }

  // ── Internal helpers ────────────────────────────────────────────────────

  Future<void> _persist(List<CheckInEntry> entries) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> serialized =
        entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, serialized);
  }
}
