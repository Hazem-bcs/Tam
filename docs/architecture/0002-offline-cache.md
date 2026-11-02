# ADR 0002 — Low-bandwidth and offline-read policy

Status: **Accepted for scaffolding**.

## Layers
- **Memory**: short-lived state and small in-session results.
- **SQLite**: durable structured read cache and local user drafts. `LocalCacheStore` is the port.
- **SharedPreferences**: optional low-value preferences only; not access tokens.
- **Secure storage**: use OS keystore/keychain for auth tokens when authentication is implemented.
- **Images**: provider/cache-backed resized images, bounded memory and disk usage. Add when designs land.

## Data categories
| Category | Offline behavior | Authority |
| --- | --- | --- |
| City lists / allowed vehicle categories | Serve stale, refresh in background | Server |
| Recent destinations / user-entered drafts | Cache locally; user may review | Device (draft) |
| Fare estimate | Label stale; recompute before request | Server |
| Nearby driver availability | Do not claim live availability offline | Server |
| Ride request / acceptance / cancellation | **No offline success**; require server ACK & idempotency key | Server |
| Ride status & location | Show timestamp, degraded/offline indicator | Server |
| Wallet / financial balances | No authoritative offline changes | Server |

## Read algorithm
1. Read keyed cache and show fresh content immediately.
2. If stale but inside `serveStaleFor`, render visibly stale content and start refresh.
3. If network fetch succeeds, update disk cache and UI.
4. If network fails, retain allowed stale data; clearly label freshness.
5. If no usable cache, show actionable retry UI without an infinite spinner.

Each feature owns TTL, invalidation keys, cache schema versions and whether user IDs are part of the cache key. Purge personal caches on logout. Place SQLite migrations behind versioned `onUpgrade`; do not store tokens or documents in plaintext cache.

Cache TTL alone is NOT a substitute for access control or server consistency. High-stakes mutations must have server-confirmed states.
