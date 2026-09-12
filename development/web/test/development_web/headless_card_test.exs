defmodule DevelopmentWeb.HeadlessCardTest do
  @moduledoc """
  The headless card's structural contract.

  A card is layout, so what is worth pinning is the markup it commits to: a real heading wired to
  the root, a figure whose DOM position — not a class — decides which corners round, and an anchor
  root when the whole card is a link.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Card

  defp slot(name, content), do: [%{inner_block: fn _, _ -> content end, __slot__: name}]

  test "the title is a real heading at the requested level, wired to the root" do
    doc =
      doc(
        render_component(&Card.card/1, %{
          id: "c",
          title_level: "h2",
          title: slot(:title, "Shoes")
        })
      )

    assert tag(doc, "[data-part=title]") == "h2"
    assert attr(doc, "[data-part=title]", "id") == "c-title"
    assert attr(doc, "[data-part=root]", "aria-labelledby") == "c-title"
  end

  test "no title means nothing to point aria-labelledby at" do
    doc = doc(render_component(&Card.card/1, id: "c"))
    refute has_attr?(doc, "[data-part=root]", "aria-labelledby")
  end

  test "figure_position decides the DOM order the rounding rules key off" do
    order = fn position ->
      assigns = %{
        id: "c",
        figure_position: position,
        figure: slot(:figure, "img"),
        title: slot(:title, "T")
      }

      render_component(&Card.card/1, assigns)
      |> doc()
      |> parts("[data-part=root] > [data-part]")
    end

    assert order.("start") == ["figure", "body"]
    assert order.("end") == ["body", "figure"]
  end

  test "navigate renders an anchor LiveView will intercept" do
    doc = doc(render_component(&Card.card/1, id: "c", navigate: "/somewhere"))

    assert tag(doc, "[data-part=root]") == "a"
    assert attr(doc, "[data-part=root]", "href") == "/somewhere"
    assert attr(doc, "[data-part=root]", "data-phx-link") == "redirect"
  end

  test "patch marks itself as a patch, not a redirect" do
    doc = doc(render_component(&Card.card/1, id: "c", patch: "/here"))

    assert attr(doc, "[data-part=root]", "href") == "/here"
    assert attr(doc, "[data-part=root]", "data-phx-link") == "patch"
  end

  test "href is a plain link with no LiveView markers" do
    doc = doc(render_component(&Card.card/1, id: "c", href: "https://example.com"))

    assert tag(doc, "[data-part=root]") == "a"
    assert attr(doc, "[data-part=root]", "href") == "https://example.com"
    refute has_attr?(doc, "[data-part=root]", "data-phx-link")
  end

  test "without a link attribute it stays a div" do
    doc = doc(render_component(&Card.card/1, id: "c"))

    assert tag(doc, "[data-part=root]") == "div"
    refute has_attr?(doc, "[data-part=root]", "href")
  end

  test "the showcase renders a card whose whole root is the link", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/showcase/headless-daisyui/card")

    doc = LazyHTML.from_document(html)
    assert LazyHTML.query(doc, "a#daisyui-card-link[data-part=root]") |> LazyHTML.tag() == ["a"]
  end
end
