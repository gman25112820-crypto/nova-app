import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/chicken_lips_widget.dart';
import 'profile_service.dart';

// ─────────────────────────────────────────────────────────────
// CompanionService
//
// Builds the greeting Miss Chicken Lips shows on the world
// scene each session. Pulls from:
//   • ProfileService (name, streak, lastCheckIn)
//   • SharedPreferences 'fab_mood_today' (last tapped mood emoji)
//
// Priority order:
//   1. 7+ day streak  → crowned celebration
//   2. 3+ days silent → she misses them
//   3. Today's mood   → mood-matched reaction
//   4. Time of day    → morning / afternoon / evening
// ─────────────────────────────────────────────────────────────

class CompanionGreeting {
  final String text;
  final ChickenMood mood;
  const CompanionGreeting({required this.text, required this.mood});
}

class CompanionService {
  CompanionService._();

  static Future<CompanionGreeting> load() async {
    final prefs   = await SharedPreferences.getInstance();
    final profile = ProfileService.profile;

    final name        = profile?.name ?? 'friend';
    final streak      = profile?.currentStreak ?? 0;
    final lastCheckIn = profile?.lastCheckIn;
    final moodEmoji   = prefs.getString('fab_mood_today');

    return _build(
      name: name,
      streak: streak,
      lastCheckIn: lastCheckIn,
      moodEmoji: moodEmoji,
    );
  }

  static CompanionGreeting _build({
    required String name,
    required int streak,
    DateTime? lastCheckIn,
    String? moodEmoji,
  }) {
    final now = DateTime.now();

    // ── 1. Streak celebration ────────────────────────────────
    if (streak >= 7) {
      return CompanionGreeting(
        text: '$streak days in a row, $name! You\'re absolutely fabulous! 🌟',
        mood: ChickenMood.crowned,
      );
    }

    // ── 2. She misses them (3+ days no log) ─────────────────
    if (lastCheckIn != null &&
        now.difference(lastCheckIn).inDays >= 3) {
      return CompanionGreeting(
        text: 'Haven\'t heard from you in a while, $name… '
            'I\'ve missed you! 💜',
        mood: ChickenMood.sad,
      );
    }

    // ── 3. Mood-matched reaction ─────────────────────────────
    if (moodEmoji != null) {
      if (moodEmoji == '😄' || moodEmoji == '🙂') {
        return CompanionGreeting(
          text: 'You seem fab today, $name! ✨',
          mood: ChickenMood.happy,
        );
      }
      if (moodEmoji == '😟' || moodEmoji == '😣') {
        return CompanionGreeting(
          text: 'Let\'s find a quiet spot together, $name 💜',
          mood: ChickenMood.worried,
        );
      }
    }

    // ── 4. No mood logged yet ────────────────────────────────
    if (moodEmoji == null) {
      return CompanionGreeting(
        text: 'How are you feeling today, $name?',
        mood: ChickenMood.happy,
      );
    }

    // ── 5. Time-of-day fallback ──────────────────────────────
    return _byTime(name);
  }

  static CompanionGreeting _byTime(String name) {
    final h = DateTime.now().hour;
    if (h < 12) {
      return CompanionGreeting(
        text: 'Good morning, $name! Ready for a fabulous day? ☀️',
        mood: ChickenMood.happy,
      );
    }
    if (h < 17) {
      return CompanionGreeting(
        text: 'Good afternoon, $name! 💛',
        mood: ChickenMood.wink,
      );
    }
    return CompanionGreeting(
      text: 'Evening, $name! Time to wind down 🌙',
      mood: ChickenMood.sleeping,
    );
  }
}
