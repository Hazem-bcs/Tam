# TAM-MOTION-01 — Flutter Motion Vertical Slice

Date: 2026-11-12
Scope: customer app, ride-request visual presentation only.
Baseline (local): `bfebc0e11f7ee14b41a1858642116331624d6616`
Branch: `codex/tam-motion-vslice-20261112`
Checkout: `/home/hazem/projects/tam-motion-vslice`
Design exploration: https://www.figma.com/design/dW6LCuvdifCDLZp7bHQD0y

## Intent

Translate the first elements of the TAM motion study into production Flutter
**without** introducing a parallel booking workflow or changing existing
Domain/Data/API contracts.

The browser design exploration is NOT copied into production as new independent
colors or fonts. AppTheme remains the source of visual truth. Brand-direction
approval and exact rendering parity are separate upcoming tasks.

## Implemented

- Shared `AppMotion` durations and easing in `app_tokens.dart`.
- `RideJourneyProgress`: animated stage feedback (pickup, destination,
  vehicle/quotation, review) derived from `RideDraftState`, not a timer or
  synthetic booking events.
- `RideRouteMotionPreview`: animates the height of the **existing**
  `RouteMapView` when the draft has a valid route. The map is isolated in a
  `RepaintBoundary`; there are no invented location coordinates or fake tiles.
- Ride-request destination bottom sheet: explicit entry and exit durations,
  respecting `MediaQuery.disableAnimationsOf`.
- `RideVehiclePicker`: animated selection border, icon scale and selected-state
  transition with colors from the ambient `ThemeData`.
- Places, schedule, map, vehicle, quote and confirmation continue using the
  **existing** BLoC and callbacks. Scheduling is placed directly after locations
  so it remains reachable even on smaller viewports.

## Safety and architecture

- No changes to Auth, Domain, Data, repository contracts, Postman, or backend.
- No new runtime package dependencies.
- No fake booking success; the original mock/API selector controls behavior.
- Central colors, typography, spacing and accessibility preferences remain in
  effect. Flutter Material semantics and native InkWell interaction are retained.
- No edits to the original local checkout, store PCs, or GitHub main branch.
- Work in isolated git worktree only.

## Verification

- `dart format --output=none --set-exit-if-changed lib test`: passed.
- `flutter analyze --no-pub`: passed, 0 findings.
- Motion widget tests: progression depends on draft and map grows only after a
  valid route; reduced-motion preference respected.
- Existing ride-request widget tests: Arabic 390dp, English, tablet, small
  320dp with 2x text and keyboard: passed.
- Existing scheduled-booking integration test: passed after rearranging
  scheduling above the map. This fixes a real lazy-list visibility regression
  introduced by the additional vertical motion layout.
- Full `flutter test --no-pub`: **PASSED — 683 tests** (final run after fixing the scheduling visibility regression).

## Known limits / next work

- No physical Android/device performance profile in this iteration; no claim of
  sustained 60fps or release readiness.
- The final Urban Pulse / Fluid Continuity art direction is still undecided.
  This slice uses the existing central burgundy TAM theme.
- No custom route-path drawing or Rive state machine is integrated; the map
  implementation stays authoritative. Future work should measure actual
  route-drawing costs against map movement and tile rendering.
- Visual golden baselines and screenshots should be reviewed during the
  dedicated art-direction approval phase; this handoff is not an aesthetic
  approval.
- Next: independent review, motion profiling on Android, and user testing before
  widening final visual changes.
