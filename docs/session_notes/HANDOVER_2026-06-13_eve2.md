# Session Handover — 2026-06-13 Evening (Session 2)

## Done this session — per-child / SENCO chain working end-to-end

**Committed `8dbd5a3`:** SENCO report repointed to per-child Hive; full profile→persistence→clinical-report chain working, proven live.

Real root cause was NOT the assumed "Hive persistence wall." It was stale SharedPreferences data with mismatched types: old code wrote `child_avatar` as a String, current code reads it as int (`getInt`) — the throw aborted profile load → `ProfileService.profile` NULL → no `ChildProfile` → MoodScreen blocked.

**Fixes:**
- `SelectedChildService` singleton (mirrors `FamilyAccount`/`ProfileService`)
- MoodScreen migrated to per-child Hive (`${child.id}_${date}` in `moods` box), per-child isolation confirmed
- Onboarding `_finish()` creates `ChildProfile` in `FamilyAccount` + one-time migration (deterministic Jan-1 DOB from age, edit-mode updates not duplicates)
- `child_avatar` → `child_avatar_emoji` rename (Settings screen)
- SENCO repointed to per-child Hive with `_childName` from `ChildProfile`
- 1–5 → 0–4 scale conversion confirmed deliberate and correct

**Proven live:** onboarded "Giraffe" age 7 → profile resolves → mood persists → SENCO School Wellbeing Report generates with real name, 1 entry, avg 3.0 (Good correct on 0–4), distribution + School Pattern reading correctly.

---

## BLOCKER before deploy

Fix proven on freshly-wiped storage only. Existing testers still have the polluted `child_avatar` key. **Code does NOT self-heal dirty storage.** Existing testers who previously saved an avatar via old Settings will crash on Settings → Edit Profile (`getInt` on a String-typed value); the bad key persists because the crash is in `_loadExistingProfile()` before `_finish()` can overwrite it. App startup / home / mood are unaffected.

**Fix required before deploy:** one-time startup cleanup — detect legacy `child_avatar`, if String then delete or migrate to `child_avatar_emoji`. Small change. Deploy only after.

---

## Priority next session

1. **Deploy-safety fix** → one-time startup cleanup for legacy `child_avatar` key → then deploy `8dbd5a3`
2. **PIN gate verification** — flashed then bypassed after wipe; confirm no-PIN-expected vs render race vs real bypass (child-safety critical)
3. **Sleep/energy/worry persistence** — copy the Mood pattern (Hive, per-child)

---

## Backlog captured

- **Onboarding visual/layout pass:** proper Miss Chicken Lips mascot on welcome page (purple outfit/stethoscope/crown, not emoji); oversized/clipped condition cards (shrink so all 6 fit); modernise styling to scenery aesthetic
- **Onboarding DOB:** captures age but only deterministic DOB — fine for age-band; collect real DOB if ever needed clinically
- **Parent Dashboard:** shows pain/nerve fields (Nova Health adult metrics?) on child dashboard — confirm shared component / hide for child app
- **`ambient_summer.mp3` 404** — sound work now unblocked since Hive's in
- **Orphaned legacy `child_avatar` key** in storage (tied to deploy-safety question above)

---

## Lessons reinforced

- Bug rarely where the last handover assumed — recon before building on assumptions
- "Compiles clean" ≠ "works" — prove with real data + console
- Fix proven on clean slate ≠ proven for existing users (deploy gate)
- SharedPreferences: read-type and write-type must agree per key
- Clear site data (DevTools → Application → Storage) clears IndexedDB too — where Flutter web keeps prefs
- PowerShell: multiple `-m` flags, never heredocs
