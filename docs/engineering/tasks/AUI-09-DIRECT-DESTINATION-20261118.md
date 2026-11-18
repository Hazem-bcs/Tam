# AUI-09-DIRECT-DESTINATION-20261118
Role: SUPERVISOR / DEVELOPER. READY task authorized directly by user.
Baseline: 9f33eb0, ahmad-ui, /home/hazem/projects/tam-ahmad-ui.
Scope/ownership: RideRequestPage, focused page regression test, this handoff.
Goal: remove introductory route CTA; open destination selection immediately; map confirmation goes directly to vehicle/fare when route is complete. Preserve current-location pickup and editable endpoints.
Integration: fetched origin/ahmad-ui and merged latest address/map refinements (eedfcba) without conflicts; existing support changes retained. No main changes or push.
References: current user screenshot; existing AUI-09 protocol and project instructions. Existing API/mock/auth contracts unchanged.
Verification: incremental Android debug build/install/run succeeded on emulator-5554; existing emulator reused. Focused destination-entry regression test recorded in /tmp/tam-direct-destination-test.log. Broad checks deferred per iteration pace; earlier broad failures remain in AUI-09 delivery report.
Visual: native UI hierarchy confirms route header and place picker with no introductory CTA; full visual screenshot review not performed in this follow-up.

Follow-up: user removed the persistent destination-search step too. Default scene now contains map and editable top endpoints only. Picker appears on endpoint tap, disappears after selection; complete routes show vehicle/fare. Shell keeps same map mounted when panel is hidden and clears its map inset. Focused regression 'shows only map until an endpoint is edited' passed. Android rebuilt/run; no broad suite repeated.
