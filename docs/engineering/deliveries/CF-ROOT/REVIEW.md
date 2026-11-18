# CF-ROOT — independent review

Reviewer: CF-THEME owner acting independently as CF-ROOT REVIEWER.
Input implementation SHA: `856b990769bf14ca2ab4ea493ff2387ce3f43596`.
Reviewed baseline/diff: `1b8890049177b56b3ce8e2c0254b622defa95bbf..856b990769bf14ca2ab4ea493ff2387ce3f43596`.
Isolated review branch: `codex/customer-feedback-review-root-20261118`.
Worktree: `/home/hazem/.codex/worktrees/customer-feedback-review-root/mashwar`.
Final reviewed identity: containing review commit, exact SHA sent to supervisor.
Verdict: **APPROVED_AT_SHA** for this owned implementation with the integration prerequisites below. This does not approve the eventual combined app without its milestone checks.

## Scope and findings

Read AGENTS, task card and existing portable protocol/architecture/design/navigation guidance. Reviewed complete commit diff, surrounding Auth normalizer/field, coupon normalization/codec/fields/book, account identity layout, legal footer/routes/page, Arabic API proposal/examples/Postman and tests. Did not review own F07 implementation or later F16 changes.

- Phone: fixed +963 remains a presentation prefix; 9-digit local starts9 or10-digit local starts09 uses existing Auth normalization. Formatter accepts Arabic/Persian digits and digits-only bounded editing, strips complete supported international prefixes on paste, maps selection offsets through filtering/prefix removal and truncates to10 local digits. Auth session/domain contracts unchanged.
- Coupons: trim + ASCII Latin uppercase + Arabic/Persian digit normalization preserves Arabic identifier letters. Arabic fixture `تم10` is independent ofTAM10; duplicate/reset logic includes both. Transport validation rejects whitespace, bidi controls and overlength; docs and saved Arabic response agree with fixture. Account/Home activation stays simulated and does not imply real backend activation.
- Account: small phone OR large text uses stacked identity area. Phone stays selectable and LTR with wrapping; no forced text-scaling cap. Existing focused 320dp Arabic/800dp English case at2× passes.
- Auth overlay: status icon/navigation icon brightness follows ambient darkness; statusBarBrightness uses corresponding iOS appearance. No independent hardcoded feature palette added.
- Legal: existing terms/privacy routes are public, distinct and pushed from the real footer; BackButton returns correctly. No fictional legal content added. Approved published legal content remains unavailable and visible as such.

No functional blocker found in this scoped diff. Reviewer fixed analyzer findings only: removed unnecessary non-null assertion in NationalPhoneFormatter, sorted TripWireCodec imports, removed redundant services import in input test. These have no runtime behavior change; no functional regression test was needed solely for lint cleanup.

## Integration prerequisites, explicitly outside this reviewed SHA

1. After CF-BOOKING integrates, RideDraftBloc must call shared normalizeCouponCode/isCanonicalCouponCode instead of ASCII-only handling. MockRideRequestRepository must normalize the same way and accept MockRidePricing.couponCodes. Currently it still accepts onlyTAM10. Supervisor explicitly declared this deferred shared-file wiring before review; approval here does not imply Arabic pricing works before that patch. Add end-to-end Arabic quote→book→snapshot restore coverage at integration.
2. Merge F07 and review overall dark compatibility including Home/system overlays; final app persistence requires the agreed DI registration. The root Auth overlay code was reviewed statically here; an actual dark Android device rendering was not run.
3. Final combined format/analyze/test, Android build, emulator keyboard/navigation/RTL/large-text checks remain supervisor milestone work. Published legal text and real-device profiling remain external limitations.

## Actual independent checks

Flutter3.41.4 / Dart3.11.1, local Linux widget-test engine; copied ignored .dart_tool from ahmad-ui to reuse existing offline dependency resolution. No dependency or package edits.

From apps/customer:

```text
flutter test --no-pub test/features/customer_feedback test/features/ride_request/data/ride_coupon_contract_test.dart
11/11 passed.

flutter test --no-pub test/features/settings/settings_page_test.dart --plain-name 'layout at 320dp RTL and 800dp LTR with large text'
1/1 passed, covering both sizes/locales at2× text.

dart analyze <all11 modified product files> test/features/customer_feedback test/features/ride_request/data/ride_coupon_contract_test.dart
Final: No issues found! (initial1 warning+2 info fixed as above).

dart format --output=none --set-exit-if-changed <3 reviewer-touched Dart files>
3 files,0 changes.

git diff --check
Passed.
```

Postman JSON/saved response equality was verified by the passing coupon contract test; no Postman GUI import or live HTTP call. Visual verification in this review consists of widget layout/assertions, not inspected device screenshots. No full suite, build, emulator, push, main merge or Actions were run. Branch is frozen for supervisor integration/review handling.
