# TAM-HOME-REBUILD-01 — Source-of-truth reference manifest

## 0. Primary offline image references — open these FIRST (Figma NOT required)

**Key visual direction:**
- `references/concept/C-FLUID-HOME.png` — main **Fluid Continuity** home/ride-entry concept. Inspect typography, flexible surface, hierarchy, mood, and spatial composition.
- `references/C-FLUID-STORYBOARD.png` — FIVE consecutive Fluid stages (home → search → route/car → confirmation → driver search). Derive motion choreography from the state transitions, not from an animated mock button.
- `references/concept/A-URBAN-HOME.png` — contrasting **Urban Pulse** concept; take spatial language only if appropriate.
- `references/A-URBAN-STORYBOARD.png` — five Urban states; compare with Fluid before selecting a direction.
- `references/A-C-HOME-COMPARISON.png` — read the aesthetic contrast in a single sheet.
- `references/company/UI-04-Home.jpeg` — original company's real Customer Home reference and feature inventory.
- `references/company/UI-10-Pickup-Destination.jpeg` and `references/company/UI-11-Quote-Vehicles.jpeg` — booking context only; do NOT redesign those screens in this task.
- `references/TAM_Motion_Prototype_v1.html` — same local interactive browser concept from which PNG references were rendered; optional supporting source (no Figma required).

All images were exported from the previously created **browser prototype or the actual company's JPEG folder** and verified to exist as project files. The prototype screenshots are **not direct Figma exports** and depict **abstract maps, not real GPS tiles**. Use them as creative inputs while building a brand-new **multifunction Home** based on real product contracts. Do not claim pixel-perfect Figma equivalence.

## 1. Figma design exploration (optional provenance ONLY; do not open)

**File:** https://www.figma.com/design/dW6LCuvdifCDLZp7bHQD0y — optional reference link, not a dependency.
**Page:** `02 • Motion Prototype` — previously recorded as 10 editable frames: 2 directions × 5 states.
**Other exploration:** Three art directions (Urban Pulse / Editorial Mobility / Fluid Continuity). Figma design should be opened and visually verified by Codex before claiming direct fidelity.

- A — **Urban Pulse**: strong spatial identity, dark map aesthetic, contrasting direction cues. Warning: dark map and battery/legibility costs.
- B — **Editorial Mobility**: disciplined Arabic typography, warm light backgrounds, deliberate whitespace.
- C — **Fluid Continuity**: one coherent surface transforming from search → selection → confirmation, gentle motion; stronger continuity but easy to overanimate.
- **Direction is not yet approved.** Compare A/C and consider a carefully reasoned hybrid with B's typographic discipline. Do not paste all ideas onto one busy screen.

**Figma export note:** The remote tool hit its Starter rate limit. We instead captured a *real locally available interactive browser prototype* that was previously designed as part of the same visual exploration. Codex must work from the PNG/JPEGs in this directory **without using Figma**. No Figma export is falsely represented as delivered.

## 2. Company's original 24 JPEGs — actually present in Git

**Original directory:** `apps/customer/Tam Cusstomer UI/`
**Index:** `docs/engineering/design-reference-index.md`
**Required Home original UI-04:**
`apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.02.59 PM (2).jpeg`

For convenience, exact source copies are inside:
`docs/engineering/tasks/TAM-HOME-REBUILD-01/references/company/UI-04-Home.jpeg`
`docs/engineering/tasks/TAM-HOME-REBUILD-01/references/company/UI-10-Pickup-Destination.jpeg`
`docs/engineering/tasks/TAM-HOME-REBUILD-01/references/company/UI-11-Quote-Vehicles.jpeg`

- **UI-04** = customer Home: greeting/location area, customer service navigation, promotion, home bottom nav. Legacy Mashwar branding/photos are **not** final Tam visual assets.
- **UI-10** = pickup/destination in booking (context only; do not redesign booking).
- **UI-11** = vehicle/fare selection (context only; do not redesign booking).
- The other JPEGs mix **customer and driver screens**; don't use driver UI as customer Home. Read the index first. Do not copy unavailable food/shopping as fully launched services.

**Priority of sources:** existing Home business/navigation contracts and company UI-04 content requirements > bundled prototype flow imagery > art-direction inspiration. Company and Figma screenshots are inspiration, never authoritative backend specifications.

## 3. Prior local visual implementation (negative baseline, not a target)

`docs/engineering/deliveries/TAM-VISUAL-01/01-fluid-home-emulator.png`
`docs/engineering/deliveries/TAM-VISUAL-01/TAM-Visual-Before-After.png`
`apps/customer/lib/features/home/presentation/**`

These show the previous cosmetic treatment which the user **explicitly rejected**. DO NOT use as the base composition. They are only useful for detecting whether a new UI is genuinely transformative.

## 4. Supplementary locally generated research/prototype pack

Earlier project files exist as ChatGPT conversation attachments, not necessarily in the Codex machine:
- `TAM_Creative_Research_v1.md`
- `TAM_Art_Direction_Review_v1.md`
- `TAM_Motion_Implementation_Spec_v1.md`
- `TAM_Motion_Refinement_v2_Notes.md`
- `TAM_Motion_Prototype_v1.html`
- `TAM_Motion_Prototype_v2.html`
- `TAM_Motion_Showcase_v2.mp4`
- `TAM_Motion_v2_Desktop.png`, `TAM_Motion_v2_Mobile.png`
- `TAM_Motion_Storyboard_v1.png`

The necessary **image** references are ALREADY inside `references/` and accessible to Codex directly. Historical optional chat attachments may be absent; the agent must NOT rely on downloading or opening Figma. Inspect the images above, and report unavailable optional research files honestly. Browser prototype prices/routes/ETA are illustrative, NOT live features.

## 5. Mandatory existing docs
- `AGENTS.md`
- `docs/engineering/agent-task-template.md`
- `docs/engineering/parallel-work.md`
- `docs/engineering/working-agreement.md`
- `docs/engineering/development-phases.md`
- `docs/engineering/design-system.md`
- `docs/engineering/design-reference-index.md`
- `docs/engineering/mock-api-policy.md`
- `docs/engineering/navigation.md`

Never infer that a Figma tool succeeded, file exists, or business logic is implemented solely because this manifest names it; check it.
