#!/usr/bin/env bash
# One shard of the device suite (development/mob/test/device) on the booted emulator. `mix e2e`
# installs the APK, attaches to the app over adb and runs `mix test --only device` for its
# partition. On a failure the crash context from logcat is printed before the job fails.
set -uo pipefail
shard="${1:?usage: android_e2e.sh <shard> [shards]}"
shards="${2:-2}"
report="${GITHUB_WORKSPACE:-$PWD}/e2e-report"

cd development/mob || exit 1
mix e2e --device emulator-5554 --shard "$shard/$shards" --report "$report"
status=$?

if [ "$status" -ne 0 ]; then
  f="$report/logcat-emulator-5554.txt"
  if [ -f "$f" ]; then
    echo "── AndroidRuntime / Compose / mob ─────────────────────────────"
    grep -nE "AndroidRuntime|FATAL|Compose|SlotTable|mishka_mob|MobBridge" "$f" \
      | tail -120 || echo "(no matching lines)"
  else
    echo "no logcat captured"
  fi
fi
exit "$status"
