# Customer feedback implementation — 2026-11-18

Role: DEVELOPER; status READY, assigned by supervisor root.
Repository: isolated managed worktree supplied in the assignment.
Baseline: 6eb1e990d0a6c7a911098b0dd08f5883f717bc81 plus this coordination commit.
Goal: implement the owned feedback completely, preserving Auth/guest/localAccess and mock/API boundaries.
Read AGENTS.md, agent-task-template.md, parallel-work.md, working-agreement.md, architecture ADR, design-system.md, navigation.md and customer-feedback-plan-20261118.md.
References: docs/engineering/references/customer-feedback-20261118/01-route.jpeg, 02-rating-support.png, 03-driver-panel.png. Inspect images before dependent visual edits.
No push/main/Actions. Supervisor owns the task board, generated l10n, integration, Android build and the only emulator.
Use feature ARB fragments; generate locally if necessary, commit only owned fragments. Shared changes outside ownership go to supervisor as a specific request.
Batch broad verification at integration. Format touched code and add meaningful regression tests. Do not run full suite/build/emulator.
Deliver committed exact SHA and focused HANDOFF.md with changed paths, actual checks, visual evidence and limitations; freeze delivered SHA. Review assigned independently on exact SHA.
All application operations remain mock in current default; no live booking/payment/auth claims or silent fallback.
Communication with supervisor and assigned teammate agents for coordination/review is authorized by the user's multi-agent request; no external messaging.

Scope F04,F05 and F08 search animation, booking keyboard/responsiveness in F02.
Owned: features/ride_request/** except ride_coupon_field.dart and ride_coupon_picker.dart; features/home/**; shared/data/mock/mock_trip_store.dart and mock_trip_snapshot_store.dart; features/active_trip/domain/** and data/**; features/active_trip/presentation/widgets/active_matching_pulse.dart and active_search_journey.dart; app/router/ride_journey_page.dart; matching tests; docs/api/scheduling/**; docs/engineering/deliveries/CF-BOOKING/**.
Root owns router wiring/app.dart and generated translations; request precise changes. Trip-display agent owns other active_trip presentation and all trips/chat/completion.
Decisions for mock implementation: preserve existing schedule lead-time/horizon validation; scheduled trips do not prevent immediate booking; future scheduled trips remain discoverable outside history, ordered by scheduled time and individually selectable; cancellation removes only that trip from upcoming; reuse existing snapshot owner isolation and restoration. Do not invent live collision policy: preserve existing immediate-trip semantics, document server-authoritative future conflicts and explicit simulated scope. Any new API behavior must update existing versioned scheduling contract/Postman/examples/README.
Vehicle list feedback explicitly authorizes an initial inset/discovery hint despite older horizontal-list preference; direction aware, accessible, no hidden choices. Keep map state stable across panel transitions, reduced motion respected.
