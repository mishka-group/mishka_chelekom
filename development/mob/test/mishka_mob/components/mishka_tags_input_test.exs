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

  test "every variant renders" do
    for props <- [%{}, %{tags: ["a", "b"]}, %{tags: ["a"], disabled: true}, %{draft: "x"}] do
      assert_renderable(TI.tags_input(props))
    end
  end
end
