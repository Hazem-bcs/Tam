# Tam project instructions

These standards apply to every feature and change in this repository, including Home. Preserve existing uncommitted work and follow the current user's task scope. The Flutter-specific conventions below apply to `apps/customer`; use the corresponding framework conventions elsewhere.

These instructions are provider-neutral: they apply to Codex, Claude, Gemini and other agents. Do not assume automatic instruction loading, shared chat memory or vendor-specific tools. Start each assigned task with the [portable task protocol](docs/engineering/agent-task-template.md) and report unavailable context or verification capabilities explicitly.

## Architecture and code quality

- Follow Clean Architecture, Clean Code, SOLID, DRY and KISS in practical terms: clear responsibilities, explicit dependencies, readable names and cohesive, testable functions/classes.
- Keep Flutter feature-first under `lib/features/<feature>/`, adding `presentation`, `domain` and `data` only where needed. Follow `presentation -> domain <- data`; domain must not import Flutter, transport, storage or platform SDKs.
- Put business rules and asynchronous orchestration outside widgets. Repositories expose domain models and failures, not JSON, DTOs, Dio exceptions or SDK objects. Keep mapping and persistence in data implementations.
- Depend on focused domain contracts and inject implementations through the existing `get_it` composition root. Widgets must not resolve services from the locator or invoke HTTP, storage or platform services directly.
- Use the existing `flutter_bloc` stack and immutable feature states. Keep transient UI state local; scope providers/selectors and rebuilds to the feature/subtree that owns the data. Dispose controllers, subscriptions and resources correctly.
- Reuse established behavior and components. Extract shared code when it represents the same responsibility; do not couple unrelated features merely because their code looks similar. Avoid giant utility classes, duplicate sources of truth and global mutable application state.
- Add abstractions or use cases only for real boundaries, rules, orchestration or useful test seams. Do not add forwarding-only classes, speculative frameworks, packages or architectural layers without a concrete need.

## One application design system and configuration

- Every screen, feature, dialog, sheet and UI state must consume the central theme. Read semantic colors from `Theme.of(context).colorScheme`, typography from `textTheme`, and custom semantic roles from existing theme extensions.
- Do not hardcode feature palettes, `Colors.*`, hex colors or independent feature `ThemeData`/typography systems. Raw palette values belong in `lib/app/theme/app_colors.dart`; screens must not bypass the ambient theme by reading the palette directly.
- Use `app_tokens.dart` for shared spacing, radii, dimensions and elevation. Add genuinely reusable missing tokens centrally. Small feature-specific drawing/layout geometry is allowed; do not turn every local number into a global token.
- Reuse `TamButton`, `TamTextField`, `TamCard` and `TamLoadingIndicator` where suitable. Native themed Material controls and specialized inputs are allowed when they inherit the same theme and accessibility behavior. Avoid duplicating shared controls or adding wrappers with no purpose.
- A central theme change must propagate consistently to all features. Extend the shared design system when needed rather than creating exceptions inside a feature.
- Keep application-wide settings and feature flags in `AppConfig` or their existing central owner, dependencies in the composition root, and route paths/access decisions in `AppRoutes`/`RouteAccessPolicy`. Do not scatter duplicate settings, environment reads or route strings across features.

## Responsive, localized and accessible UI

- Design with constraints, `LayoutBuilder`, flexible layouts and sensible content maximum widths. Support small phones around 320dp, normal/large phones, tablets at 600–840dp and above, and landscape; do not stretch a phone form across a tablet or scale the entire page by screen width.
- Respect SafeArea, keyboard insets and system text scaling. Allow scrolling and control growth where necessary; prevent overflow, clipped text/inputs and keyboard-obscured actions. Never cap text scaling merely to force a layout to fit.
- Support Arabic RTL and English LTR through the existing ARB workflow. Use directional padding/alignment; keep phone numbers and verification codes LTR. Do not hardcode user-facing strings or introduce a separate localization mechanism.
- Include meaningful loading, empty, error/offline, disabled and success states where applicable. Provide semantics, readable contrast, adequate touch targets and feedback beyond color alone; respect reduced-motion preferences.
- Review actual rendered UI for visual changes and verify relevant phone/tablet sizes, text scaling and keyboard behavior. Use the existing theme and reference language consistently across features.

## Behavior, validation and delivery

- Preserve existing Auth behavior, guest access, the authorized temporary `localAccess` flow and the current `TEMPORARY_PHONE_ENTRY` default unless the user explicitly changes that scope. Local/guest access must never become backend authentication or grant access to protected routes/APIs.
- Do not fabricate production users, trips, drivers, credentials or service responses. Keep test doubles under `test/`; represent unavailable integrations honestly and preserve agreed API contracts.
- Test meaningful behavior, boundary/error cases and navigation/layout regressions relevant to the change. Avoid tests that only repeat implementation or trivial styling details.
- For Flutter code changes, run the appropriate checks from `apps/customer`: `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze --no-pub`, and `flutter test --no-pub`. Report actual results and any checks that could not run; documentation-only changes do not require Flutter builds/tests.
- Keep changes focused and preserve unrelated work. Do not automatically push, merge into `main`, run GitHub Actions or start expensive builds. Report real limitations; do not infer release readiness from a polished UI alone.
- For authorized parallel work, follow [the coordination plan](docs/engineering/parallel-work.md): isolate writers in worktrees, assign file ownership, review exact commit SHAs, and let the supervisor coordinate shared files and final integration.
- Read the relevant existing guidance: [working agreement](docs/engineering/working-agreement.md), [architecture ADR](docs/architecture/0001-frontend-architecture.md), [design system](docs/engineering/design-system.md), and [navigation](docs/engineering/navigation.md).

## Local Android emulator

- Reuse the emulator if it is already running correctly.
- When launching or restarting on this machine, always use `/home/hazem/.local/bin/run-emu Medium_Phone`.
- Never invoke `/home/hazem/Android/Sdk/emulator/emulator` directly, or use `-gpu swiftshader_indirect` or any software-rendering mode.
- Do not manually change NVIDIA, Vulkan, XWayland or GNOME Mutter settings; `run-emu` manages them.
