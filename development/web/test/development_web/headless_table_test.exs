defmodule DevelopmentWeb.HeadlessTableTest do
  @moduledoc """
  The table's semantics: the parts a stylesheet cannot give you.

  daisyUI's table is a look. What is pinned here is what makes it a *table* to a screen reader —
  a caption, `scope` on the headers and on the row header — plus the two behaviours the component
  owns: which column claims `aria-sort`, and the tri-state of the select-all.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Table

  @rows [
    %{id: 1, name: "Cy", job: "QA"},
    %{id: 2, name: "Hart", job: "Support"},
    %{id: 3, name: "Brice", job: "Tax"}
  ]

  defp cols do
    [
      %{
        inner_block: fn _, row -> row.name end,
        __slot__: :col,
        label: "Name",
        key: "name",
        row_header: true
      },
      %{inner_block: fn _, row -> row.job end, __slot__: :col, label: "Job", key: "job"}
    ]
  end

  defp grid(assigns) do
    defaults = %{id: "t", rows: @rows, col: cols(), row_id: &"r-#{&1.id}"}
    doc(render_component(&Table.table/1, Map.merge(defaults, assigns)))
  end

  test "the caption names the table and is there whether or not it is shown" do
    hidden = grid(%{caption: "Crew"})

    assert LazyHTML.query(hidden, "[data-part=caption]") |> LazyHTML.text() |> String.trim() ==
             "Crew"

    assert has_attr?(hidden, "[data-part=caption]", "data-hidden")

    shown = grid(%{caption: "Crew", show_caption: true})
    refute has_attr?(shown, "[data-part=caption]", "data-hidden")
  end

  test "headers are column-scoped and the row header names its row" do
    doc = grid(%{})

    scopes = doc |> LazyHTML.query("[data-part=header]") |> LazyHTML.attribute("scope")
    assert scopes == ~w(col col)

    first_row = doc |> LazyHTML.query("tbody tr:first-child [data-part=cell]")
    assert LazyHTML.tag(first_row) == ~w(th td)
    assert LazyHTML.attribute(first_row, "scope") == ["row"]
  end

  test "a column is only sortable with both a key and somewhere to send the event" do
    no_event = grid(%{})
    assert LazyHTML.query(no_event, "[data-part=sort]") |> LazyHTML.to_tree() == []

    no_key =
      grid(%{
        on_sort: "sort",
        col: [%{inner_block: fn _, r -> r.name end, __slot__: :col, label: "Name"}]
      })

    assert LazyHTML.query(no_key, "[data-part=sort]") |> LazyHTML.to_tree() == []

    both = grid(%{on_sort: "sort"})
    assert length(LazyHTML.to_tree(LazyHTML.query(both, "[data-part=sort]"))) == 2
  end

  test "only the sorted column claims aria-sort" do
    doc = grid(%{on_sort: "sort", sort_by: "job", sort_dir: "desc"})

    sorts = doc |> LazyHTML.query("[data-part=header]") |> LazyHTML.attribute("aria-sort")
    assert sorts == ["descending"]
    assert has_attr?(doc, "[data-part=header][aria-sort]", "data-sortable")
  end

  test "the sorted column reverses; every other column starts ascending" do
    doc = grid(%{on_sort: "sort", sort_by: "name", sort_dir: "asc"})

    [name, job] = doc |> LazyHTML.query("[data-part=sort]") |> LazyHTML.attribute("phx-click")
    assert name =~ ~s("dir":"desc")
    assert job =~ ~s("dir":"asc")

    flipped = grid(%{on_sort: "sort", sort_by: "name", sort_dir: "desc"})
    [name, _] = flipped |> LazyHTML.query("[data-part=sort]") |> LazyHTML.attribute("phx-click")
    assert name =~ ~s("dir":"asc")
  end

  test "the arrow and aria-sort come from the same attribute, so they cannot disagree" do
    doc = grid(%{on_sort: "sort", sort_by: "name", sort_dir: "desc"})

    assert attr(doc, "[data-part=sort][data-dir]", "data-dir") == "desc"
    assert attr(doc, "[data-part=header][aria-sort]", "aria-sort") == "descending"
  end

  test "the selection column only exists when there is somewhere to send it" do
    plain = grid(%{})
    assert LazyHTML.query(plain, "[data-part=select]") |> LazyHTML.to_tree() == []

    doc = grid(%{on_select: "pick"})
    assert length(LazyHTML.to_tree(LazyHTML.query(doc, "[data-part=select]"))) == 3
    assert attr(doc, "[data-part=select]", "aria-label") == "Select row"
  end

  test "the select-all reports none, some and all distinctly" do
    none = grid(%{on_select: "pick", selected: []})
    refute has_attr?(none, "[data-part=select-all]", "checked")
    refute has_attr?(none, "[data-part=select-all]", "data-indeterminate")

    some = grid(%{on_select: "pick", selected: ["r-1"]})
    refute has_attr?(some, "[data-part=select-all]", "checked")
    assert has_attr?(some, "[data-part=select-all]", "data-indeterminate")

    all = grid(%{on_select: "pick", selected: ~w(r-1 r-2 r-3)})
    assert has_attr?(all, "[data-part=select-all]", "checked")
    refute has_attr?(all, "[data-part=select-all]", "data-indeterminate")
  end

  test "an empty table's select-all is not 'all selected'" do
    doc = grid(%{rows: [], on_select: "pick", selected: []})
    refute has_attr?(doc, "[data-part=select-all]", "checked")
  end

  test "the select-all carries the hook, since the middle state has no attribute" do
    doc = grid(%{on_select: "pick"})
    assert attr(doc, "[data-part=select-all]", "phx-hook") == "Indeterminate"
  end

  test "selected rows are marked, and each checkbox pushes its own id" do
    doc = grid(%{on_select: "pick", selected: ["r-2"]})

    marked = doc |> LazyHTML.query("[data-part=row][data-selected]") |> LazyHTML.attribute("id")
    assert marked == ["r-2"]

    clicks = doc |> LazyHTML.query("[data-part=select]") |> LazyHTML.attribute("phx-click")

    for {click, row} <- Enum.zip(clicks, @rows) do
      assert click =~ ~s("id":"r-#{row.id}")
    end
  end

  test "rows are keyed so LiveView can patch one of them" do
    doc = grid(%{})

    assert doc |> LazyHTML.query("tbody [data-part=row]") |> LazyHTML.attribute("id") ==
             ~w(r-1 r-2 r-3)
  end

  test "the empty slot replaces the body and spans every column, selection included" do
    doc = grid(%{rows: [], empty: [%{inner_block: fn _, _ -> "Nobody" end, __slot__: :empty}]})
    assert attr(doc, "[data-part=empty]", "colspan") == "2"

    assert LazyHTML.query(doc, "[data-part=empty]") |> LazyHTML.text() |> String.trim() ==
             "Nobody"

    with_select =
      grid(%{
        rows: [],
        on_select: "pick",
        empty: [%{inner_block: fn _, _ -> "-" end, __slot__: :empty}]
      })

    assert attr(with_select, "[data-part=empty]", "colspan") == "3"
  end

  test "the showcase's sortable table reports the column and direction", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/table")

    html =
      view
      |> element("#daisyui-table-sortable [data-part=sort]", "Job")
      |> render_click()

    assert html =~ "sort job asc"
  end
end
