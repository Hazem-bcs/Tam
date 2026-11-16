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
