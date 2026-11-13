# TAM-HOME-REBUILD-01 — Design extraction / 2026-11-13

## Inspected sources
Opened all eight required local PNG/JPEG images in the manifest, in image-first order. No Figma used. Company UI-04 supplies responsibilities, not final art direction. A/C source images are browser prototype captures, not geography or production screens. Optional historical research attachments are not available/required.

- **Company:** greeting, notifications, services, promotion and bottom destinations. The large photo-led hero competes with starting a ride; unavailable services must stay unavailable. Existing Home additionally exposes saved addresses, active-trip entry and session identity.
- **Fluid:** broad quiet planes, large top-aligned Arabic headings, rounded sheet/field vocabulary, violet focal color with restrained secondary colors. About the lower third belongs to a single next action. Transitions grow/recede the action surface as actual state changes.
- **Urban:** dark blue-green field, mint action and spatial density; compelling at night, but invented map roads and location dot cannot become Home content. Its map occupies too much space for the real multifunction Home.
- **Storyboards:** keep context during each action, then promote the next real input. No elapsed-time success animation. We only redesign Home; navigation into the existing booking flow stays authoritative.
- **Arabic:** bold sans forms, zero tracking, directional alignment and generous line-height. System Naskh fallback in the former Android Home weakened the intended hierarchy. Bundle unmodified Noto Sans Arabic Regular/Bold plus Noto Sans Latin fallback (four unmodified fonts, approximately 1.46 MiB total, SIL OFL 1.1; local Debian notice included and declared under Flutter licenses), and apply it only through central opt-in Home typography.

## Two explorations
See `concepts/two-directions.png` and its reproducible HTML source. These are original static design studies with existing labels, not screenshots of implemented Flutter.

1. **Pulse Station:** dark ink, mint boarding-action bar, asymmetric vertical side rail, list-like service directory. Strong night identity, but more density and less daylight comfort. No conceptual streets copied.
2. **Fluid Editorial (selected):** warm paper surrounding a continuous violet departure stage, typographic heading, geometric directional sculpture, white destination action, two utility links and an open service index. Promotions become editorial footnotes, not another competing hero. Bottom navigation remains visible. This replaces the old greeting/search/promotion/card-grid hierarchy.

Scores out of five (critical design judgment, not measured user research):

| Concept | Identity | Arabic hierarchy | Usability/daylight | Runtime simplicity |
|---|---:|---:|---:|---:|
| Pulse Station | 4 | 4 | 3 | 4 |
| Fluid Editorial | 5 | 5 | 5 | 5 |

Choose Fluid Editorial for obvious primary action, calm surrounding utility content and clear contrast without a live map. The diagonal folded-arrow sculpture is decorative, excluded from semantics and pointer handling. It represents direction, not route/position/driver status.

## Translation to production
- Semantic opt-in `AppTheme.home(ambient)`: paper, ink, violet action, pale violet secondary, contrasting citron accent, stable Material control states. Raw palette centralized in app_colors.dart. Only Home installs it; pushed pages continue using the app theme.
- 24dp horizontal rhythm, 16dp compact spacing, 32dp sectional spacing. Hero height grows from its content; no fixed text boxes. Content max width 760dp; tablet stage uses side-by-side heading/sculpture when appropriate. Compact landscape and large text suppress decorative space, not content or text scale.
- Native type roles extended centrally for Home: bold display, readable 14–16dp labels/body, font-family confined to Home. No remote fonts or extra runtime packages.
- Entry: one 450ms ease-out reveal of stage content with at most 12dp travel. Press: 180ms scale/tint feedback derived from pointer/focus state, navigation callback immediate. Returning from booking restores Home scroll/state. Reduced-motion sets duration/travel to zero; no permanent animation ticker, blur or shader.
- Data: all promotions and availability still come from HomeCubit/HomeContent. Existing ARB labels reused. Notification widget/count and navigation callbacks remain injected.

## Behavior preservation checklist
- [ ] Guest, localAccess, authenticated identity and LTR phone; sign in/out.
- [ ] Notification action/count stays scoped to existing unread-count Cubit.
- [ ] Primary ride action only when ride service available; same callback.
- [ ] Saved addresses and active-trip entry; same route guards.
- [ ] Ride service opens booking; food/shopping remain disabled with localized status.
- [ ] All promotion title/subtitle/enabled/action semantics preserved, including unknown server text length.
- [ ] Loading, empty, offline/API-unavailable, retry; no mock fallback.
- [ ] Trips/settings navigation, back stack and Home scroll retention.
- [ ] AR/EN, 320dp 2x, 390dp, tablet, landscape/keyboard, reduced motion, meaningful semantics and focus/tap targets.

Baseline ff1da1d8e8c2f7c04d6203dc79c13e1d7b732584; sole writer on dedicated worktree/branch. Central palette/theme/typography and font assets/pubspec are the explicitly authorized shared changes. No other active writer was found in this checkout (clean preflight); do not modify other features.

## Scope update / user direction
The user subsequently authorized the linked staged booking journey and asked to prioritize visible design over rerunning broad tests. See ../TAM-RIDE-JOURNEY-01/HANDOFF.md. The original Home-only exclusion was superseded for booking presentation and its matching screen; Domain/Data/Auth/API remain unchanged.
