defmodule MishkaMob.Components.MishkaMenu do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Menu** — a list of actions
  revealed from a trigger.

  Builds on `MishkaMob.Components.MishkaPopover.panel/2`, so a menu and a popover
  are the same surface with the same radius, border and padding; the menu adds
  the item list, separators and labels.

  The menu is **placed by the caller** — under its trigger in a `Column` for a
  dropdown, or inside a `MishkaMob.Components.MishkaDrawer` for a bottom-sheet
  action list, which is often the better phone idiom anyway. This used to say
  Mob cannot anchor a floating panel to a trigger at all. It can: the Popover
  now draws its panel in its own window, over the page, on the `:anchored` node
  (`MishkaMob.Components.Anchored`). The menu has not been moved onto it, and it
  keeps the full-width shell it always had by passing `panel/2` no `fill_width`
  of its own.

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

  Not ported: `side`, `align`, offsets, `open_on_hover`, `delay` and the `id` /
  `*_class` attrs. A touch screen has no hover; the positioning props are absent
  because a menu is PLACED BY ITS CALLER and so has no side to take. Anchored
  overlays do exist now — `MishkaMob.Components.Anchored`, which `popover`,
  `tooltip` and `preview_card` are built on — this component simply has not been
  moved onto one.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Event, MishkaPopover}

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
        test_id: Keyword.get(opts, :test_id)
      },
      children: []
    }
  end

  @doc "A divider between groups of items."
  @spec separator() :: map()
  def separator, do: %{type: @sep, props: %{}, children: []}

  @doc "A small heading above a group of items."
  @spec label(String.t()) :: map()
  def label(text), do: %{type: @label, props: %{text: text}, children: []}

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

  # Rows keep their written order, so this is one ordered pass rather than a
  # filter per kind. A submenu recurses into its own children — the only place
  # in this library where a slot tag nests inside another, which works because
  # a slot tag has no expander and therefore arrives with its subtree intact.
  defp rows(children, props) do
    Enum.map(children, &row(&1, props))
  end

  defp row(%{type: @sep}, _props) do
    ~MOB"""
    <Column fill_width={true}>
      <Spacer size={6} />
      <Box fill_width={true} height={1} background={:border} />
      <Spacer size={6} />
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
  end

  defp row(%{type: @item, props: item}, props) do
    disabled? = truthy?(Map.get(item, :disabled, false))
    icon = Map.get(item, :icon)

    color =
      cond do
        disabled? -> :muted
        truthy?(Map.get(item, :danger, false)) -> Map.get(props, :danger_color) || :error
        true -> :on_surface
      end

    # `test_id` is merged rather than interpolated. An item built without one
    # carries `test_id: nil`, an inline `id={nil}` still lands in the props map,
    # and `:json` encodes an atom as a string — so every untagged row reached
    # the bridge with the testTag "nil", and a test looking for one row found
    # whichever came first.
    node =
      ~MOB"""
      <Box fill_width={true} padding={:space_sm} corner_radius={:radius_sm}>
        <Row fill_width={true}>
          <Text text={icon} text_size={:base} text_color={color} :if={is_binary(icon)} />
          <Spacer size={10} :if={is_binary(icon)} />
          <Text text={Map.get(item, :label) || ""} text_size={:base} text_color={color} />
        </Row>
      </Box>
      """
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
