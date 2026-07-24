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

            {:mob, "~> 0.7"}

        The files will still be generated — they just will not compile until the
        dependency is there.
        """)

      _ ->
        igniter
    end
  end
end
