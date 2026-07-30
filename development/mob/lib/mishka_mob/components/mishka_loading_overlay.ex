defmodule MishkaMob.Components.MishkaLoadingOverlay do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Loading Overlay** — a scrim
  over a region while it is busy.

  Two things make it an overlay rather than a spinner:

    * it **covers** its region, so the stale content underneath is visibly
      inert rather than half-usable, and
    * it **absorbs taps**, so a double submit is impossible while the work is in
      flight. That is the part a bare spinner cannot give you, and it is why the
      scrim carries a no-op handler (the same trick the Drawer's panel uses).

  The busy indicator is Mob's native indeterminate `Progress`, which animates on
  its own — and it is **linear**, because that is the only self-animating
  indicator the platform offers: `LinearProgressIndicator` on Android,
  `.progressViewStyle(.linear)` on iOS, with no circular option reachable from a
  Progress node. A canvas could draw a ring, but nothing would turn it.

  So the indicator and its label sit on a small **panel**. A lone thin bar
  centred on a large scrim reads as a stray divider rather than a loader; the
  panel is what makes it read as one. Pass `panel_color` to suit a dark scrim,
  or supply children and own the body entirely.

  The web component ships neither — its loader is the default slot ("provide the
  loader: a spinner, text, …") and it ships no styling at all. What is here is
  this port's default, not a translation of a web one.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `visible` | boolean | `false` | Whether the overlay is shown. |
  | `label` | string | `nil` | Text under the indicator. |
  | `scrim_color` | ARGB int / token | `0xCCFFFFFF` on light surfaces | Scrim fill. |
  | `panel_color` | color token / ARGB int | `:surface` | The panel behind the indicator. |
  | `color` | color token / ARGB int | `:primary` | Indicator colour. |
  | `corner_radius` | radius token / number | `nil` | Match the region it covers. |

  Children replace the indicator, panel and all.

  Not ported: `label` as an `aria-label` (it renders as visible text instead) and
  `id` / `*_class`.
  """

  import Mob.Sigil

  # A no-op the host screen's catch-all handle_info/2 swallows; its only job is
  # to give the scrim a hit-test shape so taps cannot reach what is underneath.
  @absorb :__mishka_loading_ignore
  @scrim 0xCC_FF_FF_FF

  # The indicator's width, the panel's padding, and so the panel's width. Fixed
  # rather than derived from the label: the panel must not resize as the caption
  # changes, or a busy state would visibly twitch.
  @bar 140
  @pad 18

  @doc "Composite expander (`<MishkaLoadingOverlay>`). Children replace the indicator."
  @spec expand(map(), [map()], %{screen: pid()}) :: map()
  def expand(props, children, ctx), do: loading_overlay(props, children, ctx)

  @doc """
  The overlay node. Renders nothing when not visible.

      <Box>
        {content}
        <MishkaLoadingOverlay visible={@saving?} />
      </Box>
  """
  @spec loading_overlay(map() | keyword(), [map()], map()) :: map()
  def loading_overlay(props \\ %{}, content \\ [], ctx \\ %{}) do
    props = Map.new(props)

    if truthy?(Map.get(props, :visible, false)) do
      scrim(props, content, ctx)
    else
      ~MOB(<Column />)
    end
  end

  defp scrim(props, content, ctx) do
    # Local, not `@scrim`: a module attribute inside a ~MOB expression is
    # rewritten to `assigns.scrim`.
    fill = Map.get(props, :scrim_color, @scrim)
    radius = Map.get(props, :corner_radius)

    node = ~MOB"""
    <Box
      fill_width={true}
      fill_height={true}
      align={:center}
      background={fill}
      corner_radius={radius}
    >
      {body(props, content)}
    </Box>
    """

    %{node | props: Map.put(node.props, :on_tap, absorb(ctx))}
  end

  # The indicator and its label sit on a panel, not loose on the scrim. Mob's
  # only self-animating busy indicator is a LINEAR bar — Progress is
  # `LinearProgressIndicator` on Android and `.progressViewStyle(.linear)` on
  # iOS, with no circular option reachable from a Progress node — and a lone
  # thin bar centred on a large scrim reads as a stray divider rather than a
  # loader. The panel is what makes it read as one.
  #
  # It carries an explicit width because a Box cannot hug: iOS `MobBox` falls to
  # `.frame(maxWidth: .infinity)` for anything without a fixed width, so a
  # hugging panel is not expressible cross-platform. A Row hugs on both, but its
  # corner_radius is clipped only on Android — square on iOS. Fixed width is the
  # one construction that behaves the same on both.
  defp body(props, []) do
    label = Map.get(props, :label)
    color = Map.get(props, :color, :primary)
    panel = Map.get(props, :panel_color, :surface)
    bar = @bar
    pad = @pad
    width = @bar + 2 * @pad

    ~MOB"""
    <Box width={width} padding={pad} align={:center} background={panel} corner_radius={:radius_lg}>
      <Column fill_width={true}>
        {centre(~MOB(<Box width={bar}>
          <Progress color={color} />
        </Box>))}
        {caption(label)}
      </Column>
    </Box>
    """
  end

  defp body(_props, content), do: ~MOB(<Column>
  {content}
</Column>)

  defp caption(label) when is_binary(label) do
    text =
      centre(~MOB"""
      <Text text={label} text_size={:sm} text_color={:muted} text_align={:center} />
      """)

    [~MOB(<Spacer size={10} />), text]
  end

  defp caption(_label), do: []

  # A Column cannot align its children — Android maps it to a bare Compose
  # Column with no horizontalAlignment, iOS to `VStack(alignment: .leading)`.
  # So the label used to left-align against the 140dp bar and sit visibly off
  # centre. Each part gets its own centring Box, the way MishkaEmptyState does.
  defp centre(node) do
    ~MOB"""
    <Box fill_width={true} align={:center}>
      {node}
    </Box>
    """
  end

  defp absorb(%{screen: pid}) when is_pid(pid), do: {pid, @absorb}
  defp absorb(_ctx), do: {self(), @absorb}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
