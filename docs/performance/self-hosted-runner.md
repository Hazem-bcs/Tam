# Mashwar self-hosted GitHub Actions runner — one-time registration

## Already prepared on the Ubuntu laptop

- Runner installation: `/home/hazem/actions-runner-mashwar` (independent of the existing ZAD runner).
- systemd user unit: `/home/hazem/.config/systemd/user/mashwar-actions-runner.service`.
- Dedicated Android virtual device: `Mashwar_CI_API34`, CI port 5590, headless. The user's personal `Medium_Phone` stays untouched.
- Workflow `runs-on: [self-hosted, Linux, X64, mashwar-ci]` and fires only for trusted pushes to `main` / `hazem-dev`, plus manual dispatch.
- Runner service CPU capped at 250% and RAM capped at 14 GiB; regular ZAD runner is unchanged.

## One-time manual registration (token never belongs in chat or git)

The automatic token registration request was blocked by the execution environment's security controls. Finish this action **on the laptop**, not in a chat:

1. Open GitHub repository **Hazem-bcs/mashwar** → **Settings** → **Actions** → **Runners** → **New self-hosted runner** → Linux, x64. Retrieve the short-lived registration token.
2. In a terminal on the Ubuntu laptop, run:

```bash
cd /home/hazem/actions-runner-mashwar
read -rsp 'Paste GitHub runner registration token: ' RUNNER_TOKEN; echo
./config.sh --unattended \
  --url https://github.com/Hazem-bcs/mashwar \
  --token "$RUNNER_TOKEN" \
  --name mashwar-g16-local \
  --labels mashwar-ci \
  --work _work \
  --replace
unset RUNNER_TOKEN

systemctl --user daemon-reload
systemctl --user enable --now mashwar-actions-runner.service
systemctl --user status mashwar-actions-runner.service --no-pager
```

3. Confirm that `mashwar-g16-local` shows **Idle/Online** on GitHub > Settings > Actions > Runners. You can trigger **Actions > Mashwar performance and quality > Run workflow** for a manual validation.

**Do not** run `./config.sh` with the token pasted literally in your shell command history. Do not send the token to a teammate or chat.

If the service was not registered yet, GitHub workflows with the `mashwar-ci` label will remain **queued**.

## After setup

- Review / edit the source at **`/home/hazem/projects/mashwar`**, not inside runner checkout.
- Runner's temporary checkout: `/home/hazem/actions-runner-mashwar/_work/mashwar/mashwar`.
- Local reports: `/home/hazem/projects/mashwar/.ci-reports/<branch>/<run-id>/report.md`.
- GitHub Actions run Summary and downloadable `performance-metrics` artifact are retained.
- Service logs: `journalctl --user -u mashwar-actions-runner.service -f`.
- Stop runner: `systemctl --user stop mashwar-actions-runner.service`.
- Resume: `systemctl --user start mashwar-actions-runner.service`.
- Disable on login: `systemctl --user disable --now mashwar-actions-runner.service`.

## Security and resource tradeoffs

GitHub still queues jobs and hosts reports, but **code and Android benchmarks execute on your laptop** and use local electricity/CPU/disk. The laptop must be awake and connected; jobs queue otherwise. Running self-hosted CI as your regular desktop account means trusted commits execute with that account's file access. Only allow trusted committers on the two monitored branches. Use a dedicated non-personal user or machine if untrusted contributors join. Never run fork PR code on your personal self-hosted runner.

Local PHP CLI is not currently installed; the CI workflow explicitly reports backend PHP validation skipped rather than falsely claiming success. Release APK + Android emulator runs can be computationally expensive on each push.
