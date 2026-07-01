# Batch Diagnosis — 2026-06-28
**Branch:** nova-fab | **Status:** read-only investigation, no edits, no commits

---

## 1. Factory-Reset Bug — X vs Y

### All write sites for `family_account` → `"current"`

Every location in the codebase that calls `account.save()` or `box.put('current', ...)`:

| File:line | Trigger | Guard |
|-----------|---------|-------|
| `main_fab.dart:57` | Startup migration — bridges old ProfileService profile into a new FamilyAccount if roster is empty/null | `migrProfile != null && (current == null \|\| children.isEmpty)` |
| `onboarding_screen.dart:162` | `_finish()` — user completes the 4-page onboarding wizard ("Let's Go!") | User must tap through all 4 pages |
| `family_dashboard_screen.dart:687` | Update child profile in FamilyDashboard | Orphaned screen — unreachable in live nav |
| `family_dashboard_screen.dart:769` | Set/update parent password | Orphaned screen |
| `family_dashboard_screen.dart:925` | Clear parent password | Orphaned screen |
| `family_dashboard_screen.dart:1072` | Confirm add-child in FamilyDashboard | Orphaned screen |
| `fab_settings_screen.dart:104` | Remove parent PIN from settings | `if (account == null) return` |
| `child_lock_screen.dart:188` | Persist child lock PIN change | `if (account != null)` — guards against null |
| `parent_dashboard_screen.dart:1861` | Backup import/restore — writes restored roster | Import flow only |
| `parent_pin_gate.dart:423` | Set parent PIN | `if (account == null) return` |

### Does onboarding write before the user finishes?

**No.** `OnboardingScreen.initState()` (lines 70–78):

```dart
void initState() {
  super.initState();
  if (widget.editMode) _loadExistingProfile();  // only in edit mode
  if (widget.initialPage > 0) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageCtrl.jumpToPage(widget.initialPage);
    });
  }
}
```

`editMode = false` in the post-reset flow. `_loadExistingProfile()` is never called.
Navigation between pages (tapping "Start →", "Next →") only calls `_pageCtrl.animateToPage()`. No writes.

The ONLY write in onboarding is `_finish()` at line 162, which fires on page 4 ("Let's Go!"). A user on page 2 ("Let's get to know you") has not triggered it.

### Is `FabHomeScreen.initState()` a write path?

**No.** `FabHomeScreen.initState()` (lines 77–89):

```dart
void initState() {
  super.initState();
  _theme      = FabWorldTheme.fromCalendar();
  _audio      = FabWorldAudio();
  _initAudio();
  _loadMood();
  _loadStars();
  _loadCompanion();
  _glowCtrl = AnimationController(...);
}
```

`_loadMood()` reads SharedPreferences. `_loadStars()` reads FabStarsService. `_loadCompanion()` calls `CompanionService.load()` which is read-only. None write to `family_account`.

### Tracing the post-reset sequence

After `_clearAllData()` completes:
1. `family_account.clear()` → box empty in IndexedDB (in-memory map also cleared)
2. `FamilyAccount.init()` with fix → `raw = null` → `_cached = null` ✓
3. `_load()` → confirmed read-only (reads checkins, sleep, worries, notes, reward requests)
4. Snackbar: "Factory reset complete — relaunch to onboard fresh"
5. Widget stays on `ParentDashboardScreen`

On fresh page reload:
1. `ProfileService.init()` → `profiles` box empty → `_profile = null` (fresh static)
2. `FamilyAccount.init()` → `family_account` box empty → `_cached = null` ✓
3. Migration check: `migrProfile == null` → migration does NOT run
4. `prefs.getBool('onboarding_complete') = null` → `done = false` → `OnboardingScreen()`
5. `OnboardingScreen.initState()` → no writes
6. User taps "Start →" (page 1 → 2) → no writes

**At this point `family_account` should have 0 rows.** All paths traced.

