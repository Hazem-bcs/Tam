#!/usr/bin/env bash
# Durable local copy outside runner _work; GitHub artifact remains optional.
set -euo pipefail
BRANCH="${GITHUB_REF_NAME:-manual}"
RUN_ID="${GITHUB_RUN_ID:-local}"
BASE="$HOME/projects/mashwar/.ci-reports/$BRANCH/$RUN_ID"
mkdir -p "$BASE"
for filename in current.json report.md flutter-tests.log cache-tests.log   coalescer-tests.log android-start.txt android-memory.txt   android-install.txt apk_bytes.txt; do
  if [ -f "$CI_METRICS_DIR/$filename" ]; then
    cp "$CI_METRICS_DIR/$filename" "$BASE/$filename"
  fi
done
echo "Local report directory: $BASE"
