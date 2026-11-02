#!/usr/bin/env bash
# Self-hosted Android benchmark: uses a dedicated, headless AVD, never Medium_Phone.
set -euo pipefail
mkdir -p "$CI_METRICS_DIR" "$HOME/.mashwar-ci"
exec 9>"$HOME/.mashwar-ci/android-emulator.lock"
flock -n 9 || { echo "Mashwar Android benchmark already running"; exit 1; }
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
ADB="$ANDROID_HOME/platform-tools/adb"
EMULATOR="$ANDROID_HOME/emulator/emulator"
PORT=5590
SERIAL="emulator-$PORT"
if "$ADB" devices | grep -q "^$SERIAL[[:space:]]"; then
  echo "Dedicated emulator port $PORT already in use. Refusing to touch another emulator."
  exit 1
fi
AVD=Mashwar_CI_API34
test -f "$HOME/.android/avd/${AVD}.ini"
"$EMULATOR" -avd "$AVD" -port "$PORT" -no-window -no-audio   -no-boot-anim -no-snapshot -gpu swiftshader_indirect -memory 1536 -cores 2   > "$CI_METRICS_DIR/android-emulator.log" 2>&1 &
EMULATOR_PID=$!
cleanup() {
  "$ADB" -s "$SERIAL" emu kill >/dev/null 2>&1 || true
  kill "$EMULATOR_PID" 2>/dev/null || true
  wait "$EMULATOR_PID" 2>/dev/null || true
}
trap cleanup EXIT
echo "Starting dedicated Mashwar emulator $SERIAL"
booted=0
for attempt in $(seq 1 120); do
  if ! kill -0 "$EMULATOR_PID" 2>/dev/null; then
    echo "Emulator exited unexpectedly; inspect android-emulator.log" >&2
    exit 1
  fi
  if [ "$("$ADB" -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; then
    booted=1
    break
  fi
  sleep 2
done
[ "$booted" = 1 ] || { echo "Emulator did not boot" >&2; exit 1; }
cd apps/customer
flutter build apk --release --no-pub
APK=build/app/outputs/flutter-apk/app-release.apk
test -f "$APK"
stat -c '%s' "$APK" > "$CI_METRICS_DIR/apk_bytes.txt"
"$ADB" -s "$SERIAL" install -r "$APK" > "$CI_METRICS_DIR/android-install.txt"
"$ADB" -s "$SERIAL" shell am force-stop com.mashwar.mashwar_customer || true
"$ADB" -s "$SERIAL" shell am start -W -n   com.mashwar.mashwar_customer/.MainActivity > "$CI_METRICS_DIR/android-start.txt"
sleep 3
"$ADB" -s "$SERIAL" shell dumpsys meminfo com.mashwar.mashwar_customer   > "$CI_METRICS_DIR/android-memory.txt"
echo "Android smoke metrics captured"
