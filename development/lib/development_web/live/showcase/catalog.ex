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

      %{
        name: name,
        category: to_string(cfg[:category] || "other"),
        doc_url: cfg[:doc_url],
        description: DevelopmentWeb.Showcase.Meta.styled_description(name),
        sibling: DevelopmentWeb.Showcase.Meta.headless_sibling(name),
        args: args,
        dims: dims,
        flags: flags(json_attrs)
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
