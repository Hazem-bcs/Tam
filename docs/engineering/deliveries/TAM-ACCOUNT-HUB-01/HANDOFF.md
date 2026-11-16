# TAM-ACCOUNT-HUB-01 — Flutter visual redesign / handoff

Date: 2026-11-16
Task: Account Hub (settings root and embedded interactions)
Role: Developer
Input baseline: 107497f1df22e8a9d09d52756093edd767c85c85 (latest local main at branch creation)
Worktree: /home/hazem/projects/tam-account-hub-v1
Branch: codex/tam-account-hub-v1-20261116
Status: READY_FOR_REVIEW; no independent approval, no main merge, no push.

## Result

- An ivory/rose, app-themed welcome surface now uses the *original* TAM pin mascot as a static, lossless 234KB WebP. No new Rive controller, model editing or animation code was introduced. This is an integration slot, not a second mascot workflow.
- A separate account identity panel shows the real supplied phone, or an explicit guest label if the phone is absent; it does not claim SMS verification. Name editing remains a working SettingsCubit operation, inline and keyboard-safe, with validation, failure, discard and save state intact.
- Compact group surfaces replace scattered lists: in-app notification setting and language; addresses and phone change; help/terms/privacy; separate delete action; standalone sign out.
- Notification helper copy explicitly says *in-app only, not push*. The longer simulation disclosure remains accessible under an “About this version” expansion instead of being confused with normal settings.
- Language picker is a dedicated, visual bottom sheet with selected state and existing session-local AppLocaleController. No new routes or fake backend features.
- The latest central app shell owns bottom navigation; this feature does not duplicate it, and its screen-level screenshot excludes the surrounding shell navigation.

## Owned code

- settings/presentation/pages/settings_page.dart (AppBar and language picker wiring)
- settings/presentation/widgets/settings_profile_section.dart, settings_preferences_section.dart, settings_account_links.dart
- settings/presentation/widgets/settings_group.dart, settings_action_tile.dart, settings_language_sheet.dart, settings_mascot.dart
- settings/l10n/app_ar.arb, app_en.arb; synchronized central app ARB and generated localization Dart **in this isolated worktree only**, as a coordinated shared-input update.
- apps/customer/assets/images/tam_account_mascot.webp, sourced from prior user's approved transparent character, not an image of an entire UI screen.
- settings feature widget tests and new golden screenshots.

## Verified screenshots (Flutter widget-test rendering with Arabic/Latin fonts loaded)

- screenshots/TAM-Account-Before-After.png — compares original baseline vs new 390dp Arabic Account screen.
- screenshots/settings_ar_390.png — root Account page.
- screenshots/settings_ar_actions_scrolled.png — support/legal/account deletion, version disclosure and logout below the fold.
- screenshots/settings_ar_language_sheet.png — open localized language chooser.
- screenshots/settings_ar_profile_editor.png — edit-name state.
- screenshots/settings_ar_320_large.png — Arabic at 320dp, 2× text scaling.
- screenshots/settings_en_800.png — English tablet.

**These are genuine Flutter-rendered widget-test captures, not screenshots from the Android emulator.** They exclude the central shell's bottom navigation and aren't proof of Android frame pacing. Future emulator review must inspect tap areas, navigation states and the final composed shell at real DPI.

## Testing

- `flutter pub get --offline`: PASS.
- `dart format --output=none --set-exit-if-changed lib test`: PASS (0 files changed).
- `flutter analyze --no-pub lib/features/settings/presentation test/features/settings`: PASS (0 issues).
- Whole project `flutter analyze --no-pub`: currently emits 4 **info-level** findings in untouched ride_request files; no settings findings.
- `flutter test --no-pub test/features/settings`: PASS, 37 tests (including new design baselines skipped in normal mode).
- `flutter test --no-pub --update-goldens --dart-define=CAPTURE_SETTINGS_GOLDENS=true test/features/settings/settings_page_test.dart`: PASS, screenshots refreshed with app-consistent font fallback.
- `scripts/dev/sync_feature_l10n.py --check`: PASS.
- Full project `flutter test --no-pub`: **737 passed, 26 failed**. Exact output `/tmp/tam_account_final_full_tests.log`. No failure occurs in `test/features/settings/**`. Failures include booking, places/maps, session, active trips, chat, home and 2 outdated Auth sign-out tests. The Auth tests specifically still expect immediate Home `Sign out` rather than the current Account tab and logout-confirmation flow (`test/features/auth/auth_flow_test.dart:59–63`); these weren't modified because Auth is separately owned. Other failures were not independently baseline-compared. Do not call full-suite status green.

## Known limits

- Linked destination pages (addresses, support, account management, terms, privacy) are owned by other features. They were deliberately not visually rewritten in this task; routing remains unchanged.
- With mock data or temporary local access, a displayed number is a session value, not a claim of server verification; account deletion and phone change retain their existing route guards and behaviors.
- The static mascot is intentionally awaiting future shared Rive work; no per-page Rive customization was added.
- Real-device performance, contrast/assistive-technology manual audit, and independent code/visual review remain outstanding.
- No build/APK install or takeover of the already running Android emulator; user may have other concurrent work there.

## Next gate

Visually review the first Account Hub screenshot set with the user. Then review exact changes on their SHA in a separate worktree; once approved, merge into the current integration branch and run integration tests. Extend the same approved design language to addresses/support/account-management *with their owners* in separate tasks.
