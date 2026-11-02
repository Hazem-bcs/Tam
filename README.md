# مشوار | Mashwar

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

No CI workflows are enabled by default. Never commit API secrets, service-account credentials, signing keys or personal data.
