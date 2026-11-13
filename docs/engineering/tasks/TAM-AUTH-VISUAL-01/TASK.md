# TAM-AUTH-VISUAL-01 — The Journey Begins / Auth Visual Rebuild

**User authorization:** 2026-11-13, user asked for a careful design and actual Flutter implementation of original UI-06 (login / sign up) and UI-07 (OTP), with original company screens as reference.
**Task owner:** Assistant acting as Flutter UI implementer.
**Branch:** codex/tam-auth-visual-20261113
**Isolated worktree:** /home/hazem/projects/tam-auth-visual-20261113
**Baseline:** bfebc0e11f7ee14b41a1858642116331624d6616
**Status:** READY_FOR_REVIEW / review not yet approved

## Sources and requirements
- Read AGENTS.md, docs/engineering/agent-task-template.md, parallel-work.md, design-system.md and navigation.md.
- Originals: apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.00 PM (1).jpeg (two phone screens); (2).jpeg (OTP).
- Existing AuthCubit/auth domain and existing auth widget tests are the behavioral contract.
- UI-06 has distinct login/register, but actual app has **one phone auth request** for new/existing users; registration name is NOT a supported auth request property. Do not fabricate name persistence or create a second backend request merely to copy a screenshot.
- Temporary phone entry may directly grant LOCAL ACCESS (not server authentication). The current guest and true OTP flows must remain intact.
- Original reference brand says “مشوار” but app brand is “تم”.

## Owned files
apps/customer/lib/features/auth/presentation/widgets/**
apps/customer/lib/features/auth/presentation/pages/{phone_auth_page.dart,otp_auth_page.dart}
apps/customer/test/features/auth/**
docs/engineering/tasks/TAM-AUTH-VISUAL-01/**
docs/engineering/deliveries/TAM-AUTH-VISUAL-01/**
The shared theme/ARB/router/DI/Domain/Data are supervisor-controlled; no edits to them without need/consent.

## Visual direction — “The Journey Begins”
- Upper primary-color brand scene with centred TAM identity and an abstract route/messaging illustration.
- Bright, overlapping content surface to ground readability and keep forms comfortably accessible on mobile.
- Arabic-native typographic hierarchy (large bold heading, readable smaller description); LTR digit islands.
- Elegant 1-shot path-drawing motion using CustomPainter/PathMetric, modest content reveal, 160–300 ms field/OTP state transitions; **no perpetual ambient animation**.
- Animated form response from existing AuthCubit failures/loading, never fake OTP success.
- Responsive compact mode when keyboard/large text/small height: shorten scene, scroll naturally, no fixed height panel, touch targets 48+.
- Minimum implementation in this phase: unified phone entry and OTP real flows. A separate name registration page stays **design-only/deferred** until authenticated profile/update contract is specified.
- Use ONLY ambient theme ColorScheme/textTheme, central spacing/radii; no new packages and no scattered palette constants.

## Acceptance
- Visibly changed auth scenes (not cosmetic adjustment), original appName “تم”, real phone contract intact, guest/localAccess works.
- Semantics, auto-fill, normalization of Arabic digits, timers, errors, resend, back edit, valid OTP remain intact.
- dart format, flutter analyze, widget/full tests; report genuine result.
- No push, merge, CI, remote other machines, or emulator takeover while Codex independently modifies Home.
- Deliver exact branch/SHA and a short visual/code audit, note any visual renders actually performed.
