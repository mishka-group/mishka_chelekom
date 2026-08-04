defmodule MishkaMob.Showcase.Components.PreviewCard do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaPreviewCard` and
  `MishkaMob.Components.MishkaScroller`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaScroller
  alias MishkaMob.Showcase.Example

  # Two of them, because one trigger can only prove that a card opens — two prove
  # that opening the second closes the first, which is what a screen owning a
  # single `open` assign actually does.
  @entries [
    {"pc-elixir", "Elixir", "@elixir-lang", "EX",
     "A dynamic, functional language for building scalable and maintainable applications."},
    {"pc-phoenix", "Phoenix", "@phoenixframework", "PX",
     "A productive web framework that does not compromise speed or maintainability."}
  ]

  @impl true
  def entry do
    %{
      slug: :preview_card,
      name: "Preview Card",
      category: "Overlays",
      order: 5,
      # ScrollerTest finds this page by the rail half of this sentence, and the
      # rail really does live here — one page, two components.
      description: "Hold a name to reveal its card of detail, plus a horizontal scroller rail."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:pc_open, nil)
    |> Mob.Socket.assign(:pc_visited, nil)
    |> Mob.Socket.assign(:pc_followed, nil)
    |> Mob.Socket.assign(:pc_top, false)
    |> Mob.Socket.assign(:pc_side, false)
    |> Mob.Socket.assign(:pc_nudges, 0)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Hold a name — the touch hover",
        description:
          "Press and hold either name to reveal its card, as the web reveals it on hover. " <>
            "A plain tap passes straight through to on_tap, because the web trigger is a link.",
        code: ~S"""
        <MishkaPreviewCard
          id={id}
          open={@open == id}
          on_hold={:hold}
          on_tap={:visit}
          arrow={true}
          title={name}
          subtitle={handle}
          initials={initials}
          avatar_color={0xFF7C3AED}
          description={blurb}
        >
          <MishkaPreviewCardTrigger>
            {name_chip(name)}
          </MishkaPreviewCardTrigger>
          {[follow_button(id)]}
        </MishkaPreviewCard>

        # The tag is the form to reach for. A whole LIST of cards comes out of
        # DATA instead, and then there is no markup to hang a tag in: the
        # `trigger` prop takes the node the same helper already built. Both
        # forms end up in trigger/3, so the tree is identical either way.
        Enum.map(@people, fn {id, name} ->
          preview_card(%{id: id, open: @open == id, trigger: name_chip(name), on_hold: :hold})
        end)

        # The card owns no state. A hold ASKS for a change and the screen
        # decides — here holding the open one closes it and holding the other
        # moves the card, so only ever one is open.
        def handle_info({:tap, {:hold, id}}, socket) do
          next = if socket.assigns.open == id, do: nil, else: id
          {:noreply, Mob.Socket.assign(socket, :open, next)}
        end

        # The tap the long press did NOT swallow — a link still follows.
        def handle_info({:tap, {:visit, id}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :visited, id)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {cards(@pc_open, @pc_followed)}
            <Spacer size={10} />
            <Text
              id={"pc-visited-" <> slug(@pc_visited)}
              text={"Tapped: " <> slug(@pc_visited)}
              text_size={:sm}
              text_color={:muted}
              max_lines={1}
            />
            <Spacer size={4} />
            <Text
              id={"pc-followed-" <> slug(@pc_followed)}
              text={"Followed: " <> slug(@pc_followed)}
              text_size={:sm}
              text_color={:muted}
              max_lines={1}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Above the trigger",
        description:
          "side={:top} puts the card over the trigger instead of under it, align={:end} moves " <>
            "the arrow to the far edge, and side_offset is the real gap between the two.",
        code: ~S"""
        <MishkaPreviewCard
          id="pc-top"
          open={@top?}
          side={:top}
          align={:end}
          side_offset={14}
          align_offset={6}
          arrow={true}
          arrow_color={:primary}
          on_hold={:top_hold}
          title="Anchored upward"
        >
          <MishkaPreviewCardTrigger>
            {hint("Hold for the card above")}
          </MishkaPreviewCardTrigger>
        </MishkaPreviewCard>

        def handle_info({:tap, {:top_hold, _id}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :top?, not socket.assigns.top?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPreviewCard
              id="pc-top"
              open={@pc_top}
              side={:top}
              align={:end}
              side_offset={14}
              align_offset={6}
              arrow={true}
              arrow_color={:primary}
              on_hold={:pc_top_hold}
              title="Anchored upward"
              subtitle="side={:top}"
              initials="UP"
              description="The arrow points down at the trigger, because the card took the side above it."
            >
              <MishkaPreviewCardTrigger>
                {hint("Hold for the card above")}
              </MishkaPreviewCardTrigger>
            </MishkaPreviewCard>
          </Column>
          """
        end
      },
      %Example{
        title: "Beside the trigger",
        description:
          "side={:right} lays the pair out as a Row. Both halves carry a weight, so on a phone " <>
            "that is about half the width each — offered because the web offers it.",
        code: ~S"""
        <MishkaPreviewCard
          id="pc-side"
          open={@side?}
          side={:right}
          align={:start}
          arrow={true}
          on_hold={:side_hold}
          title="Beside"
        >
          <MishkaPreviewCardTrigger>{hint("Hold me")}</MishkaPreviewCardTrigger>
        </MishkaPreviewCard>

        def handle_info({:tap, {:side_hold, _id}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :side?, not socket.assigns.side?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPreviewCard
              id="pc-side"
              open={@pc_side}
              side={:right}
              align={:start}
              arrow={true}
              on_hold={:pc_side_hold}
              title="Beside"
              subtitle="side={:right}"
              description="Cramped, and honest about it."
            >
              <MishkaPreviewCardTrigger>
                {hint("Hold me")}
              </MishkaPreviewCardTrigger>
            </MishkaPreviewCard>
          </Column>
          """
        end
      },
      %Example{
        title: "Pinned open, no trigger",
        description:
          "Leave trigger out and it is the popup alone — the shape for a screen that already " <>
            "knows what to preview. image gives the avatar a picture instead of initials.",
        code: ~S"""
        <MishkaPreviewCard
          id="pc-static"
          open={true}
          image="https://avatars.githubusercontent.com/u/1481354"
          title="Ecto"
          subtitle="elixir-ecto/ecto"
          description="A toolkit for data mapping and queries."
          padding={:space_lg}
          corner_radius={:radius_lg}
        />

        # Nothing to handle — with no trigger there is nothing to hold, and
        # `open` is a constant.
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPreviewCard
              id="pc-static"
              open={true}
              image="https://avatars.githubusercontent.com/u/1481354"
              title="Ecto"
              subtitle="elixir-ecto/ecto"
              description="A toolkit for data mapping and queries."
              padding={:space_lg}
              corner_radius={:radius_lg}
            />
            <Spacer size={10} />
            <MishkaPreviewCard id="pc-bare" open={true} title="Every part is optional" />
          </Column>
          """
        end
      },
      %Example{
        title: "Scroller",
        description: "A horizontal rail. The arrows move it — press one instead of swiping.",
        code: ~S"""
        <MishkaScroller id="gallery" on_prev={:back} on_next={:fwd} height={76}>
          {[rail()]}
        </MishkaScroller>

        # Scrolling is a side effect on a live widget, so there is no assign to
        # set and nothing re-renders — nudge/3 reads the rail's current offset
        # and drives the native scroll view to a new one.
        def handle_info({:tap, :fwd}, socket) do
          MishkaScroller.nudge("gallery", :next)
          {:noreply, socket}
        end

        def handle_info({:tap, :back}, socket) do
          MishkaScroller.nudge("gallery", :prev)
          {:noreply, socket}
        end
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
        name: "id",
        type: "string",
        default: "nil",
        description:
          "testTag root — <id>-open / -closed / -trigger / -popup-<side> / -arrow-<align> — " <>
            "and the value on_hold and on_tap report."
      },
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the card is shown. The trigger renders either way."
      },
      %{
        name: "<MishkaPreviewCardTrigger>",
        type: "slot",
        default: "—",
        description:
          "What you hold, as markup. The card wires the hold — the tag takes no props of its own."
      },
      %{
        name: "trigger",
        type: "node / [node]",
        default: "nil",
        description:
          "The same slot as data, for a card built by Enum.map with no markup to hang a tag in. " <>
            "Omit both and only the popup renders."
      },
      %{
        name: "on_hold",
        type: "event tag",
        default: "nil",
        description: "Long press on the trigger — {:tap, {tag, id}}. The touch hover."
      },
      %{
        name: "on_tap",
        type: "event tag",
        default: "nil",
        description: "Plain tap on the trigger — {:tap, {tag, id}}. The link still follows."
      },
      %{
        name: "side",
        type: ":bottom :top :left :right",
        default: ":bottom",
        description: "Column for top/bottom, Row for left/right."
      },
      %{
        name: "align",
        type: ":start :center :end",
        default: ":center",
        description: "Where the arrow sits along the card's facing edge."
      },
      %{
        name: "side_offset / align_offset",
        type: "number",
        default: "8 / 0",
        description: "The gap between the pair, and a nudge along the alignment axis."
      },
      %{
        name: "arrow / arrow_color",
        type: "boolean / color",
        default: "false / :border",
        description: "The pointer back at the trigger."
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
        description: "Avatar content — it uses MishkaAvatar. Omit both and there is no avatar."
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

  # A hold ASKS for a change; the screen decides what it means. Holding the open
  # one closes it, holding the other moves the card — one `open` assign, so only
  # ever one card.
  @impl true
  def handle({:pc_hold, id}, socket) do
    next = if socket.assigns.pc_open == id, do: nil, else: id
    Mob.Socket.assign(socket, :pc_open, next)
  end

  # The tap the long press did not swallow.
  def handle({:pc_visit, id}, socket), do: Mob.Socket.assign(socket, :pc_visited, id)

  def handle({:pc_follow, id}, socket) do
    next = if socket.assigns.pc_followed == id, do: nil, else: id
    Mob.Socket.assign(socket, :pc_followed, next)
  end

  def handle({:pc_top_hold, _id}, socket),
    do: Mob.Socket.assign(socket, :pc_top, not socket.assigns.pc_top)

  def handle({:pc_side_hold, _id}, socket),
    do: Mob.Socket.assign(socket, :pc_side, not socket.assigns.pc_side)

  # The arrows move the rail. They used only to count their own taps, which
  # looked wired up while the one thing this component exists for — pressing ‹
  # or › instead of swiping — did nothing at all. `nudge/3` is the side effect;
  # the counter stays, as the visible difference between "the arrow is dead"
  # and "the rail is already at the end and cannot go further".
  def handle(:pc_prev, socket), do: nudge_rail(:prev, socket)
  def handle(:pc_next, socket), do: nudge_rail(:next, socket)
  def handle(_tag, socket), do: socket

  defp nudge_rail(direction, socket) do
    MishkaScroller.nudge("gallery", direction)
    Mob.Socket.assign(socket, :pc_nudges, socket.assigns.pc_nudges + 1)
  end

  defp cards(open, followed) do
    @entries
    |> Enum.map(&card(&1, open, followed))
    |> Enum.intersperse(%{type: :spacer, props: %{size: 10}, children: []})
  end

  defp card({id, name, handle, initials, blurb}, open, followed) do
    ~MOB"""
    <MishkaPreviewCard
      id={id}
      open={open == id}
      on_hold={:pc_hold}
      on_tap={:pc_visit}
      arrow={true}
      title={name}
      subtitle={handle}
      initials={initials}
      avatar_color={0xFF7C3AED}
      description={blurb}
    >
      <MishkaPreviewCardTrigger>
        {name_chip(name)}
      </MishkaPreviewCardTrigger>
      {[follow_button(id, followed == id)]}
    </MishkaPreviewCard>
    """
  end

  # A long press is invisible unless something says so, so the chip says so.
  defp name_chip(name) do
    ~MOB"""
    <Box
      fill_width={true}
      background={:surface}
      corner_radius={:radius_md}
      border_color={:border}
      border_width={1}
      padding={10}
    >
      <Row fill_width={true}>
        <Box weight={1}>
          <Text text={name} text_size={:base} text_color={:primary} max_lines={1} />
        </Box>
        <Text text="hold" text_size={:sm} text_color={:muted} max_lines={1} />
      </Row>
    </Box>
    """
  end

  defp hint(text) do
    ~MOB"""
    <Box fill_width={true} background={:surface_raised} corner_radius={:radius_md} padding={10}>
      <Text text={text} text_size={:sm} text_color={:on_surface} max_lines={1} />
    </Box>
    """
  end

  # The state goes in the tag as well as in the label: "Following" and "Follow"
  # differ by a word and a colour, and a device test can read neither off a
  # button that merges its own text.
  defp follow_button(id, following?) do
    %{
      type: :button,
      props: %{
        id: id <> if(following?, do: "-follow-on", else: "-follow-off"),
        text: if(following?, do: "Following", else: "Follow"),
        background: if(following?, do: :surface_raised, else: :primary),
        text_color: if(following?, do: :on_surface, else: :on_primary),
        padding: :space_sm,
        on_tap: {self(), {:pc_follow, id}}
      },
      children: []
    }
  end

  # The readouts fold their value into their own tag: "nothing has been tapped"
  # and "Phoenix was tapped" differ only by a word inside a Text, and the e2e
  # reads tags rather than a page whose code samples are text nodes too.
  defp slug(nil), do: "none"
  defp slug(id), do: id

  # Each tile is numbered. A scrolled rail does not move its own container —
  # only its contents slide under it — so the tiles are the only thing whose
  # position can witness a nudge, and a device test needs to name one.
  defp rail do
    tiles =
      Enum.flat_map(1..10, fn i ->
        [
          %{
            type: :box,
            props: %{
              id: "gallery-tile-#{i}",
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
    <Column fill_width={true}>
      <Box fill_width={true} background={:surface_raised} corner_radius={:radius_sm} padding={5}>
        <Box width={46} height={7} background={:primary} corner_radius={:radius_sm} />
      </Box>
      <Spacer size={5} />
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
          <Box weight={1}>
            <Column fill_width={true}>
              <Box width={54} height={8} background={:muted} corner_radius={:radius_sm} />
              <Spacer size={5} />
              <Box width={40} height={6} background={:surface_raised} corner_radius={:radius_sm} />
            </Column>
          </Box>
        </Row>
      </Box>
    </Column>
    """
  end
end
