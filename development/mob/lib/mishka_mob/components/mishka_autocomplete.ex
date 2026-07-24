defmodule MishkaMob.Components.MishkaAutocomplete do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Autocomplete** — a text field
  that suggests completions as you type.

  ## Autocomplete or Combobox?

  They are close enough that the port makes them the same machinery and keeps the
  difference the web component actually draws:

    * a **Combobox** picks from a fixed list — the value is one of the options,
      and the field is a filter over them.
    * an **Autocomplete** accepts free text and merely *suggests* — the query IS
      the value, and choosing a suggestion fills it in.

  So this renders through `MishkaMob.Components.MishkaCombobox` (same filtering,
  same list surface) but the value it reports is the **text**, and picking a
  suggestion replaces that text rather than selecting an id. `single`
  `on_select` therefore hands back the suggestion's label, which is what a
  free-text field needs.

  Suggestions are also hidden once the query exactly matches one, since there is
  nothing left to suggest.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `query` | string | `""` | The field's text — this is the value. |
  | `open` | boolean | `false` | Whether suggestions are shown. |
  | `suggestions` | list of strings | `[]` | What to offer. |
  | `filter` | `:contains` `:starts_with` | `:starts_with` | Match mode — prefix by default, which is what "autocomplete" means. |
  | `placeholder` | string | `"Type to search…"` | Field placeholder. |
  | `clear` | boolean | `false` | Render a ✕ that clears the text. |
  | `empty_text` | string | `"No suggestions"` | Shown when nothing matches. |
  | `disabled` | boolean | `false` | Mutes and unwires. |
  | `on_query` / `on_select` / `on_clear` | event tags | — | Typing, choosing, clearing. |

  Not ported: `name` / `required` / `readonly` (form plumbing), `auto_highlight`
  (no focus ring), and `id` / `*_class`.
  """

  alias MishkaMob.Components.MishkaCombobox

  @doc "Composite expander (`<MishkaAutocomplete />`)."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: autocomplete(props)

  @doc """
  The suggestions to show for a query — filtered, and empty once the query
  already matches one exactly.

      iex> alias MishkaMob.Components.MishkaAutocomplete, as: A
      ...> A.suggest(["Iran", "Ireland", "Italy"], "ir")
      ["Iran", "Ireland"]

      iex> alias MishkaMob.Components.MishkaAutocomplete, as: A
      ...> A.suggest(["Iran", "Ireland"], "Iran")
      []

      iex> alias MishkaMob.Components.MishkaAutocomplete, as: A
      ...> A.suggest(["Iran", "Ireland"], "")
      ["Iran", "Ireland"]
  """
  @spec suggest([String.t()], String.t() | nil, keyword()) :: [String.t()]
  def suggest(suggestions, query, opts \\ []) do
    mode = Keyword.get(opts, :mode, :starts_with)
    folded = MishkaCombobox.fold(query)

    exact? = Enum.any?(suggestions, &(MishkaCombobox.fold(&1) == folded and folded != ""))

    if exact? do
      []
    else
      suggestions
      |> Enum.map(&{&1, &1})
      |> MishkaCombobox.filter(query, mode: mode)
      |> Enum.map(&elem(&1, 0))
    end
  end

  @doc """
  Whether the query already names a suggestion exactly — in which case there is
  nothing left to suggest.

      iex> MishkaMob.Components.MishkaAutocomplete.exact?(["Iran"], "iran")
      true
      iex> MishkaMob.Components.MishkaAutocomplete.exact?(["Iran"], "ir")
      false
      iex> MishkaMob.Components.MishkaAutocomplete.exact?(["Iran"], "")
      false
  """
  @spec exact?([String.t()], String.t() | nil) :: boolean()
  def exact?(suggestions, query) do
    folded = MishkaCombobox.fold(query)
    folded != "" and Enum.any?(suggestions, &(MishkaCombobox.fold(&1) == folded))
  end

  @doc "The autocomplete node."
  @spec autocomplete(map() | keyword()) :: map()
  def autocomplete(props \\ %{}) do
    props = Map.new(props)
    query = Map.get(props, :query, "")
    all = List.wrap(Map.get(props, :suggestions, []))

    # Options carry the LABEL as their id, so choosing one hands the screen the
    # text to put in the field rather than an id it would have to look up.
    # The Combobox does the filtering, from the same query the field shows —
    # pre-filtering here and blanking its query would have emptied the field.
    options =
      if exact?(all, query), do: [], else: Enum.map(all, &MishkaCombobox.option(&1, &1))

    props
    |> Map.drop([:suggestions])
    |> Map.put(:filter, Map.get(props, :filter, :starts_with))
    |> Map.put_new(:placeholder, "Type to search…")
    |> Map.put_new(:empty_text, "No suggestions")
    |> MishkaCombobox.combobox(options)
  end
end
