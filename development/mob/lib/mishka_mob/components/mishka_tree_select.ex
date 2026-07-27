defmodule MishkaMob.Components.MishkaTreeSelect do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Tree Select** — a trigger
  showing the current selection, and a tree that opens beneath it.

  A thin shell, exactly as on the web: it owns the trigger and the panel, and
  whatever you put inside is the panel's content — normally a
  `MishkaMob.Components.MishkaTree`.

  The panel is rendered **in flow** rather than in a popover, for the reason
  given in `MishkaMob.Components.MishkaColorInput`: Mob has no anchored-overlay
  primitive, and on a phone a floating panel would cover the trigger it belongs
  to.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | The current selection. Falls back to `placeholder`. |
  | `placeholder` | string | `"Select…"` | Shown when nothing is selected. |
  | `open` | boolean | `false` | Whether the panel is shown. |
  | `disabled` | boolean | `false` | Mutes and unwires. |
  | `on_toggle` | event tag (atom) | — | `{:tap, tag}` on the trigger. |

  Children are the panel's content.

  Not ported: Escape / click-away dismissal (a panel in flow has nothing to
  click away from) and `id` / `*_class`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaTreeSelect>`). Children become the panel."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: tree_select(props, children)

  @doc """
  The tree select.

      <MishkaTreeSelect
        label={@picked}
        open={@open}
        on_toggle={:toggle}
      >{[tree(nodes: @nodes)]}</MishkaTreeSelect>
  """
  @spec tree_select(map() | keyword(), [map()]) :: map()
  def tree_select(props \\ %{}, children \\ []) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))
    open? = truthy?(Map.get(props, :open, false))

    ~MOB"""
    <Column fill_width={true}>
      {trigger(props, open?, disabled?)}
      {panel(children, open?)}
    </Column>
    """
  end

  defp trigger(props, open?, disabled?) do
    selected = Map.get(props, :label)
    text = if is_binary(selected) and selected != "", do: selected, else: placeholder(props)
    ink = cond_ink(disabled?, is_binary(selected) and selected != "")
    glyph = if open?, do: "▴", else: "▾"

    ~MOB"""
    <Box
      fill_width={true}
      background={:surface}
      corner_radius={:radius_md}
      padding={:space_md}
      border_color={:border}
      border_width={1}
    >
      <Row fill_width={true} align={:center}>
        <Text text={text} text_size={:base} text_color={ink} />
        <Spacer weight={1} />
        <Text text={glyph} text_size={:sm} text_color={:muted} />
      </Row>
    </Box>
    """
    |> put(:on_tap, if(disabled?, do: nil, else: Event.handler(Map.get(props, :on_toggle))))
  end

  defp panel(_children, false), do: nil

  defp panel(children, true) do
    ~MOB"""
    <Column fill_width={true}>
      <Spacer size={8} />
      <Box
        fill_width={true}
        background={:surface}
        corner_radius={:radius_md}
        padding={:space_sm}
        border_color={:border}
        border_width={1}
      >
        <Column fill_width={true}>
          {children}
        </Column>
      </Box>
    </Column>
    """
  end

  defp placeholder(props), do: Map.get(props, :placeholder, "Select…")

  # Muted when disabled, muted when it is only a placeholder, ink when chosen.
  defp cond_ink(true, _chosen?), do: :muted
  defp cond_ink(_disabled?, true), do: :on_surface
  defp cond_ink(_disabled?, _chosen?), do: :muted

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
