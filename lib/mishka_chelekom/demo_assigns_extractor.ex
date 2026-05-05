defmodule MishkaChelekom.DemoAssignsExtractor do
  @moduledoc """
  Extract initial-render assigns from a demo `<comp>_live.ex` file.

  Walks the companion `mount/3` body via Sourceror, finds every
  `assign/2` and `assign/3` call, and tries to evaluate the value
  expression at export time. Successful evaluations are kept as Elixir
  terms; unsafe / unsupported expressions are dropped with a build-time
  warning so the eventual JSON only carries data the consumer (CMS)
  can serialize and consume without `Code.eval_string/1`.

  ## Returned shape

      {%{posts: %{total: 10, active: 1}, csp_nonce: nil, …},
       [
         {"code_1", :unsupported_expression},
         {"seo_tags", :unsafe_call}
       ]}

  Skip rules are deliberately conservative — anything that looks like
  IO / DB / process state / unbound module call is skipped:

    * Function captures (`&fun/1`)
    * Calls into modules we don't whitelist
    * `~p"..."` route helpers (the verified-routes macro requires a
      router context that the export environment doesn't have)
    * `Phoenix.LiveView.JS` struct literals (we keep them — JS is
      whitelisted because it's pure data)
  """

  @safe_modules [
    Phoenix.LiveView.JS,
    Map,
    List,
    String,
    Enum,
    Range,
    Kernel
  ]

  # Identifiers that are part of safe data construction grammar — NOT
  # function calls. Anything not listed here, when used as a local
  # function call inside an `assign/3` value, is treated as unsafe.
  @safe_kernels [
    :%{},
    :{},
    :"::",
    :<<>>,
    :|,
    :__block__,
    :__aliases__,
    :__MODULE__,
    :@
  ]

  @type extraction_result :: {map(), [{atom(), :unsupported_expression | :unsafe_call | :raised}]}

  @doc """
  Read the file at `path` and return `{assigns_map, skipped_entries}`.
  Missing files yield `{%{}, []}`.
  """
  @spec extract_from_file(Path.t()) :: extraction_result()
  def extract_from_file(path) do
    case File.read(path) do
      {:ok, source} -> extract_from_source(source)
      {:error, _} -> {%{}, []}
    end
  end

  @spec extract_from_source(String.t()) :: extraction_result()
  def extract_from_source(source) when is_binary(source) do
    case Code.string_to_quoted(source, columns: false, token_metadata: false) do
      {:ok, ast} ->
        ast
        |> find_mount_body()
        |> walk_assigns({%{}, []})

      {:error, _} ->
        {%{}, []}
    end
  end

  defp find_mount_body({:defmodule, _, [_alias, [do: {:__block__, _, body}]]}),
    do: find_mount_in_block(body)

  defp find_mount_body({:defmodule, _, [_alias, [do: single]]}),
    do: find_mount_in_block([single])

  defp find_mount_body(_), do: nil

  defp find_mount_in_block(stmts) do
    Enum.find_value(stmts, fn
      {:def, _, [{:mount, _, args}, [do: body]]} when length(args) == 3 -> body
      _ -> nil
    end)
  end

  defp walk_assigns(nil, acc), do: acc

  # `socket |> assign(:k, v) |> assign(...)` — Macro.prewalk visits each call.
  defp walk_assigns(ast, acc) do
    {_, final} = Macro.prewalk(ast, acc, &collect_assign/2)
    final
  end

  defp collect_assign({:assign, _, [_socket, key, value]} = node, acc),
    do: {node, capture_assign(acc, key, value)}

  defp collect_assign({:assign, _, [_socket, kw]} = node, acc) when is_list(kw),
    do: {node, capture_keyword_list(acc, kw)}

  defp collect_assign({:assign, _, [kw]} = node, acc) when is_list(kw),
    do: {node, capture_keyword_list(acc, kw)}

  defp collect_assign({:assign, _, [key, value]} = node, acc) when is_atom(key) or is_binary(key),
    do: {node, capture_assign(acc, key, value)}

  defp collect_assign(node, acc), do: {node, acc}

  defp capture_keyword_list(acc, kw) do
    Enum.reduce(kw, acc, fn
      {k, v}, acc -> capture_assign(acc, k, v)
      _, acc -> acc
    end)
  end

  defp capture_assign({map, skipped}, key, value_ast) do
    key_atom = to_atom_key(key)

    case key_atom do
      nil ->
        {map, skipped}

      key_atom ->
        case eval_value(value_ast) do
          {:ok, term} -> {Map.put(map, key_atom, term), skipped}
          {:error, reason} -> {map, [{key_atom, reason} | skipped]}
        end
    end
  end

  defp to_atom_key(k) when is_atom(k), do: k
  defp to_atom_key(k) when is_binary(k), do: String.to_atom(k)
  defp to_atom_key({:__aliases__, _, _}), do: nil
  defp to_atom_key(_), do: nil

  defp eval_value(ast) do
    cond do
      contains_unsafe?(ast) ->
        {:error, :unsafe_call}

      true ->
        try do
          {value, _bindings} =
            Code.eval_quoted(ast, [], file: "demo_assigns_extractor", line: 1)

          if serializable?(value), do: {:ok, value}, else: {:error, :unsupported_expression}
        rescue
          _ -> {:error, :raised}
        catch
          _, _ -> {:error, :raised}
        end
    end
  end

  defp contains_unsafe?(ast) do
    {_, found?} =
      Macro.prewalk(ast, false, fn
        node, true ->
          {node, true}

        # Function capture `&Mod.fun/n` or `&fun/n`
        {:&, _, _} = node, _acc ->
          {node, true}

        # Module-qualified call — only allow whitelisted modules
        {{:., _, [{:__aliases__, _, mod_path}, _fn]}, _, _args} = node, _acc ->
          mod = Module.concat(mod_path)
          if mod in @safe_modules, do: {node, false}, else: {node, true}

        # Erlang module call
        {{:., _, [erl_mod, _fn]}, _, _args} = node, _acc when is_atom(erl_mod) ->
          if erl_mod in [:erlang, :crypto], do: {node, false}, else: {node, true}

        # Local function call (e.g. `code_string(1)`, `seo_tags()`)
        {fn_name, _, args} = node, _acc when is_atom(fn_name) and is_list(args) ->
          if fn_name in @safe_kernels, do: {node, false}, else: {node, true}

        # `~p"..."` route sigil → unsafe (no router context)
        {:sigil_p, _, _} = node, _acc ->
          {node, true}

        # `IO.inspect`, `IO.puts` etc. via direct atom dot-call
        {:io, _, _} = node, _acc ->
          {node, true}

        node, acc ->
          {node, acc}
      end)

    found?
  end

  # Anything we couldn't represent in JSON or that the CMS shouldn't
  # accept. Functions, PIDs, refs are all out.
  defp serializable?(value) do
    case value do
      v when is_function(v) -> false
      v when is_pid(v) -> false
      v when is_reference(v) -> false
      v when is_port(v) -> false
      v when is_tuple(v) -> Enum.all?(Tuple.to_list(v), &serializable?/1)
      v when is_list(v) -> Enum.all?(v, &serializable?/1)
      %_struct{} = s -> Map.from_struct(s) |> Map.values() |> Enum.all?(&serializable?/1)
      v when is_map(v) -> Enum.all?(Map.values(v), &serializable?/1)
      _ -> true
    end
  end
end
