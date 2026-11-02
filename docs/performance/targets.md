# Automated performance goals

Workflow: `.github/workflows/performance.yml` on every push to `main` or `hazem-dev`, and pull requests targeting either.

Reports: GitHub Actions run Summary + artifact `performance-metrics`. The first successful **self-hosted** run is the baseline; later runs compare against the most recent successful report on the same branch (fallback main).

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

## Runner location (Ubuntu laptop)

- Developer working tree (review/edit here): `/home/hazem/projects/mashwar`
- Customer Flutter application: `/home/hazem/projects/mashwar/apps/customer`
- CI workflow: `/home/hazem/projects/mashwar/.github/workflows/performance.yml`
- CI scripts: `/home/hazem/projects/mashwar/scripts/ci/`
- Dedicated GitHub runner install: `/home/hazem/actions-runner-mashwar`
- GitHub CI checkout during a run: `/home/hazem/actions-runner-mashwar/_work/mashwar/mashwar` (ephemeral; **do not edit**)
- Durable reports (per branch and workflow run): `/home/hazem/projects/mashwar/.ci-reports/`
- Dedicated AVD: `Mashwar_CI_API34`, headless at emulator port 5590; never touch `Medium_Phone`.
- Runner service: `~/.config/systemd/user/mashwar-actions-runner.service`.

Runner labels: `[self-hosted, Linux, X64, mashwar-ci]`.
The pipeline only uses push to `main` / `hazem-dev` plus manual dispatch; **no PR events** because self-hosted runners execute repository code on the developer's personal computer.
This uses **local CPU, RAM, disk and power**. GitHub only queues the jobs and stores summaries/artifacts; offline/sleeping laptop means queued or unrun jobs.
Runner is configured as a systemd user service using account `hazem` and does not constitute a security boundary against malicious commits. Limit write permissions to trusted developers; ideally move to a dedicated CI user/machine before accepting third-party contributions. Avoid committing secrets.

PHP CLI is not currently installed on the laptop, so the workflow marks PHP lint as skipped rather than falsely passing; install PHP 8.3 locally when backend integration tests matter.
Android release APK builds and headless emulator diagnostics run after **every push**, so expect battery and compute impact. Restart from GitHub if a run was skipped while the laptop was offline.
