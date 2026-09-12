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

  Not ported: `id` and the `*_class` attrs.
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

    ~MOB"""
    <Column fill_width={true}>
      <Column fill_width={true} :if={body != []}>
        {body}
        <Spacer size={10} />
      </Column>
      {control(props, expanded?)}
    </Column>
    """
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

    node = ~MOB"""
    <Box padding_top={pad} padding_bottom={pad} fill_width={false}>
      <Text text={text} text_size={:base} text_color={color} />
    </Box>
    """

    case Event.handler(Map.get(props, :on_toggle)) do
      nil -> node
      tap -> %{node | props: Map.put(node.props, :on_tap, tap)}
    end
  end

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
