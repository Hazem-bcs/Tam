# W1-NOTIFICATIONS — Handoff to supervisor

**Task / role:** W1-NOTIFICATIONS / Feature owner D
**Baseline:** `tam-w1-baseline-2026-11-07` / `e570439c2593af610ed30b309c15e5cda1027da4`
**Branch:** `codex/w1-notifications`
**Isolated checkout:** `/home/hazem/projects/tam-w1-notifications`
**Remote:** `git@github.com:Hazem-bcs/Tam.git`
**Final SHA:** use the SHA of the branch head after committing this report.
**Verdict:** READY_FOR_REVIEW (independent review/integration pending).

## Context and scope
Read `AGENTS.md`, `agent-onboarding.md`, `W1-NOTIFICATIONS.md`, `wave-one-contracts.md`, `mock-api-policy.md`, `api-handoff-template.md`, `agent-task-template.md`, the task board, central navigation/theme conventions and existing entry contracts. Viewed original **UI-05** JPEG from `apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.02.59 PM.jpeg` (not merely its index). Implementation is confined to `apps/customer/lib/features/notifications/**`, `apps/customer/test/features/notifications/**`, `docs/api/notifications/**`, and this delivery folder.

## Implemented
- Client inbox with generated Arabic/English localization fragments, theme-based cards, date grouping, responsive list, loading/empty/error/retry, pull-to-refresh, incremental pagination and failure messaging.
- Typed domain notifications and targets; **only** `home`, `trips`, `trip` may navigate through `CustomerNavigation`. Unknown targets and missing `trip_id` show their text but do not navigate. The linked trip fixture ID is **`mock-history-001`**.
- Typed `NotificationsRepository` and `NotificationsUnreadCountSource` for shared badge source; unified mock repository maintains unread count, change stream, pagination and idempotent mark-read / mark-all. Failures leave read state unconfirmed; no negative/duplicate decrement.
- API-mode repository reports `SERVICE_UNAVAILABLE`; **no** silent mock fallback, live HTTP, FCM, push, device permission or background worker. Mode selection is at the feature entry.
- `docs/api/notifications/`: Arabic README, v1 API contract, Postman v2.1 collection (four proposed endpoints, first and next page requests) and 14 JSON examples validated against Dart parser/fixtures.

## Badge integration seam for supervisor
- `features/notifications/domain/notifications_repository.dart`: `NotificationsUnreadCountSource` exposes `Future<int> getUnreadCount()` and `Stream<int> get unreadChanges`.
- `features/notifications/notifications_entry.dart`: `notificationsUnreadCountSourceFor(FeatureDataMode mode)`. This returns **the same source as the inbox**, so Home should observe it rather than create a separate count. **Home untouched**.
- **Shared integration request:** move long-lived notification mock repository ownership from feature-entry static instance into the app/service composition owner (e.g. `TamApp`) with a session-clear/dispose lifecycle, then inject the same object into both Home badge and inbox. Do not create a second store. During this isolated wave-one task, logout/session-aware shared lifecycle remains unintegrated because `app/core` and Home are outside D ownership.

## API handoff
Proposed (not live): `GET /notifications`, `GET /notifications/unread-count`, `POST /notifications/{id}/read`, `POST /notifications/read-all`. Auth and response envelope are consistent with common Auth contract; error codes, cursor range, read-at UTC timestamps and nullable fields documented. No Auth endpoint changes. Review cursor stability under concurrent inserts with backend owner.

## Verification — actual results
Executed on user's Ubuntu ROG device with installed Flutter, in `apps/customer`:
- `python3 scripts/dev/sync_feature_l10n.py` (repo root): **pass**.
- `flutter gen-l10n`: **pass**.
- `dart format --output=none --set-exit-if-changed lib test`: **pass**, 85 files unchanged.
- `flutter analyze --no-pub`: **pass, no issues**.
- `flutter test --no-pub`: **pass, 164 tests**, with 4 host-dependent golden tests skipped by default.
- `TAM_NOTIFICATIONS_GOLDEN=1 flutter test --no-pub --update-goldens test/features/notifications/notifications_widget_test.dart`: **pass, 9 tests**, including all four screenshot cases. Golden font loader references local host Noto/MaterialIcons fonts solely during opt-in rendering; no font files committed.
- JSON validation: all examples and Postman responses parse as JSON; Postman v2.1 collection has required four endpoints / five sample requests. **Not** imported into Postman UI, **not** sent to a live server.
- Rendered screenshot sizes: Arabic 390×844, English 390×844, Arabic tablet 800×1080, Arabic 320×780 at 2× text scale. See `screenshots/` and widget goldens. Actual device/emulator capture **not performed** because shared emulator was not launched without coordination.
- Independent manual visual review of UI-05 and rendered Arabic/English screenshots. The 320dp 2× text overflow found during testing was corrected.

## Owned files and generated derivatives
New code under `lib/features/notifications/{data,domain,presentation}`; feature `notifications_entry.dart`, `l10n/app_ar.arb`, `l10n/app_en.arb`; tests under `test/features/notifications/`, docs under `docs/api/notifications/`, screenshots here. **Do not stage/commit** shared generated `apps/customer/lib/l10n/app_*.arb` or `app_localizations*.dart`; supervisor must rerun `sync_feature_l10n.py` and `flutter gen-l10n` during integration.

## Remaining limitations
- Real API, authenticated session, device push, system notifications and actual backend integration are outside this task.
- Shared composition lifecycle and Home badge hookup belong to supervisor. Current mock entry is feature-scoped static and survives local session sign-out until composition is revised.
- One handwritten UI page is approximately 310 lines (slightly above the 300-line guideline) for a cohesive screen including loading/error/empty sections and extracted notification tile; no speculative abstraction added.
- Golden files are host-specific visual evidence; 4 optional comparisons are skipped in normal `flutter test`, enabled only when `TAM_NOTIFICATIONS_GOLDEN=1`. Re-generate only in a matching environment.
- No main merge, GitHub Actions invocation, or force push.
