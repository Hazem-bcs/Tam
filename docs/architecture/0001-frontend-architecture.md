# ADR 0001 — Flutter customer architecture

Status: **Accepted for scaffolding**, 2026-11-03.

## Decisions
- One Flutter application in `apps/customer`; one deployable app, not micro-frontends or independent packages.
- **Feature-first**, with `presentation / domain / data` added only to features that need them.
- `flutter_bloc` for asynchronous feature state; immutable states; local ephemeral widget state can stay in a widget.
- `get_it` as the composition root. Each feature exposes a small registration function; central entrypoint wires them.
- `go_router` for navigation; typed, centralized route paths.
- `dio` for HTTP, all transport concerns isolated in core/network.
- Arabic RTL and English translations from Flutter's built-in ARB/localization generator.
- Single source of truth per resource in its repository. No widget invokes HTTP, storage or SDK directly.
- Design system under app/theme once reference UI is reviewed.
- Offline reads supported by repository-owned cache policies; remote booking confirmation always authoritative.

## Dependency rule
`presentation -> domain <- data`.
Presentation depends on use cases / repository contracts; data implements them. Domain never imports Flutter, Dio, sqflite or Google Maps SDK.

## Suggested feature layout (create only when implementing)
```text
lib/features/ride_request/
  domain/entities/
  domain/repositories/
  domain/usecases/
  data/datasources/
  data/models/
  data/repositories/
  presentation/bloc/
  presentation/pages/
  presentation/widgets/
```
Avoid a use-case class when it just forwards a single call; introduce it for meaningful domain rules/orchestration.

## Performance rules
1. Avoid restarting Google Maps or rebuilding the full page for every driver-position update.
2. Scope BlocProvider and BlocSelector to the smallest subtree. No high-frequency GPS positions in a global AppBloc.
3. No synchronous JSON parsing of huge payloads on the UI thread; benchmark before adding isolates.
4. Prefer const widgets, slivers/lazy lists, properly sized images and measured animations.
5. Show cached content immediately when safe; fetching is non-blocking. Do not infer connectivity from WiFi alone.
6. Add observability and error taxonomy; never silently swallow exceptions.
7. Maintain cancellation and idempotency rules for network requests and retries.

## Boundary
The backend is a separate Laravel deployment planned for this repository; **Monolith** refers to deployable boundaries, not combining every Dart concern into one class.
