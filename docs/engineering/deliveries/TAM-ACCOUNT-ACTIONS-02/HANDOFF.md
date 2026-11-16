# TAM-ACCOUNT-ACTIONS-02 — Account preferences & footer polish

Date: 2026-11-16. Baseline main SHA: a351c036d1eae05ca1b5e112e2fe4f4d676c8abf. Branch: codex/tam-account-actions-polish-20261116. Status: READY_FOR_USER_VISUAL_REVIEW; not merged, pushed or installed on emulator.

## User request
The user supplied a screenshot showing the save-preferences button after changing a notification toggle, and requested no extra save button, a prettier About-this-version presentation, and a subtler logout action.

## Changes
- Added SettingsCubit.updateNotificationsImmediately to optimistically update the switch, call the existing savePreferences contract immediately, and restore the stored value if the save fails. The UI shows an error Snackbar on failure, no redundant success Snackbar, and disables the switch while saving. Existing savePreferences direct callers and name edits are unaffected. The development repository remains mock-backed and in-memory; do not claim backend persistence.
- Replaced the full-width outlined logout button with a quiet 48dp-minimum text/icon action; original confirmation, loading and error handling preserved.
- Replaced a large About-this-version ExpansionTile with a slim footer text action below a divider. It opens an accessible bottom sheet preserving the original mock-development disclosure. No invented version number, new assets or dependencies.
- No changes to auth, maps, router, Rive, central theme or other features. UI and state changes localized to settings.

## Visual evidence
Actual Flutter widget-test screenshots (NOT Android emulator), in /home/hazem/Desktop/TAM_Account_Actions_Polish_20261116:
- TAM-Settings-Footer-Before-After.png: before/after lower Account screen.
- AFTER-about-version-sheet.png: About dialog.
- AFTER-actions-390.png, AFTER-account-390.png, AFTER-account-320-large.png, AFTER-account-en-800.png.

## Verification
- Flutter pub get --offline: PASS.
- dart format --output=none --set-exit-if-changed lib test: PASS (450 files, 0 changes).
- flutter analyze --no-pub lib/features/settings test/features/settings: PASS (0 issues).
- flutter test --no-pub test/features/settings: PASS, 47/47 tests.
- flutter test --no-pub --update-goldens --dart-define=CAPTURE_SETTINGS_GOLDENS=true test/features/settings/settings_page_test.dart: PASS, 20/20 screenshot-enabled tests.
- 320dp Arabic at 2x text scaling: About sheet checked for layout exceptions.
- Full-project flutter analyze: EXIT 1, 42 info-level findings in other files; /tmp/tam_actions_full_analyze.log.
- Full-project flutter test: 701 passed / 96 failed in other features and integration; full suite NOT green. No exhaustive baseline comparison, do not assert all pre-existing. /tmp/tam_actions_full_test.log.

## Next gate
User reviews screenshots and behavior. If approved, independently review the exact commit and merge into the then-current main, then verify on Android emulator when appropriate. Do not push unprompted.
