defmodule Mix.Tasks.Mishka.Ui.Gen.Mob.Kit do
  use Igniter.Mix.Task

  alias MishkaChelekom.Generators.{Core, Mob}

  @example "mix mishka.ui.gen.mob.kit"
  @shortdoc "Vendor the shared Mob support modules (Event, Color) into your app"
  @moduledoc """
  #{@shortdoc}

  Mob components share two support modules that are **not** Chelekom components —
  nobody generates `event` by name:

    * `Event` — widens a bare event tag into the `{screen_pid, tag}` the renderer
      registers. A handler prop that skips this serialises as an ordinary prop and
      the control renders perfectly and does nothing, which is the single easiest
      mistake to make in a Mob component.
    * `Color` — hex parsing, HSV↔RGB and ARGB packing, used by the colour
      controls.

  They are vendored once, into `lib/<app>/components/`, and are never
  module-prefixed: a prefix distinguishes *your* components from someone else's,
  and these are neither — they are the shared floor both stand on.

  Run this before generating any component. `mix mishka.ui.gen.mob` composes it
  for you when a component needs it, so you rarely run it by hand.

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--only` - Comma-separated kit modules, instead of all of them
  * `--module-prefix` - Not applied to the kit modules themselves, but their docs
    reference components, and those follow the prefix
  * `--yes` - Apply without prompts
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      example: @example,
      group: :mishka_chelekom,
      schema: [only: :csv, sub: :boolean, module_prefix: :string]
    }
  end

  def supports_umbrella?(), do: false

  def igniter(igniter) do
    Application.ensure_all_started(:owl)
    sub? = igniter.args.options[:sub] == true
    spin? = !sub? and Mix.env() != :test and IO.ANSI.enabled?()

    if !sub? and Mix.env() != :test, do: Core.banner(IO.ANSI.magenta(), "Mob Kit")
    if spin?, do: Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    final =
      igniter
      |> Mob.Locations.assign_namespace()
      |> assign_requested_modules()
      |> write_kit_modules()

    if spin? do
      if Map.get(final, :issues, []) == [],
        do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
        else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")
    end

    final
  end

  defp assign_requested_modules(igniter) do
    # A :csv option is `[]` when absent, not nil — matching only on nil would
    # make a bare invocation filter down to nothing.
    requested =
      case igniter.args.options[:only] do
        empty when empty in [nil, []] -> Mob.kit_modules()
        list -> Enum.filter(list, &(&1 in Mob.kit_modules()))
      end

    case requested do
      [] ->
        Igniter.add_issue(
          igniter,
          "No known kit modules requested. Available: #{Enum.join(Mob.kit_modules(), ", ")}"
        )

      modules ->
        Igniter.assign(igniter, :mob_kit_modules, modules)
    end
  end

  defp write_kit_modules(%{assigns: %{mob_kit_modules: modules}} = igniter) do
    Enum.reduce(modules, igniter, fn kit, acc ->
      template = Core.lib_priv("mob/kit/#{kit}.eex")

      if File.exists?(template) do
        namespace = acc.assigns.mob_namespace

        # Core.module_atom, not Module.concat: the latter yields an
        # `Elixir.`-prefixed atom that a template would interpolate verbatim.
        module = Core.module_atom("#{namespace}.#{kit}")

        acc
        |> Core.track_generated_file(Mob.Locations.kit_path(acc, kit))
        |> Igniter.copy_template(
          template,
          Mob.Locations.kit_path(acc, kit),
          Mob.eex_assigns(module, namespace, module_prefix_camel: kit_prefix_camel(acc)),
          on_exists: :overwrite
        )
      else
        Igniter.add_issue(acc, "Kit template missing: #{template}. Run `mix mishka.mob.sync`.")
      end
    end)
  end

  defp write_kit_modules(igniter), do: igniter

  # The kit modules are never prefixed themselves, but their moduledocs name
  # components (`<MishkaDrawer />`), and those tags follow the run's prefix.
  defp kit_prefix_camel(igniter) do
    igniter.args.options[:module_prefix]
    |> Mob.Locations.normalize_prefix()
    |> String.trim_trailing("_")
    |> Macro.camelize()
  end
end
