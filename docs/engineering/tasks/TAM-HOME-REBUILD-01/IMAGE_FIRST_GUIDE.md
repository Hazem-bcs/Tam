# IMAGE FIRST — How Codex must use these assets

**Figma not required. Do NOT try to access Figma.** These screenshots capture our earlier offline browser design exploration and are usable directly via file-reading/image-viewing.

## Required view order
1. `references/company/UI-04-Home.jpeg` — **company's customer Home**: exact content categories, not final composition.
2. `references/A-C-HOME-COMPARISON.png` — inspect the difference in visual language.
3. `references/concept/C-FLUID-HOME.png` — Fluid Continuity detailed visual direction.
4. `references/C-FLUID-STORYBOARD.png` — five consecutive stages of the **booking** concept (contextual motion language, not five pages to rebuild).
5. `references/concept/A-URBAN-HOME.png` and `references/A-URBAN-STORYBOARD.png` — alternative direction.
6. `references/company/UI-10-Pickup-Destination.jpeg` and `UI-11-Quote-Vehicles.jpeg` — contextual future flow only.

**IMPORTANT distinction:** our `HOME` prototype images show the **ride-entry/map interaction**, NOT the complete customer multifunction Home. Do not paste that screen over the app and call the Home redesign complete. Combine the interaction language with *actual Home responsibilities* from UI-04 and current Home domain/navigation contracts.

## Provenance
- `references/TAM_Motion_Prototype_v1.html` is the original existing local browser prototype. The 10 individual PNGs were captured directly from it in Chromium; C and A storyboard images were assembled from those captures.
- They are **not direct Figma exports**. Figma access is deliberately unnecessary.
- Conceptual map lines are **not geographic map tiles**; no route/ETA/driver availability claims may be inferred.
- Company JPEGs are direct copies from the repo's `apps/customer/Tam Cusstomer UI/` directory.

## Extraction instructions
Describe the design in a concise `DESIGN_EXTRACTION.md` before coding:
- Layout grid/safe areas; hierarchy; Arabic text alignment and typographic proportions.
- Color roles (not random hex tokens per widget), surface depth, shape families and spacing rhythm.
- Interaction trajectory and animation candidates (duration/curve/purpose/reduced-motion).
- Which elements are purely decorative; which map to real Home models and actions.
- Differences between prototype **ride-entry** screens and actual multifunction **Customer Home**.

Translate image proportions semantically, not pixel-for-pixel. Test at 320/390/tablet sizes. The design should be recognizable as an original new system, *not* a clone of company UI-04 or a re-skinned current Home.

## Quality gate
A static screenshot is only one reference; demonstrate real scrolling, working taps, loading/error/unavailable states, RTL/LTR, animation state control, battery-friendly performance and visual review on Android.
