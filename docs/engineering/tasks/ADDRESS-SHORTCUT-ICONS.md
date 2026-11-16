# ADDRESS-SHORTCUT-ICONS

- Owner: root / SUPERVISOR; INTEGRATED after READY → IMPLEMENTING, 2026-11-16.
- Baseline: `342c07e697186dd62e9e8160b07e1a576987fded` in the customer repository.
- Branch: `codex/reuse-address-shortcut-icons`.
- Scope: saved_address_shortcuts.dart and saved_address_picker.dart; reuse AddressVisualIcon for saved-address categories. No new assets, theme, localization, layout structure or selection behavior.
- References: the user's two screenshots showing the booking shortcuts and address category artwork; AGENTS.md and the portable task protocol. No missing design inputs.
- Acceptance: both compact booking shortcuts and saved-address list show each address's existing transparent category asset, at 30 logical pixels, using the existing semantics exclusion.
- Verification: format and focused analysis of the two touched widgets; broad tests/builds deferred under the user's iteration preference. No new tests for this reversible asset substitution.
- Synchronization: integrate into local customer main, then merge its commits into Ahmad's canonical repository without touching apps/driver. User authorized ongoing synchronization.

Actual checks: Dart format: 2 files, no changes; focused flutter analyze --no-pub: no issues; git diff --check: pass. No rendered preview or full test/build run in this iteration.
