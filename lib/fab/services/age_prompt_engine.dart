// ─────────────────────────────────────────────────────────────
// AgePromptEngine
//
// Derives age-aware prompts and transition state from a child's
// age (calculated from ChildProfile.dob). UK school year is
// approximated as: year ≈ age − 4 (Reception = Year 0).
//
// Transition phases:
//   Year 5-6 (age 9-11) — gentle prep prompts
//   Year 7   (age 11-12) — transition mode active
//   Year 8-9 (age 12-14) — hormone/mood shift prompts
// ─────────────────────────────────────────────────────────────

class AgePromptResult {
  final int schoolYear;
  final bool showTransitionBanner;
  final String? bannerMessage;
  final String? checkInPrompt;

  const AgePromptResult({
    required this.schoolYear,
    required this.showTransitionBanner,
    this.bannerMessage,
    this.checkInPrompt,
  });
}

class AgePromptEngine {
  AgePromptEngine._();

  /// UK school year approximation from age.
  static int schoolYearFromAge(int age) => (age - 4).clamp(0, 13);

  /// Evaluate transition state and prompts for a child of [age] years.
  static AgePromptResult evaluate(int age) {
    final year = schoolYearFromAge(age);

    // ── Year 5-6 (age 9-11): gentle prep ─────────────────────
    if (year == 5 || year == 6) {
      return AgePromptResult(
        schoolYear: year,
        showTransitionBanner: true,
        bannerMessage: year == 6
            ? 'Big changes coming up soon 💜  We\'ve got you.'
            : 'Secondary school is on the horizon — no rush!',
        checkInPrompt:
            'Big changes are coming up. How are you feeling about moving schools?',
      );
    }

    // ── Year 7 (age 11-12): new school ───────────────────────
    if (year == 7) {
      return AgePromptResult(
        schoolYear: year,
        showTransitionBanner: true,
        bannerMessage: 'New school, new chapter 💜  How\'s it going?',
        checkInPrompt: 'How\'s the new school going? What\'s the best bit so far?',
      );
    }

    // ── Year 8-9 (age 12-14): mood shift awareness ────────────
    if (year == 8 || year == 9) {
      return AgePromptResult(
        schoolYear: year,
        showTransitionBanner: false,
        checkInPrompt:
            'Lots of changes happen at your age — how are you feeling in yourself?',
      );
    }

    return AgePromptResult(schoolYear: year, showTransitionBanner: false);
  }
}
