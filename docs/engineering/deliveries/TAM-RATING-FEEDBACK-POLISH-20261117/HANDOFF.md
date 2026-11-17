# TAM — Trip-rating quick feedback polish

Baseline: 9c963cbc6ba928c32ae892bda19c39e97202a493
Branch: codex/tam-rating-feedback-polish-20261117

## Scope
Only the quick-feedback heading and option compactness within trip-completion rating.
The old technical heading was replaced with a context-sensitive question:
- ar positive (4–5 stars): ما الذي أعجبك في الرحلة؟
- ar negative (1–3 stars): ما الذي يمكن تحسينه؟
- The heading has a small RTL section icon and an unobtrusive optional label.
- The three anchored option cards remain fixed-position when switching rating sentiment; option icon size and vertical space were modestly refined.
- Reduced-motion setting respected by the heading transition.
- English localization included.
- No domain, API, submit semantics, or other-feature changes.

## Verification
- Localization source synchronization and Flutter gen-l10n completed.
- Flutter analyze: no issues.
- Flutter test test/features/completion: 57 tests passed.
- Two Arabic 390x844 Flutter widget screenshot captures included in this directory (not emulator images).
- No Android build or emulator deployment performed.
- No merge to main; source branch is ready for review.
