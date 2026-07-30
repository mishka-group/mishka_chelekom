defmodule MishkaMob.Components.MishkaFloatingWindowTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaFloatingIndicator, MishkaFloatingWindow}

  doctest MishkaMob.Components.MishkaFloatingWindow
  doctest MishkaMob.Components.MishkaFloatingIndicator

  defp taps(tree),
    do: tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

  describe "nudge/4" do
    test "up subtracts, because screen y grows downwards" do
      assert MishkaFloatingWindow.nudge({40, 40}, :up, 10) == {40, 30}
      assert MishkaFloatingWindow.nudge({40, 40}, :down, 10) == {40, 50}
    end

    test "left and right move x, leaving y alone" do
      assert MishkaFloatingWindow.nudge({40, 40}, :left, 10) == {30, 40}
      assert MishkaFloatingWindow.nudge({40, 40}, :right, 10) == {50, 40}
    end

    test "clamps inside bounds at both edges" do
      assert MishkaFloatingWindow.nudge({0, 0}, :left, 10, {200, 200}) == {0, 0}
      assert MishkaFloatingWindow.nudge({0, 0}, :up, 10, {200, 200}) == {0, 0}
      assert MishkaFloatingWindow.nudge({195, 195}, :right, 10, {200, 200}) == {200, 195}
      assert MishkaFloatingWindow.nudge({195, 195}, :down, 10, {200, 200}) == {195, 200}
    end

    test "without bounds it is unbounded, including negative" do
      assert MishkaFloatingWindow.nudge({0, 0}, :left, 10) == {-10, 0}
    end

    test "an unknown direction is a no-op rather than an error" do
      assert MishkaFloatingWindow.nudge({5, 5}, :sideways, 10) == {5, 5}
    end

    test "the default step is 20" do
      assert MishkaFloatingWindow.nudge({0, 40}, :up) == {0, 20}
    end

    test "repeated nudges accumulate and settle against the edge" do
      final =
        Enum.reduce(1..20, {0, 0}, fn _, pos ->
          MishkaFloatingWindow.nudge(pos, :right, 20, {100, 100})
        end)

      assert final == {100, 0}
    end
  end

  describe "rendering" do
    test "is positioned by offset, since there is no drag to position it" do
      tree = MishkaFloatingWindow.floating_window(%{x: 30, y: 12})

      assert tree.props.offset_x == 30
      assert tree.props.offset_y == 12
    end

    test "the handle shows the label and the body shows the children" do
      body = [%{type: :text, props: %{text: "contents"}, children: []}]
      tree = MishkaFloatingWindow.floating_window(%{label: "Inspector"}, body)

      assert text(tree) =~ "Inspector"
      assert text(tree) =~ "contents"
    end

    test "each arrow reports its own direction" do
      tree = MishkaFloatingWindow.floating_window(%{on_move: :move})

      for direction <- [:up, :down, :left, :right] do
        assert {self(), {:move, direction}} in taps(tree)
      end
    end

    test "the nudge controls can be hidden" do
      tree = MishkaFloatingWindow.floating_window(%{show_nudges: false, on_move: :move})

      assert taps(tree) == []
    end

    test "the close button appears only when wired" do
      refute text(MishkaFloatingWindow.floating_window(%{})) =~ "✕"

      closable = MishkaFloatingWindow.floating_window(%{on_close: :close})

      assert text(closable) =~ "✕"
      assert {self(), :close} in taps(closable)
    end

    test "width is a prop, so the window does not fill the stage" do
      assert MishkaFloatingWindow.floating_window(%{width: 180}).props.width == 180
      assert MishkaFloatingWindow.floating_window(%{}).props.width == 260
    end
  end

  describe "floating indicator" do
    @targets [
      %{label: "Day", value: :day},
      %{label: "Week", value: :week},
      %{label: "Month", value: :month, disabled: true}
    ]

    defp highlighted(tree) do
      tree
      |> find_all(:box)
      |> Enum.filter(&(&1.props[:background] not in [nil, :transparent, :surface]))
    end

    test "exactly one target is highlighted — the invariant, kept by construction" do
      tree = MishkaFloatingIndicator.floating_indicator(targets: @targets, active: :week)

      assert match?([_], highlighted(tree))
      assert text(tree) =~ "Week"
    end

    test "no active value highlights nothing" do
      tree = MishkaFloatingIndicator.floating_indicator(targets: @targets)

      assert highlighted(tree) == []
    end

    test "an unknown active value highlights nothing rather than guessing" do
      tree = MishkaFloatingIndicator.floating_indicator(targets: @targets, active: :year)

      assert highlighted(tree) == []
    end

    test "moving the active value moves the highlight, and only it" do
      day = MishkaFloatingIndicator.floating_indicator(targets: @targets, active: :day)
      week = MishkaFloatingIndicator.floating_indicator(targets: @targets, active: :week)

      refute day == week
      assert match?([_], highlighted(day))
      assert match?([_], highlighted(week))
    end

    test "the active label is emphasised" do
      tree = MishkaFloatingIndicator.floating_indicator(targets: @targets, active: :day)
      active = tree |> find_all(:text) |> Enum.find(&(&1.props.text == "Day"))
      other = tree |> find_all(:text) |> Enum.find(&(&1.props.text == "Week"))

      # `font_weight`, not `weight` — the bridges read the former for typography,
      # and the latter is a parent Row/Column layout weight that styles nothing.
      assert active.props.font_weight == :semibold
      assert other.props.font_weight == :regular
      refute Map.has_key?(active.props, :weight)
    end

    test "the highlight colour is a prop" do
      tree =
        MishkaFloatingIndicator.floating_indicator(
          targets: @targets,
          active: :day,
          color: 0xFF3B82F6
        )

      assert [box] = highlighted(tree)
      assert box.props.background == 0xFF3B82F6
    end

    test "targets report their value; a disabled one does not" do
      tree = MishkaFloatingIndicator.floating_indicator(targets: @targets, on_change: :pick)

      assert {self(), {:pick, :day}} in taps(tree)
      refute {self(), {:pick, :month}} in taps(tree)
    end

    test "disabling the group disables every target" do
      tree =
        MishkaFloatingIndicator.floating_indicator(
          targets: @targets,
          disabled: true,
          on_change: :pick
        )

      assert taps(tree) == []
    end

    test "orientation switches between a row and a stack" do
      row = MishkaFloatingIndicator.floating_indicator(targets: @targets)

      stack =
        MishkaFloatingIndicator.floating_indicator(targets: @targets, orientation: :vertical)

      assert find(row, :row)
      refute find(stack, :row)

      assert MishkaFloatingIndicator.floating_indicator(
               targets: @targets,
               orientation: "vertical"
             ) ==
               stack
    end

    test "active?/2 is the whole semantics" do
      assert MishkaFloatingIndicator.active?(:a, :a)
      refute MishkaFloatingIndicator.active?(:a, :b)
      refute MishkaFloatingIndicator.active?(:a, nil)
      refute MishkaFloatingIndicator.active?(nil, nil)
    end
  end

  test "expand/3 delegates for both" do
    ctx = %{screen: self()}
    body = [%{type: :text, props: %{text: "x"}, children: []}]

    assert MishkaFloatingWindow.expand(%{x: 5}, body, ctx) ==
             MishkaFloatingWindow.floating_window(%{x: 5}, body)

    assert MishkaFloatingIndicator.expand(%{targets: @targets}, [], ctx) ==
             MishkaFloatingIndicator.floating_indicator(targets: @targets)
  end

  test "every variant renders" do
    for tree <- [
          MishkaFloatingWindow.floating_window(),
          MishkaFloatingWindow.floating_window(%{
            x: 10,
            y: 10,
            label: "W",
            on_close: :c,
            on_move: :m
          }),
          MishkaFloatingWindow.floating_window(%{show_nudges: false}),
          MishkaFloatingIndicator.floating_indicator(),
          MishkaFloatingIndicator.floating_indicator(targets: @targets, active: :day),
          MishkaFloatingIndicator.floating_indicator(
            targets: @targets,
            orientation: :vertical,
            disabled: true
          )
        ] do
      assert_renderable(tree)
    end
  end
end
