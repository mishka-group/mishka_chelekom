defmodule DevelopmentWeb.HeadlessRatingTest do
  @moduledoc """
  The rating's radio-group shape and its half-star arithmetic.

  A rating is a single choice from an ordered set, so the things worth pinning are the radio
  contract the shared `RadioGroup` hook depends on — one tab stop, exactly one checked item, a
  hidden input carrying the value — and the fact that `precision` produces real half values rather
  than an index the server has to interpret.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Rating

  defp stars(assigns) do
    doc(render_component(&Rating.rating/1, Map.merge(%{id: "r"}, assigns)))
  end

  defp values(doc),
    do: doc |> LazyHTML.query("[data-part=item]") |> LazyHTML.attribute("data-value")

  defp checked(doc) do
    doc
    |> LazyHTML.query(~s|[data-part=item][aria-checked="true"]|)
    |> LazyHTML.attribute("data-value")
  end

  test "the root is a radio group wired to the shared engine" do
    doc = stars(%{value: 3, label: "Your score"})

    assert attr(doc, "[data-part=root]", "role") == "radiogroup"
    assert attr(doc, "[data-part=root]", "aria-label") == "Your score"
    assert attr(doc, "[data-part=root]", "phx-hook") == "RadioGroup"
    # The hook navigates left/right, not up/down.
    assert attr(doc, "[data-part=root]", "data-orientation") == "horizontal"
  end

  test "whole precision gives one control per star" do
    for count <- 1..7 do
      doc = stars(%{count: count, value: 1})
      assert values(doc) == Enum.map(1..count, &"#{&1}.0")
    end
  end

  test "half precision gives two controls per star, and real halves as values" do
    for count <- 1..5 do
      doc = stars(%{count: count, precision: 0.5, value: 1})
      expected = Enum.map(1..(count * 2), &to_string(&1 / 2))
      assert values(doc) == expected, "count=#{count}"
      assert length(values(doc)) == count * 2
    end
  end

  test "each half is marked with the side of the star it covers" do
    doc = stars(%{count: 3, precision: 0.5})
    sides = doc |> LazyHTML.query("[data-part=item]") |> LazyHTML.attribute("data-half")
    assert sides == ~w(first second first second first second)
  end

  test "whole precision marks no halves at all" do
    doc = stars(%{count: 3})
    assert doc |> LazyHTML.query("[data-part=item][data-half]") |> LazyHTML.to_tree() == []
  end

  test "exactly one item is checked, and it is the one holding the value" do
    for {value, precision} <- [{3, 1.0}, {2.5, 0.5}, {5, 1.0}, {0.5, 0.5}] do
      doc = stars(%{value: value, precision: precision})
      assert checked(doc) == [to_string(value / 1)], "value=#{value}"
    end
  end

  test "a value that matches nothing leaves the control unchecked rather than guessing" do
    doc = stars(%{value: 2.5, precision: 1.0})
    assert checked(doc) == []
  end

  test "the group is one tab stop, landing on the checked star" do
    doc = stars(%{value: 3})
    tabindexes = doc |> LazyHTML.query("[data-part=item]") |> LazyHTML.attribute("tabindex")

    assert Enum.count(tabindexes, &(&1 == "0")) == 1
    assert attr(doc, ~s|[data-part=item][aria-checked="true"]|, "tabindex") == "0"
  end

  test "with nothing chosen the first star is the tab stop, so the group is still reachable" do
    doc = stars(%{value: 0})
    tabindexes = doc |> LazyHTML.query("[data-part=item]") |> LazyHTML.attribute("tabindex")

    assert Enum.count(tabindexes, &(&1 == "0")) == 1
    assert List.first(tabindexes) == "0"
  end

  test "clearable adds a zero control before the stars" do
    plain = stars(%{value: 1})
    refute has_attr?(plain, "[data-part=item]", "data-clear")

    doc = stars(%{value: 0, clearable: true})
    assert attr(doc, "[data-part=item]", "data-value") == "0"
    assert has_attr?(doc, "[data-part=item]", "data-clear")
    assert checked(doc) == ["0"]
  end

  test "the hidden input is what carries the value into a form" do
    doc = stars(%{name: "score", value: 3.5, precision: 0.5})

    assert attr(doc, "input[type=hidden]", "name") == "score"
    assert attr(doc, "input[type=hidden]", "value") == "3.5"
  end

  test "readonly and disabled are not the same thing" do
    readonly = stars(%{value: 3, readonly: true})
    assert attr(readonly, "[data-part=root]", "aria-readonly") == "true"
    # Focus must still move through a readonly rating so it can be read out.
    refute has_attr?(readonly, "[data-part=item]", "disabled")

    disabled = stars(%{value: 3, disabled: true})
    assert has_attr?(disabled, "[data-part=root]", "data-disabled")
    assert has_attr?(disabled, "[data-part=item]", "disabled")
  end

  test "every star says what it means, not just that it is a radio" do
    doc = stars(%{count: 5, value: 1})
    labels = doc |> LazyHTML.query("[data-part=item]") |> LazyHTML.attribute("aria-label")
    assert labels == Enum.map(1..5, &"#{&1}.0 of 5")
  end

  test "on_change rides on the root for the hook to push" do
    doc = stars(%{value: 1, on_change: "rated"})
    assert attr(doc, "[data-part=root]", "data-on-change") == "rated"
  end

  test "the showcase's form rating is wired end to end", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/rating")

    html =
      view
      |> form("#daisyui-rating-form-el")
      |> render_change(%{"score" => "4.5"})

    assert html =~ "score 4.5"
  end
end
