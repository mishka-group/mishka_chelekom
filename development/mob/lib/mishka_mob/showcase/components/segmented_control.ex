defmodule MishkaMob.Showcase.Components.SegmentedControl do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSegmentedControl`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  import MishkaMob.Components.MishkaSegmentedControl, only: [option: 2, option: 3]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :segmented_control,
      name: "Segmented Control",
      category: "Forms",
      order: 9,
      description: "A joined strip where exactly one option is always selected."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:sc_view, :day)
    |> Mob.Socket.assign(:sc_theme, :system)
    |> Mob.Socket.assign(:sc_size, :m)
    |> Mob.Socket.assign(:sc_mail, :inbox)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Always one selected",
        description: "Re-tapping the selected segment is a no-op — it cannot be cleared.",
        code: ~S"""
        <MishkaSegmentedControl value={@view} on_change={:view} id="view">
          {[option(:day, "Day"), option(:week, "Week"), option(:month, "Month")]}
        </MishkaSegmentedControl>

        # select/2 is the rule, and it is deliberately boring: always the tapped
        # id. A toggle group would clear here; a radio group would keep. Neither
        # is what a segmented control does.
        def handle_info({:tap, {:view, id}}, socket) do
          next = MishkaSegmentedControl.select(socket.assigns.view, id)
          {:noreply, Mob.Socket.assign(socket, :view, next)}
        end

        def handle_info(_msg, socket), do: {:noreply, socket}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaSegmentedControl value={@sc_view} on_change={:sc_view} id="sc-view">
                {[
                option(:day, "Day"),
                option(:week, "Week"),
                option(:month, "Month")
              ]}
              </MishkaSegmentedControl>
            </Row>
            <Spacer size={12} />
            <Text text={"Value: " <> to_string(@sc_view)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "With a label",
        description: "A heading above the strip.",
        code: ~S"""
        <MishkaSegmentedControl label="THEME" value={@theme} on_change={:theme}>{opts}</MishkaSegmentedControl>
        """,
        render: fn assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaSegmentedControl label="THEME" value={@sc_theme} on_change={:sc_theme} id="sc-theme">
              {[
              option(:light, "Light"),
              option(:dark, "Dark"),
              option(:system, "System")
            ]}
            </MishkaSegmentedControl>
          </Row>
          """
        end
      },
      %Example{
        title: "It hugs, or it spans",
        description: "The strip is the width of its labels unless you ask for fill_width.",
        code: ~S"""
        <MishkaSegmentedControl fill_width={true} value={@v}>{opts}</MishkaSegmentedControl>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaSegmentedControl value={@sc_size} on_change={:sc_size} id="sc-hug">
                {[option(:s, "S"), option(:m, "M"), option(:l, "L")]}
              </MishkaSegmentedControl>
            </Row>
            <Spacer size={12} />
            <MishkaSegmentedControl value={@sc_size} on_change={:sc_size} fill_width={true} id="sc-fill">
              {[option(:s, "S"), option(:m, "M"), option(:l, "L")]}
            </MishkaSegmentedControl>
            <Spacer size={8} />
            <Text
              text="Segments stay content-sized either way — equal widths would need
                    layout weight, which iOS does not have."
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Styled by props, not by a stylesheet",
        description: "Like the headless original it ships no look. Every visual is a prop.",
        code: ~S"""
        <MishkaSegmentedControl
          value={@v}
          color={0xFF7C3AED}
          background={0xFFEFEDF7}
          corner_radius={20}
          segment_radius={17}
          padding={12}
        >{opts}</MishkaSegmentedControl>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaSegmentedControl
                value={@sc_view}
                on_change={:sc_view}
                color={0xFF7C3AED}
                background={0xFFEFEDF7}
                corner_radius={20}
                segment_radius={17}
                padding={12}
                text_size={:sm}
              >
                {[option(:day, "Day"), option(:week, "Week"), option(:month, "Month")]}
              </MishkaSegmentedControl>
            </Row>
            <Spacer size={14} />
            <Row fill_width={true}>
              <MishkaSegmentedControl
                value={@sc_view}
                on_change={:sc_view}
                color={0xFF111111}
                background={:background}
                border_color={:border}
                border_width={1}
                corner_radius={4}
                segment_radius={2}
                padding={10}
                text_size={:sm}
              >
                {[option(:day, "Day"), option(:week, "Week"), option(:month, "Month")]}
              </MishkaSegmentedControl>
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description:
          "One segment, or the whole control. A locked control is greyed, not accented.",
        code: ~S"""
        option(:archive, "Archive", disabled: true)
        <MishkaSegmentedControl disabled={true} value={@v}>{opts}</MishkaSegmentedControl>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text text="ONE SEGMENT OFF" text_size={:sm} text_color={:muted} />
            <Spacer size={8} />
            <Row fill_width={true}>
              <MishkaSegmentedControl value={@sc_mail} on_change={:sc_mail} id="sc-one">
                {[
                option(:inbox, "Inbox"),
                option(:sent, "Sent"),
                option(:archive, "Archive (off)", disabled: true)
              ]}
              </MishkaSegmentedControl>
            </Row>
            <Spacer size={16} />
            <Text text="WHOLE CONTROL OFF" text_size={:sm} text_color={:muted} />
            <Spacer size={8} />
            <Row fill_width={true}>
              <MishkaSegmentedControl value={:mid} disabled={true} id="sc-off">
                {[
                option(:low, "Low (off)"),
                option(:mid, "Mid (off)"),
                option(:high, "High (off)")
              ]}
              </MishkaSegmentedControl>
            </Row>
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "value",
        type: "option id",
        default: "first option",
        description: "The selected segment. An unknown id falls back to the first."
      },
      %{name: "label", type: "string", default: "nil", description: "Heading above the strip."},
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Disables every segment."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, option_id}}."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Selected segment fill."
      },
      %{
        name: "text_color",
        type: "color / ARGB",
        default: ":on_primary",
        description: "Selected segment label."
      },
      %{
        name: "label_color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "An unselected segment's label."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "The track behind the segments."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_sm",
        description: "Inside each segment."
      },
      %{
        name: "track_padding",
        type: "number",
        default: "3",
        description: "Inset between the track and its segments."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: ":radius_md",
        description: "The track's corners."
      },
      %{
        name: "segment_radius",
        type: "radius / number",
        default: ":radius_sm",
        description: "A segment's corners."
      },
      %{
        name: "border_color / border_width",
        type: "color / number",
        default: "nil / 0",
        description: "An optional border around the track."
      },
      %{name: "text_size", type: "text token", default: ":base", description: "Segment labels."},
      %{
        name: "fill_width",
        type: "boolean",
        default: "false",
        description: "The track spans its parent instead of hugging its labels."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Prefix for each segment's tag: <id>-<option>-selected."
      },
      %{
        name: "option/3",
        type: "helper",
        default: "—",
        description: "option(id, label, disabled: false) — a single segment can be off."
      },
      %{
        name: "select/2",
        type: "helper",
        default: "—",
        description: "The next value for a tap: always the tapped id, never nil."
      }
    ]
  end

  @impl true
  def handle({:sc_view, id}, socket), do: Mob.Socket.assign(socket, :sc_view, id)
  def handle({:sc_theme, id}, socket), do: Mob.Socket.assign(socket, :sc_theme, id)
  def handle({:sc_size, id}, socket), do: Mob.Socket.assign(socket, :sc_size, id)
  def handle({:sc_mail, id}, socket), do: Mob.Socket.assign(socket, :sc_mail, id)
  def handle(_tag, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Box fill_width={true} background={:surface_raised} corner_radius={:radius_md} padding={4}>
      <Row fill_width={true}>
        <Box width={46} height={22} background={:primary} corner_radius={:radius_sm} />
        <Spacer size={4} />
        <Box width={46} height={22} corner_radius={:radius_sm} />
        <Spacer size={4} />
        <Box width={46} height={22} corner_radius={:radius_sm} />
      </Row>
    </Box>
    """
  end
end
