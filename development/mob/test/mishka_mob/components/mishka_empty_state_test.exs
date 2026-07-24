defmodule MishkaMob.Components.MishkaEmptyStateTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaEmptyState, as: ES

  defp actions, do: [%{type: :button, props: %{text: "New"}, children: []}]

  describe "layout" do
    test "centred wraps the block in a centring Box" do
      tree = ES.empty_state(title: "No messages")

      assert tree.type == :box
      assert tree.props.align == :center
    end

    test "leading lays the indicator beside the text" do
      tree = ES.empty_state(align: :leading, indicator: "🔍", title: "No results")

      assert tree.type == :row
      assert text(tree) =~ "🔍"
      assert text(tree) =~ "No results"
    end

    test "padding is overridable on the centred layout" do
      assert ES.empty_state(title: "x", padding: :space_sm).props.padding == :space_sm
    end
  end

  describe "parts are optional" do
    test "title only" do
      tree = ES.empty_state(title: "Nothing here")

      assert text(tree) =~ "Nothing here"
      assert find_all(tree, :button) == []
    end

    test "description only" do
      assert text(ES.empty_state(description: "Nothing to see")) =~ "Nothing to see"
    end

    test "an indicator glyph renders, and is absent when not given" do
      assert text(ES.empty_state(indicator: "📭", title: "x")) =~ "📭"
      refute text(ES.empty_state(title: "x")) =~ "📭"
    end

    test "nothing at all still renders" do
      assert_renderable(ES.empty_state())
    end
  end

  describe "actions" do
    test "render beneath the text when given" do
      tree = ES.empty_state(%{title: "x"}, [], actions())

      assert find(tree, :button, text: "New")
    end

    test "no actions means no actions row" do
      tree = ES.empty_state(%{title: "x"}, [], [])

      assert find_all(tree, :button) == []
    end
  end

  test "indicator nodes replace the glyph" do
    art = [%{type: :text, props: %{text: "★"}, children: []}]
    tree = ES.empty_state(%{indicator: "📭", title: "x"}, art, [])

    assert text(tree) =~ "★"
    refute text(tree) =~ "📭"
  end

  test "expand/3 treats the tag's children as the actions" do
    tree = ES.expand(%{title: "x"}, actions(), %{screen: self()})

    assert find(tree, :button, text: "New")
  end

  test "every variant renders" do
    for props <- [%{}, %{title: "t"}, %{align: :leading, title: "t"}, %{indicator: "x"}] do
      assert_renderable(ES.empty_state(props))
    end
  end
end
