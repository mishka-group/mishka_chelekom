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
  # Slot tags carry no module to anchor on — being consumed by a parent's
  # expand/3 is the whole point — so they are read off the @slot_tags list
  # instead. Still tags, still validated by the sigil, still need whitelisting.
  @slots ~r/@slot_tags\s+\[([^\]]*)\]/
  # Primitive node types this app renders ITSELF in MobBridge.kt, which mob's own
  # whitelist does not know about. They are never written as ~MOB tags — the
  # components emit them as raw maps — so the sigil does not need them.
  # Mob.ScreenCase.assert_renderable/2 does: it bakes @renderable_types from
  # these same files at mob's compile time and flunks any type outside the list,
  # which would fail every test that touches a popover.
  @natives ~r/@native_tags\s+\[([^\]]*)\]/
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
    source = File.read!(@catalog)

    composites =
      @register
      |> Regex.scan(source, capture: :all_but_first)
      |> List.flatten()

    if composites == [], do: Mix.raise("no composite tags found in #{@catalog}")

    atoms = fn regex ->
      case Regex.run(regex, source, capture: :all_but_first) do
        [list] -> Regex.scan(~r/:([a-z0-9_]+)/, list, capture: :all_but_first) |> List.flatten()
        nil -> []
      end
    end

    slots = atoms.(@slots)
    natives = atoms.(@natives)

    names =
      (composites ++ slots ++ natives)
      |> Enum.map(&Macro.camelize/1)
      |> Enum.uniq()
      |> Enum.sort()

    # Mob is recompiled when the set changes — @known_tags is baked at MOB's
    # compile time, so an untouched dep keeps serving the old list — and also
    # when THIS env's build predates the file. Each env has its own
    # _build/<env>/lib/mob, but they share one deps/ copy of the whitelist, so
    # writing it under `mix compile` leaves the test build stale and every tag
    # warns again the moment `mix test` runs.
    changed? = Enum.any?(Enum.map(@tag_files, &sync_tags(&1, names)))

    # Only force a rebuild of an EXISTING build. On a fresh checkout :mob has not
    # been compiled yet, and `deps.compile mob --force` compiles that one dep in
    # isolation — before nimble_parsec, which Mob.Sigil imports, leaving CI with
    # "module NimbleParsec is not loaded". Nothing needs forcing there anyway:
    # the tags file is already written, so the ordinary compile that follows
    # reads it.
    if (changed? or stale_build?()) and File.dir?(mob_ebin()) do
      Mix.shell().info("whitelisting #{length(names)} composite tags — recompiling :mob")
      Mix.Task.run("deps.compile", ["mob", "--force"])
    end

    :ok
  end

  # Mix tracks a dependency's staleness by its source, and priv/ is not source —
  # so a whitelist written while another env was building is invisible here.
  # Mob.Sigil is the module that bakes the list in, which makes its beam the
  # thing to compare against.
  defp mob_ebin, do: Path.join(["_build", to_string(Mix.env()), "lib/mob/ebin"])

  defp stale_build? do
    beam = Path.join(mob_ebin(), "Elixir.Mob.Sigil.beam")

    case {File.stat(beam), File.stat("deps/mob/priv/tags/android.txt")} do
      {{:ok, built}, {:ok, tags}} -> tags.mtime > built.mtime
      _ -> false
    end
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
  # Every @Test relaunches MainActivity, and past roughly 70-85 launches in one process
  # the app dies at the next Activity teardown — Compose's SlotTable miscounts its own
  # gap and close() throws. 397 tests in a single `am instrument` sails past that, so
  # the suite could never finish. Each invocation gets its own app process, so batching
  # keeps every process well under the threshold.
  #
  # This is containment, not a cure: the launch-count bug is real and still open. It
  # just isn't reachable by anything a user does, and it should not hold the suite (or
  # a release) hostage while it is investigated.
  @launch_budget 40

  defp e2e(args) do
    cmd!(Path.expand("android/gradlew"), ["assembleDebugAndroidTest"], "android")
    cmd!("adb", ["install", "-r", @test_apk])

    batches =
      case args do
        [] -> test_classes() |> batch_by_launches(@launch_budget)
        names -> [Enum.map(names, &qualify/1)]
      end

    if length(batches) > 1 do
      Mix.shell().info(
        "Running #{length(batches)} batches (≤#{@launch_budget} Activity launches each)\n"
      )
    end

    failed =
      batches
      |> Enum.with_index(1)
      |> Enum.reduce([], fn {classes, i}, acc ->
        if length(batches) > 1 do
          Mix.shell().info("── batch #{i}/#{length(batches)} ─────────────────────────")
        end

        if instrument_ok?(classes), do: acc, else: [i | acc]
      end)

    unless failed == [] do
      Mix.raise(
        "device tests failed in batch(es) #{failed |> Enum.reverse() |> Enum.join(", ")} " <>
          "— see the output above"
      )
    end
  end

  # One `am instrument` run. Streams as it goes: the runner prints each class when it
  # finishes, but capturing into a string withholds all of it until the command returns,
  # which makes a wedged suite indistinguishable from a slow one and leaves a killed run
  # with no test output at all. `tee` keeps a copy because the verdict is read back out
  # of the text — `am instrument` exits 0 whether tests pass or fail.
  defp instrument_ok?(classes) do
    log = Path.join(System.tmp_dir!(), "mob_e2e_#{System.unique_integer([:positive])}.log")
    filter = if classes == [], do: [], else: ["-e", "class", Enum.join(classes, ",")]
    instrument = Enum.join(["am", "instrument", "-w"] ++ filter ++ [@runner], " ")

    System.cmd("sh", ["-c", "adb shell #{instrument} 2>&1 | tee #{log}"],
      into: IO.stream(:stdio, :line)
    )

    out = File.read!(log)
    File.rm(log)

    not String.contains?(out, "FAILURES!!!") and String.contains?(out, "OK (")
  end

  # Every *Test.kt, paired with its @Test count — the number of Activity launches it
  # will cost. Read from source so a new class is batched the moment it lands.
  defp test_classes do
    "android/app/src/androidTest/**/*Test.kt"
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.map(fn path ->
      tests = path |> File.read!() |> then(&Regex.scan(~r/^\s*@Test\b/m, &1)) |> length()
      {qualify(Path.basename(path, ".kt")), max(tests, 1)}
    end)
  end

  # Greedy pack, in the runner's own order, so a batch reads as a contiguous run.
  defp batch_by_launches(classes, budget) do
    classes
    |> Enum.reduce({[], [], 0}, fn {name, tests}, {done, current, spent} ->
      if current != [] and spent + tests > budget,
        do: {[Enum.reverse(current) | done], [name], tests},
        else: {done, [name | current], spent + tests}
    end)
    |> then(fn {done, current, _} -> Enum.reverse([Enum.reverse(current) | done]) end)
    |> Enum.reject(&(&1 == []))
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
