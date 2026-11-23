defmodule MishkaMob.Components.MishkaHeatmap do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Heatmap** — a grid of equal
  cells whose colour the caller owns.

  A heatmap is a table of days: one square per day, shaded by how much of it
  was kept. The component draws the squares and nothing else — the scale, the
  palette, the caption and the meaning of a colour all belong to the caller, so
  one component serves a year of contributions, a thirteen-week consistency
  field and a single week of ticked habits.

  ## Cells are data

  `cells` is a list, and each entry is either

    * a map — `%{color: c}`, with optional `tick: true`, `on_tap: {pid, tag}`
      and `id: "…"` — or
    * a bare colour token or ARGB integer, shorthand for `%{color: c}`.

  `color` is passed through untouched, so an app's own palette maps straight
  into the grid. A cell with no `color` is drawn in the platform default, which
  is what `:transparent` is for when a gap must still occupy a cell.

  `columns` declares where the grid breaks. Mob has no wrap primitive and no
  measurement back into `render/1`, so the count is declared rather than
  measured — the same rule every grid in Mob follows. `nil` puts every cell on
  one line, which is what a week strip wants.

  ## A tick says the day was kept

  `tick: true` on a cell draws `tick_icon` centred in it. A string is drawn as a
  `Text` at `tick_size` in `tick_color`; a node or list of nodes is used as
  given, so an app's Material Symbol or icon font keeps its own type and the
  caller sizes it. Cells hug nothing and are exactly `cell_size` square, so the
  glyph is the caller's choice and cannot change the grid's rhythm.

  ## Taps

  A cell with `on_tap` is tappable. The event goes through
  `MishkaMob.Components.Event.handler/1`, so a bare tag is widened to
  `{self(), tag}` and the message is `{:tap, tag}` in the screen's own process
  — the same shape every other control in the set sends.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `cells` | list of maps / colours | `[]` | One entry per cell, in reading order. |
  | `columns` | integer / `nil` | `nil` | Cells per row; `nil` puts them on one line. |
  | `cell_size` | number | `12` | Each cell's width and height, in dp/pt. |
  | `gap` | number | `4` | Space between cells on a row. |
  | `row_gap` | number | `gap` | Space between rows. |
  | `corner_radius` | number | `nil` (square) | Corner rounding, per cell. |
  | `tick_icon` | string, node, or list of nodes | `"✓"` | What a ticked cell draws. |
  | `tick_size` | number | `cell_size - 5` | A string `tick_icon`'s text size. |
  | `tick_color` | color token / ARGB int | `:on_primary` | A string `tick_icon`'s ink. |
  | `id` | string | unset | Native testTag on the grid; cells are `<id>-<index>` unless they carry their own. |

  Children are ignored; the grid is data.

  **Documentation:** https://mishka.tools/chelekom/docs/mob/heatmap
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc """
  Composite expander (`<MishkaHeatmap />`). Delegates to `heatmap/1`.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: heatmap(props)

  @doc """
  The grid node.

      heatmap(cells: [0xFF4E9A73, 0xFFE7E3DC], cell_size: 8, gap: 4)
      heatmap(cells: [%{color: 0xFF4E9A73, tick: true}], columns: 7, cell_size: 16)
  """
  @spec heatmap(map() | keyword()) :: map()
  def heatmap(props \\ %{}) do
    props = Map.new(props)
    cells = props |> Map.get(:cells) |> List.wrap() |> Enum.map(&normalise_cell/1)
    gap = setting(props, :gap, 4)

    ~MOB"""
    <Column>
      {rows(cells, Map.get(props, :columns), props, gap)}
    </Column>
    """
    |> put(:id, Map.get(props, :id))
  end

  # A bare colour is the common case — a list of tones with no ticks and no
  # taps — and making every one of them a map at the call site is noise.
  defp normalise_cell(%{} = cell), do: cell
  defp normalise_cell(color), do: %{color: color}

  defp rows([], _columns, _props, _gap), do: []

  defp rows(cells, columns, props, gap) when is_integer(columns) and columns > 0 do
    cells
    |> Enum.chunk_every(columns)
    |> Enum.map(&row(&1, props, gap))
    |> Enum.intersperse(vertical_gap(setting(props, :row_gap, gap)))
  end

  defp rows(cells, _one_line, props, gap), do: [row(cells, props, gap)]

  defp row(cells, props, gap) do
    children =
      cells
      |> Enum.with_index()
      |> Enum.map(fn {cell, index} -> cell_node(cell, index, props) end)
      |> Enum.intersperse(horizontal_gap(gap))

    ~MOB"""
    <Row align="center">
      {children}
    </Row>
    """
  end

  defp cell_node(cell, index, props) do
    size = setting(props, :cell_size, 12)

    box_props =
      %{width: size, height: size, align: "center", background: Map.get(cell, :color)}
      |> maybe_put(:corner_radius, Map.get(props, :corner_radius))
      |> maybe_put(:id, Map.get(cell, :id) || cell_id(Map.get(props, :id), index))
      |> maybe_put(:on_tap, Event.handler(Map.get(cell, :on_tap)))

    %{type: :box, props: box_props, children: tick_children(cell, props)}
  end

  defp tick_children(cell, props) do
    if truthy?(Map.get(cell, :tick)) do
      tick = Map.get(props, :tick_icon) || "✓"
      size = setting(props, :tick_size, setting(props, :cell_size, 12) - 5)
      List.wrap(tick_node(tick, size, setting(props, :tick_color, :on_primary)))
    else
      []
    end
  end

  defp tick_node(icon, size, color) when is_binary(icon) do
    ~MOB(<Text text={icon} text_size={size} text_color={color} />)
  end

  defp tick_node(nodes, _size, _color), do: nodes

  defp horizontal_gap(gap), do: %{type: :spacer, props: %{size: gap}, children: []}
  defp vertical_gap(gap), do: %{type: :spacer, props: %{size: gap}, children: []}

  defp cell_id(nil, _index), do: nil
  defp cell_id(id, index), do: "#{id}-#{index}"

  defp setting(props, key, default), do: Map.get(props, key) || default

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_value), do: true
end
