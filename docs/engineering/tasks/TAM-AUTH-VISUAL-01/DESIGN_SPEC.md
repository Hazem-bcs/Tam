# TAM Auth — The Journey Begins
**Art direction and Flutter behavior specification — V1 / 13 Nov 2026**

## Reference and product truth
- Company UI-06: legacy “مشوار” login/register image, including optional name entry.
- Company UI-07: OTP verification reference with 6 slots.
- Actual Flutter: PhoneAuthPage handles returning and new users through one phone-based flow; OtpAuthPage only appears after a valid challenge; AuthStatusPage restores sessions.
- AuthCubit.requestOtp() accepts the phone number only; AuthCubit.verifyOtp() determines isNewUser afterward. No backend name-registration contract exists. Do not pretend to save a name.
- Temporary phone mode is unverified localAccess; do not suggest an SMS was sent or a backend session was created.

## Visual direction — The Journey Begins
A cohesive narrative from phone number to real verification, using a transportation metaphor only as abstract illustration.

1. **Immersive upper scene:** primary-color background, centered TAM identity, quiet cropped circular forms, pin/route illustration on phone entry and message/check illustration on OTP.
2. **Path illustration:** gently curved dotted line from one map pin to another. Draws once via CustomPainter/PathMetric and never suggests geographic truth.
3. **Overlapping content surface:** bright surfaceContainerLowest card overlapping upper scene by 24dp, soft boundary, 24dp corner radius and subtle brand accent.
4. **Typography:** bold start-aligned Arabic headline, body text with onSurfaceVariant, clear label hierarchy and touch targets >=48dp; maximum inner content width 432dp even on tablets.
5. **Phone:** +963 remains an LTR prefix, real native editable field and existing validation, autofill, paste, localized error and retry logic.
6. **CTA/guest:** existing TamButton.primary labels and busy/disabled states, with guest path preserved. No fake sign-in success.
7. **OTP:** tinted phone-number panel with LTR E.164 number and editable action; six visual slots backed by a single native TextField for accessibility, paste and SMS autofill.
8. **OTP motion:** active/error border 160ms, inserted digit fades/scales in 160ms, button/resend/attempts driven by actual AuthCubit state.

## Motion tokens (all honor reduced-motion preference)
- Hero first entrance: 520ms easeOutCubic fade+small translate, once.
- Route line drawing: 880ms easeOutCubic, once.
- White content card: 340ms easeOutCubic fade and 16dp translate, once.
- OTP digit insertion: 160ms scale 0.78→1 and fade.
- No perpetual glowing loops, no timer-driven fake authentication progress.

## Responsive
- Brand scene 246dp normal, 143dp compact when available height below 610dp or large text.
- Scroll content responds to SafeArea/keyboard, never caps system text scale.
- 320dp, 390dp, 430dp, tablet and landscape need overflow-free forms and working focus.
- RTL Arabic and LTR phone/OTP islands; screen readers get one logical OTP input.

## Registration — deferred functional boundary
The company's separate name/registration page is a visual reference only at present. The app's current real Auth API is unified: phone first, then OTP, and the server decides new/existing user afterward. A name field must only appear after a verified profile-completion step or an approved registration contract. Do not add a fake name field or route now.

## Changed architecture
- NEW auth_brand_hero.dart — visual hero and safe back control.
- NEW auth_scaffold.dart — responsive scrollable composition.
- UPDATED auth_artwork.dart — full-width one-shot route painter and inverted on-primary drawing.
- UPDATED auth_otp_input.dart — per-digit entrance while preserving native field semantics.
- UPDATED otp_auth_page.dart — phone summary; original OTP retry/expiry/validation unchanged.
- UPDATED auth_widgets.dart — old monolithic scaffold extracted; error notice/countdown retained.
- UPDATED phone/OTP/status pages — import new scaffold.
- NEW auth_visual_shell_test.dart — route-width/brand/320dp layout regression coverage.

## Verification and known limits
- Focused Auth tests and static analysis performed; final full suite results in handoff document.
- No Android emulator takeover: another worktree/agent currently works on Home.
- Flutter widget-test snapshots used default block-glyph Ahem font, which cannot truthfully showcase Arabic; these draft previews were removed. Real Android visual acceptance and profile-mode timings remain future independent QA.
- No changes to AuthCubit, Domain/Data, routes, localization, shared theme, contracts or app configuration.
