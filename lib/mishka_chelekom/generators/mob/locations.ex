defmodule MishkaChelekom.Generators.Mob.Locations do
  @moduledoc """
  Where a generated Mob component lands, and under what module.

  A Mob application is a plain OTP application — there is no `_web` namespace and
  no Phoenix endpoint — so none of the headless generator's location logic
  applies. Components go under `lib/<app>/components/`, in `<App>.Components`.

  All three Mob tasks pipe through `assign_namespace/1` first, so the namespace
  is computed once and read from `igniter.assigns.mob_namespace` afterwards.
  """

  alias Igniter.Project.Application, as: IAPP
  alias MishkaChelekom.Generators.Core

  @doc """
  Assigns `:mob_namespace` — the module every generated component lives under.

  `MyApp.Components` for an app named `:my_app`.

  Built with `Core.module_atom/1` rather than `Module.concat/1`, and that is not
  cosmetic: `Module.concat` yields `:"Elixir.MyApp.Components"`, whose
  `to_string/1` keeps the `Elixir.` prefix, so a template interpolating it emits
  `defmodule Elixir.MyApp.Components.Chip` — valid Elixir that reads as a bug in
  every generated file.
  """
  @spec assign_namespace(Igniter.t()) :: Igniter.t()
  def assign_namespace(igniter) do
    Igniter.assign(
      igniter,
      :mob_namespace,
      Core.module_atom("#{IAPP.app_name(igniter)}.components")
    )
  end

  @doc "The app's base module, e.g. `MyApp`."
  @spec base_module(Igniter.t()) :: atom()
  def base_module(igniter), do: Core.module_atom("#{IAPP.app_name(igniter)}")

  @doc "Directory holding the generated components, e.g. `lib/my_app/components`."
  @spec components_dir(Igniter.t()) :: String.t()
  def components_dir(igniter), do: "lib/#{IAPP.app_name(igniter)}/components"

  @doc "Path for a component file, given the (possibly prefixed) file basename."
  @spec component_path(Igniter.t(), String.t()) :: String.t()
  def component_path(igniter, name_part), do: "#{components_dir(igniter)}/#{name_part}.ex"

  @doc "Path for a vendored kit module."
  @spec kit_path(Igniter.t(), String.t()) :: String.t()
  def kit_path(igniter, kit), do: "#{components_dir(igniter)}/#{kit}.ex"

  @doc """
  Path for the composite-tag registry, `lib/<app>/components.ex`.

  It sits beside the components directory rather than inside it, so a wildcard
  over the directory never picks the registry up as a component.
  """
  @spec registry_path(Igniter.t()) :: String.t()
  def registry_path(igniter), do: "lib/#{IAPP.app_name(igniter)}/components.ex"

  @doc """
  The file basename and module for a component, honouring `--module-prefix` and
  an explicit `--module`.

  Returns `{name_part, module}`.
  """
  @spec resolve(Igniter.t(), String.t(), keyword()) :: {String.t(), module()}
  def resolve(igniter, component, opts) do
    module_prefix = opts[:module_prefix] || ""
    name_part = if module_prefix == "", do: component, else: "#{module_prefix}#{component}"

    module =
      case opts[:module] do
        nil -> Core.module_atom("#{igniter.assigns.mob_namespace}.#{name_part}")
        custom -> Core.module_atom(custom)
      end

    {name_part, module}
  end
end
