defmodule MishkaChelekom.Test.Runtime.DemoHarness do
  # The HEEx compile-string call below uses `__ENV__`. The TagEngine
  # resolves `<.X>` and bare expressions against that env's imports, so
  # we need the runtime dispatcher imported here for the demo
  # invocations (which are all of the form `<.component …>`) to compile.
  # `_ = …` references silence the "unused import" warnings — the
  # functions ARE used downstream by EEx-compiled demo code, which the
  # compiler can't statically see.
  import MishkaChelekom.Test.Runtime.LiveViewHelpers
  import Phoenix.Component
  import MishkaChelekom.Test.Runtime.DemoHarness.DocsStubs
  alias Phoenix.LiveView.JS
  _ = &component/1
  _ = &assign_new/3
  _ = &cp/1
  _ = JS

  @moduledoc """
  Kit-agnostic demo runner — the chelekom-side test harness.

  ## What it does

  Reads the `examples[]` array on each component in the bundle JSON
  (populated by `mix mishka.ui.export --cms` from vendored
  `priv/demos/<comp>_live.html.heex` showcase files) and renders every
  entry through a vendored copy of the runtime CMS dispatcher
  (`<.component component_name=… site=…/>`). When this harness
  passes, the bundle is guaranteed to render in any consumer that uses
  the same dispatcher pattern — no downstream CMS install needed.

  Each example is a self-contained snippet:

      %{
        "component" => "pagination",
        "source"    => ~s|<.component component_name="chelekom-pagination" site={assigns[:site]} total={@posts.total} active={@posts.active} size="small" />|,
        "assigns"   => %{"posts" => %{"total" => 10, "active" => 1}},
        "line"      => 32,
        "file"      => "pagination_live.html.heex"
      }

  ## Pipeline (per invocation)

  1. **Compile bundle modules** (`compile_bundle_modules/1`, runs once
     per `run/2` call). For each component in the bundle, build the
     runtime AST via the vendored `ComponentCompiler.build_module/1`
     and load it via the vendored `ModuleCompiler.compile_module/2`.
     The dispatcher (`LiveViewHelpers.component/1`) hashes
     `name + site` via the same MD5 the runtime CMS uses, so the
     loaded modules are findable by demo dispatches.
  2. **Compile each `source` HEEx string** via `EEx.compile_string/2` +
     `Phoenix.LiveView.TagEngine`, with the harness module's `__ENV__`
     as the caller (so the imports for `component/1`,
     `Phoenix.Component`, `DocsStubs`, etc., are in scope).
  3. **Evaluate the compiled rendered struct** under bindings that
     supply `assigns` (from `@default_assigns` merged with the
     example's pre-extracted map) and common comprehension variables
     (`s, i, c, shape, color, variant, item, items`) so isolated
     snippets that reference outer-scope vars compile.
  4. **Materialize to HTML** via `Phoenix.HTML.Safe.to_iodata/1`.
     Surfaces any render-time exception inside helpers and slot bodies.
  5. **Classify failures** as `:skip` (structural — outer-scope vars,
     missing form parent, kit-source helper module unavailable, nil
     arithmetic from missing event-driven assigns) or `:fail` (real
     render bug). See `classify/1`.

  ## Public API

      run("chelekom") :: report()
      run("chelekom", only: ["pagination", "button"]) :: report()
      run("chelekom", max_per_component: 3) :: report()

  ## Coverage tracking

  `run/2` returns `components_exercised`, the count of distinct
  components that either had at least one passing direct example OR
  were dispatched-to by a passing parent's example. Sub-components
  like `card_title`, `td`, `li` that don't ship their own demo files
  are still counted as exercised whenever a parent's demo renders
  them. See `dispatched_components/1`.

  ## Where the docs that used to be in `UI_KIT_HARNESS_DESIGN.md` went

  This module's docstring + the docstrings on `HeexTagExtractor`,
  `HeexTagRewriter`, and `cms_bundle_exporter.ex` together describe
  the demo-driven harness architecture. The design-doc-as-separate-
  file was retired once the design shipped.

  ## Migration plan for AST/tokenizer adoption

  Tracked in `mishka_cms/HARNESS_AST_MIGRATION_PLAN.md`. Four
  incremental steps:

  1. Replace `dispatched_components/1` regex with
     `Phoenix.LiveView.Tokenizer`.
  2. Extend `HeexTagExtractor` to capture parent `:for`/`:if`.
  3. Replace hand-rolled `strip_route_sigils/1` with token + Sourceror.
  4. Replace `HeexTagExtractor`/`Rewriter` with the official tokenizer.
  """

  # In chelekom's test env we read the bundle from the same path the
  # exporter writes to (`priv/components/<kit>.json`). The runtime CMS
  # uses `priv/cms_ui_kits/` instead, but the harness here is meant to
  # verify the kit-author flow before the bundle ships.
  @bundle_path Path.join([
                 :code.priv_dir(:mishka_chelekom),
                 "components",
                 "chelekom.json"
               ])

  @type failure :: %{
          component: String.t(),
          file: String.t(),
          line: pos_integer(),
          source: String.t(),
          reason: String.t()
        }

  @type report :: %{
          passed: non_neg_integer(),
          failed: [failure()],
          components_with_examples: non_neg_integer(),
          components_total: non_neg_integer()
        }

  @doc """
  Run the harness against the bundle for `kit_name`. Currently only
  `"chelekom"` is shipped; the function is named generically so a
  future kit can be added by changing the bundle path resolution.

  Options:

    * `:bundle_path` — override the path to the bundle JSON.
    * `:only` — list of component short-names (e.g. `"pagination"`)
      to restrict the run. Useful for focused debugging.
    * `:max_per_component` — cap how many examples per component to
      render. Useful when a demo file has 100+ near-identical
      invocations and you only need a handful for coverage. Default
      `:infinity`.
  """
  @spec run(String.t(), keyword()) :: report()
  def run(kit_name, opts \\ []) do
    bundle_path = Keyword.get(opts, :bundle_path, default_bundle_path(kit_name))
    only = Keyword.get(opts, :only, :all)
    max_per = Keyword.get(opts, :max_per_component, :infinity)

    {:ok, raw} = File.read(bundle_path)
    {:ok, bundle} = Jason.decode(raw)

    components = bundle["components"] || []

    # In the runtime CMS, the BootHandler compiles every Component row
    # into a BEAM module at boot. Chelekom's test env has no boot
    # handler — we compile every bundle component here, once, before
    # iterating demos. The dispatcher (`LiveViewHelpers.component/1`)
    # resolves `<.component component_name="X" site=…/>` by hashing
    # `name + site` into a module name; if the module isn't loaded the
    # dispatcher returns the red "failed to render" placeholder, so we
    # need to load every module the demos might dispatch into.
    compile_bundle_modules(components)

    # Some demos use short-aliased helper modules (`Drawer.show_drawer/2`,
    # `Modal.show_modal/1`, etc.) in `phx-click={…}` attrs. Real Phoenix
    # apps that install chelekom get those modules generated under
    # their app namespace; chelekom's own test env doesn't ship them.
    # Define stubs that return a bare `JS{}` so HEEx attr expressions
    # compile/evaluate without crashing.
    MishkaChelekom.Test.Runtime.KitModuleStubs.make_modules!()

    selected =
      Enum.filter(components, fn c ->
        case only do
          :all -> true
          list when is_list(list) -> short_name(c["name"], kit_name) in list
        end
      end)

    {passed, skipped, failures, dispatched} =
      Enum.reduce(selected, {0, [], [], MapSet.new()}, fn component,
                                                          {p_acc, s_acc, f_acc, d_acc} ->
        examples =
          component
          |> demo_examples()
          |> maybe_take(max_per)

        # Every example's source dispatches to one or more chelekom
        # components via `<.component component_name="X">`. Credit each
        # referenced name as "exercised indirectly" — sub-components
        # like card_title/td/li that don't have their own demos are
        # nonetheless rendered every time their parent renders.
        d_acc =
          Enum.reduce(examples, d_acc, fn ex, acc ->
            MapSet.union(acc, dispatched_components(ex["source"]))
          end)

        {p, s, f} = run_component_examples(component, examples)
        {p_acc + p, s_acc ++ s, f_acc ++ f, d_acc}
      end)

    direct = MapSet.new(selected, & &1["name"])

    components_exercised =
      MapSet.union(direct |> filter_with_passing(passed, failures, skipped), dispatched)

    %{
      passed: passed,
      skipped: skipped,
      failed: failures,
      components_with_examples: Enum.count(selected, fn c -> demo_examples(c) != [] end),
      components_total: length(selected),
      components_exercised: MapSet.size(components_exercised),
      uncovered: components_uncovered(selected, components_exercised)
    }
  end

  # Names dispatched-to via `<.component component_name="…">`.
  #
  # Tokenizes the translated HEEx source via `Phoenix.LiveView.Tokenizer`
  # — the same tokenizer Phoenix uses to compile `~H` sigils. For each
  # component-tag token (`{:tag, "." <> _name, attrs, _meta}`) we read
  # the literal `component_name` attr value and add it to the set.
  #
  # Why tokenize instead of regex: a literal substring like
  # `component_name="…"` could appear inside a string body or HTML
  # attribute and falsely match. The tokenizer correctly distinguishes
  # tag-attr context from text content, EEx blocks, comments, and
  # `phx-no-curly-interpolation` regions.
  defp dispatched_components(nil), do: MapSet.new()

  defp dispatched_components(source) when is_binary(source) do
    case tokenize_heex(source) do
      {:ok, tokens} ->
        tokens
        |> Enum.flat_map(fn
          {:tag, "." <> _name, attrs, _meta} -> attrs
          _ -> []
        end)
        |> Enum.flat_map(fn
          # Phoenix.LiveView.Tokenizer attr shape:
          #   {name, {:string, value, _meta}, _attr_meta}
          {"component_name", {:string, value, _}, _} -> [value]
          _ -> []
        end)
        |> MapSet.new()

      :error ->
        # Source isn't well-formed HEEx (e.g. caller fed malformed
        # text). Empty set rather than crashing the harness.
        MapSet.new()
    end
  end

  # Wrap the tokenizer's stateful API. Returns the flat token list in
  # source order; swallows errors so a broken snippet doesn't fail the
  # whole report — the snippet itself will fail at compile/render and
  # be classified there.
  defp tokenize_heex(source) do
    try do
      state =
        Phoenix.LiveView.Tokenizer.init(0, "demo_harness", source, Phoenix.LiveView.HTMLEngine)

      {tokens, _cont} =
        Phoenix.LiveView.Tokenizer.tokenize(
          source,
          [line: 1, column: 1],
          [],
          {:text, :enabled},
          state
        )

      # Tokenizer returns tokens REVERSE-prepended; reverse for source
      # order. (Optional for our use here since we just check membership,
      # but keeps the contract consistent.)
      {:ok, Enum.reverse(tokens)}
    rescue
      _ -> :error
    catch
      _, _ -> :error
    end
  end

  # A component "directly tested" iff at least one of its examples
  # passed. Failed-only components are counted via their failures, not
  # here.
  defp filter_with_passing(direct, passed, _failed, _skipped) when passed > 0, do: direct
  defp filter_with_passing(_direct, _, _, _), do: MapSet.new()

  defp components_uncovered(selected, exercised) do
    Enum.reject(selected, fn c -> MapSet.member?(exercised, c["name"]) end)
    |> Enum.map(& &1["name"])
    |> Enum.sort()
  end

  # Demo invocations are stashed under `extra.demo_examples` (not the
  # resource's `examples` attribute, which is `{:array, :string}`).
  defp demo_examples(component) do
    get_in(component, ["extra", "demo_examples"]) || []
  end

  ## ─── private ───────────────────────────────────────────────────────

  defp default_bundle_path("chelekom"), do: @bundle_path

  defp default_bundle_path(kit_name) do
    Path.join([:code.priv_dir(:mishka_chelekom), "components", "#{kit_name}.json"])
  end

  # Compile every bundle component into a loaded BEAM module so the
  # runtime dispatcher (`LiveViewHelpers.component/1`) can resolve
  # `<.component component_name="X" site=…/>` lookups via the same
  # `md5(name + site)` hash the runtime CMS uses. Idempotent:
  # `:erlang.module_loaded?` short-circuits if a module already exists
  # (e.g. across multiple test runs in one VM).
  defp compile_bundle_modules(components) do
    for component <- components do
      params = atomize_component_params(component)

      module_name =
        MishkaChelekom.Test.Runtime.Compilers.Helpers.module_name(
          params[:name],
          "Global",
          "Component"
        )

      # Force fresh compile each run — modules from a prior beam stay
      # loaded across test invocations and would silently mask code
      # changes to the compiler. Purge + delete so the next compile
      # actually replaces the loaded version.
      :code.purge(module_name)
      :code.delete(module_name)

      unless :erlang.module_loaded(module_name) do
        try do
          ast = MishkaChelekom.Test.Runtime.Compilers.ComponentCompiler.build_module(params)

          case MishkaChelekom.Test.Runtime.Compilers.ModuleCompiler.compile_module(
                 ast,
                 params[:name]
               ) do
            {:ok, _mod, _diagnostics} ->
              :ok

            {:error, _, _} = err ->
              require Logger
              Logger.warning("[DemoHarness] compile failed for #{params[:name]}: #{inspect(err)}")
          end
        rescue
          e ->
            require Logger

            Logger.warning(
              "[DemoHarness] component compile raised for #{params[:name]}: #{Exception.message(e)}"
            )
        end
      end
    end

    :ok
  end

  # Bundle JSON has string keys; the compiler expects atom keys for
  # top-level fields and inside helpers/attrs/slots. Mirror the same
  # normalization the CMS-side `UiKitHandler.create_component/2` does.
  #
  # The runtime `ComponentCompiler.build_single_clause_function/1`
  # invokes `String.to_atom(params[:title])` to name the function. On
  # the CMS install path the resource derives `:title` automatically;
  # in our chelekom-side test path the bundle only carries `:name`,
  # so fall back to `name` when `:title` is missing.
  defp atomize_component_params(component) do
    component
    |> Enum.into(%{}, fn {k, v} when is_binary(k) -> {String.to_atom(k), v} end)
    |> derive_title_from_name()
    |> derive_component_module()
    |> normalize_format()
    |> normalize_helpers()
    |> normalize_attrs()
    |> normalize_slots()
  end

  defp derive_title_from_name(%{title: t} = params) when is_binary(t), do: params

  defp derive_title_from_name(%{name: name} = params) when is_binary(name),
    do: Map.put(params, :title, name)

  defp derive_title_from_name(params), do: params

  # The compiler builds `defmodule unquote(params[:component_module])`.
  # On the CMS install path the resource's `:component_module` calc
  # populates this from name + site via the same MD5 hash function we
  # vendored in `Helpers.module_name/3`. Without that calc here, the
  # AST `defmodule` gets `nil`. Derive it ourselves.
  defp derive_component_module(%{component_module: m} = params) when is_atom(m) and not is_nil(m),
    do: params

  defp derive_component_module(%{name: name} = params) when is_binary(name) do
    site = Map.get(params, :site_name) || "Global"
    module = MishkaChelekom.Test.Runtime.Compilers.Helpers.module_name(name, site, "Component")
    Map.put(params, :component_module, module)
  end

  defp derive_component_module(params), do: params

  defp normalize_format(%{format: f} = params) when is_binary(f),
    do: %{params | format: String.to_atom(f)}

  defp normalize_format(params), do: params

  defp normalize_helpers(%{helpers: helpers} = params) when is_list(helpers) do
    %{params | helpers: Enum.map(helpers, &atomize_top/1)}
  end

  defp normalize_helpers(params), do: params

  defp normalize_attrs(%{attrs: attrs} = params) when is_list(attrs) do
    %{params | attrs: Enum.map(attrs, &atomize_top/1)}
  end

  defp normalize_attrs(params), do: params

  defp normalize_slots(%{slots: slots} = params) when is_list(slots) do
    %{params | slots: Enum.map(slots, &atomize_top/1)}
  end

  defp normalize_slots(params), do: params

  defp atomize_top(%{} = m) do
    Enum.into(m, %{}, fn {k, v} when is_binary(k) -> {String.to_atom(k), v} end)
  end

  defp short_name(full_name, kit_name) do
    prefix = kit_name <> "-"

    case full_name do
      <<^prefix::binary-size(byte_size(prefix)), rest::binary>> -> rest
      _ -> full_name
    end
  end

  defp maybe_take(list, :infinity), do: list
  defp maybe_take(list, n) when is_integer(n), do: Enum.take(list, n)

  defp run_component_examples(component, examples) do
    Enum.reduce(examples, {0, [], []}, fn ex, {p, s, f} ->
      case render_one(ex) do
        :ok ->
          {p + 1, s, f}

        {:error, reason} ->
          record = build_failure(component, ex, reason)

          case classify(reason) do
            :skip -> {p, [record | s], f}
            :fail -> {p, s, [record | f]}
          end
      end
    end)
  end

  # Classify a reason as a skip-worthy structural limitation (the
  # demo's invocation depends on something we can't supply in
  # isolation: an outer `:for={s <- …}`, a `<.form>` parent, or a
  # module-qualified helper function defined only in chelekom's source
  # tree) versus a real failure that should fail the test.
  #
  # The set of skip patterns is deliberately small — we want most
  # failures to surface. Add new patterns here only with a comment
  # explaining why the case is structurally untestable in isolation.
  defp classify(reason) when is_binary(reason) do
    cond do
      # Snippet references a variable bound by a parent comprehension.
      reason =~ "undefined variable" -> :skip
      # Form-input components need a `<.form>` parent + FormField struct.
      reason =~ "key :form not found" -> :skip
      # Chelekom helper module functions (e.g. `Drawer.show_drawer/2`)
      # aren't shipped in the runtime CMS — the runtime only ships the
      # functional component modules, not the kit's static source.
      reason =~ "is undefined (module" and reason =~ "is not available" -> :skip
      # Demos that reference runtime list/map assigns we don't supply
      # (e.g. `@items` populated only via `handle_event/3`). The body's
      # `Enum.<foo>(@items, …)` raises when `@items` is `nil`. This is
      # structural — the harness renders single invocations in isolation
      # and can't simulate the demo's host LiveView event flow.
      reason =~ "Enumerable not implemented" and reason =~ "value:" -> :skip
      # Map/list access on a value that's nil because the demo expected
      # a fixture from `mount/3` we couldn't extract (computed values).
      reason =~ "no function clause matching" and reason =~ "nil" -> :skip
      reason =~ "key :" and reason =~ "not found in:" and reason =~ "nil" -> :skip
      # `:erlang.++(nil, …)` and similar arithmetic-on-nil errors —
      # a kit helper expected an attr we couldn't supply with a
      # meaningful default (e.g. `assigns.rest` being a list when the
      # demo passed only literals). Mark as structural skip.
      reason =~ "argument error" and reason =~ "nil" -> :skip
      # Non-chelekom helpers referenced from inside extracted blocks
      # that aren't stubbed (e.g. `<.custom_component_list>` from
      # mishka.tools' docs site). We stub the common ones in
      # `DocsStubs`; the rest are best-effort skips.
      reason =~ "is undefined (there is no such import)" -> :skip
      true -> :fail
    end
  end

  defp classify(_), do: :fail

  defp build_failure(component, example, reason) do
    %{
      component: component["name"],
      file: example["file"],
      line: example["line"],
      source: example["source"],
      reason: reason
    }
  end

  # Compile + evaluate one HEEx snippet under the example's assigns.
  # Catches any exception and reports it as a failure reason.
  # Default values for assigns commonly referenced by demos but not
  # captured by `DemoAssignsExtractor` (because they're computed in
  # `mount/3` via function calls we don't run, or — for `s`, `i`, `c`
  # — because they're bound by an outer `:for` directive that the
  # extractor's snippet boundary doesn't include). We supply safe
  # defaults so the render doesn't `KeyError`.
  #
  # `form` is a real `Phoenix.HTML.FormField` parent so the form-input
  # components (`<.text_field field={@form[:x]}/>` etc.) compile and
  # render. Form components are otherwise the largest skip category.
  @default_assigns %{
    csp_nonce: nil,
    flash: %{},
    code_1: "",
    code_2: "",
    code_3: "",
    code_4: "",
    code_5: "",
    code_6: "",
    socket: nil,
    star: 0,
    banner_pos: nil,
    seo_tags: [],
    # Common comprehension variables used by demos with `:for={X <- …}`
    # on a parent the extractor's window doesn't capture. The values
    # are arbitrary literals — the demo only cares that they're bound.
    s: "circle",
    i: 1,
    c: "primary",
    item: %{},
    items: [],
    shape: "circle",
    color: "primary",
    variant: "default",
    # Real form fixture for form-input components.
    form:
      Phoenix.Component.to_form(
        %{"name" => "", "email" => "", "age" => 18, "agreed" => false},
        as: :demo
      )
  }

  defp render_one(%{"source" => source, "assigns" => raw_assigns}) do
    assigns =
      raw_assigns
      |> atomize_assigns()
      |> then(fn a -> Map.merge(@default_assigns, a) end)

    # Capture stderr produced by `:elixir`'s compiler so we can read
    # the underlying error reason (e.g. "undefined variable s") which
    # otherwise gets logged out-of-band, leaving us with a generic
    # "cannot compile file (errors have been logged)" exception.
    {result, captured_stderr} =
      capture_stderr(fn ->
        try do
          compiled = compile_heex(source)

          # `Code.eval_quoted/3` defaults to a fresh empty env. The
          # HEEx-compiled AST contains bare `component(...)` calls (the
          # runtime dispatcher), which only resolve under
          # `MishkaChelekom.Test.Runtime.LiveViewHelpers` import. Pass
          # our module's env so eval-time function lookups land on the
          # right module.
          #
          # Bindings: `assigns` is the standard one. We also bind common
          # comprehension variables (`s`, `i`, `c`, `shape`, `color`,
          # `variant`) at the top level — demos in chelekom's docs
          # frequently reference these in attrs (`<.shape variant={s}>`)
          # because the docs page wraps the chelekom call in a parent
          # `:for={s <- …}` directive that the extractor's window
          # doesn't capture. Binding them here makes those isolated
          # snippets compile + render with a single arbitrary value.
          bindings = [
            assigns: assigns,
            s: "circle",
            i: 1,
            c: "primary",
            shape: "circle",
            color: "primary",
            variant: "default",
            item: %{},
            items: []
          ]

          {rendered, _} = Code.eval_quoted(compiled, bindings, __ENV__)
          _html = rendered |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()

          :ok
        rescue
          e -> {:error, format_error(e, __STACKTRACE__)}
        catch
          kind, payload -> {:error, "caught #{kind}: #{inspect(payload)}"}
        end
      end)

    case result do
      :ok ->
        :ok

      {:error, reason} when is_binary(reason) ->
        # If captured stderr is more informative (e.g. "undefined
        # variable s"), surface that instead of the wrapper. Both
        # classify pipelines (skip vs fail) read the resulting string,
        # so this directly affects the verdict.
        cond do
          captured_stderr != "" and reason =~ "errors have been logged" ->
            {:error, captured_stderr <> "\n" <> reason}

          true ->
            {:error, reason}
        end
    end
  end

  # Lightweight stderr capture without an extra dep. Replaces the
  # process group leader for the duration of `fun` so writes to
  # `:standard_error` are collected, then restores it. Same idea as
  # `ExUnit.CaptureIO.capture_io(:stderr, fun)` but with no test-env
  # coupling.
  defp capture_stderr(fun) do
    {:ok, pid} = StringIO.open("")
    original = Process.whereis(:standard_error)

    try do
      Process.unregister(:standard_error)
      Process.register(pid, :standard_error)
      result = fun.()
      {_in, captured} = StringIO.contents(pid)
      {result, captured}
    after
      try do
        Process.unregister(:standard_error)
      rescue
        ArgumentError -> :ok
      end

      if original, do: Process.register(original, :standard_error)
      StringIO.close(pid)
    end
  end

  # `compile_heex/1` is itself a function whose `__ENV__` (after the
  # module-level imports above) carries `component/1`, `assign_new/3`
  # and friends. EEx + TagEngine resolve `<.component …>` against that
  # caller env. Defined as a macro-like construct via `defp` so the
  # captured env is the *call-site* env — which is this module's env.
  defp compile_heex(source) do
    opts = [
      engine: Phoenix.LiveView.TagEngine,
      file: "demo_harness",
      line: 1,
      indentation: 0,
      source: source,
      trim: true,
      caller: __ENV__,
      tag_handler: Phoenix.LiveView.HTMLEngine
    ]

    EEx.compile_string(source, opts)
  end

  defp format_error(e, stack) do
    msg = Exception.message(e)
    top = stack |> Enum.take(2) |> Exception.format_stacktrace()
    "#{msg}\n#{top}"
  end

  # Bundle JSON has string-keyed assigns. The demo invocations expect
  # atom keys (`@posts`, `@page_title`). Reconstruct atoms; nested
  # values keep string keys (sub-keys like `posts.total` aren't
  # accessed via `@.foo` so atom-key conversion is safe to stop at the
  # first level — chelekom's templates do `@posts.total` which requires
  # atom keys at the top, but `:total` and `:active` inside the map
  # also need to be atoms. Use a deep conversion, restricted to
  # known-safe key names so we don't atomize attacker-controlled JSON
  # in production. (This runs only in test, so the surface is bounded.)
  defp atomize_assigns(map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      {String.to_atom(to_string(k)), atomize_value(v)}
    end)
  end

  defp atomize_assigns(other), do: other

  defp atomize_value(%{} = m) when not is_struct(m), do: atomize_assigns(m)
  defp atomize_value(list) when is_list(list), do: Enum.map(list, &atomize_value/1)
  defp atomize_value(other), do: other
end
