#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$CI_METRICS_DIR/baseline"
branch="${REF_NAME:-main}"
[ "${GITHUB_EVENT_NAME:-}" = pull_request ] && branch=main
fetch_from() {
  local b="$1" id
  for id in $(gh run list --repo "$REPO_NAME" --workflow performance.yml --branch "$b" --status success --limit 8 --json databaseId --jq '.[].databaseId' 2>/dev/null); do
    if gh run download "$id" --repo "$REPO_NAME" --name performance-metrics --dir "$CI_METRICS_DIR/baseline" >/dev/null 2>&1 && [ -f "$CI_METRICS_DIR/baseline/current.json" ]; then
      mv "$CI_METRICS_DIR/baseline/current.json" "$CI_METRICS_DIR/baseline/metrics.json"
      echo "Baseline: branch=$b run=$id"
      return 0
    fi
  done
  return 1
}
fetch_from "$branch" || { [ "$branch" = main ] || fetch_from main || true; }
[ -f "$CI_METRICS_DIR/baseline/metrics.json" ] || echo "No baseline yet"
