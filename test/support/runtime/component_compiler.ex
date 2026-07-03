defmodule MishkaChelekom.Test.Runtime.Compilers.ComponentCompiler do
  @moduledoc """
  Runtime compiler for Phoenix Components with dynamic content compilation.

  This module provides functionality to dynamically compile Phoenix Components at runtime
  from configuration data. It generates complete Phoenix Component modules with proper
  attribute definitions, slot definitions, helper functions, and HEEx template compilation.

  ## Features

  - Dynamic component module generation from configuration
  - Full Phoenix Component attribute and slot support
  - HEEx template compilation with proper context
  - Default value handling for all attribute types including @rest
  - Helper function integration
  - Component metadata and access control information
  - Support for struct-based attributes
  - Proper Phoenix LiveView integration

  ## Component Structure

  Generated components include:
  - `__component_information__/0` - Returns component metadata
  - `__component_information__/1` - Returns specific metadata by key
  - Main component function (named after the component title)
  - `render/2` - Alternative rendering function
  - Helper functions (if defined)
  - Proper attr/slot declarations for Phoenix Component compliance

  ## Usage



      params = %{
        title: "alert_box",
        component_module: MyApp.Components.AlertBox,
        template: ~S'''
        <div class={"alert alert-\#{@type} \#{@class}"} role="alert">
          <h4 :if={@title}><%= @title %></h4>
          <%= render_slot(@inner_block) %>
          <button :if={@closable} class="btn-close" phx-click={@on_close}>×</button>
        </div>
        ''',
        attrs: [
          %{name: "type", type: "string", opts: [default: "info", values: ["info", "warning", "error", "success"]]},
          %{name: "title", type: "string", opts: [default: nil]},
          %{name: "closable", type: "boolean", opts: [default: false]},
          %{name: "on_close", type: "string", opts: [default: nil]},
          %{name: "class", type: "string", opts: [default: ""]}
        ],
        slots: [
          %{name: "inner_block", opts: [required: true, doc: "Main content of the alert"]}
        ],
        helpers: [
          %{
            name: "format_message",
            args: "message, type",
            code: ~S\"\"\"
            case type do
              "error" -> "⚠️ " <> message
              "success" -> "✅ " <> message
              _ -> message
            end
            \"\"\"
          }
        ]
      }

      ast = ComponentCompiler.build_module(params)
      MishkaChelekom.Test.Runtime.Compilers.ModuleCompiler.compile_module(ast)
  """

  import Kernel, except: [def: 2, defp: 2]
  import Phoenix.Component.Declarative

  @supported_attr_types ~w(any string atom boolean integer float list map global)

  ####################################################################################
  ############################ (▰˘◡˘▰) Functions (▰˘◡˘▰) #############################
  ####################################################################################

  @doc """
  Main function to build component modules from component data.

  Takes component configuration parameters and returns a complete AST for a Phoenix Component module.
  The function orchestrates the entire compilation process through a pipeline of transformations.

  ## Parameters

  - `params` - Map containing component configuration with keys:
    - `:title` - Component name (required)
    - `:component_module` - Target module name (required)
    - `:template` - HEEx template string (optional)
    - `:body` - Elixir code to execute before rendering (optional)
    - `:attrs` - List of attribute definitions (optional)
    - `:slots` - List of slot definitions (optional)
    - `:helpers` - List of helper function definitions (optional)
    - `:site`, `:site_id`, `:host` - Site context information
    - `:permissions` - Access control permissions
    - `:extra` - Additional metadata

  ## Returns

  Returns the complete AST for the component module that can be compiled using
  `MishkaChelekom.Test.Runtime.Compilers.ModuleCompiler.compile_module/1`.

  ## Example

      params = %{
        title: "card",
        component_module: MyApp.Components.Card,
        template: ~S(<div class="card {@class}"><%= @content %></div>),
        attrs: [
          %{name: "class", type: "string", opts: [default: ""]},
          %{name: "content", type: "string", opts: [required: true]}
        ]
      }

      ast = build_module(params)
  """
  def build_module(params) do
    :telemetry.span(
      [:mishka_cms, :runtime, :compilers, :component],
      %{name: params[:title] || params["title"], site: params[:site] || params["site"]},
      fn ->
        result =
          MishkaChelekom.Test.Runtime.Compilers.Helpers.atomize_keys(params)
          |> build_component_information()
          |> build_module_attributes()
          |> build_attributes()
          |> build_slots()
          |> build_component_function()
          |> build_helpers()
          |> create_module_ast()

        {result, %{}}
      end
    )
  end

  @doc """
  Build component information including metadata.

  Creates AST for the `__component_information__` functions that provide access to component
  metadata, private information, ACL permissions, and extra data. These functions are used
  by the runtime system to introspect component properties.

  ## Parameters

  - `params` - Atomized component parameters map

  ## Returns

  Returns a tuple `{params, functions_ast}` where `functions_ast` contains the AST for:
  - `__component_information__/0` - Returns complete metadata map
  - `__component_information__/1` - Returns metadata by atom key or key path
  - `__component_information__/1` - Returns metadata by string dot-notation path

  ## Metadata Structure

  The metadata includes:
  - `:component` - Public component info (name, timestamp, attrs, slots)
  - `:private` - Private runtime info (id, priority, module, site details)
  - `:acl` - Access control permissions
  - `:extra` - Additional custom metadata
  """
  def build_component_information(params) do
    component_info_ast =
      quote do
        def __component_information__() do
          %{
            component: %{
              name: unquote(params[:title]),
              timestamp: unquote(Macro.escape(params[:timestamp])),
              attrs: unquote(Macro.escape(params[:attrs] || [])),
              slots: unquote(Macro.escape(params[:slots] || []))
            },
            private: %{
              id: unquote(params[:id]),
              priority: unquote(params[:priority] || 0),
              component_module: unquote(params[:component_module]),
              site: unquote(params[:site]),
              site_id: unquote(params[:site_id]),
              host: unquote(params[:host]),
              format: unquote(params[:format]) || :heex
            },
            acl: %{permissions: unquote(Macro.escape(params[:permissions] || []))},
            extra: unquote(Macro.escape(params[:extra]))
          }
        end

        def __component_information__(key) when is_atom(key) do
          get_in(__component_information__(), [key])
        end

        def __component_information__(keys) when is_list(keys) do
          get_in(__component_information__(), keys)
        end

        def __component_information__(key) when is_binary(key) do
          String.split(key, ".")
          |> Enum.map(&String.to_existing_atom/1)
          |> then(&get_in(__component_information__(), &1))
        rescue
          _ -> nil
        end
      end

    {params, [component_info_ast]}
  end

  @doc """
  Build component attributes.

  Generates Phoenix Component attribute declarations from the component configuration.
  Creates proper `attr/3` calls with type validation and options handling.

  ## Parameters

  - `{params, functions_ast}` - Tuple containing params and accumulated AST functions

  ## Returns

  Returns updated tuple with attribute setup and individual attribute declarations added.
  Each attribute is properly validated and converted to Phoenix Component format with:
  - Proper type conversion (including struct types)
  - Option filtering to valid Phoenix Component options
  - Default value handling

  ## Supported Options

  Valid attribute options that are preserved:
  - `:required` - Whether the attribute is required
  - `:default` - Default value for the attribute
  - `:examples` - Example values
  - `:values` - Allowed values list
  - `:doc` - Attribute documentation
  - `:include` - Global attributes to include
  - `:exclude` - Global attributes to exclude
  """
  def build_attributes({params, functions_ast}) do
    attr_setup_ast =
      quote do
        [] = Phoenix.Component.Declarative.__setup__(__MODULE__, [])

        attr = fn name, type, opts ->
          Phoenix.Component.Declarative.__attr__!(
            __MODULE__,
            name,
            type,
            opts,
            __ENV__.line,
            __ENV__.file
          )
        end
      end

    attributes_ast =
      Enum.map(params[:attrs] || [], fn component_attr ->
        type = attr_type_to_atom(component_attr.type, Map.get(component_attr, :struct_name))
        opts = ignore_invalid_attr_opts(Map.get(component_attr, :opts, []))
        opts = coerce_default_for_type(opts, type)

        quote do
          attr.(
            unquote(String.to_atom(component_attr.name)),
            unquote(type),
            unquote(Macro.escape(opts))
          )
        end
      end)

    # Synthetic attrs every compiled runtime component MUST declare:
    #
    #   :site           — the kit-rewriter emits `site={@site}` in
    #                     parent→child runtime dispatches. Without a
    #                     declared `attr :site, :any, default: nil`, the
    #                     `@site` access in the parent's HEEx raises
    #                     KeyError because Phoenix Component change-
    #                     tracking won't auto-populate undeclared keys.
    #
    #   :component_name — likewise, the parent's template references
    #                     `@component_name` when rewriting children, and
    #                     the runtime helper requires it on the assigns
    #                     map at the call-site. Declare it once here so
    #                     it's always safe to read.
    #
    # Both are declared with `default: nil` so existing Chelekom sources
    # (which don't declare them) still compile cleanly.
    declared_names = Enum.map(params[:attrs] || [], fn a -> a.name end)

    synthetic_attrs =
      [{"site", :any}, {"component_name", :any}]
      |> Enum.reject(fn {n, _} -> n in declared_names end)
      |> Enum.map(fn {n, t} ->
        quote do
          attr.(unquote(String.to_atom(n)), unquote(t), default: nil)
        end
      end)

    {params, functions_ast ++ [attr_setup_ast] ++ attributes_ast ++ synthetic_attrs}
  end

  @doc """
  Build component slots.

  Generates Phoenix Component slot declarations from the component configuration.
  Creates proper `slot/3` calls with nested attribute support for slot parameters.

  ## Parameters

  - `{params, functions_ast}` - Tuple containing params and accumulated AST functions

  ## Returns

  Returns updated tuple with slot setup and individual slot declarations added.
  Each slot includes:
  - Proper slot declaration with options
  - Nested attribute definitions for slot parameters
  - Option filtering to valid Phoenix Component slot options

  ## Supported Slot Options

  Valid slot options that are preserved:
  - `:required` - Whether the slot is required
  - `:validate_attrs` - Whether to validate slot attributes
  - `:doc` - Slot documentation

  Slot attributes support the same options as regular component attributes.
  """
  def build_slots({params, functions_ast}) do
    slot_setup_ast =
      quote do
        slot = fn name, opts, block ->
          Phoenix.Component.Declarative.__slot__!(
            __MODULE__,
            name,
            opts,
            __ENV__.line,
            __ENV__.file,
            fn -> nil end
          )
        end
      end

    # Emit slots WITHOUT their nested attr declarations.
    #
    # Phoenix's standard `slot :foo, opts do attr :x, ... end` is a
    # MACRO that scopes inner attrs to the slot. Our runtime-built
    # slots use a fn (`slot = fn name, opts, _block -> __slot__! end`)
    # which doesn't pass the do-block through, so any `attr.()` call
    # inside the block registers at TOP-LEVEL — colliding with same-
    # named top-level attrs (e.g. accordion's :id top-level vs :item.id).
    #
    # Slot-attrs in the bundle are still useful for the test harness
    # to synthesize slot-item shapes; they just can't drive runtime
    # validation. Phoenix is permissive about runtime slot items
    # carrying extra keys, so this is safe.
    slots_ast =
      Enum.map(params[:slots] || [], fn component_slot ->
        quote do
          slot.(
            unquote(String.to_atom(component_slot.name)),
            unquote(ignore_invalid_slot_opts(Map.get(component_slot, :opts, []))),
            do: nil
          )
        end
      end)

    {params, functions_ast ++ [slot_setup_ast] ++ slots_ast}
  end

  @doc """
  Build the main component function with HEEx template compilation and default values.

  Creates the primary component rendering function and an alternative `render/2` function.
  Both functions handle default value merging, execute any body code, and render the HEEx template.

  ## Parameters

  - `{params, functions_ast}` - Tuple containing params and accumulated AST functions

  ## Returns

  Returns updated tuple with the main component function and render function added.

  ## Generated Functions

  - `component_name(assigns)` - Main component function named after the title
  - `render(component_name, assigns)` - Alternative rendering interface

  Both functions:
  1. Merge default values into assigns
  2. Execute any body code (if present)
  3. Compile and render the HEEx template
  4. Return the rendered output

  ## Default Value Handling

  Default values are extracted from attribute definitions and merged into assigns
  before rendering, ensuring all attributes have proper defaults including @rest
  for global attributes.
  """
  def build_component_function({params, functions_ast}) do
    case params[:clauses] do
      list when is_list(list) and list != [] ->
        build_multi_clause_function({params, functions_ast}, list)

      _ ->
        build_single_clause_function({params, functions_ast})
    end
  end

  defp build_single_clause_function({params, functions_ast}) do
    {template_ast, body_ast} = compile_template_and_body(params)

    defaults_map = extract_all_defaults(params[:attrs] || [])

    # Components written like `def fn(assigns) do; assigns = assigns
    # |> assign_new(...); ~H""" """; end` rebind a LOCAL `assigns`
    # before the template. Our template uses `var!(assigns)` which is
    # a different variable, so without a wrapper the body's effects
    # are invisible to the template.
    #
    # When body has content, we run it inside a block where the local
    # `assigns` aliases `var!(assigns)`, then rebind `var!(assigns)`
    # from whatever the body produced. The body's last expression must
    # be a map (the new assigns) — Chelekom convention guarantees
    # this. When body is empty or doesn't return a map, we fall back
    # to the original `var!(assigns)` so we never accidentally clobber
    # it with `nil` or non-map values.
    body_block =
      if params[:body] && params[:body] != "" do
        quote do
          var!(assigns) =
            (
              assigns = var!(assigns)
              new_assigns = unquote(body_ast)
              if is_map(new_assigns), do: new_assigns, else: assigns
            )
        end
      else
        quote do: :ok
      end

    component_function_ast =
      quote do
        def unquote(String.to_atom(params[:title]))(var!(assigns)) do
          var!(assigns) = Map.merge(unquote(Macro.escape(defaults_map)), var!(assigns))
          unquote(body_block)
          unquote(template_ast)
        end

        def render(unquote(params[:title]), var!(assigns)) when is_map(var!(assigns)) do
          var!(assigns) = Map.merge(unquote(Macro.escape(defaults_map)), var!(assigns))
          unquote(body_block)
          unquote(template_ast)
        end
      end

    {params, functions_ast ++ [component_function_ast]}
  end

  defp build_multi_clause_function({params, functions_ast}, clauses) do
    defaults_map = extract_all_defaults(params[:attrs] || [])
    title_atom = String.to_atom(params[:title])

    # Build each arrow clause as a direct `{:->, [], [[pattern], body]}`
    # AST tuple. Avoids the `quote do x -> y end` form which doesn't
    # reliably produce arrow clauses outside case/fn/cond contexts.
    arrow_asts =
      Enum.map(clauses, fn clause ->
        pattern_ast = parse_clause_match(Map.get(clause, :match))
        body_ast = parse_clause_body(Map.get(clause, :body))
        template_ast = compile_clause_template(Map.get(clause, :template, ""), params)

        branch_body =
          quote do
            unquote(body_ast)
            unquote(template_ast)
          end

        {:->, [], [[pattern_ast], branch_body]}
      end)

    # Construct the case node manually rather than going through
    # `quote do case x do unquote(arrows) end end`, which may not splice
    # arrow lists correctly into the do-block. Direct construction:
    # `{:case, [], [subject, [do: arrow_asts]]}` is unambiguous.
    case_ast =
      {:case, [], [quote(do: var!(assigns)), [do: arrow_asts]]}

    # ONE `def` whose body is a `case assigns do ... end`. Phoenix's
    # auto-generated `-inlined-X-/1-` wrapper sees a single function head
    # (the bare `assigns` arg) so attr/slot declarations + change tracking
    # work normally; dispatch happens inside the case via the same
    # patterns the bundle declared in `clauses[*].match`.
    component_function_ast =
      quote do
        def unquote(title_atom)(var!(assigns)) do
          var!(assigns) =
            Map.merge(unquote(Macro.escape(defaults_map)), var!(assigns))

          unquote(case_ast)
        end

        def render(unquote(params[:title]), var!(assigns)) when is_map(var!(assigns)) do
          apply(__MODULE__, unquote(title_atom), [var!(assigns)])
        end
      end

    {params, functions_ast ++ [component_function_ast]}
  end

  # The catch-all pattern is `var!(assigns)` so it binds the same variable
  # the surrounding def already binds — meaning the inner branch can keep
  # reading `@something` via the standard Phoenix.Component.assign path.
  defp parse_clause_match(nil), do: quote(do: var!(assigns))
  defp parse_clause_match(""), do: quote(do: var!(assigns))
  defp parse_clause_match(str) when is_binary(str), do: Code.string_to_quoted!(str)

  defp parse_clause_body(nil), do: quote(do: nil)
  defp parse_clause_body(""), do: quote(do: nil)
  defp parse_clause_body(str) when is_binary(str), do: Code.string_to_quoted!(str)

  defp compile_clause_template("", _params), do: quote(do: ~H"")

  defp compile_clause_template(str, params) when is_binary(str) do
    opts = [
      line: 1,
      indentation: 0,
      file: "mishka_cms_runtime_component_#{params[:title]}_#{params[:site]}_clause",
      caller: make_env(),
      trim: true,
      tag_handler: Phoenix.LiveView.HTMLEngine
    ]

    Phoenix.LiveView.TagEngine.compile(str, opts)
  end

  @doc """
  Build module-level attributes (e.g. `@indicator_positions [...]`).

  Reads `params[:module_attributes]` — a list of `%{name, value, when}` maps.
  Emits `Module.put_attribute(__MODULE__, :name, value)` calls inside the
  module body so the resulting attribute is referenceable by subsequent
  `attr/3` `values:` lists.

  When-gating is performed by the Importer before this point — the compiler
  always emits whatever is in the list.
  """
  def build_module_attributes({params, functions_ast}) do
    attrs_ast =
      Enum.map(params[:module_attributes] || [], fn entry ->
        name =
          entry
          |> Map.get(:name, Map.get(entry, "name"))
          |> String.to_atom()

        value = Map.get(entry, :value, Map.get(entry, "value"))

        quote do
          Module.register_attribute(__MODULE__, unquote(name), persist: true)

          Module.put_attribute(
            __MODULE__,
            unquote(name),
            unquote(Macro.escape(value))
          )
        end
      end)

    {params, functions_ast ++ attrs_ast}
  end

  @doc """
  Build helper functions for the component.

  Processes helper function definitions and creates corresponding function AST.
  Helper functions extend component functionality with custom Elixir code.

  ## Parameters

  - `{params, functions_ast}` - Tuple containing params and accumulated AST functions

  ## Returns

  Returns updated tuple with helper functions added to the AST.

  ## Helper Function Structure

  Each helper function definition should contain:
  - `:name` - Function name as string
  - `:args` - Function arguments as Elixir code string
  - `:code` - Function body as Elixir code string

  ## Example Helper Definition

      %{
        name: "format_date",
        args: "date, format \\\\ :short",
        code: "Calendar.strftime(date, format)"
      }

  This generates a helper function that can be called within the component template.
  """
  def build_helpers({params, functions_ast}) do
    helpers_ast =
      Enum.flat_map(params[:helpers] || [], fn helper ->
        # If the helper carries its own attrs/slots (Chelekom convention:
        # `attr :size, :string, default: "small" ; defp toast_dismiss
        # (assigns) do ~H""" ... """; end`), emit them as `attr.()` /
        # `slot.()` calls IMMEDIATELY before the def. Phoenix's macro
        # associates them with the next def/defp in compilation order,
        # giving the helper its own component contract — defaults flow,
        # `@size` access in the helper template works.
        helper_decls = build_helper_attr_decls(helper)
        [build_helper_def(helper) | helper_decls] |> Enum.reverse()
      end)

    {params, functions_ast ++ helpers_ast}
  end

  # Emit attr/slot decls before the helper. Returns AST nodes in the
  # order they should appear (decls first, then the helper def follows
  # via `build_helper_def`).
  defp build_helper_attr_decls(%{} = helper) do
    attrs = Map.get(helper, :attrs, []) || []
    slots = Map.get(helper, :slots, []) || []

    attr_nodes =
      Enum.map(attrs, fn raw ->
        a = normalize_attr_map(raw)
        type = attr_type_to_atom(a.type, Map.get(a, :struct_name))
        opts = ignore_invalid_attr_opts(Map.get(a, :opts, []))
        opts = coerce_default_for_type(opts, type)

        quote do
          attr.(unquote(String.to_atom(a.name)), unquote(type), unquote(Macro.escape(opts)))
        end
      end)

    slot_nodes =
      Enum.map(slots, fn raw ->
        s = normalize_slot_map(raw)
        opts = ignore_invalid_slot_opts(Map.get(s, :opts, []))

        quote do
          slot.(unquote(String.to_atom(s.name)), unquote(opts), do: nil)
        end
      end)

    attr_nodes ++ slot_nodes
  end

  defp build_helper_def(%{name: name, args: args, code: code}) do
    {head_args, guard} = split_args_and_guard(args || "")

    src =
      case guard do
        nil ->
          "def #{name}(#{head_args}) do\n#{code}\nend"

        g ->
          "def #{name}(#{head_args}) when #{g} do\n#{code}\nend"
      end

    Code.string_to_quoted!(src)
  end

  # Helper attr/slot maps may have string OR atom keys depending on
  # whether they came straight from the converter (atom-keyed) or
  # round-tripped through Ash (`:map`-typed nested values stay
  # string-keyed). Normalize the top-level keys we use.
  defp normalize_attr_map(%{} = a) do
    %{
      name: Map.get(a, :name) || Map.get(a, "name"),
      type: Map.get(a, :type) || Map.get(a, "type") || "any",
      opts: Map.get(a, :opts) || Map.get(a, "opts") || %{},
      struct_name: Map.get(a, :struct_name) || Map.get(a, "struct_name")
    }
  end

  defp normalize_slot_map(%{} = s) do
    %{
      name: Map.get(s, :name) || Map.get(s, "name"),
      opts: Map.get(s, :opts) || Map.get(s, "opts") || %{}
    }
  end

  defp split_args_and_guard(args) when is_binary(args) do
    case String.split(args, " when ", parts: 2) do
      [head] -> {head, nil}
      [head, guard] -> {head, guard}
    end
  end

  @doc """
  Create the final module AST.

  Assembles all component parts into a complete Phoenix Component module AST.
  The generated module includes all necessary imports and uses for proper Phoenix Component operation.

  ## Parameters

  - `{params, functions_ast}` - Tuple containing params and all accumulated function ASTs

  ## Returns

  Returns the complete module AST ready for compilation via `ModuleCompiler.compile_module/1`.

  ## Generated Module Structure

  The final module includes:
  - `defmodule` declaration with the target module name
  - Required Phoenix Component imports and uses
  - MishkaCmsWeb LiveView integration
  - Runtime component helper imports
  - All accumulated function definitions (info, attrs, slots, helpers, main function)

  The module is fully self-contained and ready for runtime compilation and loading.
  """
  def create_module_ast({params, functions_ast}) do
    prelude_ast =
      case params[:prelude] do
        str when is_binary(str) and byte_size(str) > 0 ->
          Code.string_to_quoted!(str,
            file: "ui_kit_prelude:#{params[:title]}"
          )

        _ ->
          nil
      end

    quote do
      defmodule unquote(params[:component_module]) do
        import Phoenix.Component.Declarative
        # Vendored test variant: the runtime CMS injects
        # `use MishkaCmsWeb, :live_view` here. In chelekom's test env
        # we don't carry the host-app LiveView macros, so we substitute
        # the minimal set the compiled components actually need.
        use Phoenix.Component
        import MishkaChelekom.Test.Runtime.LiveViewHelpers, only: [component: 1, component: 2]

        # Tier-1 hardcoded imports — every UI-kit component needs these.
        alias Phoenix.LiveView.JS
        import Phoenix.LiveView.Utils, only: [random_id: 0]
        # Gettext backend is host-app concern; chelekom test env doesn't
        # need it. Stub the macros that templates may reference (`gettext/1`,
        # `ngettext/2`) via the bare-bones backend below.
        require MishkaChelekom.Test.Runtime.GettextStub
        import MishkaChelekom.Test.Runtime.GettextStub

        unquote(prelude_ast)
        unquote_splicing(functions_ast)
      end
    end
  end

  ####################################################################################
  ############################ (▰˘◡˘▰) Helpers (▰˘◡˘▰) ###############################
  ####################################################################################

  # Extract default values from attribute definitions.
  #
  # Processes attribute definitions to create a map of default values that will be
  # merged into assigns before rendering. Handles special cases like @rest attributes.
  #
  # ## Parameters
  #
  # - `attrs` - List of attribute definition maps
  #
  # ## Returns
  #
  # Returns a map where keys are attribute names (atoms) and values are the default values.
  #
  # ## Special Handling
  #
  # - Global attributes with name "rest" get an empty map `%{}` as default
  # - Regular attributes use their `:default` or `"default"` option value
  # - Attributes without defaults are not included in the result map
  defp extract_all_defaults(attrs) do
    for attr <- attrs,
        opts = Map.get(attr, :opts, []),
        default = get_default_from_opts(opts, attr),
        reduce: %{} do
      acc ->
        Map.put(acc, String.to_atom(attr.name), decode_default_value(default))
    end
  end

  # `extract_all_defaults` reads `attr.opts.default` straight from the
  # bundle row — which (for atom-keyed map defaults) is still in the
  # `%{"__atom_map__" => [["k", "v"], …]}` JSON envelope. The
  # `coerce_default_for_type/2` decode runs in a sibling code path
  # (`build_attributes`) and only affects the value passed to the
  # `attr.()` macro call, not the map merged into `var!(assigns)` at
  # render time. Decode here too so `@some_label` arrives as the
  # atom-keyed map the helper expects.
  # Match both string-keyed (`%{"__atom_map__" => pairs}`) and
  # atom-keyed (`%{__atom_map__: pairs}`) envelopes — `build_module/1`
  # runs `Helpers.atomize_keys/1` over the entire params tree as its
  # first step, which deep-atomizes the JSON envelope's outer key.
  defp decode_default_value(%{"__atom_map__" => pairs}) when is_list(pairs) do
    decode_atom_map(pairs)
  end

  defp decode_default_value(%{__atom_map__: pairs}) when is_list(pairs) do
    decode_atom_map(pairs)
  end

  defp decode_default_value(list) when is_list(list),
    do: Enum.map(list, &decode_default_value/1)

  defp decode_default_value(%{} = map) when not is_struct(map),
    do: Map.new(map, fn {k, v} -> {k, decode_default_value(v)} end)

  defp decode_default_value(other), do: other

  # Safely extract default value from opts, handling maps, keyword lists, and empty values
  defp get_default_from_opts(opts, attr) when is_map(opts) do
    Map.get(opts, :default) || Map.get(opts, "default") ||
      (attr.type == "global" && attr.name == "rest" && %{})
  end

  defp get_default_from_opts(opts, attr) when is_list(opts) and opts != [] do
    Keyword.get(opts, :default) ||
      (attr.type == "global" && attr.name == "rest" && %{})
  end

  defp get_default_from_opts(_opts, attr) do
    # Empty list or nil - only check for global rest attribute
    attr.type == "global" && attr.name == "rest" && %{}
  end

  # Compile template and body code into AST.
  #
  # Processes the component's body code and HEEx template into executable AST.
  # Body code is executed before rendering, while template produces the final output.
  #
  # ## Parameters
  #
  # - `params` - Component parameters containing :body and :template
  #
  # ## Returns
  #
  # Returns a tuple `{template_ast, body_ast}` where:
  # - `template_ast` - Compiled HEEx template AST or empty sigil_H
  # - `body_ast` - Compiled body code AST or `nil`
  #
  # ## Template Compilation
  #
  # Uses Phoenix.LiveView.TagEngine with proper context and options:
  # - Proper file naming for debugging
  # - Import context via make_env/0
  # - Trimming and HTML engine integration
  defp compile_template_and_body(params) do
    body_ast =
      if params[:body] && params[:body] != "" do
        Code.string_to_quoted!(params[:body])
      else
        quote do: nil
      end

    # Compile template using EEx with Phoenix LiveView engine
    template_ast =
      if params[:template] && params[:template] != "" do
        opts = [
          line: 1,
          indentation: 0,
          file: "mishka_cms_runtime_component_#{params[:title]}_#{params[:site]}",
          caller: make_env(),
          trim: true,
          tag_handler: Phoenix.LiveView.HTMLEngine
        ]

        Phoenix.LiveView.TagEngine.compile(params[:template], opts)
      else
        quote do: ~H""
      end

    {template_ast, body_ast}
  end

  @doc """
  Create environment for template compilation.

  Builds a compilation environment with necessary imports for HEEx template processing.
  Ensures that Phoenix HTML, Component, and LiveView helpers are available during template compilation.

  ## Returns

  Returns a `Macro.Env` struct with all required imports defined for proper template compilation.

  ## Imported Modules

  - `Phoenix.HTML` - HTML generation helpers
  - `Phoenix.Component` - Component helpers and sigil_H

  Failed imports are logged but don't stop the compilation process, ensuring robustness
  even when some modules aren't available.
  """
  def make_env() do
    imports = [
      Phoenix.HTML,
      Phoenix.Component,
      Phoenix.LiveView.Helpers
    ]

    Enum.reduce(imports, __ENV__, fn module, env ->
      with true <- :erlang.module_loaded(module),
           {:ok, env} <- define_import(env, module) do
        env
      else
        {:error, error} ->
          require Logger
          Logger.warning("failed to import #{module}: #{error}")
          env

        _ ->
          env
      end
    end)
  end

  # Define import in the compilation environment.
  #
  # Safely imports a module into the given environment for template compilation.
  # Used by make_env/0 to set up the necessary imports.
  #
  # ## Parameters
  #
  # - `env` - The Macro.Env to import into
  # - `module` - The module to import
  #
  # ## Returns
  #
  # Returns `{:ok, updated_env}` on success or `{:error, reason}` on failure.
  defp define_import(env, module) do
    meta = []
    Macro.Env.define_import(env, meta, module)
  end

  # Convert string attribute type to atom with struct handling.
  #
  # Converts component attribute type strings to proper atoms for Phoenix Component
  # attribute declarations. Handles special case for struct types.
  #
  # ## Parameters
  #
  # - `component_type` - String type name (e.g., "string", "struct")
  # - `struct_name` - Module name for struct types
  #
  # ## Returns
  #
  # Returns the appropriate type atom or module name for attr declarations.
  # Struct-typed attrs come pre-resolved with full module paths
  # (`Phoenix.LiveView.JS`, not the bare alias `JS`) — the converter
  # walks the source's `alias` declarations and emits the fully-
  # qualified name. So `Module.concat([struct_name])` always lands on
  # a real loadable module without needing a runtime lookup table.
  defp attr_type_to_atom(component_type, struct_name) when component_type == "struct" do
    Module.concat([struct_name])
  end

  defp attr_type_to_atom(component_type, _struct_name)
       when component_type in @supported_attr_types do
    String.to_atom(component_type)
  end

  # Filter attribute options to only include valid Phoenix Component options.
  #
  # Phoenix Components only accept specific options for attributes. This function
  # filters out any invalid options to prevent compilation errors.
  #
  # ## Parameters
  #
  # - `opts` - Options map, keyword list, or other value
  #
  # ## Returns
  #
  # Returns a keyword list containing only valid Phoenix Component attribute options.
  #
  # ## Valid Options
  #
  # - `:required`, `:default`, `:examples`, `:values`, `:doc`, `:include`, `:exclude`
  # JSON cannot encode atoms, so the converter stringifies atom defaults
  # (`:natural` → `"natural"`). Phoenix's attr/3 macro validates the
  # default's type at compile time and rejects strings for `:atom` typed
  # attrs. Coerce the string back to an atom here.
  defp coerce_default_for_type(opts, :atom) do
    case Keyword.fetch(opts, :default) do
      {:ok, val} when is_binary(val) -> Keyword.put(opts, :default, String.to_atom(val))
      _ -> opts
    end
  end

  # `:map` defaults like `%{kind: "toast"}` round-trip through the
  # bundle as `%{"__atom_map__" => [["k", v], ...]}` (atoms encoded
  # with leading `:` sentinel — see exporter). Decode back here.
  defp coerce_default_for_type(opts, :map) do
    # Match both string-keyed `"__atom_map__"` (raw JSON envelope) and
    # atom-keyed `:__atom_map__` (after `Helpers.atomize_keys/1` runs
    # at the start of `build_module/1`). The runtime test path goes
    # through atomize_keys; the original CMS install path doesn't.
    case Keyword.fetch(opts, :default) do
      {:ok, %{"__atom_map__" => pairs}} when is_list(pairs) ->
        Keyword.put(opts, :default, decode_atom_map(pairs))

      {:ok, %{__atom_map__: pairs}} when is_list(pairs) ->
        Keyword.put(opts, :default, decode_atom_map(pairs))

      _ ->
        opts
    end
  end

  # Struct-typed attrs (e.g. `attr :on_show, Phoenix.LiveView.JS,
  # default: %JS{}` in the original source). The converter cannot
  # encode `%JS{}` in JSON, so it drops the default — but components
  # then call `JS.remove_class(@on_show, ...)` and `JS.remove_class`
  # has no clause for `nil`. Reinstate a zero-arity struct default
  # `%Module{}` when the attr type points at a real, loadable struct
  # module and no other default was provided.
  defp coerce_default_for_type(opts, struct_module) when is_atom(struct_module) do
    cond do
      Keyword.has_key?(opts, :default) ->
        opts

      struct_module?(struct_module) ->
        Keyword.put(opts, :default, struct(struct_module))

      true ->
        opts
    end
  end

  defp coerce_default_for_type(opts, _type), do: opts

  defp struct_module?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :__struct__, 0)
  end

  # Decode a JSON `__atom_map__` envelope back into an atom-keyed map.
  # Strings prefixed with `:` were originally atoms; all other values
  # pass through unchanged.
  defp decode_atom_map(pairs) when is_list(pairs) do
    Enum.into(pairs, %{}, fn
      [k, v] -> {decode_atom_term(k), decode_atom_term(v)}
      {k, v} -> {decode_atom_term(k), decode_atom_term(v)}
    end)
  end

  defp decode_atom_term(":" <> rest), do: String.to_atom(rest)

  defp decode_atom_term(list) when is_list(list), do: Enum.map(list, &decode_atom_term/1)

  defp decode_atom_term(other), do: other

  @valid_attr_opt_keys [:required, :default, :examples, :values, :doc, :include, :exclude]

  # Helper attrs round-trip from DB with STRING keys (`%{"default" =>
  # "small"}`); top-level attrs that flow through Ash arrive atom-
  # keyed. Coerce both shapes into an atom-keyed keyword list, then
  # filter to the keys Phoenix's `attr/3` macro accepts.
  defp ignore_invalid_attr_opts(opts) when is_map(opts) do
    opts
    |> Enum.flat_map(fn {k, v} ->
      key = if is_atom(k), do: k, else: safe_atomize(k)
      if key in @valid_attr_opt_keys, do: [{key, v}], else: []
    end)
  end

  defp ignore_invalid_attr_opts(opts) when is_list(opts) do
    Enum.flat_map(opts, fn
      {k, v} when is_atom(k) ->
        if k in @valid_attr_opt_keys, do: [{k, v}], else: []

      {k, v} when is_binary(k) ->
        case safe_atomize(k) do
          nil -> []
          atom -> if atom in @valid_attr_opt_keys, do: [{atom, v}], else: []
        end

      _ ->
        []
    end)
  end

  defp ignore_invalid_attr_opts(_opts), do: []

  # `String.to_existing_atom/1` won't crash on unknown strings — but
  # @valid_attr_opt_keys atoms exist at this point (they're literal
  # atoms in this module), so existing-atom lookup is safe and avoids
  # leaking unknown atoms.
  defp safe_atomize(s) when is_binary(s) do
    String.to_existing_atom(s)
  rescue
    ArgumentError -> nil
  end

  # Filter slot options to only include valid Phoenix Component slot options.
  #
  # Phoenix Components only accept specific options for slots. This function
  # filters out any invalid options to prevent compilation errors.
  #
  # ## Parameters
  #
  # - `opts` - Options map, keyword list, or other value
  #
  # ## Returns
  #
  # Returns a keyword list containing only valid Phoenix Component slot options.
  #
  # ## Valid Slot Options
  #
  # - `:required`, `:validate_attrs`, `:doc`
  defp ignore_invalid_slot_opts(opts) when is_map(opts) do
    opts
    |> Enum.into([])
    |> Keyword.take([:required, :validate_attrs, :doc])
  end

  defp ignore_invalid_slot_opts(opts) when is_list(opts) do
    Keyword.take(opts, [:required, :validate_attrs, :doc])
  end

  defp ignore_invalid_slot_opts(_opts) do
    []
  end
end
