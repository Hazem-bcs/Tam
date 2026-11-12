# TAM-VISUAL-01 — Phase 2: Visual Home + Ride Slice

**Date:** 2026-11-12
**Task:** TAM-VISUAL-01
**Role:** User-directed developer; worktree isolated from integration.
**Baseline:** `3bbe8fe7caca1a24bdf36f6d6c7d6cd5da4e15b5`
**Branch:** `codex/tam-fluid-redesign-20261112`
**Worktree:** `/home/hazem/projects/tam-motion-vslice`
**Reference:** [TAM Fluid Continuity exploration](https://www.figma.com/design/dW6LCuvdifCDLZp7bHQD0y)

## Delivery scope

A visible new identity with central color semantics preserved. This is the
first **Flutter visual redesign slice**, not full Figma parity or an approved
cinematic motion system.

### Home
- Main ride action is placed **ahead of** artwork. Users can start booking
  without needing to scroll, including the original 800×600 integration test
  viewport.
- Existing backend-sourced hero promotion is rebuilt as a prominent deep
  burgundy surface with an abstract, one-shot drawn curve. The curve is
  explicitly decorative, **not a route map** and never displays invented data.
- Header, address and active-trip controls, entry, service cards and
  announcement have been restyled; Arabic/English text continues to come from
  existing localization and Home repository models.
- No content fixtures or routing decisions were moved into UI. Guest and
  temporary-access behavior remain unchanged.

### Ride request
- A vibrant gradient progress card with three real draft stages replaces the
  old thin text-only progress strip. Quote loading doesn't falsely imply
  user review.
- Pickup and destination fields are restyled, with clearer visual affordances
  and selected-state motion.
- Existing schedule, route preview, vehicle selector, quote/review and
  confirmation behavior continues via `RideDraftBloc`.
- Booking keeps the original lazy `ListView` for compatibility and efficient
  construction. A responsive content-order rule shows location inputs before
  the expressive progress panel on compact-height or large-text screens,
  ensuring form access on 320dp/2× text and 800×360 landscape without
  duplicating labels or rendering all quote sections ahead of the viewport.

## Constraints honored from AGENTS.md
- Architecture, Domain/Data, Auth, DI, API contracts, central configuration and
  shared ARB/theme/navigation files untouched.
- All colors consumed from ambient Material `colorScheme`, typography from
  ambient `textTheme`, spacing/radii from central tokens. No new palette.
- Feature files stay focused, under the preferred ~300-line target.
- RTL/LTR, enlarged text, hit targets and platform reduced-motion supported.
- No feature mock data, fake maps, unconfigured GPS claims or artificial
  booking success. Existing per-feature mock repositories remain the source.
- Did not touch store PCs, original project checkout, or remote main.
- Emulator was reused rather than relaunched; no CI, push or merge.

## Test status
- `dart format --output=none --set-exit-if-changed lib test`: PASS.
- `flutter analyze --no-pub`: PASS.
- Targeted Home and Ride widget tests: PASS.
- Scheduled booking, addresses picker at 320dp/2× text and 800×360
  landscape/2× text, cross-feature customer booking: PASS after fixing first
  viewport hit-testing and eager form mounting.
- Full `flutter test --no-pub`: **PASSED, 683 tests** after fixing the
  home ride entry hit-testing regression and retaining a virtualized `ListView`
  with compact-layout location-first rendering.

## Actual emulator visual evidence
- `01-fluid-home-emulator.png`: final action-first homepage, captured from the
  reinstalled Android APK after the passing full test suite.
- `02-fluid-ride-emulator.png`: real redesigned booking form.
- `TAM-Visual-Before-After.png`: genuine Android emulator before/after
  comparison including the final action-first home and updated booking screen.

## Remaining visual / technical tasks
- Current art direction is a first production slice; final cinematic transitions
  and a map-dominant layout remain future design work.
- Private map tiles are unconfigured: booking correctly shows an honest route
  summary, not an invented live map.
- Profile on a physical Android phone before claiming sustained 60 fps.
- Run deeper color contrast / accessibility checks on larger text and screen
  readers before release.
- Visual design acceptance, independent code review and integration are not
  performed in this task. Do not call it release-ready.
