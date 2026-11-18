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

Role SUPERVISOR + DEVELOPER; root. Scope F01, F06 account card, F08 legal links, remaining F02, integration and F16 final performance/size audit and test build.
Owned: auth presentation input/footer and matching tests; settings coupon files/data/mock/mock_coupon_book.dart, settings_profile_section.dart; ride_coupon_field.dart, ride_coupon_picker.dart; shared focused coupon/phone input components if needed; app/router (except delegated ride_journey_page.dart), DI/config/pubspec only as needed; task board/cards/generated l10n; final handoff.
Phone decision: separate fixed +963 country prefix; accept and normalize Arabic/Persian digits in local field, max10 local digits including optional leading0; 9 digits beginning9 or10 beginning09 verified using existing domain normalization via local prefix composition; preserve canonical Auth domain contract.
Reviewers assigned after committed deliveries, rotating independent owners in isolated review worktrees. Final integrate only reviewed SHAs, run format/analyze/test milestone, investigate baseline failures honestly; build/install/run on emulator using run-emu only.
F16: audit assets/dependencies and APK sizes with evidence; remove only proven unused items or regenerable outputs; no speculative deletion of docs/source. True device profiling remains an external limitation if only emulator available.
