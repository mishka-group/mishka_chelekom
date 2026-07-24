defmodule MishkaMob.Components.MishkaSpoilerTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaSpoiler

  doctest MishkaMob.Components.MishkaSpoiler

  defp content, do: [%{type: :text, props: %{text: "the long content"}, children: []}]
  defp preview, do: [%{type: :text, props: %{text: "a teaser"}, children: []}]

  describe "label/2 — the control changes as it works" do
    test "defaults" do
      assert MishkaSpoiler.label(%{}, false) == "Show more"
      assert MishkaSpoiler.label(%{}, true) == "Show less"
    end

    test "are overridable independently" do
      props = %{show_label: "Read on", hide_label: "Collapse"}

      assert MishkaSpoiler.label(props, false) == "Read on"
      assert MishkaSpoiler.label(props, true) == "Collapse"
    end
  end

  describe "content" do
    test "is hidden until expanded" do
      refute text(MishkaSpoiler.spoiler(%{}, content())) =~ "the long content"
      assert text(MishkaSpoiler.spoiler(%{expanded: true}, content())) =~ "the long content"
    end

    test "the preview shows while collapsed and is replaced when expanded" do
      collapsed = MishkaSpoiler.spoiler(%{preview: preview()}, content())
      expanded = MishkaSpoiler.spoiler(%{expanded: true, preview: preview()}, content())

      assert text(collapsed) =~ "a teaser"
      refute text(collapsed) =~ "the long content"
      assert text(expanded) =~ "the long content"
      refute text(expanded) =~ "a teaser"
    end

    test "with no preview only the control shows while collapsed" do
      tree = MishkaSpoiler.spoiler(%{}, content())

      assert text(tree) =~ "Show more"
      refute text(tree) =~ "the long content"
    end
  end

  describe "the control" do
    test "sits LAST, under the content — a spoiler is not a titled header" do
      tree = MishkaSpoiler.spoiler(%{expanded: true}, content())

      assert %{type: :text, props: %{text: "Show less"}} = List.last(tree.children)
    end

    test "is a text link, not a Button or a panel header" do
      assert find_all(MishkaSpoiler.spoiler(%{}, content()), :button) == []
    end

    test "the handler is widened to {pid, tag}" do
      tree = MishkaSpoiler.spoiler(%{on_toggle: :more}, content())

      assert List.last(tree.children).props.on_tap == {self(), :more}
    end

    test "no on_toggle leaves it inert" do
      tree = MishkaSpoiler.spoiler(%{}, content())

      refute Map.has_key?(List.last(tree.children).props, :on_tap)
    end

    test "colour is overridable" do
      tree = MishkaSpoiler.spoiler(%{color: 0xFF7C3AED}, content())

      assert List.last(tree.children).props.text_color == 0xFF7C3AED
    end
  end

  test "expand/3 uses the tag's children as the content" do
    assert MishkaSpoiler.expand(%{expanded: true}, content(), %{screen: self()}) ==
             MishkaSpoiler.spoiler(%{expanded: true}, content())
  end

  test "every variant renders" do
    for props <- [%{}, %{expanded: true}, %{preview: preview()}, %{on_toggle: :t}] do
      assert_renderable(MishkaSpoiler.spoiler(props, content()))
    end
  end
end
