# TAM-ACCOUNT-HUB-01 — Account Center / settings visual rebuild

**Role:** Developer (assistant under user's explicit authorization on 16 Nov 2026)
**Branch/worktree:** codex/tam-account-hub-v1-20261116 / /home/hazem/projects/tam-account-hub-v1
**Baseline:** 107497f1df22e8a9d09d52756093edd767c85c85 (current local main at worktree creation)
**Owned:** apps/customer/lib/features/settings/presentation/**, apps/customer/lib/features/settings/l10n/**, associated settings tests, this task/handoff, and the new settings-owned copy of the approved static mascot asset.
**Shared files coordinated:** only localization app_ar/app_en.arb and generated localization Dart necessary for new copy. No theme/router/DI/Auth/Rive modifications. No push/merge/CI.

## Required source & visual intent
- Actual screenshots supplied by user (2026-11-16): large mock profile card, technical notification copy, ungrouped links and visually heavy bottom nav.
- Prior generated concept board: calm ivory account hub, compact mascot in welcome, unified rows/sections, local language selection, explicit destructive account section.
- AGENTS.md, docs/engineering/{agent-task-template,parallel-work,design-system,navigation,working-agreement}.md read as prerequisites.
- Model is currently mock-backed, Auth guest/localAccess must never be presented as server-verified account. All data/state remains in SettingsCubit.

## Observable acceptance
1. Real Flutter Account screen markedly different from old screenshot: light welcome with official TAM mascot, concise profile data, coherent preferences and support groups, distinct danger action and logout.
2. Settings profile edit and language selection are real interactive surfaces, with existing focus and unsaved discard behavior maintained.
3. All navigation callbacks, mock disclosure, saved preferences, timeout/error/retry and feature permissions preserved; no new unsupported backend operations.
4. Screens render in Arabic/English 320dp/390dp/800dp including 2× text and keyboard without overflow; respect contrast/RTL/reduced motion.
5. Settings suite, analyzer, format and full suite reported accurately; capture real Flutter rendered screenshots if feasible.
6. Other feature-owned destinations (addresses, support, account management and legal) are *linked* but not redesigned in this slice; no competing writes to those features.

**Delivery status:** READY_FOR_REVIEW; visual/independent review pending.
