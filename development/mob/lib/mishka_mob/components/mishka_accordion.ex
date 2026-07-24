defmodule MishkaMob.Components.MishkaAccordion do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Accordion** — a stack of
  disclosure items where each header toggles its panel. Built as a pure-Elixir
  `Mob.Composite` (a custom `<MishkaAccordion>` tag), so it ships **no native
  Swift/Kotlin**: it expands into Mob's built-in `Box`/`Row`/`Column`/`Text`
  widgets at render time.

  Mirrors the headless component's *behaviour* (`multiple`, `collapsible`,
  per-item `disabled`, a controlled open set). The web-only affordances have no
  native counterpart and are deliberately absent: `orientation`/`loop` (arrow-key
  focus movement), `heading_level` (`<h1>`-`<h6>` semantics),
  `hidden_until_found` (browser find-in-page), and every `*_class` — a phone has
  no DOM, no CSS cascade, and no roving tab focus.

  ## Controlled, because composites are stateless

  The web engine keeps open/closed state in the DOM. A Mob composite is a pure
  function of its props, so the open set lives in the **screen** and comes back
  in as `open`. Toggling is a pure transition — use `toggle/3` so every screen
  gets identical `multiple` / `collapsible` semantics instead of re-deriving it:

      def handle_info({:tap, {:toggle_faq, id}}, socket) do
        open = MishkaAccordion.toggle(socket.assigns.faq_open, id, multiple: false)
        {:noreply, Mob.Socket.assign(socket, :faq_open, open)}
      end

  ## Usage

  Registered once at boot (see `MishkaMob.App.on_start/0`):

      Mob.Composite.register(:mishka_accordion, {#{inspect(__MODULE__)}, :expand})

  Items are the tag's children — the native analogue of Chelekom's `<:item>`
  slot. Each child is a `:mishka_accordion_item` node carrying `id` + `title`,
  whose own children are the panel body:

      %{type: :mishka_accordion, props: %{open: @faq_open, on_toggle: :toggle_faq},
        children: [
          %{type: :mishka_accordion_item,
            props: %{id: :what, title: "What is Mishka Chelekom?"},
            children: [text("A component library for Phoenix — and now for Mob.")]}
        ]}

  `on_toggle` is auto-wired by the composite framework, so you pass a bare atom;
  it fires as `{:tap, {tag, item_id}}` so one handler serves every item.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `open` | list of item ids | `[]` | The open set. Lives in the screen (see above). |
  | `multiple` | boolean | `false` | Allow several panels open at once; when `false` opening one closes the rest. |
  | `collapsible` | boolean | `true` | Allow the open item to be closed by its own trigger. `false` keeps one panel always open. |
  | `disabled` | boolean | `false` | Disable every trigger (cascades to items). |
  | `on_toggle` | event tag (atom) | — | Sent as `{:tap, {tag, item_id}}`. Without it the triggers are inert (a warning is logged). |
  | `chevron` | boolean | `true` | Show the ▸/▾ state indicator. |
  | `background` | color token / ARGB int | `:surface_raised` | Item background. |
  | `corner_radius` | radius token / number | `:radius_md` | Rounds each item. |
  | `padding` | spacing token / number | `:space_md` | Padding inside the trigger and the panel. |
  | `space` | number | `8` | Gap between items. `0` joins them into one block. |

  Per item (`:mishka_accordion_item` props): `id` (any term; falls back to the
  0-based index), `title` (string), `disabled` (boolean).

  ## Why the trigger is a Box and not a Button

  A `:button` renders a Material Button on Android, which **centres** its label —
  an accordion header must read from the leading edge. `on_tap` is applied as a
  `clickable` modifier for every node type *except* button (`MobBridge.kt`), and
  iOS gives a Box `contentShape(Rectangle()).onTapGesture` (`MobRootView.swift`),
  so a tappable Box has identical tap behaviour with correct alignment.
  """

  require Logger

  @item_type :mishka_accordion_item

  @doc """
  Composite expander. `props` arrive with `on_*` targets already resolved to
  `{screen_pid, tag}` tuples; `ctx` is `%{screen: pid}`. `children` are the raw,
  un-expanded item nodes (Mob.Composite re-expands this output to a fixpoint).
  """
  @spec expand(map(), [map()], %{screen: pid()}) :: map()
  def expand(props, children, _ctx) do
    items = items(children)
    warn_if_inert(props, items)

    items
    |> Enum.map(&item_node(&1, props))
    |> Enum.intersperse(gap(Map.get(props, :space, 8)))
    |> column()
  end

  @doc """
  Pure open-set transition for a trigger tap, honouring `multiple` and
  `collapsible`. Returns the next list of open ids.

  Options: `:multiple` (default `false`), `:collapsible` (default `true`).

      iex> alias MishkaMob.Components.MishkaAccordion, as: A
      ...> {A.toggle([], :a), A.toggle([:a], :b), A.toggle([:a], :b, multiple: true)}
      {[:a], [:b], [:a, :b]}

      iex> alias MishkaMob.Components.MishkaAccordion, as: A
      ...> {A.toggle([:a], :a), A.toggle([:a], :a, collapsible: false)}
      {[], [:a]}
  """
  @spec toggle([term()], term(), keyword()) :: [term()]
  def toggle(open, id, opts \\ []) when is_list(open) do
    multiple? = Keyword.get(opts, :multiple, false)
    collapsible? = Keyword.get(opts, :collapsible, true)

    cond do
      # Open already: close it, unless the accordion insists one stays open.
      id in open and collapsible? -> List.delete(open, id)
      id in open -> open
      # Closed: add it, or replace the set when only one may be open.
      multiple? -> open ++ [id]
      true -> [id]
    end
  end

  # ── Items ──────────────────────────────────────────────────────────────────

  # Keep only item children, and give each a stable id: the explicit `id` prop,
  # else its 0-based position (mirrors the web component's `"#{id}-#{index}"`).
  defp items(children) do
    children
    |> Enum.filter(&match?(%{type: @item_type}, &1))
    |> Enum.with_index()
    |> Enum.map(fn {item, index} ->
      props = Map.get(item, :props, %{})

      %{
        id: Map.get(props, :id, index),
        title: Map.get(props, :title),
        disabled: truthy?(Map.get(props, :disabled, false)),
        body: Map.get(item, :children, [])
      }
    end)
  end

  defp item_node(item, props) do
    open? = item.id in List.wrap(Map.get(props, :open, []))
    disabled? = truthy?(Map.get(props, :disabled, false)) or item.disabled

    inner =
      [trigger(item, props, open?, disabled?)] ++
        if open?, do: [panel(item, props)], else: []

    %{
      type: :box,
      props:
        %{fill_width: true, background: Map.get(props, :background, :surface_raised)}
        |> maybe_put(:corner_radius, Map.get(props, :corner_radius, :radius_md)),
      children: [%{type: :column, props: %{fill_width: true}, children: inner}]
    }
  end

  # The header row: title on the leading edge, state chevron trailing. Tappable
  # unless disabled — a disabled trigger gets no handler at all, so it cannot
  # fire and reads as inert.
  defp trigger(item, props, open?, disabled?) do
    text_color = if disabled?, do: :muted, else: :on_surface

    row =
      [
        %{
          type: :text,
          props: %{text: item.title, text_size: :lg, text_color: text_color},
          children: []
        }
      ] ++
        if truthy?(Map.get(props, :chevron, true)) do
          [flex_spacer(), chevron(open?, text_color)]
        else
          []
        end

    box_props = %{fill_width: true, padding: Map.get(props, :padding, :space_md)}

    box_props =
      case tap_target(Map.get(props, :on_toggle), item.id, disabled?) do
        nil -> box_props
        tap -> Map.put(box_props, :on_tap, tap)
      end

    %{
      type: :box,
      props: box_props,
      children: [%{type: :row, props: %{fill_width: true}, children: row}]
    }
  end

  defp panel(item, props) do
    %{
      type: :column,
      props: %{fill_width: true, padding: Map.get(props, :padding, :space_md)},
      children: item.body
    }
  end

  defp chevron(open?, color) do
    %{
      type: :text,
      props: %{text: if(open?, do: "▾", else: "▸"), text_size: :lg, text_color: color},
      children: []
    }
  end

  # One handler serves every item: the tag is widened to {tag, item_id}. Nil for
  # a disabled item or a missing on_toggle, so no tap is wired.
  defp tap_target(_on_toggle, _id, true), do: nil
  defp tap_target({pid, tag}, id, _disabled) when is_pid(pid), do: {pid, {tag, id}}
  defp tap_target(_on_toggle, _id, _disabled), do: nil

  defp warn_if_inert(props, items) do
    if items != [] and not tap?(Map.get(props, :on_toggle)) do
      Logger.warning(
        "[MishkaAccordion] rendered with no `on_toggle` — its triggers cannot open anything; " <>
          "the panels can only change by replacing the `open` prop from the screen."
      )
    end
  end

  # ── Node helpers ───────────────────────────────────────────────────────────
  defp column(children), do: %{type: :column, props: %{fill_width: true}, children: children}
  defp gap(size), do: %{type: :spacer, props: %{size: size}, children: []}
  defp flex_spacer, do: %{type: :spacer, props: %{weight: 1}, children: []}

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp tap?({pid, _tag}) when is_pid(pid), do: true
  defp tap?(_), do: false

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
