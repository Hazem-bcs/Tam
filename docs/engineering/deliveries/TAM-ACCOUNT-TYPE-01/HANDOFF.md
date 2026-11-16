# TAM-ACCOUNT-TYPE-01 — Account typography refinement

**Date:** 2026-11-16
**Role:** Developer / waiting for user visual evaluation
**Baseline:** `342c07e697186dd62e9e8160b07e1a576987fded` (the user's current local main at start)
**Branch:** `codex/tam-account-typography-refinement-20261116`
**Worktree:** `/home/hazem/projects/tam-account-typography-refinement-20261116`
**Outcome:** READY_FOR_USER_REVIEW. Not merged, not pushed, not installed to Android emulator.

## Problem statement and design decision

The user's two account-screen screenshots show weak differentiation between section names (18sp bold) and action titles (18sp semi-bold), alongside small supporting text and mixed typography. The existing main app ships NotoSansArabic Regular/Bold and NotoSans Latin Regular/Bold, already used by Home, but Account inherited platform fallback fonts.

The design pass conserves the existing layout, warm ivory/burgundy palette, original brand mascot, navigation and all behavior. It focuses on professional information hierarchy without inventing a second brand or adding decorative image assets.

- Added `AppTypography.account` as an **opt-in central typography scheme**, applied only via `AppTheme.account` in SettingsEntry. Other feature screens and the shared `AppTheme.light` remain unchanged. Uses the fonts already bundled with the app; **no new font download or asset size**.
- Action row titles: **16sp, bold 700**, dark onSurface. Supporting text: **14sp, regular 400**, onSurfaceVariant. Preserves full text scaling and RTL; no truncation or capped font size.
- Section headers: **15sp, bold 700**, muted onSurfaceVariant, discreet 3px primary vertical visual marker. This creates an information category layer separate from the 16sp actionable row labels.
- Account heading: **22sp, 700**; names/headings use shipped brand fonts, no synthetic 800 weight. Welcome copy and guest profile use the same text hierarchy.
- Reduced card divider and icon well contrast slightly without altering semantic colors or touch targets.
- Guest case no longer repeats `No phone number for this session` after already showing the guest explanation; actual phone values still display unchanged when present.
- No change to SettingsCubit, settings preferences save, profile validation, navigation guards, logout, Auth, Rive, business/domain code or external settings pages.

## Visual review

All below are actual **Flutter widget-test renderer** captures, **not Android emulator screenshots**.
Review directory on ROG:
`/home/hazem/Desktop/TAM_Account_Typography_Review_20261116/`

Priority review images:
- `TAM-Account-Typography-Before-After-Guest.png` — previous Account vs updated Account and updated Guest.
- `TAM-Account-Actions-Before-After.png` — lower screen comparison.
- `AFTER-account-320-large.png` — Arabic at 320dp and 2x accessibility text scale.
- `AFTER-account-800-English.png` — 800dp LTR.
- `AFTER-edit-name-390.png` — expanded inline profile editor.

Snapshot goldens maintained in `apps/customer/test/features/settings/goldens/`, including newly added `settings_ar_guest_390.png`.
Visual inspection checked 390dp and compact 320dp Arabic 2x, LTR tablet, guest and profile edit. No Android run; Android emulator belongs to the integrated main and the device storage is limited.

## Verification

- `flutter pub get --offline`: PASS.
- `dart format --output=none --set-exit-if-changed lib test`: PASS, 449 files, 0 changed.
- `flutter analyze --no-pub lib/app/theme/app_theme.dart lib/app/theme/app_typography.dart lib/features/settings test/features/settings`: PASS, **0 issues**.
- `flutter test --no-pub test/features/settings`: PASS, **40/40**.
- `flutter test --no-pub --update-goldens --dart-define=CAPTURE_SETTINGS_GOLDENS=true test/features/settings/settings_page_test.dart`: PASS; 15 tests (capture mode), actual bundled font families loaded into renderer.
- Two added focused tests: checks section/action/supporting type sizes, font family and color semantic roles; checks no duplicate missing-phone warning for guest. Extended actual SettingsEntry route test checks brand font is scoped, palette unchanged, and the global light theme does not adopt account-only type.
- `flutter analyze --no-pub` for entire project: EXIT 1 due to **42 info-level lint findings** in files outside the scoped change. No scoped findings; log `/tmp/tam_type_full_analyze.log`.
- `flutter test --no-pub` full project: **692 passed, 96 failed** (status NOT GREEN), with no failures in `test/features/settings/**`. Failures in Auth, maps, integration, active trip, etc. Root causes were not exhaustively baseline-compared; do not claim they all predate this branch. Log: `/tmp/tam_type_full_test.log`.

## Review gate

1. User evaluates before/after images and specific readability improvements (not a redesigned home/nav).
2. If accepted, perform an independent review on the exact commit SHA and test current main integration.
3. Only after explicit approval merge locally and install/test Android if there is adequate disk space, then request user visual confirmation on emulator. Do not push automatically.
