# TAM-LOCATION-DESIGN-02

Role: root supervisor / implementation. User assigned, READY → IMPLEMENTED (awaiting user visual evaluation).
Baseline: 107497f1df22e8a9d09d52756093edd767c85c85.
Branch: codex/ride-location-design-20261116, checkout tam-integrated-20261115.
Scope: ride location/header, map controls and selection drawing/interaction, feature ARB and generated translations, focused navigation/layout checks and Android preview.
Reference: user screenshot /tmp/codex-clipboard-09f501f0-e6dd-49ec-81f6-fa4254a79916.png and accepted generated concept exec-543fe33e-db12-450e-aff8-f6a60ece6af6.png.
Acceptance: three named phases, lighter back/location controls, no +/-; compact point card without coordinates, role selector + one confirmation, optional description, vector pin/shadow, pan selection. Central theme/RTL/text scaling maintained. Auth/contracts/vehicle artwork excluded.
Read: AGENTS, task protocol, working agreement, design system, navigation, architecture ADR, delivery phases, coordination and task board.
Tools: local Flutter/Android available, existing emulator reused. Broad tests deferred per iteration preference; one focused check for selection/navigation and one offline build for requested preview. No push/main merge authorized for this task.

Delivery: docs/engineering/deliveries/TAM-LOCATION-DESIGN-02/HANDOFF.md; Android screenshot included.

User follow-up at2386368: repair abrupt tapped-point transition. Native camera animation, immediate tap feedback, debounced padding serialized after recenter; focused interruption regression and Android preview. Same file ownership and exclusions.

User follow-up at e41c919: accuracy reported restored; prioritize calmer motion and smaller non-obscuring instruction. Keep map stationary on visible-point taps, short local pin feedback, native projection for dragging at the actual pin anchor, preserve collapsed card during picking. No main merge requested for this follow-up.

User follow-up at1bd6343: fix My Location camera action and visible permission/service failures even with collapsed sheet. Ownership extends Maps camera-focus presentation, RideLocationCubit, feature ARB/generated l10n and focused location tests. Explicit fresh acquisition and camera intent; preserve manual pickup/destination. Android preview authorized.

Location-button follow-up completed: 58 focused tests passed, offline Android build 7s, actual permission dialog + GPS-off settings action + successful automatic return verified. GPS restored enabled. Separate local locationpreview package avoids concurrent standard-app installs. Evidence in handoff. Full suite/analyze and main merge deferred.

User follow-up at f4f567a: READY → IMPLEMENTING, root supervisor/implementation. Implement accepted horizontal bottom entry card (reference exec-0ec378b6-3d18-452d-94de-e9f25c50ec3a.png). Owned: RideJourneyEntry and its presentation-only route connector, delivery evidence; existing localization keys reused. Preserve editing, folding, GPS, native map and endpoints. Tools available: local Flutter/Android, existing emulator. Focused responsive check for long addresses/text scaling, one offline build for requested preview; broad checks deferred. No main merge/push.

Horizontal-entry follow-up IMPLEMENTED: presentation-only, central theme and existing l10n; 9 focused journey tests pass, offline Android build6s, Arabic emulator entry/selected state reviewed. Evidence: android-horizontal-entry.png. Broad verification deferred; no main merge/push.
