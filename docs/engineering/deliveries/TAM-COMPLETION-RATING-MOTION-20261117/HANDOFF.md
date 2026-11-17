# TAM — Animated rating and stable feedback options

**Baseline:** ba357e2dc5b98df7a68bf27373ccc1a27de02905 (origin/main at task start)
**Branch:** codex/completion-rating-motion-20261117
**Scope:** Only completion rating presentation, new small vector assets and focused tests. No API/Domain changes and no main merge.

## UI improvements
- SVG gold beveled rating stars with outlined unselected counterparts.
- Short, staggered fill/scale/fade interactions and a subtle selected-star halo; never a looping animation.
- Haptic selection and support for reduced-motion accessibility preferences.
- Three anchored feedback cards with equal geometry; short label cross-fades instead of wrap changes when sentiment flips.
- Three columns on normal mobile widths; two columns for narrow phones / large text, stable within the device layout.
- Same existing submit, 500-code-point validation, retry, session and idempotency semantics.

## Verification
- flutter analyze --no-pub lib/features/completion test/features/completion
- flutter test --no-pub test/features/completion -r compact
- Both existing completion layout/accessibility tests and new steady-grid geometry tests.
- Captured with Flutter widget preview at 390×844 Arabic:
  - positive-ar-390.png: 4 stars selected, positive feedback.
  - critical-ar-390.png: 2 stars selected, critical feedback.
- These are rendered Flutter widget previews, not Android emulator captures.

## Integration
- Patch should be reviewed and applied to current main; do not overwrite other feature changes.
- No new localization keys, packages, routes, or shared-theme modifications.

## Final result
- Targeted Flutter static analysis: no issues.
- Focused completion suite: **57 tests passed**.
- Dart formatting and git diff whitespace checks: passed.
