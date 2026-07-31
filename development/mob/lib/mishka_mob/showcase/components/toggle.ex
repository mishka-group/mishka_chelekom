defmodule MishkaMob.Showcase.Components.Toggle do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaToggle`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :toggle,
      name: "Toggle",
      category: "Forms",
      order: 7,
      description: "A button that stays pressed, as in a formatting toolbar."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:tg_bold, true)
    |> Mob.Socket.assign(:tg_italic, false)
    |> Mob.Socket.assign(:tg_under, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A toolbar",
        description: "Each button holds its own pressed state.",
        code: ~S"""
        <MishkaToggle label="Bold" pressed={@bold?} on_change={:bold} />

        # A lone toggle owns one boolean, so its tag needs no id.
        def handle_info({:tap, :bold}, socket) do
          {:noreply, Mob.Socket.assign(socket, :bold?, not socket.assigns.bold?)}
        end

        def handle_info(_msg, socket), do: {:noreply, socket}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaToggle
                label="Bold"
                pressed={@tg_bold}
                on_change={:tg_bold}
                id="tg-bold"
                padding={10}
                corner_radius={6}
              />
              <Spacer size={8} />
              <MishkaToggle
                label="Italic"
                pressed={@tg_italic}
                on_change={:tg_italic}
                id="tg-italic"
                padding={10}
                corner_radius={6}
              />
              <Spacer size={8} />
              <MishkaToggle
                label="Underline"
                pressed={@tg_under}
                on_change={:tg_under}
                id="tg-under"
                padding={10}
                corner_radius={6}
              />
            </Row>
            <Spacer size={12} />
            <Text text={summary(@tg_bold, @tg_italic, @tg_under)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "It hugs its label",
        description: "A toggle is the width of its text — it is a button, not a banner.",
        code: ~S"""
        <MishkaToggle label="Pressed" pressed={true} />
        <MishkaToggle label="A much longer label" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaToggle label="Pressed" pressed={true} padding={10} corner_radius={6} id="tg-hug" />
              <Spacer size={8} />
              <MishkaToggle label="A much longer label" padding={10} corner_radius={6} id="tg-long" />
            </Row>
            <Spacer size={12} />
            <Text
              text="fill_width={true} spans the parent instead, when you want that."
              text_size={:sm}
              text_color={:muted}
            />
            <Spacer size={8} />
            <MishkaToggle
              label="Full width"
              pressed={true}
              fill_width={true}
              padding={12}
              corner_radius={6}
              id="tg-fill"
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Styled by props, not by a stylesheet",
        description: "Like the headless original it ships no look. Every visual is a prop.",
        code: ~S"""
        <MishkaToggle
          label="Violet"
          pressed={true}
          color={0xFF7C3AED}
          corner_radius={20}
          padding={12}
          border_width={0}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaToggle
                label="Pill"
                pressed={true}
                color={0xFF7C3AED}
                corner_radius={20}
                padding={12}
                border_width={0}
              />
              <Spacer size={8} />
              <MishkaToggle label="Pill" corner_radius={20} padding={12} border_width={0} />
            </Row>
            <Spacer size={14} />
            <Row fill_width={true}>
              <MishkaToggle
                label="Square"
                pressed={true}
                color={0xFF111111}
                corner_radius={2}
                padding={10}
                text_size={:sm}
              />
              <Spacer size={8} />
              <MishkaToggle
                label="Square"
                corner_radius={2}
                padding={10}
                text_size={:sm}
                background={0xFFEFEFF4}
                border_width={0}
              />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Inert, but it still shows whether it is pressed.",
        code: ~S"""
        <MishkaToggle label="Locked on" pressed={true} disabled={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaToggle
                label="Locked on"
                pressed={true}
                disabled={true}
                padding={10}
                corner_radius={6}
                id="tg-lockon"
              />
              <Spacer size={8} />
              <MishkaToggle
                label="Locked off"
                disabled={true}
                padding={10}
                corner_radius={6}
                id="tg-lockoff"
              />
            </Row>
            <Spacer size={12} />
            <Text
              text="A disabled toggle stays filled, greyed rather than accented — otherwise
                    locked-on and locked-off look identical."
              text_size={:sm}
              text_color={:muted}
            />
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
        name: "label",
        type: "string",
        default: "nil",
        description: "Button text. Children override it."
      },
      %{
        name: "pressed",
        type: "boolean",
        default: "false",
        description: "Whether it reads as pushed in. Lives in the screen."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Wires no handler and mutes it."
      },
      %{name: "on_change", type: "event tag", default: "—", description: "Sent as {:tap, tag}."},
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Fill when pressed."
      },
      %{
        name: "text_color",
        type: "color / ARGB",
        default: ":on_primary",
        description: "Label colour when pressed."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "Fill when idle — the partner of color."
      },
      %{
        name: "label_color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "Label when idle — the partner of text_color."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_sm",
        description: "Inside the button."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: ":radius_md",
        description: "Corner rounding."
      },
      %{
        name: "border_color / border_width",
        type: "color / number",
        default: ":border / 1",
        description: "Border. Width 0 removes it."
      },
      %{name: "text_size", type: "text token", default: ":base", description: "Label size."},
      %{
        name: "fill_width",
        type: "boolean",
        default: "false",
        description: "Span the parent instead of hugging its label."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Test tag, suffixed -pressed / -idle."
      }
    ]
  end

  @impl true
  def handle(:tg_bold, socket), do: flip(socket, :tg_bold)
  def handle(:tg_italic, socket), do: flip(socket, :tg_italic)
  def handle(:tg_under, socket), do: flip(socket, :tg_under)
  def handle(_tag, socket), do: socket

  defp flip(socket, key), do: Mob.Socket.assign(socket, key, not Map.fetch!(socket.assigns, key))

  defp summary(b, i, u) do
    on =
      [{b, "bold"}, {i, "italic"}, {u, "underline"}]
      |> Enum.filter(&elem(&1, 0))
      |> Enum.map_join(", ", &elem(&1, 1))

    if on == "", do: "Nothing pressed", else: "Pressed: " <> on
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true}>
      <Box width={30} height={26} background={:primary} corner_radius={:radius_md} />
      <Spacer size={8} />
      <Box width={30} height={26} background={:surface_raised} corner_radius={:radius_md} />
      <Spacer size={8} />
      <Box width={30} height={26} background={:surface_raised} corner_radius={:radius_md} />
    </Row>
    """
  end
end
