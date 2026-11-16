# TAM-ACCOUNT-ACTIONS-02 — Account preferences & footer polish

Role: Developer / standalone user request 2026-11-16.
Baseline: current main at worktree creation.
Branch: codex/tam-account-actions-polish-20261116
Worktree: /home/hazem/projects/tam-account-actions-polish-20261116
User source: account screenshot uploaded 2026-11-16 15:07 displaying an unexpected save preferences button, plus requested improved version disclosure and sign-out.
Owned: apps/customer/lib/features/settings/presentation (widgets/pages/bloc), settings-specific tests, task and delivery documents. No shared theme/ARB/router/auth/Rive modified.
Acceptance:
- Tapping notification toggle saves immediately, no secondary Save button.
- Switch is temporarily disabled during saving; success is silent and failure rolls it back to persisted choice with a meaningful Snackbar. SettingsCubit retains explicit savePreferences for other existing clients.
- Version disclosure displayed as restrained footer info, opens a readable accessible modal containing the existing mock-development notice. Do not invent server-backed features or metadata version strings.
- Sign out presented as a quiet, appropriately sized action preserving confirmation and failure behavior.
- Arabic/English, RTL/LTR, 320dp 2× and 390dp, no overflow, tests & screenshot evidence.
- Keep diff scoped; do not merge, push, install APK or alter other agents' work without user approval.
