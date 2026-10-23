defmodule MishkaMob.E2E do
  @moduledoc """
  The runner behind `mix e2e`: the device suite (`test/device`) on every attached
  Android device, one partition of the files per device, in parallel.

  It lives here and not in `lib/` because `lib/` is what gets pushed to a phone, and
  this has no business there. `mix.exs` loads it when the alias runs.

  For each device, in order:

    1. **Native.** The APK is installed (`mix android.native`) only when something
       native changed since this runner last installed on that device: the Kotlin and
       JNI under `android/`, `priv/`, `config/`, `mob.exs` or `mix.lock`. A reinstall
       made by anything else (or an app that was never installed) counts as changed,
       because the stamp records the package's `lastUpdateTime` too.
    2. **Attach.** The running app is found in the Mac's EPMD and its adb tunnels are
       set up (`MobDev.Connector`). An app that is not answering is restarted once.
    3. **Hot push.** Each module of this app's `:dev` build is compared by MD5 with the
       one the app has loaded, and the ones that differ are loaded. Nothing else is
       pushed: not `mob_nif` and not any other dependency, which is why this is not
       `mix mob.push` (that overwrites the device's `mob_nif.beam` with `--all`, and
       pushes nothing at all when the beams were compiled before the command ran).

  Then `mix test --only device --partitions N` runs once per device, each in its own OS
  process with `MOB_DEVICE_NODE` (the node `MishkaMob.Device` connects to) and
  `MIX_TEST_PARTITION` set, and a combined summary is printed. ExUnit deals the sorted
  files out round-robin, so the partitions come out within a few percent of each other.

  ## Usage

      mix e2e                          # every device test, on every attached device
      mix e2e popover                  # one file: popover_test.exs, PopoverTest, ...
      mix e2e popover tooltip          # several
      mix e2e test/device/popover_test.exs:61   # one test
      mix e2e --device emulator-5554   # only these devices (repeatable)

  ## Options

    * `--device SERIAL` - use this device (repeatable; a unique part of the serial is
      enough). Defaults to `ANDROID_SERIAL`, then every device `adb devices` lists.
    * `--install` - install the APK even if nothing native changed.
    * `--no-push` - leave the app's modules as they are.
    * `--shard I/N` - run partition I of N on the one device given. For CI, where each
      shard has an emulator of its own.
    * `--report DIR` - write the JUnit XML, each partition's output and the device's
      logcat to DIR.
    * `--trace`, `--seed N`, `--max-failures N` - as for `mix test`. Anything else for
      `mix test` goes after `--`.
  """

  @bundle_id "com.example.mishka_mob"
  @tests "test/device"
  @native_paths ~w(android priv config mix.lock)
  @generated_dirs ~w(build .gradle .cxx jniLibs)
  @adb_ms 15_000
  # Each attach attempt waits 3 seconds for the node to register.
  @boot_attempts 15

  @switches [
    device: :keep,
    install: :boolean,
    push: :boolean,
    shard: :string,
    report: :string,
    trace: :boolean,
    seed: :integer,
    max_failures: :integer
  ]

  @typedoc "One `mix test` process: the device it drives, and which share of the files it runs."
  @type partition :: %{serial: String.t(), index: pos_integer(), count: pos_integer()}

  # ── Entry ──────────────────────────────────────────────────────────────────

  @doc "Runs the device suite as `mix e2e` does. Raises when it cannot, or when a test fails."
  @spec run(args :: [String.t()]) :: :ok
  def run(args) do
    {mine, passthrough} = Enum.split_while(args, &(&1 != "--"))
    {opts, names, invalid} = OptionParser.parse(mine, strict: @switches)

    unless invalid == [] do
      Mix.raise("mix e2e: unknown option(s) #{inspect(invalid)}; see the options in test/e2e.exs")
    end

    # app.config compiles the :dev build, which is what the hot push sends.
    Mix.Task.run("app.config")

    unless Code.ensure_loaded?(Module.concat(MobDev, Connector)) do
      Mix.raise("mix e2e needs mob_dev, a :dev dependency: run it with MIX_ENV=dev (the default)")
    end

    targets = Enum.map(names, &resolve_target!/1)
    serials = select_devices!(opts)
    plan = plan!(serials, covered_files(targets), shard!(opts))
    report = report_dir(opts)
    Enum.each(plan, &check_responsive!(&1.serial))

    ready = Enum.map(plan, &prepare!(&1, opts))
    leave_distribution(ready)
    extra = Enum.drop(passthrough, 1)
    started = System.monotonic_time(:millisecond)

    results =
      with_logcat(Enum.map(ready, & &1.serial), report, fn ->
        ready |> start_partitions(targets, opts, extra, report) |> collect()
      end)

    summarize(results, System.monotonic_time(:millisecond) - started)
  end

  # ── Choosing devices and files ─────────────────────────────────────────────

  @doc "The serials `adb devices` lists as ready (not `offline` or `unauthorized`)."
  @spec parse_adb_devices(output :: String.t()) :: [String.t()]
  def parse_adb_devices(output) do
    for line <- String.split(output, "\n", trim: true),
        [serial, "device" | _] <- [String.split(line)],
        do: serial
  end

  @doc """
  The serials to use out of the `attached` ones. Each of `wanted` is an exact serial or a
  part of exactly one; with none wanted, every attached device is used.
  """
  @spec pick_devices(attached :: [String.t()], wanted :: [String.t()]) ::
          {:ok, [String.t()]} | {:error, String.t()}
  def pick_devices([], _wanted) do
    {:error, "no Android device is attached (`adb devices` lists none that is ready)"}
  end

  def pick_devices(attached, []), do: {:ok, attached}

  def pick_devices(attached, wanted) do
    Enum.reduce_while(wanted, {:ok, []}, fn want, {:ok, picked} ->
      case match_device(attached, want) do
        {:ok, serial} -> {:cont, {:ok, Enum.uniq(picked ++ [serial])}}
        {:error, _message} = error -> {:halt, error}
      end
    end)
  end

  defp match_device(attached, want) do
    case Enum.filter(attached, &String.contains?(&1, want)) do
      [serial] ->
        {:ok, serial}

      [] ->
        {:error,
         "no attached device matches #{inspect(want)} (attached: #{Enum.join(attached, ", ")})"}

      many ->
        if want in many,
          do: {:ok, want},
          else: {:error, "#{inspect(want)} matches several devices: #{Enum.join(many, ", ")}"}
    end
  end

  defp select_devices!(opts) do
    wanted =
      case {Keyword.get_values(opts, :device), System.get_env("ANDROID_SERIAL")} do
        {[], serial} when serial not in [nil, ""] -> [serial]
        {devices, _} -> devices
      end

    case pick_devices(attached_devices(), wanted) do
      {:ok, serials} -> serials
      {:error, message} -> Mix.raise(message)
    end
  end

  defp attached_devices do
    case System.cmd("adb", ["devices"], stderr_to_stdout: true) do
      {out, 0} -> parse_adb_devices(out)
      {out, code} -> Mix.raise("`adb devices` failed with exit #{code}: #{out}")
    end
  rescue
    _ in ErlangError -> Mix.raise("adb is not on the PATH (install the Android platform-tools)")
  end

  @doc """
  The test file a command-line target names. A path (optionally `:line`) is taken as given;
  anything else is a file or module name (`popover`, `popover_test`, `PopoverTest`,
  `MishkaMob.Device.PopoverTest`) looked up among `test_files`.
  """
  @spec resolve_target(target :: String.t(), test_files :: [String.t()]) ::
          {:ok, String.t()} | {:error, String.t()}
  def resolve_target(target, test_files) do
    {path, line} = split_line(target)

    cond do
      String.ends_with?(path, ".exs") and File.exists?(path) ->
        {:ok, target}

      String.ends_with?(path, ".exs") ->
        {:error, "#{path} does not exist"}

      true ->
        stem =
          path
          |> String.split(".")
          |> List.last()
          |> Macro.underscore()
          |> String.replace_suffix("_test", "")

        case Enum.find(test_files, &(Path.basename(&1) == stem <> "_test.exs")) do
          nil -> {:error, no_such_test(path, stem, test_files)}
          file -> {:ok, file <> line}
        end
    end
  end

  defp no_such_test(target, stem, test_files) do
    near =
      test_files
      |> Enum.filter(&String.contains?(&1, stem))
      |> Enum.map_join(", ", &Path.basename/1)

    "no device test named #{inspect(target)} in #{@tests}" <>
      if(near == "", do: "", else: " (similar: #{near})")
  end

  defp split_line(target) do
    case Regex.run(~r/^(.*?)(:\d+)$/, target, capture: :all_but_first) do
      [path, line] -> {path, line}
      nil -> {target, ""}
    end
  end

  defp resolve_target!(target) do
    case resolve_target(target, Path.wildcard(Path.join(@tests, "*_test.exs"))) do
      {:ok, file} -> file
      {:error, message} -> Mix.raise(message)
    end
  end

  # The files the run covers, which is what decides how many devices are worth using.
  defp covered_files([]), do: Path.wildcard(Path.join(@tests, "*_test.exs"))

  defp covered_files(targets),
    do: targets |> Enum.map(&(&1 |> split_line() |> elem(0))) |> Enum.uniq()

  @doc """
  Which device runs which partition. With `shard` (`{index, count}`) the one device runs
  that partition. Without, each device gets one of as many partitions as there are devices
  (but no more than files, so that none is left with nothing to run).
  """
  @spec plan(
          serials :: [String.t()],
          files :: [String.t()],
          shard :: {pos_integer(), pos_integer()} | nil
        ) ::
          {:ok, [partition()]} | {:error, String.t()}
  def plan([serial], _files, {index, count}),
    do: {:ok, [%{serial: serial, index: index, count: count}]}

  def plan(_serials, _files, {_index, _count}), do: {:error, "--shard runs on exactly one device"}

  def plan(serials, files, nil) do
    count = serials |> length() |> min(max(length(files), 1))

    {:ok,
     serials
     |> Enum.take(count)
     |> Enum.with_index(1)
     |> Enum.map(fn {serial, index} -> %{serial: serial, index: index, count: count} end)}
  end

  defp plan!(serials, files, shard) do
    case plan(serials, files, shard) do
      {:ok, plan} -> plan
      {:error, message} -> Mix.raise(message)
    end
  end

  @doc "`\"2/3\"` as `{2, 3}`, or `:error`."
  @spec parse_shard(shard :: String.t()) :: {pos_integer(), pos_integer()} | :error
  def parse_shard(shard) do
    with [index, count] <- String.split(shard, "/"),
         {index, ""} <- Integer.parse(index),
         {count, ""} <- Integer.parse(count),
         true <- index in 1..count//1 do
      {index, count}
    else
      _ -> :error
    end
  end

  defp shard!(opts) do
    case opts[:shard] do
      nil ->
        nil

      shard ->
        case parse_shard(shard) do
          :error -> Mix.raise("--shard takes I/N with 1 <= I <= N, got #{inspect(shard)}")
          parsed -> parsed
        end
    end
  end

  defp report_dir(opts) do
    case opts[:report] do
      nil ->
        nil

      dir ->
        dir = Path.expand(dir)
        File.mkdir_p!(dir)
        dir
    end
  end

  # ── Getting the app ready ──────────────────────────────────────────────────

  defp check_responsive!(serial) do
    case adb(serial, ["shell", "getprop", "sys.boot_completed"], 8_000) do
      {:ok, out} ->
        if String.trim(out) != "1", do: Mix.raise("#{serial} has not finished booting")

      _no_answer ->
        Mix.raise("""
        #{serial} does not answer adb within 8 seconds.

        A hung emulator: `adb -s #{serial} emu kill`, then boot it again (cold, `-no-snapshot-load`).
        A phone: unplug it, `adb kill-server`, plug it in.
        """)
    end
  end

  defp prepare!(%{serial: serial} = partition, opts) do
    info("\n#{serial}")

    installed? =
      case native_change(serial, opts) do
        :current ->
          info("  native    unchanged since the last install")
          false

        {:install, reason} ->
          info("  native    installing the APK (#{reason})")
          install!(serial)
          true
      end

    node = attach!(serial, installed?)
    info("  node      #{node}")

    if Keyword.get(opts, :push, true),
      do: hot_push!(node),
      else: info("  modules   not pushed (--no-push)")

    Map.put(partition, :node, node)
  end

  defp native_change(serial, opts) do
    installed = last_update(serial)
    stamp = read_stamp(serial)

    cond do
      opts[:install] -> {:install, "--install"}
      installed == nil -> {:install, "the app is not installed"}
      stamp == nil -> {:install, "this runner never installed it"}
      stamp.updated != installed -> {:install, "it was installed again by something else"}
      stamp.hash != native_hash() -> {:install, "native sources changed"}
      true -> :current
    end
  end

  defp install!(serial) do
    # The hash is taken before the build: a Kotlin file saved mid-build then counts as
    # changed next time instead of being recorded as built.
    hash = native_hash()
    mix!(["android.native", "--device", serial], "dev")

    case last_update(serial) do
      nil -> Mix.raise("#{@bundle_id} is not on #{serial} after `mix android.native`")
      updated -> write_stamp(serial, %{hash: hash, updated: updated})
    end
  end

  # What the installed build was made from, apart from Elixir (hot-pushed): the files git
  # knows (modified or new ones included, generated ones not), plus mob.exs, which it
  # ignores on purpose.
  defp native_hash do
    files =
      case System.cmd(
             "git",
             [
               "ls-files",
               "-z",
               "--cached",
               "--others",
               "--exclude-standard",
               "--" | @native_paths
             ],
             stderr_to_stdout: true
           ) do
        {out, 0} -> String.split(out, "\0", trim: true)
        _no_git -> walk_native_files()
      end

    (files ++ ["mob.exs"])
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.filter(&File.regular?/1)
    |> Enum.reduce(:crypto.hash_init(:sha256), fn path, acc ->
      acc |> :crypto.hash_update(path) |> :crypto.hash_update(File.read!(path))
    end)
    |> :crypto.hash_final()
    |> Base.encode16(case: :lower)
  end

  defp walk_native_files do
    @native_paths
    |> Enum.flat_map(&Path.wildcard(Path.join(&1, "**/*"), match_dot: true))
    |> Enum.reject(fn path -> Enum.any?(Path.split(path), &(&1 in @generated_dirs)) end)
  end

  defp stamp_path(serial), do: Path.join([Mix.Project.build_path(), "e2e", serial <> ".stamp"])

  defp read_stamp(serial) do
    with {:ok, text} <- File.read(stamp_path(serial)),
         [hash, updated] <- String.split(text, "\n", parts: 2, trim: true) do
      %{hash: hash, updated: updated}
    else
      _ -> nil
    end
  end

  defp write_stamp(serial, %{hash: hash, updated: updated}) do
    File.mkdir_p!(Path.dirname(stamp_path(serial)))
    File.write!(stamp_path(serial), hash <> "\n" <> updated)
  end

  defp last_update(serial) do
    with {:ok, out} <- adb(serial, ["shell", "dumpsys", "package", @bundle_id]),
         [_, time] <- Regex.run(~r/lastUpdateTime=(.+)/, out) do
      String.trim(time)
    else
      _ -> nil
    end
  end

  # The app's node, found in EPMD through the tunnels MobDev.Connector sets up. A freshly
  # installed app is still booting (it registers a few seconds after it starts), so it is
  # given a while. One that does not answer after that is restarted once: it may have
  # started before the tunnels existed (it registers in EPMD through `adb reverse`) or died.
  defp attach!(serial, fresh?) do
    attempts = if fresh?, do: @boot_attempts, else: 1

    with :error <- Enum.find_value(1..attempts, :error, &attach_attempt(serial, &1)),
         _ = info("  app       not answering, restarting it"),
         :error <- connect(serial, true) do
      Mix.raise("""
      #{serial}: the app is not reachable over Erlang distribution, even after a restart.
      Check `adb -s #{serial} logcat -d | grep -i -E 'mob|beam|AndroidRuntime'`.
      """)
    else
      {:ok, node} -> node
    end
  end

  defp attach_attempt(serial, _attempt) do
    case connect(serial, false) do
      {:ok, node} -> {:ok, node}
      :error -> nil
    end
  end

  defp connect(serial, restart?) do
    opts = [platforms: [:android], only: [serial], restart: restart?]
    {{connected, _failed}, log} = quietly(fn -> mob_dev(Connector, :connect_all, [opts]) end)

    case Enum.find(connected, &(&1.serial == serial)) do
      nil ->
        if restart?, do: IO.write(log)
        :error

      %{node: node} ->
        {:ok, node}
    end
  end

  # This VM is done with the app. Left connected, it would be in the mesh the test VMs join
  # when they connect to the same node, under a cookie they do not share: every one of them
  # logs a rejected connection and `global` splits the partitions.
  defp leave_distribution(ready) do
    Enum.each(ready, &Node.disconnect(&1.node))
    Node.stop()
    :ok
  end

  # ── Hot push ───────────────────────────────────────────────────────────────

  defp hot_push!(node) do
    local = local_modules()
    remote = remote_md5s(node, Keyword.keys(local))

    stale =
      for {module, {path, md5}} <- local, Map.get(remote, module) != md5, do: {module, path}

    Enum.each(stale, fn {module, path} -> load!(node, module, path) end)

    still_stale =
      node
      |> remote_md5s(Enum.map(stale, &elem(&1, 0)))
      |> Enum.filter(fn {module, md5} -> md5 != local |> Keyword.fetch!(module) |> elem(1) end)

    unless still_stale == [] do
      Mix.raise(
        "hot push did not take for: #{Enum.map_join(still_stale, ", ", &inspect(elem(&1, 0)))}"
      )
    end

    info("  modules   #{length(stale)} of #{length(local)} loaded (the rest already match)")
  end

  defp local_modules do
    for path <- Path.wildcard(Path.join(Mix.Project.compile_path(), "*.beam")) do
      {:ok, {module, md5}} = :beam_lib.md5(String.to_charlist(path))
      {module, {path, md5}}
    end
  end

  # One request per module, all in flight at once: over a USB tunnel a round trip each
  # would take seconds. A module the app does not have answers with an error, which is
  # a module to load.
  defp remote_md5s(node, modules) do
    modules
    |> Enum.map(&{&1, :erpc.send_request(node, &1, :module_info, [:md5])})
    |> Map.new(fn {module, request} ->
      md5 =
        try do
          :erpc.receive_response(request, 30_000)
        catch
          _kind, _reason -> nil
        end

      {module, md5}
    end)
  end

  # soft_purge first: a second push of the same module meets the first one's old code,
  # and load_binary refuses until that is gone. Killing the processes still running it
  # is the last resort.
  defp load!(node, module, path) do
    binary = File.read!(path)
    file = String.to_charlist(path)
    :erpc.call(node, :code, :soft_purge, [module], 30_000)

    case :erpc.call(node, :code, :load_binary, [module, file, binary], 30_000) do
      {:module, ^module} ->
        :ok

      {:error, :not_purged} ->
        :erpc.call(node, :code, :purge, [module], 30_000)
        {:module, ^module} = :erpc.call(node, :code, :load_binary, [module, file, binary], 30_000)

      other ->
        Mix.raise("could not load #{inspect(module)} on #{node}: #{inspect(other)}")
    end
  end

  # ── Running the partitions ─────────────────────────────────────────────────

  defp start_partitions(ready, targets, opts, extra, report) do
    mix = System.find_executable("mix") || Mix.raise("mix is not on the PATH")

    # Compiled once, here: partitions that compile the same build at the same moment
    # wait for each other's lock for nothing.
    mix!(["compile"], "test")

    parallel? = match?([_, _ | _], ready)
    info("\nrunning #{if parallel?, do: "#{length(ready)} partitions", else: "the suite"}")

    for partition <- ready do
      args = test_args(partition, targets, opts, extra, report)
      env = test_env(partition, report)

      port =
        Port.open({:spawn_executable, mix}, [
          :binary,
          :exit_status,
          :stderr_to_stdout,
          {:line, 16_384},
          {:args, args},
          {:env, env},
          {:cd, File.cwd!()}
        ])

      log = report && File.open!(Path.join(report, "mix-test-#{partition.index}.log"), [:write])

      Map.merge(partition, %{
        port: port,
        log: log,
        prefix: if(parallel?, do: "[#{partition.serial}] ", else: ""),
        partial: "",
        lines: [],
        status: nil,
        started: System.monotonic_time(:millisecond),
        finished: nil
      })
    end
  end

  defp test_args(partition, targets, opts, extra, report) do
    flags =
      [
        if(opts[:trace], do: ["--trace"], else: []),
        if(opts[:seed], do: ["--seed", to_string(opts[:seed])], else: []),
        if(opts[:max_failures], do: ["--max-failures", to_string(opts[:max_failures])], else: []),
        if(partition.count > 1, do: ["--partitions", to_string(partition.count)], else: []),
        if(report,
          do: ["--formatter", "JUnitFormatter", "--formatter", "ExUnit.CLIFormatter"],
          else: []
        ),
        if(IO.ANSI.enabled?(), do: ["--color"], else: [])
      ]

    ["test", "--only", "device"] ++
      Enum.concat(flags) ++ extra ++ if(targets == [], do: [@tests], else: targets)
  end

  defp test_env(partition, report) do
    [
      {"MIX_ENV", "test"},
      {"MOB_DEVICE_NODE", Atom.to_string(partition.node)},
      {"MIX_TEST_PARTITION", partition.count > 1 && to_string(partition.index)},
      {"E2E_REPORT_DIR", report || false}
    ]
    |> Enum.map(fn {name, value} ->
      {String.to_charlist(name), if(value, do: String.to_charlist(value), else: false)}
    end)
  end

  defp collect(partitions) do
    partitions |> Map.new(&{&1.port, &1}) |> loop()
  end

  defp loop(states) do
    if Enum.all?(Map.values(states), & &1.status) do
      states |> Map.values() |> Enum.sort_by(& &1.index)
    else
      receive do
        {port, {:data, {:eol, line}}} when is_map_key(states, port) ->
          loop(Map.update!(states, port, &emit(&1, &1.partial <> line <> "\n")))

        {port, {:data, {:noeol, chunk}}} when is_map_key(states, port) ->
          loop(Map.update!(states, port, &%{&1 | partial: &1.partial <> chunk}))

        {port, {:exit_status, status}} when is_map_key(states, port) ->
          loop(Map.update!(states, port, &finish(&1, status)))
      end
    end
  end

  defp emit(state, line) do
    IO.write(state.prefix <> line)
    if state.log, do: IO.write(state.log, line)
    %{state | partial: "", lines: [line | state.lines]}
  end

  defp finish(state, status) do
    if state.log, do: File.close(state.log)
    %{state | status: status, finished: System.monotonic_time(:millisecond)}
  end

  # The device's own log, which is where an app that died says why. Cleared first so it
  # holds this run only.
  defp with_logcat(_serials, nil, fun), do: fun.()

  defp with_logcat(serials, report, fun) do
    pids =
      for serial <- serials do
        adb(serial, ["logcat", "-c"])
        file = Path.join(report, "logcat-#{serial}.txt")

        port =
          Port.open({:spawn_executable, "/bin/sh"}, [
            :exit_status,
            args: ["-c", "exec adb -s #{serial} logcat -v time > '#{file}' 2>&1"]
          ])

        {:os_pid, pid} = Port.info(port, :os_pid)
        pid
      end

    try do
      fun.()
    after
      Enum.each(pids, &System.cmd("kill", [to_string(&1)]))
    end
  end

  # ── Summary ────────────────────────────────────────────────────────────────

  @doc """
  What `mix test` reported in `output`: `%{tests, failures, failed}`, where `failed` lists
  each failing test with its location. `nil` when there is no summary line (a run that
  died before it).

  Elixir 1.20 prints `Result: 190/191 passed` (or `Result: 191 passed`); earlier versions
  `191 tests, 1 failure`. Both are read, colours or not.
  """
  @spec parse_summary(output :: String.t()) ::
          %{tests: non_neg_integer(), failures: non_neg_integer(), failed: [String.t()]} | nil
  def parse_summary(output) do
    text = Regex.replace(~r/\e\[[0-9;]*m/, output, "")

    case counts(text) do
      nil -> nil
      {tests, failures} -> %{tests: tests, failures: failures, failed: failed_tests(text)}
    end
  end

  defp counts(text) do
    case Regex.run(~r/^Result: (\d+)\/(\d+) passed/m, text, capture: :all_but_first) do
      [passed, total] ->
        {String.to_integer(total), String.to_integer(total) - String.to_integer(passed)}

      nil ->
        counts_all_passed(text)
    end
  end

  defp counts_all_passed(text) do
    case Regex.run(~r/^Result: (\d+) passed/m, text, capture: :all_but_first) do
      [passed] -> {String.to_integer(passed), 0}
      nil -> counts_before_1_20(text)
    end
  end

  defp counts_before_1_20(text) do
    case Regex.scan(~r/^(?:\d+ doctests?, )?(\d+) tests?, (\d+) failures?/m, text,
           capture: :all_but_first
         ) do
      [] ->
        if text =~ ~r/^Result: 0 tests/m, do: {0, 0}

      matches ->
        [tests, failures] = List.last(matches)
        {String.to_integer(tests), String.to_integer(failures)}
    end
  end

  defp failed_tests(output) do
    lines = String.split(output, "\n")

    for {line, index} <- Enum.with_index(lines),
        [_, name] <- [Regex.run(~r/^\s{1,4}\d+\) (.+)$/, line)] do
      location = Enum.at(lines, index + 1, "")

      if Regex.match?(~r/^\s+\S+\.exs?:\d+/, location),
        do: name <> " - " <> String.trim(location),
        else: name
    end
  end

  defp summarize(results, wall_ms) do
    info("\n" <> String.duplicate("─", 24) <> " e2e summary " <> String.duplicate("─", 24))

    rows =
      for result <- results do
        {result, result.lines |> Enum.reverse() |> Enum.join() |> parse_summary()}
      end

    Enum.each(rows, &print_row/1)

    summaries = for {_result, %{} = summary} <- rows, do: summary
    tests = summaries |> Enum.map(& &1.tests) |> Enum.sum()
    failures = summaries |> Enum.map(& &1.failures) |> Enum.sum()
    info("  total            #{tests} tests, #{failures} failures, #{duration(wall_ms)} wall")

    for {result, %{failed: failed}} <- rows, line <- failed do
      info("  failed [#{result.serial}] #{line}")
    end

    broken =
      for {result, summary} <- rows, result.status != 0 or is_nil(summary), do: result.serial

    if broken != [], do: Mix.raise("the device suite failed on #{Enum.join(broken, ", ")}")
    :ok
  end

  defp print_row({result, summary}) do
    share = if result.count > 1, do: "#{result.index}/#{result.count}", else: "all"

    what =
      case summary do
        nil -> "no summary (exit #{result.status})"
        %{tests: tests, failures: failures} -> "#{tests} tests, #{failures} failures"
      end

    took = duration(result.finished - result.started)

    info(
      "  #{String.pad_trailing(result.serial, 16)} #{String.pad_trailing(share, 5)} #{what} in #{took}"
    )
  end

  defp duration(ms) do
    seconds = div(ms, 1000)

    if seconds >= 60,
      do: "#{div(seconds, 60)}m#{rem(seconds, 60)}s",
      else: "#{seconds}.#{div(rem(ms, 1000), 100)}s"
  end

  # ── Plumbing ───────────────────────────────────────────────────────────────

  defp info(message), do: Mix.shell().info(message)

  # mob_dev is a :dev-only dependency, and the unit tests compile this file in :test,
  # where a direct call would warn about a module that does not exist.
  defp mob_dev(module, function, args), do: apply(Module.concat(MobDev, module), function, args)

  # Output a library prints for itself, kept out of the run's output unless it is needed.
  defp quietly(fun) do
    {:ok, io} = StringIO.open("")

    task =
      Task.async(fn ->
        Process.group_leader(self(), io)
        fun.()
      end)

    result = Task.await(task, :infinity)

    {_input, output} = StringIO.contents(io)
    StringIO.close(io)
    {result, output}
  end

  defp mix!(args, env) do
    mix = System.find_executable("mix") || Mix.raise("mix is not on the PATH")

    case System.cmd(mix, args,
           env: [{"MIX_ENV", env}],
           into: IO.stream(:stdio, :line),
           stderr_to_stdout: true
         ) do
      {_, 0} -> :ok
      {_, code} -> Mix.raise("mix #{Enum.join(args, " ")} failed with exit #{code}")
    end
  end

  # adb answers within a second or not at all: an emulator that hung, a phone that went to
  # sleep. System.cmd has no timeout of its own.
  defp adb(serial, args, timeout \\ @adb_ms) do
    task = Task.async(fn -> System.cmd("adb", ["-s", serial | args], stderr_to_stdout: true) end)

    case Task.yield(task, timeout) || Task.shutdown(task, :brutal_kill) do
      {:ok, {out, 0}} -> {:ok, out}
      {:ok, {out, code}} -> {:error, "exit #{code}: #{out}"}
      _timeout -> {:error, :timeout}
    end
  end
end
