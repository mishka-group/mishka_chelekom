defmodule MishkaMob.Components.MishkaTreeSelect do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Tree Select** — a trigger
  showing the current selection, and a tree that opens beneath it.

  A thin shell, exactly as on the web: it owns the trigger and the panel, and
  whatever you put inside is the panel's content — normally a
  `MishkaMob.Components.MishkaTree`. The tree keeps its own selection and its
  own expand/collapse, so wire its `on_select` to the screen and let the screen
  set `label` and close the panel.

  ## The panel is in flow, not floating

  The web anchors the panel to the trigger and dismisses it on Escape or on a
  click outside. This used to say Mob has no anchored-overlay primitive; it has
  one — the `:anchored` node (`MishkaMob.Components.Anchored`), which
  `MishkaMob.Components.MishkaPopover` is built on. A tree select does not use
  it: a tree is as tall as its data, and one floating over a phone covers the
  trigger it belongs to. So the panel renders in flow beneath the trigger, and
  nothing surrounds it to click away from. Tapping the trigger again is the
  dismissal — and an anchored panel would not have changed that either, because
  its window dismisses itself on nothing: no back-press, no outside tap. For a
  tree too large to sit in the page, hand the same tree to a bottom
  `MishkaMob.Components.MishkaDrawer`, which brings a scrim and a dismissal of
  its own.

  ## `id`, because the trigger's only text is yours

  Everything this component says about itself, it says in colour and in a glyph:
  a placeholder is muted where a real selection is not, and open is a ▴ where
  closed is a ▾. A device test can read neither. So `id` becomes a native
  testTag on each part, with the state folded into the name:

  | Tag | Part |
  |-----|------|
  | `<id>` | the root |
  | `<id>-trigger-open` / `-closed` / `-disabled` | the trigger — the web's `aria-expanded` |
  | `<id>-value` / `<id>-placeholder` | the value — the web's `data-placeholder` |
  | `<id>-caret` | the ▾ / ▴ |
  | `<id>-panel` | the panel, absent entirely while closed |

  A disabled trigger reports `-disabled` in place of its open state, because
  disabled is otherwise nothing but a muted ink; the panel's own tag still says
  whether it is showing.

  Give the tree inside its own `id` too. `MishkaMob.Components.MishkaTree`
  defaults its tag prefix to `"tree"`, so two tree selects on one page hand
  every row the same tag and a test can no longer say which panel it tapped.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | The current selection. Falls back to `placeholder`. |
  | `placeholder` | string | `"Select…"` | Shown when nothing is selected. |
  | `open` | boolean | `false` | Whether the panel is shown. |
  | `disabled` | boolean | `false` | Mutes and unwires the trigger. |
  | `on_toggle` | event tag (atom) | — | `{:tap, tag}` on the trigger. |
  | `id` | string | `nil` | Test tags for the trigger, the value, the caret and the panel. |

  Children are the panel's content.

  Not ported: Escape and click-away dismissal (a panel in flow has nothing to
  click away from), and the `*_class` attrs. There is nothing for a long press
  to carry either — the web original has no hover and no context menu, and the
  tree inside owns every gesture but the trigger's tap.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @placeholder "Select…"

  @doc "Composite expander (`<MishkaTreeSelect>`). Children become the panel."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: tree_select(props, children)

  @doc """
  The tree select.

      <MishkaTreeSelect
        label={@picked}
        open={@open}
        on_toggle={:toggle}
        id="ts-file"
      >{[tree(nodes: @nodes, id: "ts-file-tree", on_select: :pick)]}</MishkaTreeSelect>
  """
  @spec tree_select(map() | keyword(), [map()]) :: map()
  def tree_select(props \\ %{}, children \\ []) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))
    open? = truthy?(Map.get(props, :open, false))
    id = Map.get(props, :id)

    ~MOB"""
    <Column fill_width={true}>
      {trigger(props, id, open?, disabled?)}
      {panel(children, id, open?)}
    </Column>
    """
    |> put(:id, id)
  end

  @doc """
  The text a trigger shows for a label — the label itself, or the placeholder.

  An empty string is not a selection, which is the one case worth having a
  function for: it is what a form field hands back when it has been cleared.

      iex> MishkaMob.Components.MishkaTreeSelect.display(nil, "Pick one")
      "Pick one"
      iex> MishkaMob.Components.MishkaTreeSelect.display("", "Pick one")
      "Pick one"
      iex> MishkaMob.Components.MishkaTreeSelect.display("mix.exs", "Pick one")
      "mix.exs"
  """
  @spec display(term(), String.t()) :: String.t()
  def display(label, placeholder \\ @placeholder),
    do: if(chosen?(label), do: label, else: placeholder)

  defp trigger(props, id, open?, disabled?) do
    label = Map.get(props, :label)
    chosen? = chosen?(label)
    text = display(label, placeholder(props))

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
        {value(text, id, chosen?, disabled?)}
        <Spacer size={8} />
        {caret(id, open?, disabled?)}
      </Row>
    </Box>
    """
    |> put(:on_tap, if(disabled?, do: nil, else: Event.handler(Map.get(props, :on_toggle))))
    |> put(:id, trigger_tag(id, open?, disabled?))
  end

  # The value sits in a weighted Box and the caret does not, because Compose
  # measures a Row's unweighted children first: an unwrapped label took as much
  # width as its text wanted and left the caret nothing. max_lines is the other
  # half — a Text squeezed narrower than its content wraps character by
  # character, so a long path arrived as a column of single letters rather than
  # the one line the web ellipsises.
  defp value(text, id, chosen?, disabled?) do
    ink = if disabled? or not chosen?, do: :muted, else: :on_surface

    # The tag goes on the Text rather than the Box around it, so a device test
    # can ask one question — this tag, that text — instead of tag-then-descend.
    label =
      ~MOB"""
      <Text text={text} text_size={:base} text_color={ink} max_lines={1} />
      """
      |> value_tag(id, chosen?)

    ~MOB"""
    <Box weight={1}>
      {label}
    </Box>
    """
  end

  defp caret(id, open?, disabled?) do
    ink = if disabled?, do: :muted, else: :on_surface

    glyph = if open?, do: "▴", else: "▾"

    ~MOB"""
    <Text text={glyph} text_size={:sm} text_color={ink} />
    """
    |> put(:id, if(id, do: "#{id}-caret"))
  end

  defp panel(_children, _id, false), do: nil

  defp panel(children, id, true) do
    surface =
      ~MOB"""
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
      """
      |> put(:id, if(id, do: "#{id}-panel"))

    ~MOB"""
    <Column fill_width={true}>
      <Spacer size={8} />
      {surface}
    </Column>
    """
  end

  defp placeholder(props), do: Map.get(props, :placeholder) || @placeholder

  # The web's `@label not in [nil, ""]`: an empty string is what a cleared form
  # field hands back, and it is not a selection.
  defp chosen?(label), do: is_binary(label) and label != ""

  defp trigger_tag(nil, _open?, _disabled?), do: nil
  defp trigger_tag(id, _open?, true), do: "#{id}-trigger-disabled"
  defp trigger_tag(id, true, _disabled?), do: "#{id}-trigger-open"
  defp trigger_tag(id, _open?, _disabled?), do: "#{id}-trigger-closed"

  # The web marks the placeholder with data-placeholder; here the difference is
  # a muted ink, so it goes in the tag instead — a test cannot read a colour.
  defp value_tag(node, nil, _chosen?), do: node
  defp value_tag(node, id, true), do: put(node, :id, "#{id}-value")
  defp value_tag(node, id, _chosen?), do: put(node, :id, "#{id}-placeholder")

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
