defmodule MishkaMob.Showcase.Components.Toolbar do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaToolbar` and
  `MishkaMob.Components.MishkaBurger`.

  Every example owns its assigns and its own toolbar `id`. Sharing one `@pressed`
  between two bars makes every device assertion ambiguous the moment the second
  one renders the same label — and this page renders nine bars.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaToggle, only: [toggle: 1]
  import MishkaMob.Components.MishkaActionIcon, only: [action_icon: 1]

  alias MishkaMob.Components.MishkaToolbar
  alias MishkaMob.Showcase.Example

  # Both overflow examples draw from these, so the only thing that differs
  # between them is the mode under test. Eight is more than a phone is wide,
  # which is the whole point.
  @wide [
    {:cut, "Cut", "✂"},
    {:copy, "Copy", "⧉"},
    {:paste, "Paste", "📋"},
    {:undo, "Undo", "↺"},
    {:redo, "Redo", "↻"},
    {:link, "Link", "🔗"},
    {:image, "Image", "🖼"},
    {:quote, "Quote", "❝"},
    {:code, "Code", "⌨"},
    {:list, "List", "☰"},
    {:align, "Align", "⇹"},
    {:colour, "Colour", "🎨"},
    {:table, "Table", "▦"}
  ]

  @impl true
  def entry do
    %{
      slug: :toolbar,
      name: "Toolbar",
      category: "Navigation",
      order: 3,
      description: "A strip of related controls, in groups, with separators between them."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:tb_bold, true)
    |> Mob.Socket.assign(:tb_italic, false)
    |> Mob.Socket.assign(:tb_kinds_last, nil)
    |> Mob.Socket.assign(:tb_kinds_query, "")
    |> Mob.Socket.assign(:tb_group_last, nil)
    |> Mob.Socket.assign(:tb_hint, nil)
    |> Mob.Socket.assign(:tb_off_hint, nil)
    |> Mob.Socket.assign(:tb_mix_last, nil)
    |> Mob.Socket.assign(:tb_more_open, false)
    |> Mob.Socket.assign(:tb_nav, false)
  end

  @impl true
  def examples do
    [
      own_controls(),
      four_kinds(),
      groups(),
      hint(),
      disabled(),
      scrolling(),
      collapsing(),
      vertical(),
      burger()
    ]
  end

  defp own_controls do
    %Example{
      title: "A strip of your own controls",
      description: "Anything that is not a toolbar item passes straight through, untouched.",
      code: ~S"""
      <MishkaToolbar id="tb-own">{[
        toggle(label: "B", pressed: @bold?, on_change: :bold, id: "tb-own-b"),
        toggle(label: "I", pressed: @italic?, on_change: :italic, id: "tb-own-i"),
        MishkaToolbar.separator(),
        action_icon(icon: "↺", on_tap: :undo)
      ]}</MishkaToolbar>

      def handle_info({:tap, :bold}, socket) do
        {:noreply, Mob.Socket.assign(socket, :bold?, not socket.assigns.bold?)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column fill_width={true}>
          <MishkaToolbar id="tb-own">
            {own_items(@tb_bold, @tb_italic)}
          </MishkaToolbar>
        </Column>
        """
      end
    }
  end

  defp four_kinds do
    %Example{
      title: "Four item kinds",
      description:
        "button, link, input and separator — the web's <:item> types, all four. One on_select " <>
          "clause serves every button and link, because each reports its own id.",
      code: ~S"""
      <MishkaToolbar
        id="tb-kinds"
        on_select={:act}
        on_input={:typed}
      >{[
        MishkaToolbar.button(:bold, "Bold", icon: "B"),
        MishkaToolbar.link(:docs, "Docs", href: "https://mishka.tools/chelekom"),
        MishkaToolbar.separator(),
        MishkaToolbar.input(:find, placeholder: "Find…", value: @query)
      ]}</MishkaToolbar>

      def handle_info({:tap, {:act, :docs}}, socket) do
        # href/2 turns the reported id back into the destination. Opening it is
        # the screen's job — a node tree is a description, not an effect.
        Mob.Device.open_url(MishkaToolbar.href(items(), :docs))
        {:noreply, socket}
      end

      def handle_info({:change, {:typed, :find}, value}, socket) do
        {:noreply, Mob.Socket.assign(socket, :query, value)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column fill_width={true}>
          <MishkaToolbar id="tb-kinds" on_select={:tb_kinds_act} on_input={:tb_kinds_type}>
            {kind_items(@tb_kinds_query)}
          </MishkaToolbar>
          <Spacer size={10} />
          <Text
            id="tb-kinds-status"
            text={kinds_status(@tb_kinds_last, @tb_kinds_query)}
            text_size={:sm}
            text_color={:muted}
          />
        </Column>
        """
      end
    }
  end

  defp groups do
    %Example{
      title: "Groups",
      description:
        "Consecutive items sharing a :group are chunked into one cluster, exactly as the web " <>
          "wraps them in a role=group div. Its label is invisible there too — here it becomes " <>
          "the cluster's test tag.",
      code: ~S"""
      <MishkaToolbar id="tb-grp" on_select={:align}>{[
        MishkaToolbar.button(:left, "Left", icon: "◀", group: "Align"),
        MishkaToolbar.button(:center, "Centre", icon: "◆", group: "Align"),
        MishkaToolbar.button(:right, "Right", icon: "▶", group: "Align"),
        MishkaToolbar.button(:list, "List", icon: "☰", group: "Lists"),
        MishkaToolbar.button(:quote, "Quote", icon: "❝", group: "Lists")
      ]}</MishkaToolbar>

      def handle_info({:tap, {:align, id}}, socket) do
        {:noreply, Mob.Socket.assign(socket, :align, id)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column fill_width={true}>
          <MishkaToolbar id="tb-grp" on_select={:tb_group_act}>
            {group_items()}
          </MishkaToolbar>
          <Spacer size={10} />
          <Text id="tb-grp-status" text={picked(@tb_group_last)} text_size={:sm} text_color={:muted} />
        </Column>
        """
      end
    }
  end

  defp hint do
    %Example{
      title: "Hold an icon to read its label",
      description:
        "The web puts label in aria-label, and a desktop browser shows it on hover. There is no " <>
          "hover here, so hold the button: on_hold reports the id, and passing it back as hint " <>
          "prints that item's label under the strip.",
      code: ~S"""
      <MishkaToolbar
        id="tb-hint"
        on_select={:act}
        on_hold={:hold}
        hint={@hint}
      >{icon_items()}</MishkaToolbar>

      # A long press is the touch equivalent of a hover. The plain tap still
      # does whatever the button does, so the hint costs the caller nothing.
      def handle_info({:tap, {:hold, id}}, socket) do
        {:noreply, Mob.Socket.assign(socket, :hint, id)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column fill_width={true}>
          <MishkaToolbar id="tb-hint" on_select={:tb_hint_act} on_hold={:tb_hint_hold} hint={@tb_hint}>
            {hint_items()}
          </MishkaToolbar>
        </Column>
        """
      end
    }
  end

  defp disabled do
    %Example{
      title: "Disabled, and still discoverable",
      description:
        "The first bar is disabled whole; the second has a single dead item. Either way a " <>
          "disabled item still answers a long press — that is focusable_when_disabled, which on " <>
          "the web keeps it in the roving order so it stays findable.",
      code: ~S"""
      <MishkaToolbar id="tb-off" disabled={true} on_hold={:hold} hint={@held}>{items}</MishkaToolbar>

      <MishkaToolbar id="tb-mix" on_select={:act}>{[
        MishkaToolbar.button(:bold, "Bold", icon: "B"),
        MishkaToolbar.button(:italic, "Italic", icon: "I", disabled: true)
      ]}</MishkaToolbar>

      # focusable_when_disabled={false} takes the long press away as well.
      def handle_info({:tap, {:hold, id}}, socket) do
        {:noreply, Mob.Socket.assign(socket, :held, id)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column fill_width={true}>
          <MishkaToolbar
            id="tb-off"
            disabled={true}
            on_select={:tb_off_act}
            on_hold={:tb_off_hold}
            hint={@tb_off_hint}
          >
            {off_items()}
          </MishkaToolbar>
          <Spacer size={12} />
          <MishkaToolbar id="tb-mix" on_select={:tb_mix_act}>
            {mix_items()}
          </MishkaToolbar>
          <Spacer size={10} />
          <Text id="tb-mix-status" text={picked(@tb_mix_last)} text_size={:sm} text_color={:muted} />
        </Column>
        """
      end
    }
  end

  defp scrolling do
    %Example{
      title: "Overflow: scroll",
      description:
        "A Row does not wrap and nothing measures itself, so eight controls on a phone are " <>
          "simply clipped. overflow={:scroll} makes the strip scroll along its own axis instead.",
      code: ~S"""
      <MishkaToolbar
        id="tb-scr"
        overflow={:scroll}
        on_select={:act}
      >{wide_items()}</MishkaToolbar>

      def handle_info({:tap, {:act, id}}, socket), do: {:noreply, act(socket, id)}
      """,
      render: fn _assigns ->
        ~MOB"""
        <Column fill_width={true}>
          <MishkaToolbar id="tb-scr" overflow={:scroll} on_select={:tb_noop}>
            {wide_items()}
          </MishkaToolbar>
        </Column>
        """
      end
    }
  end

  defp collapsing do
    %Example{
      title: "Overflow: collapse",
      description:
        "The other answer — keep `visible` controls and put a ⋯ at the end. It reports " <>
          "on_overflow, so the rest go wherever you decide: a drawer, a menu, a second bar.",
      code: ~S"""
      <MishkaToolbar
        id="tb-more"
        overflow={:collapse}
        visible={3}
        on_overflow={:show_rest}
        on_select={:act}
      >{wide_items()}</MishkaToolbar>

      def handle_info({:tap, :show_rest}, socket) do
        {:noreply, Mob.Socket.assign(socket, :sheet_open?, true)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column fill_width={true}>
          <MishkaToolbar
            id="tb-more"
            overflow={:collapse}
            visible={3}
            on_select={:tb_noop}
            on_overflow={:tb_more_open}
          >
            {wide_items()}
          </MishkaToolbar>
          <Spacer size={10} />
          <Text
            id="tb-more-status"
            text={rest_status(@tb_more_open)}
            text_size={:sm}
            text_color={:muted}
          />
        </Column>
        """
      end
    }
  end

  defp vertical do
    %Example{
      title: "Vertical",
      description: "The separator orients itself to the toolbar's axis.",
      code: ~S"""
      <MishkaToolbar id="tb-vert" orientation={:vertical} on_select={:act}>{[
        MishkaToolbar.button(:edit, "Edit", icon: "✎"),
        MishkaToolbar.separator(),
        MishkaToolbar.button(:delete, "Delete", icon: "🗑")
      ]}</MishkaToolbar>

      def handle_info({:tap, {:act, id}}, socket), do: {:noreply, act(socket, id)}
      """,
      render: fn _assigns ->
        ~MOB"""
        <Row fill_width={true}>
          <MishkaToolbar id="tb-vert" orientation={:vertical} on_select={:tb_noop}>
            {vertical_items()}
          </MishkaToolbar>
        </Row>
        """
      end
    }
  end

  defp burger do
    %Example{
      title: "Burger",
      description: "Three bars, and a ✕ when open — one control, one tap target.",
      code: ~S"""
      <MishkaBurger opened={@nav_open?} on_toggle={:toggle_nav} />

      def handle_info({:tap, :toggle_nav}, socket) do
        {:noreply, Mob.Socket.assign(socket, :nav_open?, not socket.assigns.nav_open?)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column fill_width={true}>
          <Row fill_width={true}>
            <MishkaBurger opened={@tb_nav} on_toggle={:tb_nav} />
            <Spacer size={12} />
            <MishkaBurger opened={@tb_nav} on_toggle={:tb_nav} color={:primary} />
            <Spacer size={12} />
            <MishkaBurger disabled={true} />
          </Row>
          <Spacer size={10} />
          <Text
            text={if(@tb_nav, do: "Navigation open", else: "Navigation closed")}
            text_size={:sm}
            text_color={:muted}
          />
        </Column>
        """
      end
    }
  end

  defp own_items(bold?, italic?) do
    [
      toggle(label: " B ", pressed: bold?, on_change: :tb_bold, id: "tb-own-b"),
      toggle(label: " I ", pressed: italic?, on_change: :tb_italic, id: "tb-own-i"),
      MishkaToolbar.separator(),
      action_icon(icon: "↺", on_tap: :tb_noop),
      action_icon(icon: "↻", on_tap: :tb_noop)
    ]
  end

  defp kind_items(query) do
    [
      MishkaToolbar.button(:bold, "Bold", icon: "B"),
      MishkaToolbar.link(:docs, "Docs", href: "https://mishka.tools/chelekom"),
      MishkaToolbar.separator(),
      MishkaToolbar.input(:find, placeholder: "Find…", value: query)
    ]
  end

  defp group_items do
    [
      MishkaToolbar.button(:left, "Left", icon: "◀", group: "Align"),
      MishkaToolbar.button(:center, "Centre", icon: "◆", group: "Align"),
      MishkaToolbar.button(:right, "Right", icon: "▶", group: "Align"),
      MishkaToolbar.button(:list, "List", icon: "☰", group: "Lists"),
      MishkaToolbar.button(:quote, "Quote", icon: "❝", group: "Lists")
    ]
  end

  defp hint_items do
    [
      MishkaToolbar.button(:undo, "Undo", icon: "↺"),
      MishkaToolbar.button(:redo, "Redo", icon: "↻"),
      MishkaToolbar.separator(),
      MishkaToolbar.button(:link, "Insert link", icon: "🔗")
    ]
  end

  defp off_items do
    [
      MishkaToolbar.button(:bold, "Bold", icon: "B"),
      MishkaToolbar.button(:italic, "Italic", icon: "I")
    ]
  end

  defp mix_items do
    [
      MishkaToolbar.button(:bold, "Bold", icon: "B"),
      MishkaToolbar.button(:italic, "Italic", icon: "I", disabled: true)
    ]
  end

  defp vertical_items do
    [
      MishkaToolbar.button(:edit, "Edit", icon: "✎"),
      MishkaToolbar.button(:copy, "Copy", icon: "⧉"),
      MishkaToolbar.separator(),
      MishkaToolbar.button(:delete, "Delete", icon: "🗑")
    ]
  end

  defp wide_items do
    Enum.map(@wide, fn {id, label, icon} -> MishkaToolbar.button(id, label, icon: icon) end)
  end

  defp kinds_status(nil, ""), do: "Nothing tapped, nothing typed"
  defp kinds_status(nil, query), do: "Looking for #{query}"
  defp kinds_status(id, ""), do: "Tapped #{id}"
  defp kinds_status(id, query), do: "Tapped #{id}, looking for #{query}"

  defp picked(nil), do: "Nothing picked yet"
  defp picked(id), do: "Picked #{id}"

  defp rest_status(true), do: "The rest would open in a drawer"
  defp rest_status(_closed), do: "Tap the ⋯ for the rest"

  @impl true
  def props do
    [
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Test tag. Items get <id>-<item_id>, and -disabled when they are."
      },
      %{
        name: "orientation",
        type: ":horizontal · :vertical",
        default: ":horizontal",
        description: "Layout axis. Separators follow it."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Disables every item in the bar."
      },
      %{
        name: "focusable_when_disabled",
        type: "boolean",
        default: "true",
        description: "A disabled item still answers a long press."
      },
      %{
        name: "on_select",
        type: "event tag",
        default: "—",
        description: "{:tap, {tag, item_id}} from a button or link."
      },
      %{
        name: "on_hold",
        type: "event tag",
        default: "—",
        description: "{:tap, {tag, item_id}} from a long press — the hover replacement."
      },
      %{
        name: "on_input",
        type: "event tag",
        default: "—",
        description: "{:change, {tag, item_id}, value} from an input item."
      },
      %{
        name: "on_overflow",
        type: "event tag",
        default: "—",
        description: "{:tap, tag} from the ⋯."
      },
      %{
        name: "hint",
        type: "item id",
        default: "nil",
        description: "Prints that item's label under the strip."
      },
      %{
        name: "overflow",
        type: ":none · :scroll · :collapse",
        default: ":none",
        description: "What too many controls do. Nothing wraps."
      },
      %{
        name: "visible",
        type: "integer",
        default: "3",
        description: "Controls kept when overflow is :collapse."
      },
      %{name: "space", type: "number", default: "8", description: "Gap between items."},
      %{
        name: "height",
        type: "number",
        default: "nil",
        description: "Bounds the strip. A vertical :scroll needs it."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "Strip fill."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: ":radius_md",
        description: "Strip corners."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_sm",
        description: "Padding inside the strip."
      },
      %{
        name: "group_background",
        type: "color / ARGB",
        default: ":surface",
        description: "Fill behind a labelled group."
      },
      %{
        name: "item_color · link_color",
        type: "color / ARGB",
        default: ":on_surface · :primary",
        description: "Button ink, and link ink."
      },
      %{
        name: "button/3 · link/3 · input/2 · separator/1",
        type: "builders",
        default: "—",
        description: "The four item kinds. Each takes :disabled and :group."
      },
      %{
        name: "href/2 · split/2 · item_tag/3",
        type: "helpers",
        default: "—",
        description: "A link's destination, the collapse policy, an item's test tag."
      },
      %{
        name: "Burger: opened / on_toggle / size / color",
        type: "see MishkaBurger",
        default: "—",
        description: "The three-bar nav button, sharing this page."
      }
    ]
  end

  @impl true
  def handle(:tb_bold, socket), do: flip(socket, :tb_bold)
  def handle(:tb_italic, socket), do: flip(socket, :tb_italic)
  def handle(:tb_nav, socket), do: flip(socket, :tb_nav)
  def handle(:tb_more_open, socket), do: Mob.Socket.assign(socket, :tb_more_open, true)
  def handle({:tb_kinds_act, id}, socket), do: Mob.Socket.assign(socket, :tb_kinds_last, id)
  def handle({:tb_group_act, id}, socket), do: Mob.Socket.assign(socket, :tb_group_last, id)
  def handle({:tb_hint_hold, id}, socket), do: Mob.Socket.assign(socket, :tb_hint, id)
  def handle({:tb_off_hold, id}, socket), do: Mob.Socket.assign(socket, :tb_off_hint, id)
  def handle({:tb_mix_act, id}, socket), do: Mob.Socket.assign(socket, :tb_mix_last, id)
  def handle(_tag, socket), do: socket

  @impl true
  def handle_change({:tb_kinds_type, :find}, value, socket),
    do: Mob.Socket.assign(socket, :tb_kinds_query, value)

  def handle_change(_tag, _value, socket), do: socket

  defp flip(socket, key), do: Mob.Socket.assign(socket, key, not Map.fetch!(socket.assigns, key))

  @impl true
  def card_preview do
    ~MOB"""
    <Box fill_width={true} background={:surface_raised} corner_radius={:radius_md} padding={6}>
      <Row fill_width={true}>
        <Box width={26} height={22} background={:primary} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={26} height={22} background={:surface} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={1} height={22} background={:border} />
        <Spacer size={6} />
        <Box width={26} height={22} background={:surface} corner_radius={:radius_sm} />
      </Row>
    </Box>
    """
  end
end
