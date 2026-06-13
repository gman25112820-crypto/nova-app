# Room Readiness Audit
**Date:** 12 June 2026
**Purpose:** Assess each room's current asset state for parallax and ambient polish.

Columns:
- **Background layered?** — separate fg/mg/bg files, or single flat PNG
- **Hero object candidate** — best existing tappable for promotion to hero
- **Existing ambient motion?** — any animation already present in the room

---

## Chicken House

| Room | Background layered? | Hero object candidate | Existing ambient motion? |
|---|---|---|---|
| CL Bedroom | ❌ Flat PNG | Memory Lamp (🪞 mood mirror → lamp) | No |
| Girl 1 Room | ❌ Flat PNG | Creative journal (🎨) | No |
| Girl 2 Room | ❌ Flat PNG | Worry corner (💭) | No |
| Bathroom | ❌ Flat PNG | Breathing bubble (🫧 calm breathing) | No |
| Kitchen | ❌ Flat PNG | Cooking pot (👩‍🍳 cooking activity) | No |
| Living Room | ❌ Flat PNG | Games console (🎮 games sheet) | No |
| Hallway | ❌ Flat PNG | Memory Lamp (🖼️ gallery — strong lamp candidate) | No |
| Front Door | ❌ Flat PNG | Garden portal (✨ Enchanted Garden) | No |
| Back Door | ❌ Flat PNG | Dino portal (🦕 Dino Garden) | No |
| Safe Corner | ❌ Flat PNG | **Humming Stones** (🪨 — council locked) | No |
| Music Corner | ❌ Flat PNG | Sound explorer (🎹 — strongest tappable in house) | No |

## Giraffe House

| Room | Background layered? | Hero object candidate | Existing ambient motion? |
|---|---|---|---|
| Main Bedroom | ❌ Flat PNG | Mood mirror (🪞 mood check-in) | No |
| Boy 1 Room (Theo) | ❌ Flat PNG | Trophy shelf (🏆 achievements stub) | No |
| Boy 2 Room (Ollie) | ❌ Flat PNG | Night sky window (🌟 — strong hero candidate) | No |
| Kitchen | ❌ Flat PNG | Cooking pot (👨‍🍳) | No |
| Games Room | ❌ Flat PNG | Noughts & crosses board (⭕ — fully live) | No |
| Bathroom | ❌ Flat PNG | Breathing bubble (🫧) | No |
| Study | ❌ Flat PNG | Desk lamp / focus helper (💻) | No |
| Attic | ❌ Flat PNG | **Treasure chest** (📦 — strong hero candidate) | No |

---

## Summary

**0 of 19 rooms** have layered assets. Every room background is a single flat PNG.

**Implication for parallax:** Re-generating layered art from the Kontext pipeline
is the clean path (separate bg, mg, fg plates per room), but it's a significant
asset production task. The practical first step is a **blur + overlay fake-depth**
approach: apply a Gaussian blur to a copy of the flat PNG for the background layer,
use the sharp original as the midground, and place a lightweight painted overlay
(vignette, foreground prop) as the top layer. This gives convincing parallax with
zero new art required and can be validated on the Safe Corner prototype before any
re-generation decision is made.

**Existing ambient motion:** None in any room. All rooms are completely static.
The particle system and breathing animations will be net-new for every room.

**Strongest prototype candidate:** Safe Corner (Chicken House)
- Dark, calm palette — closest to the night garden in mood
- Humming Stones hero object already specified and locked
- No competing tappables that would distract from the prototype test
- Particle candidate: soft firefly sparks or slow ember drift
