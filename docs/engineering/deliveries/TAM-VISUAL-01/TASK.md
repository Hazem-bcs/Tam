# TAM-VISUAL-01 — Phase 2 Home + Ride Visual Redesign
Role: Supervisor-directed developer (user authorized follow-up 2026-11-12).
Task status: READY_FOR_REVIEW on isolated worktree; visual approval pending.
Baseline: 3bbe8fe7caca1a24bdf36f6d6c7d6cd5da4e15b5
Branch: codex/tam-fluid-redesign-20261112
Worktree: /home/hazem/projects/tam-motion-vslice
Owned: `apps/customer/lib/features/home/presentation/**`, `apps/customer/lib/features/ride_request/presentation/**`, relevant tests under `apps/customer/test/features/home` and `apps/customer/test/features/ride_request`, this handoff directory.
Shared owner: Central AppTheme/AppConfig/ARB/router untouched unless separately authorized.
Goal: Make visibly different, polished, cohesive home/ride UI based on Fluid Continuity, retaining existing burgundy semantic theme, data flow, callbacks, accessible controls, responsive layouts, localized strings and system reduced-motion.
Reference: TAM Figma exploration https://www.figma.com/design/dW6LCuvdifCDLZp7bHQD0y (concept Fluid Continuity), prior screenshots from TAM-MOTION-01.
Excluded: domain/data, Auth, API, private tile configuration, backend, main branch, other computers, CI.
Data: Existing centrally injected mock/API repositories; no UI fixtures, fake routes or invented backend success.
Acceptance: Existing behavior and `home-*` keys and accessible taps unchanged; visible redesign in real Android app, evidence screenshots; verify format/analyze/full tests; 320dp/2x and English/tablet tests.
Environment: Local ROG Ubuntu 24.04, Flutter stable, existing Medium_Phone emulator. Do not relaunch emulator unnecessarily.