### Verdict: Hypothesis Y — but it's not a bug

**Hypothesis X (reset recreates the row):** Not the cause. With the `else { _cached = null }` fix applied, `FamilyAccount.init()` on an empty box sets `_cached = null`. `_load()` is confirmed read-only. Nothing in the reset path writes back to the box.

**Hypothesis Y (onboarding writes after reset):** The surviving "current" row is written by `onboarding_screen.dart:162` when the user completes onboarding after the reset. This is CORRECT BEHAVIOR — a factory reset leaves the DB empty; completing onboarding correctly writes a fresh row representing the new child profile.

**The most likely explanation for the user's observation:** They checked DevTools AFTER completing onboarding (hitting "Let's Go!" on page 4), not while sitting on page 2 as believed. Alternatively, the DevTools IndexedDB panel was showing stale/cached data that hadn't been refreshed (Chrome DevTools requires manual refresh of the IndexedDB object store listing). In either case, the "surviving row" is not a bug.

**One genuine risk remains:** `Hive.box.clear()` writes to IndexedDB via an async transaction. If the user reloads the page very quickly (before the transaction commits), the clear might not have persisted. `deleteBoxFromDisk` would be more robust because it calls `indexedDB.deleteDatabase()` which is a more atomic operation.

### Recommended fix plan (not applied)

**Option A — minimal (current approach, confirmed correct):**
The `else { _cached = null }` fix in `FamilyAccount.init()` is sufficient. No further change needed. The surviving row is from onboarding completing normally.

**Option B — belt-and-suspenders (safer on web):**
Replace `clear()` + `FamilyAccount.init()` pair with `deleteBoxFromDisk` + `FamilyAccount.clearCache()`:

```
File: lib/fab/models/family_account.dart
Add after line 88:
  static void clearCache() => _cached = null;

File: lib/fab/screens/parent_dashboard_screen.dart
Replace lines 2025-2034:
  // OLD:
  if (Hive.isBoxOpen('family_account')) await Hive.box<Map>('family_account').clear();
  ...
  await FamilyAccount.init();

  // NEW:
  await Hive.deleteBoxFromDisk('family_account');
  FamilyAccount.clearCache();
```

`deleteBoxFromDisk` works on open or closed boxes; it closes the box and deletes the IndexedDB database. No `init()` call needed (and `init()` would crash since the box is now closed). `clearCache()` resets `_cached` without touching the box. Safe because `_load()` does not access `family_account`.

**Recommendation:** Option A (status quo) is fine if the observation is confirmed to be from stale DevTools or post-onboarding. Option B is a 2-line hardening that eliminates the flush-timing risk entirely and is worth doing before the next test cycle. **Not urgent.** Confirm DevTools was refreshed before escalating.

---

## 2. Factory Reset Completeness Audit

### Full data inventory vs `_clearAllData`

