defmodule MishkaMob.Components.MishkaSegmentedControlTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  import Mob.Sigil

  alias MishkaMob.Components.MishkaSegmentedControl, as: SC

  doctest MishkaMob.Components.MishkaSegmentedControl

  defp opts do
    [SC.option(:day, "Day"), SC.option(:week, "Week"), SC.option(:month, "Month", disabled: true)]
  end

  defp build(props),
    do: SC.segmented_control(Map.merge(%{on_change: :pick}, props), opts())

  defp track(tree), do: find(tree, :box)
  defp segments(tree), do: find(tree, :row).children

  describe "always one selected" do
    test "select/2 returns the tapped id, so it can never be cleared" do
      assert SC.select(:a, :b) == :b
      assert SC.select(:a, :a) == :a
    end

    test "an unknown or missing value falls back to the first option" do
      assert SC.selected(%{}, [%{id: :a}, %{id: :b}]) == :a
      assert SC.selected(%{value: :gone}, [%{id: :a}, %{id: :b}]) == :a
      assert SC.selected(%{value: :b}, [%{id: :a}, %{id: :b}]) == :b
    end

    test "no options yields nil rather than raising" do
      assert SC.selected(%{value: :a}, []) == nil
    end

    test "exactly one segment is filled" do
      fills = build(%{value: :week}) |> segments() |> Enum.map(& &1.props.background)

      assert Enum.count(fills, &(&1 == :primary)) == 1
      assert Enum.at(fills, 1) == :primary
    end

    test "with no value the FIRST segment is filled, never none" do
      fills = build(%{}) |> segments() |> Enum.map(& &1.props.background)

      assert Enum.at(fills, 0) == :primary
    end
  end

  describe "the track" do
    test "is one joined box holding the segments" do
      tree = build(%{})

      assert track(tree).props.background == :surface_raised
      assert track(tree).props.corner_radius == :radius_md
      assert length(segments(tree)) == 3
    end

    test "unselected segments are transparent so the track shows through" do
      fills = build(%{value: :day}) |> segments() |> Enum.map(& &1.props.background)

      assert Enum.at(fills, 1) == :transparent
    end

    test "track and selection colours are overridable" do
      tree = build(%{value: :day, background: 0xFF111827, color: 0xFF7C3AED})

      assert track(tree).props.background == 0xFF111827
      assert Enum.at(segments(tree), 0).props.background == 0xFF7C3AED
    end
  end

  describe "events" do
    test "each segment reports the same tag widened with its own id" do
      taps = build(%{value: :day}) |> segments() |> Enum.map(& &1.props[:on_tap])

      assert [{pid, {:pick, :day}}, {_, {:pick, :week}}, nil] = taps
      assert pid == self()
    end

    test "a disabled segment is inert; a disabled control cascades" do
      assert build(%{}) |> segments() |> List.last() |> get_in([Access.key(:props), :on_tap]) ==
               nil

      assert Enum.all?(segments(build(%{disabled: true})), &(&1.props[:on_tap] == nil))
    end

    test "no on_change means nothing is tappable" do
      tree = SC.segmented_control(%{value: :day}, opts())

      assert Enum.all?(segments(tree), &(&1.props[:on_tap] == nil))
    end
  end

  describe "layout" do
    test "every segment HUGS its label" do
      # A Box with neither a width nor fill_width fills its parent, so an
      # unguarded first segment claims the whole strip and the rest are pushed
      # off the screen — correct in the tree, invisible on the device. This is
      # also what makes the moduledoc's "content-sized" claim true.
      assert Enum.all?(segments(build(%{})), &(&1.props.fill_width == false))
    end

    test "the track hugs by default and spans on request" do
      assert track(build(%{})).props.fill_width == false
      assert track(build(%{fill_width: true})).props.fill_width == true
    end

    test "the inner Row follows the track, or a hugging track wraps a filling child" do
      assert find(build(%{}), :row).props.fill_width == false
      assert find(build(%{fill_width: true}), :row).props.fill_width == true
    end
  end

  describe "styling is the caller's" do
    test "every visual is overridable" do
      tree =
        build(%{
          value: :day,
          padding: 14,
          track_padding: 6,
          corner_radius: 12,
          segment_radius: 9,
          border_color: :border,
          border_width: 1,
          text_size: :sm,
          label_color: :muted
        })

      assert track(tree).props.padding == 6
      assert track(tree).props.corner_radius == 12
      assert track(tree).props.border_width == 1

      selected = Enum.at(segments(tree), 0)
      assert selected.props.padding == 14
      assert selected.props.corner_radius == 9

      # label_color paints an UNSELECTED label; the selected one keeps text_color.
      assert find(Enum.at(segments(tree), 1), :text).props.text_color == :muted
      assert find(selected, :text).props.text_size == :sm
    end

    test "the track has no border unless one is asked for" do
      assert track(build(%{})).props.border_width == 0
    end
  end

  describe "segment test tags" do
    # Selection is a fill colour, and colour is not in the accessibility tree —
    # these tags are the only way a device test can see which segment is chosen.
    test "each segment is tagged <control>-<option>-<state>" do
      ids = build(%{id: "view", value: :week}) |> segments() |> Enum.map(& &1.props[:id])

      assert ids == ["view-day-idle", "view-week-selected", "view-month-idle"]
    end

    test "no control id leaves every segment untagged" do
      ids = build(%{value: :week}) |> segments() |> Enum.map(& &1.props[:id])

      assert Enum.all?(ids, &is_nil/1)
    end
  end

  test "a disabled segment that is SELECTED keeps its selected label colour" do
    # Otherwise the fill stays accent-coloured under a muted label, which is
    # unreadable — and the user cannot see which segment is locked in.
    tree = build(%{value: :month, disabled: true})

    assert find(Enum.at(segments(tree), 2), :text).props.text_color == :on_primary
  end

  test "the label renders above the strip when given" do
    assert text(build(%{label: "VIEW"})) =~ "VIEW"
  end

  test "expand/3 reads segment children and ignores anything else" do
    stray = %{type: :text, props: %{text: "stray"}, children: []}
    tree = SC.expand(%{value: :day}, opts() ++ [stray], %{screen: self()})

    refute text(tree) =~ "stray"
    assert length(segments(tree)) == 3
  end

  describe "slots" do
    # The tag form is the one a screen writes; the function form is what you want
    # when the segments come from data. They must stay interchangeable, because
    # the showcase and the usage rule both promise it.
    defp tag_opts do
      [
        ~MOB(<MishkaSegmentedControlOption id={:day} label="Day" />),
        ~MOB(<MishkaSegmentedControlOption id={:week} label="Week" />),
        ~MOB(<MishkaSegmentedControlOption id={:month} label="Month" disabled={true} />)
      ]
    end

    test "<MishkaSegmentedControlOption> builds the node option/3 builds" do
      assert ~MOB(<MishkaSegmentedControlOption id={:day} label="Day" disabled={false} />) ==
               SC.option(:day, "Day")

      assert ~MOB(<MishkaSegmentedControlOption id={:month} label="Month" disabled={true} />) ==
               SC.option(:month, "Month", disabled: true)
    end

    test "a tag written without `disabled` still means false" do
      [day, _week, _month] = tag_opts()

      # The tag simply has no such key where option/3 writes `false`. That is the
      # only difference between the two forms, and it is why everything reading a
      # segment's props takes `disabled` with a default rather than matching on
      # it — the tree-equality test below is what proves the default lands.
      refute Map.has_key?(day.props, :disabled)
    end

    test "the tag form and the function form expand to the same tree" do
      props = %{value: :week, on_change: :pick, id: "view", label: "VIEW"}
      ctx = %{screen: self()}

      assert SC.expand(props, tag_opts(), ctx) == SC.expand(props, opts(), ctx)
    end

    test "no slot marker survives expansion" do
      tree = SC.expand(%{value: :week, on_change: :pick}, tag_opts(), %{screen: self()})

      # assert_renderable is blind here: mix.exs whitelists the tag name so the
      # helper considers it renderable, while the renderer's `when (node.type)`
      # has no else branch and simply draws nothing. Only an explicit check
      # catches a marker the expander forgot to consume.
      assert find_all(tree, :mishka_segmented_control_option) == []
      assert length(segments(tree)) == 3
    end
  end

  test "every variant renders" do
    for props <- [%{}, %{value: :week}, %{disabled: true}, %{label: "V"}] do
      assert_renderable(build(props))
    end
  end
end
