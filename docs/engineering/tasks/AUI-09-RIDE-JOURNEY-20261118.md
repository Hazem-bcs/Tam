# AUI-09-RIDE-JOURNEY-20261118
Role: SUPERVISOR / DEVELOPER root. Branch ahmad-ui. Baseline e88e313.
Status: READY_FOR_REVIEW.
Integration base advanced to ccb7d08 while working; preserved other clients’ addresses/support merges.
Goal: TAM map-led ride planning, editable current-location pickup, active coupon selection/activation, refined matching and all live stages on one mounted map; resume current trip after returning/restarting.
Owned: ride_request presentation/domain/data and l10n/tests; active_trip composition/presentation/cubit/tests; app composition/router; shared mock trip persistence and tests; generated localization; task/delivery/API handoff notes. Existing unrelated work and main excluded.
References: all eight images attached in current request; interaction structure only, light central TAM theme and existing assets. No AI/ad buttons.
Interfaces: existing booking, active/current/fetch/cancel, maps and coupon pricing contracts. Preserve Auth, session isolation, localAccess and guest policy. API mode never falls back to mock.
Data: current configured mock/API modes. Durable mock snapshots isolated by local session identity, explicit logout/account switch clears scope. No tokens/authentication/offline booking queue. Existing v1 API and Postman remain source of server integration.
Required checks: targeted behavior/layout/continuity/restoration tests, format/analyze/full suite at delivery milestone, Android rendered review. Existing broad-suite failures reported separately.
Available: local Flutter, adb and running emulator. No real backend connected. No delegation requested.

Delivery: docs/ahmad-ui/deliveries/AUI-09-RIDE-JOURNEY-20261118/REPORT.ar.md. 176 focused tests + 4 render tests passed; 42 changed Dart files analyze/format clean. Full suite865/46 with failures disclosed; no push/main merge.