| Data category | Storage | Wiped? | Mechanism | Gap? |
|---------------|---------|--------|-----------|------|
| Per-child sleep entries | SharedPrefs `${childId}_sleep_entries` | ✓ Yes | `prefs.clear()` | — |
| Per-child energy entries | SharedPrefs `${childId}_energy_entries` | ✓ Yes | `prefs.clear()` | — |
| Per-child check-in mood | SharedPrefs `${childId}_checkin_mood_*` | ✓ Yes | `prefs.clear()` | — |
| Per-child check-in done | SharedPrefs `${childId}_checkin_done_*` | ✓ Yes | `prefs.clear()` | — |
| Per-child today's mood | SharedPrefs `${childId}_mood_today_*` | ✓ Yes | `prefs.clear()` | — |
| Child name / age / avatar | SharedPrefs `child_name`, `child_age`, `child_avatar`, `child_avatar_emoji` | ✓ Yes | `prefs.clear()` | — |
| Onboarding flags | SharedPrefs `onboarding_complete`, `onboarding_done` | ✓ Yes | `prefs.clear()` | — |
| Fab stars balance + flags | SharedPrefs `fab_stars`, `fab_stars_first_ever_done` | ✓ Yes | `prefs.clear()` | — |
| Stars date keys | SharedPrefs `fab_checkin_stars_*`, `fab_pain_stars_*` | ✓ Yes | `prefs.clear()` | — |
| Game: Brilliant Me | SharedPrefs `brilliant_good_*`, `brilliant_hard_*`, `brilliant_wish_*`, `brilliant_traits_*` | ✓ Yes | `prefs.clear()` | — |
| Game: DinoGarden | SharedPrefs `dino_egg_*`, `dino_golden_fossil`, `dino_energy_*` | ✓ Yes | `prefs.clear()` | — |
| Little Ones last obs | SharedPrefs `fab_lo_last_obs` | ✓ Yes | `prefs.clear()` | — |
| Transition banner seen | SharedPrefs `fab_transition_banner_y*` | ✓ Yes | `prefs.clear()` | — |
| Advice bookmarks | SharedPrefs `nova_advice_bookmarks` | ✓ Yes | `prefs.clear()` | — |
| PIN fail count + lockout | SharedPrefs `pin_fail_count`, `pin_lock_until` | ✓ Yes | `prefs.clear()` | — |
| Storage version marker | SharedPrefs `storage_version` | ✓ Yes | `prefs.clear()` (re-run on next startup, harmless) | — |
| Nutrition log | SharedPrefs `nutrition_*` | ✓ Yes | `prefs.clear()` | — |
| Check-in entries (Nova Core pain log) | Hive `checkins` | ✓ Yes | `.clear()` | — |
| Worry entries | Hive `worries` | ✓ Yes | `.clear()` | — |
| Parent notes | Hive `parent_notes` | ✓ Yes | `.clear()` | — |
| Mood entries | Hive `moods` | ✓ Yes | `.clear()` | — |
| Old ProfileService profile | Hive `profiles` | ✓ Yes | `.clear()` | — |
| Family roster + PIN hashes | Hive `family_account` | ⚠ Partial | `.clear()` (may not flush before reload) | Flush timing risk on web |
| Skeleton key audit log | Hive `audit_log` | ✓ Yes | `.clear()` | — |
| Notification settings | Hive `settings` (on-demand) | ✓ Yes | `deleteBoxFromDisk` | — |
| Child lock PIN | Hive `pin_prefs` (on-demand) | ✓ Yes | `deleteBoxFromDisk` | — |
| Walkthrough seen flags | Hive `walkthrough` (on-demand) | ✓ Yes | `deleteBoxFromDisk` | — |
| Per-child data boxes (roster children) | Hive `child_<id>` | ✓ Yes | `deleteChildBoxes` loop (Source A: roster) | — |
| Per-child journal boxes (roster children) | Hive `child_<id>_journal` | ✓ Yes | `deleteChildBoxes` loop (Source A: roster) | — |
| Per-child data boxes (SharedPrefs-derived orphans) | Hive `child_<id>` | ✓ Yes | `deleteChildBoxes` loop (Source B: regex scan) | — |
| **Truly orphaned child box (no SharedPrefs data)** | Hive `child_<id>` | **✗ No** | childId undiscoverable — not in roster, no SharedPrefs | Requires `indexedDB.databases()` or manual DevTools |

### Summary

`prefs.clear()` is comprehensive — covers all 20+ SharedPrefs key patterns across 10+ screens, including future keys automatically. Cleaner than any enumerated list.

`deleteChildBoxes` via two-source union (roster + regex scan) catches all practical orphans. The only unresolvable gap is a child whose Hive boxes exist but who wrote **zero** SharedPrefs data ever — effectively impossible after any real usage (every live child accumulates at least one `${id}_mood_today_*` or `${id}_checkin_done_*` key).

