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

      # The clear button is a Box now — it was a Row wrapping a Box, and the tap
      # sat on the wrapper, so the spacer beside the glyph was part of the
      # target. Assert membership: the open list's option rows are Boxes with
      # their own taps, and equality here would be asserting the whole page.
      taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)
      assert {self(), :cleared} in taps
    end

    test "disabled unwires the field and the clear button" do
      tree = build(%{clear: true, disabled: true, on_query: :t, on_clear: :c})

      refute Map.has_key?(find(tree, :text_field).props, :on_change)
      refute {self(), :c} in (tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]))
    end
  end

  test "expand/3 reads option children" do
    tree = C.expand(%{open: true, query: "ir"}, opts(), %{screen: self()})

    assert text(tree) =~ "Iran"
  end

  describe "chips" do
    test "multiple shows the selection as removable chips inside the control" do
      tree = build(%{multiple: true, value: [:ir, :de]})

      # Without these the selection is invisible until you reopen the list.
      assert text(tree) =~ "Iran"
      assert text(tree) =~ "Germany"
    end

    test "single mode renders no chips" do
      # Not a text assertion: "Iran" is also an OPTION in the open list, so the
      # page contains it either way. The chip's own tag is the honest witness.
      ids =
        C.combobox(%{id: "cb", open: true, value: :ir, multiple: false}, opts())
        |> find_all(:box)
        |> Enum.map(& &1.props[:id])

      refute "cb-chip-ir" in ids
    end

    test "a chip's ✕ reports the id it would remove" do
      # The pill puts its remove handler on a ROW, not the pill box.
      taps =
        build(%{multiple: true, value: [:ir], on_remove: :drop})
        |> find_all(:row)
        |> Enum.map(& &1.props[:on_tap])

      assert {self(), {:drop, :ir}} in taps
    end

    test "a value with no matching option still shows, as its own id" do
      # A stale selection must be visible rather than silently vanishing.
      assert text(build(%{multiple: true, value: [:gone]})) =~ "gone"
    end
  end

  describe "the trigger button" do
    test "is opt-in and reports through on_toggle" do
      refute text(build(%{})) =~ "▴"

      tree = build(%{trigger: true, on_toggle: :flip})

      assert text(tree) =~ "▴"
      assert {self(), :flip} in (tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]))
    end

    test "the glyph follows the open state" do
      assert text(C.combobox(%{trigger: true, open: false}, opts())) =~ "▾"
      assert text(C.combobox(%{trigger: true, open: true}, opts())) =~ "▴"
    end
  end

  describe "groups and disabled options" do
    defp grouped do
      [
        C.option(:apple, "Apple", group: "FRUIT"),
        C.option(:cherry, "Cherry", group: "FRUIT"),
        C.option(:carrot, "Carrot", group: "VEGETABLE"),
        C.option(:durian, "Durian", group: "FRUIT", disabled: true)
      ]
    end

    test "a heading renders above each run" do
      tree = C.combobox(%{open: true}, grouped())

      assert text(tree) =~ "FRUIT"
      assert text(tree) =~ "VEGETABLE"
    end

    test "a disabled option survives filtering and stays inert" do
      # Options used to be flattened to {id, label}, which threw `disabled` and
      # `group` away — a disabled option was indistinguishable from any other.
      tree = C.combobox(%{open: true, on_select: :pick}, grouped())
      taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap])

      assert {self(), {:pick, :apple}} in taps
      refute {self(), {:pick, :durian}} in taps
    end

    test "filtering keeps the groups of whatever survives" do
      tree = C.combobox(%{open: true, query: "carrot"}, grouped())

      assert text(tree) =~ "VEGETABLE"
      refute text(tree) =~ "FRUIT"
    end
  end

  describe "creatable" do
    test "offers a create row for a query that matches nothing" do
      tree = build(%{creatable: true, query: "Pomelo", on_create: :make})

      assert text(tree) =~ ~s(Create "Pomelo")

      assert {self(), {:pick, :__create__}} in (tree
                                                |> find_all(:box)
                                                |> Enum.map(& &1.props[:on_tap]))
    end

    test "offers it even when a PARTIAL match is on screen" do
      # The web offers "Create Ira" while "Iran" is listed; only an EXACT match
      # suppresses it, which is the difference between a create row and a
      # duplicate.
      tree = build(%{creatable: true, query: "Ira"})

      assert text(tree) =~ "Iran"
      assert text(tree) =~ ~s(Create "Ira")
    end

    test "an exact match suppresses it, case- and accent-insensitively" do
      refute text(build(%{creatable: true, query: "Iran"})) =~ "Create"
      refute text(build(%{creatable: true, query: "cafe"})) =~ "Create"
    end

    test "a blank query, or creatable off, offers nothing" do
      refute text(build(%{creatable: true, query: "   "})) =~ "Create"
      refute text(build(%{query: "Pomelo"})) =~ "Create"
    end

    test "a disabled combobox offers nothing either" do
      refute text(build(%{creatable: true, query: "Pomelo", disabled: true})) =~ "Create"
    end
  end

  describe "test tags" do
    test "the input, the buttons and every option are addressable" do
      tree =
        C.combobox(
          %{id: "cb", open: true, clear: true, trigger: true, value: :ir, multiple: true},
          opts()
        )

      ids = tree |> find_all(:box) |> Enum.map(& &1.props[:id])

      assert find(tree, :text_field).props.id == "cb-input"
      assert "cb-on_clear" in ids
      assert "cb-on_toggle" in ids
      assert "cb-chip-ir" in ids
      assert "cb-option-ir-selected" in ids
      assert "cb-option-uk-idle" in ids
    end
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
