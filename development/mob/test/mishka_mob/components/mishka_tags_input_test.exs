defmodule MishkaMob.Components.MishkaTagsInputTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaTagsInput, as: TI

  doctest MishkaMob.Components.MishkaTagsInput

  describe "add/3" do
    test "appends, newest last" do
      assert TI.add(["a"], "b") == ["a", "b"]
      assert TI.add([], "a") == ["a"]
    end

    test "trims surrounding whitespace" do
      assert TI.add([], "  spaced  ") == ["spaced"]
    end

    test "ignores blank input rather than adding an empty token" do
      assert TI.add(["a"], "") == ["a"]
      assert TI.add(["a"], "   ") == ["a"]
      assert TI.add(["a"], nil) == ["a"]
    end

    test "refuses a duplicate — including one that only differs by whitespace" do
      assert TI.add(["a"], "a") == ["a"]
      assert TI.add(["a"], "  a  ") == ["a"]
    end

    test "allow_duplicates opts back in" do
      assert TI.add(["a"], "a", allow_duplicates: true) == ["a", "a"]
    end
  end

  describe "remove/2" do
    test "removes by value and leaves the rest" do
      assert TI.remove(["a", "b"], "a") == ["b"]
      assert TI.remove(["a"], "zzz") == ["a"]
    end
  end

  describe "the control" do
    test "is a bordered box holding tokens above a draft field" do
      tree = TI.tags_input(tags: ["a", "b"])

      assert tree.type == :box
      assert tree.props.border_width == 1
      assert find(tree, :text_field)
      assert text(tree) =~ "a"
      assert text(tree) =~ "b"
    end

    test "with no tags it is just the draft field" do
      tree = TI.tags_input(tags: [])

      assert find(tree, :text_field)
      refute text(tree) =~ "✕"
    end

    test "each token carries its own remove tag" do
      tree = TI.tags_input(tags: ["a", "b"], on_remove: :drop)

      taps =
        tree
        |> find_all(:row)
        |> Enum.map(& &1.props[:on_tap])
        |> Enum.reject(&is_nil/1)

      assert taps == [{self(), {:drop, "a"}}, {self(), {:drop, "b"}}]
    end

    test "the draft field reports typing and return separately" do
      field = find(TI.tags_input(on_draft: :typed, on_add: :commit), :text_field)

      assert field.props.on_change == {self(), :typed}
      assert field.props.on_submit == {self(), :commit}
      assert field.props.return_key == "done"
    end

    test "the draft value and placeholder are passed through" do
      field = find(TI.tags_input(draft: "half", placeholder: "Add…"), :text_field)

      assert field.props.value == "half"
      assert field.props.placeholder == "Add…"
    end

    test "disabled unwires the draft and every token" do
      tree = TI.tags_input(tags: ["a"], disabled: true, on_draft: :t, on_add: :c, on_remove: :d)
      field = find(tree, :text_field)

      refute Map.has_key?(field.props, :on_change)
      refute Map.has_key?(field.props, :on_submit)
      assert tree |> find_all(:row) |> Enum.all?(&(&1.props[:on_tap] == nil))
    end
  end

  test "expand/3 delegates" do
    assert TI.expand(%{tags: ["a"]}, [], %{screen: self()}) == TI.tags_input(tags: ["a"])
  end

  describe "layout" do
    test "the draft field draws no box, so no line crosses the control" do
      field = find(TI.tags_input(%{}), :text_field)

      # A Material text field with no border of its own draws its INDICATOR
      # line, which lands inside the container as a stray border.
      assert field.props.underline == false
      assert field.props.background == :transparent
    end

    test "the container's decoration is all overridable" do
      plain = TI.tags_input(%{border_width: 0, background: :background, padding: 0})

      assert plain.props.border_width == 0
      assert plain.props.background == :background
      assert plain.props.padding == 0
    end

    test "tokens wrap onto more rows as they get longer" do
      # Neither renderer has a flow layout, so a single Row of tokens runs off
      # the edge. Rows are packed by an estimate; this pins that they multiply.
      short = TI.tags_input(%{tags: ["a", "b", "c"]})
      long = TI.tags_input(%{tags: ["aaaaaaaaaa", "bbbbbbbbbb", "cccccccccc"]})

      assert token_rows(short) == 1
      assert token_rows(long) > 1
    end

    test "wrap_chars moves the budget" do
      assert token_rows(TI.tags_input(%{tags: ["aaaa", "bbbb"], wrap_chars: 100})) == 1
      assert token_rows(TI.tags_input(%{tags: ["aaaa", "bbbb"], wrap_chars: 9})) == 2
    end
  end

  describe "test tags" do
    test "the draft and every token are addressable" do
      tree = TI.tags_input(%{id: "tg", tags: ["elixir", "phoenix"]})
      ids = tree |> find_all(:box) |> Enum.map(& &1.props[:id]) |> Enum.reject(&is_nil/1)

      assert find(tree, :text_field).props.id == "tg-draft"
      # Every ✕ reads the same glyph, so the tag itself makes the id unique.
      assert "tg-tag-elixir" in ids
      assert "tg-tag-phoenix" in ids
    end

    test "no id leaves everything untagged" do
      tree = TI.tags_input(%{tags: ["a"]})

      refute Map.has_key?(find(tree, :text_field).props, :id)
    end
  end

  # A token row is a :row holding pills; the container Column holds those rows.
  defp token_rows(tree) do
    tree
    |> find_all(:row)
    |> Enum.count(fn row ->
      Enum.any?(row.children, &(&1.type == :mishka_pill or &1.type == :box)) and text(row) != ""
    end)
  end

  test "every variant renders" do
    for props <- [%{}, %{tags: ["a", "b"]}, %{tags: ["a"], disabled: true}, %{draft: "x"}] do
      assert_renderable(TI.tags_input(props))
    end
  end
end
