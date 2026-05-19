# Nova Body Atlas / Pain Map — Repository History Check

Check date: 2026-05-19
Scope: Full git history across all branches, all 54 commits.
Method: Read-only. No code changes made.

---

## Branches checked

| Branch | Status |
|--------|--------|
| `nova-fab` | Current working branch |
| `main` | Exists locally and remotely |
| `remotes/origin/nova-fab` | Remote tracking |
| `remotes/origin/main` | Remote tracking |

**`restore/pain-management` does not exist.** There is no stash, tag, or ref by that name anywhere in this repository. Total branches: 2 local, 2 remote tracking.

---

## Files found in current branch (nova-fab)

### Relevant to pain / body location

| File | What it contains | Status |
|------|-----------------|--------|
| `lib/fab/screens/pain_screen.dart` | Pain level slider, 11 body-part chips, 8 symptom chips, medication picker, in-memory log | Orphaned — not imported or routed |
| `lib/fab/screens/nova_back_pain_module_screen.dart` | Full interactive back pain daily log — sliders, triggers, medication, sleep, evidence notes, summary | Live — routed from `NovaHealthScreen` |
| `lib/fab/screens/nova_evidence_notes_screen.dart` | 8-field appointment/evidence notes screen, selectable summary | Live — routed from `NovaHealthScreen` |
| `lib/fab/screens/fab_clinician_screen.dart` | Stub: "Clinician view coming soon" | Orphaned |

### No body atlas / anatomy / diagram code found anywhere in current branch

No files matching: `BodyAtlas`, `body_atlas`, `BodyMap`, `body_map`, `BodyDiagram`, `body_diagram`, `SpinePainter`, `disc`, `nervous system`, `sciatica painter`, `hit_test`, anatomy coordinates, SVG body outline, front/back toggle, or tap-region mapping.

The word "sciatica" appears only as a symptom label string in `nova_back_pain_module_screen.dart` (line 52) — not as a diagram element.

---

## Files found in git history (not in current branch)

### `docs/nova_app_v2_main.dart` — stored in commit `b15ea18` as a diff applied to `lib/main.dart`

This is an early (v2) pain score tracker. 397 lines. Contains:

- `SharedPreferences`-backed pain score list (up to 30 entries)
- `fl_chart` `LineChart` for pain trend visualisation
- `_loadScores()`, `_saveScores()`, `_clearAll()` methods
- Statistics: latest score, average, trend delta
- Recent entries list (last 8)
- `google_fonts` (DM Sans) and `dart:math` imports

**This is NOT a body atlas.** It is a simple numeric pain score tracker — one global score per entry, no body locations, no anatomy, no CustomPainter body diagram. It is the early Nova Pain Tracker MVP.

This file lives in `docs/nova_app_v2_main.dart` in history (the commit applied it as a patch to `lib/main.dart`). The current `lib/main.dart` is unrelated (standard Flutter counter demo entry — 21 lines, immediately replaced by `main_fab.dart`).

### `lib/fab/screens/pain_screen.dart` — added in commit `9a4d77e`

Already documented in the previous audit. Most relevant pre-existing pain screen.

### `lib/fab/screens/sleep_screen.dart` — added in commit `dc2a88a`

Already documented. Sleep tracker with `_SleepArcPainter`. Orphaned.

### `lib/fab/widgets/fab_characters_painter.dart` / `fab_world_painter.dart`

CustomPainter files — Fabulously Me world scene rendering. Not related to body atlas or pain map. Do not extract or modify.

---

## No matching files found anywhere in history

The following patterns returned **zero results** across all 54 commits:

- `check_in_repository` / `CheckInRepository`
- `check_in_entry` / `CheckInEntry`
- `export_service` / `ExportService`
- `body_diagram_painter` / `BodyDiagramPainter`
- `SpinePainter` / `DiscPainter`
- `hit_test` (in a body map context)
- `lib/core/` (directory never existed)
- `lib/features/` (directory never existed)
- `lib/health/` (directory never existed)
- HTML export engine
- CSV export engine
- JSON serialization on a health entry model

---

## Summary of what exists vs what was described

| Claimed to exist | Actually found |
|-----------------|----------------|
| `restore/pain-management` branch | Does not exist — never existed in this repo |
| 1425-line monolith | Does not exist. Largest pain-related file is `pain_screen.dart` (~250 lines, orphaned) |
| `body_diagram_painter.dart` with spine/disc rendering | Does not exist anywhere in history |
| `check_in_entry.dart` with JSON serialization | Does not exist anywhere in history |
| `check_in_repository.dart` with SharedPreferences CRUD | Does not exist anywhere in history |
| `export_service.dart` with HTML/CSV engine | Does not exist anywhere in history |
| `lib/core/` directory | Never existed |
| `lib/features/atlas/` directory | Never existed |

---

## Likely reusable files (confirmed existing)

| File | What to reuse |
|------|--------------|
| `lib/fab/screens/pain_screen.dart` | `_bodyParts` chip list, `_symptomList`, `_meds` list, `_painColor()` / `_painLabel()` helpers, in-memory log entry structure |
| `lib/fab/screens/nova_back_pain_module_screen.dart` | Already live — full interactive module with sliders, chips, notes, and summary. Extend this rather than replace it. |
| `docs/nova_app_v2_main.dart` (recoverable from `b15ea18`) | SharedPreferences score list pattern, `_loadScores`/`_saveScores` pattern. Useful as a persistence reference only. |
| `lib/fab/models/profile_model.dart` | `CheckInModel` and `SleepFactors` field patterns — reference only, do not couple to Nova Health modules |

---

## Missing pieces (confirmed not in repo)

1. Body location data model with persistence (`{region, intensity, symptomTypes, timestamp}`)
2. SharedPreferences CRUD layer for health entries
3. Interactive body diagram (SVG or CustomPainter with tap regions)
4. Front / back body toggle
5. Per-region pain intensity (current code has one global pain level only)
6. HTML or CSV export engine
7. `lib/core/` and `lib/features/` directory structure

---

## Recommendation

**Rebuild cleanly. There is no recoverable monolith.**

The repository contains no prior body atlas implementation to recover. The described `restore/pain-management` branch, 1425-line monolith, and four target extraction files (`check_in_entry.dart`, `check_in_repository.dart`, `export_service.dart`, `body_diagram_painter.dart`) do not exist in this repo's history. They cannot be extracted because they were never committed here.

The correct path forward:

1. **Extend `NovaBackPainModuleScreen`** with body-location chip list and symptom type chips from `pain_screen.dart` (safe, additive, no new files needed)
2. **Add SharedPreferences persistence** for back pain entries (new work, small scope, well-established pattern in this codebase)
3. **Build a body diagram** only after the data model and persistence are stable, and only after an asset or CustomPainter design has been agreed
4. **Build a `CheckInEntry` model and repository** as new work in a new `lib/core/` directory — treat as Queue 3 new build, not recovery

If an external backup of the described monolith exists (zip, separate machine, different repo), provide access to it and extraction can proceed from that source.
