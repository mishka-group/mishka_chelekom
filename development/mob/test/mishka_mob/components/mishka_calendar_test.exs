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

defmodule MishkaMob.Components.MishkaCalendarViewsTest do
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCalendar

  describe "the week view" do
    test "draws seven equal lanes with their headings and blocks" do
      lanes =
        for n <- 1..7 do
          %{
            weekday: "W#{n}",
            day: "#{n}",
            tag: String.to_atom("lane_#{n}"),
            blocks: [%{label: "09", height: 44, tag: String.to_atom("block_#{n}")}]
          }
        end

      node = MishkaCalendar.calendar(%{view: :week, lanes: lanes})

      [row] = node.children
      lane_nodes = Enum.reject(row.children, &match?(%{type: :spacer}, &1))
      assert length(lane_nodes) == 7
      assert Enum.all?(lane_nodes, &(&1.props.weight == 1.0))

      first = hd(lane_nodes)
      assert first.props.on_tap == {self(), :lane_1}
      assert text(first) =~ "W1"
      assert text(first) =~ "1"
      assert find(first, :box, width: 2.5) != nil
    end

    test "the selected lane paints its heading card" do
      node =
        MishkaCalendar.calendar(%{
          view: :week,
          lanes: [%{weekday: "MON", day: "9", state: :selected, tag: :lane}],
          lane_selected_background: 0xFFABCDEF,
          lane_selected_shadow: "0 1 2 0 #0D1A1917"
        })

      [row] = node.children
      [lane] = row.children
      [header | _] = lane.children
      assert header.props.background == 0xFFABCDEF
      assert header.props.shadow != nil
    end

    test "today's number takes the today colour" do
      node =
        MishkaCalendar.calendar(%{
          view: :week,
          lanes: [%{weekday: "MON", day: "9", state: :today}],
          today_color: 0xFF123456
        })

      assert Enum.any?(find_all(node, :text), &(&1.props.text_color == 0xFF123456))
    end
  end

  describe "the day view" do
    test "draws the rows in order, with their time, title and duration" do
      rows = [
        %{time: "09:00", title: "First", meta: "Calendar", duration: "1h", tag: :row_1},
        %{time: "13:00", title: "Second", duration: "2h", tag: :row_2}
      ]

      node = MishkaCalendar.calendar(%{view: :day, rows: rows})

      texts = node |> find_all(:text) |> Enum.map(& &1.props.text)
      assert texts == ["09:00", "First", "Calendar", "1h", "13:00", "Second", "2h"]

      assert Enum.any?(flatten(node), &(&1.props[:on_tap] == {self(), :row_1}))
      assert Enum.any?(flatten(node), &(&1.props[:on_tap] == {self(), :row_2}))
    end

    test "a rule sits between rows, not after the last" do
      node =
        MishkaCalendar.calendar(%{
          view: :day,
          rows: [%{time: "a", title: "A"}, %{time: "b", title: "B"}],
          rule_color: 0xFF111111
        })

      rules =
        Enum.filter(
          flatten(node),
          &(&1.props[:height] == 1 and &1.props[:background] == 0xFF111111)
        )

      assert length(rules) == 1
    end

    test "an empty day draws the empty node" do
      empty = %{type: :text, props: %{text: "Nothing"}, children: []}

      node = MishkaCalendar.calendar(%{view: :day, rows: [], empty: empty})

      assert node == empty
    end
  end

  describe "the day cluster timeline" do
    test "lays out each cluster's clash, gutter and lanes with the given margins" do
      cluster = %{
        clash: %{type: :text, props: %{text: "2 at once"}, children: []},
        gutter: %{type: :text, props: %{text: "09:00"}, children: []},
        lanes: %{type: :text, props: %{text: "LANE"}, children: []}
      }

      node =
        MishkaCalendar.calendar(%{
          view: :day,
          clusters: [cluster],
          cluster_gap: 14,
          cluster_padding_left: 21,
          cluster_padding_right: 21
        })

      [column] = node.children
      assert column.props.padding_left == 21
      assert column.props.padding_right == 21
      assert text(node) =~ "2 at once"
      assert text(node) =~ "09:00"
      assert text(node) =~ "LANE"
      assert Enum.any?(column.children, &match?(%{type: :spacer, props: %{size: 14}}, &1))
    end
  end

  describe "the agenda view" do
    test "draws each section's label and one card of its rows" do
      sections = [
        %{label: "TODAY", items: [%{time: "09:00", title: "Stand-up"}]},
        %{label: "TOMORROW", items: [%{time: "10:00", title: "Dentist"}]}
      ]

      node = MishkaCalendar.calendar(%{view: :agenda, sections: sections})

      texts = node |> find_all(:text) |> Enum.map(& &1.props.text)
      assert "TODAY" in texts
      assert "TOMORROW" in texts
      assert "Stand-up" in texts
      assert "Dentist" in texts
      assert length(find_all(node, :text)) == 6
    end

    test "a section header node replaces the built label" do
      header = %{type: :text, props: %{text: "OWN HEADER"}, children: []}
      node = MishkaCalendar.calendar(%{view: :agenda, sections: [%{header: header, items: []}]})

      assert text(node) =~ "OWN HEADER"
    end

    test "a row's leading node sits between its rail and its body" do
      leading = %{type: :text, props: %{text: "POSTER"}, children: []}
      rows = [%{time: "09:00", title: "Row", leading: leading}]
      node = MishkaCalendar.calendar(%{view: :day, rows: rows})

      assert text(node) =~ "POSTER"
      assert text(node) =~ "Row"
    end

    test "an empty agenda draws the empty node" do
      empty = %{type: :text, props: %{text: "Nothing"}, children: []}

      assert MishkaCalendar.calendar(%{view: :agenda, sections: [], empty: empty}) == empty
    end
  end
end
