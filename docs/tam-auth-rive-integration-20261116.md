# TAM auth mascot — Rive integration (2026-11-16)

## Scope
Selective integration into the customer app's `main` worktree. The old auth-reference branch is not merged wholesale; no changes to trip, map, home, settings, or notification implementations were copied from it.

- `apps/customer/assets/animations/tam_mascot_auth.riv` is the **real animated** Rive asset (approximately 1.6 MB).
- `AuthRiveMascot` loads it once per mounted widget; Rive renders the wave, autonomous idle, eyelid and posture animations.
- `phoneFocused` and bound `gazeX`/`gazeY` react to the phone/OTP caret; Flutter eases numeric gaze changes over 260 ms only when the caret moves.
- Playback pauses when the app isn't resumed or the route has its ticker disabled. Loading, controller and listeners are disposed on unmount. The mascot is wrapped in a repaint boundary and does not handle tap gestures.
- The keyboard no longer compresses the header on focus; the form scrolls when required. Colors are from the application's ambient `ColorScheme`.

## Local editable source
The Rive source project with editable artboard, independent shoulder/wrist rig, images and rebuild script lives at:

`~/projects/tam-mascot-performance-rig-v1` (local Git commit `fa2c11e`).

The prior experimental prototype remains at `~/projects/tam-mascot-auth-life-v2`. These are **separate local Git repositories**; only the exported `.riv` is in the customer app Git repository. Keep the original Rive source project for future animation changes.

## Tests and build prerequisites
- `flutter pub get --offline` succeeded using existing packages and updated `pubspec.lock` with Rive 0.14.11.
- `flutter analyze --no-pub lib/features/auth test/features/auth`: zero issues.
- `FLUTTER_TEST=1 flutter test --no-pub test/features/auth`: **73 tests passed** (including the updated account/settings sign-out route, OTP, keyboard, and caret behavior).
- The full-app `flutter analyze` surfaced 45 diagnostics in non-auth areas of the baseline; this merge did not attempt to change those unrelated files.
- For Linux headless Flutter tests with Rive Native, the cached library should be present as `apps/customer/linux/bin/lib/debug_shared/librive_native.so`. The temporary local symlink used during the verification was intentionally removed from `main`; future CI runners need their own Rive Native setup. Do not commit a machine-specific symlink.
- Android CPU/GPU load and frame pacing **have not yet been measured** on a physical device; the emulator was unavailable during final merge. Rive's autonomous idle continues animating while the auth route is visible and resumed.

## Remaining design work
The new 2D rig coordinates shoulders and wrists more naturally; it still uses fixed open-palm gloves. A professional finish needs separately drawn relaxed/waving hands, improved cuff joins, refined eyelids and reduced visual artifacts on close inspection. The auth page should also be reviewed on a physical device with a profile/release build.

No backend OTP logic, billing, app navigation outside auth test fixes, or network behavior was changed.
