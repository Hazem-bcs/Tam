# TAM — New Home Visual Direction / Creative Brief

## Product ambition
Tam | تم is a real customer-facing ride app, not a generic portfolio mockup.
The goal is a distinctive, cinematic **yet practical** journey narrative that a senior UI designer and Flutter engineer can defend during review.

The previous UI and the `TAM-VISUAL-01` cosmetic facelift are **rejected as design baselines**. The user requests a **full Home composition replacement** rather than refinements. Only Home is authorized now.

## Non-negotiable experience
The Home answers three questions within the first glance:
1. What app is this and what can I do now?
2. Where can I start a ride? (clear, primary first action)
3. Where are my trips / saved places / notifications / account?

Actual behavior comes from existing Home repository and navigation callbacks, **not** fabricated static content inside widgets. Home can visualize a brand's mobility theme without pretending to render precise Aleppo routes. If map tiles/service unavailable, show a visually coherent, truthful alternative; do not invent user GPS coordinates, available drivers, real ETA or fare.

## Distinctive visual hypotheses to explore
**Concept A — Pulse / Spatial:** leading with purposeful spatial language, bold hierarchy, active vehicle/route motifs; dense, dark map-dominant aesthetic only if legible and technically grounded.

**Concept C — Fluid / Continuity:** responsive flexible canvas; one primary action surface that stretches and changes meaning when entering the booking flow; calmer light surface with strong focal accent. Transitions must reflect **real navigation/state**.

**Concept B — Editorial typography:** restrained typography-led art direction; Arabic letterforms and hierarchy as key identity rather than generic app-card stack. Use to discipline A/C, not mechanically copy another brand.

**Creative criteria:** surprising but intuitive; cinematic framing, structured whitespace, deliberate depth, art-direction unity; memorable unique iconography/illustration only when fully attributed/licensed; highly readable in sunlight; test on low/mid-range Android. Do not imitate Uber/Careem/Bolt screens pixel-for-pixel.

## What NOT to do
- Do not keep the old heading → promotion card → search card → services grid → announcement structure and simply recolor it.
- Do not stack ornamental containers, random gradients, blur, glows and endless loops to fake quality.
- Do not use stock AI-looking photos of cars, fictitious customer names, fake discounts or button labels that don't reflect actual state.
- Do not turn unavailable food/shopping into enabled purchase actions.
- Do not change Domain/Data/Auth/route guards to fit a picture.
- Do not move all app screens to this new identity in this task; Home first, migrations later.
- Do not mix the literal legacy word 'مشوار' from the company's historic mockups with product branding `تم`; keep existing product-labeled service semantics where applicable.

## Visual fidelity and accessible engineering
- Replace the previous visual language with an intentional new art direction; the old burgundy palette is **not mandatory**. Introduce opt-in Home/brand semantic tokens in the **central** design system as needed, without making unrelated screens accidentally change. No scattered magic colors, font sizes or radii. Existing behavior and backend architecture stay intact.
- Distinct components should have meaningful names and single responsibilities; clean-state-driven animations, no timers that imply backend completion; reduced motion behavior.
- RTL Arabic and LTR English must both feel native; maintain text scaling, keyboard, small phone/tablet/landscape SafeArea and screen reader semantics. Maintain contrast and minimum touch targets.
- No broad package additions unless demonstrated need; use Flutter native transitions first. Rive only for uniquely authored controlled assets that offer tangible value.
- Motion choreography: entry should direct focus to ride action; morphs must preserve context, avoid sudden re-layout and not block taps; no perpetual CPU drain.
- Debug emulator screenshots support visual checking only; profile-mode frame measurements required before claiming 60fps.

## Deliverables and critique gate
1. Two real concept explorations **meaningfully different** in layout/art direction, annotated with reasons and risks; choose one yourself with a concise scoring rationale.
2. Rebuilt **Home only**, old Home-only presentation layout/widgets deleted once replaced. Navigation/state, content and error/loading cases remain working.
3. Screenshot set: before, new Home RTL 390, EN 390, 320dp text 2x and 800dp tablet; one screen motion capture if actually possible.
4. Source review: no dead Home UI, redundant tokens, data in widgets, hardcoded palette or inaccessible controls.
5. Tests and a code/visual handoff tied to a real SHA. Mark `READY_FOR_REVIEW`, not fully approved or production-ready.

**Success:** A reviewer should be able to distinguish the new Home from the previous version instantly, without reading commit messages, while existing functional integration tests remain valid.
