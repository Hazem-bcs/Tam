# Working agreement

The mandatory coding and UI standards for every feature are maintained in
[`AGENTS.md`](../../AGENTS.md). They cover practical Clean Architecture, Clean Code,
SOLID, DRY and KISS; shared application theme/configuration; responsive layouts;
localization, accessibility and validation. Apply them consistently to Home and
all later features. Follow the [architecture ADR](../architecture/0001-frontend-architecture.md)
and [design system](design-system.md) for the established implementation patterns.

For the current five-owner wave, follow the [team plan](wave-one-plan.md),
[task board](task-board.md), [mock/API policy](mock-api-policy.md) and
[backend handoff checklist](api-handoff-template.md). The user authorizes
isolated mock-backed development until the backend is ready; Auth remains
on its existing temporary phone-entry flow.

The user adopted a [two-phase delivery plan](development-phases.md) on
2026-11-08: complete architecture, Domain/Data, working flows, integration and
API contracts with usable preliminary UI first; refine every screen visually
after the agreed application flows are complete. Record visual follow-ups,
but do not block phase-one integration on polish alone. Correct behavior,
session isolation, shared theme, responsiveness and accessibility still apply.

- Default branch: `main`; use short-lived branches with the repository/tool's configured prefix. The current wave proposes `codex/w1-*`, independently of the agent provider. Start from the supervisor's exact baseline, not necessarily `main`.
- Pull request should state scope, before/after images for UI, risks, test evidence and rollback plan.
- Review requirements: `dart format`, `flutter analyze`, `flutter test` on touched project.
- No giant `utils.dart`, no global mutable state, no business rules in widgets, no magic string route names.
- Repositories expose domain models and failures, not Dio exceptions or JSON.
- Cache invalidation and error/offline states must be part of every feature's acceptance criteria.
- Avoid overengineering: an abstraction must protect a real boundary or simplify testing.
- No automatically triggered GitHub Actions at bootstrap.
- Arabic RTL, text scaling, semantics, disabled/loading/error states and accessibility are required for UI review.
- API keys restricted by application IDs/API scopes; backend secrets must never be packaged into Flutter.
- Performance: profile on representative low-end devices, poor-network conditions and in release/profile mode. Targets are verified, not asserted.
