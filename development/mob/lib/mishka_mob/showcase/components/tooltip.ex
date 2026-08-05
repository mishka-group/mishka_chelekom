defmodule MishkaMob.Showcase.Components.Tooltip do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaTooltip`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @controls [
    {:copy, "⧉", "Copy to clipboard"},
    {:share, "↗", "Share a link"},
    {:trash, "🗑", "Delete for everyone"}
  ]

  @dark_fill 0xFF_11_18_27

  @impl true
  def entry do
    %{
      slug: :tooltip,
      name: "Tooltip",
      category: "Overlays",
      order: 4,
      description: "A short hint about the control it wraps."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:tip_hold, nil)
    |> Mob.Socket.assign(:tip_tapped, nil)
    |> Mob.Socket.assign(:tip_soft, true)
    |> Mob.Socket.assign(:tip_sticky, true)
    |> Mob.Socket.assign(:tip_off, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Hold to reveal",
        description:
          "A phone has no hover, so the gesture is the one the platform already uses for " <>
            "reveal-more: press and hold. Hold again to put the hint away.",
        code: ~S"""
        <MishkaTooltip
          id="tip-copy"
          text="Copy to clipboard"
          open={@tip == :copy}
          side={:bottom}
          arrow={true}
          fill_width={false}
          on_open_change={{:hold, :copy}}
          on_tap={{:use, :copy}}
        >
          <MishkaActionIcon icon="⧉" variant={:filled} />
        </MishkaTooltip>

        # on_open_change carries the state the tooltip wants NEXT, so one clause
        # opens and closes, and a second hold on the same control puts it away.
        def handle_info({:tap, {{:hold, which}, open?}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :tip, if(open?, do: which, else: nil))}
        end

        # The control's own tap lives on the tooltip, not on the ActionIcon: a
        # clickable child would swallow the hold before the tooltip ever saw it.
        def handle_info({:tap, {:use, which}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :used, which)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              {held(@tip_hold)}
            </Row>
            <Spacer size={10} />
            <Text text={tapped(@tip_tapped)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Every side, with an arrow",
        description:
          "side puts the bubble above, below or beside the trigger and turns the arrow to " <>
            "match. It displaces the layout rather than floating over it — nothing here can " <>
            "measure a trigger's rectangle.",
        code: ~S"""
        <MishkaTooltip
          id="side-left"
          text="On the left"
          open={true}
          side={:left}
          arrow={true}
        >
          <MishkaActionIcon icon="●" variant={:filled} />
        </MishkaTooltip>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {sides()}
          </Column>
          """
        end
      },
      %Example{
        title: "Align, and the two offsets",
        description:
          "align places the bubble across the side, side_offset is the gap to the trigger " <>
            "and align_offset nudges along the alignment axis.",
        code: ~S"""
        <MishkaTooltip
          id="align-end"
          text="Pinned to the end"
          open={true}
          align={:end}
          side_offset={16}
          align_offset={-12}
        >
          <MishkaActionIcon icon="◆" variant={:filled} />
        </MishkaTooltip>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {alignments()}
          </Column>
          """
        end
      },
      %Example{
        title: "Tap the hint to dismiss",
        description:
          "The web closes on blur, pointer-leave or Escape. A phone has none of the three, " <>
            "so the bubble itself is the dismissal — unless close_on_tap says otherwise, and " <>
            "then only a second hold closes it.",
        code: ~S"""
        <MishkaTooltip
          id="dismiss-sticky"
          text="Only a second hold closes me"
          open={@sticky?}
          close_on_tap={false}
          on_open_change={:sticky}
        >
          <MishkaActionIcon icon="📌" variant={:filled} />
        </MishkaTooltip>

        # The same clause serves the bubble's tap and the trigger's hold: both
        # report the state they want, so the screen only has to store it.
        def handle_info({:tap, {:sticky, open?}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :sticky?, open?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaTooltip
              id="dismiss-soft"
              text="Tap me to close"
              open={@tip_soft}
              side={:bottom}
              fill_width={false}
              on_open_change={:tip_soft}
            >
              <MishkaActionIcon icon="✕" variant={:filled} />
            </MishkaTooltip>
            <Spacer size={20} />
            <MishkaTooltip
              id="dismiss-sticky"
              text="Hold to close"
              open={@tip_sticky}
              side={:bottom}
              fill_width={false}
              close_on_tap={false}
              on_open_change={:tip_sticky}
            >
              <MishkaActionIcon icon="📌" variant={:filled} />
            </MishkaTooltip>
            <Spacer weight={1} />
          </Row>
          """
        end
      },
      %Example{
        title: "Disabled",
        description:
          "The control still works and still taps. The hint is what is switched off, so no " <>
            "hold handler is wired and open cannot win.",
        code: ~S"""
        <MishkaTooltip
          id="tip-off"
          text="You will never see this"
          open={@off?}
          disabled={true}
          on_open_change={:off}
        >
          <MishkaActionIcon icon="🚫" variant={:filled} />
        </MishkaTooltip>

        # Wired, and still never called — disabled drops the handler rather
        # than ignoring the event, so nothing arrives to ignore.
        def handle_info({:tap, {:off, open?}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :off?, open?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTooltip
              id="tip-off"
              text="You will never see this"
              open={@tip_off}
              disabled={true}
              side={:bottom}
              fill_width={false}
              on_open_change={:tip_off}
            >
              <MishkaActionIcon icon="🚫" variant={:filled} />
            </MishkaTooltip>
            <Spacer size={10} />
            <Text text={off_state(@tip_off)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Colours, size and a static nudge",
        description:
          "Dark by default so it reads over any surface; a theme token restyles it without " <>
            "a hex. offset_x / offset_y shift the bubble without moving anything else.",
        code: ~S"""
        <MishkaTooltip
          id="style-token"
          text="Themed"
          open={true}
          background={:primary}
          color={:on_primary}
          text_size={:base}
          offset_x={12}
        >
          <MishkaActionIcon icon="◐" variant={:filled} />
        </MishkaTooltip>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {styles()}
          </Column>
          """
        end
      },
      %Example{
        title: "Without a trigger",
        description:
          "No children means the bare bubble, for a screen that places its own. Closed it " <>
            "contributes no node at all, so it takes no space in the layout.",
        code: ~S"""
        <MishkaTooltip id="bare" text="Saved to your library" open={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTooltip id="bare" text="Saved to your library" open={true} />
            <Spacer size={8} />
            <MishkaTooltip id="bare-shut" text="You cannot see me" open={false} />
            <Box fill_width={true} height={28} background={:surface_raised} corner_radius={:radius_sm} />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "text", type: "string", default: "nil", description: "The hint."},
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether it is shown. Lives in the screen."
      },
      %{
        name: "side",
        type: ":top :bottom :left :right",
        default: ":top",
        description: "Which side of the trigger the bubble is stacked on."
      },
      %{
        name: "align",
        type: ":start :center :end",
        default: ":center",
        description: "Placement across that side."
      },
      %{
        name: "side_offset",
        type: "number",
        default: "6",
        description: "Gap between trigger and bubble, in dp."
      },
      %{
        name: "align_offset",
        type: "number",
        default: "0",
        description: "Nudge along the alignment axis, in dp."
      },
      %{
        name: "arrow",
        type: "boolean",
        default: "false",
        description: "Draw a triangle pointing back at the trigger."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Never opens, and wires no hold handler."
      },
      %{
        name: "on_open_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, next_open?}} on hold and on dismissal."
      },
      %{
        name: "on_tap",
        type: "event tag",
        default: "—",
        description: "The wrapped control's own tap. It belongs here, not on the control."
      },
      %{
        name: "close_on_tap",
        type: "boolean",
        default: "true",
        description: "Tapping the bubble dismisses it — the phone's Escape."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: "0xFF111827",
        description: "Bubble fill — dark so it reads over any surface."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: "0xFFFFFFFF",
        description: "Hint colour."
      },
      %{name: "text_size", type: "size token", default: ":sm", description: "Hint size."},
      %{
        name: "offset_x / offset_y",
        type: "number",
        default: "nil",
        description: "Static nudge in dp. Not anchoring."
      },
      %{
        name: "fill_width",
        type: "boolean",
        default: "true",
        description: "Turn off to sit several tooltips in one Row."
      },
      %{
        name: "id",
        type: "string",
        default: "—",
        description: "testTags: id-trigger, id-open, id-arrow-<side>."
      }
    ]
  end

  @impl true
  def handle({{:tip_hold, which}, open?}, socket) do
    Mob.Socket.assign(socket, :tip_hold, if(open?, do: which, else: nil))
  end

  # A plain tap, so the tag arrives whole — on_open_change composes the wanted
  # state onto its tag and this one does not.
  def handle({:tip_use, which}, socket), do: Mob.Socket.assign(socket, :tip_tapped, which)
  def handle({:tip_soft, open?}, socket), do: Mob.Socket.assign(socket, :tip_soft, open?)
  def handle({:tip_sticky, open?}, socket), do: Mob.Socket.assign(socket, :tip_sticky, open?)
  def handle({:tip_off, open?}, socket), do: Mob.Socket.assign(socket, :tip_off, open?)
  def handle(_tag, socket), do: socket

  # Three tooltips in one Row, which is exactly the case fill_width={false}
  # exists for: a filling stack is measured against the whole row and leaves
  # its siblings nothing.
  defp held(open) do
    @controls
    |> Enum.map(fn {id, glyph, hint} -> control(id, glyph, hint, open) end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 16}, children: []})
    |> Kernel.++([%{type: :spacer, props: %{weight: 1}, children: []}])
  end

  defp control(id, glyph, hint, open) do
    ~MOB"""
    <MishkaTooltip
      id={"tip-#{id}"}
      text={hint}
      open={open == id}
      side={:bottom}
      arrow={true}
      fill_width={false}
      on_open_change={{:tip_hold, id}}
      on_tap={{:tip_use, id}}
    >
      <MishkaActionIcon icon={glyph} variant={:filled} />
    </MishkaTooltip>
    """
  end

  defp sides do
    [{:top, "▲"}, {:bottom, "▼"}, {:left, "◀"}, {:right, "▶"}]
    |> Enum.map(fn {side, glyph} ->
      ~MOB"""
      <MishkaTooltip id={"side-#{side}"} text={"side #{side}"} open={true} side={side} arrow={true}>
        <MishkaActionIcon icon={glyph} variant={:filled} />
      </MishkaTooltip>
      """
    end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 14}, children: []})
  end

  defp alignments do
    [
      {"align-start", :start, "start", 0, 6},
      {"align-center", :center, "center", 0, 6},
      {"align-end", :end, "end", -12, 16}
    ]
    |> Enum.map(fn {id, align, label, nudge, gap} ->
      ~MOB"""
      <MishkaTooltip
        id={id}
        text={label}
        open={true}
        align={align}
        align_offset={nudge}
        side_offset={gap}
        arrow={true}
      >
        <MishkaActionIcon icon="◆" variant={:filled} />
      </MishkaTooltip>
      """
    end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 14}, children: []})
  end

  # The fill is read out of the attribute HERE, not inside the ~MOB below:
  # within the sigil a leading @ means an assign, so @dark_fill would be
  # rewritten to assigns.dark_fill and blow up naming the sigil, not the
  # attribute.
  defp styles do
    [
      {"style-dark", "Dark by default", @dark_fill, 0xFF_FF_FF_FF, :sm, nil},
      {"style-token", "Themed", :primary, :on_primary, :base, 12},
      {"style-plum", "A literal, when no token fits", 0xFF7C3AED, 0xFF_FF_FF_FF, :sm, nil}
    ]
    |> Enum.map(fn {id, label, fill, ink, size, nudge} ->
      ~MOB"""
      <MishkaTooltip
        id={id}
        text={label}
        open={true}
        background={fill}
        color={ink}
        text_size={size}
        offset_x={nudge}
      >
        <MishkaActionIcon icon="◐" variant={:filled} />
      </MishkaTooltip>
      """
    end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 14}, children: []})
  end

  defp tapped(nil), do: "Tap a control to use it; hold one to see what it does"
  defp tapped(which), do: "tapped #{which}"

  defp off_state(false), do: "The hint stayed shut, as it must"
  defp off_state(true), do: "disabled leaked — the hold handler fired"

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box width={104} height={22} background={0xFF111827} corner_radius={:radius_sm} />
      <Row fill_width={true}>
        <Spacer size={14} />
        <Box width={10} height={6} background={0xFF111827} />
      </Row>
      <Spacer size={6} />
      <Row fill_width={true}>
        <Box width={28} height={28} background={:surface_raised} corner_radius={:radius_md} />
        <Spacer size={8} />
        <Box width={28} height={28} background={:surface_raised} corner_radius={:radius_md} />
      </Row>
    </Column>
    """
  end
end
