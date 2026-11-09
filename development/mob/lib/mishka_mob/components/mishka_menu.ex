defmodule MishkaMob.Components.MishkaMenu do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Menu** — a list of actions
  revealed from a trigger.

  Builds on `MishkaMob.Components.MishkaPopover.panel/2`, so a menu and a popover
  are the same surface with the same radius, border and padding; the menu adds
  the item list, separators and labels.

  `menu/2` is **placed by the caller** — under its trigger in a `Column`, or
  inside a `MishkaMob.Components.MishkaDrawer` for a bottom-sheet action list,
  which is often the better phone idiom anyway. `dropdown/4` is the anchored
  form: the trigger stays in flow and the panel is drawn in its own window, over
  the page, on the `:anchored` node (`MishkaMob.Components.Anchored`), so opening
  it does not push the page down.

  ## Items are children, and rows are left-aligned

  `item/3`, `separator/0` and `label/1` build the children. Rows are tappable
  boxes rather than Buttons for the reason the Drawer and Accordion document: a
  Material Button centres its label, and a menu reads from the leading edge.

  A `danger: true` item is tinted so a destructive action does not look like the
  rest — the one visual distinction a menu genuinely needs.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `open` | boolean | `false` | Whether the menu is shown. |
  | `on_select` | event tag (atom) | — | Sent as `{:tap, {tag, item_id}}`. |
  | `width` | number | `nil` | Panel width. |
  | `danger_color` | color token / ARGB int | `0xFFDC2626` | Destructive item colour. |
  | plus everything `MishkaMob.Components.MishkaPopover` accepts | | | |

  Not ported: `open_on_hover`, `delay` and the `id` / `*_class` attrs. A touch
  screen has no hover. `dropdown/4` takes the side, align and offsets as
  options; `menu/2` itself takes no placement because the caller places it.

  **Documentation:** https://mishka.tools/chelekom/docs/mob/menu
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Anchored, Event, MishkaPopover}

  @item :mishka_menu_item
  @sep :mishka_menu_separator
  @label :mishka_menu_label
  @checkbox :mishka_menu_checkbox
  @radio :mishka_menu_radio
  @submenu :mishka_menu_submenu

  @slot_types [@item, @sep, @label, @checkbox, @radio, @submenu]

  # How far a submenu's rows sit in from their trigger.
  @indent 16

  @doc "Composite expander (`<MishkaMenu>`). Children are items."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: menu(props, children)

  @doc """
  Build one action row. Options: `:disabled`, `:danger`, `:icon`, `:test_id`.

  `:id` is the EVENT tag — what `on_select` reports. `:test_id` is separate and
  becomes the row's native testTag, because a device test otherwise has nothing
  to address a row by but its label, and labels repeat across a page.
  """
  @spec item(term(), String.t(), keyword()) :: map()
  def item(id, label, opts \\ []) do
    %{
      type: @item,
      props: %{
        id: id,
        label: label,
        icon: Keyword.get(opts, :icon),
        disabled: Keyword.get(opts, :disabled, false),
        danger: Keyword.get(opts, :danger, false),
        on_tap: Keyword.get(opts, :on_tap),
        test_id: Keyword.get(opts, :test_id)
      },
      children: []
    }
  end

  @doc "A divider between groups of items."
  @spec separator() :: map()
  def separator, do: %{type: @sep, props: %{}, children: []}

  @doc """
  A small heading above a group of items. Option: `:test_id`, the heading's native
  testTag, so a device test can tell where a group starts.
  """
  @spec label(String.t(), keyword()) :: map()
  def label(text, opts \\ []) do
    node = %{type: @label, props: %{text: text}, children: []}

    # Left off when absent, so an untagged heading never carries `test_id: nil`
    # (which `item/3` documents reaching the bridge as the testTag "nil").
    put(node, :test_id, Keyword.get(opts, :test_id))
  end

  @doc """
  A row that carries a tick. Options: `:checked`, `:disabled`, `:test_id`.

      checkbox(:grid, "Show grid", checked: true)
  """
  @spec checkbox(term(), String.t(), keyword()) :: map()
  def checkbox(id, label, opts \\ []) do
    %{
      type: @checkbox,
      props: %{
        id: id,
        label: label,
        checked: Keyword.get(opts, :checked, false),
        disabled: Keyword.get(opts, :disabled, false),
        test_id: Keyword.get(opts, :test_id)
      },
      children: []
    }
  end

  @doc """
  One choice in a named group. Options: `:checked`, `:disabled`, `:test_id`.

  `name` groups rows that select one another out — it is carried through to the
  event so a screen can tell which group moved.

      radio(:by_name, "Name", "sort", checked: true)
  """
  @spec radio(term(), String.t(), String.t(), keyword()) :: map()
  def radio(id, label, name, opts \\ []) do
    %{
      type: @radio,
      props: %{
        id: id,
        label: label,
        name: name,
        checked: Keyword.get(opts, :checked, false),
        disabled: Keyword.get(opts, :disabled, false),
        test_id: Keyword.get(opts, :test_id)
      },
      children: []
    }
  end

  @doc """
  A nested group. Its children are the rows it reveals.

  Options: `:open`, `:disabled`, `:test_id`.

      submenu(:share, "Share", open: @sub == :share, rows: [item(:link, "Copy link")])

  On the web a submenu flies out sideways on hover. There is no hover on a
  touch screen and no room beside a phone-width panel, so this opens **inline**:
  the trigger stays put and its rows appear underneath, indented. Same
  information, no second surface to chase.
  """
  @spec submenu(term(), String.t(), keyword()) :: map()
  def submenu(id, label, opts \\ []) do
    %{
      type: @submenu,
      props: %{
        id: id,
        label: label,
        open: Keyword.get(opts, :open, false),
        disabled: Keyword.get(opts, :disabled, false),
        test_id: Keyword.get(opts, :test_id)
      },
      children: Keyword.get(opts, :rows, [])
    }
  end

  @doc """
  The menu node. Renders nothing when closed.

      <MishkaMenu
        open={@open?}
        on_select={:pick}
      >{[
        item(:edit, "Edit"),
        separator(),
        item(:delete, "Delete", danger: true)
      ]}</MishkaMenu>
  """
  @spec menu(map() | keyword(), [map()]) :: map()
  def menu(props \\ %{}, children \\ []) do
    props = Map.new(props)

    if truthy?(Map.get(props, :open, false)) do
      MishkaPopover.panel(Map.put_new(props, :padding, 6), rows(children, props))
    else
      ~MOB(<Column />)
    end
  end

  @doc """
  An anchored dropdown: the trigger in the page, the panel in its own window.

  `menu/2` is placed by the caller — a column under its trigger, or a row in a
  drawer. A dropdown has to float over the page instead, so this function uses
  the same `Anchored` node `MishkaPopover` uses: the trigger stays in flow, the
  panel is drawn in its own window, and a tap outside it reports `on_dismiss`.

  The caller keeps the trigger's own `on_tap`; the trigger stays in flow and
  only the panel is drawn over the page.

  Panel defaults are the dropdown shape: 250 wide, card fill, radius 18, no
  border, 6pt above and below the rows. `shadow` is the one panel prop a menu
  usually needs and `MishkaPopover.panel/2` did not carry before this.

  On iOS the anchored primitive is not implemented; this degrades to the
  stacked arrangement Mob gives an unknown node type. That is the same platform
  limit the other anchored components have.

  ## Options

  * `:width`, `:background`, `:corner_radius`, `:border_width`, `:shadow`
  * `:padding_top`, `:padding_bottom`, `:padding_left`, `:padding_right`
  * `:side`, `:align`, `:side_offset`, `:on_dismiss`
  * `:danger_color`
  * item geometry: `:item_height`, `:item_padding_x`, `:item_padding_y`,
    `:item_icon_gap`, `:item_text_size`, `:item_font_weight`,
    `:item_label_weight`, `:item_corner_radius`, `:item_text_color`,
    `:item_max_lines`
  * separator: `:separator_color`, `:separator_thickness`,
    `:separator_padding_y`, `:separator_padding_x`
  """
  @spec dropdown(map(), boolean(), [map()], keyword() | map()) :: map()
  def dropdown(trigger, open?, children, opts \\ []) do
    opts = Map.new(opts)

    if truthy?(open?) do
      panel =
        MishkaPopover.panel(
          %{
            width: Map.get(opts, :width) || 250,
            background: Map.get(opts, :background) || :surface,
            corner_radius: Map.get(opts, :corner_radius) || 18,
            padding: 0,
            padding_top: Map.get(opts, :padding_top, 6),
            padding_right: Map.get(opts, :padding_right, 0),
            padding_bottom: Map.get(opts, :padding_bottom, 6),
            padding_left: Map.get(opts, :padding_left, 0),
            border_width: Map.get(opts, :border_width, 0),
            shadow: Map.get(opts, :shadow)
          },
          rows(children, opts)
        )

      Anchored.anchor(trigger, panel,
        side: Map.get(opts, :side) || :bottom,
        align: Map.get(opts, :align) || :end,
        side_offset: Map.get(opts, :side_offset) || 8,
        on_dismiss: Map.get(opts, :on_dismiss)
      )
    else
      Anchored.closed(trigger)
    end
  end

  # Rows keep their written order, so this is one ordered pass rather than a
  # filter per kind. A submenu recurses into its own children — the only place
  # in this library where a slot tag nests inside another, which works because
  # a slot tag has no expander and therefore arrives with its subtree intact.
  defp rows(children, props) do
    Enum.map(children, &row(&1, props))
  end

  defp row(%{type: @sep}, props) do
    py = Map.get(props, :separator_padding_y) || 6
    px = Map.get(props, :separator_padding_x) || 0
    color = Map.get(props, :separator_color) || :border
    thickness = Map.get(props, :separator_thickness) || 1

    ~MOB"""
    <Column
      fill_width={true}
      padding_top={py}
      padding_bottom={py}
      padding_left={px}
      padding_right={px}
    >
      <Box fill_width={true} height={thickness} background={color} />
    </Column>
    """
  end

  defp row(%{type: @label, props: p}, _props) do
    text = Map.get(p, :text)

    ~MOB"""
    <Box fill_width={true} padding={:space_sm}>
      <Text text={text} text_size={:xs} text_color={:muted} />
    </Box>
    """
    |> put(:id, Map.get(p, :test_id))
  end

  defp row(%{type: @item, props: item}, props) do
    disabled? = truthy?(Map.get(item, :disabled, false))
    icon = Map.get(item, :icon)
    danger? = truthy?(Map.get(item, :danger, false))

    color =
      cond do
        disabled? -> :muted
        danger? -> Map.get(props, :danger_color) || :error
        true -> Map.get(props, :item_text_color) || :on_surface
      end

    height = Map.get(props, :item_height)

    box_props =
      %{fill_width: true}
      |> put_some(:height, height)
      |> put_some(:align, if(height, do: Map.get(props, :item_align) || :center))
      |> put_some(:corner_radius, Map.get(props, :item_corner_radius) || :radius_sm)
      |> item_padding(props)

    row_children = icon_nodes(icon, color, props) ++ [item_label(item, color, props)]

    # `test_id` is merged rather than interpolated. An item built without one
    # carries `test_id: nil`, an inline `id={nil}` still lands in the props map,
    # and `:json` encodes an atom as a string — so every untagged row reached
    # the bridge with the testTag "nil", and a test looking for one row found
    # whichever came first.
    node =
      %{
        type: :box,
        props: box_props,
        children: [%{type: :row, props: %{fill_width: true}, children: row_children}]
      }
      |> put(:id, Map.get(item, :test_id))

    put(node, :on_tap, tap(props, item, disabled?))
  end

  defp row(%{type: @checkbox, props: item}, props) do
    mark(item, props, if(truthy?(Map.get(item, :checked, false)), do: "✓", else: " "))
  end

  defp row(%{type: @radio, props: item}, props) do
    mark(item, props, if(truthy?(Map.get(item, :checked, false)), do: "●", else: "○"))
  end

  defp row(%{type: @submenu, props: sub, children: rows}, props) do
    open? = truthy?(Map.get(sub, :open, false))
    disabled? = truthy?(Map.get(sub, :disabled, false))

    trigger =
      %{
        type: @item,
        props: %{
          id: Map.get(sub, :id),
          label: Map.get(sub, :label),
          icon: if(open?, do: "▾", else: "▸"),
          disabled: disabled?,
          danger: false,
          test_id: submenu_tag(Map.get(sub, :test_id), open?)
        },
        children: []
      }
      |> row(props)

    # A local, not @indent: inside ~MOB a leading @ means an ASSIGN, so the
    # module attribute is rewritten to assigns.indent and blows up at compile
    # time with a message that names the sigil rather than the attribute.
    indent = @indent

    nested =
      if open? and rows != [] do
        [
          ~MOB"""
          <Row fill_width={true}>
            <Spacer size={indent} />
            <Column fill_width={true}>
              {rows(rows, props)}
            </Column>
          </Row>
          """
        ]
      else
        []
      end

    ~MOB"""
    <Column fill_width={true}>
      {[trigger | nested]}
    </Column>
    """
  end

  defp row(other, _props), do: other

  defp icon_nodes(nil, _color, _props), do: []

  defp icon_nodes(icon, color, props) when is_binary(icon) do
    text = %{
      type: :text,
      props: %{
        text: icon,
        text_size: Map.get(props, :item_text_size) || :base,
        text_color: color
      },
      children: []
    }

    [text, spacer(Map.get(props, :item_icon_gap) || 10)]
  end

  defp icon_nodes(icon, _color, props) when is_map(icon) or is_list(icon) do
    List.wrap(icon) ++ [spacer(Map.get(props, :item_icon_gap) || 10)]
  end

  defp item_label(item, color, props) do
    %{
      type: :text,
      props: %{
        text: Map.get(item, :label) || "",
        text_size: Map.get(props, :item_text_size) || :base,
        text_color: color
      },
      children: []
    }
    |> put(:font_weight, Map.get(props, :item_font_weight))
    |> put(:max_lines, Map.get(props, :item_max_lines))
    |> put(:weight, Map.get(props, :item_label_weight))
  end

  defp item_padding(map, props) do
    px = Map.get(props, :item_padding_x)
    py = Map.get(props, :item_padding_y)

    if is_nil(px) and is_nil(py) do
      Map.put(map, :padding, :space_sm)
    else
      map
      |> Map.put(:padding, 0)
      |> Map.put(:padding_left, px || 0)
      |> Map.put(:padding_right, px || 0)
      |> Map.put(:padding_top, py || 0)
      |> Map.put(:padding_bottom, py || 0)
    end
  end

  defp spacer(size), do: %{type: :spacer, props: %{size: size}, children: []}

  defp put_some(map, _key, nil), do: map
  defp put_some(map, key, value), do: Map.put(map, key, value)

  # Checkbox and radio rows are an item with an indicator glyph in the icon
  # slot — but the STATE also goes in the tag, because a glyph is not something
  # a device test can attribute to a row.
  defp mark(item, props, glyph) do
    checked? = truthy?(Map.get(item, :checked, false))

    %{
      type: @item,
      props: %{
        id: Map.get(item, :id),
        label: Map.get(item, :label),
        icon: glyph,
        disabled: Map.get(item, :disabled, false),
        danger: false,
        test_id: state_tag(Map.get(item, :test_id), checked?)
      },
      children: []
    }
    |> row(props)
  end

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp state_tag(nil, _checked?), do: nil
  defp state_tag(id, true), do: id <> "-checked"
  defp state_tag(id, false), do: id <> "-unchecked"

  defp submenu_tag(nil, _open?), do: nil
  defp submenu_tag(id, true), do: id <> "-open"
  defp submenu_tag(id, false), do: id <> "-closed"

  @doc """
  Every node type a menu consumes as a row — the slot tags plus their function
  equivalents. Exported so a test can prove none of them leaked to the renderer.
  """
  @spec slot_types() :: [atom()]
  def slot_types, do: @slot_types

  defp tap(_props, _item, true), do: nil

  # A row's own `on_tap` wins over the menu's `on_select`: a caller that gives
  # every row its own tag must not have it rewritten into `{on_select, item_id}`.
  # `on_select` remains the grouped form.
  defp tap(_props, %{on_tap: on_tap}, _disabled) when not is_nil(on_tap),
    do: Event.handler(on_tap)

  defp tap(props, item, _disabled) do
    case Event.handler(Map.get(props, :on_select)) do
      nil -> nil
      {pid, tag} -> {pid, {tag, Map.get(item, :id)}}
    end
  end

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
