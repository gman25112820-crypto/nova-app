# Fabulously Me — Age-Adaptive Architecture Spec

Created: 2026-06-04

---

## 1. Five-Band Age System

AgeMode is derived from the child's date of birth, never stored directly.

| Band | Age | Label | Character | PIN |
|---|---|---|---|---|
| `littleOnes` | 0–3 | Little Ones | parent | none |
| `earlyYears` | 4–6 | Early Years | Giraffe Family | not recommended |
| `middleYears` | 7–9 | Growing Up | Chicken Lips | recommended |
| `preteen` | 10–12 | Finding Strength | Older Kids' Space | required |
| `teen` | 13–18 | My Space | Teen Space | required + child PIN option |

---

## 2. Navigation by Age Band

| Band | House route | World access | Child PIN |
|---|---|---|---|
| `littleOnes` | `HouseType.littleOnes` — parent log only | Zones visible but parent navigates | None |
| `earlyYears` | `HouseType.giraffe` — Giraffe House | All zones | Not required |
| `middleYears` | `HouseType.chicken` — Chicken House | All zones | Recommended |
| `preteen` | `HouseType.olderKids` — Older Kids' Space | All zones | Required |
| `teen` | `HouseType.teen` — Teen Space | All zones + private journal | Child-set PIN gates private zones |

---

## 3. Prompt Engine by Band

| Band | Prompt type | Parent visibility |
|---|---|---|
| `littleOnes` | Parent observation nudges — no child prompts | Fully parent-facing |
| `earlyYears` | Visual emoji only — no text input | Parent sees responses |
| `middleYears` | "How's your day going?" standard mood/energy | Parent sees summaries |
| `preteen` | Transition prompts (Yr 6–7). "How are you feeling about moving schools?" | Transition state shown to parent |
| `teen` | Mood/hormone shift prompts Yr 8–9. Privacy-aware. | Teen prompts do not surface in parent dashboard |

---

## 4. Transition Banner Rules

- Shown for `preteen` band children in school year 6 or 7.
- UK school year approximation: year ≈ age − 4.
- Banner message: "Big year coming up 💜 We've got you"
- Tappable → `TransitionTipsScreen` (resource hub for transitions).
- Dismiss button stores `dismissed = true` in Hive box `transition_banner_{childId}`.
- Does not re-appear once dismissed.

---

## 5. PIN Rules

| Band | Parent PIN | Child PIN |
|---|---|---|
| `littleOnes` | N/A | Never shown |
| `earlyYears` | Optional | Never shown |
| `middleYears` | Optional | Optional |
| `preteen` | Required | Required |
| `teen` | Required | Child may set own PIN for private zones only. Parent skeleton key always overrides. |

PIN idle modes (stored in Hive box `pin_prefs`, key `require_mode`):

- `always` — PIN required on every profile open.
- `idle_15` — PIN required only if app has been idle for 15+ minutes.

---

## 6. Walkthrough System

Two walkthrough types: `child` and `parent`.

Each walkthrough runs once per install. Completion stored in Hive box `walkthrough`:
- Key `child_complete = true`
- Key `parent_complete = true`

Child steps: Companion → Mood zone → World scene → Games.
Parent steps: Family dashboard → Child profile card → Report generator → Skeleton key → Settings.

---

## 7. Files

| File | Purpose |
|---|---|
| `lib/fab/models/child_profile.dart` | `AgeMode` enum — 5 bands |
| `lib/fab/screens/house_interior_screen.dart` | `HouseType` — 5 types + `houseTypeForAge()` |
| `lib/fab/services/age_prompt_engine.dart` | Prompt derivation — 5-band aligned |
| `lib/fab/widgets/transition_banner.dart` | Year 6–7 banner with dismiss |
| `lib/fab/screens/transition_tips_screen.dart` | Transition resource hub (placeholder) |
| `lib/fab/widgets/walkthrough_overlay.dart` | Spotlight walkthrough overlay |

---

## 8. Safety Rules

- All prompts are optional and dismissable — never forced.
- Teen prompts do not surface in parent dashboard.
- Child PIN only gates child's own private zones. Parent skeleton key overrides everything.
- `littleOnes` children never see a PIN prompt.
- AgeMode is always derived from DOB — never written or overridden directly.
