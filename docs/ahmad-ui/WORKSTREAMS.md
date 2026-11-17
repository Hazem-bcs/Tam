# Ahmad UI — 20-agent accelerated production plan

**Repo:** `Hazem-bcs/Tam`  
**Existing/current variant:** `main` — protected by workflow policy: do not alter or merge Ahmad into it.  
**Ahmad visual variant:** `ahmad-ui`, forked initially from `ffad266d4de544d7634bec79ac25587584987416`.  
**Single intake:** [REFERENCE_GALLERY.md](REFERENCE_GALLERY.md). **Rules:** [DESIGN_CONTRACT.md](DESIGN_CONTRACT.md), root `AGENTS.md`.

## Work allocation — 12 customer screen owners

All owners edit only their designated **presentation** files plus **distinctive named test files** for their part; no domain/data/route/theme/general localization writes. If a needed file is outside ownership, send an exact request to A20. These assignments are a **proposed ready-to-delegate map**: implementation begins only after the supervisor gives each agent a task card with precise baseline, paths, and references. Reference UI IDs are not permission to invent missing screens.

| Agent | Screen / source reference | Proposed exclusive owned code | Review deliverable |
|:--|:--|:--|:--|
| A01 | Home, promotions/navigation — UI-04 | `features/home/presentation/**` | Full Home golden; unique booking CTA; promo state |
| A02 | Phone/OTP/Auth — UI-06, UI-07 | `features/auth/presentation/**` (no auth business flow changes) | Phone/OTP mock-safe states |
| A03 | Account/settings — UI-08 | `features/settings/presentation/**` and account-management **presentation only if separately authorized** | Settings, account, logout visual |
| A04 | Saved addresses — UI-02 | `features/addresses/presentation/**` | List/edit/picker presentation, same data contract |
| A05 | Trips activity/list/filter — UI-01 | `features/trips/presentation/pages/trips_list_page.dart`, widgets `activity_masthead.dart`, `trip_card.dart`, `trip_history_list.dart`, `trip_status_filter.dart`, `trips_failure_banner.dart`, `next_trip_prompt.dart`, `active_trip_card.dart` | Trips overview/filter |
| A06 | Trip details — UI-03 | `features/trips/presentation/pages/trip_details_page.dart`, widgets `trip_details_body.dart`, `trip_details_actions.dart`, `trip_journey.dart` | Trip details and status transitions |
| A07 | Notifications — UI-05 | `features/notifications/presentation/**` | Unread/read/empty/filters |
| A08 | Ride pickup/destination/location — UI-10 | Ride-request leaf widgets: `ride_journey_locations.dart`, `ride_journey_place_sheet.dart`, `ride_location_fields.dart`, `ride_place_picker.dart`, `ride_place_suggestion_tile.dart`, `ride_map_point_panel.dart`, `ride_map_point_role.dart` | Location picker, map overlay, golden |
| A09 | Ride scheduling — UI-09 | Ride-request leaf widgets: `ride_schedule_dialog.dart`, `ride_schedule_picker.dart`, `ride_time_dialog.dart` | Schedule dialog and selected-time summary |
| A10 | Vehicle classes / quote / payment presentation — UI-11 | Ride-request leaf widgets: `ride_vehicle_picker.dart`, `ride_quote_review.dart`, `ride_artwork.dart` | Vehicle and fare review |
| A11 | Waiting/matched/arriving ride — UI-12, UI-15 | `features/active_trip/presentation/**` | Waiting, driver card, cancel/contact states |
| A12 | Customer ↔ driver chat — UI-13 | `features/chat/presentation/**` | Chat and keyboard/empty/error states |

**Special collision locks:** 
- A05 and A06 share the Trips **feature**, but never the same files. Any new shared Trips file belongs to A20 until explicitly allocated.
- A08/A09/A10 share Ride Request. They **do not modify** `ride_request_page.dart`, `ride_journey_shell.dart`, `ride_journey_entry.dart`, `ride_journey_body.dart`, `ride_journey_stage.dart`, `ride_journey_panel_content.dart`, `ride_journey_sheet.dart`, `ride_journey_header.dart`, `ride_journey_progress.dart`, `ride_journey_backdrop.dart`, navigation connectors, global state or the same golden file. A20 integrates their leaf widgets into the page flow after UI contract review.
- A02 must not rework temporary phone login, guest access, OTP protection or Rive runtime behavior outside an explicit task.

## Five specialized support agents (A13–A17)

| Agent | Job | Exclusive write scope |
|:--|:--|:--|
| A13 — Ahmad Visual Lead | Define the **one** alternative visual language (colors, type, cards, radii, bottom nav specification, etc.) adapted from original client references; issue a design-system baseline for all screen owners. | Central theme/tokens/shared UI **only after A20 assigns exact paths**; initial draft in PR. |
| A14 — Asset/Illustration | Inventory reference assets and existing WebP/SVG; create needed customer-only icons/art in one coherent style, report dimensions/weights/licensing. | New unique assets under `assets/images/ahmad_ui/` (and approved SVG paths); no changes to existing mascot without permission. |
| A15 — Motion & Rive | Interaction motion specification, transitions and expressive Rive compatibility; no gratuitous animation. | New isolated assets under `assets/animations/ahmad_ui/`, focused isolated tests; central hooks assigned by A20. |
| A16 — Cloud Preview Engineer | Extend Github-hosted UI previews beyond the four existing features, generate AR/EN and screen-size snapshots, collect downloads; do not use ROG self-hosted runner. | New `.github/workflows/ahmad-ui-preview.yml` and uniquely named preview harnesses approved by A20. |
| A17 — UX QA | Cross-feature layout and user-journey checks, deduplicate buttons, track semantic issues and accessibility. | PR reviews and `docs/ahmad-ui/reviews/ux-*.md` under A20's assigned document ownership. |

