# Ahmad UI — Design Contract (v1)

**Variant:** `ahmad-ui` (a separately maintained design release line). **App brand:** TAM | تم — do not rename the public-facing app to Ahmad UI.

## Objective and source priority
1. The **customer-only** reference images in [REFERENCE_GALLERY.md](REFERENCE_GALLERY.md) are the visual brief (UI-01–UI-13 and UI-15, including composites). They are not code and do not automatically authorize new product behavior.
2. `AGENTS.md`, `docs/engineering/design-system.md`, `docs/architecture/0001-frontend-architecture.md`, and `docs/engineering/parallel-work.md` remain mandatory.
3. `ahmad-ui` is a **new visual direction based on the manager's references**, not a recolor of the existing Home and not a request to change the existing `main` design.
4. Preserve domain behavior, data contracts, current Auth/guest/localAccess semantics and application routes unless the supervisor expressly approves a behavior/API change.
5. If the JPEG references conflict with current code or the design system, the UI lead proposes **one central Ahmad-variant-specific** resolution; feature owners cannot create one-off palettes, fonts or shared control variants.

## Aesthetic and UX bar
- Premium, natural, restrained and distinctive. Hierarchy comes from typography, spacing, rhythm, purposeful negative space, effective control placement and clear content.
- Refine the references for modern mobile UX. Keep their intended screen purpose and information hierarchy, but do not trace broken spacing or outdated phone mockup borders literally.
- Avoid cinematic AI-generated background pictures, landmark/car hero photography, meaningless 3D decoration, bloated cards, repeated CTAs, duplicate navigation destinations and visually false inputs.
- Functional vector/SVG icons for controls; carefully built/approved WebP or vector illustrative assets where useful. Use existing company-owned references or create new assets only under the asset owner's task. Do not copy driver mockups.
- Preserve purposeful motion: meaningful feedback, consistent durations and easing, coherent entry/exit, touch response; respect reduce-motion, battery/GPU load, and Rive runtime limits.
- Use the **central, variant-specific** `ThemeData`, semantic `ColorScheme`, typography/tokens, shared widgets and the RTL/LTR ARB workflow. No feature-local hardcoded palette or independent design system.
- Usability: entry, back, state continuity, offline/loading/error/empty, disabled and success handling. No fake booking or API behavior.

## Layout & accessibility
- Arabic RTL and English LTR, directional paddings, phone numbers LTR.
- 320dp, 390dp, 600–840dp+, landscape; text scale 1x and 2x (more if sensitive), SafeArea and keyboard.
- Touch targets >= 48dp, semantic labels and focus order, contrast, proper truncation/wrapping, no pixel overflows. Dark mode is not in scope unless explicitly assigned.

## Scope and ownership
- Source repository `Hazem-bcs/Tam`; variant branch `ahmad-ui`. All task PRs target **`ahmad-ui`**, never `main`.
- Agent branches start from the supervisor-approved **design baseline** within `ahmad-ui`; the original `ffad266...` is only the initial fork point. Do not blindly rebase on shifting heads.
- One writer per file, independent task branches. `app/theme`, `app/router`, `app/di`, shared widgets, `lib/l10n`, `pubspec`, core, and the ride-request shared shell are supervisor-controlled.
- Each feature owner reads the relevant references visually, reports constraints, and edits only the explicit owned presentation files/tests. Preserve domain/data unless the task specifies otherwise.
- Each PR contains before/reference/after images, tested configurations, exact SHA, scope, tests/limitations, and behavioral changes (ideally none). A reviewer cannot approve their own PR.

## Fast cloud-first delivery
- Existing `.github/workflows/ui-preview.yml` renders Home, Trips, Notifications and Settings as Flutter test snapshots on GitHub Ubuntu runners; do not misrepresent these as Android emulator screenshots.
- CI owner extends preview coverage for Ahmad customer screens in a dedicated workflow when necessary; PRs can use the existing workflow where supported. CI should be authorized and cost-aware, including the self-hosted legacy performance runner.
- Batch comprehensive checks at a review milestone, not after each padding tweak. Every PR needs focused tests, Flutter rendering/screenshot evidence and a reviewer verdict for the exact commit SHA.
- Shared image comparison board: [README.md](README.md). Original references: [REFERENCE_GALLERY.md](REFERENCE_GALLERY.md).
- Integration lead alone merges verified changes into `ahmad-ui`, performs cross-screen navigation/semantics checks and manages version reconciliation. **Do not merge `ahmad-ui` into `main`.**
- The customer-visible two-design launch needs separate build outputs (one per design branch) or an approved Flutter flavor solution later; a branch itself does not simultaneously ship two variants.

## Review gates
**G0:** central Ahmad style contract and shared tokens signed off.  
**G1:** screen-wise reference interpretation, independent golden preview and user/UX review.  
**G2:** feature PR accepted at SHA and merged into Ahmad integration line.  
**G3:** complete Android flow, offline/route/OTP validation, artifacts, separate production builds and final owner approval.

**Do not mark G3 complete just because GitHub Actions widget tests are green.**
