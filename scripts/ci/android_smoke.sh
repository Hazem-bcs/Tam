#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$CI_METRICS_DIR"
cd apps/customer
flutter build apk --release --no-pub
APK=build/app/outputs/flutter-apk/app-release.apk
test -f "$APK"
stat -c '%s' "$APK" > "$CI_METRICS_DIR/apk_bytes.txt"
adb install -r "$APK"
adb shell am force-stop com.mashwar.mashwar_customer || true
adb shell am start -W -n com.mashwar.mashwar_customer/.MainActivity > "$CI_METRICS_DIR/android-start.txt"
sleep 3
adb shell dumpsys meminfo com.mashwar.mashwar_customer > "$CI_METRICS_DIR/android-memory.txt"
