# TAM Home — three competing concepts and selected implementation

**Task:** HOME-V3-DESIGN | **Owner:** Home presentation + Home v1 proposed campaign contract
**Base:** `main` at `86c431c` | **Branch:** `feat/tam-home-destination-first-20261116`

## Why the previous Home failed
- Pickup row, destination row and the primary button opened the **same** ride-request page.
- The "follow my trip" shortcut was shown even when no active trip was known, and Trips already exists in bottom navigation.
- Saved addresses were promoted to a permanent shortcut even though ride request already exposes address management.
- Promotion content looked like a static pink card: one approved slide, no discernible next card.
- Coming-soon services were given nearly the same visual weight as the live ride service.
- A generated landmark/car photograph was disallowed; the original TAM mascot is the only character illustration permitted here.

## Three distinct wireframes

### A — Destination First (SELECTED)
```
┌──────────────────────────────────┐
│ تم   أهلًا بك         [إشعارات]   │
├──────────────────────────────────┤
│ ╔══════════════════════════════╗ │
│ ║ وين رايح اليوم؟              ║ │
│ ║ خلّينا نوصلك ببساطة          ║ │
│ ║ ┌──────────────────────────┐ ║ │
│ ║ │ 📍 حدد وجهتك           ←│ ║ │
│ ║ └──────────────────────────┘ ║ │
│ ╚══════════════════════════════╝ │
│ عروض وإعلانات              1 / 3 │
│ ┌─────────────────────────┐ ╭──┐ │
│ │ حملة 1 + شخصية تم       │ │2 │ │
│ └─────────────────────────┘ ╰──┘ │
│           ● • •                  │
│ قريباً في تم   الطعام   التسوق   │
├──────────────────────────────────┤
│ الرئيسية   نشاطي   حسابي        │
└──────────────────────────────────┘
```
**One decisive conversion action.** Campaigns are visually distinct, horizontally swipeable, and can be text-only or HTTPS creative images from the proposed Home contract. Unavailable services remain compact.

### B — Advertising Editorial (NOT SELECTED)
```
Header → full-width magazine campaign slider → destination search action →
large service editorial grid → tabs
```
Pros: maximum sponsor exposure. Cons: paying content pushes the principal booking function below the fold and can make TAM feel ad-first.

### C — Live Operations (DEFERRED)
```
Header → contextual active-trip card when live → destination action →
trip history/reorder suggestions → subdued offers → tabs
```
Pros: excellent for frequent travelers. Cons: requires **actual** active-ride data and permissions; the current `GET /home` contract intentionally contains no active-trip status, so building this now would invent state.

## Decision matrix (1–5)
| Criterion | A | B | C |
|---|---:|---:|---:|
| Main action discoverability | 5 | 3 | 4 |
| No redundant actions | 5 | 4 | 5 |
| Brand cohesion without photos | 5 | 4 | 4 |
| Advertiser surface | 4 | 5 | 3 |
| Honest current data requirements | 5 | 5 | 2 |
| Small-screen economy | 5 | 3 | 4 |
| **Total** | **29** | **24** | **25** |

## Implementation rules

- Only **one tappable ride entry** uses `home-ride-entry`. Do not render additional pickup/destination UI unless the home itself truly captures and carries the selection.
- No permanent "my addresses" or "follow my trip" cards. The ride flow owns addresses; the navigation tabs own trips.
- The promotional area uses **approved** `HomePromotion` data in backend order. An approved informational campaign may have no action; no campaign opens another ride entry.
- Mock content is explicitly a **demo**. Do not present sample sponsorship as a real deal or run mock content in API mode.
- Carousel has a visible neighboring slide, position counter, and dots when there are 2+ slides. It does not animate automatically or take control away from the user.
- The existing original TAM mascot may appear on a branded promotion; do not generate another character or use city/car scenes.
- Live ride availability comes from the existing `HomeCubit`. Failures, no content and disabled ride remain honest states.
- `image_url` is a proposed optional HTTPS creative, not a deployed backend feature. Backend controls first-party CDN hosts, upload moderation, 16:7 recommended framing, compression and cache. The client falls back to readable text if loading fails.
- **Future v2**: Advertiser landing pages or deeplinks must use an allowlisted action type with explicit backend contract and authorization; they are not supported now.

## Visual verification checklist
- Arabic 390dp and 320dp at 2× text, English 390dp, tablet/landscape, keyboard and reduced motion.
- One destination entry only; navigation click increments the ride action exactly once.
- No fake active trips and no taps on coming-soon features.
- Swipe between multiple campaigns; no pagination controls for a single slide.
- No horizontal overflow in RTL/LTR; low-cost rendering and no new heavy dependency.
- Nothing merged into main without user approval.
