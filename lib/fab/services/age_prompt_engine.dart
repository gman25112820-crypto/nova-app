// ─────────────────────────────────────────────────────────────
// AgePromptEngine
//
// Derives age-aware prompts and transition state from a child's
// age. Two entry points:
//
//   evaluateByMonths(int months) — for 0–59 months (Little Ones).
//     All prompts are parent-facing; isParentOnly == true.
//     0–11 months  : observation nudges (new sounds/reactions)
//     12–23 months : communication milestones (pointing, showing)
//     24–35 months : social/sensory responses
//     36–59 months : pre-school transition ("new people")
//
//   evaluate(int age) — for age 5+ (Growing Up / Finding Me).
//     UK school year approximated as year ≈ age − 4.
//     Year 5-6 : gentle secondary-prep prompts
//     Year 7   : new-school active prompts
//     Year 8-9 : hormone/mood shift awareness
// ─────────────────────────────────────────────────────────────

class AgePromptResult {
  final int schoolYear;
  final bool showTransitionBanner;

  /// True when the prompt is for the parent, not the child.
  /// Always true for evaluateByMonths (Little Ones).
  final bool isParentOnly;

  final String? bannerMessage;
  final String? checkInPrompt;

  const AgePromptResult({
    required this.schoolYear,
    required this.showTransitionBanner,
    this.isParentOnly = false,
    this.bannerMessage,
    this.checkInPrompt,
  });
}

class AgePromptEngine {
  AgePromptEngine._();

  // ── Little Ones (0–4): parent-facing prompts ─────────────────

  /// Evaluate prompts for a child whose age is known in months.
  /// Use this for children under 5; prompts go to the parent only.
  static AgePromptResult evaluateByMonths(int months) {
    // ── 0–11 months: sensory/sound observation nudges ─────────
    if (months < 12) {
      return const AgePromptResult(
        schoolYear: 0,
        showTransitionBanner: false,
        isParentOnly: true,
        checkInPrompt:
            'Have you noticed any new sounds or reactions today?',
      );
    }
    // ── 12–23 months: communication milestones ────────────────
    if (months < 24) {
      return const AgePromptResult(
        schoolYear: 0,
        showTransitionBanner: false,
        isParentOnly: true,
        checkInPrompt: 'Did they point at anything new today?',
      );
    }
    // ── 24–35 months: social responses & sensory reactions ────
    if (months < 36) {
      return const AgePromptResult(
        schoolYear: 0,
        showTransitionBanner: false,
        isParentOnly: true,
        checkInPrompt:
            'Have they been calm or overwhelmed in new spaces today?',
      );
    }
    // ── 36–59 months: approaching school start ────────────────
    return const AgePromptResult(
      schoolYear: 0,
      showTransitionBanner: false,
      isParentOnly: true,
      checkInPrompt:
          'Big year coming — how are they finding new people?',
    );
  }

  // ── Growing Up / Finding Me (5+): child-facing prompts ───────

  /// UK school year approximation from age in years.
  static int schoolYearFromAge(int age) => (age - 4).clamp(0, 13);

  /// Evaluate transition state and prompts for a child aged [age] years.
  /// For under-5 use [evaluateByMonths] instead.
  static AgePromptResult evaluate(int age) {
    final year = schoolYearFromAge(age);

    // ── Year 5-6 (age 9-11): gentle secondary prep ───────────
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
        checkInPrompt:
            'How\'s the new school going? What\'s the best bit so far?',
      );
    }

    // ── Year 8-9 (age 12-14): mood shift awareness ───────────
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
