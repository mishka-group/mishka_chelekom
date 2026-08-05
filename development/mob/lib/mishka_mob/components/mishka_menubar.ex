defmodule MishkaMob.Components.MishkaMenubar do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Menubar** — a bar of menus
  where at most one is open at a time.

  ## What survives the trip, and what does not

  A menubar is defined by two behaviours. One is *exclusivity*: opening a menu
  closes the one before it, so the bar never shows two popups. That is state, it
  ports exactly, and `open_menu/2` expresses it.

  The other is *hover switching*: with a menu already open, moving the pointer
  to another trigger switches to it without a click. That one has no meaning
  here — there is no pointer, and a finger is either down or not. So every menu
  opens on tap, which is what a touch menubar does anyway.

  The panel is rendered in flow beneath the bar. That used to be because Mob had
  no anchored overlay at all; it has one now — the `:anchored` node
  (`MishkaMob.Components.Anchored`), which `MishkaMob.Components.MishkaPopover`
  is built on — and the menubar has simply not been moved onto it. It draws
  through `MishkaMob.Components.MishkaMenu`, which is unchanged. `:anchored` is
  Android-only so far; on iOS the node falls through to a column, which is the
  stacked shape the bar already has.

  ## Menus

  A menu is `%{label:, value:, items: [...], disabled:}`, and an item is
  `%{label:, value:, disabled:}` or `:separator`.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `menus` | list of menu maps | `[]` | The bar. |
  | `open` | value | `nil` | Which menu is open. |
  | `disabled` | boolean | `false` | Disables the whole bar. |
  | `on_open` | event tag (atom) | — | `{:tap, {tag, menu_value}}` on a trigger. |
  | `on_select` | event tag (atom) | — | `{:tap, {tag, item_value}}` on an item. |

  Not ported: roving tabindex and the arrow-key/Home/End navigation, `loop`,
  `modal`, and `orientation: vertical` (a vertical menubar is a
  `MishkaMob.Components.MishkaMenu`).
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaMenubar />`). Delegates to `menubar/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: menubar(props)

  @doc """
  The menubar.

      menubar(menus: @menus, open: @open, on_open: :open, on_select: :pick)
  """
  @spec menubar(map() | keyword()) :: map()
  def menubar(props \\ %{}) do
    props = Map.new(props)
    menus = List.wrap(Map.get(props, :menus, []))
    open = Map.get(props, :open)

    triggers = Enum.map(menus, &trigger(&1, open, props))

    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true} align={:center}>
        {triggers}
      </Row>
      {panel(menus, open, props)}
    </Column>
    """
  end

  @doc """
  The value that should be open after tapping `value` — the exclusivity rule.

  Tapping the open menu closes it; tapping any other switches straight to it,
  never leaving two open.

      iex> MishkaMob.Components.MishkaMenubar.open_menu(:file, nil)
      :file

      iex> MishkaMob.Components.MishkaMenubar.open_menu(:file, :file)
      nil

      iex> MishkaMob.Components.MishkaMenubar.open_menu(:edit, :file)
      :edit
  """
  @spec open_menu(term(), term()) :: term() | nil
  def open_menu(value, current), do: if(value == current, do: nil, else: value)

  defp trigger(menu, open, props) do
    open? = menu.value == open
    disabled? = disabled?(props) or truthy?(Map.get(menu, :disabled, false))
    ink = if disabled?, do: :muted, else: :on_surface

    node =
      ~MOB"""
      <Box
        background={if(open?, do: :surface_raised, else: :transparent)}
        corner_radius={:radius_sm}
        padding={:space_sm}
      >
        <Text text={menu.label} text_size={:base} text_color={ink} />
      </Box>
      """
      |> put(:on_tap, tag_handler(props, :on_open, menu.value, disabled?))

    ~MOB"""
    <Row>
      {node}
      <Spacer size={4} />
    </Row>
    """
  end

  defp panel(menus, open, props) do
    case Enum.find(menus, &(&1.value == open)) do
      nil ->
        nil

      menu ->
        rows = menu |> Map.get(:items, []) |> List.wrap() |> Enum.map(&item(&1, props))

        ~MOB"""
        <Column fill_width={true}>
          <Spacer size={6} />
          <Box
            fill_width={true}
            background={:surface}
            corner_radius={:radius_md}
            padding={:space_sm}
            border_color={:border}
            border_width={1}
          >
            <Column fill_width={true}>
              {rows}
            </Column>
          </Box>
        </Column>
        """
    end
  end

  defp item(:separator, _props) do
    ~MOB"""
    <Column fill_width={true}>
      <Spacer size={4} />
      <Divider />
      <Spacer size={4} />
    </Column>
    """
  end

  defp item(entry, props) do
    disabled? = disabled?(props) or truthy?(Map.get(entry, :disabled, false))
    ink = if disabled?, do: :muted, else: :on_surface

    ~MOB"""
    <Box fill_width={true} corner_radius={:radius_sm} padding={6}>
      <Row fill_width={true} align={:center}>
        <Text text={entry.label} text_size={:base} text_color={ink} />
        <Spacer weight={1} />
        {shortcut(entry)}
      </Row>
    </Box>
    """
    |> put(:on_tap, tag_handler(props, :on_select, entry.value, disabled?))
  end

  defp shortcut(entry) do
    case Map.get(entry, :shortcut) do
      nil -> nil
      text -> ~MOB(<Text text={text} text_size={:sm} text_color={:muted} />)
    end
  end

  defp tag_handler(_props, _key, _value, true), do: nil

  defp tag_handler(props, key, value, _disabled?) do
    case Map.get(props, key) do
      nil -> nil
      tag -> Event.handler(tag, value)
    end
  end

  defp disabled?(props), do: truthy?(Map.get(props, :disabled, false))

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
