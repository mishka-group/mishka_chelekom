defmodule MishkaMob.Showcase.Components.Collapsible do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaCollapsible`.

  Each example drives its own boolean, so the difference from the Accordion is
  visible: nothing here coordinates with anything else.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :collapsible,
      name: "Collapsible",
      category: "Disclosure",
      order: 1,
      description: "A trigger that shows and hides one region."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:cl_basic, true)
    |> Mob.Socket.assign(:cl_plain, false)
    # Its own flag, not :cl_basic. Two examples sharing one boolean meant
    # opening either moved the other, which reads as a bug in the component.
    |> Mob.Socket.assign(:cl_tinted, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A disclosure",
        description: "One trigger, one region, one boolean in the screen.",
        code: ~S"""
        <MishkaCollapsible
          title="Shipping details"
          open={@open}
          on_toggle={:toggle}
        >{body}</MishkaCollapsible>

        def handle_info({:tap, :toggle}, socket) do
          {:noreply, assign(socket, :open, not socket.assigns.open)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCollapsible title="Shipping details" open={@cl_basic} on_toggle={:cl_basic}>
              {paragraph("Ships in 2–4 working days. Tracking is emailed once the parcel leaves the warehouse.")}
            </MishkaCollapsible>
          </Column>
          """
        end
      },
      %Example{
        title: "Without a chevron",
        description: "Hide the indicator when the row already reads as a control.",
        code: ~S"""
        <MishkaCollapsible
          title="More"
          open={@open}
          chevron={false}
          on_toggle={:t}
        >{body}</MishkaCollapsible>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCollapsible
              title="What is a headless component?"
              open={@cl_plain}
              chevron={false}
              on_toggle={:cl_plain}
            >
              {paragraph("Behaviour and structure with no styling — you bring the looks. This port maps that behaviour onto native widgets.")}
            </MishkaCollapsible>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "No handler is wired, so the trigger cannot open.",
        code: ~S"""
        <MishkaCollapsible title="Locked" disabled={true}>{body}</MishkaCollapsible>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCollapsible title="Locked (closed)" disabled={true}>
              {paragraph("You cannot see this.")}
            </MishkaCollapsible>
            <Spacer size={8} />
            <MishkaCollapsible title="Locked (open)" open={true} disabled={true}>
              {paragraph("Held open by the screen, not by the trigger.")}
            </MishkaCollapsible>
          </Column>
          """
        end
      },
      %Example{
        title: "Custom colours",
        description:
          "background, color, corner_radius and padding are props. Set color " <>
            "whenever you set background — the default ink is the THEME's, and a " <>
            "tinted panel is no longer a theme surface.",
        code: ~S"""
        <MishkaCollapsible
          title="Tinted"
          open={@open}
          background={0xFF7C3AED}
          color={0xFFFFFFFF}
          corner_radius={:radius_lg}
          on_toggle={:t}
        >{body}</MishkaCollapsible>

        def handle_info({:tap, :t}, socket) do
          {:noreply, Mob.Socket.assign(socket, :open, not socket.assigns.open)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCollapsible
              title="Tinted panel"
              open={@cl_tinted}
              background={0xFF7C3AED}
              color={0xFFFFFFFF}
              corner_radius={:radius_lg}
              on_toggle={:cl_tinted}
            >
              {[%{type: :text,
                 props: %{text: "Any colour token or ARGB int works here.",
                          text_size: :base, text_color: 0xFFFFFFFF},
                 children: []}]}
            </MishkaCollapsible>
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "title", type: "string", default: "nil", description: "The trigger label."},
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the region is shown. Lives in the screen."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Wires no handler, so the trigger is inert."
      },
      %{
        name: "on_toggle",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, tag} — a bare tag, unlike the Accordion's {tag, item_id}."
      },
      %{
        name: "chevron",
        type: "boolean",
        default: "true",
        description: "Show the ▸/▾ indicator."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "Title and chevron. Set it whenever you set background."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "Row background."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: ":radius_md",
        description: "Rounds the row."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_md",
        description: "Padding inside the trigger and the region."
      }
    ]
  end

  @impl true
  def handle(:cl_basic, socket), do: flip(socket, :cl_basic)
  def handle(:cl_plain, socket), do: flip(socket, :cl_plain)
  def handle(:cl_tinted, socket), do: flip(socket, :cl_tinted)
  def handle(_tag, socket), do: socket

  defp flip(socket, key),
    do: Mob.Socket.assign(socket, key, not Map.fetch!(socket.assigns, key))

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={54} height={10} background={:muted} corner_radius={:radius_sm} />
        <Spacer weight={1} />
        <Box width={10} height={10} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={10} />
      <Box fill_width={true} height={26} background={:surface_raised} corner_radius={:radius_sm} />
    </Column>
    """
  end

  defp paragraph(text) do
    [%{type: :text, props: %{text: text, text_size: :base, text_color: :muted}, children: []}]
  end
end
