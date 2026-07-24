defmodule MishkaChelekom.Generators.Mob do
  @moduledoc """
  Turns the Mob components in `development/mob` into the `priv/mob` catalog the
  `mix mishka.ui.gen.mob` generators read.

  ## Why a converter and not hand-written templates

  `development/mob` is a real, running Mob application with a showcase and a test
  suite — it is where the components are actually exercised on a device. Keeping
  a second, hand-maintained copy under `priv/mob` would guarantee the two drift.
  So the templates are **derived**, `mix mishka.mob.sync` regenerates them, and
  the tests assert the derivation round-trips: rendered, compiled and called.

  ## What the derivation has to rewrite

  A Mob component differs from a headless one in a way that matters here: headless
  components never reference each other in code (you compose them in HEEx), while
  Mob components do — a close button *calls* an action icon. So the templates need
  the consumer's namespace, which headless templates never do:

  | Source | Template | With `--module-prefix mishka_` |
  |--------|----------|-------------------------------|
  | `defmodule MishkaMob.Components.MishkaChip` | `defmodule <%= @module %>` | `MyApp.Components.MishkaChip` |
  | `alias MishkaMob.Components.MishkaActionIcon` | `alias <%= @namespace %>.<%= @module_prefix_camel %>ActionIcon` | `alias MyApp.Components.MishkaActionIcon` |
  | `alias MishkaMob.Components.Event` | `alias <%= @namespace %>.Event` | (kit modules are never prefixed) |
  | `def action_icon(` | `def <%= @component_prefix %>action_icon(` | `def mishka_action_icon(` |

  The last row is the subtle one: prefixing a component's public function means
  every *sibling's* call to it has to move too, or the generated code compiles
  into a call that does not exist.
  """

  @source_namespace "MishkaMob.Components"

  # Shared support modules. They are not Chelekom components — nobody generates
  # `event` by name — so they are vendored once by `mix mishka.ui.gen.mob.kit`
  # and are never module-prefixed, exactly like the Kit engine's modules.
  @kit_modules ~w(color event)

  @doc "The Mob application's component directory, relative to the library root."
  @spec source_dir() :: String.t()
  def source_dir, do: "development/mob/lib/mishka_mob/components"

  @doc "The kit module basenames (`[\"color\", \"event\"]`)."
  @spec kit_modules() :: [String.t()]
  def kit_modules, do: @kit_modules

  @doc """
  Every `{component_name, path}` in `dir`, excluding the kit modules and any
  nested companion module (see `companions/2`).

  A component is a file named `mishka_<name>.ex` whose module is
  `MishkaMob.Components.Mishka<Name>`; `mishka_toast_queue.ex` is *not* a
  component — it defines `MishkaToast.Queue`, which belongs to `toast`.
  """
  @spec components(String.t()) :: [{String.t(), String.t()}]
  def components(dir \\ source_dir()) do
    dir
    |> Path.join("mishka_*.ex")
    |> Path.wildcard()
    |> Enum.map(&{Path.basename(&1, ".ex") |> String.replace_prefix("mishka_", ""), &1})
    |> Enum.reject(fn {name, path} -> nested_module?(name, path) end)
    |> Enum.sort()
  end

  @doc """
  Files defining a module *nested* under `component`'s module, which have to be
  emitted into the same generated file.

  Only `toast` has one today (`MishkaToast.Queue`), but the rule is structural
  rather than a special case: a generator writes one file per component, so a
  module the component's public API refers to has to travel with it.
  """
  @spec companions(String.t(), String.t()) :: [String.t()]
  def companions(component, dir \\ source_dir()) do
    prefix = "#{@source_namespace}.Mishka#{Macro.camelize(component)}."

    dir
    |> Path.join("mishka_*.ex")
    |> Path.wildcard()
    |> Enum.filter(fn path -> String.contains?(File.read!(path), "defmodule #{prefix}") end)
    |> Enum.sort()
  end

  defp nested_module?(name, path) do
    # `mishka_toast_queue.ex` declares `...MishkaToast.Queue`, so its declared
    # module does not match the name its filename implies.
    expected = "defmodule #{@source_namespace}.Mishka#{Macro.camelize(name)} do"

    not String.contains?(File.read!(path), expected)
  end

  @doc """
  The component's public function name, or `nil` when it has none.

  `accordion` and `drawer` are composite-only — they expose `expand/3` and
  helpers but no render function — so there is nothing for `--component-prefix`
  to prefix, and pretending otherwise would emit a prefix onto a definition that
  does not exist.

      iex> MishkaChelekom.Generators.Mob.public_function("chip", "\\n  def chip(props) do")
      "chip"

      iex> MishkaChelekom.Generators.Mob.public_function("drawer", "\\n  def expand(a, b, c) do")
      nil
  """
  @spec public_function(String.t(), String.t()) :: String.t() | nil
  def public_function(component, source) do
    if String.contains?(source, "\n  def #{component}("), do: component, else: nil
  end

  @doc """
  Sibling components this source depends on, as `{module_suffix, function}` — the
  call sites `--component-prefix` has to move.

  Derived from **alias lines only**, which is the exact signal: every Mob
  component reaches a sibling through an alias, and nothing else does. Scanning
  the whole source instead picks up two things that are not dependencies and
  both bite — a moduledoc that names the component's own module (which makes it
  depend on itself, and the generator recurse forever) and prose like
  "`MishkaSelect`'s behaviour" (which yields a component named `select`'s).

      iex> MishkaChelekom.Generators.Mob.siblings("  alias MishkaMob.Components.MishkaActionIcon")
      [{"ActionIcon", "action_icon"}]

      iex> MishkaChelekom.Generators.Mob.siblings("  alias MishkaMob.Components.{Event, MishkaPill}")
      [{"Pill", "pill"}]

  A doc reference is not a dependency:

      iex> MishkaChelekom.Generators.Mob.siblings("  See `MishkaMob.Components.MishkaChip`.")
      []
  """
  @spec siblings(String.t()) :: [{String.t(), String.t()}]
  def siblings(source) do
    ~r/^\s*alias\s+#{@source_namespace}\.(?:\{([^}]*)\}|(Mishka[A-Z][A-Za-z0-9]*))/m
    |> Regex.scan(source)
    |> Enum.flat_map(fn
      [_, braced, ""] -> String.split(braced, ",")
      [_, braced] -> String.split(braced, ",")
      [_, "", single] -> [single]
    end)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&Regex.match?(~r/\AMishka[A-Z][A-Za-z0-9]*\z/, &1))
    |> Enum.map(&String.replace_prefix(&1, "Mishka", ""))
    |> Enum.uniq()
    |> Enum.map(&{&1, Macro.underscore(&1)})
    |> Enum.sort()
  end

  @doc """
  Kit modules this source needs (`["event"]`, `["color", "event"]`, …).

      iex> MishkaChelekom.Generators.Mob.kit_dependencies("alias MishkaMob.Components.{Color, Event}")
      ["color", "event"]
  """
  @spec kit_dependencies(String.t()) :: [String.t()]
  def kit_dependencies(source) do
    Enum.filter(@kit_modules, fn kit ->
      camel = Macro.camelize(kit)

      String.contains?(source, "#{@source_namespace}.#{camel}") or
        Regex.match?(~r/#{@source_namespace}\.\{[^}]*\b#{camel}\b/, source)
    end)
  end

  @doc """
  Rewrite a component's source into its EEx template.

  `opts` takes `:component` (required) and `:companions` (extra sources appended
  to the same file).
  """
  @spec templatize(String.t(), keyword()) :: String.t()
  def templatize(source, opts) do
    component = Keyword.fetch!(opts, :component)
    companion_sources = Keyword.get(opts, :companions, [])

    body =
      [source | companion_sources]
      |> Enum.map_join("\n", &rewrite(&1, component))
      |> String.trim_trailing()

    body <> "\n"
  end

  @doc """
  Rewrite a kit module (`Color`, `Event`) into its template.

  Kit modules are never module-prefixed and have no component function, so this
  is only the namespace rewrite — kept separate from `templatize/2` so that fact
  is stated rather than falling out of a name that happens not to match.
  """
  @spec templatize_kit(String.t()) :: String.t()
  def templatize_kit(source) do
    source
    |> rewrite_doc_only_references()
    |> rewrite_namespace()
    |> rewrite_bare_modules()
  end

  defp rewrite(source, component) do
    siblings = siblings(source)

    source
    |> rewrite_doc_only_references()
    |> rewrite_defmodule(component)
    |> rewrite_namespace()
    |> rewrite_bare_modules()
    |> rewrite_own_function(component, public_function(component, source))
    |> rewrite_sibling_calls(siblings)
  end

  # `MishkaMob.App` is this repo's demo application, which a consumer does not
  # have. It only ever appears in prose, so it becomes prose.
  defp rewrite_doc_only_references(source) do
    String.replace(source, "`MishkaMob.App.on_start/0`", "your app's `on_start/0`")
  end

  # Done before the generic namespace pass so the component's own defmodule
  # picks up `@module` (which carries any custom `--module`) rather than being
  # rebuilt from the namespace.
  defp rewrite_defmodule(source, component) do
    String.replace(
      source,
      "defmodule #{@source_namespace}.Mishka#{Macro.camelize(component)} do",
      "defmodule <%= @module %> do"
    )
  end

  defp rewrite_namespace(source) do
    source
    |> String.replace(
      "#{@source_namespace}.Mishka",
      "<%= @namespace %>.<%= @module_prefix_camel %>"
    )
    |> String.replace("#{@source_namespace}.", "<%= @namespace %>.")
  end

  # Alias-local names (`MishkaActionIcon.action_icon(...)`) and any remaining
  # bare reference. `MishkaMob` is already gone by here.
  #
  # The lookbehind protects `<MishkaCloseButton />` in the docs: that is a
  # **composite tag**, not a module. Tags stay `mishka_*` whatever the module
  # prefix, because the tag is the markup API and the catalog registers it by
  # that name — rewriting it would document a tag the app never registers.
  defp rewrite_bare_modules(source) do
    String.replace(
      source,
      ~r/(?<![<\w])Mishka([A-Z][A-Za-z0-9]*)/,
      "<%= @module_prefix_camel %>\\1"
    )
  end

  defp rewrite_own_function(source, _component, nil), do: source

  defp rewrite_own_function(source, _component, function) do
    # Every occurrence, not just the definition: `def close_button`, its `@spec`,
    # the `do: close_button(...)` in expand/3 and the examples in @doc all name
    # the same function, and a prefix that moves the definition but not the
    # self-call generates a module that does not compile.
    String.replace(
      source,
      ~r/(?<![\w.:])#{function}\(/,
      "<%= @component_prefix %>#{function}("
    )
  end

  # The half that is easy to forget: prefixing a public function also moves
  # every sibling's call to it.
  defp rewrite_sibling_calls(source, siblings) do
    Enum.reduce(siblings, source, fn {_suffix, function}, acc ->
      String.replace(acc, ".#{function}(", ".<%= @component_prefix %>#{function}(")
    end)
  end

  @doc """
  Build the `.exs` catalog for a component.

  `category` and `doc_url` are lifted from the matching headless catalog when one
  exists, so the two layers cannot describe the same component differently.
  """
  @spec catalog(String.t(), keyword()) :: String.t()
  def catalog(component, opts) do
    necessary = Keyword.get(opts, :necessary, [])
    kit = Keyword.get(opts, :kit, [])
    function = Keyword.get(opts, :function)
    {category, doc_url} = headless_metadata(component)

    """
    [
      #{component}: [
        name: "#{component}",
        category: "#{category}",
        doc_url: "#{doc_url}",
        args: [type: ["#{component}"], only: ["#{component}"], helpers: [], module: ""],
        optional: [],
        necessary: #{inspect(necessary)},
        scripts: [],
        mob: [
          composite_tag: "mishka_#{component}",
          function: #{inspect(function)},
          kit: #{inspect(kit)}
        ]
      ]
    ]
    """
  end

  defp headless_metadata(component) do
    path = Path.join([File.cwd!(), "priv", "headless", "#{component}.exs"])

    with true <- File.exists?(path),
         config when is_list(config) <- Config.Reader.read!(path)[String.to_atom(component)] do
      {Keyword.get(config, :category, "mob"),
       Keyword.get(config, :doc_url, "https://mishka.tools/chelekom/docs/headless/#{component}")}
    else
      _ -> {"mob", "https://mishka.tools/chelekom/docs/headless/#{component}"}
    end
  end

  @doc """
  The EEx assigns a Mob template is rendered with.

    * `:module` — this component's module
    * `:namespace` — where the generated components live (`MyApp.Components`)
    * `:module_prefix_camel` — `""` or e.g. `"Mishka"`
    * `:component_prefix` — `""` or e.g. `"mishka_"`

  `component_prefix` is normalised to `""` rather than left `nil`, because a nil
  interpolates as empty in EEx but raises the moment anything calls a String
  function on it.
  """
  @spec eex_assigns(module(), module(), keyword()) :: keyword()
  def eex_assigns(module, namespace, opts \\ []) do
    [
      module: module,
      namespace: namespace,
      module_prefix_camel: opts[:module_prefix_camel] || "",
      component_prefix: opts[:component_prefix] || ""
    ]
  end
end
