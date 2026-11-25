defmodule MishkaMob.Showcase.Components.Heatmap do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaHeatmap`.

  Three shapes of the same grid: a year of contributions, one week of ticked
  habits, and the dense field a statistics card draws. The week is live — its
  cells are tappable, so the tick and the count below it move together.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  # The four tones of a kept-day scale, darkest for a full day.
  @done 0xFF4E9A73
  @mid 0xFFB08E55
  @light 0xFFE4D2B0
  @pale 0xFFEFE3CB
  @empty 0xFFE7E3DC

  @impl true
  def entry do
    %{
      slug: :heatmap,
      name: "Heatmap",
      category: "Data display",
      order: 0,
      description: "A grid of equal cells coloured by the caller — days, weeks, a year."
    }
  end

  @impl true
  def mount(socket) do
    Mob.Socket.assign(socket, :hm_week, [true, true, false, true, false, false, true])
  end

  @impl true
  def handle(tag, socket) do
    with "hm_" <> index <- Atom.to_string(tag),
         {i, ""} <- Integer.parse(index) do
      week = List.update_at(socket.assigns.hm_week, i, &(!&1))
      Mob.Socket.assign(socket, :hm_week, week)
    else
      _ -> socket
    end
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A year of days",
        description:
          "Ninety-one cells, thirteen to a row. The component draws the squares; " <>
            "the caller decides what a shade means.",
        code: ~S"""
        <MishkaHeatmap cells={@year} columns={13} cell_size={10} gap={4} corner_radius={2} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column>
            <MishkaHeatmap
              cells={MishkaMob.Showcase.Components.Heatmap.year()}
              columns={13}
              cell_size={10}
              gap={4}
              corner_radius={2}
            />
            <Spacer size={10} />
            <Text text="Less ░ ▒ ▓ █ More" text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "A week of ticks",
        description:
          "Seven cells on one line, each carrying a tick and a tap. Nothing here is a " <>
            "calendar: the caller says which day is kept and what a tap means.",
        code: ~S"""
        <MishkaHeatmap
          cells={week_cells(@week)}
          columns={7}
          cell_size={16}
          gap={5}
          corner_radius={5}
          tick_color={0xFFFBFAF8}
        />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column>
            <MishkaHeatmap
              id="hm-week"
              cells={MishkaMob.Showcase.Components.Heatmap.week_cells(@hm_week)}
              columns={7}
              cell_size={16}
              gap={5}
              corner_radius={5}
              tick_color={0xFFFBFAF8}
            />
            <Spacer size={10} />
            <Text
              text={MishkaMob.Showcase.Components.Heatmap.kept_line(@hm_week)}
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Density and corners",
        description:
          "The same data at a card's scale: 27 columns of 8pt cells wraps a " <>
            "thirteen-week field into four tight rows.",
        code: ~S"""
        <MishkaHeatmap cells={@field} columns={27} cell_size={8} gap={4} corner_radius={2} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaHeatmap
              cells={MishkaMob.Showcase.Components.Heatmap.year()}
              columns={27}
              cell_size={8}
              gap={4}
              row_gap={4}
              corner_radius={2}
            />
            <Spacer size={16} />
            <MishkaHeatmap
              cells={MishkaMob.Showcase.Components.Heatmap.year()}
              columns={14}
              cell_size={12}
              gap={6}
              row_gap={6}
              corner_radius={4}
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
        name: "cells",
        type: "list",
        default: "[]",
        description:
          "One entry per cell: a map (%{color:, tick:, on_tap:, id:}) or a bare colour."
      },
      %{
        name: "columns",
        type: "integer / nil",
        default: "nil",
        description: "Cells per row. nil puts every cell on one line."
      },
      %{
        name: "cell_size",
        type: "number",
        default: "12",
        description: "Each cell's width and height."
      },
      %{name: "gap", type: "number", default: "4", description: "Space between cells on a row."},
      %{name: "row_gap", type: "number", default: "gap", description: "Space between rows."},
      %{
        name: "corner_radius",
        type: "number",
        default: "nil",
        description: "Corner rounding, per cell. nil is square."
      },
      %{
        name: "tick_icon",
        type: "string / node / nodes",
        default: "\"✓\"",
        description: "What a cell with tick: true draws."
      },
      %{
        name: "tick_size",
        type: "number",
        default: "cell_size - 5",
        description: "A string tick_icon's text size."
      },
      %{
        name: "tick_color",
        type: "color / ARGB",
        default: ":on_primary",
        description: "A string tick_icon's ink."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "TestTag on the grid; cells are id-index unless they carry their own."
      }
    ]
  end

  @doc "The week example's cells, in the order the grid draws them."
  @spec week_cells([boolean()]) :: [map()]
  def week_cells(week) do
    week
    |> Enum.with_index()
    |> Enum.map(fn {kept?, index} ->
      %{
        color: if(kept?, do: @done, else: @empty),
        tick: kept?,
        id: "hm-cell-#{index}",
        on_tap: {self(), String.to_atom("hm_#{index}")}
      }
    end)
  end

  @doc "How many of the week's seven cells are ticked, in words."
  @spec kept_line([boolean()]) :: String.t()
  def kept_line(week), do: "#{Enum.count(week, & &1)} of 7 kept"

  @doc """
  A deterministic year of tones — no randomness, so a device test and a frame
  taken on two devices compare.

  91 cells, four shades, arranged so runs of near-equal shades read as a
  plausible week rather than as a repeating stripe.
  """
  @spec year() :: [non_neg_integer()]
  def year do
    tones = [@pale, @light, @mid, @done, @light, @pale, @mid]

    for i <- 0..90 do
      Enum.at(tones, rem(i * 3 + div(i, 7), length(tones)))
    end
  end
end
