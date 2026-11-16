# Tam Home API — v1

**Status:** proposed backend contract (2026-11-07, revised 2026-11-16 for non-clickable campaigns and optional HTTPS creative), NOT implemented or live-tested.

**Scope:** GET `/home`, presentation content only. No trips, quotes, current location, customer profile, notifications, purchases, payments or badge counts.

## Endpoint and headers

- Base URL: `{{base_url}}` includes `/api/v1` (e.g., `https://api.example.invalid/api/v1` is an intentionally invalid example host).
- `GET {{base_url}}/home` — public; **no bearer token or authenticated session required**. Never send local-only phone identity as an access token.
- Request: `Accept: application/json`; `Accept-Language: ar` or `en` optional (default `ar`). Content text is returned in **both** languages regardless of requested locale.
- No request body, path/query parameters, user identifier or private headers.
- Response: `Content-Type: application/json; charset=utf-8`. Server may send `Cache-Control: public, max-age=60` and `ETag`, but clients must also work without cache headers.

## 200 success envelope

```json
{
  "data": {
    "revision": "home-demo-1",
    "promotions": [
      {
        "id": "promo-ride",
        "kind": "hero",
        "title": {"ar": "مشوارك أسهل مع تم", "en": "Getting there is easier with Tam"},
        "subtitle": {"ar": "من أول خطوة حتى وجهتك، اطلب رحلتك ببساطة.", "en": "From pickup to destination, request a ride with ease."},
        "enabled": true,
        "action": "ride_request"
      }
    ],
    "services": [
      {"id": "ride", "available": true, "action": "ride_request"},
      {"id": "food", "available": false, "action": null},
      {"id": "shopping", "available": false, "action": null}
    ]
  }
}
```

Full authoritative proposal examples: `examples/home-success.json` and `examples/home-empty.json`. Empty arrays mean success with an empty state, not 404. Do not return `null` in place of arrays.

### Fields and validation

| Field | Type | Required / nullable | Constraints |
|---|---|---|---|
| `data` | object | required / no | Single envelope; no `meta` because this is not a paginated list |
| `revision` | string | required / no | Non-empty stable revision for cache/content invalidation; change when content/availability changes |
| `promotions` | array<object> | required / no | 0–5 items; ordered by backend display priority |
| `promotions[].id` | string | required / no | Non-empty, unique within the array, opaque stable id |
| `promotions[].kind` | enum string | required / no | `hero` or `announcement` |
| `promotions[].title`, `subtitle` | object | required / no | Both `ar` and `en` are required, non-empty strings; subtitle can be short but not null |
| `promotions[].enabled` | boolean | required / no | Whether this campaign is approved for display, independent of clickability. |
| `promotions[].action` | enum string or null | required / **yes** | `ride_request` or `null`; **never a URL or arbitrary route**. The home UI deliberately does not add a second route to the same ride flow. |
| `promotions[].image_url` | HTTPS URL or null | optional / **yes** | Optional banner creative hosted by a trusted first-party CDN. Backend must enforce ownership, permitted hosts, dimensions, compression and content safety; client validates HTTPS and displays a text fallback on load failure. |
| `services` | array<object> | required / no | At most one of each canonical service id; backend display order |
| `services[].id` | enum string | required / no | `ride`, `food`, `shopping`; no duplicate ids |
| `services[].available` | boolean | required / no | In wave one only `ride` may be true |
| `services[].action` | enum string or null | required / **yes** | `ride_request` only for active ride; otherwise `null` |

**Invariants:** promotions may be displayed when `enabled=true` and `action=null` (informational banners). Services still require `available == (action != null)`; unsupported food/shopping must remain false. The client uses a strict action allowlist mapped to `CustomerNavigation`, never executes route strings. Unknown enum/action or malformed JSON is an invalid response, not an invitation to navigate. The UI labels of canonical services are localized from app ARBs; backend is not a duplicate source.

### Ordering, size and pagination

The endpoint is a single bounded snapshot. **No cursor, limit, offset or pagination.** Promotions and services retain server array order. The UI groups the hero before service tiles and announcement after; backend should send at most one active hero for clarity. The current mock uses multiple **clearly non-commercial** informational cards solely to verify paging. Recommend payload < 20 KiB and normal UTF-8 strings. Dates and money are not present; no timezone, monetary rounding, or implicit price promises are needed.

## Errors and recovery

All API errors use the existing Auth-compatible envelope `{"error":{"code":"...","message":{"ar":"...","en":"..."}}}`. No `data` on errors.

| HTTP | `error.code` | When | Client behavior |
|---|---|---|---|
| 503 | `SERVICE_UNAVAILABLE` | Home backend under maintenance | Show unavailable state; user can retry; **never fallback to mock** |
| 429 | `RATE_LIMITED` | Request quota exceeded | Show error; respect optional `Retry-After`; do not spin |
| 500 | `INTERNAL_ERROR` | Unexpected failure | Error with manual retry |
| 400 | `VALIDATION_ERROR` | Malformed/unsupported input (no parameters are expected) | Show error; do not retry automatically |

Transport timeout/offline is a client failure, not an invented HTTP 200. Missing, duplicate or inconsistent fields must fail decoding safely. The future real API adapter maps transport errors to domain failures; it is not implemented in this wave.

## Mutations, consistency, privacy

GET is read-only, safe and idempotent; repeated calls do **not** create bookings, coupons, wallet credits or notification-read events. Backend controls content revisions and availability; revocation of an offer/service takes effect in subsequent reads, while final booking permission/quote must be revalidated by Ride endpoints. Promotion text must not imply a real discount without product approval. Mock campaigns are not paid ads. For external advertiser landing pages, an additional reviewed destination allowlist/API version is required; v1 does not execute arbitrary URLs or provide advertiser analytics. Home header greeting and `phoneE164` come from existing client Auth/local-access state, **not** this response. Unread notification counts are owned by Notifications; do not put a number in GET /home.

## Flutter mapping

`HomeRepository.load()` → `HomeContent`; `HomeContentMapper.fromEnvelope` validates payload; `MockHomeRepository` loads deterministic success/empty/offline scenarios; `UnavailableHomeRepository` maps future API mode to `SERVICE_UNAVAILABLE` until the real service is written. `HomeCubit` handles loading/empty/failure/retry. The homepage opens only `CustomerNavigation.openRideRequest` for allowed actions; Notifications, Trips and Settings are independent navigation routes.

**Open backend decisions:** final cache policy/ETag and server promo editorial limits. Any new service/action enum requires review with supervisor and app owner before activation.
