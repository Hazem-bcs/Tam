# CF-TRIPS — implementation handoff

Task/role: CF-TRIPS / DEVELOPER, READY_FOR_REVIEW.
Baseline: `1b8890049177b56b3ce8e2c0254b622defa95bbf`.
Branch: `codex/customer-feedback-trips-20261118`.
Worktree: `/home/hazem/.codex/worktrees/customer-feedback-trips/mashwar`.
The exact submitted commit is supplied to the supervisor; approval must refer to that SHA.

## User-visible results

- F03: reject non-road-aligned legacy tracking geometry, so it cannot suppress configured real routing while the renderer hides the synthetic line. Retain phase/end-point checks and never invent a road line. Map-scoped route conversion cache and separate live-map BlocBuilder retain the mounted map and avoid rebuilding the driver/actions panel for position-only ticks; ETA minute/status/driver/error changes still rebuild it.
- F02: driver contact buttons stack below 400dp of available content width; the active heading and driver card are more compact. Rating submit/support buttons stack below 440dp, preventing the Arabic support word splitting into individual letters. Trip details use ambient typography, scroll-dismiss the keyboard, and cancellation confirmation scrolls.
- F06: completion begins with a small recorded-total summary; trip ID/date/endpoints/driver remain in expandable details. Explicit home action appears immediately after essentials and a home icon stays accessible in the app bar even with large text or an open keyboard. The rating contract/state machine and immutable saved rating remain intact. Reduced-motion feedback bypasses AnimatedSize entirely, fixing a real-font zero-duration layout mutation exposed during verification.
- F02 chat/support: a very short landscape keyboard viewport can scroll the whole conversation to the composer. Header/status have bounded scroll areas. Read acknowledgements also intersect the actual visible screen, including keyboard insets. Support's count occupies native input counter space, grows with text, and remains LTR; decorative hero artwork gives the text full width on small screens/large text.
- Integration request from supervisor: trips list system bar icons derive brightness from the ambient color scheme, including dark mode.

All changed handwritten files remain below 300 lines. No Auth, route policy, backend credentials, feature modes, shared trip storage/domain, API endpoints, theme definitions or booking widgets were changed. Only completion feature ARB fragments are committed; generated shared localization outputs are intentionally left local for the supervisor to regenerate during integration.

## Route investigation

The recorded tested APK source `ea71aae` already includes:

- `6eba09d` / equivalent published preview changes: real map previews for valid endpoints.
- `6d7474b`: driver movement with phase routes.
- `a0ecac0`: hide synthetic road lines.
- `82afff9`: real OSRM routes for simulated drivers.

These commits are ancestors of this task's baseline. No old implementation was blindly restored. Reproducible missing-line path: `activeTrackingGeometry` accepted `roadAligned=false`; `RouteMapView` skipped repository loading for a non-null tracking route, then `TamMapCanvas` intentionally hid that same unaligned route. Returning null for the unusable tracking route permits configured real route loading. This is a source-verified reproduction, not proof of the exact packet/network state shown in reference 01. Real geometry can still be absent when routing is loading/unavailable; the app must retain its honest failure state.

## Verification actually performed

Environment: Linux Flutter widget-test renderer, cached Flutter SDK and offline dependencies. `flutter pub get --offline` succeeded without tracked dependency changes. Feature ARBs synchronized and `flutter gen-l10n` succeeded.

Focused runs from `apps/customer`:

1. `flutter test --no-pub test/features/active_trip/customer_feedback_route_test.dart test/features/chat/customer_feedback_keyboard_test.dart test/features/completion/customer_feedback_completion_test.dart test/features/active_trip/active_trip_widget_test.dart test/features/chat/chat_widget_test.dart test/features/chat/chat_visibility_test.dart`: **45 passed**.
2. Selected completion layout/widget, support widget, trip route adaptive tests: **34 passed**. The initial command additionally named three new tests before they existed and reported three missing-file load errors; those files were created and pass in run 1. This was a command sequencing error, not a hidden product failure.
3. Real-font screenshot run initially exposed the reduced-motion AnimatedSize error; fixed in the product, then relevant completion quick-feedback/layout/screenshots: **22 passed**.
4. Final screenshot/layout integration run: `flutter test --no-pub --update-goldens --dart-define=CF_TRIPS_UI=true test/features/completion/customer_feedback_visual_test.dart test/features/trips/trips_system_bar_test.dart test/features/support/support_widget_test.dart test/features/completion/completion_layout_test.dart`: **36 passed**. It covers RTL/LTR 320/390/800dp, 2x text, landscape and keyboard, dark/light system bars, and all screenshot cases.
5. Focused `dart analyze` over the five owned presentation directories and changed/new regression tests: **No issues found** (rerun after final changes before commit).
6. Final evidence capture with settled scroll positions plus completion save/home/reopen: **10 passed**. Route fallback integration additionally verifies one real repository lookup and a road-aligned route reaching TamMapCanvas: **4 passed**.
7. Touched files formatted and `git diff --check` clean.

