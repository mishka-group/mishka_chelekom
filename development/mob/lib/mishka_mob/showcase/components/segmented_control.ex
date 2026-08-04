defmodule MishkaMob.Showcase.Components.SegmentedControl do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSegmentedControl`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  # Only option/2 now: the segments are written as <MishkaSegmentedControlOption>
  # tags everywhere except the data-driven example, which has nothing to disable.
  import MishkaMob.Components.MishkaSegmentedControl, only: [option: 2]

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
    |> Mob.Socket.assign(:sc_role, :admin)
  end

  # Data for the one example that is genuinely data-driven — see "Segments from
  # data" below, where option/2 is the right call and the tag is not.
  #
  # Read through a function rather than as @roles, because inside ~MOB an @name
  # is an ASSIGN, not a module attribute.
  @roles [{:owner, "Owner"}, {:admin, "Admin"}, {:member, "Member"}]
  defp roles, do: @roles

  @impl true
  def examples do
    [
      %Example{
        title: "Always one selected",
        description: "Re-tapping the selected segment is a no-op — it cannot be cleared.",
        code: ~S"""
        # Segments are slot tags, like Chelekom's <:option>. Each one carries its
        # id and its label; the control keeps the handler.
        <MishkaSegmentedControl value={@view} on_change={:view} id="view">
          <MishkaSegmentedControlOption id={:day} label="Day" />
          <MishkaSegmentedControlOption id={:week} label="Week" />
          <MishkaSegmentedControlOption id={:month} label="Month" />
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
                <MishkaSegmentedControlOption id={:day} label="Day" />
                <MishkaSegmentedControlOption id={:week} label="Week" />
                <MishkaSegmentedControlOption id={:month} label="Month" />
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
        <MishkaSegmentedControl label="THEME" value={@theme} on_change={:theme}>
          <MishkaSegmentedControlOption id={:light} label="Light" />
          <MishkaSegmentedControlOption id={:dark} label="Dark" />
          <MishkaSegmentedControlOption id={:system} label="System" />
        </MishkaSegmentedControl>
        """,
        render: fn assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaSegmentedControl label="THEME" value={@sc_theme} on_change={:sc_theme} id="sc-theme">
              <MishkaSegmentedControlOption id={:light} label="Light" />
              <MishkaSegmentedControlOption id={:dark} label="Dark" />
              <MishkaSegmentedControlOption id={:system} label="System" />
            </MishkaSegmentedControl>
          </Row>
          """
        end
      },
      %Example{
        title: "Segments from data",
        description:
          "When the segments come from a list, option/2 builds the same node the tag does.",
        code: ~S"""
        # Written as a LIST here rather than as <MishkaSegmentedControlOption>
        # tags, because the segments come from data. option/3 builds exactly the
        # node the tag does — %{type: :mishka_segmented_control_option, props:
        # %{id:, label:, disabled:}} — so the two forms are interchangeable. Use
        # the tag when you are writing the segments out, the function when you
        # are mapping over a list.
        @roles [{:owner, "Owner"}, {:admin, "Admin"}, {:member, "Member"}]

        <MishkaSegmentedControl value={@role} on_change={:role} text_size={:sm}>
          {Enum.map(@roles, fn {id, label} -> option(id, label) end)}
        </MishkaSegmentedControl>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaSegmentedControl value={@sc_role} on_change={:sc_role} id="sc-role" text_size={:sm}>
                {Enum.map(roles(), fn {id, label} -> option(id, label) end)}
              </MishkaSegmentedControl>
            </Row>
            <Spacer size={8} />
            <Text
              text="Tag or function, the control cannot tell — both build the same node."
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "It hugs, or it spans",
        description: "The strip is the width of its labels unless you ask for fill_width.",
        code: ~S"""
        <MishkaSegmentedControl fill_width={true} value={@v}>
          <MishkaSegmentedControlOption id={:s} label="S" />
          <MishkaSegmentedControlOption id={:m} label="M" />
          <MishkaSegmentedControlOption id={:l} label="L" />
        </MishkaSegmentedControl>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaSegmentedControl value={@sc_size} on_change={:sc_size} id="sc-hug">
                <MishkaSegmentedControlOption id={:s} label="S" />
                <MishkaSegmentedControlOption id={:m} label="M" />
                <MishkaSegmentedControlOption id={:l} label="L" />
              </MishkaSegmentedControl>
            </Row>
            <Spacer size={12} />
            <MishkaSegmentedControl value={@sc_size} on_change={:sc_size} fill_width={true} id="sc-fill">
              <MishkaSegmentedControlOption id={:s} label="S" />
              <MishkaSegmentedControlOption id={:m} label="M" />
              <MishkaSegmentedControlOption id={:l} label="L" />
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
        >
          <MishkaSegmentedControlOption id={:day} label="Day" />
          <MishkaSegmentedControlOption id={:week} label="Week" />
          <MishkaSegmentedControlOption id={:month} label="Month" />
        </MishkaSegmentedControl>
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
                <MishkaSegmentedControlOption id={:day} label="Day" />
                <MishkaSegmentedControlOption id={:week} label="Week" />
                <MishkaSegmentedControlOption id={:month} label="Month" />
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
                <MishkaSegmentedControlOption id={:day} label="Day" />
                <MishkaSegmentedControlOption id={:week} label="Week" />
                <MishkaSegmentedControlOption id={:month} label="Month" />
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
        # One segment off — disabled sits on the option tag.
        <MishkaSegmentedControl value={@v} on_change={:pick}>
          <MishkaSegmentedControlOption id={:inbox} label="Inbox" />
          <MishkaSegmentedControlOption id={:archive} label="Archive" disabled={true} />
        </MishkaSegmentedControl>

        # The whole control off — disabled on the control cascades to every one.
        <MishkaSegmentedControl disabled={true} value={@v}>…</MishkaSegmentedControl>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text text="ONE SEGMENT OFF" text_size={:sm} text_color={:muted} />
            <Spacer size={8} />
            <Row fill_width={true}>
              <MishkaSegmentedControl value={@sc_mail} on_change={:sc_mail} id="sc-one">
                <MishkaSegmentedControlOption id={:inbox} label="Inbox" />
                <MishkaSegmentedControlOption id={:sent} label="Sent" />
                <MishkaSegmentedControlOption id={:archive} label="Archive (off)" disabled={true} />
              </MishkaSegmentedControl>
            </Row>
            <Spacer size={16} />
            <Text text="WHOLE CONTROL OFF" text_size={:sm} text_color={:muted} />
            <Spacer size={8} />
            <Row fill_width={true}>
              <MishkaSegmentedControl value={:mid} disabled={true} id="sc-off">
                <MishkaSegmentedControlOption id={:low} label="Low (off)" />
                <MishkaSegmentedControlOption id={:mid} label="Mid (off)" />
                <MishkaSegmentedControlOption id={:high} label="High (off)" />
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
        name: "<MishkaSegmentedControlOption>",
        type: "slot tag",
        default: "—",
        description: "One segment: id, label, disabled. Consumed by the control."
      },
      %{
        name: "option/3",
        type: "helper",
        default: "—",
        description: "option(id, label, disabled: false) — the same node, for segments from data."
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
  def handle({:sc_role, id}, socket), do: Mob.Socket.assign(socket, :sc_role, id)
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
