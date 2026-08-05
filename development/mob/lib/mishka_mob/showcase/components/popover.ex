defmodule MishkaMob.Showcase.Components.Popover do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaPopover`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaPopover
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :popover,
      name: "Popover",
      category: "Overlays",
      order: 3,
      description: "A trigger that toggles a panel of content beside it."
    }
  end

  # One assign per example. Sharing them would mean a device test could not say
  # which trigger it just pressed — every example would move together.
  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:pop_details, false)
    |> Mob.Socket.assign(:pop_hold, false)
    |> Mob.Socket.assign(:pop_above, false)
    |> Mob.Socket.assign(:pop_beside, false)
    |> Mob.Socket.assign(:pop_aligned, false)
    |> Mob.Socket.assign(:pop_off, false)
    |> Mob.Socket.assign(:pop_data, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Tap the trigger",
        description:
          "The whole anatomy: a trigger that reads as pressed while its panel is up, " <>
            "a title, a description, a beak pointing back at the trigger, and a close action.",
        code: ~S"""
        # Every part is a SLOT TAG, like Chelekom's <:trigger>, <:title> and the
        # rest. Order does not matter — each is placed where the anatomy says.
        <MishkaPopover id="details" open={@open?} on_open_change={:details}>
          <MishkaPopoverTrigger text="Order details" />
          <MishkaPopoverTitle text="Shipped 2 days ago" />
          <MishkaPopoverDescription text="Tracking arrives by email." />
          <MishkaPopoverArrow />
          <MishkaPopoverClose text="Got it" />
          {content}
        </MishkaPopover>

        # The trigger sends the state it wants, so one clause serves the
        # trigger, the long press and the footer's close button alike.
        def handle_info({:tap, {:details, open?}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :open?, open?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPopover id="pop" open={@pop_details} on_open_change={:pop_details}>
              <MishkaPopoverTrigger text="Order details" />
              <MishkaPopoverTitle text="Shipped 2 days ago" />
              <MishkaPopoverDescription text="Tracking arrives by email." />
              <MishkaPopoverArrow />
              <MishkaPopoverClose text="Got it" />
              {body()}
            </MishkaPopover>
          </Column>
          """
        end
      },
      %Example{
        title: "Hold to open",
        description:
          "open_on_hold is the port of open_on_hover — a long press is what a touch screen " <>
            "has instead of a pointer resting on something. The tap still toggles.",
        code: ~S"""
        <MishkaPopover id="hint" open={@open?} open_on_hold={true} on_open_change={:hint}>
          <MishkaPopoverTrigger text="Press and hold me" />
          {content}
        </MishkaPopover>

        # A hold always sends true; only the tap sends the opposite of now.
        def handle_info({:tap, {:hint, open?}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :open?, open?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPopover id="hold" open={@pop_hold} open_on_hold={true} on_open_change={:pop_hold}>
              <MishkaPopoverTrigger text="Press and hold me" />
              {[line("A hold opens it. A tap toggles it.")]}
            </MishkaPopover>
          </Column>
          """
        end
      },
      %Example{
        title: "Which side it takes",
        description:
          "side puts the panel before or after its trigger in the same flow container, " <>
            "and side_offset is the gap. :top and :bottom stack; :left and :right sit abreast.",
        code: ~S"""
        <MishkaPopover id="up" open={@up?} side={:top} side_offset={12} on_open_change={:up}>
          <MishkaPopoverTrigger text="Above" />
          {content}
        </MishkaPopover>

        <MishkaPopover id="next" open={@next?} side={:right} on_open_change={:next}>
          <MishkaPopoverTrigger text="Beside" />
          {content}
        </MishkaPopover>

        def handle_info({:tap, {:up, open?}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :up?, open?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPopover
              id="above"
              open={@pop_above}
              side={:top}
              side_offset={12}
              on_open_change={:pop_above}
            >
              <MishkaPopoverTrigger text="Panel above" />
              {[line("This panel sits above its trigger.")]}
            </MishkaPopover>
            <Spacer size={12} />
            <MishkaPopover
              id="beside"
              open={@pop_beside}
              side={:right}
              align={:center}
              on_open_change={:pop_beside}
            >
              <MishkaPopoverTrigger text="Beside" />
              {[line("And this one sits to its right.")]}
            </MishkaPopover>
          </Column>
          """
        end
      },
      %Example{
        title: "A narrow panel has somewhere to go",
        description:
          "align only bites once width makes the panel narrower than its parent — " <>
            "a panel that fills looks identical at every alignment. align_offset nudges it.",
        code: ~S"""
        <MishkaPopover
          id="menu"
          open={@open?}
          width={220}
          align={:end}
          align_offset={-4}
          on_open_change={:menu}
        >
          <MishkaPopoverTrigger text="Trailing edge" />
          {content}
        </MishkaPopover>

        def handle_info({:tap, {:menu, open?}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :open?, open?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPopover
              id="aligned"
              open={@pop_aligned}
              width={220}
              align={:end}
              align_offset={-4}
              on_open_change={:pop_aligned}
            >
              <MishkaPopoverTrigger text="Trailing edge" />
              {[line("220dp wide, pushed to the trailing edge.")]}
            </MishkaPopover>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled, and without a chevron",
        description:
          "disabled wires no handler at all, so the trigger cannot fire. " <>
            "chevron={false} drops the ▾ when the panel itself is indication enough.",
        code: ~S"""
        <MishkaPopover
          id="off"
          open={@open?}
          disabled={true}
          chevron={false}
          on_open_change={:off}
        >
          <MishkaPopoverTrigger text="Unavailable" />
          {content}
        </MishkaPopover>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPopover
              id="off"
              open={@pop_off}
              disabled={true}
              chevron={false}
              on_open_change={:pop_off}
            >
              <MishkaPopoverTrigger text="Unavailable" />
              {[line("You will never see this.")]}
            </MishkaPopover>
          </Column>
          """
        end
      },
      %Example{
        title: "Chrome",
        description:
          "background, color, muted_color, corner_radius, padding and the border are props — " <>
            "set the ink whenever you set the fill, or the title keeps the theme's near-black.",
        code: ~S"""
        <MishkaPopover
          open={true}
          background={0xFF1E1B4B}
          color={0xFFFFFFFF}
          muted_color={0xFFC7D2FE}
          border_width={0}
          corner_radius={:radius_lg}
        >
          <MishkaPopoverTitle text="Any colour works" />
        </MishkaPopover>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPopover
              id="chrome"
              open={true}
              background={0xFF1E1B4B}
              color={0xFFFFFFFF}
              muted_color={0xFFC7D2FE}
              border_width={0}
              corner_radius={:radius_lg}
              padding={:space_lg}
            >
              <MishkaPopoverTitle text="Any colour works" />
              <MishkaPopoverDescription text="But then the ink is yours to set too." />
            </MishkaPopover>
          </Column>
          """
        end
      },
      %Example{
        title: "Parts built from data",
        description:
          "The tag and the function build the identical node, so when the parts come from a " <>
            "list the function is the right form — a comprehension can return trigger/1, and " <>
            "there is no way to write a tag from one.",
        code: ~S"""
        alias MishkaMob.Components.MishkaPopover

        rows = Enum.map(@parcels, &line/1)

        # Slot nodes are ordinary nodes, so they travel in the same list as the
        # body and land in the same places the tags would.
        <MishkaPopover id="order" open={@open?} on_open_change={:order}>
          {[
            MishkaPopover.trigger("#{length(@parcels)} parcels"),
            MishkaPopover.title(@order.status),
            MishkaPopover.close("Got it") | rows
          ]}
        </MishkaPopover>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPopover id="data" open={@pop_data} on_open_change={:pop_data}>
              {from_data()}
            </MishkaPopover>
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
          "Root testTag. Parts derive theirs: -trigger-open/-closed, -panel, -title, -desc, -close, -arrow."
      },
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the panel is shown. Lives in the screen."
      },
      %{
        name: "trigger",
        type: "string / node",
        default: "nil",
        description: "Shorthand for <MishkaPopoverTrigger>. Omit both and you place your own."
      },
      %{
        name: "on_open_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, next_open?}} by trigger, hold and close alike."
      },
      %{
        name: "open_on_hold",
        type: "boolean",
        default: "false",
        description: "A long press on the trigger opens it — the port of open_on_hover."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Wires no handler, so the trigger is inert."
      },
      %{
        name: "chevron",
        type: "boolean",
        default: "true",
        description: "Show the ▾/▴ indicator on the trigger."
      },
      %{
        name: "side",
        type: ":top :right :bottom :left",
        default: ":bottom",
        description: "Which side of the trigger the panel takes, in flow."
      },
      %{
        name: "align",
        type: ":start :center :end",
        default: ":start",
        description: "Where the panel sits across that axis. Only bites once width is set."
      },
      %{
        name: "side_offset",
        type: "number",
        default: "8",
        description: "Gap between trigger and panel, in dp."
      },
      %{
        name: "align_offset",
        type: "number",
        default: "nil",
        description: "Nudge along the alignment axis, in dp."
      },
      %{
        name: "title / description",
        type: "string",
        default: "nil",
        description: "Shorthand for <MishkaPopoverTitle> and <MishkaPopoverDescription>."
      },
      %{
        name: "close",
        type: "string",
        default: "nil",
        description:
          "Shorthand for <MishkaPopoverClose> — a footer action that reports it closed."
      },
      %{
        name: "arrow",
        type: "boolean",
        default: "false",
        description: "Shorthand for <MishkaPopoverArrow> — a beak pointing back at the trigger."
      },
      %{
        name: "width",
        type: "number",
        default: "nil",
        description: "Panel width. Omit to fill the parent."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface",
        description: "Panel fill."
      },
      %{
        name: "color / muted_color",
        type: "color / ARGB",
        default: ":on_surface / :muted",
        description: "Title ink, and the description's. Set them whenever you set background."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: ":radius_md",
        description: "Panel corners."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_md",
        description: "Padding inside the panel."
      },
      %{
        name: "border_color / border_width",
        type: "color / number",
        default: ":border / 1",
        description: "The edge separating it from the content beneath."
      },
      %{
        name: "offset_x / offset_y",
        type: "number",
        default: "nil",
        description: "Static nudge in dp. Wins over align_offset."
      },
      %{
        name: "<MishkaPopoverTrigger>",
        type: "slot",
        default: "—",
        description: "The control that toggles it. text=\"…\", or your own markup. trigger/1."
      },
      %{
        name: "<MishkaPopoverTitle>",
        type: "slot",
        default: "—",
        description: "The heading inside the panel. title/1."
      },
      %{
        name: "<MishkaPopoverDescription>",
        type: "slot",
        default: "—",
        description: "The line under the heading. description/1."
      },
      %{
        name: "<MishkaPopoverClose>",
        type: "slot",
        default: "—",
        description:
          "A label builds the wired footer button; markup puts your own there. close/1."
      },
      %{
        name: "<MishkaPopoverArrow>",
        type: "slot",
        default: "—",
        description: "Written bare it draws the side's glyph; give it one of your own. arrow/0."
      }
    ]
  end

  # One clause per example, because each owns its own assign — the whole reason
  # the assigns are not shared is that a device test has to be able to say which
  # trigger it pressed.
  @impl true
  def handle({:pop_details, open?}, socket), do: Mob.Socket.assign(socket, :pop_details, open?)
  def handle({:pop_hold, open?}, socket), do: Mob.Socket.assign(socket, :pop_hold, open?)
  def handle({:pop_above, open?}, socket), do: Mob.Socket.assign(socket, :pop_above, open?)
  def handle({:pop_beside, open?}, socket), do: Mob.Socket.assign(socket, :pop_beside, open?)
  def handle({:pop_aligned, open?}, socket), do: Mob.Socket.assign(socket, :pop_aligned, open?)

  # `off` is disabled, so nothing ever sends this — the clause exists so the
  # example is wired exactly like the others and only `disabled` differs.
  def handle({:pop_off, open?}, socket), do: Mob.Socket.assign(socket, :pop_off, open?)

  def handle({:pop_data, open?}, socket), do: Mob.Socket.assign(socket, :pop_data, open?)

  def handle(_tag, socket), do: socket

  # The function form, and the case it is for: the rows come from a list, so
  # they are mapped — and the slots ride along in the same list, because a slot
  # node is an ordinary node and nothing about it has to be written as markup.
  defp from_data do
    parcels = ["Left the warehouse", "In transit", "Out for delivery"]

    [
      MishkaPopover.trigger("#{length(parcels)} parcels"),
      MishkaPopover.title("Order #4821"),
      MishkaPopover.close("Got it") | Enum.map(parcels, &line/1)
    ]
  end

  defp body do
    [
      line("Two of three parcels have left the warehouse."),
      %{type: :spacer, props: %{size: 4}, children: []},
      %{
        type: :text,
        props: %{text: "Order #4821", text_size: :sm, text_color: :muted},
        children: []
      }
    ]
  end

  defp line(text) do
    %{type: :text, props: %{text: text, text_size: :base, text_color: :on_surface}, children: []}
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box width={70} height={20} background={:primary} corner_radius={:radius_sm} />
      <Spacer size={4} />
      <Text text="▲" text_size={:sm} text_color={:surface} />
      <Box
        fill_width={true}
        background={:surface}
        corner_radius={:radius_md}
        border_color={:border}
        border_width={1}
        padding={8}
      >
        <Column fill_width={true}>
          <Box width={70} height={7} background={:muted} corner_radius={:radius_sm} />
          <Spacer size={5} />
          <Box fill_width={true} height={6} background={:surface_raised} corner_radius={:radius_sm} />
        </Column>
      </Box>
    </Column>
    """
  end
end
