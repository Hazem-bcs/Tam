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

## Follow-up: expressive hands V4 (2026-11-17)

The fixed open-palm limitation above was addressed locally by TAM-MASCOT-HANDS-V4.
Use the current editable worktree `/home/hazem/projects/tam-hand-worktrees/motion`,
branch `codex/mascot-hands-motion`, source commit `62f452e47db20fbd4ebe412fa312f06d9ebf6415`.
The original source repository remains preserved at its prior revision; its old
export must not replace V4. Current app asset SHA256:
`e89405c26503646ec938fb0a5cf6953eab31da8628a6bd2fe2a14c9061afb296`.
New relaxed/sad/happy/wave art, connected arms, static reduced-motion states and
Flutter lifecycle checks are integrated on `codex/mascot-hands-v4`, not merged to main.
See [the current delivery](engineering/deliveries/TAM-MASCOT-HANDS-V4/REPORT.ar.md)
for exact SHAs, rendered evidence, actual verification and remaining eyelid/profile limits.

## Shared Idle V5 (2026-11-17)

Latest idle source: `/home/hazem/projects/tam-hand-worktrees/idle-v5`,
commit `5177b451d0f31fba77cf80842ba485f8b1cd05ae`. The approved V4 source
worktree remains preserved. App branch `codex/mascot-idle-v5` integrates a
persistent16-second idle base, with existing event tracks/artwork preserved.
App/export SHA256 `47af1098b9837f110aad537cd38b1ee31eb56bebee14a46da68fe0d2378d2802`.
See [Idle V5 delivery](engineering/deliveries/TAM-SHARED-IDLE-V5/REPORT.ar.md)
for the30fps preview, runtime phase/anchor test, exact verification and limits.
