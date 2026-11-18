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

Scope F03 route/history investigation and measured-source performance improvements, F06 completion summary and rating/home return, F02 trips/active-trip/chat/support layout and keyboard.
Owned: features/trips/**, features/completion/**, features/chat/**, features/support/**, features/active_trip/presentation/** EXCEPT active_matching_pulse.dart and active_search_journey.dart; matching tests and API docs if relevant; docs/engineering/deliveries/CF-TRIPS/**.
No changes to shared trip store/domain models, active_trip domain/data, ride_request or theme. Request dependencies from root.
Find actual prior route implementation/history and integrate only appropriate missing behavior. Preserve map state and narrow rebuilds where concrete. No claim of production 60fps or representative before/after without a real/profile device. Report unavailable hardware profiling and add reproducible profiling instructions. Never fabricate metrics.
Completion must show compact essentials, offer rating and explicit home path without losing saved trip/rating. Fix all reported clipping with dynamic text/layout and scrolling, not scaler caps.
