# تم | Tam

Flutter-first mobility platform. The repository starts with the **customer app**; driver, merchant, admin and backend code may be added here as independently deployable folders when required.

## Current scope
- `apps/customer` — Flutter customer application (Android/iOS).
- `docs/architecture` — architecture decisions and caching model.
- `docs/engineering` — code review and contribution rules.

## Team starting point

New agents start with the [onboarding guide](docs/engineering/agent-onboarding.md)
and [design reference index](docs/engineering/design-reference-index.md).

Read [AGENTS.md](AGENTS.md), the [five-feature plan](docs/engineering/wave-one-plan.md)
and [task board](docs/engineering/task-board.md). New feature work is planned
with isolated mock repositories and backend API/Postman handoffs; see the
[mock/API policy](docs/engineering/mock-api-policy.md). The shared data-mode switch and route entry points are implemented; the five
feature implementations are assigned in task cards. The supervisor supplies the same exact
baseline SHA to all owners after the shared setup; each uses its own branch
and isolated checkout. The fixed wave reference is tag
`tam-w1-baseline-2026-11-07`; verify its SHA against the dispatch message.
Do not assume `main` contains that baseline.

The integrated wave-one features and the saved-address feature follow the
[two-phase delivery plan](docs/engineering/development-phases.md). Current
progress and the exact starting SHA for new work are recorded in the task board;
the older wave-one tag remains immutable. Saved addresses share one session-owned
repository across Home, Settings and booking. Their mock edits reset on logout
and process restart. `ADDRESSES_DATA_MODE=api` protects address routes and fails
explicitly until the API adapter is implemented. See the
[Arabic backend handoff](docs/api/addresses/README.ar.md).

## Run locally
```bash
cd apps/customer
flutter pub get
flutter run --dart-define=API_BASE_URL=https://YOUR-API-HOST/v1
```
The API URL is not configured by default. The boot screen must work without a backend.

## Quality gates
```bash
cd apps/customer
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

The performance workflow supports pushes and manual runs. Use `[skip ci]` in commit messages when pushing changes that must not trigger Actions. Never commit API secrets, service-account credentials, signing keys or personal data.

## Infrastructure naming

The product is **تم | Tam**. Existing repository URLs, local checkout paths, runner labels/services and the dedicated CI AVD retain their provisioned names until an infrastructure migration.

## Feature localization development

Feature owners edit their own `lib/features/<feature>/l10n/app_ar.arb` and
`app_en.arb` fragments. Run `python3 scripts/dev/sync_feature_l10n.py` from
the repository root, then `flutter gen-l10n` from `apps/customer` before
analysis/tests. Shared base ARB lives in `apps/customer/l10n/base/`. Owners
commit their fragments, while the supervisor regenerates and commits shared
`lib/l10n` outputs at integration. See the [wave contracts](docs/engineering/wave-one-contracts.md).
# جدولة الرحلات — W2

تدفق الحجز يدعم الموعد من30 دقيقة إلى7 أيام، بتوقيت الخدمة المعتمد
UTC+03:00 ونقل UTC، مع نفس مصدر طلباتي ومحاكاة الجلسة. الحزمة المقترحة
للباكند: [جدولة الرحلات](docs/api/scheduling/README.ar.md).
يستخدم RIDE_REQUEST_DATA_MODE نفسه، ولا يفعّل GPS أو dispatch أو API حيًا.
## الرحلة الجارية — W2

الحجز يفتح شاشة المتابعة، وتُستعاد الرحلة من الرئيسية أو تفاصيل طلباتي.
المصدر المشترك يحاكي البحث والسائق والوصول والانتظار والسير والانتهاء،
بـACTIVE_TRIP_DATA_MODE وACTIVE_TRIP_MOCK_SCENARIO=success|no_driver|disconnect.
المحاكاة مؤقتة داخل عملية التطبيق؛ لا GPS أو dispatch خلفي حقيقي.
راجع [حزمة الباكند](docs/api/active_trip/README.ar.md) للعقد وPostman والأمثلة.
