# Session: Commit 2 — Roster-Export Loop (Step 6.5)

**Date:** 2026-06-26
**Branch:** nova-fab
**Commit:** `0bc4caa`

---

## Done

- **Commit `0bc4caa`** — `_exportData()` now loops `FamilyAccount.current.children` instead of emitting an array-of-one derived from `SelectedChildService.current`. `children_data` carries one block per child keyed by `childId`. Restore writes `child_name`/`onboarding_complete` once **after** the loop from `restoredChildren.first` — deterministic active child = `children.first`, matching `selectDefault()` cold-reopen behaviour. `export_version` stays 2. **1 file, +62/−58.**

- **Proven on genuine two-child roster** (Giraffe `1781385897262` + Teds `1782464854385`): both appear in `family.children` and `children_data`; empty roster child still emits its full block skeleton. `pinHash` null on both — credentials excluded.

- **Temp debug button** (`kDebugMode` block in `parent_dashboard_screen.dart` → `FamilyDashboardScreen`) was added to reach the orphaned add-child FAB, used to add Teds, then removed before commit. Verified absent from `git diff --staged`.

---

## Key Gotchas This Session

- **The "two-child family" in storage was actually ONE registered child (Giraffe) + one orphaned data box.** The roster (`family_account` Hive box) had a single entry. The proof was unprovable until a real second child was added via the debug button.

- **Debug button shares the same file as the commit-2 edits.** Had to remove-then-stage and `diff-check --staged` to keep scaffolding out of the commit diff. The staged diff must be checked explicitly — `dart analyze` and working-tree diff are not enough.

- **Clean diff + green `dart analyze` was NOT proof** — the single-child roster was only caught by reading the actual export JSON. Integration testing matters here.

---

## Findings Backlogged (NOT Actioned)

**Multi-child nav unbuilt:**
- `FamilyDashboardScreen` (add-child FAB) is **orphaned** — never mounted, zero imports/nav in the live app.
- `SelectedChildService.select(child)` is **dead code** — never called anywhere in the codebase.
- Child selection is age-band-only via house tap zones (`selectForAgeMode`) and **breaks when two children share a band**: Giraffe (age 7) and Teds (age 8) both resolve to `AgeMode.middleYears` → both resolve to `children.first` = Giraffe. No identity-based switcher exists.
- This gates multi-child being user-reachable.

**Orphaned data box `child_1781385897201`** — no roster entry; `deleteChildBoxes()` was never called when `family_account` was cleared during development. Ties into the known `_clearAllData` asymmetry.

---

## Current State

- **nova-fab is 13 commits ahead of `origin/nova-fab`** — gate-lift redeploy not yet pushed.
- `git push` triggers Vercel deploy when ready.
- Only the build-cache `.dill` artifact should be unstaged.

---

## Next (Agreed Order)

1. **`_clearAllData` symmetric-wipe fix** — clear per-child SharedPrefs keys via `getKeys()` + prefix filter, not just Hive boxes. ICO right-to-erasure compliance.
2. **Step 7 star accumulators** — gated on product decision: siblings share one star balance or separate?
3. **Standing item: personal wellness action plan** (step 2 of the three-step sequence) — due once migration settles. Not optional.
