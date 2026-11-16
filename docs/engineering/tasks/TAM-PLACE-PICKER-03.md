# TAM-PLACE-PICKER-03
Role: root supervisor / implementation. User assigned READY → IMPLEMENTING.
Baseline: 9403d95; branch codex/ride-location-design-20261116, tam-integrated-20261115.
Reference: accepted exec-0d057a8d-71bf-4974-b60e-2369041586a7.png / user screenshot codex-clipboard-d2c8eea5-d694-4bde-93e0-a53b63acf6ca.png. Remove management action explicitly.
Scope/ownership: ride place picker/stage presentation and focused place sheet, saved-address picker presentation/entry and ride composition entry, RideDraftBloc empty-query cancellation, feature ARB and generated l10n, relevant focused tests and delivery evidence.
Acceptance: compact floating sheet, one title and opposite-endpoint context, search field, slim map action, real repository-backed saved shortcuts before typing, search results after typing, no tabs/management/arbitrary initial suggestions. Editing pickup and destination, selection/navigation, existing error/loading/empty states, RTL/LTR/text scale/keyboard preserved.
Excluded: Auth, map SDK/camera, backend contracts/modes/fixtures, new packages, address management pages, main merge/push. Existing address/search contracts unchanged; mocks remain isolated and centrally selected.
Guidance read: AGENTS, portable task protocol, working agreement, architecture ADR, design system, navigation, parallel plan, task board and iteration pace rule (same session).
Tools available: local Flutter/Android, existing emulator reused with isolated locationpreview package. Focused behavior/layout checks for switching saved/search, cancellation, keyboard/text scaling; one offline build/preview. Broad suite/analyze deferred per user preference.

Status: IMPLEMENTED, awaiting user visual evaluation. Evidence: docs/engineering/deliveries/TAM-PLACE-PICKER-03/HANDOFF.md. 9 journey + 3 focused picker tests passed; offline build/Arabic emulator review complete. Broad checks deferred; no main merge/push.

User follow-up at d3d9679: READY → IMPLEMENTING, quick automatic panel expansion on placing a point. Ownership adds RideJourneyBody/Shell and existing journey regression expectation. Expand on a changed selected point without resetting the point form; retained map and existing reduced-motion animation. Requested hot reload, no broad checks or main merge.

Automatic expansion IMPLEMENTED; hot reload successful (3 libraries,3326ms), format/diff pass. No new build or test run.
