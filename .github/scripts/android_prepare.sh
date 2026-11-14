#!/usr/bin/env bash
# The Android chain of the Mob showcase app (development/mob), shared by the release APKs and the
# emulator e2e: deps, mob.exs, the Android OTP runtimes in android/local.properties, then the
# native (zig) build, which must leave a debug APK behind.
set -euo pipefail
cd development/mob

mix deps.get

# mob.exs is gitignored: machine-specific by design.
test -f mob.exs || cat > mob.exs <<'EOF'
import Config

config :mob_dev,
  mob_dir: Path.join(File.cwd!(), "deps/mob"),
  elixir_lib:
    System.get_env("MOB_ELIXIR_LIB", :code.lib_dir(:elixir) |> to_string() |> Path.dirname())

config :mob, :plugins, [:mob_camera, :mob_location, :mob_biometric]

config :mob, :trusted_plugins, %{
  mob_camera: "ed25519:nc56w+1Kx0gIt/4EkHxnMZCKHMzp4+S5kS/HoSzEZkg=",
  mob_location: "ed25519:nc56w+1Kx0gIt/4EkHxnMZCKHMzp4+S5kS/HoSzEZkg=",
  mob_biometric: "ed25519:nc56w+1Kx0gIt/4EkHxnMZCKHMzp4+S5kS/HoSzEZkg="
}
EOF

# Prefetch the Android OTP runtimes.
mix run --no-start -e '
  paths =
    for {abi, key} <- [
          {"arm64-v8a", "mob.otp_release"},
          {"armeabi-v7a", "mob.otp_release_arm32"},
          {"x86_64", "mob.otp_release_x86_64"}
        ] do
      {:ok, path} = MobDev.OtpDownloader.ensure_android(abi)
      IO.puts("#{abi} -> #{path}")
      "#{key}=#{path}"
    end

  props =
    [
      "sdk.dir=#{System.fetch_env!("ANDROID_HOME")}",
      "mob.mob_dir=#{Path.join(File.cwd!(), "deps/mob")}"
      | paths
    ]

  File.write!("android/local.properties", Enum.join(props, "\n") <> "\n")
'
cat android/local.properties

# Build the JNI objects with zig.
mix run --no-start \
  -e 'MobDev.NativeBuild.build_all(platforms: [:android]) |> IO.inspect(label: "native")' \
  || echo "::notice::native build returned non-zero (expected: no device attached)"

apk="android/app/build/outputs/apk/debug/app-debug.apk"
if [ ! -f "$apk" ]; then
  echo "::error::native build produced no $apk — the Android chain did not complete"
  find android/app/build/outputs -name '*.apk' 2>/dev/null || true
  exit 1
fi
echo "native chain complete: $apk ($(du -h "$apk" | cut -f1))"
