#!/usr/bin/env bash
# Everything the device suite needs before the emulator boots, so that Gradle and zig have the
# runner to themselves: the debug APK (`mix e2e` installs it; its own native step is then
# incremental) and the test build.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
"$here/android_prepare.sh"

cd development/mob
MIX_ENV=test mix compile
