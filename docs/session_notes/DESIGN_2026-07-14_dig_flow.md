Dig flow design — 14 July 2026 (locked, extends DESIGN_2026-07-13_underground.md)
Room feels (4, locked): cosyNook, starCave, blanketDen, gardenHollow — warm, vast, soft, alive. "Reading burrow" dropped (name collision with The Burrow; activity-implying).
Lamp colours (5, locked): amber (default, matches entrance), rose, honeyGold, ember, moonlightCream. All warm; moonlightCream is warm off-white, never blue. Child-facing: tappable swatches, no labels.
Dig = one tap, always. Tapping "dig a new room?" immediately creates a room with soft defaults: feel cosyNook, lamp amber, name = the feel's display name ("Cosy Nook"). No wizard, no form, no required choices. The child lands inside their new room.
The dig moment: brief and gentle — earth softly parting / warm fade-through, under a second, no fanfare, no reward language. It should feel like digging, not unlocking.
Shaping happens after, optionally, forever: inside every child-dug room, one quiet affordance ("change this room?") opens feel / lamp swatches / name. Never badged, never prompted. A room never shaped is a done room.
Going up: every room has an upward doorway (one level up) plus a soft "back to the house" so a child deep down can surface in one step. Descending remains room-by-room.
Regret: rooms can be renamed/reshaped any time via the same affordance, and collapsed ("collapse this room?" + gentle confirm). Never framed as loss, waste, or warning. Welcome room cannot be collapsed.
Schema (Pattern B — List inside child's own document):
UndergroundRoom { id, name, feel, lampColour, depth, createdAt }
Deliberately absent: lastVisited, visitCount, any completeness/engagement state. Nothing that could ever power a streak, nudge, or absence-guilt.
No tutorial, no explainer. The tunnel mouth teaches itself.
