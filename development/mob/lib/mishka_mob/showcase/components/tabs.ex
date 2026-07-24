defmodule MishkaMob.Showcase.Components.Tabs do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaTabs`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaTabs, only: [tabs: 2, tab: 3, tab: 4]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :tabs,
      name: "Tabs",
      category: "Navigation",
      order: 0,
      description: "A tab strip with one visible panel."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:tb_main, :overview)
    |> Mob.Socket.assign(:tb_plain, :one)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A tab strip",
        description: "Each tab declares its own panel; only the active one renders.",
        code: ~S"""
        {tabs([active: @tab, on_change: :pick], [
          tab(:overview, "Overview", overview_body()),
          tab(:specs, "Specs", specs_body())
        ])}

        def handle_info({:tap, {:pick, id}}, socket) do
          {:noreply, assign(socket, :tab, id)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {tabs([active: @tb_main, on_change: :tb_main], [
              tab(:overview, "Overview", para("A native tab strip built from Row, Box and Text.")),
              tab(:specs, "Specs", para("Content-sized tabs, so the strip works on both platforms.")),
              tab(:support, "Support", para("Each panel is the tab's own children."))
            ])}
          </Column>
          """
        end
      },
      %Example{
        title: "Without the indicator",
        description: "indicator: false drops the underline; colour still marks the active tab.",
        code: ~S"""
        {tabs([active: @tab, indicator: false, on_change: :pick], tabs_list)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {tabs([active: @tb_plain, indicator: false, on_change: :tb_plain], [
              tab(:one, "First", para("No underline here.")),
              tab(:two, "Second", para("Just the active colour."))
            ])}
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
            {tabs([active: @tb_main, on_change: :tb_main], [
              tab(:overview, "Overview", para("Tap the tabs — Locked will not respond.")),
              tab(:locked, "Locked", para("Unreachable."), disabled: true),
              tab(:specs, "Specs", para("This one works."))
            ])}
          </Column>
          """
        end
      },
      %Example{
        title: "Colour and spacing",
        description: "color tints the active label and its underline; space sets the gap.",
        code: ~S"""
        {tabs([active: @tab, color: 0xFF7C3AED, space: 26, on_change: :pick], tabs_list)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {tabs([active: @tb_plain, color: 0xFF7C3AED, space: 26, on_change: :tb_plain], [
              tab(:one, "Violet", para("A brand-tinted strip.")),
              tab(:two, "Spaced", para("With a wider gap between tabs."))
            ])}
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
        name: "tab.id / .label / .disabled",
        type: "term / string / boolean",
        default: "index / — / false",
        description: "Per tab. Its children are that tab's panel."
      }
    ]
  end

  @impl true
  def handle({:tb_main, id}, socket), do: Mob.Socket.assign(socket, :tb_main, id)
  def handle({:tb_plain, id}, socket), do: Mob.Socket.assign(socket, :tb_plain, id)
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