`family_account` flush timing is the only meaningful risk. See Option B in §1 for the `deleteBoxFromDisk` hardening.

---

## 3. Chicken Family Hide — Is It Clean and Reversible?

### The flag

```dart
// lib/fab/widgets/fab_world_scene.dart:12
const bool kShowFamilyCharacters = false;
```

Single constant, single file.

### What `kShowFamilyCharacters` gates

Ten `CharacterSprite` widgets in `fab_world_scene.dart:274–372` (Layer 8 of the scene stack):

| Line | Character | Asset path | Scene position |
|------|-----------|------------|---------------|
| 274 | Chicken Lips | `characters/chicken_lips.png` | Left house front door (0.29, 0.88) |
| 285 | Teds | `characters/teds.png` | Left house porch (0.345, 0.88) |
| 295 | Daughter 9 | `characters/daughter_9.png` | Flowerbed left (0.22, 0.90) |
| 305 | Daughter 7 | `characters/daughter_7.png` | Flowerbed left (0.16, 0.91) |
| 315 | Cat1 | `characters/cat1.png` | Left house porch beneath lantern (0.365, 0.73) |
| 325 | Cat2 | `characters/cat2.png` | On barrel, left side (0.105, 0.77) |
| 335 | Dad Giraffe | `characters/dad_giraffe.png` | Foot of left house steps (0.22, 0.88) |
| 345 | Son Giraffe 1 (Theo) | `characters/son_giraffe_1.png` | Right house (0.66, 0.91) |
| 355 | Son Giraffe 2 (Ollie) | `characters/son_giraffe_2.png` | Right house steps (0.76, 0.90) |
| 365 | Eddie (Jack Russell) | `characters/jack_russell.png` | Path in front of gate (0.50, 0.86) |

### What `kShowFamilyCharacters` does NOT gate

- **`ChickenLipsCompanion` widget** (`fab_home_screen.dart:568–573`) — shown when `_companionGreeting != null`, which always resolves. Chicken Lips companion is **always visible** in the bottom-left of the home scene. This is completely independent of the flag.
- **Chicken house tap zone** (`fab_home_screen.dart:739–752`) — always active. Tapping the chicken house navigates to `HouseInteriorScreen(HouseType.chicken)`. All 11 rooms inside are fully functional.
- **`FabCharactersPainter`** (`fab_characters_painter.dart`) — draws the full chicken family (Chicken Lips, daughters, Shih Tzu, cats in windows) and giraffe family as custom paint. BUT `FabCharactersWidget` (which hosts the painter) is **never instantiated anywhere** in the codebase. It is dead code — not wired into any screen or scene.
- **Character sprite assets** — all PNG files exist on disk at `assets/images/characters/`: `chicken_lips.png`, `teds.png`, `daughter_7.png`, `daughter_9.png`, `cat1.png`, `cat2.png`, `dad_giraffe.png`, `son_giraffe_1.png`, `son_giraffe_2.png`, `jack_russell.png`. Also `.png.bak` backups for all. `.jpg` versions also present (unused by the scene code, which references `.png`).
- **Waypoints** — `_chickenLipsWaypoints` (lines 28–49) always defined. They are passed as `waypoints:` to `CharacterSprite` when the flag is true; when false the waypoints sit idle with zero cost.

### Other things that touch the chicken family (always on)

- `fab_world_painter.dart:308` → `_drawChickenHome()` — the painted house building itself is always drawn. Not gated by flag.
- `fab_world_audio.dart:120` — `isLeftFamily` check covers `chicken_lips`, `daughter_9`, `daughter_7`, `teds`. Audio hooks exist but only fire if a character triggers an event — which won't happen with `kShowFamilyCharacters = false`.
- `house_interior_screen.dart:38` → `HouseType.chicken` — 11-room chicken house interior is always reachable and fully populated.
- `fab_brilliant_screen.dart:456, 582` — `chicken_lips.png` used as a static image asset in the Brilliant Me screen. Always on, not gated.
- `noughts_and_crosses.dart:237` — `ChickenLipsWidget` used in the noughts-and-crosses game panel. Always on.

