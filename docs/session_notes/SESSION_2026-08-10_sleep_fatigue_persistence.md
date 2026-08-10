Sleep/Fatigue persistence — closes one of the four gaps flagged in
SESSION_2026-07-27_nova_core.md (Recovery, Sleep/Fatigue, Nutrition, Gastro
all had zero persistence). Recovery, Nutrition, and Gastro are still open.

Followed the Back Pain pattern exactly, per the storage decision reaffirmed
in the 27 Jul note: own model, own box, not piled onto CheckInEntry.

- New `lib/core/models/sleep_fatigue_entry.dart` — SleepFatigueEntry,
  mirrors CheckInEntry's shape (id, date, toJson/fromJson/copyWith,
  id-based equality).
- New `lib/core/repositories/sleep_fatigue_repository.dart` —
  SleepFatigueRepository, box name `sleep_fatigue`, same
  try/catch+debugPrint+bool-return shape as CheckInRepository.
- `lib/main_fab.dart` — registers `Hive.openBox<Map>('sleep_fatigue')`
  alongside the other module boxes.
- `lib/fab/screens/nova_sleep_fatigue_module_screen.dart` — wired to the
  repository: deterministic id `sleepfatigue_YYYY-MM-DD` (overwrite-same-day,
  same as Back Pain), `initState` loads today's existing entry if present,
  save button + snackbar added (screen previously had no save affordance at
  all — Summary Preview was display-only).

Not touched: Recovery, Nutrition, Gastro screens — same gap, same fix
shape, deliberately done one screen at a time per session as a reviewable
diff rather than as one large multi-file change.

Not verified: no Dart/Flutter toolchain available in the environment this
was written in. Checked by hand — brace/paren balance, field-name parity
between the model and the screen's state variables, and box name collision
against the rest of the codebase. Run `flutter analyze` and exercise the
screen (enter a value, navigate away, come back, confirm it reloads) before
treating this as done.
