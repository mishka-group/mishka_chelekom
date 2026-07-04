defmodule MishkaCliHelper do
  @moduledoc """
  Helpers for the direct, end-to-end mix-command tests in the development harness.

  Two flavours, used together per command:

    * `mix!/2` — invoke the REAL task via `Mix.Task.rerun`, applying its changes to the dev
      app's filesystem (true e2e). Always pair a mutation with cleanup:
        - generate with a `uniq_prefix/1` so the new file can't collide with a committed
          one, then `rm_generated/1` in `on_exit`;
        - or `snapshot/1` a committed file before a real uninstall, then `restore/1`.

    * `stage/2` — run the task through `Igniter.new/0` WITHOUT touching disk, returning the
      staged igniter, so every option (exclude, prefixes, flags, …) can be asserted
      exhaustively and non-destructively via `igniter.rewrite.sources` / `igniter.rms`.

  Real uninstall tests pass `--keep-js` and omit `--all`/`--include-css`/`--include-config`
  so the ONLY on-disk change is the component file itself, which `restore/1` puts back
  verbatim — committed *and* uncommitted harness state is preserved exactly.
  """

  @components_dir "lib/development_web/components"
  @headless_dir "lib/development_web/components/headless"

  def components_dir, do: @components_dir
  def headless_dir, do: @headless_dir
  def styled_path(name), do: "#{@components_dir}/#{name}.ex"
  def headless_path(name), do: "#{@headless_dir}/#{name}.ex"

  @doc "Run a real mix task end-to-end (re-enabled so it can run more than once per suite)."
  def mix!(task, argv) do
    Mix.Task.reenable(task)
    Mix.Task.rerun(task, argv)
  end

  @doc "Compose a task in-memory against the real dev project; nothing is written to disk."
  def stage(task_module, argv), do: Igniter.compose_task(Igniter.new(), task_module, argv)

  def staged?(igniter, path), do: Map.has_key?(igniter.rewrite.sources, path)

  def staged_content(igniter, path) do
    case igniter.rewrite.sources[path] do
      nil -> nil
      source -> Rewrite.Source.get(source, :content)
    end
  end

  @doc "A per-test-unique module prefix so generated files never collide with committed ones."
  def uniq_prefix(tag \\ "x"), do: "Clix#{tag}#{System.unique_integer([:positive])}"

  @doc "The on-disk path a prefixed generation lands at (`<prefix><component>.ex`)."
  def prefixed_styled_path(prefix, component), do: "#{@components_dir}/#{prefix}#{component}.ex"
  def prefixed_headless_path(prefix, component), do: "#{@headless_dir}/#{prefix}#{component}.ex"

  def rm_generated(paths), do: paths |> List.wrap() |> Enum.each(&File.rm_rf!/1)

  @doc "Capture a file's current content (or its absence) for later exact restoration."
  def snapshot(path), do: {path, File.read(path)}

  def restore({path, {:ok, content}}), do: File.write!(path, content)
  def restore({path, {:error, _}}), do: File.rm_rf!(path)

  def styled_rms(igniter) do
    Enum.filter(igniter.rms, fn p ->
      String.starts_with?(p, @components_dir <> "/") and not String.contains?(p, "/headless/")
    end)
  end

  def headless_rms(igniter), do: Enum.filter(igniter.rms, &String.contains?(&1, "/headless/"))
end