### Is her return "one clean flip"?

**Largely yes, with one caveat.** Setting `kShowFamilyCharacters = true` would:

✓ **Restore:** All 10 character sprites appear in their scene positions (static idle, breathing animation via `CharacterSprite`). Assets are present. Waypoints are defined.

✓ **Safe:** No rot in the flag path — all 10 `CharacterSprite` blocks are identical in structure, correctly guarded.

⚠ **Caveat — walking system is parked:** `CharacterSprite` comment (lines 7–26) explicitly states the walking/path system is "parked, not wired in current build." Characters will appear as static animated sprites (idle breathe + shadow), not walking along waypoints. The walking system was stripped but preserved in git history. Flip the flag → characters appear but stand still.

⚠ **Caveat — interaction system not wired:** `FabInteractionSystem` import is commented out in `fab_world_scene.dart:6`. The full interaction system (tap → reaction, zones, movement) is not connected. Characters will not respond to taps as scene entities (though the `ChickenLipsCompanion` widget tap already works).

⚠ **Caveat — `FabCharactersPainter` is dead:** The custom-paint character system (`FabCharactersWidget`, `FabCharactersPainter`) is never instantiated and would not appear from this flip. It's a separate, more complex animated system. The flag restores the simpler `CharacterSprite` (asset-based) layer only.

**Verdict:** One flip is safe and adds visible character sprites to the scene. Walking, interaction, and the full painter-based animation system would require additional wiring beyond the flag. No rot to repair before flipping.

---

## 4. Mascot Role Handoff

### Current state

**Chicken Lips holds the mascot role firmly** and is NOT hidden by the flag.

Evidence:
- `ChickenLipsCompanion` at `fab_home_screen.dart:568–573` renders whenever `_companionGreeting != null`
- `CompanionService.load()` (called from `FabHomeScreen._loadCompanion()`) always returns a `CompanionGreeting` with a `ChickenMood` and text — there is no null path that skips the companion
- With `kShowFamilyCharacters = false`, there are no character sprites — but the companion widget appears in bottom-left of the home scene independently
- `CompanionService.load()` reads `FamilyAccount.current?.children.first` and `ProfileService.profile` to personalise greetings. No writes. The service is purely advisory.

### "Eddie" naming collision

The onboarding screen (`onboarding_screen.dart:247, 293-300`) shows a 🐔 emoji and says "Hi! I'm Eddie 👋". This names the chicken mascot "Eddie" in the child-facing copy.

Separately, in `fab_world_scene.dart:364–372`, `jack_russell.png` is labelled "Eddie (Jack Russell) — path in front of gate". This is a different entity — a dog character in the scene.

Two things called "Eddie": the chicken mascot (child-facing name) and the Jack Russell dog character (scene asset). These need disambiguating if both appear in the same copy or UI simultaneously.

### What flipping `kShowFamilyCharacters` back on does to the mascot

Nothing changes for the mascot role. The `ChickenLipsCompanion` widget is already live. When the flag flips, a `CharacterSprite` for `chicken_lips.png` also appears at scene position `(0.29, 0.88)` — a static sprite near the left house. This is a SECOND visual representation of Chicken Lips alongside the companion widget.

The companion and the sprite are independent:
- Companion (bottom-left): interactive, shows greeting bubble, tap-to-dismiss, driven by `CompanionService`
- Sprite (scene, left house): static animated idle, no tap interaction in current build

No slot is empty. No swap required. The flag affects scene decoration, not mascot identity.

---

## 5. Backlog Audit

### FamilyDashboardScreen — orphaned (confirmed)

```
Grep for 'FamilyDashboardScreen' outside its own file: 0 matches.
```

