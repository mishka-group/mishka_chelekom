defmodule MishkaMob.Showcase.Components.PreviewCard do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaPreviewCard` and
  `MishkaMob.Components.MishkaScroller`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :preview_card,
      name: "Preview Card",
      category: "Overlays",
      order: 5,
      description: "A card of detail about a thing, plus a horizontal scroller rail."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:pc_open, true)
    |> Mob.Socket.assign(:pc_nudges, 0)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A profile preview",
        description: "Avatar, name, context and a footer for actions.",
        code: ~S"""
        <MishkaPreviewCard
          open={@open?}
          title="Shahryar"
          subtitle="@shahryar"
          initials="SH"
          description="…"
        >{[follow_button()]}</MishkaPreviewCard>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Button
              text={if(@pc_open, do: "Hide card", else: "Show card")}
              background={:surface_raised}
              text_color={:on_surface}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :pc_toggle}}
            />
            <Spacer size={10} />
            <MishkaPreviewCard
              open={@pc_open}
              title="Shahryar"
              subtitle="@shahryar · Mishka"
              initials="SH"
              avatar_color={0xFF7C3AED}
              description="Builds Mishka Chelekom, and now its native Mob port."
            >
              {[follow(), gap(), message()]}
            </MishkaPreviewCard>
          </Column>
          """
        end
      },
      %Example{
        title: "Without a footer",
        description: "Every part is optional.",
        code: ~S"""
        <MishkaPreviewCard open={true} title="Ecto" description="A database wrapper." />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPreviewCard
              open={true}
              title="Ecto"
              subtitle="elixir-ecto/ecto"
              initials="E"
              description="A toolkit for data mapping and queries."
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Scroller",
        description: "A horizontal rail; the arrows emit events the screen acts on.",
        code: ~S"""
        <MishkaScroller id="gallery" on_prev={:back} on_next={:fwd}>{[rail()]}</MishkaScroller>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaScroller id="gallery" on_prev={:pc_prev} on_next={:pc_next} height={76}>
              {[rail()]}
            </MishkaScroller>
            <Spacer size={8} />
            <Text
              text={"Arrow taps: " <> Integer.to_string(@pc_nudges)}
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
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the card is shown."
      },
      %{name: "title", type: "string", default: "nil", description: "The name."},
      %{
        name: "subtitle",
        type: "string",
        default: "nil",
        description: "A line of context under it."
      },
      %{name: "description", type: "string", default: "nil", description: "The body."},
      %{
        name: "initials / image",
        type: "string",
        default: "nil",
        description: "Avatar content — it uses MishkaAvatar."
      },
      %{
        name: "avatar_color",
        type: "color / ARGB",
        default: ":primary",
        description: "Avatar fill."
      },
      %{
        name: "Scroller: id / on_prev / on_next / controls / height",
        type: "see MishkaScroller",
        default: "—",
        description: "A horizontal rail whose arrows emit events the screen acts on."
      }
    ]
  end

  @impl true
  def handle(:pc_toggle, socket),
    do: Mob.Socket.assign(socket, :pc_open, not socket.assigns.pc_open)

  def handle(:pc_prev, socket), do: bump(socket)
  def handle(:pc_next, socket), do: bump(socket)
  def handle(_tag, socket), do: socket

  defp bump(socket), do: Mob.Socket.assign(socket, :pc_nudges, socket.assigns.pc_nudges + 1)

  defp follow do
    %{
      type: :button,
      props: %{
        text: "Follow",
        background: :primary,
        text_color: :on_primary,
        padding: :space_sm,
        on_tap: {self(), :pc_noop}
      },
      children: []
    }
  end

  defp message do
    %{
      type: :button,
      props: %{
        text: "Message",
        background: :surface_raised,
        text_color: :on_surface,
        padding: :space_sm,
        on_tap: {self(), :pc_noop}
      },
      children: []
    }
  end

  defp gap, do: %{type: :spacer, props: %{size: 8}, children: []}

  defp rail do
    tiles =
      Enum.flat_map(1..10, fn i ->
        [
          %{
            type: :box,
            props: %{
              width: 100,
              height: 60,
              background: if(rem(i, 2) == 0, do: :primary, else: :surface_raised),
              corner_radius: :radius_md
            },
            children: []
          },
          %{type: :spacer, props: %{size: 8}, children: []}
        ]
      end)

    %{type: :row, props: %{}, children: tiles}
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Box
      fill_width={true}
      background={:surface}
      corner_radius={:radius_md}
      border_color={:border}
      border_width={1}
      padding={8}
    >
      <Row fill_width={true}>
        <Box width={30} height={30} corner_radius={15} background={:primary} />
        <Spacer size={8} />
        <Column fill_width={true}>
          <Box width={54} height={8} background={:muted} corner_radius={:radius_sm} />
          <Spacer size={5} />
          <Box width={40} height={6} background={:surface_raised} corner_radius={:radius_sm} />
        </Column>
      </Row>
    </Box>
    """
  end
end
