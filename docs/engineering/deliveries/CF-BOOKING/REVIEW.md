# CF-BOOKING — independent critical review

Role: REVIEWER, assigned by supervisor root after implementation freeze.
Input implementation SHA: `0a31c58a48af4f4cff844ea243161d4022cec249`.
Reviewed diff: `1b8890049177b56b3ce8e2c0254b622defa95bbf..0a31c58a48af4f4cff844ea243161d4022cec249`.
Review branch: `codex/customer-feedback-review-booking-20261118`.
Isolated worktree: `/home/hazem/.codex/worktrees/customer-feedback-review-booking/mashwar`.
Final identity: commit containing this report; exact SHA delivered to supervisor.
Verdict: **APPROVED_AT_SHA** for the owned booking implementation, with explicit integration prerequisites below. No product fixes required during this review.

## Review findings

Read AGENTS/task card/handoff and retained same-baseline portable protocol, architecture, design/navigation rules and feedback plan. Reviewed full owned product diff plus changed tests/contracts, and surrounding MockTripStore/snapshot ordering and session lifecycle.

- current() excludes scheduled reservations; retained MockTripStore ordering keeps current immediate selection deterministic. upcoming() lists only scheduled by scheduledAt then id, while fetch(id) retains direct reservation access. Due dispatch uses the existing simulator; no invented server conflict policy.
- Upcoming Home Cubit subscribes/disposes correctly and uses request generations to reject old completions. Failed refresh keeps previous data with explicit stale-information text and retry. Provider identity includes repository/session status/phone; root router injection still required.
- Cancellation removes one reservation; immediate and remaining reservations persist. Existing snapshot owner/epoch logic protects restart, logout, owner switching and delayed restoration. New tests cover multiple reservations plus immediate booking, targeted cancellation and restart. No additional storage source or Auth behavior introduced.
- Scheduling Arabic contract/README/Postman describe additive scheduled filter/sort/cursor semantics, future API page aggregation, account isolation and simulated current behavior. Examples match actual mocked live metadata and cancellation output. API stub fails explicitly; no mock fallback.
- Keyboard unfolds the panel and constrains it above insets while keeping map element/size stable. Confirmation action becomes scrollable for short/keyboard/large-text layouts. Across actual booking/live stages RouteMapView State remains identical in focused tests.
- Vehicle list has authorized directional initial/end spacing, compact discovery hint and accessible arrow controls. Arrow scrolling and route/panel motion respect reduced-motion settings. Search motif uses a bounded repaint subtree and stops its controller under disableAnimations.

No new blocking correctness, session isolation, localization or architecture finding in the owned SHA. Existing oversized shell/page were touched narrowly and explained in implementation handoff; no unrelated refactor requested.

## Actual checks

Local Flutter3.41.4/Dart3.11.1. Reused ignored dependency resolution from ahmad-ui. Ran sync_feature_l10n.py and flutter gen-l10n locally so owned Home keys compile; generated outputs deliberately excluded from this review commit.

One independent critical batch from apps/customer:

```text
flutter test --no-pub \
 test/features/home/home_upcoming_trips_cubit_test.dart \
 test/features/active_trip/active_trip_repository_test.dart \
 test/shared/mock_trip_snapshot_test.dart \
 test/features/ride_request/scheduling/scheduling_contract_test.dart \
 test/features/ride_request/presentation/widgets/ride_keyboard_panel_test.dart \
 test/features/ride_request/presentation/widgets/ride_live_continuity_test.dart
34/34 passed (13 seconds reported test time).
```

This covers stale async completion, cancellation, session reset, due dispatch, immediate selection, explicit API failure, restart/multiple reservations/owner isolation/read-write failure, contract/Postman equivalence, keyboard at320×740/844×390/800×1000 with2× text, and map identity through all live phases at390/320/800/844 widths.

Focused dart analyze on all15 changed product path groups: **No issues found!**. `git diff --check` passed. Independently parsed all23 scheduling JSON files; Postman collection has6 requests. No full suite/build/emulator/live HTTP/Postman GUI import, UI recapture or performance claim. Visual review here is source+widget layout/assertions; developer's existing capture report remains device-limited evidence, not release certification.

## Supervisor integration prerequisites

- Inject UpcomingTripsRepository into buildHomeFeature via root router and regenerate shared localization.
- Apply prepared shared Arabic coupon normalization/pricing wiring plus its end-to-end quote/book/snapshot coverage.
- Update active-trip Postman saved responses so scheduled is represented by id details rather than current, matching the changed textual contract.
- Preserve the map subtree type across draft/live transition when integrating trip geometry changes; do not conditionally replace RideJourneyBackdrop with a different root map widget.
- Recheck combined candidate and user journey on the single emulator; physical-device profile/60fps claims remain unavailable. Server-authoritative future scheduling collision/availability policy remains unspecified and intentionally not simulated as real authorization.

Approval is tied to the report commit SHA, not a moving branch name. Branch frozen after report delivery. No push/main merge/Actions.