## Three reviewers + integrator (A18–A20)

| Agent | Job | Scope |
|:--|:--|:--|
| A18 — Localization/Accessibility QA | Inspect 320/390/800dp, scaling, RTL/LTR, focus order, keyboard, semantics, asset directionality. | PR review comments; no feature implementation writes. |
| A19 — Code/Performance QA | Review Clean Architecture, rebuild scope, code hygiene, failures, golden reliability, animation load, assets. | PR review comments; no feature implementation writes. |
| A20 — Supervisor/Integrator | Own allocations, branch and SHA verification, shared file updates (router/l10n/shell/theme coordination), commit conflict resolution, review evidence, Android integration preview, and integration into **ahmad-ui only**. | Shared app shell/ride orchestrator, docs/ahmad-ui status, final accepted merges, no merge to main. |

**Total: 20 agents = 12 screen implementers + 4 production enablers (A13–16) + 3 QA reviewers (A17–19) + 1 integrator (A20).** Additional agents only help after A20 defines a separate ownership unit; opening dozens of writers on the same feature is slower and more error-prone.

## Waves / critical path

**Wave 0 (shared visual freeze):** A13 produces central Ahmad design-system patch and rules; A14 asset inventory and starter approved assets; A16 prepares expanded preview infrastructure; A20 publishes baseline SHA and exact task cards. Other owners may read/reference/analyze but do not write conflicting code before this baseline.

**Wave 1 (12 independent implementations):** A01–A12 implement isolated assigned pages or leaf widgets in separate GitHub branches `ahmad-ui/<area>` created **from the published Wave 0 Ahmad SHA**. A15 provides animation assets where requested; never blocks static UI implementation.

**Wave 2 (review continuously):** A17–A19 check ready PRs in parallel: screen visual fidelity, UX, accessibility, contract regressions, performance and localization. Screens that pass can integrate as soon as A20 accepts their exact final SHA; do not hold independent work for the slowest feature.

**Wave 3 (real flow integration):** A20 merges PRs in dependency order, wires split ride widgets, routes, ARB keys and shared layout; runs full flow and cloud screenshots on **ahmad-ui**. Make actual Android screenshots/variant builds only when screen-level goldens cannot validate behavior, or at review milestone.

**Wave 4 (two delivery builds):** Build from `main` for the existing variant and `ahmad-ui` for Ahmad variant, label outputs distinctly, compare all screen screenshots with manager/customer. No alteration to `main` by Ahmad UI team.

## Branch / PR rules

- Keep two long-lived lines: `main` for current design, `ahmad-ui` for Ahmad variant. **No cross-merging visual changes.**
- Every task PR base = `ahmad-ui`, not `main`. A20 alone merges; agents never push to those long-lived branches directly.
- Exact base SHA, one owner per file, independent tests; one reviewer cannot approve their own work. Changes to a reviewed SHA require re-review of affected parts.
- Do not accept pixel-perfect screenshots alone as correctness. Flutter Golden screenshots are non-interactive widget renders, not proof of Android runtime; integration and Rive get separate checks.
- Avoid repeated expensive builds/tests per small edit; batch checks when PR ready.
- Existing `main` can continue functional improvements. A20 port/reconcile critical logic fixes into Ahmad via reviewed, selective integration (not uncontrolled blanket merges). The two variants must not silently drift in business/security behavior.

## First messages to agents

Start with [AGENTS.md](../../AGENTS.md), [DESIGN_CONTRACT.md](DESIGN_CONTRACT.md), [REFERENCE_GALLERY.md](REFERENCE_GALLERY.md), and `docs/engineering/agent-onboarding.md`. Then send a task card:

```text
Task ID: AUI-<agent-number>
Role: IMPLEMENTER | DESIGN LEAD | ASSET | CI | QA | INTEGRATOR
Source: Hazem-bcs/Tam (branch ahmad-ui)
Baseline SHA: <freeze SHA from A20>
Source refs: UI-XX (view actual image)
Owned files: <exact assigned paths>
Excluded files: app/theme/router/l10n/DI/pubspec except assigned central owner
Objective: Build a high-fidelity functional *second design*, not modify main
Acceptance: RTL/LTR; phone/tablet/text scale; correct UX and current behavior
Delivery: PR against ahmad-ui + final SHA + feature golden/artifacts + tests + review
Permission: no unapproved push/merge/Actions/build beyond the task card
```

**State:** allocation/design plan only. No screen-owner task has been delegated, implemented or approved yet.
