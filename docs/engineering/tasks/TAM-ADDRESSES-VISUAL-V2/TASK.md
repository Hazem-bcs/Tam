# TAM-ADDRESSES-VISUAL-V2 — User-approved Addresses UI redesign

- Role: Developer, user authorized execution on 2026-11-16.
- Baseline: 9403d95a593c5e55ea09037d1fbd78a87d5f8028, latest local main at creation.
- Branch: codex/tam-addresses-visual-v2-20261116.
- Worktree: /home/hazem/projects/tam-addresses-visual-v2-20261116.
- Owned: apps/customer/lib/features/addresses/presentation, apps/customer/test/features/addresses, apps/customer/assets/images/addresses, task/delivery notes.
- Excluded: Domain, Data, map implementation, Auth, central router/theme/l10n, Rive, app-level nav, other worktrees. Do not merge/push/install until review.
- References: user-approved four-screen Arabic Addresses UI board (2026-11-16), TAM_Address_Icons_Production_v2.zip with six separate transparent 192px WebP files (generated this chat).
- Criteria: functional saved/empty/list, add/edit, location selection and delete with real callbacks; coherent brand style, no static full-screen screenshot; icon use only for category imagery, Flutter icons for commands; maintain keys; RTL and LTR, 320dp/390dp/tablet/large text/keyboard; existing tests plus expanded focused tests; honest QA and screenshots.
- Data mode unchanged; test mocks are mock, never assert backend persistence.
- Review phase: READY_FOR_VISUAL_REVIEW. User approval is for direction, not implementation quality.
