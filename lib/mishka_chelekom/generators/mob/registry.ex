defmodule MishkaChelekom.Generators.Mob.Registry do
  @moduledoc """
  Maintains `lib/<app>/components.ex` — the module that registers every generated
  component as a `Mob.Composite` tag.

  Without registration a component still works when called as a function, but
  `<Drawer>` in `~MOB` markup does not resolve. Registering is one line per
  component, and forgetting it produces markup that renders nothing with no error.

  The tag follows the run's `--module-prefix`: none gives `:drawer`,
  `--module-prefix acme_` gives `:acme_drawer`. Tags are global to
  `Mob.Composite`, so prefixing is also how an app avoids colliding with a
  composite it already owns.

  ## Rebuilt, not appended

  The registry is regenerated from the component files actually present, rather
  than having a line appended on each run. Appending is what makes generators
  produce duplicate entries when re-run and stale ones after an uninstall; a
  rebuild is idempotent by construction.
  """

  alias MishkaChelekom.Generators.Core
  alias MishkaChelekom.Generators.Mob.Locations

  @config_file "config.exs"
  @config_path [:extra_tags]

  @doc """
  Declares the registered tags in the app's `config :mob, :extra_tags`, so they
  compile as tags without an "unknown tag" warning.

  Registering a composite makes `<Drawer>` *render*. It does not make it compile
  quietly: `~MOB` validates tag names at compile time, and a runtime
  registration is invisible to that check. Mob documents `:extra_tags` as the
  app-level way to declare them, and says not to write into its own
  `priv/tags/*.txt` — `mix deps.get` discards that. So the tags go into the
  app's own `config/config.exs`, in the same list Mob reads.

  The tags come from `entries/2`, the list that reaches `Mob.Composite.register/2`,
  which is what carries `--module-prefix` through: `--module-prefix acme_`
  registers `:acme_chip` and declares `AcmeChip`.

  Only missing tags are added, so running it for one component, ten, or the same
  one twice gives the same list. Tags already in the list — yours, or another
  kit's — are left where they are.

  Mob does not track that config read, so `compile --force` is queued: without
  it, screens that were already compiled keep warning.
  """
  @spec whitelist(Igniter.t(), keyword()) :: Igniter.t()
  def whitelist(igniter, opts \\ []) do
    case tag_names(igniter, opts) do
      [] -> igniter
      tags -> update_extra_tags(igniter, add: tags)
    end
  end

  @doc """
  Takes `tags` out of `config :mob, :extra_tags`, leaving every other entry.

  Uninstall needs this rather than a rebuild: unlike a file the generator owns,
  the list is shared with the app and other kits.
  """
  @spec unwhitelist(Igniter.t(), [String.t()]) :: Igniter.t()
  def unwhitelist(igniter, []), do: igniter

  def unwhitelist(igniter, tags) do
    if declared?(igniter), do: update_extra_tags(igniter, remove: tags), else: igniter
  end

  @doc "The `~MOB` spelling of every tag in `entries/2` (`:acme_chip` becomes `\"AcmeChip\"`)."
  @spec tag_names(Igniter.t(), keyword()) :: [String.t()]
  def tag_names(igniter, opts \\ []) do
    igniter
    |> entries(opts)
    |> Enum.map(fn {tag, _module} -> tag |> Atom.to_string() |> Macro.camelize() end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp declared?(igniter) do
    path = Path.join("config", @config_file)

    Igniter.exists?(igniter, path) and
      igniter |> Igniter.include_existing_file(path) |> source_content(path) =~ "extra_tags"
  end

  defp source_content(igniter, path),
    do: igniter.rewrite.sources[path] |> Rewrite.Source.get(:content)

  defp update_extra_tags(igniter, change) do
    add = Keyword.get(change, :add, [])
    remove = Keyword.get(change, :remove, [])

    igniter
    |> Igniter.Project.Config.configure(
      @config_file,
      :mob,
      @config_path,
      add,
      updater: &update_tags(&1, add, remove)
    )
    |> queue_recompile()
  end

  # A new setting is a plain list of strings, which Mob reads as PascalCase tag
  # names. An existing list is edited with Igniter's own list helpers, and the
  # `~w(...)` form `mix mob.new` writes is rewritten word by word. Anything else
  # was written by hand, and guessing at its shape could break the app's config,
  # so those tags are left for the user and the generator says so.
  defp update_tags(zipper, add, remove) do
    cond do
      Igniter.Code.List.list?(zipper) ->
        update_list(zipper, add, remove)

      match?({:sigil_w, _, _}, Sourceror.Zipper.node(zipper)) ->
        update_sigil(zipper, add, remove)

      true ->
        {:warning,
         "config :mob, :extra_tags is neither a list nor a ~w(...) sigil, so these tags were not " <>
           "edited in it: " <> Enum.join(add ++ remove, " ")}
    end
  end

  defp update_list(zipper, add, remove) do
    with {:ok, zipper} <- reduce_list(zipper, add, &Igniter.Code.List.append_new_to_list/2) do
      Igniter.Code.List.remove_from_list(zipper, fn item ->
        Enum.any?(remove, &Igniter.Code.Common.nodes_equal?(item, &1))
      end)
    end
  end

  defp reduce_list(zipper, tags, fun) do
    Enum.reduce_while(tags, {:ok, zipper}, fn tag, {:ok, acc} ->
      case fun.(acc, tag) do
        {:ok, next} -> {:cont, {:ok, next}}
        other -> {:halt, other}
      end
    end)
  end

  defp update_sigil(zipper, add, remove) do
    {:sigil_w, _meta, [{:<<>>, _, [text]}, _mods]} = Sourceror.Zipper.node(zipper)

    words =
      text
      |> String.split()
      |> Kernel.--(remove)
      |> then(&(&1 ++ Enum.reject(add, fn tag -> tag in &1 end)))

    node = Sourceror.parse_string!("~w(\n" <> Enum.map_join(words, &"  #{&1}\n") <> ")")

    {:ok, Sourceror.Zipper.replace(zipper, node)}
  end

  defp queue_recompile(igniter) do
    if {"compile", ["--force"]} in igniter.tasks,
      do: igniter,
      else: Igniter.add_task(igniter, "compile", ["--force"])
  end

  @doc """
  Write the registry for whatever components exist, on disk or pending in this
  Igniter run.

  `:only` restricts it to the given component names. Uninstall needs that:
  `Path.wildcard/1` reads the real filesystem, so a file Igniter is about to
  delete is still there, and a registry built from the directory alone would
  keep naming it.
  """
  @spec write(Igniter.t(), keyword()) :: Igniter.t()
  def write(igniter, opts \\ []) do
    case entries(igniter, opts) do
      [] ->
        igniter

      entries ->
        path = Locations.registry_path(igniter)

        igniter
        |> Core.track_generated_file(path)
        |> Igniter.create_new_file(path, contents(igniter, entries), on_exists: :overwrite)
    end
  end

  @doc """
  Every `{tag, module}` pairing the registry should contain, sorted.

  Considers both files already on disk and files created earlier in this same
  run — a single `mix mishka.ui.gen.mob dialog` that pulls in siblings has to
  register all of them, and none of those exist on disk yet.
  """
  @spec entries(Igniter.t(), keyword()) :: [{atom(), module()}]
  def entries(igniter, opts \\ []) do
    known =
      case Keyword.get(opts, :only) do
        nil -> MapSet.new(Core.all_component_names(igniter, :mob))
        only -> MapSet.new(only)
      end

    # What this run created wins over what the directory implies: it carries the
    # real module, including a custom --module, which no filename can express.
    recorded = Map.get(igniter.assigns, :mob_registered, [])
    prefix = Map.get(igniter.assigns, :module_prefix, "")

    from_disk = scanned_entries(igniter, known)

    recorded
    |> Enum.filter(fn {component, _module} -> MapSet.member?(known, component) end)
    |> Enum.map(fn {component, module} -> {tag(component, prefix), module} end)
    |> Enum.concat(from_disk)
    |> Enum.uniq_by(&elem(&1, 0))
    |> Enum.sort()
  end

  # A file is matched against the catalog with the prefix stripped AND as-is, so
  # a component generated under a different prefix in an earlier run is still
  # found rather than silently dropped from the registry.
  defp scanned_entries(igniter, known) do
    dir = Locations.components_dir(igniter)
    prefix = Map.get(igniter.assigns, :module_prefix, "")

    (Path.wildcard("#{dir}/*.ex") ++ pending(igniter, dir))
    |> Enum.map(&Path.basename(&1, ".ex"))
    |> Enum.uniq()
    |> Enum.flat_map(fn file ->
      case component_for(file, prefix, known) do
        nil ->
          []

        component ->
          [{tag(component, prefix), Core.module_atom("#{igniter.assigns.mob_namespace}.#{file}")}]
      end
    end)
  end

  defp component_for(file, prefix, known) do
    stripped = String.replace_prefix(file, prefix, "")

    cond do
      MapSet.member?(known, stripped) -> stripped
      MapSet.member?(known, file) -> file
      true -> nil
    end
  end

  # The tag follows `--module-prefix`, so `<AcmeChip />` renders AcmeChip and
  # `<Chip />` renders Chip. With no prefix the tag is the bare component name,
  # which can collide with a composite the app already registered under that
  # name — Mob.Composite's table is global. That is the trade the flag exists
  # for: prefix your components and the tags are namespaced with them.
  # A tag from the component name and the prefix given on the command line.
  # sobelow_skip ["DOS.StringToAtom"]
  defp tag(component, prefix), do: String.to_atom("#{prefix}#{component}")

  defp pending(igniter, dir) do
    igniter.rewrite.sources
    |> Map.keys()
    |> Enum.filter(&String.starts_with?(&1, dir <> "/"))
  end

  defp contents(igniter, entries) do
    module = igniter.assigns.mob_namespace
    base = Locations.base_module(igniter)

    pairs =
      Enum.map_join(entries, ",\n", fn {tag, component} ->
        "    {#{inspect(tag)}, #{component}}"
      end)

    example_tag =
      entries |> List.first() |> elem(0) |> Atom.to_string() |> Macro.camelize()

    """
    defmodule #{module} do
      @moduledoc \"\"\"
      Composite-tag registry for the generated Mob components.

      Call `register_all/0` once at boot, from your app's `on_start/0`:

          def on_start do
            #{module}.register_all()
            Mob.Nav.push(#{base}.HomeScreen)
          end

      After that, `<#{example_tag} />` resolves as a tag in `~MOB` markup.

      Regenerated by `mix mishka.ui.gen.mob` — edits are overwritten. Pass
      `--no-register` if you would rather own this file yourself.
      \"\"\"

      @composites [
    #{pairs}
      ]

      @doc "Every `{tag, module}` pairing this app registers."
      @spec composites() :: [{atom(), module()}]
      def composites, do: @composites

      @doc "Registers every composite tag with `Mob.Composite`."
      @spec register_all() :: :ok
      def register_all do
        Enum.each(@composites, fn {tag, module} ->
          Mob.Composite.register(tag, {module, :expand})
        end)
      end
    end
    """
  end

  @doc """
  Calls `register_all/0` from the app's `on_start/0`.

  Writing the registry is only half of it. `Mob.Composite`'s table is populated
  at runtime, so a registry nothing calls leaves every tag unregistered — and an
  unregistered tag does not fail, it renders **nothing**. Wiring the call is what
  makes `<Drawer>` actually draw, so it is done here rather than left as a step
  in the docs to be missed.

  Idempotent, and a no-op when the app module cannot be found (a project that
  boots differently keeps its own arrangement) — in which case the call to add is
  reported as a notice instead.
  """
  @spec wire_boot(Igniter.t()) :: Igniter.t()
  # The project's own modules.
  # sobelow_skip ["DOS.ModuleConcat"]
  def wire_boot(igniter) do
    module = Module.concat([Locations.base_module(igniter), "App"])
    # Interpolated, not inspected: the namespace is a plain atom rather than an
    # Elixir alias, so inspect/1 renders it quoted — `:"Test.Components"` — and
    # emits code that names an atom instead of the module.
    call = "#{igniter.assigns.mob_namespace}.register_all()"

    case Igniter.Project.Module.find_module(igniter, module) do
      {:ok, {igniter, _source, _zipper}} -> update_on_start(igniter, module, call)
      {:error, igniter} -> notice(igniter, module, call)
    end
  end

  # The project's own modules.
  # sobelow_skip ["DOS.ModuleConcat"]
  defp update_on_start(igniter, module, call) do
    # Module.concat/1 turns the namespace into a real alias — the assign is a
    # plain `:"MyApp.Components"`, which no `__aliases__` node would match.
    registry = Module.concat([igniter.assigns.mob_namespace])

    Igniter.Project.Module.find_and_update_module!(igniter, module, fn zipper ->
      with {:ok, body} <- Igniter.Code.Function.move_to_def(zipper, :on_start, 0),
           :error <-
             Igniter.Code.Function.move_to_function_call_in_current_scope(
               body,
               {registry, :register_all},
               0
             ) do
        {:ok, Igniter.Code.Common.add_code(body, call, placement: :before)}
      else
        # No on_start/0 to edit, or the call is already there. Both are fine and
        # neither is worth an issue: the registry itself is already written.
        _ -> {:ok, zipper}
      end
    end)
  end

  defp notice(igniter, module, call) do
    Igniter.add_notice(igniter, """
    Could not find #{inspect(module)}, so the composite tags are not registered yet.

    Add this to your app's `on_start/0` — until it runs, a tag like `<Drawer>`
    renders nothing at all:

        #{call}
    """)
  end

  @doc """
  Adds an issue unless the project depends on `:mob`.

  `Core.check_dependencies/1` requires Phoenix, which a Mob application does not
  have — it is a plain OTP app that renders native widgets.
  """
  @spec check_dependency(Igniter.t()) :: Igniter.t()
  def check_dependency(igniter) do
    case Igniter.Project.Deps.get_dep(igniter, :mob) do
      {:ok, nil} ->
        Igniter.add_warning(igniter, """
        This project does not depend on :mob.

        Mob components render native widgets through the Mob runtime. Add it with:

            {:mob, "~> 0.9"}

        The files will still be generated — they just will not compile until the
        dependency is there.
        """)

      _ ->
        igniter
    end
  end
end
