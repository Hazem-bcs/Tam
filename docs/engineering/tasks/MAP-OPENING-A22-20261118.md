# MAP-OPENING-A22-20261118

Role: SUPERVISOR + DEVELOPER, root; READY → IMPLEMENTING.
Baseline: 72bd1424847e524144f837b31b5f860448e220a7.
Branch: codex/map-opening-a22-20261118; existing customer-feedback-integration worktree.
Owned: vector_map_surface.dart, matching map tests, task/board/delivery evidence.
Read: AGENTS.md, portable task protocol, parallel-work, existing architecture/design/navigation guidance.
Goal: avoid native map initialization during route entrance animation, retaining mounted maps on reverse/cover/uncover; no arbitrary delay for initial or zero-transition routes.
User reproduction: Samsung A22 installed release, brief hitch opening any map screen, smooth afterward. APK hash matches delivered release; low_power=0 and thermal status=0. Cause not proven by controlled trace.
Scope excludes renderer/config/theme/auth/backend changes. Mock contracts unchanged.
Verification: route lifecycle + native map tests, format/analyze/full tests (inherited failures documented), ARM64 release/install. Real improvement needs physical comparison; widget tests cannot prove frame-rate improvement.
No push/main/Actions. Existing test failure artifacts preserved. Untracked screenshot backed up at /tmp/tam-map-opening-preserved-dark-banner-20261118.png before switching (tracked copy now present).
