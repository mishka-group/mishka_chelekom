defmodule Mix.Tasks.Mishka.Mob.Sync do
  use Igniter.Mix.Task

  alias MishkaChelekom.Generators.Mob

  @example "mix mishka.mob.sync"
  @shortdoc "Regenerate priv/mob from the Mob app in development/mob (library maintainers only)"
  @moduledoc """
  #{@shortdoc}

  `development/mob` is a real Mob application: the components there are the ones
  with a showcase and a test suite, and the ones that run on a device. This task
  derives `priv/mob/<name>.{eex,exs}` from them, so the catalog a consumer
  generates from cannot drift from the code we actually exercise.

  Consumers never run this. They run `mix mishka.ui.gen.mob`.

  ## What it writes

    * `priv/mob/<name>.eex` — the component, with its module name, namespace and
      public function turned into EEx assigns
    * `priv/mob/<name>.exs` — the catalog: category and doc_url lifted from the
      matching headless catalog, plus `necessary` (sibling components) and
      `mob: [kit: …]` (shared support modules)
    * `priv/mob/kit/<name>.eex` — the shared `Event` and `Color` modules, which
      are not components and are vendored by `mix mishka.ui.gen.mob.kit`

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--source` - Read components from a different directory
  * `--only` - Comma-separated component names, instead of all of them
  * `--yes` - Apply without prompts
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      example: @example,
      group: :mishka_chelekom,
      schema: [source: :string, only: :csv]
    }
  end

  def supports_umbrella?(), do: false

  def igniter(igniter) do
    igniter
    |> assign_source()
    |> discover_components()
    |> build_component_templates()
    |> write_component_templates()
    |> write_kit_templates()
  end

  defp assign_source(igniter) do
    source = igniter.args.options[:source] || Mob.source_dir()

    if File.dir?(source) do
      Igniter.assign(igniter, :mob_source, source)
    else
      Igniter.add_issue(igniter, "Mob source directory not found: #{source}")
    end
  end

  defp discover_components(%{assigns: %{mob_source: source}} = igniter) do
    # A :csv option arrives as [] when absent, never nil.
    requested =
      case igniter.args.options[:only] do
        empty when empty in [nil, []] -> nil
        list -> MapSet.new(list)
      end

    components =
      source
      |> Mob.components()
      |> Enum.filter(fn {name, _path} -> is_nil(requested) or MapSet.member?(requested, name) end)

    case components do
      [] -> Igniter.add_issue(igniter, "No Mob components matched in #{source}")
      found -> Igniter.assign(igniter, :mob_components, found)
    end
  end

  defp discover_components(igniter), do: igniter

  defp build_component_templates(%{assigns: %{mob_components: components}} = igniter) do
    source_dir = igniter.assigns.mob_source

    built =
      Enum.map(components, fn {name, path} ->
        source = File.read!(path)
        companions = name |> Mob.companions(source_dir) |> Enum.map(&File.read!/1)

        %{
          name: name,
          template: Mob.templatize(source, component: name, companions: companions),
          catalog:
            Mob.catalog(name,
              necessary: necessary(source),
              kit: Mob.kit_dependencies(Enum.join([source | companions], "\n")),
              function: Mob.public_function(name, source)
            )
        }
      end)

    Igniter.assign(igniter, :mob_templates, built)
  end

  defp build_component_templates(igniter), do: igniter

  # A sibling's module suffix underscores back to its component name, which is
  # exactly what `necessary:` lists — the generator then offers to build them.
  defp necessary(source) do
    source
    |> Mob.siblings()
    |> Enum.map(fn {_suffix, component} -> component end)
    |> Enum.sort()
  end

  defp write_component_templates(%{assigns: %{mob_templates: templates}} = igniter) do
    Enum.reduce(templates, igniter, fn built, acc ->
      acc
      |> Igniter.create_new_file("priv/mob/#{built.name}.eex", built.template,
        on_exists: :overwrite
      )
      |> Igniter.create_new_file("priv/mob/#{built.name}.exs", built.catalog,
        on_exists: :overwrite
      )
    end)
  end

  defp write_component_templates(igniter), do: igniter

  defp write_kit_templates(%{assigns: %{mob_source: source}} = igniter) do
    Enum.reduce(Mob.kit_modules(), igniter, fn kit, acc ->
      path = Path.join(source, "#{kit}.ex")

      if File.exists?(path) do
        template = Mob.templatize_kit(File.read!(path))

        Igniter.create_new_file(acc, "priv/mob/kit/#{kit}.eex", template, on_exists: :overwrite)
      else
        Igniter.add_issue(acc, "Kit module not found: #{path}")
      end
    end)
  end

  defp write_kit_templates(igniter), do: igniter
end
