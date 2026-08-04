defmodule MishkaMob.Showcase.Components.Drawer do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaDrawer`.

  Every example card shows only its trigger; the drawers themselves are
  rendered by `overlay/1` at the screen root, so a panel stacks over the whole
  page. Each example owns its own `open?` assign — a shared one would mean a
  device test could not say which example it had just opened.

  That split is also why the openers here are `MishkaDrawer.trigger/2` calls
  rather than `<MishkaDrawerTrigger>` tags: the slot is drawn by the drawer, in
  the drawer's own place, and these drawers live at the root while their buttons
  live inside a scrolling card. The builder returns exactly the node the tag
  builds, so the gallery loses nothing but the markup — and the code samples
  lead with the tag, which is what an app with one drawer per screen should
  write. `<MishkaDrawerFooter>` has no such tension and is used for real, by the
  undismissable sheet whose only way out is its footer.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaDrawer
  alias MishkaMob.Showcase.Example

  # The bottom sheet's snap points, written as fractions of an extent to
  # exercise both forms: a composite cannot measure the viewport, so `extent` is
  # how the caller says what the fraction is of. These resolve to 180/300/440dp.
  @sheet_snaps [0.36, 0.6, 0.88]
  @sheet_extent 500
  @sheet [
    side: :bottom,
    snap_points: @sheet_snaps,
    extent: @sheet_extent,
    snap_sequential: true,
    threshold: 48
  ]

  # Which assign each example's drawer opens. Static rather than built from the
  # tag, because a dynamically-derived assign name is a typo waiting to happen.
  @opens %{
    side: :side_open?,
    size: :size_open?,
    sheet: :sheet_open?,
    head: :head_open?,
    skin: :skin_open?,
    chrome: :chrome_open?,
    locked: :locked_open?,
    bare: :bare_open?,
    edge: :edge_open?
  }

  @impl true
  def entry do
    %{
      slug: :drawer,
      name: "Drawer",
      category: "Overlays",
      order: 0,
      description: "An edge-anchored panel that slides in over a dimmed backdrop."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:side_open?, false)
    |> Mob.Socket.assign(:side, :right)
    |> Mob.Socket.assign(:size_open?, false)
    |> Mob.Socket.assign(:size, :lg)
    |> Mob.Socket.assign(:sheet_open?, false)
    |> Mob.Socket.assign(:sheet_snap, 300)
    |> Mob.Socket.assign(:sheet_grab, nil)
    |> Mob.Socket.assign(:head_open?, false)
    |> Mob.Socket.assign(:skin_open?, false)
    |> Mob.Socket.assign(:chrome_open?, false)
    |> Mob.Socket.assign(:locked_open?, false)
    |> Mob.Socket.assign(:bare_open?, false)
    |> Mob.Socket.assign(:edge_open?, false)
    |> Mob.Socket.assign(:edge_grab, nil)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A trigger, and any side",
        description:
          "<MishkaDrawerTrigger> is the web's <:trigger> slot — it is what a CLOSED drawer " <>
            "draws, so it stands in the drawer's own place until the overlay wants it.",
        code: ~S"""
        # The opener as markup. A closed drawer renders nothing, which is exactly
        # the room the slot needs — so put the tag where the button belongs, and
        # somewhere that can hand the overlay the whole screen when it opens.
        <MishkaDrawer id="menu" open={@menu_open?} side={:left} title="Menu"
                      on_close={:close_menu}>
          <MishkaDrawerTrigger label="Menu" on_open={:open_menu} id="menu-open" />
          {menu_item("👤", "Profile")}
        </MishkaDrawer>

        # This gallery cannot use the slot, and the reason is worth knowing: its
        # triggers sit in a scrolling card while every panel is stacked at the
        # screen root, and one node cannot be in both places. trigger/2 builds
        # EXACTLY the node the tag builds — place it yourself, and `id` ties the
        # two together. It is also the only way to open one drawer from four
        # buttons, as this example does.
        {MishkaDrawer.trigger("Right", on_open: {:open_side, :right}, weight: 1)}

        <MishkaDrawer id="side" open={@side_open?} side={@side}
                      title="Menu" on_close={{:close, :side}}>
          {menu_item("👤", "Profile")}
        </MishkaDrawer>

        def handle_info({:tap, {:open_side, side}}, socket) do
          {:noreply, socket |> assign(:side, side) |> assign(:side_open?, true)}
        end

        def handle_info({:tap, {:close, :side}}, socket) do
          {:noreply, assign(socket, :side_open?, false)}
        end
        """,
        render: fn _assigns -> sides_preview() end
      },
      %Example{
        title: "Panel width",
        description:
          "size runs :xs to :xl (240–384dp). Top and bottom sheets ignore it. Five openers " <>
            "from one list — the case the builder is for.",
        code: ~S"""
        <MishkaDrawer id="size" open={@size_open?} side={:right} size={@size}
                      title="Width" on_close={{:close, :size}} />

        # When the children come from DATA, the function form is the right one:
        # a comprehension says this once, and generated markup cannot be written
        # at all. The tag is for a trigger you type; trigger/2 is for five.
        [:xs, :sm, :md, :lg, :xl]
        |> Enum.map(fn size ->
          MishkaDrawer.trigger(Atom.to_string(size),
            on_open: {:open_size, size},
            test_id: "size-open-#{size}",
            weight: 1
          )
        end)
        |> Enum.intersperse(gap(6))
        |> row()
        """,
        render: fn _assigns -> sizes_preview() end
      },
      %Example{
        title: "Bottom sheet — handle, snap points, swipe to dismiss",
        description:
          "Drag the pill. It moves one snap point per flick and dismisses from the smallest. " <>
            "The sheet settles when the finger lifts, not while it moves.",
        code: ~S"""
        <MishkaDrawer id="sheet" open={@sheet_open?} side={:bottom} handle={true}
                      snap_points={[0.36, 0.6, 0.88]} extent={500} snap={@sheet_snap}
                      snap_sequential={true} threshold={48} corner_radius={:radius_lg}
                      title="Filters" on_swipe={:sheet_swipe} on_close={{:close, :sheet}} />

        # A canvas is the only node that carries on_drag, so the handle is one —
        # and the fold lives in the screen, because a composite has no state.
        def handle_info({:drag, :sheet_swipe, payload}, socket) do
          {sheet, grab} =
            MishkaDrawer.swipe(payload, socket.assigns.sheet_grab,
              side: :bottom,
              snap_points: [0.36, 0.6, 0.88],
              extent: 500,
              snap_sequential: true,
              threshold: 48,
              open: socket.assigns.sheet_open?,
              snap: socket.assigns.sheet_snap
            )

          {:noreply,
           socket
           |> assign(:sheet_open?, sheet.open?)
           |> assign(:sheet_snap, sheet.snap)
           |> assign(:sheet_grab, grab)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {MishkaDrawer.trigger("Open the sheet", on_open: {:open, :sheet}, test_id: "sheet-open")}
            <Spacer size={10} />
            <Text text={snap_label(@sheet_snap)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Title, description, and the ✕",
        description: "The built-in header. The ✕ appears only when on_close is wired to it.",
        code: ~S"""
        <MishkaDrawer id="head" open={@head_open?} side={:right}
                      title="Notifications" description="Everything from the last week"
                      on_close={{:close, :head}} />
        """,
        render: fn _assigns ->
          MishkaDrawer.trigger("Open with a header",
            on_open: {:open, :head},
            test_id: "head-open"
          )
        end
      },
      %Example{
        title: "Custom colours",
        description: "Tint the panel and the backdrop with background + scrim_color.",
        code: ~S"""
        <MishkaDrawer id="skin" open={@skin_open?} side={:left} title="Account"
                      background={0xFF7C3AED} scrim_color={0x992E1065}
                      padding={:space_xl} corner_radius={:radius_lg}
                      on_close={{:close, :skin}} />
        """,
        render: fn _assigns ->
          MishkaDrawer.trigger("Open a coloured drawer",
            on_open: {:open, :skin},
            test_id: "skin-open"
          )
        end
      },
      %Example{
        title: "Custom chrome (header: false)",
        description:
          "Drop the built-in title/✕ and supply your own: a branded account card, a section " <>
            "label, and a highlighted current row.",
        code: ~S"""
        <MishkaDrawer id="chrome" open={@chrome_open?} side={:left} header={false}
                      corner_radius={:radius_lg} scrim_color={0x66000000}
                      on_close={{:close, :chrome}}>
          {account_card()}              # avatar + name + email, on brand violet
          {section_label("MENU")}
          {active_item("🏠", "Home")}    # highlighted "you are here" row
          {menu_item("🚪", "Sign out")}
        </MishkaDrawer>
        """,
        render: fn _assigns ->
          MishkaDrawer.trigger("Open custom chrome",
            on_open: {:open, :chrome},
            test_id: "chrome-open"
          )
        end
      },
      %Example{
        title: "Undismissable, and unblocking",
        description:
          "dismissible: false keeps the backdrop blocking but inert — only the ✕ closes it. " <>
            "scrim: false drops the backdrop entirely, so the page behind stays live. The way " <>
            "out is a <MishkaDrawerFooter>, which is what a drawer's own exit is.",
        code: ~S"""
        # The footer slot is the panel's bottom block: it gets its own
        # <id>-footer tag, and on a panel with a determined height — every side
        # drawer, and a sheet on a snap point — a weighted Spacer pushes it to
        # the floor. This sheet hugs its content, so it simply follows the body.
        <MishkaDrawer id="locked" open={@locked_open?} side={:bottom} dismissible={false}
                      title="Sign the waiver" on_close={{:close, :locked}}>
          <MishkaDrawerFooter>
            {done_row()}
          </MishkaDrawerFooter>
        </MishkaDrawer>

        # MishkaDrawer.footer/1 builds the same marker node, for a footer
        # assembled from data rather than typed:
        #   MishkaDrawer.footer(Enum.map(@actions, &action_row/1))

        <MishkaDrawer id="bare" open={@bare_open?} side={:right} scrim={false}
                      size={:sm} title="Inspector" on_close={{:close, :bare}} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {MishkaDrawer.trigger("Undismissable",
              on_open: {:open, :locked},
              test_id: "locked-open",
              weight: 1
            )}
            <Spacer size={8} />
            {MishkaDrawer.trigger("No scrim",
              on_open: {:open, :bare},
              test_id: "bare-open",
              weight: 1
            )}
          </Row>
          """
        end
      },
      %Example{
        title: "Swipe in from the edge",
        description:
          "swipe_area puts a drag patch on the screen edge while the drawer is closed — " <>
            "the faint pill on the left. Pull it in to open, and pull the handle back to close.",
        code: ~S"""
        <MishkaDrawer id="edge" open={@edge_open?} side={:left} swipe_area={true}
                      swipe_direction={:left} handle={true} title="Navigation"
                      on_swipe={:edge_swipe} on_close={{:close, :edge}} />

        # One fold serves both gestures: while the drawer is closed the payload
        # comes from the edge patch, where an inward drag opens it.
        def handle_info({:drag, :edge_swipe, payload}, socket) do
          {drawer, grab} =
            MishkaDrawer.swipe(payload, socket.assigns.edge_grab,
              side: :left, open: socket.assigns.edge_open?)

          {:noreply,
           socket
           |> assign(:edge_open?, drawer.open?)
           |> assign(:edge_grab, grab)}
        end
        """,
        render: fn _assigns ->
          MishkaDrawer.trigger("…or just tap here", on_open: {:open, :edge}, test_id: "edge-open")
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
        description:
          "Whether the drawer is shown. Lives in the screen — composites are stateless."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description:
          "Test tag. Parts get <id>-scrim, -panel, -title, -description, -close, -handle, " <>
            "-swipe-area, and -snap-<n> for the active snap point."
      },
      %{
        name: "side",
        type: ":left · :right · :top · :bottom",
        default: ":right",
        description: "Edge the panel is pinned to."
      },
      %{
        name: "size",
        type: ":xs :sm :md :lg :xl",
        default: ":lg",
        description: "Panel width for left/right (240–384). Ignored for top/bottom sheets."
      },
      %{
        name: "title",
        type: "string",
        default: "nil",
        description: "Header title, shown with a ✕ button when header is on."
      },
      %{
        name: "description",
        type: "string",
        default: "nil",
        description: "A muted line under the title."
      },
      %{
        name: "header",
        type: "boolean",
        default: "true",
        description: "Render the built-in title + description + ✕. False to supply your own."
      },
      %{
        name: "handle",
        type: "boolean",
        default: "false",
        description:
          "The drag pill. It IS the swipe surface — without it there is nothing to pull."
      },
      %{
        name: "handle_color",
        type: "ARGB int",
        default: "grey",
        description: "The pill's ink. An int, not a token: canvas ops take ints."
      },
      %{
        name: "scrim",
        type: "boolean",
        default: "true",
        description: "Dim the background. False is the web's modal={false} — nothing is blocked."
      },
      %{
        name: "scrim_color",
        type: "ARGB / token",
        default: "0x99000000",
        description: "Backdrop fill (alpha-first ARGB). Default is 60% black."
      },
      %{
        name: "dismissible",
        type: "boolean",
        default: "true",
        description: "Whether a backdrop tap closes it. False leaves it blocking but inert."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface",
        description: "Panel background."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_lg",
        description: "Padding inside the panel around your content."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: "none",
        description: "Rounds the panel corners, e.g. :radius_lg for a sheet."
      },
      %{
        name: "snap_points",
        type: "list",
        default: "[]",
        description: "Sheet heights in dp, or fractions of extent. Vertical sides only."
      },
      %{
        name: "snap / extent",
        type: "number",
        default: "smallest · nil",
        description:
          "The active point (the panel's height), and what a fraction is a fraction of."
      },
      %{
        name: "snap_sequential",
        type: "boolean",
        default: "false",
        description: "One snap point per flick, and no dismissal until the smallest."
      },
      %{
        name: "threshold",
        type: "number",
        default: "64",
        description: "How far a swipe must travel (dp) before it dismisses or opens."
      },
      %{
        name: "swipe_direction",
        type: ":up :down :left :right",
        default: "from side",
        description: "Which way a dismissing swipe goes."
      },
      %{
        name: "swipe_area",
        type: "boolean",
        default: "false",
        description: "While closed, a drag patch on the screen edge that opens the drawer."
      },
      %{
        name: "on_close",
        type: "event tag",
        default: "—",
        description: "{:tap, tag} on backdrop / ✕ tap. Provide it for tap-to-dismiss."
      },
      %{
        name: "on_swipe",
        type: "event tag",
        default: "—",
        description: "{:drag, tag, payload} from the handle or the edge. Fold it with swipe/3."
      },
      %{
        name: "<MishkaDrawerTrigger>",
        type: "slot",
        default: "—",
        description:
          "The opener, and what a CLOSED drawer draws. Takes label (or children), on_open, " <>
            "id, weight, fill_width. trigger/2 builds the same node."
      },
      %{
        name: "<MishkaDrawerFooter>",
        type: "slot",
        default: "—",
        description:
          "The panel's bottom block, tagged <id>-footer and pushed to the floor when the " <>
            "panel has a height. footer/1 builds the same node."
      },
      %{
        name: "trigger/2 · swipe/3",
        type: "helpers",
        default: "—",
        description: "The opener, and the fold that turns a drag payload into the next state."
      }
    ]
  end

  # Every drawer on the page, stacked at the screen root. Closed ones render an
  # empty node, so this costs nothing — and each carries its own assign, so a
  # device test can name the one it opened.
  #
  # The edge drawer comes first because its swipe area is the one part of a
  # CLOSED drawer that draws: last child wins in a Box, and a 16dp strip sitting
  # over another drawer's backdrop would be a live control on a dead surface.
  @impl true
  def overlay(assigns) do
    %{
      type: :box,
      props: %{fill_width: true, fill_height: true},
      children: [
        edge_drawer(assigns),
        side_drawer(assigns),
        size_drawer(assigns),
        sheet_drawer(assigns),
        head_drawer(assigns),
        skin_drawer(assigns),
        chrome_drawer(assigns),
        locked_drawer(assigns),
        bare_drawer(assigns)
      ]
    }
  end

  @impl true
  def handle({:open_side, side}, socket) do
    socket
    |> Mob.Socket.assign(:side, side)
    |> Mob.Socket.assign(:side_open?, true)
  end

  def handle({:open_size, size}, socket) do
    socket
    |> Mob.Socket.assign(:size, size)
    |> Mob.Socket.assign(:size_open?, true)
  end

  def handle({:open, key}, socket), do: set_open(socket, key, true)
  def handle({:close, key}, socket), do: set_open(socket, key, false)
  def handle(_tag, socket), do: socket

  # Every drag arrives here as {:drag, tag, payload}; ComponentScreen routes it
  # to handle_change/3 the same way it routes {:change, tag, value}.
  @impl true
  def handle_change(:sheet_swipe, payload, socket) do
    {sheet, grab} =
      MishkaDrawer.swipe(
        payload,
        socket.assigns.sheet_grab,
        @sheet ++ [open: socket.assigns.sheet_open?, snap: socket.assigns.sheet_snap]
      )

    socket
    |> Mob.Socket.assign(:sheet_open?, sheet.open?)
    |> Mob.Socket.assign(:sheet_snap, sheet.snap)
    |> Mob.Socket.assign(:sheet_grab, grab)
  end

  # Its own grab assign, not the sheet's — two examples sharing one would mean
  # a gesture on either moved both, and no test (or reader) could say which.
  def handle_change(:edge_swipe, payload, socket) do
    {drawer, grab} =
      MishkaDrawer.swipe(payload, socket.assigns.edge_grab,
        side: :left,
        open: socket.assigns.edge_open?
      )

    socket
    |> Mob.Socket.assign(:edge_open?, drawer.open?)
    |> Mob.Socket.assign(:edge_grab, grab)
  end

  def handle_change(_tag, _value, socket), do: socket

  # Read through functions, not `@sheet_snaps`, because inside ~MOB an `@name`
  # is an ASSIGN — a module attribute written there compiles to `assigns.name`
  # and blows up at render time on a key that was never assigned.
  defp sheet_snaps, do: @sheet_snaps
  defp sheet_extent, do: @sheet_extent

  defp set_open(socket, key, open?) do
    case Map.get(@opens, key) do
      nil -> socket
      assign -> Mob.Socket.assign(socket, assign, open?)
    end
  end

  # ── the drawers ──
  defp side_drawer(assigns) do
    ~MOB"""
    <MishkaDrawer id="side" open={@side_open?} side={@side} title="Menu" on_close={{:close, :side}}>
      {menu_items()}
    </MishkaDrawer>
    """
  end

  defp size_drawer(assigns) do
    ~MOB"""
    <MishkaDrawer
      id="size"
      open={@size_open?}
      side={:right}
      size={@size}
      title={size_label(@size)}
      on_close={{:close, :size}}
    >
      {menu_items()}
    </MishkaDrawer>
    """
  end

  defp sheet_drawer(assigns) do
    ~MOB"""
    <MishkaDrawer
      id="sheet"
      open={@sheet_open?}
      side={:bottom}
      handle={true}
      snap_points={sheet_snaps()}
      extent={sheet_extent()}
      snap={@sheet_snap}
      snap_sequential={true}
      threshold={48}
      corner_radius={:radius_lg}
      title="Filters"
      description="Drag the handle up or down"
      on_swipe={:sheet_swipe}
      on_close={{:close, :sheet}}
    >
      {menu_items()}
    </MishkaDrawer>
    """
  end

  defp head_drawer(assigns) do
    ~MOB"""
    <MishkaDrawer
      id="head"
      open={@head_open?}
      side={:right}
      title="Notifications"
      description="Everything from the last week"
      on_close={{:close, :head}}
    >
      {menu_items()}
    </MishkaDrawer>
    """
  end

  defp skin_drawer(assigns) do
    ~MOB"""
    <MishkaDrawer
      id="skin"
      open={@skin_open?}
      side={:left}
      title="Account"
      background={0xFF7C3AED}
      scrim_color={0x992E1065}
      padding={:space_xl}
      corner_radius={:radius_lg}
      on_close={{:close, :skin}}
    >
      {colored_items()}
    </MishkaDrawer>
    """
  end

  # Note the panel keeps the default :surface background — tinting it
  # :surface_raised made the (also :surface_raised) rows invisible, so the
  # custom drawer read as bare floating text.
  defp chrome_drawer(assigns) do
    ~MOB"""
    <MishkaDrawer
      id="chrome"
      open={@chrome_open?}
      side={:left}
      header={false}
      corner_radius={:radius_lg}
      scrim_color={0x66000000}
      on_close={{:close, :chrome}}
    >
      {custom_body()}
    </MishkaDrawer>
    """
  end

  defp locked_drawer(assigns) do
    ~MOB"""
    <MishkaDrawer
      id="locked"
      open={@locked_open?}
      side={:bottom}
      dismissible={false}
      corner_radius={:radius_lg}
      title="Sign the waiver"
      description="The backdrop will not let you out of this one"
      on_close={{:close, :locked}}
    >
      <MishkaDrawerFooter>
        {done_row()}
      </MishkaDrawerFooter>
    </MishkaDrawer>
    """
  end

  defp bare_drawer(assigns) do
    ~MOB"""
    <MishkaDrawer
      id="bare"
      open={@bare_open?}
      side={:right}
      scrim={false}
      size={:sm}
      title="Inspector"
      description="No backdrop — the page behind stays live"
      on_close={{:close, :bare}}
    >
      {menu_items()}
    </MishkaDrawer>
    """
  end

  defp edge_drawer(assigns) do
    ~MOB"""
    <MishkaDrawer
      id="edge"
      open={@edge_open?}
      side={:left}
      swipe_area={true}
      swipe_direction={:left}
      handle={true}
      size={:sm}
      title="Navigation"
      on_swipe={:edge_swipe}
      on_close={{:close, :edge}}
    >
      {menu_items()}
    </MishkaDrawer>
    """
  end

  # ── inline previews (rendered inside the example card) ──
  defp sides_preview do
    column([
      row([
        MishkaDrawer.trigger("Left",
          on_open: {:open_side, :left},
          test_id: "side-open-left",
          weight: 1
        ),
        gap(8),
        MishkaDrawer.trigger("Right",
          on_open: {:open_side, :right},
          test_id: "side-open-right",
          weight: 1
        )
      ]),
      gap(8),
      row([
        MishkaDrawer.trigger("Top",
          on_open: {:open_side, :top},
          test_id: "side-open-top",
          weight: 1
        ),
        gap(8),
        MishkaDrawer.trigger("Bottom",
          on_open: {:open_side, :bottom},
          test_id: "side-open-bottom",
          weight: 1
        )
      ])
    ])
  end

  defp sizes_preview do
    [:xs, :sm, :md, :lg, :xl]
    |> Enum.map(fn size ->
      MishkaDrawer.trigger(Atom.to_string(size),
        on_open: {:open_size, size},
        test_id: "size-open-#{size}",
        weight: 1
      )
    end)
    |> Enum.intersperse(gap(6))
    |> row()
  end

  defp size_label(size), do: "Width: #{size}"

  defp snap_label(nil), do: "No snap point"
  defp snap_label(snap), do: "Sheet height: #{round(snap)}dp"

  # ── drawer bodies ──
  #
  # Rows are tappable *boxes*, not buttons: a Material Button centres its label
  # (MobBridge.kt renders "button" -> MobButton), which read as floating centred
  # text. `on_tap` is wired as a clickable modifier for every node type except
  # button, so a Box gives the same tap with a left-aligned icon + label.
  defp menu_items do
    [
      menu_item("👤", "Profile"),
      gap(8),
      menu_item("⚙️", "Settings"),
      gap(8),
      menu_item("ℹ️", "About")
    ]
  end

  defp menu_item(icon, label) do
    row_item(icon, label, :surface_raised, :on_surface, nil)
  end

  # Items styled to sit on the violet panel of the "Custom colours" example.
  defp colored_items do
    [
      colored_item("👤", "Profile"),
      gap(8),
      colored_item("⚙️", "Settings"),
      gap(8),
      colored_item("ℹ️", "About")
    ]
  end

  defp colored_item(icon, label) do
    row_item(icon, label, 0x33_FF_FF_FF, 0xFF_FF_FF_FF, nil)
  end

  # The undismissable drawer's only way out, and the reason it is a real
  # example: with the backdrop inert, the panel has to carry its own exit.
  defp done_row do
    row_item("✔", "Done", :primary, :on_primary, "locked-done")
  end

  # One left-aligned, full-width, tappable row: [icon] [label].
  defp row_item(icon, label, background, text_color, test_id) do
    props =
      %{
        fill_width: true,
        background: background,
        corner_radius: :radius_md,
        padding: :space_md,
        on_tap: {self(), close_tag(test_id)}
      }
      |> then(&if test_id, do: Map.put(&1, :id, test_id), else: &1)

    %{
      type: :box,
      props: props,
      children: [
        row([
          %{type: :text, props: %{text: icon, text_size: :lg}, children: []},
          gap(12),
          %{
            type: :text,
            props: %{text: label, text_size: :lg, text_color: text_color, max_lines: 1},
            children: []
          }
        ])
      ]
    }
  end

  # A body row closes whichever drawer it belongs to; the plain menu rows are
  # decorative and close nothing, so they route to the ignored tag.
  defp close_tag("locked-done"), do: {:close, :locked}
  defp close_tag("chrome-signout"), do: {:close, :chrome}
  defp close_tag(_), do: :noop

  # What `header: false` is actually for: chrome you cannot get from the built-in
  # title + ✕ — a branded account card, a section label, and a highlighted
  # "current page" row.
  defp custom_body do
    [
      account_card(),
      gap(18),
      %{type: :text, props: %{text: "MENU", text_size: :xs, text_color: :muted}, children: []},
      gap(8),
      active_item("🏠", "Home"),
      gap(8),
      menu_item("👤", "Profile"),
      gap(8),
      menu_item("⚙️", "Settings"),
      gap(16),
      %{type: :box, props: %{fill_width: true, height: 1, background: :border}, children: []},
      gap(16),
      row_item("🚪", "Sign out", :surface_raised, :on_surface, "chrome-signout")
    ]
  end

  # A brand-coloured header card: avatar + name + email on violet.
  defp account_card do
    avatar = %{
      type: :box,
      props: %{
        width: 48,
        height: 48,
        background: 0x33_FF_FF_FF,
        corner_radius: :radius_pill,
        padding: 11
      },
      children: [
        %{
          type: :text,
          props: %{
            text: "SH",
            text_size: :lg,
            text_color: 0xFF_FF_FF_FF,
            fill_width: true,
            text_align: :center
          },
          children: []
        }
      ]
    }

    info =
      column([
        %{
          type: :text,
          props: %{text: "Shahryar", text_size: :lg, text_color: 0xFF_FF_FF_FF, max_lines: 1},
          children: []
        },
        gap(2),
        %{
          type: :text,
          props: %{
            text: "shahryar@mishka.tools",
            text_size: :sm,
            text_color: 0xCC_FF_FF_FF,
            max_lines: 1
          },
          children: []
        }
      ])

    %{
      type: :box,
      props: %{
        fill_width: true,
        background: 0xFF_7C_3A_ED,
        corner_radius: :radius_lg,
        padding: :space_md
      },
      children: [row([avatar, gap(12), weighted(info)])]
    }
  end

  # The "you are here" row — a tinted background + coloured label, the sort of
  # state a drawer owns and the built-in chrome has no concept of.
  defp active_item(icon, label) do
    row_item(icon, label, 0x1A_7C_3A_ED, 0xFF_7C_3A_ED, nil)
  end

  # ── card-face pieces ──
  @impl true
  def card_preview do
    dots = %{type: :row, props: %{}, children: [dot(), gap(4), dot(), gap(4), dot()]}

    panel = %{
      type: :box,
      props: %{
        width: 66,
        height: 56,
        background: :muted,
        corner_radius: :radius_sm,
        padding: :space_xs
      },
      children: [
        %{type: :column, props: %{}, children: [line(30), gap(5), line(22), gap(5), line(26)]}
      ]
    }

    content = %{
      type: :box,
      props: %{weight: 1, height: 56, background: :surface_raised, corner_radius: :radius_sm},
      children: []
    }

    layout = %{type: :row, props: %{fill_width: true}, children: [panel, gap(6), content]}
    %{type: :column, props: %{fill_width: true}, children: [dots, gap(8), layout]}
  end

  defp dot,
    do: %{
      type: :box,
      props: %{width: 6, height: 6, background: :muted, corner_radius: :radius_pill},
      children: []
    }

  defp line(width) do
    %{
      type: :box,
      props: %{width: width, height: 4, background: :surface_raised, corner_radius: :radius_sm},
      children: []
    }
  end

  # Compose measures a Row's unweighted children first, so the flexible half of
  # a row has to say it is flexible or the fixed half eats the width.
  defp weighted(child), do: %{type: :box, props: %{weight: 1}, children: [child]}

  defp row(children), do: %{type: :row, props: %{fill_width: true}, children: children}
  defp column(children), do: %{type: :column, props: %{fill_width: true}, children: children}
  defp gap(n), do: %{type: :spacer, props: %{size: n}, children: []}
end
