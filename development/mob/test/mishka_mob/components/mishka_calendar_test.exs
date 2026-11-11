defmodule MishkaMob.Components.MishkaCalendarTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCalendar

  defp cell(attrs) do
    Map.merge(%{label: "1", value: ~D[2026-11-01], state: :default, markers: []}, attrs)
  end

  defp week(day), do: for(n <- 1..7, do: cell(%{label: "#{n}", value: Date.add(day, n - 1)}))

  describe "the grid" do
    test "is a fill-width Column holding one Row per week" do
      node = MishkaCalendar.calendar(%{weeks: [week(~D[2026-11-02])]})

      assert node.type == :column
      assert node.props.fill_width == true

      [row] = node.children
      assert row.type == :column
      assert [%{type: :row, children: cells} | _] = row.children
      assert length(Enum.reject(cells, &match?(%{type: :spacer}, &1))) == 7
    end

    test "a nil cell stays an empty column" do
      node = MishkaCalendar.calendar(%{weeks: [[cell(%{}), nil]]})
      [_row] = node.children
      [row | _] = Enum.at(node.children, 0).children
      assert Enum.any?(row.children, &match?(%{type: :box, children: []}, &1))
    end

    test "on_select composes the cell value into the handler" do
      node = MishkaCalendar.calendar(%{weeks: [[cell(%{})]], on_select: :pick})

      tap = node |> find_cell() |> Map.get(:props) |> Map.get(:on_tap)

      assert tap == {self(), {:pick, ~D[2026-11-01]}}
    end

    test "a cell that carries its own tag sends exactly that tag" do
      node =
        MishkaCalendar.calendar(%{
          weeks: [[cell(%{tag: :day_2026_11_01})]],
          on_select: :pick
        })

      assert find_cell(node).props.on_tap == {self(), :day_2026_11_01}
    end

    test "a disabled cell carries no handler" do
      node = MishkaCalendar.calendar(%{weeks: [[cell(%{state: :disabled})]], on_select: :pick})

      refute Map.has_key?(find_cell(node).props, :on_tap)
    end
  end

  describe "tones" do
    test "today, selected and outside paint from their own props" do
      node =
        MishkaCalendar.calendar(%{
          weeks: [
            [
              cell(%{state: :today}),
              cell(%{state: :selected}),
              cell(%{state: :outside})
            ]
          ],
          today_background: 0xFF111111,
          today_color: 0xFF222222,
          selected_background: 0xFF333333,
          selected_color: 0xFF444444,
          outside_color: 0xFF555555
        })

      [today, selected, outside] = cells(node)

      assert today.props.background == 0xFF111111
      assert text_color(today) == 0xFF222222

      assert selected.props.background == 0xFF333333
      assert text_color(selected) == 0xFF444444

      assert text_color(outside) == 0xFF555555
    end
  end

  describe "markers" do
    test "one dot per colour, in the band under the number" do
      node = MishkaCalendar.calendar(%{weeks: [[cell(%{markers: [:primary, :success]})]]})

      dots =
        node
        |> find_cell()
        |> find_all(:box, [])
        |> Enum.filter(&(&1.props[:width] == 5 and &1.props[:height] == 5))

      assert length(dots) == 2
    end

    test "today recolours its dots when asked" do
      node =
        MishkaCalendar.calendar(%{
          weeks: [[cell(%{state: :today, markers: [:primary]})]],
          today_marker_color: 0xFFABCDEF
        })

      assert text_color(find_cell(node)) == :background
      assert Enum.any?(find_all(find_cell(node), :box), &(&1.props[:background] == 0xFFABCDEF))
    end
  end

  describe "weekday headings" do
    test "labels become seven equal columns" do
      node = MishkaCalendar.calendar(%{weekday_labels: ~w(M T W T F S S)})

      [%{type: :column, children: [row | _]} | _] = node.children
      assert [%{type: :row, children: headings} | _] = [row]
      assert length(Enum.reject(headings, &match?(%{type: :spacer}, &1))) == 7
    end

    test "nodes win over labels" do
      heading = %{type: :text, props: %{text: "X"}, children: []}
      node = MishkaCalendar.calendar(%{weekday_labels: ~w(M T), weekday_nodes: [heading]})

      assert text(node) =~ "X"
      refute text(node) =~ "M"
    end
  end

  describe "the header" do
    test "draws the month label and narrows the arrows" do
      node =
        MishkaCalendar.calendar(%{
          month_label: "November 2026",
          on_prev: :previous,
          on_next: :next
        })

      assert text(node) =~ "November 2026"
      handlers = for n <- flatten(node), {_, tag} <- [n.props[:on_tap]], do: tag
      assert :previous in handlers
      assert :next in handlers
    end

    test "is absent when there is nothing to say" do
      node = MishkaCalendar.calendar(%{})

      refute Enum.any?(flatten(node), &match?(%{props: %{on_tap: _}}, &1))
    end
  end

  test "expand/3 ignores children" do
    props = %{weekday_labels: ~w(M T W T F S S)}

    assert MishkaCalendar.expand(props, [cell(%{})], %{screen: self()}) ==
             MishkaCalendar.calendar(props)
  end

  defp find_cell(node) do
    node
    |> find_all(:box)
    |> Enum.find(&Map.has_key?(&1.props, :aspect_ratio))
  end

  defp cells(node) do
    node
    |> find_all(:box)
    |> Enum.filter(&Map.has_key?(&1.props, :aspect_ratio))
  end

  defp text_color(node) do
    node |> find_all(:text) |> hd() |> Map.get(:props) |> Map.get(:text_color)
  end
