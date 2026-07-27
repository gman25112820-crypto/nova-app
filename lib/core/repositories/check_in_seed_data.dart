/// DEBUG-ONLY seed data for the check-in log.
///
/// Calling [seedDebugCheckInData] clears every check-in entry in local
/// storage and replaces it with 14 days of scripted back-pain/sciatica
/// data. This must never be called in a release build.
library;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/check_in_entry.dart';
import 'check_in_repository.dart';

/// Clears all check-in data and writes 14 days of realistic back-pain and
/// sciatica tracking data, for local storage validation and export testing.
Future<void> seedDebugCheckInData() async {
  try {
    final DateTime today = DateTime.now();

    DateTime daysAgo(int n) =>
        DateTime(today.year, today.month, today.day - n);

    final List<CheckInEntry> seed = [
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

    await Hive.box<Map>('checkins').clear();
    final repository = CheckInRepository();
    for (final entry in seed) {
      await repository.saveEntry(entry);
    }
  } catch (e, s) {
    debugPrint('seedDebugCheckInData failed: $e\n$s');
  }
}
