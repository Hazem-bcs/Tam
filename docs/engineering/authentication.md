# Tam customer authentication — local development implementation

## Delivered scope

As of 2026-11-05, the app opens directly after a valid Syrian mobile number is
entered. OTP is temporarily skipped at the user's request. The normal application
composition uses `UnconfiguredAuthRepository`; it creates no fake backend users,
challenges, access tokens or refresh tokens. `FakeAuthRepository` now exists only
in `apps/customer/test/support/` for contract and authentication regression tests.
No deployed Auth API, SMS service or ride service is connected yet. This is a
local entry flow, not verified production authentication.

The original user-supplied document is preserved byte-for-byte in
[`../api/authentication-v1.md`](../api/authentication-v1.md). The companion
[`../api/authentication-v1.openapi.json`](../api/authentication-v1.openapi.json)
describes the six operations and their data shapes using
[OpenAPI 3.1](https://spec.openapis.org/oas/v3.1.1.html). The behavioral requirements
in the original contract remain authoritative.

## Trying the development flow

1. Enter any valid Syrian mobile number, such as `0941234567`, `941234567`,
   `963941234567`, `+963941234567` or `00963941234567`.
2. Tap Continue. The app opens directly without an OTP or network request.
3. The home screen displays the entered number and the current unavailability of
   the ride service. No fabricated trips, drivers or verified-account status appear.
4. Sign out to clear the local number. Guest browsing remains available.

The local number is held in memory for the current app process, separately from
`AuthUser` and `AuthSession`. It is not an authenticated backend identity, and does
not grant access to protected APIs. Resuming the app retains local access; process
restart asks for the number again. Local sign-out never calls server revocation.

Arabic/Persian digits are normalized. OTP autofill and paste use a single accessible
field, preserving leading zeroes; phone and code entry are LTR within Arabic UI.
The phone field also accepts `912345678`, `00963912345678`, and
`963912345678` without a `+`, matching Zad's acceptance of the bare country code.
Accepted inputs are converted to `+963912345678` before a repository request;
the Backend contract still receives E.164 only.
The current input region is Syrian mobile numbers only. Confirm other supported
regions with Backend before adding a country picker or broader phone validation.

`TEMPORARY_PHONE_ENTRY` defaults to true in all build modes while Backend is
unconnected. Disable it with `--dart-define=TEMPORARY_PHONE_ENTRY=false` when wiring
the real Auth repository and secure session store. The existing OTP screen,
verification, resend and session lifecycle remain available in that mode. Until a
real repository is registered, it displays service unavailable rather than
fabricating an authenticated session. The tests explicitly inject their fake and
keep exercising the complete OTP flow, without displaying test codes in the UI.

`API_BASE_URL` alone does not enable real authentication in this implementation.

## Separation and replacement boundary

The code lives in `apps/customer/lib/features/auth/`:

| Area | Responsibility |
| --- | --- |
| `domain/auth_models.dart` | User, challenge, session, verification result, bilingual failure |
| `domain/auth_repository.dart` | Six API operations and the separate session-store port |
| `domain/phone_number.dart` | Phone/digit normalization without framework dependencies |
| `data/auth_api_codec.dart` | Strict parsing of contract envelopes, field types, UTC times and TTLs |
| `test/support/fake_auth_repository.dart` | Test-only behavior simulator, absent from application source |
| `data/memory_auth_session_store.dart` | Process-memory storage; no tokens written to disk |
| `data/unconfigured_auth_repository.dart` | Explicit unavailable behavior without fabricated success |
| `presentation/bloc/auth_cubit.dart` | UI state, authentication and session orchestration |
| `presentation/pages/` | Phone, OTP and session-recovery pages |
| `presentation/widgets/auth_widgets.dart` | Local auth layout, notices and countdowns |
| `auth_dependencies.dart` | Repository/storage selection and temporary local-entry configuration |

Replace the repository and store registrations with a Laravel-backed repository
and an OS-secure session store. The UI, domain entities, Cubit state shape and
navigation do not depend on `FakeAuthRepository` or Dio and need not change.
Presentation receives a temporary-phone-entry setting from composition. Production
OTP and session API contracts are unchanged; local entry uses a distinct
`AuthStatus.localAccess`, never `AuthStatus.authenticated`.

The real HTTP adapter must:

- Implement the same six repository methods against `/api/v1/auth/...`.
- Use JSON headers, the current `Accept-Language`, Bearer access auth for `/me`,
  and the documented unauthenticated refresh/logout bodies.
- Use `AuthApiCodec` for success/failure shapes and map local timeout/network
  failures to `AuthFailure` without exposing raw response bodies or credentials.
- Honor `Retry-After` and `retry_after_seconds`, including a policy for missing or
  conflicting retry information agreed with Backend.
- Consume logout's empty `204` without trying to parse JSON.
- Persist rotated credentials atomically in a Keychain/Keystore-backed store.
- Coordinate protected-request refreshes through the shared session lifecycle;
  do not independently refresh the same token from multiple HTTP interceptors.
- Disable temporary phone entry and satisfy staging acceptance tests.

`display_name` stays optional. No separate registration endpoint or invented
name-update payload is added; profile completion needs its own agreed contract.

## Session behavior and limitations

The following real-session behavior applies when temporary phone entry is disabled
and an Auth repository is configured or injected by tests.

Tokens are never included in observable Cubit state or rendered UI. Domain session
diagnostics are redacted. No authentication logging interceptor is added.

The Cubit restores a saved session, refreshes expired access tokens using the
configured expiry dates, persists the rotated pair, then requests `/me`. Concurrent
restore calls share one operation. It retries a server-invalid access token with
at most one refresh per restore operation. Explicit revocation, invalid sessions
or disabled accounts clear saved credentials. A temporary network failure retains
them and exposes retry UI; a signed-in user keeps their state on a transient
foreground revalidation failure.

App foreground resume revalidates authenticated sessions. Explicit sign-out clears
local credentials even if remote revocation fails, and tells the user that server
revocation could not be confirmed (`LOGOUT_REMOTE_UNCONFIRMED`, a local code).
Guest mode creates no user/token and makes no auth API calls. The home page
contains the phone/profile, a service-unavailable state and sign-in/sign-out. Ride
booking and other features are not implemented here. Future protected routes and
all server endpoints must enforce their own authorization.

The test fake and session store both live in memory. Recreating the UI/controller
with the same repository/store can restore a session; killing the process resets
the simulator. Durable process-restart restoration requires the real backend and
secure store. It is deliberately not simulated with plaintext files or SQLite.

Backend must still define recovery for a lost refresh response after successful
rotation (for example, an agreed idempotency/grace policy). The client retains its
stored credentials on transport failure, but cannot invent a replacement token
or distinguish replay from response loss without server support. No extra request
field or altered API behavior was silently added to the supplied contract.

The fake is not an implementation of production SMS, OTP hashing, server rate
limiting, database uniqueness or security validation. Backend must implement and
verify those requirements, including SMS delivery to `+963`.

## Integration outside the feature

- `app/app.dart` owns and disposes the Cubit, router, refresh listener and lifecycle
  observer; dependencies can be injected for widget tests.
- `app/router/app_router.dart` selects the phone, OTP, restore or public-home route
  from auth state and prevents opening OTP without a challenge.
- `app/di/service_locator.dart` registers the feature.
- `core/config/app_config.dart` owns the temporary phone entry flag.
- The home page displays the phone and service availability without sample data.
- `TamTextField` now forwards native input formatters, used for OTP normalization.
- ARB files contain both languages; generated localization files were regenerated.
- The original app smoke test now enters the public shell through guest mode.

## Verification

On Flutter 3.41.4 / Dart 3.11.1:

```bash
cd apps/customer
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
```

The full suite passes: **88 tests**. `flutter analyze --no-pub` reports no issues,
and the formatting check passes with no changes.

The current suite preserves the original contract, OTP, session and UI tests, and
adds tests for local entry in both languages, multiple valid phones, invalid
numbers, no repository calls or saved credentials, guest access, sign-out,
foreground restoration, deep links and 320dp with text at 250% and keyboard insets.

The seven local-entry tests also pass with
`flutter test --no-pub --dart-define=TEMPORARY_PHONE_ENTRY=false test/features/auth/temporary_phone_entry_test.dart -r expanded`,
including dependency composition and the non-bypass service boundary.

Flutter-rendered review screenshots (test-only DejaVu font substitute, no Android
build or emulator launch) were inspected:

- [Arabic phone](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-direct-entry/ar-phone.png)
- [Arabic home](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-direct-entry/ar-home.png)
- [English home](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-direct-entry/en-home.png)
- [320dp home](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-direct-entry/small-home.png)
- [250% text, scrolled to sign out](/home/hazem/.codex/visualizations/2026/11/04/01a1a664-bf1c-7392-8258-f7fdc11e0e8a/tam-direct-entry/large-text-home-action.png)

No fake-auth or demo-code plumbing remains under `lib/`. No GitHub Actions, Android
build, commit, push or merge is required for this local change. Publication still
requires the real backend, OTP delivery, secure persistent sessions and ride
services; a clean UI alone does not complete those integrations.