`FamilyDashboardScreen` (`lib/fab/screens/family_dashboard_screen.dart`) is never imported by any other file. It is **completely unreachable** in the live app. The add-child FAB, the child card taps, the password flow — all exist inside this screen but are dark.

**What wiring it in requires:**
1. Add import to some host screen (ParentDashboardScreen or a new family management screen)
2. Add a nav entry point (e.g., a "Manage family" card in ParentDashboard's kDebugMode block first, or a permanent "Family" section)
3. Implement `SelectedChildService.select(child)` in the card-tap handler so tapping a child card actually switches the active child (currently the tap handler inside FamilyDashboardScreen does not call `select()`)
4. Test that `_load()` on ParentDashboardScreen correctly refreshes after child switch (it reads from `SelectedChildService.current` implicitly via `_repo.getAllEntries()` which uses the selected child)

### `SelectedChildService.select()` — dead code (confirmed)

```
Grep for 'SelectedChildService.select(': 0 matches anywhere in lib/.
```

`select(ChildProfile child)` method exists at `lib/fab/services/selected_child_service.dart` but is never called. Active child selection is age-band-only:
- `selectForAgeMode(AgeMode.middleYears)` — chicken house tap (`fab_home_screen.dart:748`)
- `selectForAgeMode(AgeMode.earlyYears)` — giraffe house tap (`fab_home_screen.dart:764`)
- `selectDefault()` — fallback to `children.first`

**Multi-child age-band collision:** Giraffe (age 7) and Teds (age 8) both return `AgeMode.middleYears` → both resolve to `children.first = Giraffe`. A second child in the same age band can never be selected by house tap. `select()` must be wired before identity-based switching works.

### Orphaned child Hive box

`child_1781385897201` / `child_1781385897201_journal` — the box created by the development-session orphaning event (family_account cleared in DevTools without calling `deleteChildBoxes`).

Status post-factory-reset: **cannot confirm from static analysis whether it still exists.** If that child wrote any SharedPrefs key (any `1781385897201_*` key), the two-source scan in `_clearAllData` would have caught it and called `deleteChildBoxes(1781385897201)`. If it had zero SharedPrefs data, the box may still exist as an IndexedDB database. Needs DevTools check to confirm.

### `FabCharactersWidget` — dead widget

`FabCharactersWidget` and `FabCharactersPainter` are defined in `lib/fab/widgets/fab_characters_painter.dart`. `FabCharactersWidget` is the `StatefulWidget` that hosts the painter (line 16). The only reference to `FabCharactersPainter` is inside `FabCharactersWidget.build()` (line 192) — a self-reference. No other file imports or instantiates `FabCharactersWidget`.

This is the full custom-paint animated character system (Chicken Lips with walk cycle, daughters, Shih Tzu, cats in windows, giraffe family). It exists and is well-built but is entirely disconnected from the live scene.

### `WalkthroughOverlay` — implemented but never called

`WalkthroughOverlay.showIfNeeded()` is defined at `lib/fab/widgets/walkthrough_overlay.dart:52`. The usage examples at lines 13–14 are comments:
```dart
//   await WalkthroughOverlay.showIfNeeded(context, WalkthroughType.child, steps);
//   await WalkthroughOverlay.showIfNeeded(context, WalkthroughType.parent, steps);
```

No call sites exist anywhere in the live codebase. The walkthrough is fully built but never triggered. The Hive box `walkthrough` is opened on-demand (when the overlay runs) and deleted by `_clearAllData`. Since the overlay never runs, the box is never created, so `deleteBoxFromDisk('walkthrough')` is a no-op on every reset currently.

### `FabInteractionSystem` + `LivingWorldCharacter` — commented-out imports

Both are imported only via commented-out lines in `fab_world_scene.dart:5-7`:
```dart
// import 'living_world_character.dart';
// import 'fab_interaction_system.dart';
// import 'fab_world_theme.dart'; // restored with character system
```

These exist on disk (`lib/fab/widgets/fab_interaction_system.dart`, `lib/fab/widgets/living_world_character.dart`) but have zero active callers. Part of the full character-walking system preserved for later.

### Other dead features / unwired

- `ChickenMood` enum defined TWICE: `fab_characters_painter.dart:11` (4 moods: happy/grumpy/sleepy/excited) and `chicken_lips_widget.dart:17` (7 moods: happy/sad/worried/proud/crowned/sleeping/wink). These are separate types, incompatible, used in different contexts. Not a bug but a naming clash.
- `FabWorldAudio.onCharacterEvent()` at `fab_world_audio.dart:237` has a handler for `'chicken_lips'` but the character event emission at `fab_world_scene.dart:180` is commented out. Audio hook is ready but wired to dead code.

---

## 6. Next Session Priority Plan

Ordered by dependencies and risk. Each item marked **[needs localhost proof]** if it requires visual/app verification, or **[safe/mechanical]** if it's a pure code change verifiable by `dart analyze` alone.

---

### Priority 1 — Factory reset hardening (Option B) **[safe/mechanical]**

Two files, four lines. Change `family_account` from `.clear()` to `deleteBoxFromDisk` and replace `FamilyAccount.init()` with `FamilyAccount.clearCache()`.

```
lib/fab/models/family_account.dart
  Add: static void clearCache() => _cached = null;

lib/fab/screens/parent_dashboard_screen.dart
  Replace: if (Hive.isBoxOpen('family_account')) await Hive.box<Map>('family_account').clear();
  With:    await Hive.deleteBoxFromDisk('family_account');
  Replace: await FamilyAccount.init();
  With:    FamilyAccount.clearCache();
```

Eliminates flush-timing risk. After apply: run `dart analyze`, then manually verify reset in-browser (DevTools IndexedDB: refresh the panel, confirm `family_account` database shows 0 rows immediately after reset, before page reload).

**Pre-requisite:** Confirm whether the DevTools stale-panel was the actual cause (see §1). If stale panel explains everything, Option A (status quo) is fine and this can be deprioritised.

---

### Priority 2 — Commit the `FamilyAccount.init()` else-null fix **[safe/mechanical]**

The `else { _cached = null }` fix is applied but uncommitted. Stage + commit it:

```
lib/fab/models/family_account.dart  (+2 lines)
lib/fab/screens/parent_dashboard_screen.dart  (+33/-13 lines, factory reset rewrite)
```

Commit message: `fix(factory-reset): init() resets _cached on empty box; full wipe via deleteBoxFromDisk`

---

### Priority 3 — Verify orphaned box `child_1781385897201` is gone **[needs localhost proof]**

Open browser DevTools → Application → IndexedDB. Check whether `child_1781385897201` and `child_1781385897201_journal` databases still exist. If present: confirm they were NOT caught by the SharedPrefs scan (child had no `1781385897201_*` prefs data), and either:
- (a) Accept as a known residual orphan (no clinical data, dev artefact), or
- (b) Add `indexedDB.databases()` enumeration via `dart:js_interop` to sweep all `child_*` databases regardless of SharedPrefs coverage

Difficulty of (b): moderate — requires JS interop, web-only, debug-mode only. Not high priority given the box has no real data.

---

### Priority 4 — `kShowFamilyCharacters` flip decision **[needs localhost proof]**

When character sprites are ready to show:
1. Change `kShowFamilyCharacters = true` in `fab_world_scene.dart:12`
2. Run `dart analyze`
3. Build and test on localhost — verify 10 character sprites appear in correct positions
4. Verify `ChickenLipsCompanion` continues to show in bottom-left (should be unaffected)
5. Verify chicken house tap zone still navigates correctly
6. Verify no z-order conflicts between sprite layer (Layer 8) and tap zones (stable Stack above AnimatedBuilder)

The tap zones in `fab_home_screen.dart` are in a stable `Stack` OUTSIDE the `AnimatedBuilder`. This is the correct pattern from the CanvasKit constraints. Character sprites are inside the `AnimatedBuilder` layer. Z-order: sprites below tap zones → taps on house will still register on the transparent `Container` overlays. Should be fine, but verify on mobile viewport.

---

### Priority 5 — Multi-child nav wiring (larger scope) **[needs localhost proof]**

This is the backlogged work from session notes `2026-06-26`. Three parts, all interdependent:

**5a. Wire `FamilyDashboardScreen` into live nav** `[safe/mechanical]`
Add import + a "Manage family" card to `ParentDashboardScreen` (inside `kDebugMode` block first for testing):
```dart
import 'family_dashboard_screen.dart';
// In kDebugMode block:
_buildNavCard('Manage family', Icons.group, () => Navigator.push(
  context, MaterialPageRoute(builder: (_) => const FamilyDashboardScreen()))),
```

**5b. Implement child switching** `[needs localhost proof]`
In `FamilyDashboardScreen` child card tap handler: call `SelectedChildService.select(child)`. Then add a "Switch to this child" action. Verify that `FabHomeScreen._loadMood()` and `ParentDashboardScreen._load()` both use `SelectedChildService.current` correctly after switch.

**5c. Age-band collision resolution** `[needs localhost proof]`
When two children share an age band (both middleYears or both earlyYears), house taps resolve to `children.first` always. Fix requires either identity-based house assignment (assign each house to a specific child), or a child-switcher overlay on the house tap that shows a picker when multiple children match the band. Product decision needed before code.

**Dependency note:** 5b and 5c are blocked until 5a is in place for testing.

---

### Priority 6 — Step 7 star accumulators (product decision first) **[safe/mechanical once decided]**

Gated on: siblings share one star balance, or separate per-child balances?

`FabStarsService` currently uses global keys (`fab_stars`, `fab_stars_first_ever_done`). Per-child would need `${childId}_fab_stars` etc. Decision drives implementation scope. Once decided, straightforward key migration — same pattern as the existing per-child SharedPrefs migration already in `main_fab.dart`.

---

### Standing / not time-gated

- **Personal wellness action plan** (step 2 of three-step sequence) — due once migration settles. Not optional per prior session agreement.
- **Push nova-fab to origin** — branch is 15+ commits ahead of `origin/nova-fab`. Vercel deploy blocked until push. Run `git push` when ready for live testing.
- **WalkthroughOverlay** — fully built, never called. Low priority to wire unless walkthrough becomes a product requirement.
- **`FabCharactersWidget` / `FabCharactersPainter`** — clean up or wire. If the `CharacterSprite` approach (PNG assets) is the chosen path, the painter-based system can be deleted. If painter is preferred, the `CharacterSprite` approach can be cut. Dead code risk grows if neither is decided.

---

## Backlog: Multi-child nav + identity switcher

Multi-child works at the data layer (roster export/import, per-child storage) but is NOT user-reachable. To make it usable, ONE coherent feature is needed:

Wire FamilyDashboardScreen into nav (currently orphaned — the add-child FAB exists but is unmounted).
Build an identity-based child switcher. FOUNDATION ALREADY EXISTS: SelectedChildService.select(child) is written but never called — it is the correct identity-switch method, deliberately KEPT (not deleted) as the starting point. Current selection is age-band-only (selectForAgeMode) which breaks when two children share a band (e.g. Giraffe 7 / Teds 8 both middleYears → both resolve to children.first).

Do NOT delete select() — it is scaffolding for this feature, not dead clutter.

**Intentionally retained parked code — do not delete:** `living_world_character.dart` (old walking-character widget, held during active character work), `fab_interaction_system.dart` (interactive scene foundation), `family_dashboard_screen.dart` (multi-child nav, see above), `walkthrough_overlay.dart` (onboarding system, fully built, awaiting wiring decision).
