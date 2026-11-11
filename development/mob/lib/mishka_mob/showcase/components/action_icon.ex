defmodule MishkaMob.Showcase.Components.ActionIcon do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaActionIcon` and its
  `MishkaMob.Components.MishkaCloseButton` wrapper.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :action_icon,
      name: "Action Icon",
      category: "Data display",
      order: 4,
      description: "A compact icon-only button, with a finger-sized tap target."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :ai_taps, 0)

  @impl true
  def examples do
    [
      %Example{
        title: "Icon buttons",
        description:
          "Plain by default; filled puts it on a raised surface. The count below " <>
            "is every icon button on this page — they all report to one tag.",
        code: ~S"""
        <MishkaActionIcon icon="⋯" on_tap={:menu} />
        <MishkaActionIcon icon="←" variant={:filled} on_tap={:back} />
        <MishkaActionIcon icon="★" variant={:filled} shape={:circle} on_tap={:star} />
        <MishkaActionIcon icon="⚙" color={:primary} on_tap={:settings} />

        # An icon button carries no value, so the TAG is the whole message. Give
        # each button its own — three sharing :tap arrive identically and name
        # nothing.
        def handle_info({:tap, :menu}, socket) do
          {:noreply, assign(socket, :menu_open, true)}
        end

        def handle_info({:tap, :back}, socket), do: {:noreply, Mob.Socket.pop_screen(socket)}

        # In a list, put the row's identity in the tag: on_tap={{:delete, item.id}}
        # arrives as {:tap, {:delete, 7}}.
        def handle_info({:tap, {:delete, id}}, socket) do
          {:noreply, assign(socket, :rows, List.delete(socket.assigns.rows, id))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaActionIcon icon="⋯" on_tap={:ai_tap} />
              <Spacer size={8} />
              <MishkaActionIcon icon="←" variant={:filled} on_tap={:ai_tap} />
              <Spacer size={8} />
              <MishkaActionIcon icon="★" variant={:filled} shape={:circle} on_tap={:ai_tap} />
              <Spacer size={8} />
              <MishkaActionIcon icon="⚙" color={:primary} on_tap={:ai_tap} />
            </Row>
            <Spacer size={12} />
            <Text text={taps_label(@ai_taps)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Close button",
        description: "The ✕ wrapper — same component, one spelling for close.",
        code: ~S"""
        # icon and shape are applied with Map.put_new/3, so every Action Icon
        # prop still works and both defaults can still be overridden.
        <MishkaCloseButton on_tap={:dismiss} />
        <MishkaCloseButton variant={:filled} on_tap={:dismiss} />
        <MishkaCloseButton disabled={true} />

        def handle_info({:tap, :dismiss}, socket) do
          {:noreply, assign(socket, :open, false)}
        end
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaCloseButton on_tap={:ai_tap} />
            <Spacer size={8} />
            <MishkaCloseButton variant={:filled} on_tap={:ai_tap} />
            <Spacer size={8} />
            <MishkaCloseButton disabled={true} />
          </Row>
          """
        end
      },
      %Example{
        title: "Tap targets stay finger-sized",
        description: "size is the target, not the glyph — 40 by default, not ~16.",
        code: ~S"""
        # 40 is the default, and it is the TAP TARGET — the glyph stays :lg
        # whatever size is. An icon button drawn to fit its glyph is a ~16 dp
        # target, well under the ~44 dp both platforms ask for.
        <MishkaActionIcon icon="✕" variant={:filled} size={48} on_tap={:zoom} />
        <MishkaActionIcon icon="✕" variant={:filled} on_tap={:zoom} />
        <MishkaActionIcon icon="✕" variant={:filled} size={28} on_tap={:zoom} />

        def handle_info({:tap, :zoom}, socket), do: {:noreply, socket}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaActionIcon icon="✕" variant={:filled} size={48} on_tap={:ai_tap} />
            <Spacer size={8} />
            <MishkaActionIcon icon="✕" variant={:filled} on_tap={:ai_tap} />
            <Spacer size={8} />
            <MishkaActionIcon icon="✕" variant={:filled} size={28} on_tap={:ai_tap} />
          </Row>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Muted and inert — the handler is dropped, not guarded.",
        code: ~S"""
        # on_tap is given and never wired, so nothing is sent and there is
        # nothing to ignore on the receiving end. :muted also overrides color.
        <MishkaActionIcon icon="⋯" disabled={true} on_tap={:nope} />
        <MishkaActionIcon icon="⋯" variant={:filled} disabled={true} on_tap={:nope} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaActionIcon icon="⋯" disabled={true} on_tap={:nope} />
            <Spacer size={8} />
            <MishkaActionIcon icon="⋯" variant={:filled} disabled={true} on_tap={:nope} />
          </Row>
          """
        end
      },
      %Example{
        title: "A bare glyph",
        description:
          "size: :hug drops the box's own size and decoration so the glyph is the " <>
            "target — for an icon that already sits in a row, like a pencil on a note.",
        code: ~S"""
        # No disc and no fixed target: this is a hand-rolled
        # <Box fill_width={false}> that carries a tap. The tap target is the
        # glyph, which is the caller's explicit choice.
        <MishkaActionIcon icon="✎" size={:hug} on_tap={:edit_note} />

        def handle_info({:tap, :edit_note}, socket), do: {:noreply, socket}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true} align="center">
            <Text text="A note" text_color={:on_surface} />
            <Spacer weight={1.0} />
            <MishkaActionIcon icon="✎" size={:hug} on_tap={:ai_tap} />
          </Row>
          """
        end
      },
      %Example{
        title: "A badge over the glyph",
        description:
          "overlay draws on top of the glyph, filling the target — the corner-dot " <>
            "idiom. The overlay is a normal node, so it can be any shape.",
        code: ~S"""
        # The overlay fills the 44pt target and aligns its dot to the corner; a
        # Box stacks its children, so the badge sits over the glyph rather than
        # beside it.
        <MishkaActionIcon icon="🔔" variant={:filled} shape={:circle} size={44}
                          overlay={badge_node} on_tap={:bell} />

        def handle_info({:tap, :bell}, socket) do
          {:noreply, Mob.Socket.push_screen(socket, Inbox)}
        end
        """,
        render: fn _assigns ->
          overlay = ~MOB"""
          <Box fill_width={true} fill_height={true} align="top_trailing">
            <Column padding_top={8} padding_right={9}>
              <Box id="ai-dot" width={10} height={10} corner_radius={5} background={:primary} />
            </Column>
          </Box>
          """

          assigns = %{overlay: overlay}

          ~MOB"""
          <Row fill_width={true} align="center">
            <Text text="Has news" text_color={:on_surface} />
            <Spacer size={12} />
            <Box id="ai-bell">
              <MishkaActionIcon
                icon="🔔"
                variant={:filled}
                shape={:circle}
                size={44}
                overlay={@overlay}
                on_tap={:ai_tap}
              />
            </Box>
          </Row>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "icon",
        type: "string",
        default: "nil",
        description: "The glyph. Children override it."
      },
      %{name: "on_tap", type: "event tag", default: "—", description: "Sent as {:tap, tag}."},
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description:
          "Wires no handler, mutes the glyph and drops a :filled fill to :surface. " <>
            "Children are rendered as given — Mob has no opacity to dim them with."
      },
      %{
        name: "size",
        type: "number · :hug",
        default: "40",
        description:
          "Tap-target edge, not the glyph size. Keeps the target finger-sized. " <>
            ":hug drops the box's size and decoration so it wraps the glyph."
      },
      %{
        name: "variant",
        type: ":plain · :filled",
        default: ":plain",
        description: "Transparent, or on a raised surface."
      },
      %{
        name: "shape",
        type: ":rounded · :circle",
        default: ":rounded",
        description: "Circle uses an exact size/2 radius."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "Glyph colour."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "Fill when variant: :filled. Ignored while variant is :plain."
      },
      %{
        name: "overlay",
        type: "node | list of nodes",
        default: "nil",
        description:
          "Drawn on top of the glyph and filling the target — for a badge pinned " <>
            "to a corner. An unset overlay leaves the child list untouched."
      },
      %{
        name: "CloseButton: icon",
        type: "string",
        default: "\"✕\"",
        description: "Put on with Map.put_new/3, so it is still overridable."
      },
      %{
        name: "CloseButton: shape",
        type: ":rounded · :circle",
        default: ":circle",
        description: "The only other difference — every prop above still applies."
      }
    ]
  end

  @impl true
  def handle(:ai_tap, socket), do: Mob.Socket.assign(socket, :ai_taps, socket.assigns.ai_taps + 1)
  def handle(_tag, socket), do: socket

  defp taps_label(0), do: "Not tapped yet"
  defp taps_label(1), do: "Tapped once"
  defp taps_label(n), do: "Tapped #{n} times"

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true}>
      <Box width={30} height={30} background={:surface_raised} corner_radius={:radius_md} />
      <Spacer size={8} />
      <Box width={30} height={30} background={:surface_raised} corner_radius={15} />
      <Spacer size={8} />
      <Box width={30} height={30} background={:primary} corner_radius={15} />
    </Row>
    """
  end
end
