defmodule DevelopmentWeb.HeadlessCalendarTest do
  @moduledoc """
  The calendar's grid arithmetic and its selection states.

  `weeks/3` is the component: everything the markup does follows from it, so it is tested as
  arithmetic over whole years rather than against a handful of hand-picked months — the interesting
  cases are leap years, months that start on the last column, and Februaries that fit exactly.

  Focus movement belongs to the hook and is verified in a browser.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Calendar

  defp month(assigns) do
    defaults = %{id: "cal", month: ~D[2026-03-01], today: ~D[2026-03-17]}
    doc(render_component(&Calendar.calendar/1, Map.merge(defaults, assigns)))
  end

  defp dates(doc, selector),
    do: doc |> LazyHTML.query(selector) |> LazyHTML.attribute("data-date")

  defp every_month(from, to) do
    Date.range(from, to, 32) |> Enum.map(&Date.beginning_of_month/1)
  end

  describe "weeks/3" do
    test "every row is exactly seven days, whatever the month" do
      for first <- every_month(~D[2024-01-01], ~D[2027-12-01]), start <- 1..7 do
        for week <- Calendar.weeks(first, start) do
          assert length(week) == 7, "#{first} starting #{start}"
        end
      end
    end

    test "the grid is contiguous — no gaps and no repeats across a row boundary" do
      for first <- every_month(~D[2024-01-01], ~D[2026-12-01]) do
        days = Calendar.weeks(first, 1) |> List.flatten()

        days
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.each(fn [a, b] -> assert Date.diff(b, a) == 1, "#{a} → #{b}" end)
      end
    end

    test "the first column always holds the same weekday, and it is the one asked for" do
      for first <- every_month(~D[2025-01-01], ~D[2026-12-01]), start <- 1..7 do
        Calendar.weeks(first, start)
        |> Enum.each(fn [head | _] ->
          assert Date.day_of_week(head) == start, "#{first} starting #{start}"
        end)
      end
    end

    test "every day of the month is present exactly once" do
      for first <- every_month(~D[2024-01-01], ~D[2026-12-01]) do
        days = Calendar.weeks(first, 1) |> List.flatten()
        in_month = Enum.filter(days, &(&1.month == first.month and &1.year == first.year))

        assert length(in_month) == Date.days_in_month(first), "#{first}"
      end
    end

    test "fixed weeks is always six rows; otherwise it is only as many as the month needs" do
      for first <- every_month(~D[2024-01-01], ~D[2027-12-01]) do
        assert length(Calendar.weeks(first, 1, true)) == 6
        assert length(Calendar.weeks(first, 1, false)) in 4..6
      end

      # February 2027 starts on a Monday and has 28 days: four rows, exactly.
      assert length(Calendar.weeks(~D[2027-02-01], 1, false)) == 4
      # A 31-day month starting on a Sunday needs all six.
      assert length(Calendar.weeks(~D[2026-03-01], 1, false)) == 6
    end

    test "a leap February is a day longer than the year before" do
      leap = Calendar.weeks(~D[2024-02-01], 1) |> List.flatten() |> Enum.filter(&(&1.month == 2))
      plain = Calendar.weeks(~D[2025-02-01], 1) |> List.flatten() |> Enum.filter(&(&1.month == 2))

      assert length(leap) == 29
      assert length(plain) == 28
    end
  end

  describe "rendering" do
    test "the grid is a table that names itself by the month on show" do
      doc = month(%{})

      assert tag(doc, "[data-part=grid]") == "table"
      assert attr(doc, "[data-part=grid]", "role") == "grid"
      assert attr(doc, "[data-part=grid]", "aria-labelledby") == "cal-heading"

      assert LazyHTML.query(doc, "[data-part=heading]") |> LazyHTML.text() |> String.trim() ==
               "March 2026"
    end

    test "today is marked as the current date, and only today" do
      doc = month(%{})

      assert dates(doc, "[data-part=day][aria-current=date]") == ["2026-03-17"]
      assert dates(doc, "[data-part=day][data-today]") == ["2026-03-17"]
    end

    test "a day says where it is, not just its number" do
      doc = month(%{})
      assert attr(doc, ~s|[data-date="2026-03-17"]|, "aria-label") == "Tuesday, 17 March 2026"
    end

    test "the calendar is one tab stop, landing on the selection or on today" do
      today = month(%{})

      assert today
             |> LazyHTML.query(~s|[data-part=day][tabindex="0"]|)
             |> LazyHTML.attribute("data-date") == ["2026-03-17"]

      selected = month(%{value: ~D[2026-03-05]})

      assert selected
             |> LazyHTML.query(~s|[data-part=day][tabindex="0"]|)
             |> LazyHTML.attribute("data-date") == ["2026-03-05"]
    end

    test "days from the neighbouring months are shown but marked" do
      doc = month(%{})
      outside = dates(doc, "[data-part=day][data-outside]")

      assert "2026-02-23" in outside
      assert "2026-04-05" in outside
      refute "2026-03-01" in outside
    end

    test "outside days can be dropped entirely" do
      doc = month(%{show_outside_days: false})

      assert dates(doc, "[data-part=day][data-outside]") == []
      assert length(dates(doc, "[data-part=day]")) == 31
    end

    test "single, multiple and range each mark what they select" do
      single = month(%{value: ~D[2026-03-12]})
      assert dates(single, "[data-part=day][data-selected]") == ["2026-03-12"]

      multiple = month(%{mode: "multiple", value: [~D[2026-03-03], ~D[2026-03-11]]})
      assert dates(multiple, "[data-part=day][data-selected]") == ["2026-03-03", "2026-03-11"]

      range = month(%{mode: "range", value: {~D[2026-03-09], ~D[2026-03-18]}})
      assert dates(range, "[data-part=day][data-range-start]") == ["2026-03-09"]
      assert dates(range, "[data-part=day][data-range-end]") == ["2026-03-18"]
      # Strictly between, so the ends stay legible as ends.
      assert dates(range, "[data-part=day][data-in-range]") ==
               Enum.map(10..17, &"2026-03-#{&1}")
    end

    test "a half-picked range marks its start and nothing else" do
      doc = month(%{mode: "range", value: {~D[2026-03-09], nil}})

      assert dates(doc, "[data-part=day][data-selected]") == ["2026-03-09"]
      assert dates(doc, "[data-part=day][data-in-range]") == []
    end

    test "min and max rule out the days beyond them" do
      doc = month(%{min: ~D[2026-03-05], max: ~D[2026-03-25]})
      allowed = dates(doc, ~s|[data-part=day]:not([aria-disabled="true"])|)

      assert List.first(allowed) == "2026-03-05"
      assert List.last(allowed) == "2026-03-25"
    end

    test "the paging control stops rather than moving to a month with nothing in it" do
      doc = month(%{min: ~D[2026-03-01], max: ~D[2026-03-31]})

      assert has_attr?(doc, "[data-part=previous]", "disabled")
      assert has_attr?(doc, "[data-part=next]", "disabled")

      open = month(%{})
      refute has_attr?(open, "[data-part=previous]", "disabled")
      refute has_attr?(open, "[data-part=next]", "disabled")
    end

    test "a blocked day cannot be picked, and says so" do
      doc = month(%{disabled_dates: [~D[2026-03-14]], on_select: "pick"})

      assert attr(doc, ~s|[data-date="2026-03-14"]|, "aria-disabled") == "true"
      refute has_attr?(doc, ~s|[data-date="2026-03-14"]|, "phx-click")
      assert has_attr?(doc, ~s|[data-date="2026-03-13"]|, "phx-click")
    end

    test "the week starts where it is told, headers and columns together" do
      monday = month(%{})

      assert monday
             |> LazyHTML.query("[data-part=weekday]")
             |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim())) ==
               ~w(Mo Tu We Th Fr Sa Su)

      sunday = month(%{first_day_of_week: 7})

      assert sunday
             |> LazyHTML.query("[data-part=weekday]")
             |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim())) ==
               ~w(Su Mo Tu We Th Fr Sa)

      # The column and its header have to agree, or the whole grid is off by a day. 1 March 2026 is
      # a Sunday, so a Sunday-start grid begins exactly there while a Monday-start one backs up to
      # 23 February.
      assert sunday |> dates("[data-part=week]:first-child [data-part=day]") |> List.first() ==
               "2026-03-01"

      assert monday |> dates("[data-part=week]:first-child [data-part=day]") |> List.first() ==
               "2026-02-23"
    end

    test "each day pushes its own date" do
      doc = month(%{on_select: "pick"})
      clicks = doc |> LazyHTML.query("[data-part=day]") |> LazyHTML.attribute("phx-click")
      days = dates(doc, "[data-part=day]")

      for {click, date} <- Enum.zip(clicks, days) do
        assert click =~ ~s("date":"#{date}")
      end
    end

    test "paging asks for the neighbouring month, not an arbitrary date" do
      doc = month(%{on_month_change: "page"})

      assert attr(doc, "[data-part=previous]", "phx-click") =~ ~s("month":"2026-02-01")
      assert attr(doc, "[data-part=next]", "phx-click") =~ ~s("month":"2026-04-01")
    end

    test "paging from a 31-day month does not skip one" do
      # Adding a month naively to 31 January lands in March.
      doc = month(%{month: ~D[2026-01-31], on_month_change: "page"})
      assert attr(doc, "[data-part=next]", "phx-click") =~ ~s("month":"2026-02-01")
    end
  end

  test "the showcase's live calendar reports the day it was given", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/calendar")

    html =
      view
      |> element(~s|#daisyui-calendar-live [data-date="2026-03-12"]|)
      |> render_click()

    assert html =~ "picked 2026-03-12"
  end
end
