defmodule MishkaMob.Components.MishkaScrollAreaTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaScrollArea, as: SA

  defp content, do: [%{type: :text, props: %{text: "inside"}, children: []}]

  describe "the scroller" do
    test "is Mob's native Scroll, so the platform owns momentum and the scrollbar" do
      tree = SA.scroll_area(%{}, content())

      assert tree.type == :scroll
      assert text(tree) =~ "inside"
    end

    test "vertical is the default and sends no axis" do
      refute Map.has_key?(SA.scroll_area(%{}, content()).props, :axis)
      refute Map.has_key?(SA.scroll_area(%{orientation: :vertical}, content()).props, :axis)
    end

    test "horizontal sets the axis the bridge reads" do
      assert SA.scroll_area(%{orientation: :horizontal}, content()).props.axis == "horizontal"
    end

    test "an id is passed through so Mob.Test can address the scroller" do
      assert SA.scroll_area(%{id: "log"}, content()).props.id == "log"
      refute Map.has_key?(SA.scroll_area(%{}, content()).props, :id)
    end
  end

  describe "bounding and decoration" do
    test "with nothing asked for it stays ONE node — no pointless wrapper" do
      assert SA.scroll_area(%{}, content()).type == :scroll
    end

    test "a height wraps it in a bounded box (content only scrolls inside a bound)" do
      tree = SA.scroll_area(%{height: 200}, content())

      assert tree.type == :box
      assert tree.props.height == 200
      assert tree.props.fill_width == true
      assert [%{type: :scroll}] = tree.children
    end

    test "background, padding and corner_radius also wrap it" do
      tree =
        SA.scroll_area(%{background: :surface_raised, padding: 8, corner_radius: 4}, content())

      assert tree.type == :box
      assert tree.props.background == :surface_raised
      assert tree.props.padding == 8
      assert tree.props.corner_radius == 4
    end

    test "the decoration sits on the wrapper, never on the Scroll itself" do
      tree = SA.scroll_area(%{height: 100, background: :surface_raised}, content())
      scroller = find(tree, :scroll)

      refute Map.has_key?(scroller.props, :background)
      refute Map.has_key?(scroller.props, :height)
    end
  end

  test "expand/3 uses the tag's children as the content" do
    assert SA.expand(%{height: 100}, content(), %{screen: self()}) ==
             SA.scroll_area(%{height: 100}, content())
  end

  test "every variant renders" do
    for props <- [%{}, %{height: 200}, %{orientation: :horizontal}, %{id: "x", height: 100}] do
      assert_renderable(SA.scroll_area(props, content()))
    end
  end
end
