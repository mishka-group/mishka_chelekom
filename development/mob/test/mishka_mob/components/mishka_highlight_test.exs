defmodule MishkaMob.Components.MishkaHighlightTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaHighlight, MishkaMark}

  doctest MishkaMob.Components.MishkaHighlight

  describe "split/2" do
    test "splits around a match, keeping the surrounding runs" do
      assert MishkaHighlight.split("Mishka Chelekom", "chel") ==
               [{:text, "Mishka "}, {:mark, "Chel"}, {:text, "ekom"}]
    end

    test "matches case-insensitively but keeps the SOURCE casing" do
      assert [{:mark, "BEAM"}] = MishkaHighlight.split("BEAM", "beam")
      assert [{:mark, "beam"}] = MishkaHighlight.split("beam", "BEAM")
    end

    test "marks every occurrence" do
      assert MishkaHighlight.split("aXaXa", "x") ==
               [{:text, "a"}, {:mark, "X"}, {:text, "a"}, {:mark, "X"}, {:text, "a"}]
    end

    test "handles several queries" do
      assert MishkaHighlight.split("one two three", ["one", "three"]) ==
               [{:mark, "one"}, {:text, " two "}, {:mark, "three"}]
    end

    test "blank, nil and missing queries leave one plain run" do
      assert MishkaHighlight.split("one two", []) == [{:text, "one two"}]
      assert MishkaHighlight.split("one two", "") == [{:text, "one two"}]
      assert MishkaHighlight.split("one two", ["", nil]) == [{:text, "one two"}]
      assert MishkaHighlight.split("one two", "zzz") == [{:text, "one two"}]
    end

    test "a match at either end produces no empty runs" do
      assert MishkaHighlight.split("abc", "a") == [{:mark, "a"}, {:text, "bc"}]
      assert MishkaHighlight.split("abc", "c") == [{:text, "ab"}, {:mark, "c"}]
      assert MishkaHighlight.split("abc", "abc") == [{:mark, "abc"}]
    end

    test "regex metacharacters in a query are escaped, not interpreted" do
      assert MishkaHighlight.split("a.c", ".") == [{:text, "a"}, {:mark, "."}, {:text, "c"}]
      assert MishkaHighlight.split("a+b", "+") == [{:text, "a"}, {:mark, "+"}, {:text, "b"}]
      # a wildcard must NOT swallow the whole string
      refute MishkaHighlight.split("abc", ".") == [{:mark, "abc"}]
    end

    test "an empty text stays empty" do
      assert MishkaHighlight.split("", "a") == []
    end
  end

  describe "rendering" do
    test "plain runs are Text and matched runs are Marks" do
      tree = MishkaHighlight.highlight(text: "Mishka Chelekom", highlight: "chel")

      assert tree.type == :row
      assert [%{type: :text}, %{type: :box}, %{type: :text}] = tree.children
      assert find(tree, :box).props.background == MishkaMark.default_fill()
    end

    test "with no query it is a single Text run" do
      tree = MishkaHighlight.highlight(text: "nothing", highlight: "")

      assert [%{type: :text, props: %{text: "nothing"}}] = tree.children
      assert find_all(tree, :box) == []
    end

    test "every run keeps the full text between them" do
      tree = MishkaHighlight.highlight(text: "one two three", highlight: ["one", "three"])

      assert text(tree) =~ "one"
      assert text(tree) =~ "two"
      assert text(tree) =~ "three"
    end

    test "colours apply to marks and to plain text separately" do
      tree =
        MishkaHighlight.highlight(
          text: "a B c",
          highlight: "b",
          background: 0xFFBBF7D0,
          color: 0xFF000000,
          text_color: :muted
        )

      assert find(tree, :box).props.background == 0xFFBBF7D0

      assert find(tree, :box) |> find(:text) |> Map.fetch!(:props) |> Map.fetch!(:text_color) ==
               0xFF000000

      plain = tree.children |> Enum.filter(&(&1.type == :text))
      assert Enum.all?(plain, &(&1.props.text_color == :muted))
    end

    test "text_size applies to both marked and plain runs" do
      tree = MishkaHighlight.highlight(text: "a B c", highlight: "b", text_size: :sm)

      assert Enum.all?(find_all(tree, :text), &(&1.props.text_size == :sm))
    end
  end

  test "expand/3 delegates to highlight/1" do
    assert MishkaHighlight.expand(%{text: "a", highlight: "a"}, [], %{screen: self()}) ==
             MishkaHighlight.highlight(text: "a", highlight: "a")
  end

  test "every variant renders" do
    for props <- [
          %{},
          %{text: "abc"},
          %{text: "abc", highlight: "b"},
          %{text: "abc", highlight: ["a", "c"]}
        ] do
      assert_renderable(MishkaHighlight.highlight(props))
    end
  end
end
