# TAM-ACCOUNT-TYPE-01 — Account Hub Typography & Visual Refinement

Role: Developer; explicitly user-assigned 2026-11-16. Supervisor review awaits user assessment.
Baseline: 342c07e697186dd62e9e8160b07e1a576987fded (local main)
Branch: codex/tam-account-typography-refinement-20261116
Worktree: /home/hazem/projects/tam-account-typography-refinement-20261116
Reference: two user screenshots of "حسابي" 2026-11-16 showing title / row / supporting-copy density, plus existing Flutter golden baselines in test/features/settings/goldens.
Read: AGENTS.md, docs/engineering/agent-task-template.md, parallel-work.md, working-agreement.md, design-system.md.
Goal: professionally distinguish section headings, primary row titles and readable secondary copy; use the project's bundled Arabic/Latin font specifically for Account while preserving its palette, app navigation, state, guest restrictions and behavior. Reduce duplicated guest status copy.
Scope: app/theme/app_theme.dart and app_typography.dart (central opt-in variant, no global theme mutation); settings_entry.dart; settings/presentation/{pages,widgets}; tests/features/settings and new delivery/task notes.
Excluded: other feature pages, domain/data, Auth, Rive, new font downloads, nonexisting API functionality, main Git modifications.
Acceptance: visually substantial improvement, explicit test of text hierarchy, RTL/LTR, 320dp 2x text and keyboard; Flutter snapshots before/after; no unrelated git changes; no push/merge/build heavy Android APK before user approval.
Reviewer status: READY_FOR_USER_REVIEW; not merged, independent review deferred until user approves visual direction.
