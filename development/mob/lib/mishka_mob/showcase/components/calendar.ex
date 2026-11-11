defmodule MishkaMob.Showcase.Components.Calendar do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaCalendar`.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :calendar,
      name: "Calendar",
      category: "Data display",
      order: 9,
      description: "A month grid of day cells with selection, today, markers and navigation."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:calendar_today, ~D[2026-11-11])
    |> Mob.Socket.assign(:calendar_selected, ~D[2026-11-14])
    |> Mob.Socket.assign(:calendar_month, {2026, 11})
  end

  @impl true
  def handle({:calendar_pick, %Date{} = date}, socket) do
    Mob.Socket.assign(socket, :calendar_selected, date)
  end

  def handle(:calendar_prev, socket), do: shift_month(socket, -1)
  def handle(:calendar_next, socket), do: shift_month(socket, 1)
  def handle(_tag, socket), do: socket

  defp shift_month(socket, step) do
    {year, month} = socket.assigns.calendar_month
    {year, month} = shift(year, month, step)
    Mob.Socket.assign(socket, :calendar_month, {year, month})
  end

  defp shift(year, 1, -1), do: {year - 1, 12}
  defp shift(year, 12, 1), do: {year + 1, 1}
  defp shift(year, month, step), do: {year, month + step}

  @impl true
  def examples do
    [
      %Example{
        title: "A month with today, a selection and markers",
        description:
          "The weeks arrive already laid out. The state on each cell picks the " <>
            "tone; the markers are the colours of the dots under the number.",
        code: ~S"""
        <MishkaCalendar
          weeks={weeks}
          weekday_labels={~w(M T W T F S S)}
          on_select={:calendar_pick}
        />
        """,
        render: fn assigns ->
          selected = assigns.calendar_selected
          today = assigns.calendar_today
          {year, month} = assigns.calendar_month
          weeks = weeks(year, month, today, selected, "cal-plain")

          assigns = %{weeks: weeks}

          ~MOB"""
          <MishkaCalendar
            id="cal-plain"
            weeks={@weeks}
            weekday_labels={~w(M T W T F S S)}
            on_select={:calendar_pick}
            cell_color={:on_surface}
            outside_color={:muted}
            today_background={:on_surface}
            today_color={:background}
            selected_background={:surface_raised}
            selected_shadow="0 1 2 0 #0D1A1917"
          />
          """
        end
      },
      %Example{
        title: "Month navigation",
        description:
          "on_prev and on_next put arrows beside the month label. The calendar " <>
            "reports the tap; the screen decides which month comes next.",
        code: ~S"""
        <MishkaCalendar
          weeks={weeks}
          weekday_labels={~w(M T W T F S S)}
          month_label={label}
          on_prev={:calendar_prev}
          on_next={:calendar_next}
          on_select={:calendar_pick}
        />

        def handle_info({:tap, :calendar_prev}, socket) do
          {:noreply, assign(socket, :month, previous_month(socket.assigns.month))}
        end
        """,
        render: fn assigns ->
          {year, month} = assigns.calendar_month
          weeks = weeks(year, month, assigns.calendar_today, assigns.calendar_selected, "cal-nav")
          label = "#{month_name(month)} #{year}"

          assigns = %{weeks: weeks, label: label}

          ~MOB"""
          <MishkaCalendar
            id="cal-nodes"
            weeks={@weeks}
            weekday_labels={~w(M T W T F S S)}
            month_label={@label}
            on_prev={:calendar_prev}
            on_next={:calendar_next}
            on_select={:calendar_pick}
            cell_color={:on_surface}
            outside_color={:muted}
            today_background={:on_surface}
            today_color={:background}
            selected_background={:surface_raised}
            selected_shadow="0 1 2 0 #0D1A1917"
          />
          """
        end
      },
      %Example{
        title: "Weekday headings of your own",
        description:
          "weekday_nodes wins over weekday_labels, so each letter can carry its " <>
            "own typeface — which is what a Persian, Arabic or Hebrew week needs.",
        code: ~S"""
        <MishkaCalendar weeks={weeks} weekday_nodes={heading_nodes}
                        on_select={:calendar_pick} />
        """,
        render: fn assigns ->
          nodes =
            ~w(M T W T F S S)
            |> Enum.map(fn letter ->
              assigns = %{letter: letter}

              ~MOB"""
              <Box weight={1.0} align={:center}>
                <Text text={@letter} text_size={11} font_weight={:bold} text_color={:muted} />
              </Box>
              """
            end)

          {year, month} = assigns.calendar_month

          weeks =
            weeks(year, month, assigns.calendar_today, assigns.calendar_selected, "cal-nodes")

          assigns = %{nodes: nodes, weeks: weeks}

          ~MOB"""
          <MishkaCalendar
            id="cal-nodes"
            weeks={@weeks}
            weekday_nodes={@nodes}
            on_select={:calendar_pick}
            cell_color={:on_surface}
            outside_color={:muted}
            today_background={:on_surface}
            today_color={:background}
          />
          """
        end
      },
      %Example{
        title: "The calendar can compute the month",
        description:
          "Give it any date in the month and it lays out the weeks itself: the " <>
            "first weekday is a parameter, six fixed rows keep the height stable, " <>
            "and the outside days are marked rather than dropped.",
        code: ~S"""
        <MishkaCalendar
          month={~D[2026-11-15]}
          today={~D[2026-11-11]}
          value={~D[2026-11-14]}
          weekday_labels={~w(M T W T F S S)}
          on_select={:calendar_pick}
        />
        """,
        render: fn assigns ->
          ~MOB"""
          <MishkaCalendar
            id="cal-computed"
            month={~D[2026-11-15]}
            today={~D[2026-11-11]}
            value={@calendar_selected}
            weekday_labels={~w(M T W T F S S)}
            on_select={:calendar_pick}
            cell_id_prefix="cal-c-"
            cell_color={:on_surface}
            outside_color={:muted}
            today_background={:on_surface}
            today_color={:background}
            selected_background={:surface_raised}
            selected_shadow="0 1 2 0 #0D1A1917"
          />
          """
        end
      },
      %Example{
        title: "Multiple and range selection",
        description:
          "mode: :multiple takes a list of dates. mode: :range takes a {from, to} " <>
            "pair and marks the days between as a state of their own, not a " <>
            "class the caller works out.",
        code: ~S"""
        <MishkaCalendar mode={:multiple} value={[~D[2026-11-03], ~D[2026-11-19]]} ... />
        <MishkaCalendar mode={:range} value={~D[2026-11-05]..~D[2026-11-09]} ... />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text text="Multiple" text_size={:sm} text_color={:muted} />
            <MishkaCalendar
              id="cal-multiple"
              month={~D[2026-11-15]}
              today={~D[2026-11-11]}
              mode={:multiple}
              value={[~D[2026-11-03], ~D[2026-11-19]]}
              weekday_labels={~w(M T W T F S S)}
              on_select={:calendar_pick}
              cell_id_prefix="cal-m-"
              cell_color={:on_surface}
              outside_color={:muted}
              selected_background={:surface_raised}
            />
            <Spacer size={12} />
            <Text text="Range" text_size={:sm} text_color={:muted} />
            <MishkaCalendar
              id="cal-range"
              month={~D[2026-11-15]}
              today={~D[2026-11-11]}
              mode={:range}
              value={{~D[2026-11-05], ~D[2026-11-09]}}
              weekday_labels={~w(M T W T F S S)}
              on_select={:calendar_pick}
              cell_id_prefix="cal-r-"
              cell_color={:on_surface}
              outside_color={:muted}
              selected_background={:surface_raised}
              in_range_background={:surface}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Bounds and disabled days",
        description:
          "min and max put the edges of the pickable month in one place, and " <>
            "disabled_dates names single days. A disabled day is inert, not " <>
            "merely grey.",
        code: ~S"""
        <MishkaCalendar
          month={~D[2026-11-15]}
          min={~D[2026-11-05]}
          max={~D[2026-11-25]}
          disabled_dates={[~D[2026-11-11]]}
          on_select={:calendar_pick}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <MishkaCalendar
            id="cal-bounds"
            month={~D[2026-11-15]}
            today={~D[2026-11-11]}
            min={~D[2026-11-05]}
            max={~D[2026-11-25]}
            disabled_dates={[~D[2026-11-11]]}
            weekday_labels={~w(M T W T F S S)}
            on_select={:calendar_pick}
            cell_id_prefix="cal-b-"
            cell_color={:on_surface}
            outside_color={:muted}
            disabled_color={:muted}
          />
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "weeks",
        type: "list of rows of cell maps",
        default: "[]",
        description: "The month, already laid out. A cell is %{label, value, state, markers, id}."
      },
      %{
        name: "month / today",
        type: "Date",
        default: "today",
        description:
          "When weeks is absent, the calendar lays the month out itself from any date in it."
      },
      %{
        name: "value / mode",
        type: "Date · list · range / mode",
        default: "nil / :single",
        description: "The selection, read according to the mode."
      },
      %{
        name: "min / max / disabled_dates",
        type: "Date / Date / list of dates",
        default: "nil / nil / []",
        description:
          "Bounds and single days that cannot be picked; they render disabled and inert."
      },
      %{
        name: "first_day_of_week / fixed_weeks / show_outside_days",
        type: "1..7 / boolean / boolean",
        default: "1 / true / true",
        description:
          "Which column the week starts in, whether six rows are always drawn, and " <>
            "whether the days either side of the month appear."
      },
      %{
        name: "weekday_labels / weekday_nodes",
        type: "7 strings / 7 nodes",
        default: "[]",
        description: "Column headings; nodes win, for per-letter type."
      },
      %{
        name: "on_select / on_prev / on_next",
        type: "event tag",
        default: "—",
        description: "A selected cell sends {tag, value}; the arrows send their tag."
      },
      %{
        name: "state",
        type: ":default · :today · :selected · …",
        default: ":default",
        description:
          "A cell's tone; :outside and :disabled complete the set. :disabled " <>
            "carries no tap handler."
      },
      %{
        name: "markers",
        type: "list of colors",
        default: "[]",
        description: "The dots under the number — one per section with something that day."
      },
      %{
        name: "cell_ratio / gap / row_gap / corner_radius",
        type: "number",
        default: "1.0 / 2 / 2 / 13",
        description: "The grid's geometry."
      },
      %{
        name: "colors",
        type: "tokens / ARGB",
        default: "neutral",
        description:
          "cell, today, selected and outside tones; weekday and label inks; " <>
            "month label and arrows."
      }
    ]
  end

  # ── The fixture month ───────────────────────────────────────────────────────

  defp weeks(year, month, today, selected, prefix) do
    first = Date.new!(year, month, 1)
    days = Date.days_in_month(first)
    lead = Date.day_of_week(first) - 1

    for row <- 0..5 do
      for col <- 0..6 do
        index = row * 7 + col + 1 - lead

        cond do
          index < 1 -> cell(Date.add(first, index - 1), :outside, today, selected, prefix)
          index > days -> cell(Date.add(first, index - 1), :outside, today, selected, prefix)
          true -> cell(Date.add(first, index - 1), :default, today, selected, prefix)
        end
      end
    end
  end

  defp cell(date, tone, today, selected, prefix) do
    state = state(date, tone, today, selected)
    markers = if rem(date.day, 7) in [0, 3], do: [:primary, :success], else: []
    markers = if state == :outside, do: [], else: Enum.take(markers, rem(date.day, 3))

    %{
      label: Integer.to_string(date.day),
      value: date,
      state: state,
      markers: markers,
      id: "#{prefix}-#{Date.to_iso8601(date)}"
    }
  end

  defp state(_date, :outside, _today, _selected), do: :outside
  defp state(date, _tone, date, _selected), do: :today
  defp state(date, _tone, _today, date), do: :selected
  defp state(_date, _tone, _today, _selected), do: :default

  defp month_name(1), do: "January"
  defp month_name(2), do: "February"
  defp month_name(3), do: "March"
  defp month_name(4), do: "April"
  defp month_name(5), do: "May"
  defp month_name(6), do: "June"
  defp month_name(7), do: "July"
  defp month_name(8), do: "August"
  defp month_name(9), do: "September"
  defp month_name(10), do: "October"
  defp month_name(11), do: "November"
  defp month_name(12), do: "December"
end
