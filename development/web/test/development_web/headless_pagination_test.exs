defmodule DevelopmentWeb.HeadlessPaginationTest do
  @moduledoc """
  The pagination window and the element each control becomes.

  `window/4` is the component's actual logic, so it is tested as arithmetic — swept across whole
  ranges rather than pinned to a handful of hand-written cases — and the rendering tests then check
  that the markup follows it.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Pagination

  defp control(assigns) do
    doc(render_component(&Pagination.pagination/1, Map.merge(%{id: "p", total: 10}, assigns)))
  end

  defp shown(doc) do
    doc
    |> LazyHTML.query("[data-part=page], [data-part=ellipsis]")
    |> Enum.map(fn node ->
      case LazyHTML.attribute(node, "data-page") do
        [page] -> String.to_integer(page)
        [] -> :ellipsis
      end
    end)
  end

  describe "window/4" do
    test "a range that fits is shown whole, with no ellipsis" do
      for total <- 1..7 do
        assert Pagination.window(total, 1, 1, 1) == Enum.to_list(1..total)
      end
    end

    test "the count is the same wherever you are in the range" do
      # A control that narrows at the ends shifts its buttons under the cursor.
      counts = for page <- 1..100, do: length(Pagination.window(100, page, 1, 1))
      assert Enum.uniq(counts) == [7]
    end

    test "the current page is always in the window" do
      for page <- 1..100 do
        assert page in Pagination.window(100, page, 1, 1),
               "page #{page} fell out of its own window"
      end
    end

    test "the boundaries are always pinned" do
      for page <- 1..100 do
        w = Pagination.window(100, page, 1, 2)
        assert Enum.take(w, 2) == [1, 2]
        assert Enum.take(w, -2) == [99, 100]
      end
    end

    test "siblings widen the run around the current page" do
      for siblings <- 0..3 do
        w = Pagination.window(100, 50, siblings, 1)
        run = w |> Enum.filter(&is_integer/1) |> Enum.filter(&(&1 > 1 and &1 < 100))
        assert length(run) == siblings * 2 + 1, "siblings=#{siblings}"
        assert 50 in run
      end
    end

    test "pages are strictly ascending and never repeat" do
      for total <- [8, 20, 100], page <- [1, 2, div(total, 2), total - 1, total] do
        pages = Pagination.window(total, page, 1, 1) |> Enum.filter(&is_integer/1)
        assert pages == Enum.sort(pages)
        assert pages == Enum.uniq(pages)
        assert Enum.all?(pages, &(&1 >= 1 and &1 <= total))
      end
    end

    test "an out-of-range page is clamped rather than producing a broken window" do
      assert Pagination.window(10, 0, 1, 1) == Pagination.window(10, 1, 1, 1)
      assert Pagination.window(10, 99, 1, 1) == Pagination.window(10, 10, 1, 1)
    end
  end

  describe "rendering" do
    test "the root is a named landmark carrying its position in the range" do
      doc = control(%{page: 3})

      assert tag(doc, "[data-part=root]") == "nav"
      assert attr(doc, "[data-part=root]", "aria-label") == "Pagination"
      assert attr(doc, "[data-part=root]", "data-total") == "10"
      assert attr(doc, "[data-part=root]", "data-page") == "3"
    end

    test "the markup follows the computed window" do
      for page <- [1, 5, 10] do
        assert shown(control(%{page: page, total: 10})) == Pagination.window(10, page, 1, 1)
      end
    end

    test "the current page is a disabled button, not a link to where you already are" do
      doc = control(%{page: 3, href: &"/p/#{&1}"})

      assert tag(doc, "[data-part=page][aria-current]") == "button"
      assert has_attr?(doc, "[data-part=page][aria-current]", "disabled")
      assert attr(doc, "[data-part=page][aria-current]", "data-page") == "3"

      others = doc |> LazyHTML.query("[data-part=page]:not([aria-current])") |> LazyHTML.tag()
      assert Enum.uniq(others) == ["a"]
    end

    test "previous and next disable themselves at the ends instead of wrapping" do
      first = control(%{page: 1})
      assert has_attr?(first, "[data-part=previous]", "disabled")
      refute has_attr?(first, "[data-part=next]", "disabled")

      last = control(%{page: 10})
      refute has_attr?(last, "[data-part=previous]", "disabled")
      assert has_attr?(last, "[data-part=next]", "disabled")
    end

    test "edge controls are opt-in and jump to the ends" do
      refute has_attr?(control(%{page: 5}), "[data-part=first]", "data-part")

      doc = control(%{page: 5, show_edges: true, on_select: "go"})
      assert attr(doc, "[data-part=first]", "phx-click") =~ ~s("page":1)
      assert attr(doc, "[data-part=last]", "phx-click") =~ ~s("page":10)
    end

    test "each page pushes its own number" do
      doc = control(%{page: 1, total: 5, on_select: "go"})

      for node <- LazyHTML.query(doc, "[data-part=page]:not([aria-current])") do
        [page] = LazyHTML.attribute(node, "data-page")
        assert LazyHTML.attribute(node, "phx-click") |> List.first() =~ ~s("page":#{page})
      end
    end

    test "name renders radios so the choice posts with a form" do
      doc = control(%{page: 2, total: 4, name: "page"})

      pages = LazyHTML.query(doc, "[data-part=page]")
      assert Enum.uniq(LazyHTML.tag(pages)) == ["input"]
      assert LazyHTML.attribute(pages, "value") == ~w(1 2 3 4)
      assert LazyHTML.attribute(pages, "name") |> Enum.uniq() == ["page"]
      assert attr(doc, "[data-part=page][checked]", "value") == "2"
      # The accessible name says what it is; the skin draws the bare number from data-page.
      assert attr(doc, "[data-part=page]", "aria-label") == "Page 1"
    end

    test "disabled greys every control, including the pages" do
      doc = control(%{page: 5, disabled: true, on_select: "go"})

      controls = LazyHTML.query(doc, "[data-part=page], [data-part=previous], [data-part=next]")
      assert Enum.all?(controls, &(LazyHTML.attribute(&1, "disabled") != []))
      assert Enum.all?(controls, &(LazyHTML.attribute(&1, "phx-click") == []))
    end

    test "the ellipsis is hidden from screen readers" do
      doc = control(%{page: 50, total: 100})
      assert attr(doc, "[data-part=ellipsis]", "aria-hidden") == "true"
    end
  end

  test "the showcase's live pagination reports the page it was sent", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/pagination")

    html =
      view
      |> element("#daisyui-pagination-interactive [data-part=next]")
      |> render_click()

    assert html =~ "page 5"
  end
end
