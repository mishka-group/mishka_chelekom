defmodule MishkaMob.Showcase.Components.NavLink do
  @moduledoc """
  Gallery entry for the navigation family: `MishkaMob.Components.MishkaNavLink`,
  `MishkaMob.Components.MishkaAnchor`, `MishkaMob.Components.MishkaMenubar`,
  `MishkaMob.Components.MishkaNavigationMenu` and
  `MishkaMob.Components.MishkaVisuallyHidden`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaNavLink, only: [nav_link: 2]

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
    socket
    |> Mob.Socket.assign(:active, :inbox)
    |> Mob.Socket.assign(:opened, true)
    |> Mob.Socket.assign(:menu, nil)
    |> Mob.Socket.assign(:nav, nil)
    |> Mob.Socket.assign(:last, "nothing yet")
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Nav links, flat and nested",
        description:
          "The web version uses <details>, then warns that LiveView resets it on patch. " <>
            "Here `opened` is a prop the screen owns, so it survives every render.",
        code: ~S"""
        <MishkaNavLink
          label="Mail"
          icon="✉"
          opened={@opened}
          on_toggle={:toggle}
        >{[nav_link([label: "Inbox", active: true, on_tap: :go], [])]}</MishkaNavLink>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNavLink label="Dashboard" icon="◱" active={@active == :dash} on_tap={:dash}>
              {[]}
            </MishkaNavLink>
            <MishkaNavLink label="Mail" icon="✉" opened={@opened} on_toggle={:toggle}>
              {[
                 nav_link([label: "Inbox", active: @active == :inbox, on_tap: :inbox], []),
                 nav_link([label: "Drafts", description: "3 unsent",
                           active: @active == :drafts, on_tap: :drafts], [])
               ]}
            </MishkaNavLink>
            <MishkaNavLink label="Archive" icon="▤" disabled={true}>
              {[]}
            </MishkaNavLink>
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
        name: "NavLink: label / description / icon / trailing",
        type: "string",
        default: "nil",
        description: "Row content."
      },
      %{
        name: "NavLink: active / opened / disabled",
        type: "boolean",
        default: "false",
        description: "Opened is a prop, not DOM state."
      },
      %{
        name: "NavLink: on_tap / on_toggle",
        type: "event tags",
        default: "—",
        description: "Leaf tap; parent expand. href rides along."
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

  @impl true
  def handle(:toggle, socket), do: Mob.Socket.assign(socket, :opened, not socket.assigns.opened)
  def handle(:dash, socket), do: Mob.Socket.assign(socket, :active, :dash)
  def handle(:inbox, socket), do: Mob.Socket.assign(socket, :active, :inbox)
  def handle(:drafts, socket), do: Mob.Socket.assign(socket, :active, :drafts)

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

  defp menus, do: @menus

  defp nav_items do
    [
      %{
        label: "Products",
        value: :products,
        content: [
          ~MOB"""
          <Column fill_width={true}>
            <Text text="Chelekom" text_size={:base} text_color={:on_surface} weight={:semibold} />
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
