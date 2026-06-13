# Fabulously Me — Tracked Backlog

Items here are confirmed, scoped, and waiting for a dedicated session.
Do not action inline — each needs its own test plan.

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
