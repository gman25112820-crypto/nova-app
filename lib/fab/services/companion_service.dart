import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_account.dart';
import '../widgets/chicken_lips_widget.dart';
import 'profile_service.dart';

// ─────────────────────────────────────────────────────────────
// CompanionService
//
// Builds the greeting Miss Chicken Lips shows on the world
// scene each session.
//
// Little Ones mode (first child age < 5):
//   Chicken Lips addresses the parent, not the child.
//   Reacts to 'fab_lo_last_obs' — the category of the parent's
//   last observation log entry (set by LittleOnesLogScreen).
//
// Growing Up / Finding Me mode (age 5+):
//   Pulls from ProfileService (name, streak, lastCheckIn) and
//   SharedPreferences 'fab_mood_today' (child's last mood emoji).
//   Priority: streak → silence → mood → time-of-day.
// ─────────────────────────────────────────────────────────────

class CompanionGreeting {
  final String text;
  final ChickenMood mood;
  const CompanionGreeting({required this.text, required this.mood});
}

class CompanionService {
  CompanionService._();

  static Future<CompanionGreeting> load() async {
    final prefs = await SharedPreferences.getInstance();

    // ── Detect Little Ones mode ──────────────────────────────
    final firstChild = FamilyAccount.current?.children.isNotEmpty == true
        ? FamilyAccount.current!.children.first
        : null;

    if (firstChild != null && firstChild.age < 5) {
      return _buildLittleOnes(
        childName: firstChild.name,
        lastObsCategory: prefs.getString('fab_lo_last_obs'),
      );
    }

    // ── Standard mode (age 5+) ───────────────────────────────
    final profile     = ProfileService.profile;
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

  // ── Little Ones greeting (parent-facing) ──────────────────────

  static CompanionGreeting _buildLittleOnes({
    required String childName,
    String? lastObsCategory,
  }) {
    switch (lastObsCategory) {
      case 'mood':
        return CompanionGreeting(
          text: 'You\'ve been noting $childName\'s mood — you\'re so in tune! '
              'How are they feeling today? 💛',
          mood: ChickenMood.happy,
        );
      case 'communication':
        return CompanionGreeting(
          text: 'Communication milestone spotted! How is $childName getting on today? 💬',
          mood: ChickenMood.proud,
        );
      case 'sleep':
        return CompanionGreeting(
          text: 'Tracking $childName\'s sleep — every bit of data helps. '
              'How did last night go? 🌙',
          mood: ChickenMood.sleeping,
        );
      case 'sensory':
        return CompanionGreeting(
          text: 'You\'re really in tune with $childName\'s sensory world. '
              'How are they feeling today? ✨',
          mood: ChickenMood.wink,
        );
      default:
        return CompanionGreeting(
          text: 'Hello! How is $childName doing today? 🐣',
          mood: ChickenMood.happy,
        );
    }
  }

  // ── Standard greeting (child-facing) ─────────────────────────

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