end

defmodule MishkaMob.Components.MishkaCalendarComputedTest do
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCalendar

  defp calendar(props), do: MishkaCalendar.calendar(Map.merge(%{cell_id_prefix: "d-"}, props))

  defp cell_by_id(node, id) do
    node
    |> find_all(:box)
    |> Enum.find(&(&1.props[:id] == id))
  end

  describe "weeks computed from a month" do
    test "six fixed rows starting on the configured weekday" do
      node = calendar(%{month: ~D[2026-11-15], today: ~D[2026-11-11]})

      rows = node.children |> Enum.filter(&match?(%{type: :column}, &1))
      assert length(rows) == 6

      # November 2026 starts on a Sunday, so a Monday-first grid leads with
      # 26 October.
      assert cell_by_id(node, "d-2026-10-26")
    end

    test "fixed_weeks: false draws only the rows the month needs" do
      # February 2027 starts on a Monday and has 28 days: exactly four rows.
      node = calendar(%{month: ~D[2027-02-10], fixed_weeks: false})

      rows = node.children |> Enum.filter(&match?(%{type: :column}, &1))
      assert length(rows) == 4
    end

    test "outside days are omitted, not merely muted" do
      node =
        calendar(%{
          month: ~D[2026-11-15],
          show_outside_days: false
        })

      refute cell_by_id(node, "d-2026-10-26")
      assert cell_by_id(node, "d-2026-11-01")
    end
  end

  describe "selection" do
    test "single marks one day" do
      node = calendar(%{month: ~D[2026-11-15], value: ~D[2026-11-14]})

      assert cell_by_id(node, "d-2026-11-14").props.background == :surface_raised
    end

    test "multiple marks each picked day" do
      node =
        calendar(%{
          month: ~D[2026-11-15],
          mode: :multiple,
          value: [~D[2026-11-03], ~D[2026-11-19]]
        })

      assert cell_by_id(node, "d-2026-11-03").props.background == :surface_raised
      assert cell_by_id(node, "d-2026-11-19").props.background == :surface_raised
      refute cell_by_id(node, "d-2026-11-04").props.background == :surface_raised
    end

    test "range marks the ends and everything between" do
      node =
        calendar(%{
          month: ~D[2026-11-15],
          mode: :range,
          value: {~D[2026-11-05], ~D[2026-11-09]},
          in_range_background: 0xFFABCDEF
        })

      assert cell_by_id(node, "d-2026-11-05").props.background == :surface_raised
      assert cell_by_id(node, "d-2026-11-09").props.background == :surface_raised
      assert cell_by_id(node, "d-2026-11-07").props.background == 0xFFABCDEF
      refute cell_by_id(node, "d-2026-11-10").props.background == 0xFFABCDEF
    end
  end

  describe "bounds" do
    test "a day before min or after max is disabled and carries no handler" do
      node =
        calendar(%{
          month: ~D[2026-11-15],
          min: ~D[2026-11-05],
          max: ~D[2026-11-25],
          on_select: :pick
        })

      assert cell_by_id(node, "d-2026-11-04").props.background == :transparent
      refute Map.has_key?(cell_by_id(node, "d-2026-11-04").props, :on_tap)
      assert Map.has_key?(cell_by_id(node, "d-2026-11-05").props, :on_tap)
    end

    test "disabled_dates disables exactly those days" do
      node =
        calendar(%{
          month: ~D[2026-11-15],
          disabled_dates: [~D[2026-11-11]],
          on_select: :pick
        })

      refute Map.has_key?(cell_by_id(node, "d-2026-11-11").props, :on_tap)
      assert Map.has_key?(cell_by_id(node, "d-2026-11-12").props, :on_tap)
    end
  end

  test "a computed cell reports its date through on_select" do
    node = calendar(%{month: ~D[2026-11-15], on_select: :pick})

    assert cell_by_id(node, "d-2026-11-20").props.on_tap ==
             {self(), {:pick, ~D[2026-11-20]}}
  end

  test "today is marked when nothing is selected" do
    node = calendar(%{month: ~D[2026-11-15], today: ~D[2026-11-11]})

    assert cell_by_id(node, "d-2026-11-11").props.background == :on_surface
  end
end
