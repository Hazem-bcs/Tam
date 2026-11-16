# RIDE-POINT-CONTINUITY

- Owner: root / SUPERVISOR; INTEGRATED after READY → IMPLEMENTING, 2026-11-16.
- Baseline: `a58616f400fc0e5680967316884eab97843333df`; branch `codex/ride-point-confirm-continuity` in the existing customer checkout.
- Scope: point confirmation ordering in RideRequestPage; native and raster map viewport retention for an adopted point and its asynchronous route; panel-only fade/short slide and sizing; two focused regression tests. Root task documentation is supervisor-owned.
- User reference: attached screenshot at the “اعتماد الوجهة” action. AGENTS, portable protocol, existing journey/map components and tests consulted. No missing design context or new assets.
- Acceptance: one mounted journey/map; draft contains the endpoint before selection clears; confirmation preserves camera zoom/position and insets even when route arrives; My Location can still explicitly refocus; old panel content does not reserve height or accept taps during transition. Reduced-motion behavior retained.
- No route, booking, Auth, API contract, dependency, theme or localization changes. Existing entry → vehicle → review behavior retained within one page.
- Existing map controllers and journey page were already above the preferred 300-line guideline; the cohesive lifecycle/controller implementation is retained to avoid an unrelated split.
- Validation: 5 confirmation/GPS/navigation tests pass; all 7 native map tests pass (the new viewport regression is included in both selections). Formatting/diff checks pass. Focused analysis: 11 pre-existing info diagnostics in native_vector_map.dart; no errors/warnings. Broad checks deferred per iteration agreement.
- Emulator: existing Medium_Phone reused, Flutter attach plus hot reload; no APK build or downloads. The existing map/pin/card were inspected at 1080×2400. The final native+raster fix was hot-reloaded successfully; the emulator subsequently showed Account, so no further navigation or final motion recording was forced. Tests verify center/zoom retention in both renderers; physical-device frame pacing was not measured.
- Delivery: merge into customer local main and synchronize to Ahmad's main under the user's ongoing authorization. No driver changes or Actions.

Additional regression: the raster journey test asserts identical camera center and zoom at 0/60/300 ms after confirmation; passes. Full-app verification remains deferred. No extra application screens or routes were added.

## Follow-up: panel motion (2026-11-16)

- READY → IMPLEMENTING → INTEGRATED, root/SUPERVISOR, baseline `a351c036d1eae05ca1b5e112e2fe4f4d676c8abf`; branch `codex/ride-panel-motion`. Ownership: ride_journey_shell.dart and ride_journey_panel_content.dart only, plus this task record.
- User feedback: map motion is accepted; panel changes still feel abrupt. Keep the same persistent Material surface/handle and animate only its content height. Synchronize incoming/outgoing opacity and restrained directional translation with the existing 300ms theme token. The existing reduced-motion and keyboard behavior remain. No map/navigation/data changes.
- Dart format and focused analysis of both files pass with zero diagnostics. The existing map-confirmation regression passes, covering confirmation frames, unchanged camera and mounted map. Broad tests/builds deferred under iteration agreement.
- Existing emulator connection reused with a successful hot reload; no APK build, package download or additional UI navigation. Physical-device animation pacing has not been measured.
