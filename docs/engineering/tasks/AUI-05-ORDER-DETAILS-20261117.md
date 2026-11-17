# AUI-05-ORDER-DETAILS-20261117
Role: SUPERVISOR / DEVELOPER root.
Baseline: b0abce1, branch ahmad-ui.
Status: READY_FOR_REVIEW (assigned READY by root before implementation).
Owned paths: Trips details presentation, feature ARB/generated localization, shared trip display formatter and affected tests, task/report/board.
Reference: /tmp/codex-clipboard-5903ddf3-c104-4c17-9c67-910eceb4264b.jpg.
Goal: one scrollable order details page; remove trip timing timeline and detailed-trip link, use existing icons, show route/driver/fare/payment and preserve rating/support/cancel/rebook.
No Domain/Data/Auth/main changes, fabricated metrics/settlement/discounts or generated imagery.
Guidance: AGENTS, portable task protocol, design system, navigation, working agreement and Ahmad UI design contract.
Verification: 30 focused tests passed; focused analyzer clean; native Arabic upper/lower screen review via existing emulator; Hot Reload success.
Limitations: absent stored distance/duration, discount breakdown, payment settlement or historical driver show unavailable. Rating remains existing separate form linked with same trip id.
