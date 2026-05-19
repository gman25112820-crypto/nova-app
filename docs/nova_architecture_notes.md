# Nova Architecture Notes

Notes for developers on the Nova / Fabulously Me module split.
This file covers module boundaries, tone, and what goes where.

---

## Nova is the top-level platform

`NovaHubScreen` is the root of the app.
It is a switchboard — not a product in itself.

From the Hub, users choose:
- **Fabulously Me** — child and family wellbeing branch
- **Nova Health** — personal adult health records branch

Do not collapse these two branches into one.
Do not route users directly into Fabulously Me without passing through the Hub
(unless `main_fab.dart` is used as a dev/FAB-only entry point).

---

## Fabulously Me is one branch — not the whole app

Fabulously Me (`FabHomeScreen`) is a child and family wellbeing experience.
It has its own visual world, characters, and tone.

Keep Fabulously Me:
- cute, warm, gentle, and magical
- simple and uncluttered
- character-led and child-friendly
- comforting and safe-feeling

Do not drift toward:
- clinical / medical look
- dark or anxious tone
- complex UI that overwhelms a child

**Do not place Nova Health modules inside Fabulously Me folders or routes.**

---

## Nova Health modules are separate from Fabulously Me

Nova Health modules (`nova_health_screen.dart` and all `nova_*_module_screen.dart`)
are grown-up, practical, and privacy-first.

They sit in `lib/fab/screens/` currently (historical placement),
but they are **not part of the Fabulously Me experience**.

When the codebase is reorganised, Nova Health modules should move to their
own directory (e.g. `lib/health/screens/`) separate from `lib/fab/`.
Until that reorganisation, do not add Nova Health modules to Fabulously Me routing.

Nova Health tone:
- calm and practical
- grown-up and supportive
- privacy-first and individual-owned
- not clinical, not fake-medical, not childish

---

## Privacy and local-only rules

Nova is privacy-first, individual-owned, and consent-led.
These rules apply to both branches.

Do not add:
- API calls to external services
- Cloud sync or remote storage
- Accounts, authentication, or login
- Analytics, tracking, or telemetry
- Payments or subscriptions
- Data sharing without explicit user consent

All records are local and stay on the user's device.
The user chooses what to keep, what to review, and what to share.

---

## Module list (as of May 2026)

### Fabulously Me branch
- `FabHomeScreen` — world scene, character check-ins, calm activities
- `FabCheckInScreen` — child emotional check-in
- `FabOnboardingScreen` — first-run experience
- `FabParentDashboard` — parent/carer notes
- `FabBrilliantScreen`, `FabResourceHub` — supporting content
- `FabInsightsScreen`, `CookingScreen` — FAB-specific screens

### Nova Health branch
- `NovaHealthScreen` — health module menu
- `NovaBackPainModuleScreen` — back pain daily check-in
- `NovaRecoveryModuleScreen` — recovery tracking
- `NovaSleepFatigueModuleScreen` — sleep and fatigue log
- `NovaNutritionModuleScreen` — food and pattern log
- `NovaGastroModuleScreen` — gut symptom log
- `NovaCookingModuleScreen` — cooking and recipe support
- `NovaInsightsModuleScreen` — future pattern summary (placeholder)
- `NovaEvidenceNotesScreen` — appointment prep and evidence notes

---

## Naming convention

- `fab_*` prefix — Fabulously Me widgets, screens, and utilities
- `nova_*` prefix — Nova Health screens
- `nova_hub_screen.dart` / `nova_health_screen.dart` — top-level Nova files in `lib/`
- Nova Health module screens currently live in `lib/fab/screens/` (pending reorganisation)

---

## FAB world scene notes

The Fabulously Me world scene (`fab_world_scene.dart`) uses:
- `CustomPainter` layers 0–10 with parallax
- `FabInteractionSystem` for character movement
- `FabWorldAudio` for ambient sound (audio files not yet present)
- `LivingWorldCharacter` for animated characters

See `docs/fabulously_me_polish_notes.md` for visual polish items.
