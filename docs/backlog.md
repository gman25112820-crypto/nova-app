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

## RESOLVED — SENCO PDF report Hive migration

Fixed in `8dbd5a3` (13 Jun): `senco_report_screen.dart` reads `Hive.box<Map>('moods')`
filtered by `'${child.id}_'`, matching `mood_screen.dart`'s write path. Confirmed by
re-reading both files directly -- no `SharedPreferences` reference remains in either.
This entry was left in the backlog after the fix shipped; removed 10 Aug.

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
