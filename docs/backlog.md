# Fabulously Me — Tracked Backlog

Items here are confirmed, scoped, and waiting for a dedicated session.
Do not action inline — each needs its own test plan.

---

## NEXT SESSION — Portrait layout (option b)

Scene scales to width, content stacks below in portrait. Option (a) tint fix already
shipped (`0xFF0D0820` background). Option (b) is the real fix.

**Approach:**
- In `fab_world_scene.dart`: replace `Center + AspectRatio(16/9)` with `SizedBox.expand()`
  so the scene fills whatever space it's given
- Painters use fraction-based coordinates — should scale; expect sky/ground proportions
  to need Y-fraction tuning at portrait ratio
- Tap zones in `_buildWorldScene` use `h * 0.78` for ground line — will track the new
  scene height automatically once AspectRatio is removed
- Visual-test all three layouts before redeploy: portrait mobile, landscape mobile, desktop

**Test before closing:**
- Portrait phone: scene fills width, tap zones land on visual targets, panel opens/closes
- Landscape phone: layout unchanged from current (confirmed OK)
- Desktop wide: layout unchanged from current (confirmed OK)

**Do not deploy until all three pass.**

---

## BLOCKER — SENCO PDF report reads stale SharedPreferences mood data

**File:** `lib/fab/screens/senco_report_screen.dart`

**Problem:** Still reads moods from the old global SharedPreferences key `mood_entries`
(constant `_kPrefsKey`). MoodScreen has been migrated to per-child Hive storage.
Until SENCO is repointed, the clinical PDF export generates blank/zero-entry reports
with no error message visible to the parent or clinician.

**Fix required:**
- Replace `prefs.getStringList(_kPrefsKey)` with a Hive read using
  `Hive.box<Map>('moods')`, filtering keys by `'${child.id}_'` prefix
- Replace `prefs.getString('child_name')` with `SelectedChildService.current?.name`
  (with `selectDefault()` fallback, same pattern as MoodScreen)
- Remove `_kPrefsKey` constant and `SharedPreferences` import once done
- Note: `_MoodEntry` in senco_report_screen.dart is a local duplicate of `MoodEntry`
  in mood_screen.dart — consider consolidating into a shared model at the same time

**Test before closing:**
- Log ≥7 mood entries as a real child across multiple days
- Open SENCO report → confirm entries appear, PDF generates with correct name and data
- Open as a second child → confirm their data is isolated

**Risk if shipped without fix:** Parents and clinicians see an empty report.
No error shown — silent failure in the most clinician-facing feature in the app.

---

## NOTE — Migrated/onboarded DOB is approximate

Onboarding collects age (integer), not date of birth. The migration in `main_fab.dart`
and the `_finish()` onboarding path both derive DOB as **Jan 1 of the inferred birth
year** (`DateTime(now.year - age, 1, 1)`). This is a known, deterministic approximation.

Fine for all current uses (age-band routing in `AgeMode`, house selection, `ChildProfile.age`
computed property). If exact DOB is ever needed — clinically, for a birthday feature, or
for precise age-band transitions — **onboarding must be updated to collect a real DOB
directly**. The approximation should not be patched after the fact; it must come from
the source.
