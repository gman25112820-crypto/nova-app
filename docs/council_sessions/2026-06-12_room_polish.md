# Council Session — Room Polish
**Date:** 12 June 2026
**Topic:** Interior room ambience and interactivity — what makes a room feel alive?

---

## Transcript summary

The council reviewed the current state of the house interior rooms (Chicken House
11 rooms, Giraffe House 8 rooms) — all navigable but visually static. The question
put to the council was: what is the minimum set of layers and interactions that
elevates a room from a menu grid into a place the child wants to return to?

The night garden (world scene) was proposed as the reference aesthetic and quality
bar. Any room treatment that would look out of place beside the night garden is
wrong. Any treatment that would sit naturally within it is right.

---

## Synthesis — council consensus

### Layer stack (in render order)
1. **Parallax foreground / midground / background layers** — depth illusion using
   the same fraction-offset pattern established in the world scene. Slow drift on
   mouse/tilt. Three layers minimum: bg (fixed), mg (slow), fg (fast).

2. **Ambient particle systems** — room-specific: dust motes in the hallway,
   firefly sparks in the safe corner, steam wisps in the kitchen, star drift in
   the attic. Lightweight, looping, never distracting.

3. **Time-responsive lighting tied to the day/night toggle** — warm amber in the
   evening, cool blue-white in daytime. Rooms feel continuous with the world
   outside rather than disconnected. Toggle is the single source of truth.

4. **One hero object per room** — a single interactive centrepiece that rewards
   returning. Not a tracker, not a nav tile — something that just exists in the
   room and responds to touch.

### Reference test
> *Would it look at home beside the night garden?*

If yes, build it. If it feels like a productivity app or a form, redesign.

---

## Builder specifics — locked in

These details are decided. Do not relitigate them at implementation time.

### Memory Lamp (hero object — Chicken Lips bedroom or hallway)
- Tapping the lamp cycles through colour: warm amber → soft rose → deep violet
- **Remembers the last 3 colours** the child chose across sessions (Hive)
- On open, lamp glows in the most recent colour — continuity of presence

### Humming Stones (hero object — Safe Corner)
- Five stones arranged in a shallow arc
- Tap produces a **kalimba tone, pentatonic scale: C D E G A**
- **2.3 s reverb tail** — room fills with resonance after each tap
- Prompt text: **"tap to wake the stones"** — shown on first visit, fades after
- Stones pulse faintly when idle (breathing animation, same cadence as characters)

### Garden plant — world scene panel or garden room
- One leaf added per **unique calendar day** the child visits
- **Maximum 12 leaves** — full bloom state, never overflows
- Leaf count persists in Hive (`child_<id>` data box, key `garden_plant`)
- Visual state: bud → 3 leaves → 6 → 9 → 12 (full)

---

## Implementation strategy — agreed order

1. **Prototype ONE room** — pick the room closest in mood to the night garden
   (Safe Corner is the leading candidate: dark, calm, particle-friendly)
2. **Test on minimum-spec device** before any further rooms — frame rate and
   particle count must be validated on a low-end phone/tablet first
3. **Modularise** — extract the layer stack and particle system into reusable
   widgets before applying to a second room
4. Do not build all rooms in parallel — depth compounds bugs

---

## Open questions (not resolved in this session)

- Which room goes first — Safe Corner or Attic? (Attic has star particles already
  implied by the Night Sky stub; Safe Corner has the Humming Stones hero object)
- Day/night toggle source of truth — SharedPreferences or Hive `settings` box?
- Memory Lamp placement — bedroom or hallway? (hallway gives it more foot traffic)
