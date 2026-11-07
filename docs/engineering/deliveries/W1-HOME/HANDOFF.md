# W1-HOME — Developer A handoff

**Status:** READY_FOR_REVIEW at the eventual HEAD of `codex/w1-home` (exact SHA reported after commit/push; this document is part of that commit).

## Assignment and isolation

- Task/role: W1-HOME / agent A (feature developer; **not independent reviewer**).
- Repository: `Hazem-bcs/Tam`, baseline tag `tam-w1-baseline-2026-11-07`.
- Verified immutable input SHA: `e570439c2593af610ed30b309c15e5cda1027da4`.
- Branch: `codex/w1-home`.
- Independent worktree: `/home/hazem/projects/tam-w1-home`, on user's ROG Ubuntu machine. Supervisor checkout `/home/hazem/projects/mashwar` was not modified or switched.
- Instructions read: `AGENTS.md`, `docs/engineering/agent-onboarding.md`, `agent-task-template.md`, W1-HOME card, task board (READY/assigned A), wave-one contracts/plan, mock/API policy, API handoff checklist, parallel-work guidance, Dart organization, navigation, design system, ADR 0001.
- Reference **actually viewed visually**: UI-04, `apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.02.59 PM (2).jpeg` (590×1278). Preserved header/notification, primary promotional card, services, smaller promotional/announcement card and bottom navigation; added a dedicated trip-entry affordance. Replaced imagery with theme-consistent local Material icons (authorized by task).

## Implemented feature and owned files

- `apps/customer/lib/features/home/home_entry.dart`: composes the correct Repository per centrally supplied `FeatureDataMode`, creates `HomeCubit` and keeps the public `HomePage`. Signature unchanged; Auth is not changed.
- `domain/entities/home_content.dart`, `domain/repositories/home_repository.dart`: immutable domain content, typed errors and repository boundary.
- `data/home_content_mapper.dart`: strict v1 decoder; checks localized strings, required arrays, unique IDs, supported enum actions, availability consistency; never opens arbitrary route strings.
- `data/mock/home_fixtures.dart` and `mock_home_repository.dart`: deterministic success, empty, offline cases with optional latency. Fixtures match backend examples.
- `data/unavailable_home_repository.dart`: API mode returns typed `SERVICE_UNAVAILABLE`, no live HTTP and **no mock fallback**.
- `presentation/bloc/home_cubit.dart`: loading → ready/empty/error plus manual retry; safe after closing.
- `presentation/pages/home_page.dart` and `presentation/widgets/`: greeting/local phone, notification route (no fabricated count), hero, trip-entry card when ride is available, service grid (food/shopping clearly «قريبًا», not clickable), announcement, existing logout callback, bottom links through `CustomerNavigation`.
- `l10n/app_ar.arb`, `l10n/app_en.arb`: owned fragment keys only, with `home` prefix. Service names are app-localized; editorial promotional copy comes from bilingual domain data.
- `apps/customer/test/features/home/`: repository/fixture consistency and hostile action decoding, Cubit states/retry, navigation callbacks, language cases, empty/offline/API failure, 320/390/800 dp ×2 text scaling, local screenshot capture harness.
- `docs/api/home/`: `README.ar.md`, `home-v1.md`, `home-v1.postman_collection.json` (Postman v2.1) and full success/empty/503/429 examples.
- `docs/engineering/deliveries/W1-HOME/`: this handoff and screenshots (see below).

## Rendering and screenshot evidence

- Screenshot environment: Flutter **headless widget rendering on Ubuntu**, not Android emulator/device. Captures use local host Noto Sans Arabic font + Flutter MaterialIcons to avoid the default Ahem squares in widget-test goldens; no font files committed or delivered.
- Capture command: from `apps/customer`, `flutter test --no-pub --dart-define=CAPTURE_HOME_GOLDENS=true --update-goldens test/features/home/home_visual_test.dart`; copy generated PNGs to `docs/engineering/deliveries/W1-HOME/`.
- Reviewed actual rendered `home-ar-390-x1.png`, after fixing screenshot-specific fonts and wrapping; also generated:
  - `home-ar-320-x2.png` — narrow Arabic/2x text.
  - `home-ar-390-x1.png` — Arabic phone.
  - `home-en-390-x1.png` — English phone.
  - `home-ar-800-x1.png` — tablet width.
- Device emulator was already running and may be in use by another agent; **did not start, restart or use it**, respecting the coordination rule. No Android build.

## Verification, actual commands/results

1. `python3 scripts/dev/sync_feature_l10n.py` — **passed**.
2. `flutter pub get --offline` (inside own worktree only) — **passed**.
3. `flutter gen-l10n` — **passed**.
4. `dart format lib/features/home test/features/home` — applied locally; final `dart format --output=none --set-exit-if-changed lib test` — **passed (0 changed)**.
5. `flutter analyze --no-pub` — **passed; no issues found** after removing three unused imports.
6. `flutter test --no-pub test/features/home` — **19 tests passed** (includes local visual layout tests; capture-only path skipped during normal runs).
7. `flutter test --no-pub` — **155 tests passed** including existing Auth/navigation tests.
8. `flutter test --no-pub --dart-define=CAPTURE_HOME_GOLDENS=true --update-goldens test/features/home/home_visual_test.dart` — **4 captures passed**, PNGs saved.
9. Parsed `docs/api/home/**/*.json` via Python `json`; checked Postman `info.schema` v2.1, GET method, and decoded all saved response bodies — **passed**. Flutter tests assert exact match of success/empty example JSON to mock fixtures.
10. `git diff --check` — run before commit.

**Not run / limitations:** No live API endpoint exists; Postman collection was structurally verified, not imported into Postman UI or executed against a live service. No physical Android/iOS validation; screenshots are widget renderings rather than device screenshots. Flutter test screenshot capture uses optional host-specific font files and should be rerun on a similarly provisioned host if needed.

## Contract and integration boundaries

- `GET /api/v1/home` is a **proposal**, not a deployed server. Public read-only, `data` for success, localized `error` for failure, typed constraints, no pagination, no mutations, no personal info/quotes/trips/notification count.
- Active default `HOME_DATA_MODE=mock`; `api` explicitly unavailable until supervisor integrates real backend adapter.
- Home navigation delegates to central routes. It creates no trips, route strings, fake Auth session, location guesses or unrelated feature screen.
- Only feature-owned ARB fragments are part of this commit. **Supervisor action required:** run `scripts/dev/sync_feature_l10n.py` and `flutter gen-l10n` during integration, and commit generated shared `lib/l10n` artifacts; they remain dirty **locally but unstaged** in this worktree.
- Future integration with owner D: connect notifications unread count to D's real source if desired; no fixed badge added by A.
- No changes requested in app/router, app/theme, shared, Auth, root tests, pubspec or task board.
- Review should inspect exact final pushed SHA. Freeze this branch until supervisor/reviewer feedback.

## Verdict

**READY_FOR_REVIEW** (developer self-check only, not independent approval). Feature is mocked for development; it is **not** production-booking or backend release readiness.
