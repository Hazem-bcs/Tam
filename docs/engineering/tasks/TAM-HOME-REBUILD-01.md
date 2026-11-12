# TAM-HOME-REBUILD-01 — Radical Home redesign (phase 2 / customer)

**Role:** Codex implementing developer and critical design reviewer (one owner).
**Owner / authority:** User-directed redesign task; no concurrent writer is assigned to these files in this checkout.
**Starting commit:** `98c5226eee7c54cfaf0385905cd9fc3c49239551`
**Worktree:** `/home/hazem/projects/tam-home-rebuild`
**Branch:** `codex/tam-home-rebuild-20261112`
**Goal:** DELETE/REPLACE the old Home **presentation composition** and produce a genuinely original production Flutter Home design, not cosmetic polish. Keep all existing business behavior, source-of-truth models and feature boundaries. One page only.

## Mandatory preflight
1. Read `AGENTS.md` (real file, not Agent.md), `docs/engineering/agent-task-template.md`, `docs/engineering/parallel-work.md`, `docs/engineering/working-agreement.md`, `docs/engineering/development-phases.md`, `docs/engineering/design-system.md`, `docs/engineering/design-reference-index.md`, `docs/engineering/mock-api-policy.md`, `docs/engineering/navigation.md`.
2. Read `docs/engineering/tasks/TAM-HOME-REBUILD-01/REFERENCE_MANIFEST.md`, `DESIGN_BRIEF.md`, `IMAGE_FIRST_GUIDE.md`. **Visually open the bundled local PNG/JPEG references before coding. DO NOT use Figma or depend on its access.** The optional Figma URL is provenance only; use screenshots as visual source.
3. Confirm `git status`, branch, HEAD, repo remote; verify this is not the working original checkout. Preserve any unexpected uncommitted changes.
4. Review `apps/customer/lib/features/home/`, app shell/router, central theme/tokens, l10n, Home contracts and existing tests. Identify all required interactions and UI states before deleting layout code.
5. Check free disk space. Do not launch CI, build emulator from scratch, or use software rendering.

## Owned paths
- Primary: `apps/customer/lib/features/home/presentation/**`, related `apps/customer/test/features/home/**` and visual QA evidence under `docs/engineering/deliveries/TAM-HOME-REBUILD-01/**`.
- Central theme/tokens/ARB/shared controls are **shared architectural boundaries**. New visual identity is allowed and expected: create a coherent *opt-in* set of semantic Home tokens/roles in the central design layer if needed, without silently changing the look of every other screen. Before editing shared files verify no ownership conflict; document tokens and impact. No hardcoded scattered palette and no duplicate ThemeData inside Home.
- Read-only: `features/home/domain/**`, `features/home/data/**`, Auth, router, AppConfig, API/Postman, all other features and historical company assets.
- If an accessible local asset needs to be bundled, only add it with a valid license/permission, explicit file size checks, and no misleading map/photo content.

## Critical constraints
- The existing Home layout hierarchy is **disposable**. Do not preserve its hero card/service-grid arrangements simply to make a diff small. Rebuild it from a blank composition when appropriate; delete obsolete home-only presentation widgets only after all required behavior is migrated.
- **Do not artificially keep the existing burgundy palette** if it conflicts with the selected new direction. The old UI style is not a fixed requirement. New color/typography choices must be reasoned, centrally owned and introduced safely without forcing unreviewed redesign onto other screens.
- **Never** delete the Flutter app or its business layer; keep Domain/Data/BLoC, mocks, Auth, routes, repository contracts, navigation callbacks, localized content, loading/empty/error/retry, accessibility, and existing automated tests.
- Home ONLY this iteration. Do not redesign booking, trip history, settings, or authentication. The first customer-facing CTA may open the existing booking flow unchanged.
- The company UI-04 is a **content/feature reference, not a template to copy**. The browser/Figma prototypes depict illustrative journeys; never reproduce them as live geospatial data or invent driver/price/route status.
- No unrelated dependencies; justify any new animation/asset package. Respect device reduced-motion and battery constraints.
- No push, merge to main, GitHub Actions, unrelated PC changes, or remote deployment.

## Execution contract (do all stages, not just advice)
1. **Inventory:** map existing content, navigation and user actions. Save a one-page behavior-preservation checklist.
2. **Design challenge:** critically compare the actual bundled Urban Pulse vs Fluid Continuity PNG screens, Editorial Mobility typography principles, and company UI-04. Build at least **two materially different Home visual compositions** (quick design boards or screenshots), critique them (originality, usability, Arabic typography, visual hierarchy, implementation cost) and select one with reasons. A third hybrid is optional. Note: bundled C/A HOME screenshots show a ride-entry concept, **not a finished multifunction Customer Home**; derive a NEW Home layout rather than copying the sheet wholesale.
3. **Home rebuild:** implement the selected Home composition in Flutter as **new focused, testable presentation components**, with purposeful motion and clearly changed layout. Don't just add a curved line, adjust padding, or change a card border.
4. **Polish:** maintain genuine connected data/state and all original navigation. Verify responsive and a11y (320dp 2× Arabic, 390dp AR/EN, 800dp tablet, landscape/keyboard), focus states and reduced-motion.
5. **Test & render:** run `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze --no-pub`, `flutter test --no-pub` from `apps/customer`. Reuse the running emulator, and when needed start it only with `/home/hazem/.local/bin/run-emu Medium_Phone`. Capture authentic before/after screenshot(s). Do not assert 60fps unless measured on-device in profile mode.
6. **Handoff:** deliver final commit SHA, branch, changed files, conceptual rationale, exact tests and results, before/after screenshot paths, limitations and deferred next-page items. Stop after **Home**: do NOT modify other screens.

## Acceptance gate
- Visible structural transformation immediately recognizable from an Android screenshot; not another polished variant of the old screen.
- Preserved Home interactions: guest/temporary entry, real localization, notification count/button, saved addresses, active trip entry, ride CTA, services and unavailable states, promotions, trips/settings bottom navigation, sign in/out, retries, loading/error/empty.
- No fictitious booking/payment/destination, fake map tiles or nonfunctional 'working' actions.
- No overflow, focus loss or inaccessible taps at required viewports.
- Tests pass; any pre-existing failures explicitly separated from newly introduced ones, never hidden.
- Output marked **READY_FOR_REVIEW**, not visual approval or release-ready without independent review.

**Task status:** READY for Codex to start on the dedicated branch.
**Image-first mode:** All visual references required for implementation are bundled as local PNG/JPEG in the task's `references/` folder, extracted from our existing browser design prototypes. Figma is not needed and must not block the task. These are browser prototype captures, not direct Figma exports. The URL is optional provenance only.
