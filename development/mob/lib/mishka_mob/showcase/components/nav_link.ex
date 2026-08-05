defmodule MishkaMob.Showcase.Components.NavLink do
  @moduledoc """
  Gallery entry for the navigation family: `MishkaMob.Components.MishkaNavLink`,
  `MishkaMob.Components.MishkaAnchor`, `MishkaMob.Components.MishkaMenubar`,
  `MishkaMob.Components.MishkaNavigationMenu` and
  `MishkaMob.Components.MishkaVisuallyHidden`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.{MishkaAnchor, MishkaMenubar, MishkaNavigationMenu}
  alias MishkaMob.Showcase.Example

  @menus [
    %{
      label: "File",
      value: :file,
      items: [
        %{label: "New", value: :new, shortcut: "⌘N"},
        %{label: "Open…", value: :open, shortcut: "⌘O"},
        :separator,
        %{label: "Quit", value: :quit, disabled: true}
      ]
    },
    %{
      label: "Edit",
      value: :edit,
      items: [%{label: "Undo", value: :undo}, %{label: "Redo", value: :redo}]
    },
    %{label: "View", value: :view, items: [%{label: "Zoom in", value: :zoom}]}
  ]

  @impl true
  def entry do
    %{
      slug: :nav_link,
      name: "Nav Link",
      category: "Navigation",
      order: 9,
      description: "Nav rows, anchors, a menubar and a navigation menu."
    }
  end

  @impl true
  def mount(socket) do
    # One assign per example, never shared: two examples reading the same assign
    # look identical on the device and no test can say which one it moved.
    socket
    |> Mob.Socket.assign(:nl_current, "/dashboard")
    |> Mob.Socket.assign(:nl_mail_open, false)
    |> Mob.Socket.assign(:nl_mail_pick, nil)
    |> Mob.Socket.assign(:nl_marked, false)
    |> Mob.Socket.assign(:menu, nil)
    |> Mob.Socket.assign(:nav, nil)
    |> Mob.Socket.assign(:last, "nothing yet")
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Leaves — one handler, many links",
        description:
          "A link is a tap plus a destination. `href` rides back with the tag, so a whole " <>
            "sidebar reports through one clause, and `active` marks whichever one it named.",
        code: ~S"""
        <MishkaNavLink
          id="nav-docs"
          label="Docs"
          icon="▤"
          trailing="↗"
          href="/docs"
          active={@current == "/docs"}
          on_tap={:pick}
        />

        # The component never navigates: a node tree only describes one.
        def handle_info({:tap, {:pick, href}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :current, href)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNavLink
              id="nav-dash"
              label="Dashboard"
              icon="◱"
              href="/dashboard"
              active={@nl_current == "/dashboard"}
              on_tap={:nl_pick}
            />
            <MishkaNavLink
              id="nav-docs"
              label="Docs"
              icon="▤"
              trailing="↗"
              href="/docs"
              active={@nl_current == "/docs"}
              on_tap={:nl_pick}
            />
            <MishkaNavLink
              id="nav-settings"
              label="Settings"
              icon="⚙"
              href="/settings"
              active={@nl_current == "/settings"}
              on_tap={:nl_pick}
            />
            <Spacer size={10} />
            <Text text={"Current: " <> @nl_current} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "A group the screen owns",
        description:
          "The web uses <details>, then warns that LiveView resets it on every patch. " <>
            "Here `opened` is a prop, so nothing can lose it — and `indent` sets how far " <>
            "the nested links sit in.",
        code: ~S"""
        <MishkaNavLink
          id="nav-mail"
          label="Mail"
          icon="✉"
          indent={24}
          opened={@open?}
          on_toggle={:toggle}
        >
          <MishkaNavLink
            id="nav-inbox"
            label="Inbox"
            description="12 unread"
            href="inbox"
            on_tap={:pick}
          />
        </MishkaNavLink>

        def handle_info({:tap, :toggle}, socket) do
          {:noreply, Mob.Socket.assign(socket, :open?, not socket.assigns.open?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNavLink
              id="nav-mail"
              label="Mail"
              icon="✉"
              indent={24}
              opened={@nl_mail_open}
              on_toggle={:nl_mail}
            >
              <MishkaNavLink
                id="nav-inbox"
                label="Inbox"
                description="12 unread"
                active={@nl_mail_pick == "inbox"}
                href="inbox"
                on_tap={:nl_mail_pick}
              />
              <MishkaNavLink
                id="nav-drafts"
                label="Drafts"
                description="3 unsent"
                active={@nl_mail_pick == "drafts"}
                href="drafts"
                on_tap={:nl_mail_pick}
              />
            </MishkaNavLink>
            <Spacer size={10} />
            <Text text={picked(@nl_mail_pick)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "default_opened — nobody owns it",
        description:
          "The web's fallback for a static page, with the web's precedence: it applies only " <>
            "while `opened` is nil. Tapping this row does nothing, because a node tree has " <>
            "nowhere to keep the answer. Pass `opened` the moment it has to toggle.",
        code: ~S"""
        <MishkaNavLink id="nav-team" label="Team" icon="◍" default_opened={true}>
          <MishkaNavLink id="nav-alice" label="Alice" />
        </MishkaNavLink>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNavLink id="nav-team" label="Team" icon="◍" default_opened={true}>
              <MishkaNavLink id="nav-alice" label="Alice" />
              <MishkaNavLink id="nav-bob" label="Bob" />
            </MishkaNavLink>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled, and a node in the trailing slot",
        description:
          "`trailing` takes a node as readily as a glyph — the web slot's whole point. " <>
            "Tapping Reports marks it; Archive is disabled, so it wires no handler at all " <>
            "and nothing it does can mark anything.",
        code: ~S"""
        # A trailing NODE must state its own width: a Box with none fills its
        # parent on both bridges, and a filling badge shoves the label off the row.
        <MishkaNavLink id="nav-reports" label="Reports" trailing={badge(3)}
                       active={@on?} on_tap={:mark} />
        <MishkaNavLink id="nav-archive" label="Archive" disabled={true} on_tap={:mark} />

        def handle_info({:tap, :mark}, socket) do
          {:noreply, Mob.Socket.assign(socket, :on?, not socket.assigns.on?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNavLink
              id="nav-reports"
              label="Reports"
              icon="▦"
              trailing={unread_badge(3)}
              active={@nl_marked}
              on_tap={:nl_mark}
            />
            <MishkaNavLink id="nav-archive" label="Archive" icon="▤" disabled={true} on_tap={:nl_mark} />
          </Column>
          """
        end
      },
      %Example{
        title: "Anchor",
        description:
          "A link is a tap plus a destination. The component never opens the URL itself — " <>
            "the screen does, via MishkaAnchor.open/1.",
        code: ~S"""
        <MishkaAnchor label="mishka.tools" href="https://mishka.tools" on_tap={:open} />

        def handle({:open, href}, socket), do: (MishkaAnchor.open(href); socket)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaAnchor label="mishka.tools" href="https://mishka.tools" on_tap={:visit} />
            <Spacer size={10} />
            <MishkaAnchor
              label="No underline"
              href="https://elixir-lang.org"
              underline={false}
              on_tap={:visit}
            />
            <Spacer size={10} />
            <Text text={"Last tapped: " <> @last} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Menubar",
        description:
          "Opening a menu closes the one before it — exclusivity, which ports exactly.",
        code: ~S"""
        <MishkaMenubar menus={@menus} open={@open} on_open={:open} on_select={:pick} />

        def handle({:open, value}, socket),
          do: assign(socket, :open, MishkaMenubar.open_menu(value, socket.assigns.open))
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaMenubar menus={menus()} open={@menu} on_open={:menu} on_select={:pick} />
          </Column>
          """
        end
      },
      %Example{
        title: "Navigation menu",
        description:
          "Site nav, not commands: some items are plain links, and every panel shares one " <>
            "viewport so two can never render at once.",
        code: ~S"""
        <MishkaNavigationMenu items={@items} value={@open} on_open={:open} on_link={:go} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNavigationMenu items={nav_items()} value={@nav} on_open={:nav} on_link={:visit_item} />
          </Column>
          """
        end
      },
      %Example{
        title: "Visually hidden",
        description:
          "The one component that cannot do its job here: no node type in the bridge carries " <>
            "an accessibility label, so there is nothing a screen reader could announce. It " <>
            "renders nothing and says so rather than pretending.",
        code: ~S"""
        MishkaVisuallyHidden.announce?()  #=> false — branch on this
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text
              text="↑ There is a visually hidden node above this line."
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
        name: "NavLink: id",
        type: "string",
        default: "nil",
        description: "Test tags: <id>, <id>-active/-inactive/-disabled, <id>-open/-closed."
      },
      %{
        name: "NavLink: label / description / icon / trailing",
        type: "string or node",
        default: "nil",
        description: "Row content. icon and trailing also take a node."
      },
      %{
        name: "NavLink: active / disabled",
        type: "boolean",
        default: "false",
        description: "Current-page ink; muted and unwired."
      },
      %{
        name: "NavLink: opened / default_opened",
        type: "boolean",
        default: "nil · false",
        description: "A prop, not DOM state. opened wins while it is not nil."
      },
      %{
        name: "NavLink: indent",
        type: "number",
        default: "16",
        description: "How far the nested links sit in."
      },
      %{
        name: "NavLink: href",
        type: "string",
        default: "nil",
        description: "Rides back with the tap as {tag, href}."
      },
      %{
        name: "NavLink: on_tap / on_toggle",
        type: "event tags",
        default: "—",
        description: "Leaf tap; parent expand. on_toggle falls back to on_tap."
      },
      %{
        name: "Anchor: label / href / underline / color",
        type: "—",
        default: "— · true · :primary",
        description: "on_tap carries the href back."
      },
      %{
        name: "Anchor: open/1",
        type: "helper",
        default: "—",
        description: "Wraps Mob.Device.open_url; rejects non-http URLs."
      },
      %{
        name: "Menubar: menus / open",
        type: "list · value",
        default: "[] · nil",
        description: "Items may be :separator."
      },
      %{
        name: "Menubar: open_menu/2",
        type: "helper",
        default: "—",
        description: "The exclusivity rule, as one function."
      },
      %{
        name: "NavigationMenu: items / value / orientation",
        type: "—",
        default: "[] · nil · :horizontal",
        description: "An item with :content is a trigger; without, a link."
      },
      %{
        name: "NavigationMenu: trigger?/1 · toggle/2",
        type: "helpers",
        default: "—",
        description: "Link-or-panel, and the shared-viewport rule."
      },
      %{
        name: "VisuallyHidden: announce?/0",
        type: "helper",
        default: "false",
        description: "Whether hidden text can reach a screen reader. It cannot."
      }
    ]
  end

  # One clause for a whole sidebar: the href the link was given rides back with
  # the tag, so the handler never has to know which row was tapped.
  @impl true
  def handle({:nl_pick, href}, socket), do: Mob.Socket.assign(socket, :nl_current, href)

  def handle(:nl_mail, socket),
    do: Mob.Socket.assign(socket, :nl_mail_open, not socket.assigns.nl_mail_open)

  def handle({:nl_mail_pick, which}, socket), do: Mob.Socket.assign(socket, :nl_mail_pick, which)

  def handle(:nl_mark, socket),
    do: Mob.Socket.assign(socket, :nl_marked, not socket.assigns.nl_marked)

  # The screen performs the side effect; the node tree only described it.
  def handle({:visit, href}, socket) do
    MishkaAnchor.open(href)

    Mob.Socket.assign(socket, :last, href)
  end

  def handle({:menu, value}, socket),
    do: Mob.Socket.assign(socket, :menu, MishkaMenubar.open_menu(value, socket.assigns.menu))

  def handle({:pick, value}, socket) do
    socket
    |> Mob.Socket.assign(:last, to_string(value))
    |> Mob.Socket.assign(:menu, nil)
  end

  def handle({:nav, value}, socket),
    do: Mob.Socket.assign(socket, :nav, MishkaNavigationMenu.toggle(value, socket.assigns.nav))

  def handle({:visit_item, value}, socket), do: Mob.Socket.assign(socket, :last, to_string(value))
  def handle(_tag, socket), do: socket

  defp picked(nil), do: "No mailbox yet"
  defp picked(which), do: "Mailbox: " <> which

  # A node in the trailing slot has to state its own width: a Box given neither
  # `width` nor a fixed frame fills its parent on both bridges, and a badge that
  # fills would shove the label off the row.
  defp unread_badge(count) do
    ~MOB"""
    <Box width={24} height={18} align={:center} background={:primary} corner_radius={:radius_sm}>
      <Text text={to_string(count)} text_size={:xs} text_color={:on_primary} />
    </Box>
    """
  end

  defp menus, do: @menus

  defp nav_items do
    [
      %{
        label: "Products",
        value: :products,
        content: [
          ~MOB"""
          <Column fill_width={true}>
            <Text text="Chelekom" text_size={:base} text_color={:on_surface} font_weight={:semibold} />
            <Spacer size={4} />
            <Text text="Headless components for Phoenix and Mob." text_size={:sm} text_color={:muted} />
          </Column>
          """
        ]
      },
      %{
        label: "Docs",
        value: :docs,
        content: [
          ~MOB"""
          <Column fill_width={true}>
            <Text
              text="Guides, usage rules and the component reference."
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        ]
      },
      %{label: "Blog", value: :blog}
    ]
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row align={:center}>
        <Text text="✉" text_size={:sm} text_color={:muted} />
        <Spacer size={8} />
        <Box width={46} height={8} background={:muted} corner_radius={:radius_sm} />
        <Spacer weight={1} />
        <Text text="▾" text_size={:sm} text_color={:muted} />
      </Row>
      <Spacer size={9} />
      <Row align={:center}>
        <Spacer size={16} />
        <Box width={36} height={8} background={:primary} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={9} />
      <Row align={:center}>
        <Spacer size={16} />
        <Box width={42} height={8} background={:muted} corner_radius={:radius_sm} />
      </Row>
    </Column>
    """
  end
end
