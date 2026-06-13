defmodule DevelopmentWeb.Showcase.Catalog do
  @moduledoc """
  Loads Mishka Chelekom component catalog metadata at runtime from the library's
  `priv/components/*.exs` files.

  The library is wired in as a path dependency (see `development/README.md`), so
  `:code.priv_dir(:mishka_chelekom)` resolves (through the `_build` symlink) to the
  live repo source. Editing a component's `.exs` in the repo is reflected here on the
  next request — no recompile needed.

  Each `.exs` is a keyword list keyed by the component atom, e.g.

      [button: [name: "button", category: "general", args: [variant: [...], color: [...]], ...]]
  """

  # The visual argument dimensions we expose as interactive controls. Anything else in
  # `args` (`type`, `only`, `helpers`, `module`) is a generator concern, not a runtime attr.
  @visual_dims ~w(variant color size rounded padding space border media_size)a

  @type dim :: %{key: String.t(), values: [String.t()]}
  @type component :: %{
          name: String.t(),
          category: String.t(),
          doc_url: String.t() | nil,
          args: keyword(),
          dims: [dim()]
        }

  @doc "Absolute path to the library's component catalog directory."
  def components_dir do
    Path.join(:code.priv_dir(:mishka_chelekom), "components")
  end

  @doc "All components, sorted by name."
  @spec all() :: [component()]
  def all do
    components_dir()
    |> Path.join("*.exs")
    |> Path.wildcard()
    |> Enum.map(&load/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(& &1.name)
  end

  @doc "A single component by name, or nil."
  @spec get(String.t()) :: component() | nil
  def get(name) when is_binary(name), do: Enum.find(all(), &(&1.name == name))

  @doc """
  The previous and next components around `name` in the global (name-sorted) order, for page-to-page
  navigation. Each is `nil` at the ends — no wraparound.
  """
  @spec neighbors(String.t()) :: {component() | nil, component() | nil}
  def neighbors(name) do
    list = all()

    case Enum.find_index(list, &(&1.name == name)) do
      nil -> {nil, nil}
      0 -> {nil, Enum.at(list, 1)}
      i -> {Enum.at(list, i - 1), Enum.at(list, i + 1)}
    end
  end

  @doc "Components grouped and sorted by category."
  @spec by_category() :: [{String.t(), [component()]}]
  def by_category do
    all()
    |> Enum.group_by(& &1.category)
    |> Enum.sort_by(fn {category, _} -> category end)
  end

  @doc "Total component count."
  def count, do: length(all())

  defp load(path) do
    name = Path.basename(path, ".exs")
    {term, _bindings} = Code.eval_file(path)

    cfg =
      cond do
        is_list(term) and Keyword.has_key?(term, String.to_atom(name)) ->
          term[String.to_atom(name)]

        is_list(term) and term != [] ->
          term |> List.first() |> elem(1)

        true ->
          nil
      end

    if cfg do
      args = cfg[:args] || []

      json_attrs = DevelopmentWeb.Showcase.JsonMeta.attrs(name)
      attr_types = Map.new(json_attrs, &{&1.name, &1.type})

      dims =
        for key <- @visual_dims, vals = args[key], is_list(vals) and vals != [] do
          {attr, type} = resolve_attr(key, attr_types)

          %{
            key: Atom.to_string(key),
            attr: attr,
            type: type,
            values: Enum.map(vals, &to_string/1)
          }
        end

      dims =
        (dims ++ extra_dims(name))
        |> Enum.uniq_by(& &1.key)
        |> Enum.reject(&(&1.key in dead_dims(name)))

      %{
        name: name,
        category: to_string(cfg[:category] || "other"),
        doc_url: cfg[:doc_url],
        description: DevelopmentWeb.Showcase.Meta.styled_description(name),
        sibling: DevelopmentWeb.Showcase.Meta.headless_sibling(name),
        args: args,
        dims: dims,
        flags: Enum.reject(flags(json_attrs), &(&1.name in dead_flags(name)))
      }
    end
  rescue
    _ -> nil
  end

  # Resolve a catalog dimension key to the component's REAL attribute (name + type). The catalog
  # uses conventional keys (e.g. `color`), but a component may expose that option under a different
  # attr — e.g. alert's color lives in `kind` (an atom). Falls back to the key itself (string) when
  # the JSON has no attribute info for this component.
  defp resolve_attr(:color, types) do
    cond do
      Map.has_key?(types, "color") -> {"color", type_of(types["color"])}
      Map.has_key?(types, "kind") -> {"kind", type_of(types["kind"])}
      true -> {"color", :string}
    end
  end

  defp resolve_attr(key, types) do
    k = Atom.to_string(key)
    {k, type_of(Map.get(types, k, "string"))}
  end

  # Per-component control fixups. A component's catalog `args` can list a dim it never actually applies
  # (a dead control that does nothing in the live preview), or omit one the component really supports.

  # Dims the component declares but ignores, so they don't appear as inert controls.
  # banner: `@size` is unused by `banner/1`; `@space` is `space-y-*` on a wrapper that always has a
  # single child, so it can never change anything.
  defp dead_dims("banner"), do: ["size", "space"]
  defp dead_dims(_), do: []

  # Boolean flags the component declares but never reads, or that aren't a working standalone mode.
  # file_field: `live` (without dropzone) renders <.live_file_input upload={@upload}>, but @upload is
  # only assigned in the dropzone path — mishka never uses live standalone, so it's not a real mode.
  defp dead_flags("file_field"), do: ["live"]
  # toggle_field: `ring` and `reverse` were declared but never read (@ring/@reverse used 0×) — deleted
  # from the component; the JSON metadata still lists them, so drop them from the controls here too.
  defp dead_flags("toggle_field"), do: ["ring", "reverse"]
  defp dead_flags(_), do: []

  # Real, visible dims the catalog args omit. banner supports `border` (a `border-*` thickness).
  defp extra_dims("banner") do
    [
      %{
        key: "border",
        attr: "border",
        type: :string,
        values: ~w(none extra_small small medium large extra_large)
      }
    ]
  end

  # input_field is the core `<.input>` that dispatches by `type` — its defining prop. The catalog
  # exposes no dims, so surface `type` so the input can actually be switched/tested.
  defp extra_dims("input_field") do
    [
      %{
        key: "type",
        attr: "type",
        type: :string,
        values:
          ~w(text email password number search tel url date time color range select checkbox textarea file)
      }
    ]
  end

  defp extra_dims(_), do: []

  defp type_of("atom"), do: :atom
  defp type_of(_), do: :string

  # Boolean attrs worth toggling in the showcase (e.g. combobox `searchable`/`multiple`/`creatable`,
  # button `full_width`, tabs `vertical`). Excludes field-state/validation flags that aren't about
  # styling or that would freeze the preview.
  @flag_blocklist ~w(disabled required readonly checked)

  defp flags(json_attrs) do
    for a <- json_attrs, a.type == "boolean", a.name not in @flag_blocklist do
      %{name: a.name, default: a.default in [true, "true"]}
    end
  end
end
