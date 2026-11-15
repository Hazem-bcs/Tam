# TAM-AUTH-VISUAL-01 — Flutter Auth Design Handoff

**Date:** 2026-11-13
**Task:** Flutter phone-entry / OTP visual redesign; user requested deep creative description and real code.
**Starting point:** bfebc0e11f7ee14b41a1858642116331624d6616
**Branch:** codex/tam-auth-visual-20261113
**Checkout:** /home/hazem/projects/tam-auth-visual-20261113
**Status:** READY_FOR_REVIEW — visual approval NOT granted.

## Creative direction
“The Journey Begins”: full primary-color brand scene, genuine Tam wordmark from localization, route/messaging illustration and a bright floating form surface. More structured and distinctive than the old flat centered form. Inspiration came from company references UI-06 and UI-07, not pixel copying. A one-shot route drawing and gentle form transitions are the focal animation; no infinite decorative rendering.

## Implementation / architecture
- New AuthBrandHero: branded immersive top, inverse primary-colored art, accessible back.
- New AuthScaffold: handles phone, OTP, session recovery; overlapping form surface; fully scrollable with keyboard and text scaling, tablet width limits.
- Route artwork: CustomPainter with actual path metrics, adequate width; animates one time, paints no fake route map.
- OTP: existing one native editable field controls six visual slots; per-digit 160ms fade/scale. Native SMS autofill, selection, clipboard, screen reader, attempt and expiry semantics remain.
- OTP phone E.164 number is displayed in a tinted card with real edit action; no new backend calls or artificial auth success.
- AuthCubit, domain and data contracts, auth routing, l10n, central ThemeData, package manifest and platform files unchanged. Guest and temporary localAccess behavior preserved.
- No separate registration/name flow implemented because backend phone request cannot store names. Server determines isNewUser only after verification.

## Accessibility and responsive
- Small/large screens and landscape with focused inputs, SafeArea/keyboard and scroll.
- Form-content width <=432 logical pixels at large viewports.
- Brand route width validated by a new visual-shell widget test.
- RTL label alignment, LTR phone/OTP input, system text scaling, reduced motion respected.

## Verification on current isolated worktree
- Dart format --output=none --set-exit-if-changed lib test: PASS.
- Flutter analyze --no-pub: PASS, 0 issues.
- Focused Auth suite: PASS, 68 tests.
- Full flutter test --no-pub: PASS, 681 tests (branch baseline differs from other parallel UI worktrees).
- No edits on original /home/hazem/projects/mashwar; no GitHub push or merge.

## Honest visual evidence limitations
- Did NOT take over Android emulator while the other Codex Home worktree was active.
- A standalone widget-test raster was attempted, but the Flutter test engine used square-glyph Ahem font. Those files are unsuitable as visual QA and were removed.
- Real-device screenshots and frame profiling, plus manual UX/art-direction sign-off, remain outstanding. Do not claim visual parity or production-ready UI.

## Next authorized review
1. Inspect real Android sign-in and OTP at 390dp Arabic & English, 320dp with keyboard/text scale, and tablet; record screenshots.
2. Critique artwork curve, title wrapping and card elevation/spacing; revise based on actual rendering.
3. Decide registration/profile completion contract before adding name fields.
4. If approved, integrate this isolated Auth SHA into a dedicated integration branch after assessing conflicts with Home, Trips and other concurrent worktrees.
