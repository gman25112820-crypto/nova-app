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

(Update below: Back Pain has since been wired up — see the second set of
commits. Four screens still collect data with no persistence at all:
Recovery, Sleep/Fatigue, Nutrition, Gastro. Each is a fully built form
(sliders, chips, text fields, live summary preview) that loses everything on
navigating away — no `CheckInRepository` or `SharedPreferences` call in any
of them.)

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

---

Update, same day: four more commits closing the Back Pain gap. d402571
(`CheckInEntry` extended with the 11 nullable Back Pain fields decided above
— `mobilityScore`, `walkingTolerance`, `sittingTolerance`,
`standingTolerance`, `helped`, `safeNextStep`, `flareNotes`,
`medicationNotes`, `sleepNotes`, `gpNotes`, `evidenceNotes` — following the
`focusScore`/`hyperactivityScore` convention exactly; no existing key
renamed or retyped, no call site touched), e4e10fd (Back Pain screen now
persists: a "Save today's entry" button builds a `CheckInEntry` from form
state and calls `saveEntry`, which returns `bool` — the snackbar only claims
success when the write actually succeeded), 414f82a (clinician export PDF
gets a new section 6, "Functional Impact & Daily Living," covering all 11
fields — functional-score averages, "what helped" and "safe next step"
frequency tables, five small per-field notes tables — everything gated so
the whole section, and each sub-block within it, omits rather than prints
"Not recorded" when empty; sections 6–9 renumbered to 7–10), fdcf070 (wording
fix, no field/value/model change: "Mobility impact" and
"Walking/Sitting/Standing tolerance" read in opposite directions from each
other — tolerance implied higher-is-better while everything else in the app
is higher-is-worse. Relabelled all four to limitation framing ("Mobility
limitation", "Walking limitation", etc.) with explicit 0/10 anchors, in the
screen, the Summary Preview, and the PDF, so direction is consistent with
pain and nerve everywhere the number appears).

Back Pain's persistence uses a deterministic id, `backpain_YYYY-MM-DD` —
saving again the same day overwrites that entry instead of creating a
duplicate, and opening the screen loads today's existing entry if one
exists. This is the pattern the remaining screens should follow when they
get their own storage, rather than random/timestamp ids.

"Unknown" showing up in the clinician PDF's Triggers frequency table (1
occurrence) is not a bug — it's a legitimate chip. Both `CheckInEntry
.knownTriggers` and the Back Pain screen's own trigger option list include
`'Unknown'` as a deliberate "cause not known" choice, same as any other
trigger. No fallback anywhere inserts it for an empty set — symptoms and
pain locations have no such option and never produce it. (An unrelated
`'Unknown'` also exists in `fab_clinician_export_screen.dart` as a
child-name fallback — same string, nothing to do with triggers.)

Storage decision reaffirmed: Recovery, Sleep/Fatigue, Gastro, and Nutrition
still need their own separate models and boxes, not more nullable columns on
`CheckInEntry` — unchanged from the original call above, now that Back Pain
is the one screen that did extend the shared model.
