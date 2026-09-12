defmodule Mix.Tasks.Mishka.Ui.Gen.Mob do
  use Igniter.Mix.Task

  alias MishkaChelekom.Config
  alias MishkaChelekom.Generators.{Core, Mob}
  alias MishkaChelekom.Generators.Mob.{Locations, Registry}

  @example "mix mishka.ui.gen.mob drawer"
  @shortdoc "Generate a native Mob component for a BEAM-on-device app"
  @moduledoc """
  #{@shortdoc}

  Mob components are **native**: they build a node tree of platform widgets
  (`Box`, `Row`, `Text`, `Slider`, `Canvas`, …) that Compose and SwiftUI render
  directly. There is no HTML, no JS engine and no CSS, so unlike
  `mix mishka.ui.gen.headless` this task installs no npm packages and touches no
  stylesheet.

  Output goes to `lib/<app>/components/<name>.ex` (module
  `<App>.Components.<Name>`) — a Mob app is a plain OTP application with no
  `_web` namespace.

  ## What it does that the headless generator does not

  Headless components never reference each other in code; you compose them in
  HEEx. Mob components *do* — a close button calls an action icon — so two extra
  things happen here:

    * **`necessary:` does real work.** ~20 components depend on a sibling, and
      the task generates them too. It does not ask: the dependency is a compile
      -time one — an alias and a call — so declining it would leave a module
      that cannot compile.
    * **the composite registry is maintained** in `lib/<app>/components.ex`, so
      `<Drawer>` works in `~MOB` markup. The tag follows `--module-prefix` like
      every other generated name — no prefix gives `:drawer`, `--module-prefix
      acme_` gives `:acme_drawer` and `<AcmeDrawer>`. Registration is idempotent:
      the registry is rebuilt from the components present, not appended to.

  Note that `Mob.Composite`'s table is global, so an unprefixed `:drawer` can
  collide with a composite the app already registered under that name. That is
  what `--module-prefix` is for.

  ## Writing components as tags

  Registering a composite makes `<Drawer>` *render*. It does not make it compile
  quietly: `~MOB` validates tag names against a whitelist baked into Mob, and a
  runtime registration is invisible to a compile-time check, so the sigil warns
  that the tag is unknown. Mob documents that as expected — but on
  `--warnings-as-errors` an expected warning is indistinguishable from a real
  one, and the tag form becomes unusable.

  So generating a component also adds its tag to that whitelist and recompiles
  `:mob`, which is what lets you write

      <AcmeDrawer open={@open} />

  instead of `{drawer(open: @open)}`. The tags come from the registry above
  rather than from filenames, so `--module-prefix` is carried through. The
  change is a fenced block in `deps/mob/priv/tags/`, shown in the diff like any
  other; `mix deps.get` discards it and re-running the generator restores it.

  Pass `--no-tags` to leave Mob's whitelist alone and call the functions.

  The shared `Event`/`Color` modules are vendored automatically when a component
  needs them (see `mix mishka.ui.gen.mob.kit`).

  ## Example

  ```bash
  #{@example}
  mix mishka.ui.gen.mob color_picker --module-prefix mishka_
  ```

  ## Options

  * `--module` or `-m` - Custom module name for the component
  * `--component-prefix` - Prefix for the public function name
  * `--module-prefix` - Prefix for the module name
  * `--sub` - Marks this as a dependency sub-generation
  * `--no-save` - Use prefixes without saving them to config
  * `--no-register` - Do not touch the composite-tag registry
  * `--no-tags` - Do not add the tags to Mob's `~MOB` whitelist
  * `--no-kit` - Do not vendor the shared support modules
  * `--yes` - Apply without prompts
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      example: @example,
      positional: [:component],
      group: :mishka_chelekom,
      # NOT "mishka.ui.gen.mob". This task does compose itself at run time, for
      # `necessary:` siblings — but `composes:` is not a record of that. It is
      # the list Igniter merges OPTION SCHEMAS from, and a task's own schema is
      # already the one being merged into.
      #
      # `Igniter.Util.Info.recursively_compose_schema/4` walks the list with no
      # visited set, so naming yourself here is unbounded recursion: it never
      # returns, and because each level merges a keyword list that is one entry
      # longer than the last, the process sits at ~90% CPU in binary and list
      # building with no output at all. That is what #78 reported as "hangs" —
      # 23 minutes, zero output, no component written.
      composes: ["mishka.ui.gen.mob.kit"],
      schema: [
        module: :string,
        component_prefix: :string,
        module_prefix: :string,
        sub: :boolean,
        no_save: :boolean,
        no_register: :boolean,
        no_kit: :boolean,
        no_tags: :boolean
      ],
      aliases: [m: :module]
    }
  end

  def supports_umbrella?(), do: false

  def igniter(igniter) do
    # Owl's widget supervisor is not running under a bare `mix` invocation, so
    # Owl.Spinner.start/1 exits with :noproc. Every Owl-using task in this repo
    # starts it first; the tests never caught it because their setup does.
    Application.ensure_all_started(:owl)
    %Igniter.Mix.Task.Args{positional: %{component: component}, options: options} = igniter.args

    print_banner(options)

    tty? = IO.ANSI.enabled?()
    spin? = !options[:sub] and Mix.env() != :test and tty?
    if spin?, do: Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    final =
      igniter
      |> Igniter.assign(:mishka_user_config, Config.load_user_config(igniter))
      |> Registry.check_dependency()
      |> Locations.assign_namespace()
      |> resolve_template(component)
      |> compute_location()
      |> build_eex_assigns()
      |> write_component()
      |> vendor_kit()
      |> generate_necessary()
      |> register_composites()
      |> wire_boot()
      |> whitelist_tags()
      |> maybe_save_prefixes()

    if spin? do
      if Map.get(final, :issues, []) == [],
        do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
        else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")
    end

    final
  end

  defp print_banner(options) do
    if !options[:sub] and Mix.env() != :test, do: Core.banner(IO.ANSI.magenta(), "Mob")
    :ok
  end

  defp resolve_template(igniter, component) do
    case Core.fetch_catalog(igniter, component, :mob) do
      {:ok, template} ->
        igniter
        |> Igniter.assign(:component_name, template.component)
        |> Igniter.assign(:template_path, template.path)
        |> Igniter.assign(:template_config, template.config)

      {:error, {:not_found, _path}} ->
        Igniter.add_issue(
          igniter,
          "Mob component #{inspect(component)} not found in priv/mob/. Available: " <>
            Enum.join(Core.all_component_names(igniter, :mob), ", ")
        )

      {:error, {:bad_catalog, reason, _config_path}} ->
        Igniter.add_issue(igniter, "Invalid Mob catalog for #{component}: #{reason}")
    end
  end

  defp compute_location(%{assigns: %{component_name: component}} = igniter) do
    options = igniter.args.options

    module_prefix =
      Locations.normalize_prefix(
        options[:module_prefix] || get_in(igniter.assigns, [:mishka_user_config, :module_prefix])
      )

    {name_part, module} =
      Locations.resolve(igniter, component,
        module_prefix: module_prefix,
        module: options[:module]
      )

    location = Locations.component_path(igniter, name_part)

    igniter
    |> Core.track_generated_file(location)
    |> Igniter.assign(:module_prefix, module_prefix)
    |> Igniter.assign(:component_module, module)
    |> Igniter.assign(:proper_location, location)
    |> record_registration(component, module)
  end

  defp compute_location(igniter), do: igniter

  # The registry cannot recover a custom --module from a filename, and guessing
  # from the prefix breaks as soon as one run uses a different one. So each run
  # records the pairing it actually created.
  defp record_registration(igniter, component, module) do
    Igniter.update_assign(igniter, :mob_registered, [{component, module}], fn existing ->
      Enum.uniq([{component, module} | existing])
    end)
  end

  defp build_eex_assigns(%{assigns: %{component_module: module}} = igniter) do
    options = igniter.args.options

    component_prefix =
      options[:component_prefix] ||
        get_in(igniter.assigns, [:mishka_user_config, :component_prefix]) || ""

    assigns =
      Mob.eex_assigns(module, igniter.assigns.mob_namespace,
        component_prefix: component_prefix,
        module_prefix_camel: camelize_prefix(igniter.assigns.module_prefix)
      )

    Igniter.assign(igniter, :eex_assigns, assigns)
  end

  defp build_eex_assigns(igniter), do: igniter

  # The prefix is normalised to end in "_" by Locations.normalize_prefix/1, so
  # trimming it here yields exactly the camel case the file name will produce.
  defp camelize_prefix(prefix) when is_binary(prefix) and prefix != "",
    do: prefix |> String.trim_trailing("_") |> Macro.camelize()

  defp camelize_prefix(_), do: ""

  defp write_component(%{assigns: %{eex_assigns: assigns}} = igniter) do
    Igniter.copy_template(
      igniter,
      igniter.assigns.template_path,
      igniter.assigns.proper_location,
      assigns,
      on_exists: :overwrite
    )
  end

  defp write_component(igniter), do: igniter

  # The kit is not optional in practice: 41 of the 72 components alias `Event`.
  # Composing the task rather than duplicating the copy keeps one definition of
  # where those modules live.
  defp vendor_kit(%{assigns: %{template_config: config}} = igniter) do
    kit = get_in(config, [:mob, :kit]) || []

    if igniter.args.options[:no_kit] || kit == [] do
      igniter
    else
      args =
        ["--only", Enum.join(kit, ","), "--sub", "--yes"]
        |> Core.append_arg("--module-prefix", igniter.assigns.module_prefix)

      Igniter.compose_task(igniter, "mishka.ui.gen.mob.kit", args)
    end
  end

  defp vendor_kit(igniter), do: igniter

  # A sibling that is missing does not fail loudly at generation time — it fails
  # at compile time in the consumer's app, with an error about a module they
  # never asked for. So they are generated with the same prefixes.
  defp generate_necessary(%{assigns: %{template_config: config}} = igniter) do
    necessary = Keyword.get(config, :necessary, [])

    Enum.reduce(necessary, igniter, fn sibling, acc ->
      if already_generated?(acc, sibling) do
        acc
      else
        Igniter.compose_task(acc, "mishka.ui.gen.mob", [sibling | inherited_flags(acc)])
      end
    end)
  end

  defp generate_necessary(igniter), do: igniter

  defp already_generated?(igniter, sibling) do
    name_part =
      case igniter.assigns.module_prefix do
        "" -> sibling
        prefix -> "#{prefix}#{sibling}"
      end

    path = Locations.component_path(igniter, name_part)

    Map.has_key?(igniter.rewrite.sources, path) or File.exists?(path)
  end

  defp inherited_flags(igniter) do
    options = igniter.args.options

    ["--sub", "--yes", "--no-register"]
    |> Core.append_arg("--module-prefix", igniter.assigns.module_prefix)
    |> Core.append_arg("--component-prefix", options[:component_prefix])
  end

  # Rebuilt from what is on disk rather than appended to, so re-running a
  # generator cannot register the same tag twice or leave a stale one behind.
  defp register_composites(%{assigns: %{proper_location: _}} = igniter) do
    if igniter.args.options[:no_register] do
      igniter
    else
      Registry.write(igniter)
    end
  end

  defp register_composites(igniter), do: igniter

  # A registry nothing calls registers nothing, and an unregistered tag renders
  # nothing rather than failing — so the call is wired in, not documented.
  defp wire_boot(%{assigns: %{proper_location: _}} = igniter) do
    if igniter.args.options[:no_register], do: igniter, else: Registry.wire_boot(igniter)
  end

  defp wire_boot(igniter), do: igniter

  # Registering a composite makes `<Drawer>` render; whitelisting it is what
  # makes it compile without a warning. Both are decided by the same list, and
  # both happen here — the generator already knows the tags, so needing a second
  # command afterwards to finish the job would just be a step to forget.
  defp whitelist_tags(%{assigns: %{proper_location: _}} = igniter) do
    if igniter.args.options[:no_tags], do: igniter, else: Registry.whitelist(igniter)
  end

  defp whitelist_tags(igniter), do: igniter

  defp maybe_save_prefixes(%{assigns: %{eex_assigns: _}} = igniter),
    do: Core.maybe_save_prefixes(igniter, igniter.args.options)

  defp maybe_save_prefixes(igniter), do: igniter
end
