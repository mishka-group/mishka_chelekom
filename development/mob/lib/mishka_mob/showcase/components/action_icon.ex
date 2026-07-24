defmodule MishkaMob.Showcase.Components.ActionIcon do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaActionIcon` and its
  `MishkaMob.Components.MishkaCloseButton` wrapper.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaActionIcon, only: [action_icon: 1]
  import MishkaMob.Components.MishkaCloseButton, only: [close_button: 1]

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
        description: "Plain by default; filled puts it on a raised surface.",
        code: ~S"""
        {action_icon(icon: "⋯", on_tap: :menu)}
        {action_icon(icon: "←", variant: :filled, shape: :circle, on_tap: :back)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              {action_icon(icon: "⋯", on_tap: :ai_tap)}
              <Spacer size={8} />
              {action_icon(icon: "←", variant: :filled, on_tap: :ai_tap)}
              <Spacer size={8} />
              {action_icon(icon: "★", variant: :filled, shape: :circle, on_tap: :ai_tap)}
              <Spacer size={8} />
              {action_icon(icon: "⚙", color: :primary, on_tap: :ai_tap)}
            </Row>
            <Spacer size={12} />
            <Text
              text={"Tapped " <> Integer.to_string(@ai_taps) <> " times"}
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Close button",
        description: "The ✕ wrapper — same component, one spelling for close.",
        code: ~S"""
        {close_button(on_tap: :dismiss)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {close_button(on_tap: :ai_tap)}
            <Spacer size={8} />
            {close_button(variant: :filled, on_tap: :ai_tap)}
            <Spacer size={8} />
            {close_button(disabled: true)}
          </Row>
          """
        end
      },
      %Example{
        title: "Tap targets stay finger-sized",
        description: "size is the target, not the glyph — 40 by default, not ~16.",
        code: ~S"""
        {action_icon(icon: "✕", size: 40)}   # default
        {action_icon(icon: "✕", size: 28)}   # deliberately smaller
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {action_icon(icon: "✕", variant: :filled, size: 48, on_tap: :ai_tap)}
            <Spacer size={8} />
            {action_icon(icon: "✕", variant: :filled, on_tap: :ai_tap)}
            <Spacer size={8} />
            {action_icon(icon: "✕", variant: :filled, size: 28, on_tap: :ai_tap)}
          </Row>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Muted and inert.",
        code: ~S"""
        {action_icon(icon: "⋯", disabled: true)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {action_icon(icon: "⋯", disabled: true)}
            <Spacer size={8} />
            {action_icon(icon: "⋯", variant: :filled, disabled: true)}
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
        description: "Wires no handler and mutes the glyph."
      },
      %{
        name: "size",
        type: "number",
        default: "40",
        description: "Tap-target edge, not the glyph size. Keeps the target finger-sized."
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
        description: "Fill when variant: :filled."
      }
    ]
  end

  @impl true
  def handle(:ai_tap, socket), do: Mob.Socket.assign(socket, :ai_taps, socket.assigns.ai_taps + 1)
  def handle(_tag, socket), do: socket

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
