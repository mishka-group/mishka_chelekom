defmodule MishkaMob.Components.MishkaTabs do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Tabs** — a tab strip with one
  visible panel.

  ## Why this is not Mob's `TabBar`

  Mob ships a `TabBar` tag and it is tempting to map onto it, but it is a
  different component: `MobTabBar` renders a `Scaffold` with a Material
  `NavigationBar` pinned to the **bottom** of the screen, each item requiring an
  icon. That is app-level navigation, not an inline tab strip — dropping it into
  a card would move the tabs to the bottom of the phone and take over the
  layout.

  Chelekom's tabs are a strip above their panel, so this port builds that from
  `Row` / `Box` / `Text` instead. When you *do* want bottom navigation, use
  `TabBar` directly; it is the right widget for that job.

  ## Tabs are slot tags, like Chelekom's `<:tab>`

  Write them out as `<MishkaTab>` children. A tab and its panel are declared
  together rather than matched up by position:

      <MishkaTabs active={@tab} on_change={:pick} id="main">
        <MishkaTab id={:overview} label="Overview">
          <Text text="What this thing is." />
        </MishkaTab>
        <MishkaTab id={:specs} label="Specs">
          <Text text="How big it is." />
        </MishkaTab>
      </MishkaTabs>

  A slot tag is matched on `:type` among the parent's children and consumed by
  `expand/3`, so it never reaches the renderer.

  `tab/4` builds exactly the same node by hand —
  `%{type: :mishka_tab, props: %{id: …, label: …}, children: panel}` — and the
  two forms are interchangeable. Use the tag when you are writing tabs out, the
  function when the tabs come from a list:

      <MishkaTabs active={@tab} on_change={:pick}>
        {Enum.map(@folders, fn {id, label, body} -> tab(id, label, body) end)}
      </MishkaTabs>

  `on_change` is auto-wired by the composite framework, so you pass a bare atom;
  it fires as `{:tap, {tag, tab_id}}`, so one handler serves every tab.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `active` | tab id | first tab | Which tab is selected. Lives in the screen. |
  | `on_change` | event tag (atom) | — | Sent as `{:tap, {tag, tab_id}}`. |
  | `indicator` | boolean | `true` | Underline the active tab. |
  | `color` | color token / ARGB int | `:primary` | Active label and indicator. |
  | `space` | number | `18` | Gap between tabs. |
  | `scrollable` | boolean | `true` | The strip drags sideways when the tabs overflow. |
  | `id` | string | `nil` | Test tags — see below. |

  Per tab (`:mishka_tab` props): `id`, `label`, `disabled`.

  ## The strip scrolls, because a Row cannot wrap

  The tab bar used to be a bare `Row`, so the fifth tab — or any set of long
  labels — was drawn past the screen edge and could never be reached. It is a
  horizontal `Scroll` now: drag it left and right with a finger. `scrollable:
  false` gives back the old fixed row for the cases that genuinely fit.

  Mob's native `tab_bar` node is no help here: on Android it is a Material
  `NavigationBar` pinned to the bottom of the screen and on iOS a SwiftUI
  `TabView`. That is app-level navigation, not an inline strip, and neither
  scrolls sideways.

  ## Tags, and why the state is in them

  A tab announces itself with a colour and a 2dp underline, and **neither is in
  the semantics tree** — so a device test cannot otherwise tell the selected tab
  from any other. With an `id` set:

    * the strip is `<id>-strip`,
    * each trigger is `<id>-tab-<tab_id>-<active|idle|disabled>`,
    * the panel is `<id>-panel`.

  Not ported: `orientation: "vertical"`, `activate_on_focus` (there is no focus
  ring to follow), `default_value` (the screen holds state, so "uncontrolled"
  has no meaning here) and the `*_class` attrs.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @tab_type :mishka_tab

  @doc """
  Composite expander (`<MishkaTabs>`). Children are `:mishka_tab` nodes.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: tabs(props, children)

  @doc "Build one tab node: its label and its panel, declared together."
  @spec tab(term(), String.t(), [map()], keyword()) :: map()
  def tab(id, label, panel \\ [], opts \\ []) do
    %{
      type: @tab_type,
      props: %{id: id, label: label, disabled: Keyword.get(opts, :disabled, false)},
      children: panel
    }
  end

  @doc """
  The tabs node: a strip of labels above the active tab's panel.
  """
  @spec tabs(map() | keyword(), [map()]) :: map()
  def tabs(props \\ %{}, children \\ []) do
    props = Map.new(props)
    items = items(children)
    active = active(props, items)

    ~MOB"""
    <Column fill_width={true}>
      {strip(items, props, active)}
      {panel(items, active, Map.get(props, :id))}
    </Column>
    """
  end

  @doc """
  Which tab is active: the `active` prop when it names a real tab, otherwise the
  first one — so a stale or missing id still shows something rather than an
  empty panel.
  """
  @spec active(map() | keyword(), [map()]) :: term() | nil
  def active(props, items) do
    ids = Enum.map(items, & &1.id)
    wanted = props |> Map.new() |> Map.get(:active)

    if wanted in ids, do: wanted, else: List.first(ids)
  end

  defp items(children) do
    children
    |> Enum.filter(&match?(%{type: @tab_type}, &1))
    |> Enum.with_index()
    |> Enum.map(fn {tab, index} ->
      props = Map.get(tab, :props, %{})

      %{
        id: Map.get(props, :id) || index,
        label: Map.get(props, :label),
        disabled: truthy?(Map.get(props, :disabled, false)),
        panel: Map.get(tab, :children, [])
      }
    end)
  end

  # The strip scrolls sideways.
  #
  # It used to be a bare `<Row fill_width={true}>`, and a Row cannot wrap — so
  # the fifth tab, or any set of long labels, was drawn past the screen edge and
  # was permanently unreachable. Nothing said so, because every example on the
  # showcase page happened to fit.
  #
  # A horizontal `Scroll` fixes it on BOTH platforms with no native change. Mob's
  # own `tab_bar` node is no help here — on Android it is a Material
  # `NavigationBar` pinned to the bottom of the screen and on iOS a SwiftUI
  # `TabView`, i.e. app-level navigation, and neither scrolls horizontally.
  defp strip(items, props, active) do
    space = Map.get(props, :space) || 18
    id = Map.get(props, :id)

    triggers =
      items
      |> Enum.map(&trigger(&1, props, &1.id == active))
      |> Enum.intersperse(~MOB(<Spacer size={space} />))

    row = ~MOB"""
    <Row>
      {triggers}
    </Row>
    """

    # `nil` means "not given", not `false`: `Map.get/3` hands back its default
    # only when the key is ABSENT, so a keyword-built props map carrying an
    # unset key as an explicit nil used to read as a deliberate `false`.
    # Only a real `false` turns this off.
    if Map.get(props, :scrollable) != false do
      %{
        type: :scroll,
        props: scroll_props(id),
        children: [row]
      }
    else
      %{row | props: Map.put(row.props, :fill_width, true)}
    end
  end

  defp scroll_props(nil), do: %{axis: "horizontal"}
  defp scroll_props(id), do: %{axis: "horizontal", id: strip_id(id)}

  @doc """
  The test tag on the scrolling strip, given the tabs' `id`.

      iex> MishkaMob.Components.MishkaTabs.strip_id("plans")
      "plans-strip"
  """
  @spec strip_id(String.t()) :: String.t()
  def strip_id(id) when is_binary(id), do: id <> "-strip"

  @doc """
  The test tag on one tab's trigger, with its state folded in.

  A tab says which one it is with a colour and a 2dp underline, and neither is
  in the semantics tree — so without the state in the tag itself a device test
  cannot tell the selected tab from any other.

      iex> MishkaMob.Components.MishkaTabs.tab_id("plans", :pro, :active)
      "plans-tab-pro-active"
  """
  @spec tab_id(String.t(), term(), :active | :idle | :disabled) :: String.t()
  def tab_id(id, tab, state) when is_binary(id), do: "#{id}-tab-#{tab}-#{state}"

  @doc """
  The test tag on the panel below the strip.

      iex> MishkaMob.Components.MishkaTabs.panel_id("plans")
      "plans-panel"
  """
  @spec panel_id(String.t()) :: String.t()
  def panel_id(id) when is_binary(id), do: id <> "-panel"

  # A tappable Box, not a Button: a Material Button centres and boxes its label,
  # which is wrong for a tab strip.
  defp trigger(item, props, active?) do
    color = Map.get(props, :color) || :primary

    text_color =
      cond do
        item.disabled -> :muted
        active? -> color
        true -> :on_surface
      end

    node = ~MOB"""
    <Column>
      <Text text={item.label} text_size={:base} text_color={text_color} />
      <Spacer size={6} />
      <Box
        fill_width={true}
        height={2}
        background={color}
        corner_radius={:radius_sm}
        :if={active? and Map.get(props, :indicator) != false}
      />
    </Column>
    """

    node = tag(node, trigger_tag(Map.get(props, :id), item, active?))

    case tap_target(props, item) do
      nil -> node
      target -> %{node | props: Map.put(node.props, :on_tap, target)}
    end
  end

  defp trigger_tag(nil, _item, _active?), do: nil

  defp trigger_tag(id, item, active?) do
    state =
      cond do
        item.disabled -> :disabled
        active? -> :active
        true -> :idle
      end

    tab_id(id, item.id, state)
  end

  defp tap_target(_props, %{disabled: true}), do: nil

  defp tap_target(props, item) do
    case Event.handler(Map.get(props, :on_change)) do
      nil -> nil
      {pid, tag} -> {pid, {tag, item.id}}
    end
  end

  defp panel(items, active, id) do
    body =
      case Enum.find(items, &(&1.id == active)) do
        nil -> []
        item -> item.panel
      end

    ~MOB"""
    <Column fill_width={true} :if={body != []}>
      <Spacer size={14} />
      {body}
    </Column>
    """
    |> tag(if(is_binary(id), do: panel_id(id)))
  end

  defp tag(node, nil), do: node
  defp tag(node, id), do: %{node | props: Map.put(node.props, :id, id)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
