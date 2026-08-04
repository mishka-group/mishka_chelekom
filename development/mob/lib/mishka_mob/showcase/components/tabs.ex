defmodule MishkaMob.Showcase.Components.Tabs do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaTabs`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaTabs, only: [tab: 3, tab: 4]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :tabs,
      name: "Tabs",
      category: "Navigation",
      order: 0,
      description: "A tab strip with one visible panel, draggable when it overflows."
    }
  end

  @impl true
  def mount(socket) do
    # One assign per example. They used to share two between four examples —
    # and the two sharing `:tb_main` did not even have the same tab ids, so
    # picking "Support" in one made the other silently snap back to its first
    # tab. Sharing state between examples means no reader (and no test) can say
    # which strip they just touched.
    socket
    |> Mob.Socket.assign(:tb_main, :overview)
    |> Mob.Socket.assign(:tb_many, :inbox)
    |> Mob.Socket.assign(:tb_plain, :one)
    |> Mob.Socket.assign(:tb_locked, :overview)
    |> Mob.Socket.assign(:tb_styled, :one)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A tab strip",
        description: "Each tab declares its own panel; only the active one renders.",
        code: ~S"""
        <MishkaTabs
          active={@tab}
          on_change={:pick}
          id="main"
        >{[
          tab(:overview, "Overview", overview_body()),
          tab(:specs, "Specs", specs_body()),
          tab(:support, "Support", support_body())
        ]}</MishkaTabs>

        # One clause serves every tab: the message carries the tab's own id.
        def handle_info({:tap, {:pick, id}}, socket) do
          {:noreply, assign(socket, :tab, id)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTabs active={@tb_main} on_change={:tb_main} id="main">
              {[
              tab(:overview, "Overview", para("A native tab strip built from Row, Box and Text.")),
              tab(:specs, "Specs", para("Content-sized tabs, so the strip works on both platforms.")),
              tab(:support, "Support", para("Each panel is the tab's own children."))
            ]}
            </MishkaTabs>
          </Column>
          """
        end
      },
      %Example{
        title: "Too many to fit — drag the strip sideways",
        description:
          "Nine tabs on a phone. Swipe the bar left and right with your finger; every tab is " <>
            "still tappable, and its panel still shows.",
        code: ~S"""
        # The strip is a horizontal Scroll, so it drags. A Row cannot wrap, and
        # before this the fifth tab was drawn past the screen edge for good.
        <MishkaTabs active={@tab} on_change={:pick} id="many">{[
          tab(:inbox, "Inbox", body(:inbox)),
          tab(:starred, "Starred", body(:starred)),
          # …seven more
        ]}</MishkaTabs>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTabs active={@tb_many} on_change={:tb_many} id="many">
              {[
              tab(:inbox, "Inbox", para("Nine tabs. Drag the bar to reach the ones off-screen.")),
              tab(:starred, "Starred", para("Starred messages live here.")),
              tab(:snoozed, "Snoozed", para("Back later.")),
              tab(:sent, "Sent", para("Everything you sent.")),
              tab(:drafts, "Drafts", para("Unfinished business.")),
              tab(:archive, "Archive", para("Kept, but out of the way.")),
              tab(:spam, "Spam", para("The bad stuff.")),
              tab(:trash, "Trash", para("On its way out.")),
              tab(:settings, "Settings", para("The last tab — you had to drag to get here."))
            ]}
            </MishkaTabs>
          </Column>
          """
        end
      },
      %Example{
        title: "Without the indicator",
        description: "indicator: false drops the underline; colour still marks the active tab.",
        code: ~S"""
        <MishkaTabs active={@tab} indicator={false} on_change={:pick}>{tabs_list}</MishkaTabs>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTabs active={@tb_plain} indicator={false} on_change={:tb_plain} id="plain">
              {[
              tab(:one, "First", para("No underline here.")),
              tab(:two, "Second", para("Just the active colour.")),
              tab(:three, "Third", para("Three tabs, no underline."))
            ]}
            </MishkaTabs>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled tab",
        description: "A disabled tab renders muted and wires no handler.",
        code: ~S"""
        tab(:locked, "Locked", body, disabled: true)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTabs active={@tb_locked} on_change={:tb_locked} id="locked">
              {[
              tab(:overview, "Overview", para("Tap the tabs — Locked will not respond.")),
              tab(:locked, "Locked", para("Unreachable."), disabled: true),
              tab(:specs, "Specs", para("This one works."))
            ]}
            </MishkaTabs>
          </Column>
          """
        end
      },
      %Example{
        title: "Colour and spacing",
        description: "color tints the active label and its underline; space sets the gap.",
        code: ~S"""
        <MishkaTabs
          active={@tab}
          color={0xFF7C3AED}
          space={26}
          on_change={:pick}
        >{tabs_list}</MishkaTabs>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTabs
              active={@tb_styled}
              color={0xFF7C3AED}
              space={26}
              on_change={:tb_styled}
              id="styled"
            >
              {[
              tab(:one, "Violet", para("A brand-tinted strip.")),
              tab(:two, "Spaced", para("With a wider gap between tabs.")),
              tab(:three, "Wide", para("Three tabs, 26dp apart."))
            ]}
            </MishkaTabs>
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
        name: "active",
        type: "tab id",
        default: "first tab",
        description: "Which tab is selected. A stale id falls back to the first tab."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, tab_id}}, so one handler serves every tab."
      },
      %{
        name: "indicator",
        type: "boolean",
        default: "true",
        description: "Underline the active tab."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Active label and indicator."
      },
      %{name: "space", type: "number", default: "18", description: "Gap between tabs."},
      %{
        name: "scrollable",
        type: "boolean",
        default: "true",
        description: "The strip drags sideways when the tabs overflow. A Row cannot wrap."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Tags: <id>-strip, <id>-tab-<tab>-<active|idle|disabled>, <id>-panel."
      },
      %{
        name: "tab.id / .label / .disabled",
        type: "term / string / boolean",
        default: "index / — / false",
        description: "Per tab. Its children are that tab's panel."
      }
    ]
  end

  @impl true
  # One clause per strip. The message carries the tab id, so a single clause
  # serves every tab in that strip.
  def handle({:tb_main, id}, socket), do: Mob.Socket.assign(socket, :tb_main, id)
  def handle({:tb_many, id}, socket), do: Mob.Socket.assign(socket, :tb_many, id)
  def handle({:tb_plain, id}, socket), do: Mob.Socket.assign(socket, :tb_plain, id)
  def handle({:tb_locked, id}, socket), do: Mob.Socket.assign(socket, :tb_locked, id)
  def handle({:tb_styled, id}, socket), do: Mob.Socket.assign(socket, :tb_styled, id)
  def handle(_tag, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Column>
          <Box width={38} height={8} background={:primary} corner_radius={:radius_sm} />
          <Spacer size={5} />
          <Box fill_width={true} height={2} background={:primary} corner_radius={:radius_sm} />
        </Column>
        <Spacer size={12} />
        <Box width={30} height={8} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={12} />
        <Box width={26} height={8} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={12} />
      <Box fill_width={true} height={24} background={:surface_raised} corner_radius={:radius_sm} />
    </Column>
    """
  end

  defp para(text) do
    [%{type: :text, props: %{text: text, text_size: :base, text_color: :muted}, children: []}]
  end
end
