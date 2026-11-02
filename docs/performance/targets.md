# Automated performance goals

Workflow: `.github/workflows/performance.yml` on every push to `main` or `hazem-dev`, and pull requests targeting either.

Reports: GitHub Actions run Summary + artifact `performance-metrics`. The first successful run is the baseline; later runs compare against the most recent successful report on the same branch (fallback main).

| Goal | Target | Current CI | Status |
|---|---|---|---|
| UI smoothness | 60 FPS at 60 Hz; frame time budget 16.7 ms | No representative animation/map screen | UNMEASURED |
| First usable screen | Defer optional bootstrap, investigate >2 s | Android `am start -W` TotalTime | EMULATOR PROXY |
| Cached data | Show safe stale data, refresh and invalidate | TTL unit test | PARTIAL |
| Driver positions | 0 full map remounts during marker updates | Real map not implemented | UNMEASURED |
| Low-end RAM | Establish device baseline, avoid regressions | Android `dumpsys meminfo` PSS | EMULATOR PROXY |
| Offline recovery | Resume without duplicate ride confirmation | No real booking API yet | UNMEASURED |
| APK size | Investigate >5% increase, provisional 50 MiB budget | Release APK file bytes | MEASURED |

**Never claim 60 FPS on a physical device based on emulator timings.** Run profile-mode tests on an actual low-end phone after the map screen exists. Hosted Android emulators produce noisy PSS and launch times.

CI jobs build release APKs and use Android emulators after every push. Private GitHub repositories may incur hosted Actions minutes beyond included allowance. No local laptop emulator or GitHub Actions was run before this workflow is committed.

A warning trend is not a failed gate; failing Flutter analysis/unit tests/build **is** a failed gate. Add real location streaming, map redraw counters and offline integration tests as those features are implemented.
