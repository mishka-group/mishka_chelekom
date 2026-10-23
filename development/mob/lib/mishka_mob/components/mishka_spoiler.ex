defmodule MishkaMob.Components.MishkaSpoiler do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Spoiler** — long content that
  starts collapsed behind a "Show more" control.

  ## Not a Collapsible with different words

  They share a mechanism and differ in intent, which changes the markup:

    * `MishkaMob.Components.MishkaCollapsible` hides content behind a **titled
      header** — the header is the thing you read first, and the content is
      secondary.
    * A spoiler shows content that is **already the point** and merely too long,
      behind a control that sits *underneath* it and changes label as it works
      ("Show more" / "Show less").

  So the control is rendered last, not first, and it is a text link rather than a
  panel header.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `expanded` | boolean | `false` | Whether the content is revealed. |
  | `show_label` | string | `"Show more"` | Control label while collapsed. |
  | `hide_label` | string | `"Show less"` | Control label while expanded. |
  | `preview` | list of nodes | `[]` | What to show while collapsed (e.g. a truncated line). |
  | `on_toggle` | event tag (atom) | — | Sent as `{:tap, tag}`. |
  | `color` | color token / ARGB int | `:primary` | Control colour. |
  | `padding` | number | `10` | Vertical padding around the control — it is the tap target, not decoration. |
  | `id` | string | `nil` | Test tag on the root. The shown text is `<id>-preview` or `<id>-content`, the control `<id>-control`, its label `<id>-label`. |

  Not ported: the `*_class` attrs. `id` is not the DOM anchor the web means by
  it; it is the test tag, and what a device test needs is which of preview and
  content is on screen, and what the control says.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaSpoiler>`). Children are the content."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: spoiler(props, children)

  @doc """
  The spoiler node. `content` is revealed when expanded.

      spoiler([expanded: @open?, on_toggle: :more], long_text())
  """
  @spec spoiler(map() | keyword(), [map()]) :: map()
  def spoiler(props \\ %{}, content \\ []) do
    props = Map.new(props)
    expanded? = truthy?(Map.get(props, :expanded, false))
    body = if expanded?, do: content, else: List.wrap(Map.get(props, :preview, []))
    id = Map.get(props, :id)

    ~MOB"""
    <Column fill_width={true}>
      {shown(body, id, expanded?)}
      {control(props, expanded?)}
    </Column>
    """
    |> put(:id, id)
  end

  @doc """
  The test tag on what the spoiler is showing, given its `id`: `-content` once
  expanded, `-preview` while collapsed.

  Collapsed content is not in the tree at all (the preview replaces it), so which
  of the two exists is the answer to "is it open".

      iex> MishkaMob.Components.MishkaSpoiler.shown_tag("more", false)
      "more-preview"
      iex> MishkaMob.Components.MishkaSpoiler.shown_tag("more", true)
      "more-content"
      iex> MishkaMob.Components.MishkaSpoiler.shown_tag(nil, true)
      nil
  """
  @spec shown_tag(id :: String.t() | nil, expanded? :: boolean()) :: String.t() | nil
  def shown_tag(nil, _expanded?), do: nil
  def shown_tag(id, true), do: "#{id}-content"
  def shown_tag(id, _collapsed), do: "#{id}-preview"

  @doc """
  The test tag on the control, the padded tap target, given the spoiler's `id`.

      iex> MishkaMob.Components.MishkaSpoiler.control_tag("more")
      "more-control"
  """
  @spec control_tag(id :: String.t() | nil) :: String.t() | nil
  def control_tag(nil), do: nil
  def control_tag(id), do: "#{id}-control"

  @doc """
  The test tag on the control's label.

      iex> MishkaMob.Components.MishkaSpoiler.label_tag("more")
      "more-label"
  """
  @spec label_tag(id :: String.t() | nil) :: String.t() | nil
  def label_tag(nil), do: nil
  def label_tag(id), do: "#{id}-label"

  # Nothing at all when there is nothing to show, rather than an empty column that
  # still reserves the spacer's height.
  defp shown([], _id, _expanded?), do: nil

  defp shown(body, id, expanded?) do
    ~MOB"""
    <Column fill_width={true}>
      {body}
      <Spacer size={10} />
    </Column>
    """
    |> put(:id, shown_tag(id, expanded?))
  end

  @doc """
  The control's label for a state — the whole of the "changes as it works" rule.

      iex> MishkaMob.Components.MishkaSpoiler.label(%{}, false)
      "Show more"
      iex> MishkaMob.Components.MishkaSpoiler.label(%{}, true)
      "Show less"
      iex> MishkaMob.Components.MishkaSpoiler.label(%{show_label: "Read on"}, false)
      "Read on"
  """
  @spec label(map() | keyword(), boolean()) :: String.t()
  def label(props, expanded?) do
    props = Map.new(props)

    if expanded?,
      do: Map.get(props, :hide_label) || "Show less",
      else: Map.get(props, :show_label) || "Show more"
  end

  # A text control, not a panel header: it belongs to the content above it.
  #
  # Wrapped in a padded Box because a line of :base text is a ~20 dp tap target,
  # less than half the ~44 dp both platforms ask for — the same complaint
  # MishkaActionIcon's `size` default exists to prevent. The padding is VERTICAL
  # only, so the label still sits flush with the content above it, and
  # fill_width={false} keeps the target on the words rather than spanning the
  # row, where a stray tap anywhere on the line would toggle it.
  defp control(props, expanded?) do
    text = label(props, expanded?)
    color = Map.get(props, :color) || :primary
    pad = Map.get(props, :padding) || 10

    id = Map.get(props, :id)

    label =
      put(~MOB(<Text text={text} text_size={:base} text_color={color} />), :id, label_tag(id))

    ~MOB"""
    <Box padding_top={pad} padding_bottom={pad} fill_width={false}>
      {label}
    </Box>
    """
    |> put(:on_tap, Event.handler(Map.get(props, :on_toggle)))
    |> put(:id, control_tag(id))
  end

  # A prop left out is a prop the node never carries: `nil` serialises as the
  # string "nil", and the bridge would tag the node with it.
  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
