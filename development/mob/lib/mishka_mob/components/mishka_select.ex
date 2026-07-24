defmodule MishkaMob.Components.MishkaSelect do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Select** — a trigger showing
  the current choice, and a list to pick from.

  ## Trigger and list, placed by the caller

  The web version floats its listbox beside the trigger. That needs anchored
  positioning, which Mob does not have (see
  `MishkaMob.Components.MishkaPopover`), so the list renders in flow beneath the
  trigger — or, for a long list on a phone, inside a bottom
  `MishkaMob.Components.MishkaDrawer`, which is where a native picker belongs
  anyway. `side` and `highlight_on_hover` are dropped: no anchoring, no hover.

  The list is built on `MishkaMenu`'s surface so a select and a menu do not
  disagree about what a list of choices looks like.

  ## Single and multiple

  `select/2` is a display of `value`; `toggle/3` is the transition. In multiple
  mode `value` is a list and picking accumulates; in single mode it is one value
  and picking replaces it and closes the list — which is why `toggle/3` returns
  `{value, close?}` rather than just the value. A multi-select that closed after
  every pick would be exhausting.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | option id, list, or `nil` | `nil` | The current choice(s). |
  | `open` | boolean | `false` | Whether the list is shown. |
  | `multiple` | boolean | `false` | Allow several choices. |
  | `placeholder` | string | `"Select…"` | Trigger text when nothing is chosen. |
  | `label` | string | `nil` | Caption above the trigger. |
  | `disabled` | boolean | `false` | Mutes and unwires. |
  | `on_toggle` | event tag (atom) | — | `{:tap, tag}` from the trigger. |
  | `on_select` | event tag (atom) | — | `{:tap, {tag, option_id}}` from an option. |

  Options are children built with `option/3`.

  Not ported: `name`, `form`, `required`, `readonly` (form plumbing), `side`,
  `highlight_on_hover`, and `id` / `*_class`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Event, MishkaMenu}

  @option :mishka_select_option

  @doc "Composite expander (`<MishkaSelect>`). Children are options."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: select(props, children)

  @doc "Build one option node."
  @spec option(term(), String.t(), keyword()) :: map()
  def option(id, label, opts \\ []) do
    %{
      type: @option,
      props: %{id: id, label: label, disabled: Keyword.get(opts, :disabled, false)},
      children: []
    }
  end

  @doc """
  The next `{value, close?}` after picking `id`.

  Single mode replaces and closes; multiple accumulates and stays open, because
  a multi-select that closed after every pick would be exhausting.

      iex> MishkaMob.Components.MishkaSelect.toggle(nil, :a, false)
      {:a, true}
      iex> MishkaMob.Components.MishkaSelect.toggle(:a, :a, false)
      {:a, true}
      iex> MishkaMob.Components.MishkaSelect.toggle([:a], :b, true)
      {[:a, :b], false}
      iex> MishkaMob.Components.MishkaSelect.toggle([:a, :b], :a, true)
      {[:b], false}
  """
  @spec toggle(term(), term(), boolean()) :: {term(), boolean()}
  def toggle(value, id, true) do
    list = List.wrap(value)
    next = if id in list, do: List.delete(list, id), else: list ++ [id]
    {next, false}
  end

  def toggle(_value, id, _single), do: {id, true}

  @doc """
  The text a trigger shows for a value.

      iex> MishkaMob.Components.MishkaSelect.display(nil, [], "Pick one")
      "Pick one"
      iex> MishkaMob.Components.MishkaSelect.display(:a, [{:a, "Alpha"}], "Pick one")
      "Alpha"
      iex> MishkaMob.Components.MishkaSelect.display([:a, :b], [{:a, "Alpha"}, {:b, "Beta"}], "x")
      "Alpha, Beta"
      iex> MishkaMob.Components.MishkaSelect.display([], [{:a, "Alpha"}], "Pick one")
      "Pick one"
  """
  @spec display(term(), [{term(), String.t()}], String.t()) :: String.t()
  def display(value, labels, placeholder) do
    chosen =
      value
      |> List.wrap()
      |> Enum.map(fn id -> labels |> Enum.find(&(elem(&1, 0) == id)) |> label_of(id) end)

    if chosen == [], do: placeholder, else: Enum.join(chosen, ", ")
  end

  # An id with no matching option falls back to its own name rather than
  # vanishing, so a stale value is visible instead of silently blank.
  defp label_of(nil, id), do: to_string(id)
  defp label_of({_option_id, label}, _id), do: label

  @doc "The select node: a trigger, and the option list when open."
  @spec select(map() | keyword(), [map()]) :: map()
  def select(props \\ %{}, children \\ []) do
    props = Map.new(props)
    options = children |> Enum.filter(&match?(%{type: @option}, &1)) |> Enum.map(& &1.props)
    labels = Enum.map(options, &{Map.get(&1, :id), Map.get(&1, :label)})
    label = Map.get(props, :label)

    ~MOB"""
    <Column fill_width={true}>
      <Text text={label} text_size={:sm} text_color={:muted} :if={is_binary(label)} />
      <Spacer size={6} :if={is_binary(label)} />
      {trigger(props, labels)}
      <Spacer size={6} :if={open?(props)} />
      {list(props, options)}
    </Column>
    """
  end

  defp open?(props), do: truthy?(Map.get(props, :open, false))

  defp trigger(props, labels) do
    disabled? = truthy?(Map.get(props, :disabled, false))
    chosen? = List.wrap(Map.get(props, :value)) != []
    text = display(Map.get(props, :value), labels, Map.get(props, :placeholder, "Select…"))

    color =
      cond do
        disabled? -> :muted
        chosen? -> :on_surface
        true -> :muted
      end

    node = ~MOB"""
    <Box
      fill_width={true}
      background={:surface}
      corner_radius={:radius_sm}
      padding={:space_sm}
      border_color={:border}
      border_width={1}
    >
      <Row fill_width={true}>
        <Text text={text} text_size={:base} text_color={color} />
        <Spacer weight={1} />
        <Text text={if(open?(props), do: "▴", else: "▾")} text_size={:base} text_color={color} />
      </Row>
    </Box>
    """

    case handler(props, :on_toggle, disabled?) do
      nil -> node
      tap -> %{node | props: Map.put(node.props, :on_tap, tap)}
    end
  end

  # Built on the Menu surface so a select and a menu agree on what a list of
  # choices looks like. A chosen option is ticked, which is the only affordance
  # a multi-select really needs.
  defp list(props, options) do
    if open?(props) and options != [] do
      chosen = List.wrap(Map.get(props, :value))

      items =
        Enum.map(options, fn option ->
          id = Map.get(option, :id)
          ticked = if id in chosen, do: "✓", else: nil

          MishkaMenu.item(id, Map.get(option, :label),
            icon: ticked,
            disabled: truthy?(Map.get(option, :disabled, false))
          )
        end)

      MishkaMenu.menu(
        %{open: true, on_select: Map.get(props, :on_select)},
        items
      )
    else
      ~MOB(<Column />)
    end
  end

  defp handler(_props, _key, true), do: nil
  defp handler(props, key, _), do: Event.handler(Map.get(props, key))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