The new tests also verify saved mock trip/rating persistence across disposing and reopening the completion page, route identity and phase rejection, mounted map preservation, position-only panel filtering, send reachability and draft preservation with a 740x320 / 2x text / 200dp keyboard.

### Actual visual evidence

Original three feedback references were inspected before implementation. Generated and visually inspected PNGs under `screenshots/` use real preview fonts in the Flutter widget renderer:

- `completion-ar-390.png`, `completion-ar-320-x2.png`, `completion-en-800.png`: compact summary/home and scrolling with large text; app-bar title remains readable.
- `completion-rating-ar-390.png`, `inline-rating-support-ar-390.png`: selected rating and full-width support label.
- `contact-ar-390.png`, `contact-en-390.png`: stacked full-width driver actions.
- `support-ar-320-x2.png`: growing field and correct LTR count.
- `chat-en-landscape-keyboard-x2.png`: send/input visible with draft, after scrolling the tiny viewport. The test inset is simulated, not a rendered Android keyboard.

These are widget-rendered screenshots, not Android/native-map verification. Native road rendering, integrated dark theme, actual keyboard/device navigation and combined application flow belong to supervisor integration QA. The page scrolls at 2x text rather than compressing or capping system text scaling.

## Performance limitation and reproducible next step

**No representative real-device profile measurement was available. No before/after frame-time numbers, APK performance claim or 60fps claim is made.** Source-level work is justified by eliminating repeat GeoPath conversion and panel rebuilds for unchanged UI inputs; tests verify those boundaries, not device frame times.

At the agreed integration milestone on a physical Android device:

1. Checkout the baseline and integrated candidate separately; use the same routing mode, device, refresh rate, theme/text scale and deterministic trip/endpoints. Record device/OS/build SHA and thermal/power state.
2. Use `flutter run --profile -d <physical-device-id>` (not run by this task). Open the same trip details and active trip; wait for the road route to load, then record opening, 30s tracking, panel drag/collapse, back/reopen and keyboard scenarios in DevTools Performance.
3. Save before/after timeline exports; report build/raster p50/p90/p99, >16.67ms frames for 60Hz, longest frame, UI/raster slow-frame counts, and map-controller recreation/network-route counts. Include first-load and warm-route runs separately.
4. Inspect native map work as well as Flutter frames. Do not infer device frame times from this widget renderer or an emulator.
5. Shared `maps/presentation/widgets/driver_map_motion.dart` currently intentionally throttles marker repaints to >=33ms (roughly 30fps). It was outside this assignment's ownership. Evaluate that tradeoff with representative profile evidence before promising 60fps driver motion.

## Remaining constraints

- Full `flutter analyze --no-pub`, full tests, Android build and the sole emulator were deferred to the supervisor's integration milestone as assigned; no app/emulator was launched here.
- Approved legal copy remains unavailable: `MockSupportRepository.legal` explicitly returns null; `LegalPage`/`LegalCubit` select and validate terms/privacy correctly and show the honest unpublished state. No legal text was invented.
- Data remains mock/session scoped under the current defaults. No API contract change was needed because this changes presentation/routing fallback only, not backend operations or endpoint semantics.
- Booking deliberately keeps a stable `RideJourneyBackdrop` across request confirmation. Do not replace its backdrop with the new differently typed `ActiveJourneyMap` at the active transition, which would remount the existing map. The new cache/build boundary is used on the separate active page; the shared mapper fix also applies to booking's existing map.
