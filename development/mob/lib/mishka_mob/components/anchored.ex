defmodule MishkaMob.Components.Anchored do
  @moduledoc """
  The `:anchored` node — a panel that draws OVER the page instead of taking a
  place in it.

  This is the native answer to the web's `position: fixed` floating panel, and
  it is what lets `MishkaMob.Components.MishkaPopover`,
  `MishkaMob.Components.MishkaTooltip` and
  `MishkaMob.Components.MishkaPreviewCard` behave like their Chelekom originals
  rather than like an accordion.

  ## Why it has to be a node type

  The three components used to stack `[trigger, panel]` in a `:column` or a
  `:row`. That is layout, not floating: opening a panel pushed every sibling
  below it down the page, a tooltip shoved the icon next to it sideways, and
  `side: :top` was a lie — a panel "above" its trigger still consumed the same
  vertical space.

  The obvious fix — place the panel outside the parent's bounds — does not work
  and was measured failing. A `:box` with a `corner_radius` clips, and every
  showcase example sits inside one; a vertical `:scroll` clips its main axis,
  and every gallery page is one. A panel placed outside either measures
  `(0, 0, 0, 0)`: invisible AND untappable, which is worse than the accordion it
  replaced.

  So the panel needs its own window. On Android that is
  `androidx.compose.ui.window.Popup`, which no ancestor can clip, positioned by
  a transliteration of the web's `positionPopup()`.

  ## Shape

  Exactly two children. The first is the anchor and renders in flow; the second
  is the panel and renders over everything:

      Anchored.anchor(trigger_node, panel_node, side: :bottom, align: :start, side_offset: 8)

  One child means "closed" — the anchor alone, no window, no panel.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `side` | `:top` `:right` `:bottom` `:left` | `:bottom` | Which side of the anchor the panel takes. |
  | `align` | `:start` `:center` `:end` | `:center` | Where it sits along the cross axis. |
  | `side_offset` | number | `0` | Gap between anchor and panel, in dp. |
  | `align_offset` | number | `0` | Nudge along the align axis. Positive pushes INWARD on `:end`, matching the web. |
  | `panel_offset_x` / `panel_offset_y` | number | `0` | Raw nudge, applied last. |
  | `flip` | boolean | `true` | Turn to the opposite side when the requested one has no room. |
  | `clamp` | boolean | `true` | Keep the panel inside the window. |
  | `edge_padding` | number | `8` | Kept clear of the window edges, plus the safe-area inset. |
  | `panel_max_width` / `panel_max_height` | number | screen − 2·edge | Cap on the panel. |
  | `focusable` | boolean | `false` | Whether the panel's window takes keyboard focus. |

  `offset_x` / `offset_y` are deliberately NOT read: `Mob.Renderer` wraps any
  node carrying them in an offset Box, which would move the ANCHOR rather than
  the panel. That is why the raw nudge is spelled `panel_offset_*`.

  ## Open state is still yours

  The panel's window never dismisses itself — no back-press, no outside tap.
  The screen owns `open`, exactly as it did before, so the node cannot
  desynchronise from the assign that produced it.

  ## iOS

  Not implemented. An unknown node type on iOS falls through to
  `MobNodeTypeColumn`, so an anchored panel degrades to the old stacked
  accordion rather than erroring or blanking. See `IOS_TODO.md` §17.
  """

  @type side :: :top | :right | :bottom | :left
  @type align :: :start | :center | :end

  # Everything the bridge reads. Anything else on the node is ignored, so a
  # caller that passes its whole props map does not leak chrome into the layout.
  @props ~w(side align side_offset align_offset panel_offset_x panel_offset_y
            flip clamp edge_padding panel_max_width panel_max_height focusable
            id)a

  @doc """
  An anchored pair: `anchor` in flow, `panel` over the page.

      Anchored.anchor(trigger, panel, side: :top, align: :center, side_offset: 8)

  `opts` may be a keyword list or a map; keys outside the documented props are
  dropped, and `nil` values are omitted so the bridge's own defaults apply.
  """
  @spec anchor(map(), map(), keyword() | map()) :: map()
  def anchor(anchor, panel, opts \\ []) do
    %{type: :anchored, props: take(opts), children: [anchor, panel]}
  end

  @doc """
  The closed form: the anchor alone, with no panel and no window.

  Kept as its own function so a component never has to build a one-child
  `:anchored` node by hand — one child is a shape the bridge tolerates but that
  says nothing to a reader.
  """
  @spec closed(map(), keyword() | map()) :: map()
  def closed(anchor, opts \\ []) do
    %{type: :anchored, props: take(opts), children: [anchor]}
  end

  defp take(opts) do
    opts
    |> Map.new()
    |> Map.take(@props)
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
