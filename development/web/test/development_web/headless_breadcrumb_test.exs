defmodule DevelopmentWeb.HeadlessBreadcrumbTest do
  @moduledoc """
  The breadcrumb's semantics and its collapse arithmetic.

  The markup is the whole component here — a nav landmark, an ordered list, and a last crumb that
  is text rather than a link — so that is what these pin. The collapse is checked against derived
  trail lengths rather than one hand-written case, since the interesting behaviour is at the
  boundaries.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Breadcrumb

  defp crumbs(labels) do
    Enum.map(labels, fn label ->
      %{inner_block: fn _, _ -> label end, __slot__: :item, href: "/#{label}"}
    end)
  end

  defp trail(assigns), do: doc(render_component(&Breadcrumb.breadcrumb/1, assigns))

  # `LazyHTML.text/1` concatenates every match into one string, which would hide the boundary
  # between crumbs — enumerate the query so each crumb keeps its own label.
  defp labels(doc) do
    doc
    |> LazyHTML.query("[data-part=link], [data-part=ellipsis]")
    |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim()))
  end

  test "the trail is an ordered list inside a named landmark" do
    doc = trail(%{id: "b", item: crumbs(~w(Home Docs))})

    assert tag(doc, "[data-part=root]") == "nav"
    assert attr(doc, "[data-part=root]", "aria-label") == "Breadcrumb"
    assert tag(doc, "[data-part=list]") == "ol"
  end

  test "the last crumb is text with aria-current, not a link" do
    doc = trail(%{id: "b", item: crumbs(~w(Home Docs Add))})

    links = doc |> LazyHTML.query("[data-part=link]") |> LazyHTML.tag()
    assert links == ["a", "a", "span"]
    assert attr(doc, "[data-part=link][aria-current]", "aria-current") == "page"
  end

  test "a crumb can be marked current even when it is not last" do
    [home, docs] = crumbs(~w(Home Docs))
    doc = trail(%{id: "b", item: [Map.put(home, :current, true), docs]})

    tags = doc |> LazyHTML.query("[data-part=link]") |> LazyHTML.tag()
    assert tags == ["span", "span"]
  end

  test "separators sit between crumbs, never before the first, and are hidden from readers" do
    for n <- 1..5 do
      doc = trail(%{id: "b", item: crumbs(Enum.map(1..n, &"c#{&1}"))})
      seps = LazyHTML.query(doc, "[data-part=separator]")

      assert length(LazyHTML.to_tree(seps)) == n - 1,
             "#{n} crumbs should have #{n - 1} separators"
    end

    doc = trail(%{id: "b", item: crumbs(~w(a b))})
    assert attr(doc, "[data-part=separator]", "aria-hidden") == "true"
    assert has_attr?(doc, "[data-part=separator]", "data-default")
  end

  test "a custom separator drops the default marker the skin keys off" do
    doc =
      trail(%{
        id: "b",
        item: crumbs(~w(a b)),
        separator: [%{inner_block: fn _, _ -> "›" end, __slot__: :separator}]
      })

    refute has_attr?(doc, "[data-part=separator]", "data-default")
    assert LazyHTML.query(doc, "[data-part=separator]") |> LazyHTML.text() =~ "›"
  end

  test "a trail at or under max_items is left alone" do
    for n <- 1..4 do
      doc = trail(%{id: "b", max_items: 4, item: crumbs(Enum.map(1..n, &"c#{&1}"))})
      assert length(labels(doc)) == n
      refute has_attr?(doc, "[data-part=root]", "data-collapsed")
    end
  end

  test "a longer trail keeps `boundary` crumbs at each end around one ellipsis" do
    for boundary <- 1..2 do
      doc =
        trail(%{
          id: "b",
          max_items: 3,
          boundary: boundary,
          item: crumbs(~w(one two three four five six))
        })

      shown = labels(doc)
      assert length(shown) == boundary * 2 + 1
      assert Enum.at(shown, boundary) == "…"
      assert Enum.take(shown, boundary) == Enum.take(~w(one two three four five six), boundary)
      assert Enum.take(shown, -boundary) == Enum.take(~w(one two three four five six), -boundary)
      assert has_attr?(doc, "[data-part=root]", "data-collapsed")
    end
  end

  test "the ellipsis is inert markup until on_expand makes it a button" do
    base = %{id: "b", max_items: 3, item: crumbs(~w(a b c d e))}

    assert tag(trail(base), "[data-part=ellipsis]") == "span"

    doc = trail(Map.put(base, :on_expand, "expand"))
    assert tag(doc, "[data-part=ellipsis]") == "button"
    assert attr(doc, "[data-part=ellipsis]", "aria-label") == "Show all"
    assert attr(doc, "[data-part=ellipsis]", "phx-click") =~ "expand"
  end

  test "the showcase's expandable trail pushes when the ellipsis is clicked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/breadcrumb")

    html =
      view
      |> element("#daisyui-breadcrumb-expandable [data-part=ellipsis]")
      |> render_click()

    assert html =~ "expand the trail"
  end
end
