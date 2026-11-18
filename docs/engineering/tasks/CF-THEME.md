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

Scope F07: central compact typography, persisted font preference respecting system scaler, dark/light/system (default system), Arabic default independent of device and persisted selected language. Preserve/migrate existing preferences.
Owned: lib/app/theme/**, lib/app/locale/**, new lib/app/preferences/**, lib/app/app.dart, features/settings except coupon-related files and settings_profile_section.dart; matching tests; feature settings ARB fragments; docs/engineering/deliveries/CF-THEME/**. Paths relative to apps/customer unless docs. No pubspec/config/router edits without request.
Single delegated writer of these shared theme/app files. Avoid overwriting account/coupon changes owned by root.
Acceptance: restoration, system theme changes, failed/malformed storage handled, no text scaling cap; central dark semantic roles; default slightly smaller readable text. Local preferences require no invented endpoints.
