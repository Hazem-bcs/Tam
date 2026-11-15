# TAM-MOTION-JOURNAL-02 — Design & Engineering Handoff

## Scope and decision
- Role: design-led developer; user-requested major revision of customer Trips (نشاطي), 2026-11-13.
- Baseline: `e72728dc37302f1a88ab3ea9c2f4a978bb161723`, separate Trips worktree `/home/hazem/projects/tam-trips-visual`.
- File ownership: Trips presentation, Trips-only localization ARB, feature test support/visual test, this handoff. Global theme, DI, routing, Auth, data contracts and other screens intentionally untouched.
- Design direction: **TAM Motion Journal** — burgundy graphic masthead with a distinctive dashed path, editorial contrast, tactile destination emphasis, compact activity tickets and a floating bottom dock.
- No invention of fares, driver tracking, discounts, badge counts or historical rides.

## Research inputs (design decisions, not borrowed artwork)
- Google Design: Material 3 Expressive research — strategic contrast/shape/color/motion to help users find actions, while preserving familiar navigation and accessible controls. https://design.google/library/expressive-material-design-google-research
- Google Design: Making Motion Meaningful — animations communicate continuity and state changes instead of serving as decoration. https://design.google/library/making-motion-meaningful
- r/UXDesign, 2026-09-14: the "minimalism trap" and calls for product-derived repeatable motifs rather than generic neutral cards. https://www.reddit.com/r/UXDesign/comments/1wfxcll/how_do_you_break_out_of_the_minimalism_trap_as_a/
- r/UI_Design, 2026-05-06: hierarchy and identical card visual weight make a functional layout feel like a prototype. https://www.reddit.com/r/UI_Design/comments/1t5e3gn/struggling_like_crazy_with_design/

## UI design choices
1. Header is the signature: a burgundy gradient and hand-painted motion trail, rather than another neutral app bar.
2. Tab group uses a true selected state; shopping and food remain clearly "soon" with no dead navigation promises.
3. Activity history is scanned as a ticket: status/date → origin/destination → fare/detail. No separate date-section headers wasting vertical space.
4. Destination is typographically dominant; pickup is de-emphasized. Currency for Arabic Syrian fares is rendered as `ل.س` without changing underlying `Money` semantics.
5. Active trips are pulled from existing repositories and receive stronger contrast plus a tracking CTA; no active card is shown when there is no active trip.
6. If no ride is active and the user is viewing all history, a nonfake booking CTA fills the otherwise empty end of the feed.
7. Motion: staggered row reveal, press-scale on history tickets, filter switch fade/slide, animated selected tabs and active-dot entrance. All dynamic effects respect `MediaQuery.disableAnimationsOf(context)`.
8. Floating dock retains home/settings destinations and native navigation. It is a Trips-scoped visual exploration; coordinate a shared dock in a later app-wide design-system task before shipping.

## UX and behavior invariants
- `TripsListCubit`, repository pagination, refresh, filters, guest/localAccess and guarded API mode remain unchanged.
- No user-facing strings are hardcoded into widgets: all added labels are in feature Arabic/English ARB fragments.
- Verified through widget tests at small Arabic screens with 2x text and wider English tablet/landscape. Do not suppress system text scaling.
- UI data on the emulator is deterministic mock seed; the screenshot is not evidence of a live backend.
- Real Android screenshot: `activity-android-actual.png` in this folder, captured from emulator-5554, Android 14, on `Medium_Phone`.
- Existing Flutter golden in `apps/customer/test/features/trips/goldens/` is a structural regression image rendered with test font, not a substitute for this Android capture.

## Delivery gate
- Run `python3 scripts/dev/sync_feature_l10n.py` and `flutter gen-l10n` at integration; shared generated l10n artifacts are supervisor-owned and intentionally not committed by feature author.
- Tests: `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze --no-pub`, `flutter test --no-pub`.
- Visual/design acceptance: actual screenshot checked, but the user is final judge; do not claim production-readiness or guarantee a subjective reaction.
- Do not push, merge into main, run CI, edit ongoing Home worktree or reconfigure the emulator.
