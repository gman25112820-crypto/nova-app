import 'package:shared_preferences/shared_preferences.dart';
import 'selected_child_service.dart';

// ─────────────────────────────────────────────────────────────
// FAB STARS SERVICE
// Centralised earning logic. All reads/writes go through here.
// Keys used:
//   fab_stars                    — current balance (int)
//   fab_stars_first_ever_done    — welcome bonus flag (bool)
//   fab_checkin_stars_YYYY-MM-DD — check-in award guard (bool)
//   fab_pain_stars_YYYY-MM-DD    — pain-log award guard (bool)
//   checkin_done_YYYY-MM-DD      — existing check-in flag (bool)
// ─────────────────────────────────────────────────────────────

class FabStarsService {
  static const _balanceKey   = 'fab_stars';
  static const _firstEverKey = 'fab_stars_first_ever_done';

  // ── Public API ────────────────────────────────────────────────

  static Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_balanceKey) ?? 0;
  }

  /// Award stars for completing a daily check-in.
  /// Safe to call multiple times — guard prevents double-awarding on same day.
  static Future<AwardResult> awardForCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());

    final alreadyAwarded = prefs.getBool('fab_checkin_stars_$today') ?? false;
    if (alreadyAwarded) {
      return AwardResult.empty(prefs.getInt(_balanceKey) ?? 0);
    }

    final breakdown = <String>[];
    int earned = 0;

    // Welcome bonus — first check-in ever
    final firstEver = prefs.getBool(_firstEverKey) ?? false;
    if (!firstEver) {
      earned += 20;
      breakdown.add('🎉 Welcome bonus +20');
      await prefs.setBool(_firstEverKey, true);
    }

    // Base check-in reward
    earned += 5;
    breakdown.add('⭐ Check-in +5');

    // Streak bonus (streak includes today)
    final streakChild = SelectedChildService.current ?? SelectedChildService.selectDefault();
    final streak = _calcStreak(prefs, streakChild?.id ?? '');
    if (streak >= 7) {
      earned += 25;
      breakdown.add('🔥 7-day streak +25');
    } else if (streak >= 3) {
      earned += 10;
      breakdown.add('🔥 3-day streak +10');
    }

    final newBalance = (prefs.getInt(_balanceKey) ?? 0) + earned;
    await prefs.setInt(_balanceKey, newBalance);
    await prefs.setBool('fab_checkin_stars_$today', true);

    return AwardResult(earned: earned, breakdown: breakdown, balance: newBalance);
  }

  /// Spend stars from the balance.
  /// Returns true if successful, false if [amount] exceeds current balance.
  static Future<bool> spendStars(int amount) async {
    if (amount <= 0) return false;
    final prefs   = await SharedPreferences.getInstance();
    final current = prefs.getInt(_balanceKey) ?? 0;
    if (current < amount) return false;
    await prefs.setInt(_balanceKey, current - amount);
    return true;
  }

  /// Award stars for saving a pain log entry.
  /// 5 stars per day, once only. Welcome bonus if first-ever entry.
  static Future<AwardResult> awardForPainEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());

    final alreadyAwarded = prefs.getBool('fab_pain_stars_$today') ?? false;
    if (alreadyAwarded) {
      return AwardResult.empty(prefs.getInt(_balanceKey) ?? 0);
    }

    final breakdown = <String>[];
    int earned = 0;

    // Welcome bonus — shared flag with check-in
    final firstEver = prefs.getBool(_firstEverKey) ?? false;
    if (!firstEver) {
      earned += 20;
      breakdown.add('🎉 Welcome bonus +20');
      await prefs.setBool(_firstEverKey, true);
    }

    earned += 5;
    breakdown.add('⭐ Pain log +5');

    final newBalance = (prefs.getInt(_balanceKey) ?? 0) + earned;
    await prefs.setInt(_balanceKey, newBalance);
    await prefs.setBool('fab_pain_stars_$today', true);

    return AwardResult(earned: earned, breakdown: breakdown, balance: newBalance);
  }

  /// Award stars for finishing a game round. No daily guard — rewarded each time.
  static Future<AwardResult> awardForGame(int stars, String label) async {
    if (stars <= 0) return AwardResult.empty(await getBalance());
    final prefs = await SharedPreferences.getInstance();
    final newBalance = (prefs.getInt(_balanceKey) ?? 0) + stars;
    await prefs.setInt(_balanceKey, newBalance);
    return AwardResult(
      earned: stars,
      breakdown: ['$label +$stars'],
      balance: newBalance,
    );
  }

  // ── Internals ─────────────────────────────────────────────────

  static String _dateKey(DateTime d) => d.toIso8601String().substring(0, 10);

  /// Count consecutive days with checkin_done flag, including today.
  static int _calcStreak(SharedPreferences prefs, String childId) {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final key = '${childId}_checkin_done_${_dateKey(now.subtract(Duration(days: i)))}';
      if (prefs.getBool(key) ?? false) {
        streak++;
      } else {
        break;
      }
    }
    // Today's check-in flag is written before this is called, so streak >= 1 if today done.
    return streak;
  }
}

// ─────────────────────────────────────────────────────────────
// AWARD RESULT
// ─────────────────────────────────────────────────────────────

class AwardResult {
  final int earned;
  final List<String> breakdown;
  final int balance;

  const AwardResult({
    required this.earned,
    required this.breakdown,
    required this.balance,
  });

  factory AwardResult.empty(int balance) =>
      AwardResult(earned: 0, breakdown: const [], balance: balance);

  bool get hasEarned => earned > 0;

  /// Short snackbar message: "⭐ +5 Fab Stars! Total: 47 ⭐"
  String get snackMessage =>
      hasEarned ? '⭐ +$earned Fab Stars!  Total: $balance ⭐' : '';

  /// Multi-line breakdown for the done screen.
  String get breakdownText => breakdown.join('\n');
}
