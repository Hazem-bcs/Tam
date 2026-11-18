# AUI-11 — follow captain and road routing
Role SUPERVISOR/DEVELOPER root; READY direct user request. Baseline 6d7474b, ahmad-ui.
Scope: map camera follow with manual-pan pause/recenter; replace misleading synthetic geometry with provider-backed road geometry when a routing provider is supplied. Existing no-public-routing preference remains unless user authorizes a demo provider. Asked user for provider choice; camera work independent.
Owned: maps configuration/domain/data/rendering, active_trip mock route integration, ride journey plumbing, l10n maps fragments/generated integration and scoped tests/docs. Other clients' branding/Auth/Home/platform edits are preserved.
Verification: focused camera tests, provider contract/error tests, route simulation continuity, actual emulator run. No main/push/CI.

Camera implemented for native and raster maps, with smooth first focus, continuous follow, gesture pause and resume button, insets, reduced-motion support, throttled native commands and final flush. Synthetic paths flagged road_aligned=false and no longer rendered as road routes; genuine provider geometry remains supported unchanged. No public provider activated: user choice is still pending in the async question. Road-network simulation remains incomplete pending that input.
Checks: native camera suite8 passed, active contract/geometry8 passed, raster gesture and synthetic-line guard2 passed after fixing lazy ticker initialization. Maps/shared/ride/active changed surface analysis clean before final focused changes; final verification recorded separately. Platform map files already exceed300 lines and retain their lifecycle/gesture ownership to keep this change focused. Unrelated brand/Auth/Home/platform work preserved.
Final: camera/line-guard READY_FOR_REVIEW, routing provider choice STILL_PENDING. 102/102 scoped tests and final analyzer clean; Android screenshot reviewed. Preserved concurrent branding commit8842b19. Report: docs/ahmad-ui/deliveries/AUI-11-FOLLOW-ROADS-20261118/REPORT.ar.md.

متابعة: المستخدم اختار OSRM صراحة2026-11-18. التنفيذ والتسليم الحالي في AUI-12-OSRM-20261118؛ فقرة STILL_PENDING أعلاه توثق الحالة السابقة فقط.
