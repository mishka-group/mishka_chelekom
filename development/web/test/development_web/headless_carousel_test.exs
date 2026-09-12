defmodule DevelopmentWeb.HeadlessCarouselTest do
  @moduledoc """
  The carousel's server-rendered shape and its APG semantics.

  The scrolling is native and the current-slide tracking belongs to the hook — both verified in a
  browser. What is pinned here is the markup that makes a scrolling strip describable: the
  roledescriptions, the "N of M" labels, and controls that start out disabled at the ends rather
  than waiting for JavaScript to disable them.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Carousel

  defp slides(count) do
    Enum.map(1..count, fn n -> %{inner_block: fn _, _ -> "slide #{n}" end, __slot__: :slide} end)
  end

  defp strip(assigns) do
    defaults = %{id: "c", label: "Photos", slide: slides(4)}
    doc(render_component(&Carousel.carousel/1, Map.merge(defaults, assigns)))
  end

  test "the root describes itself as a carousel, by name" do
    doc = strip(%{})

    assert attr(doc, "[data-part=root]", "role") == "region"
    assert attr(doc, "[data-part=root]", "aria-roledescription") == "carousel"
    assert attr(doc, "[data-part=root]", "aria-label") == "Photos"
    assert attr(doc, "[data-part=root]", "phx-hook") == "HeadlessCarousel"
  end

  test "each slide is a labelled group, numbered out of the total" do
    doc = strip(%{slide: slides(3)})

    groups = LazyHTML.query(doc, "[data-part=slide]")
    assert LazyHTML.attribute(groups, "role") |> Enum.uniq() == ["group"]
    assert LazyHTML.attribute(groups, "aria-roledescription") |> Enum.uniq() == ["slide"]
    assert LazyHTML.attribute(groups, "aria-label") == ["1 of 3", "2 of 3", "3 of 3"]
  end

  test "a slide can name itself instead of being counted" do
    doc =
      strip(%{
        slide: [%{inner_block: fn _, _ -> "x" end, __slot__: :slide, label: "The kitchen"}]
      })

    assert attr(doc, "[data-part=slide]", "aria-label") == "The kitchen"
  end

  test "the starting slide is current, and the others are hidden from the reader" do
    doc = strip(%{index: 2})

    assert attr(doc, "[data-part=slide][data-current]", "data-index") == "2"

    # `LazyHTML.attribute/2` omits the elements that lack it, so count instead: every slide but the
    # current one is hidden.
    hidden =
      doc
      |> LazyHTML.query(~s|[data-part=slide][aria-hidden="true"]|)
      |> LazyHTML.attribute("data-index")

    assert hidden == ~w(0 1 3)
  end

  test "the viewport is focusable, so the arrow keys have somewhere to land" do
    assert attr(strip(%{}), "[data-part=viewport]", "tabindex") == "0"
  end

  test "controls and indicators are both opt-in" do
    plain = strip(%{})
    assert LazyHTML.query(plain, "[data-part=next]") |> LazyHTML.to_tree() == []
    assert LazyHTML.query(plain, "[data-part=indicator]") |> LazyHTML.to_tree() == []

    doc = strip(%{show_controls: true, show_indicators: true})
    assert attr(doc, "[data-part=previous]", "aria-label") == "Previous slide"
    assert attr(doc, "[data-part=next]", "aria-controls") == "c"
    assert length(LazyHTML.to_tree(LazyHTML.query(doc, "[data-part=indicator]"))) == 4
  end

  test "one indicator per slide, and only the current one is marked" do
    doc = strip(%{show_indicators: true, index: 1})

    indicators = LazyHTML.query(doc, "[data-part=indicator]")
    assert LazyHTML.attribute(indicators, "data-index") == ~w(0 1 2 3)
    assert LazyHTML.attribute(indicators, "aria-label") |> List.first() == "Go to slide 1"
    assert attr(doc, "[data-part=indicator][aria-current]", "data-index") == "1"
  end

  test "the controls start out disabled at the ends, before any JavaScript runs" do
    first = strip(%{show_controls: true, index: 0})
    assert has_attr?(first, "[data-part=previous]", "disabled")
    refute has_attr?(first, "[data-part=next]", "disabled")

    last = strip(%{show_controls: true, index: 3})
    refute has_attr?(last, "[data-part=previous]", "disabled")
    assert has_attr?(last, "[data-part=next]", "disabled")
  end

  test "a looping carousel never disables its controls" do
    doc = strip(%{show_controls: true, index: 0, loop: true})

    refute has_attr?(doc, "[data-part=previous]", "disabled")
    refute has_attr?(doc, "[data-part=next]", "disabled")
    assert has_attr?(doc, "[data-part=root]", "data-loop")
  end

  test "snap and orientation ride on the root for the skin to read" do
    for snap <- ~w(start center end none) do
      assert attr(strip(%{snap: snap}), "[data-part=root]", "data-snap") == snap
    end

    assert attr(strip(%{orientation: "vertical"}), "[data-part=root]", "data-orientation") ==
             "vertical"
  end

  test "autoplay is announced to the hook and silences the live region" do
    quiet = strip(%{})
    refute has_attr?(quiet, "[data-part=root]", "data-autoplay")

    doc = strip(%{autoplay: 2500})
    assert attr(doc, "[data-part=root]", "data-autoplay") == "2500"
    # An auto-advancing region must not narrate itself.
    assert attr(doc, "[data-part=viewport]", "aria-live") == "off"
  end

  test "the showcase renders every carousel with slides and a label", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/showcase/headless-daisyui/carousel")

    doc = LazyHTML.from_document(html)
    roots = LazyHTML.query(doc, "[data-part=root].chelekom-carousel")

    assert length(LazyHTML.to_tree(roots)) >= 10
    assert Enum.all?(roots, &(LazyHTML.attribute(&1, "aria-label") != [""]))
    assert length(LazyHTML.to_tree(LazyHTML.query(doc, "[data-part=slide]"))) > 30
  end
end
