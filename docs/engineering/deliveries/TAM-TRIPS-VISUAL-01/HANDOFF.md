# TAM-TRIPS-VISUAL-01 — handoff (phase-two UI)

- Task and role: TAM-TRIPS-VISUAL-01 / DEVELOPER, direct user-directed visual improvement of Trips.
- Source reference: image sent in chat, Arabic "نشاطي" screen with active ride and grouped history.
- Baseline: `bfebc0e11f7ee14b41a1858642116331624d6616`.
- Implementation: `codex/tam-trips-visual-20261113`; worktree `/home/hazem/projects/tam-trips-visual`.
- Scope owned: customer Trips presentation/widgets/pages, feature-owned Arabic/English ARB fragments, feature tests and this handoff. **No global theme, router, auth, API or DI changes.**

## Result

- Replaced the plain filter-chip list with the reference's activity header, notifications link and trips/shopping/food tabs. Shopping/food explicitly display "Soon" without pretending to work.
- Preserved all four list filters using the header popup, including the Cubit's existing repository-backed loading, pagination, refresh, error/empty states and session-safe data flow.
- Highlighted actual active rides with their route, current status and follow action pointing at the existing active-trip route.
- Grouped historical rides by Today, Yesterday and localized older dates; kept completed/cancelled labels and the recorded price (no invented discounts or zero fares).
- Implemented a vertical dotted route motif, compact history cards and a 3-item activity bottom nav, using semantic ambient theme colors and responsive layout.
- Added ARB keys to Trips-only localization fragments. Per AGENTS.md generated `lib/l10n/app_*.arb` and `app_localizations*.dart` are local sync outputs, **not committed by the feature author**; supervisor should regenerate and commit these at integration.
- Added an Arabic 390dp screenshot golden for layout regression, plus updates to filter/navigation tests.

## Verification — local ROG Flutter environment

- `python3 scripts/dev/sync_feature_l10n.py`: passed.
- `flutter gen-l10n`: passed.
- `dart format --output=none --set-exit-if-changed lib test`: 369 files, 0 changes, passed.
- `flutter analyze --no-pub`: no issues found.
- `flutter test --no-pub`: **680 tests passed**.
- `flutter test --no-pub --update-goldens test/features/trips/trips_activity_visual_test.dart`: passed, produced layout golden.
- Real Android screenshot/pixel comparison: **NOT RUN**. Another `flutter run` session was already using emulator-5554, so it was left undisturbed. Flutter test's default Ahem font renders Arabic text as placeholders in the golden; it checks layout, not the final device typography.

## Integration notes / visual follow-up

- Cherry-pick this feature commit onto the approved integration branch **after** the ongoing Home rebuild is integrated; don't overwrite its uncommitted changes.
- Re-run localization sync and generation during integration; retest the combined navigation/theme and real Android Arabic screenshot against the user's reference.
- The reference shows an unread badge and discount strikethrough; these were deliberately not faked because this Trips UI does not own the global unread count or a discount field in the Trip model. Integrate them only when genuine shared data/contract is exposed.
- Current behavior is mock-backed unless the existing centralized data mode is changed by its owner. API mode still reports unavailable, with no fake fallback.

Verdict: **READY_FOR_REVIEW** — tests green, real-device visual review pending.
