defmodule MishkaMob.MixProject do
  use Mix.Project

  def project do
    [
      app: :mishka_mob,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: false,
      deps: deps(),
      aliases: aliases(),
      erlc_paths: ["src"],
      erlc_options: [:debug_info]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:mob, "~> 0.7"},
      {:mob_dev, "~> 0.6", only: :dev, runtime: false},
      {:ecto_sqlite3, "~> 0.18"},
      # Showcase plugins — each ships a demo screen the home auto-lists, so a
      # fresh app demonstrates real device capabilities out of the box. Remove
      # any you don't need (and drop it from config :mob, :plugins in mob.exs);
      # the native build shrinks accordingly. Browse more at
      # https://hexdocs.pm/mob/packages.html.
      {:mob_camera, "~> 0.1"},
      {:mob_location, "~> 0.1"},
      {:mob_biometric, "~> 0.1"},
      {:mob_themes, "~> 0.1"},
      # Required by `mix mob.icon` (libvips NIF) to resize the Mishka mark into
      # every launcher / AppIcon size. Dev-only — it never ships on device.
      {:image, "~> 0.72", only: :dev, runtime: false},
      # Code quality — Credo + ex_slop (catches AI-generated patterns
      # like blanket rescue, narrator docs, redundant Enum chains, etc).
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_slop, "~> 0.4.2", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false}
    ]
  end

  # Shorthands for the common mob workflows — `mix deploy` is `mix mob.deploy`,
  # etc. Extra args pass through to the underlying task, so `mix deploy
  # --device <udid>` works as expected.
  defp aliases do
    [
      # Whitelist our composite tags before anything compiles — see tags/1.
      # Mix does not re-enter an alias, so naming this `compile` wraps the real
      # task rather than recursing into itself.
      compile: [&tags/1, "compile"],

      # The quality gate — the agent runs `mix precommit` before finishing and
      # CI runs it on the way in. NO Sobelow here: it scans Phoenix web surfaces
      # (XSS/CSRF/SQLi in controllers + HEEx), and this is a native Mob app with
      # no web endpoint. Dialyzer runs on its own (slow) via `mix dialyzer`; add
      # :boundary once contexts are annotated.
      precommit: [
        "compile --warnings-as-errors",
        "deps.unlock --check-unused",
        "format --check-formatted",
        "deps.audit",
        "hex.audit",
        "credo --strict",
        "xref graph --label compile-connected --fail-above 0",
        "test --warnings-as-errors"
      ],
      connect: ["mob.connect"],
      deploy: ["mob.deploy"],
      watch: ["mob.watch"],
      icon: ["mob.icon"],
      ios: ["mob.deploy --ios"],
      "ios.native": ["mob.deploy --native --ios"],
      android: ["mob.deploy --android"],
      "android.native": ["mob.deploy --native --android"],

      # Device tests. `mix test` covers the node trees; this covers what the
      # screen actually does, which is the only place bridge behaviour shows up.
      #
      #     mix e2e                 # every device test
      #     mix e2e OtpFieldTest    # one class
      e2e: [&e2e/1]
    ]
  end

  @tag_files ~w(android ios)
  @catalog "lib/mishka_mob/showcase.ex"
  # Both catalog shapes at once — positional `:mishka_chip, MishkaMob.Components.X`
  # and the keyword `mishka_burger: MishkaMob.Components.X` used for a page's
  # companion tags. Anchoring on the module is what makes this a real pairing
  # rather than a guess: only an atom actually bound to a component matches.
  @register ~r/:?([a-z0-9_]+)[:,]\s*MishkaMob\.Components\.[A-Z]/
  @fence_start "# >>> mishka_mob composites — regenerated on compile, do not edit"
  @fence_end "# <<< mishka_mob composites"

  # Teach the ~MOB sigil about our composite tags.
  #
  # The sigil validates tag names at compile time against a whitelist baked into
  # Mob from priv/tags/{android,ios}.txt. Our components are composites
  # registered at RUNTIME, which a compile-time check cannot see, so <MishkaChip/>
  # warns "not in the Mob tag whitelist" — and this project builds with
  # --warnings-as-errors, which turns that warning into a wall.
  #
  # The whitelist is plain data and Mob skips "#" lines, so adding our tags to it
  # and recompiling Mob makes the sigil accept them. That is what lets the
  # showcase write <MishkaChip /> instead of {chip(...)} — the tag an app writes.
  #
  # Consumers get this from the CLI instead: `mix mishka.ui.gen.mob` wires
  # `mix mishka.mob.tags` into their aliases, reading the tags out of the
  # registry it generates so a --module-prefix is carried through. This copy
  # exists because the dev app is not a consumer — it has no generated registry.
  #
  # It lives in mix.exs rather than lib/mix/tasks/ deliberately: a task there
  # needs the project compiled in order to run, which is the thing it exists to
  # unblock. mix.exs is evaluated first, always.
  #
  # Rewriting a dependency's file is not something to do lightly, so the block is
  # fenced and regenerated wholesale rather than appended to. deps.get,
  # deps.clean and a fresh clone all drop it; hanging this off `compile` is what
  # makes that a non-event, because the next build puts it back.
  defp tags(_args) do
    # Read the tags out of the catalog that registers them, not off the filenames.
    # The catalog is what decides a tag; a filename is only a guess at one, and
    # the guess is already wrong here — a page may register companion tags whose
    # components it is not named after (a burger alongside a toolbar).
    names =
      @catalog
      |> File.read!()
      |> then(&Regex.scan(@register, &1, capture: :all_but_first))
      |> List.flatten()
      |> Enum.map(&Macro.camelize/1)
      |> Enum.uniq()
      |> Enum.sort()

    if names == [], do: Mix.raise("no composite tags found in #{@catalog}")

    # Mob is recompiled only when the set actually changes: @known_tags is baked
    # at MOB's compile time, so an untouched dep keeps serving the old list.
    if Enum.any?(Enum.map(@tag_files, &sync_tags(&1, names))) do
      Mix.shell().info("whitelisting #{length(names)} composite tags — recompiling :mob")
      Mix.Task.run("deps.compile", ["mob", "--force"])
    end

    :ok
  end

  defp sync_tags(platform, names) do
    path = "deps/mob/priv/tags/#{platform}.txt"

    if File.exists?(path) do
      current = File.read!(path)

      updated =
        strip_fence(current) <>
          "\n\n" <> @fence_start <> "\n" <> Enum.join(names, "\n") <> "\n" <> @fence_end <> "\n"

      if updated == current do
        false
      else
        File.write!(path, updated)
        true
      end
    else
      # Not fatal: deps.get has simply not run yet, and the compile that follows
      # fails with a far clearer message than anything raised here.
      false
    end
  end

  defp strip_fence(contents) do
    case String.split(contents, @fence_start, parts: 2) do
      [before, rest] ->
        tail = rest |> String.split(@fence_end, parts: 2) |> List.last()
        String.trim_trailing(before) <> String.trim_trailing(tail)

      [only] ->
        String.trim_trailing(only)
    end
  end

  @test_apk "android/app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
  @runner "com.example.mishka_mob.test/androidx.test.runner.AndroidJUnitRunner"

  # Deliberately NOT `gradlew connectedDebugAndroidTest`. That reinstalls the app
  # APK, and Android wipes the app's files/ directory on any reinstall — which is
  # where the whole OTP release lives, so the BEAM dies with `cannot get
  # bootfile` a second after onCreate. Installing only the TEST apk leaves the
  # app package untouched.
  defp e2e(args) do
    filter =
      case args do
        [] -> []
        names -> ["-e", "class", Enum.map_join(names, ",", &qualify/1)]
      end

    cmd!(Path.expand("android/gradlew"), ["assembleDebugAndroidTest"], "android")
    cmd!("adb", ["install", "-r", @test_apk])

    # `am instrument` exits 0 even when tests fail — the verdict is in its
    # output, so a green exit code here would be a lie.
    {out, _} = System.cmd("adb", ["shell", "am", "instrument", "-w"] ++ filter ++ [@runner])
    IO.puts(out)

    if String.contains?(out, "FAILURES!!!") or not String.contains?(out, "OK (") do
      Mix.raise("device tests failed — see the output above")
    end
  end

  defp qualify(name) do
    if String.contains?(name, "."), do: name, else: "com.example.mishka_mob." <> name
  end

  # System.cmd resolves the binary against PATH, not against :cd — so the
  # wrapper needs an absolute path even though it runs inside android/.
  defp cmd!(bin, args, dir \\ ".") do
    opts = [into: IO.stream(:stdio, :line), cd: dir]

    case System.cmd(bin, args, opts) do
      {_, 0} -> :ok
      {_, code} -> Mix.raise("#{bin} #{Enum.join(args, " ")} failed with exit #{code}")
    end
  end
end
