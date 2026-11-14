#!/usr/bin/env bash
# The release APKs (arm64-v8a, armeabi-v7a, universal) and the AAB of the Mob showcase app, named
# after $VERSION in development/mob/dist. Signed when the ANDROID_KEYSTORE_* variables are set,
# unsigned otherwise.
set -euo pipefail
: "${VERSION:?VERSION must be set}"
export ORG_GRADLE_PROJECT_mobVersionName="$VERSION"
export ORG_GRADLE_PROJECT_mobVersionCode="${GITHUB_RUN_NUMBER:-1}"

here="$(cd "$(dirname "$0")" && pwd)"
"$here/android_prepare.sh"

cd development/mob

# Environment check.
mix mob.doctor || true

# Decode the upload keystore, if configured.
if [ -z "${ANDROID_KEYSTORE_BASE64:-}" ]; then
  echo "::notice::no ANDROID_KEYSTORE_BASE64 secret — release APKs will be unsigned"
else
  echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > android/upload_jks.keystore
  cat > android/keystore.properties <<EOF
storeFile=upload_jks.keystore
storePassword=$ANDROID_KEYSTORE_PASSWORD
keyAlias=$ANDROID_KEY_ALIAS
keyPassword=$ANDROID_KEY_PASSWORD
EOF
fi

# Stage otp.zip and build the AAB.
mix mob.release --android

# Assemble the split APKs from the same staging.
(cd android && ./gradlew assembleRelease --no-daemon -PsplitAbi)

# Name the outputs after the release.
out="android/app/build/outputs/apk/release"
mkdir -p dist
pick() {
  local match
  match="$(ls "$out"/app-$1-release*.apk 2>/dev/null | head -1 || true)"
  if [ -z "$match" ]; then
    echo "::error::no APK matched app-$1-release*.apk in $out"
    ls -la "$out" || true
    exit 1
  fi
  cp "$match" "dist/mishka_mob_${VERSION}_android_$2.apk"
  echo "  $2 <- $(basename "$match")"
}
pick "arm64-v8a"   "arm64-v8a"
pick "armeabi-v7a" "armeabi-v7a"
pick "universal"   "universal"
aab="$(ls android/app/build/outputs/bundle/release/*.aab 2>/dev/null | head -1 || true)"
[ -n "$aab" ] && cp "$aab" "dist/mishka_mob_${VERSION}_android.aab"
ls -la dist
