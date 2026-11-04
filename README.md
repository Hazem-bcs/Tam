# تم | Tam

Flutter-first mobility platform. The repository starts with the **customer app**; driver, merchant, admin and backend code may be added here as independently deployable folders when required.

## Current scope
- `apps/customer` — Flutter customer application (Android/iOS).
- `docs/architecture` — architecture decisions and caching model.
- `docs/engineering` — code review and contribution rules.

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
