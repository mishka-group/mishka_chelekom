defmodule MishkaMob.Components.MishkaComboboxTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaCombobox, as: C

  doctest MishkaMob.Components.MishkaCombobox

  defp pairs, do: [{:ir, "Iran"}, {:uk, "United Kingdom"}, {:de, "Germany"}, {:ca, "Café"}]
  defp opts, do: Enum.map(pairs(), fn {id, label} -> C.option(id, label) end)

  defp build(props),
    do: C.combobox(Map.merge(%{open: true, on_select: :pick}, props), opts())

  describe "fold/1" do
    test "case-folds and strips diacritics" do
      assert C.fold("Café") == "cafe"
      assert C.fold("ÜBER") == "uber"
      assert C.fold("  Spaced  ") == "spaced"
    end

    test "nil is empty" do
      assert C.fold(nil) == ""
    end
  end

  describe "filter/3" do
    test "matches anywhere by default" do
      assert C.filter(pairs(), "ir") == [{:ir, "Iran"}]
      assert C.filter(pairs(), "king") == [{:uk, "United Kingdom"}]
    end

    test "ignores case AND accents — a phone keyboard has neither" do
      assert C.filter(pairs(), "cafe") == [{:ca, "Café"}]
      assert C.filter(pairs(), "CAFÉ") == [{:ca, "Café"}]
      assert C.filter(pairs(), "IRAN") == [{:ir, "Iran"}]
    end

    test "an empty or nil query matches everything" do
      assert C.filter(pairs(), "") == pairs()
      assert C.filter(pairs(), nil) == pairs()
      assert C.filter(pairs(), "   ") == pairs()
    end

    test "no match yields an empty list" do
      assert C.filter(pairs(), "zzz") == []
    end

    test "starts_with only matches the beginning" do
      assert C.filter(pairs(), "ir", mode: :starts_with) == [{:ir, "Iran"}]
      assert C.filter(pairs(), "ran", mode: :starts_with) == []
      assert C.filter(pairs(), "ran") == [{:ir, "Iran"}]
    end
  end

  describe "rendering" do
    test "is a text field over the filtered list" do
      tree = build(%{query: "ir"})

      assert find(tree, :text_field)
      assert text(tree) =~ "Iran"
      refute text(tree) =~ "Germany"
    end

    test "the list is hidden while closed" do
      refute text(C.combobox(%{query: ""}, opts())) =~ "Iran"
    end

    test "no matches renders a message rather than collapsing" do
      tree = build(%{query: "zzz", empty_text: "Nothing found"})

      assert text(tree) =~ "Nothing found"
    end

    test "the empty row is not selectable" do
      tree = build(%{query: "zzz"})
      taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

      assert taps == []
    end

    test "chosen options are ticked" do
      assert text(build(%{query: "", value: :ir})) =~ "✓"
      refute text(build(%{query: ""})) =~ "✓"
    end

    test "each visible option carries its own id" do
      taps =
        build(%{query: "ir"})
        |> find_all(:box)
        |> Enum.map(& &1.props[:on_tap])
        |> Enum.reject(&is_nil/1)

      assert taps == [{self(), {:pick, :ir}}]
    end

    test "typing reports through on_query" do
      assert find(build(%{on_query: :typed}), :text_field).props.on_change == {self(), :typed}
    end

    test "the clear button is opt-in and carries its own handler" do
      refute text(build(%{})) =~ "✕"

      tree = build(%{clear: true, on_clear: :cleared})
      assert text(tree) =~ "✕"

      taps = tree |> find_all(:row) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)
      assert taps == [{self(), :cleared}]
    end

    test "disabled unwires the field and the clear button" do
      tree = build(%{clear: true, disabled: true, on_query: :t, on_clear: :c})

      refute Map.has_key?(find(tree, :text_field).props, :on_change)
      assert tree |> find_all(:row) |> Enum.all?(&(&1.props[:on_tap] == nil))
    end
  end

  test "expand/3 reads option children" do
    tree = C.expand(%{open: true, query: "ir"}, opts(), %{screen: self()})

    assert text(tree) =~ "Iran"
  end

  test "every variant renders" do
    for props <- [
          %{},
          %{open: true},
          %{open: true, query: "zzz"},
          %{open: true, value: [:ir], multiple: true}
        ] do
      assert_renderable(C.combobox(props, opts()))
    end
  end
end
