# Nova Body Atlas / Pain Map — Existing Code Audit

Audit date: 2026-05-18
Scope: Full repo search for body atlas, pain map, anatomy map, body location, and related UI/data code.

---

## EXISTING WORK FOUND

| File | Purpose | Status | Reusable | Notes |
|------|---------|--------|----------|-------|
| `lib/fab/screens/pain_screen.dart` | General pain log with body location chips, symptom chips, medication picker, pain slider, in-memory log | Orphaned — not imported anywhere | Yes — partial | Most valuable pre-existing file. Has 11 body part chips and 8 symptom type chips. No body SVG/map. No persistence. |
| `lib/fab/screens/sleep_screen.dart` | Sleep tracker with bedtime/wake pickers, quality rating, CustomPainter arc | Orphaned — not imported anywhere | Partial — `_SleepArcPainter` pattern useful | No relation to body atlas. Useful sleep arc painter for Sleep/Fatigue module only. |
| `lib/fab/screens/recovery_screen.dart` | Sobriety tracker (not physical recovery) | Orphaned — not imported anywhere | No | Hardcoded sobriety start date. Crisis line links. Not relevant to body atlas or physical pain. |
| `lib/fab/screens/nutrition_screen.dart` | Food/calorie tracker with calorie counts | Orphaned — not imported anywhere | No | Not relevant to body atlas. |
| `lib/fab/screens/fab_clinician_screen.dart` | Stub — "Clinician view coming soon" | Orphaned — not imported anywhere | No | Empty placeholder only. |
| `lib/fab/screens/fab_insights_screen.dart` | Stub — "Insights coming soon" | Orphaned — not imported anywhere | No | Empty placeholder only. |

**No body atlas, pain map, anatomy SVG, or interactive body diagram code exists anywhere in the repo.**

---

## EXISTING DATA MODELS

### From `lib/fab/screens/pain_screen.dart`

```dart
// Body location options (chips only — no coordinates, no SVG)
final List<String> _bodyParts = [
  'Head', 'Neck', 'Shoulders', 'Chest', 'Back',
  'Arms', 'Hands', 'Stomach', 'Hips', 'Legs', 'Feet',
];

// Symptom type options
final List<String> _symptomList = [
  'Throbbing', 'Burning', 'Sharp', 'Dull ache',
  'Tightness', 'Numbness', 'Tingling', 'Pressure',
];

// Medication list
final List<String?> _meds = [
  'None taken', 'Paracetamol', 'Ibuprofen', 'Codeine',
  'Tramadol', 'Morphine', 'Amitriptyline', 'Gabapentin', 'Other',
];

// In-memory log entry structure (not persisted)
_log.insert(0, {
  'time': DateTime.now(),
  'level': _painLevel,        // int 0–10
  'locations': List<String>.from(_locations),
  'symptoms': List<String>.from(_symptoms),
  'medication': _medication,
  'notes': _noteCtrl.text.trim(),
});
```

### From `lib/fab/models/profile_model.dart`

```dart
// CheckInModel — includes health fields relevant to pain/sleep modules
class CheckInModel {
  final int moodScore;
  final double sleepHours;
  final TimeOfDay? bedTime;
  final TimeOfDay? wakeTime;
  final int sleepQuality;   // 1–5
  final int wakeUps;
  final int focusScore;
  final int energyScore;
  // ... etc.
}

// SleepFactors — trigger/helper lists for sleep
class SleepFactors {
  final List<String> triggers;
  final List<String> helpers;
}
```

No body location coordinates, no pain intensity by region, no SVG path data.

---

## EXISTING UI / WIDGETS

### Pain location: chip list only (no body map)

`pain_screen.dart` renders body parts as `FilterChip` / `ChoiceChip` style tappable chips in a `Wrap`. There is no visual body diagram, no SVG, no `GestureDetector` on a body image. The chips are a flat list.

### Pain intensity: slider

`pain_screen.dart` has a slider (0–10) with `_painColor()` and `_painLabel()` helpers:

```dart
Color _painColor() {
  if (_painLevel <= 2) return const Color(0xFF4CAF50);  // green
  if (_painLevel <= 5) return const Color(0xFFFFC107);  // amber
  if (_painLevel <= 7) return const Color(0xFFFF9800);  // orange
  return const Color(0xFFF44336);                       // red
}

String _painLabel() {
  if (_painLevel == 0) return 'No pain';
  if (_painLevel <= 2) return 'Mild';
  if (_painLevel <= 5) return 'Moderate';
  if (_painLevel <= 7) return 'Severe';
  return 'Very severe';
}
```

