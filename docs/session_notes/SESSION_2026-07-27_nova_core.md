Nova Health clinical-integrity pass — four commits on nova-core.

Commits: e85078f (CheckInRepository: every `catch (_) {}` replaced with a
logged `catch (e, s)` via debugPrint; `saveEntry` now returns `Future<bool>`
instead of `Future<void>` so a caller can tell a write failed — no existing
caller checks the value, but the signal now exists), ab4ff7b (clinician
export PDF: the "Medication adherence" row is omitted entirely — from both
the PDF table and the on-screen stat chip — when `_medAdherence` is null,
instead of printing "Not recorded"; no screen can currently set
`medicationTaken` so this row always fired, and a blank-looking clinical PDF
row reads as "patient failed to log this," which isn't true), bd3645b
(`inject14DaySeedData()` moved out of CheckInRepository into a new top-level
function `seedDebugCheckInData()` in `lib/core/repositories/check_in_seed_data.dart`
— nothing that calls `_box.clear()` lives on the class that owns real user
data anymore; `AtlasScreen`'s `kDebugMode` guard is unchanged, just calls the
new function), 1b6c63d (`nova_evidence_notes_screen.dart` persists its 8 text
fields to SharedPreferences under `nova_evidence_notes`, one JSON blob,
following `HealthProfileScreen`'s `_prefsKey`/`_load()`/`_save()` shape —
autosave debounced 800ms off the existing `onChanged`, no save button, a
quiet fading "Saved" tag, `dispose()` cancels the debounce timer and flushes
a final save by building the JSON payload synchronously before the
controllers are torn down).

Five screens still collect data with no persistence at all: Back Pain,
Recovery, Sleep/Fatigue, Nutrition, Gastro. Each is a fully built form
(sliders, chips, text fields, live summary preview) that loses everything on
navigating away — no `CheckInRepository` or `SharedPreferences` call in any
of them.

Storage decision for closing that gap: Back Pain extends `CheckInEntry`
with nullable fields only (`mobilityScore`, `walkingTolerance`,
`sittingTolerance`, `standingTolerance`, `helped`, `safeNextStep`,
`flareNotes`, `medicationNotes`, `sleepNotes`, `gpNotes`, `evidenceNotes`) —
never rename or retype an existing key, since `CheckInEntry` is shared with
Fab and old Hive-stored JSON blobs must keep decoding under the same field
names and types. Sleep/Fatigue, Gastro, Nutrition, and Recovery get their
own separate models and boxes rather than piling more nullable columns onto
`CheckInEntry` — their categorical fields (`stoolNote`, `wokeInNight`,
`recoveryState`, meal-scoped shape, etc.) don't share meaning with a
back-pain check-in row, and Nutrition in particular breaks the "one entry
per day" cardinality `CheckInEntry` assumes.

Housekeeping, not done this session: `nova_evidence_notes_screen.dart`
currently sits in `lib/fab/` even though it's a Nova Health screen — it
should move to `lib/features/` to match where its siblings
(`health_profile`, `advice_hub`, `clinician_export`, etc.) already live.
Relocate it when Codex is between jobs.

Reference: production Vercel builds only ever build the Fab app —
`build_and_deploy.ps1` runs `flutter build web -t lib/main_fab.dart --release`.
`lib/main.dart` (the Nova Health / NovaHubScreen entry point covered above)
is not part of the deployed build target today.
