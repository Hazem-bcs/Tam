# AUI-10-LIVE-MOTION-20261118
Role: SUPERVISOR/DEVELOPER root. Status READY; baseline b9cdc8a, ahmad-ui.
Authorization: user requests smooth vehicle movement, correct heading, route drawing and backend-like simulation.
Owned paths: shared live domain/codec + focused geometry helper; active_trip simulation/presentation; maps rendering/motion; tests and API handoff for additive tracking geometry.
Preserve Auth, session policy, theme, existing uncommitted failure artifacts. No main/push/CI.
Acceptance: optional driver bearing and phase route survive codec/cache; mock emits same shape; route follows phase, car interpolates along geometry and turns by shortest angle; stale/teleport/reduced motion never imply continued movement; same map remains mounted.
Backend: no real transport connected; additive v1 proposal and fixtures/Postman examples documented. Mock geometry is synthetic, not road routing or map matching. Existing configured route provider remains authoritative for actual roads.
Checks: focused behavior/codec/geometry/render tests, changed-file analysis, actual emulator run; broad checks deferred to integration milestone.

Status: READY_FOR_REVIEW. Independent addresses commit fa2a465 arrived while working and was preserved. Handoff: docs/ahmad-ui/deliveries/AUI-10-LIVE-MOTION-20261118/REPORT.ar.md. Actual native screenshot recorded, scoped tests/analyzer passed after fixture correction; legacy app test still expects the previously removed details button and is disclosed. Real road routing remains a backend dependency, no public routing fallback added.