These helpers are reusable as-is for the Back Pain module.

### Sleep arc painter (unrelated to body atlas)

`sleep_screen.dart` has `_SleepArcPainter extends CustomPainter` — draws an arc to visualise sleep duration. Unrelated to body maps but the CustomPainter pattern is established in this codebase.

### No interactive body diagram exists

There is no:
- SVG body outline
- `GestureDetector` mapped to body regions
- `CustomPainter` body shape
- Positioned touch-target anatomy
- Front/back body toggle
- Pain overlay on a body shape

---

## EXISTING ASSETS / DIAGRAMS

None found. No body SVG files, no anatomy images, no pain map assets of any kind exist in `assets/` or anywhere else in the repo.

---

## EXISTING NAVIGATION / ROUTES

`pain_screen.dart`, `recovery_screen.dart`, `sleep_screen.dart`, `nutrition_screen.dart` are all orphaned — no route, no import, no navigation to them exists.

The Nova Health module menu (`lib/nova_health_screen.dart`) routes to `NovaBackPainModuleScreen` for back pain. That is the correct entry point for any body-location-aware pain logging.

---

## WHAT SHOULD BE REUSED

| Item | Source | Where to reuse |
|------|--------|----------------|
| `_bodyParts` chip list | `pain_screen.dart` | Body location section in `NovaBackPainModuleScreen` — adapt to back-specific locations |
| `_symptomList` chip list | `pain_screen.dart` | Symptom type section in back pain / gastro modules |
| `_painColor()` / `_painLabel()` helpers | `pain_screen.dart` | Pain level display in `NovaBackPainModuleScreen` |
| In-memory log entry structure | `pain_screen.dart` | Pattern for future SharedPreferences-backed log |
| `_meds` list | `pain_screen.dart` | Medication picker in back pain and other modules |
| `CheckInModel` fields | `profile_model.dart` | Reference only — do not couple health modules to FAB profile model |

---

## WHAT SHOULD NOT BE DUPLICATED

| Item | Reason |
|------|--------|
| `recovery_screen.dart` sobriety logic | Not physical recovery. Do not reuse or re-expose. |
| `fab_clinician_screen.dart` stub | Replaced by `NovaEvidenceNotesScreen`. Do not add a second clinician route. |
| FAB theme colours (`FabColors`) | Nova Health uses its own dark theme. Do not mix themes. |
| Any API call, cloud sync, or account logic | None exists now — do not introduce any. |

---

## MISSING PIECES

The following do not exist and would need to be built for a Body Atlas / Pain Map feature:

1. **Body outline asset or CustomPainter** — no SVG or drawn body shape exists
2. **Interactive tap regions on a body diagram** — no GestureDetector-mapped anatomy
3. **Front / back body toggle** — not implemented anywhere
4. **Per-region pain intensity** — existing code logs one global pain level; no per-location intensity
5. **Pain history persistence** — existing log is in-memory only; no SharedPreferences or Hive write
6. **Body location data model** — no structured model for `{region, intensity, symptomTypes, timestamp}`
7. **Pain map visualisation** — no heatmap, colour overlay, or region-highlight rendering

---

## RECOMMENDED NEXT SAFE STEP

**Do not build an interactive body SVG map yet.**

The safest and most useful next step is to upgrade `NovaBackPainModuleScreen` to include:

1. A multi-select body location chip list (adapt `_bodyParts` from `pain_screen.dart` to back-specific regions: Upper back, Mid back, Lower back, Left side, Right side, Both sides, Radiating to leg, Neck/shoulders)
2. A symptom type chip list (from `pain_screen.dart`'s `_symptomList`)
3. A medication chip/picker (from `pain_screen.dart`'s `_meds`)
4. SharedPreferences persistence for at least the most recent entry

This adds real clinical value without requiring any SVG asset, body diagram, or touch-region mapping. A visual body map can follow once the data model and persistence layer are stable.

Only start building an interactive body diagram after:
- Persistent per-entry storage is working
- The data model for `{region, intensity, symptomTypes}` is stable
- A body outline asset (SVG or CustomPainter) has been designed and approved
