defmodule MishkaMob.Components.MishkaSemiCircleProgressTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaSemiCircleProgress

  doctest MishkaMob.Components.MishkaSemiCircleProgress

  defp canvas(props) do
    find(MishkaSemiCircleProgress.semi_circle_progress(props), :canvas)
  end

  defp arcs(props), do: canvas(props).props.draw |> Enum.filter(&(&1.op == :arc))

  defp readouts(props) do
    MishkaSemiCircleProgress.semi_circle_progress(props)
    |> find_all(:text)
    |> Enum.reject(&(&1.props[:text_color] == :muted))
  end

  describe "the arc" do
    # The whole point of the rewrite: this used to be a flat 8dp bar with a
    # moduledoc claiming Mob had no canvas. It has one, and an :arc op.
    test "is a real half circle, not a bar" do
      [track | _] = arcs(%{value: 50})

      assert track.start_deg == 180
      assert track.end_deg == 360
      refute match?(%{type: :progress}, canvas(%{value: 50}))
    end

    test "keeps the headless viewBox proportions at any size" do
      # viewBox "0 0 200 108": height 0.54 x width, stroke 0.06 x width, and the
      # radius inset by a full stroke.
      for size <- [104, 140, 200] do
        node = canvas(%{value: 50, size: size})
        [track | _] = arcs(%{value: 50, size: size})
        stroke = size * 0.06

        assert node.props.width == size
        assert node.props.height == round(size * 0.54)
        assert_in_delta track.width, stroke, 0.001
        assert_in_delta track.r, size / 2 - stroke, 0.001
        assert_in_delta track.x, size / 2, 0.001
        assert_in_delta track.y, size / 2, 0.001
      end
    end

    test "the indicator sweeps 180 degrees in proportion to the value" do
      assert [_track, %{end_deg: end_deg}] = arcs(%{value: 72})
      assert_in_delta end_deg, 180 + 180 * 0.72, 0.001

      assert [_track, %{end_deg: full}] = arcs(%{value: 100})
      assert_in_delta full, 360, 0.001
    end

    test "the indicator is omitted at zero, never drawn empty" do
      # A round cap with nothing to stroke paints a cap-sized dot at the left
      # end, and neither renderer guards a zero sweep.
      assert [_track_only] = arcs(%{value: 0})
      assert [_track_only] = arcs(%{})
      assert [_track_only] = arcs(%{value: -40})
    end

    test "only the indicator is round-capped, matching the web" do
      [track, indicator] = arcs(%{value: 50})

      refute Map.has_key?(track, :cap)
      assert indicator.cap == :round
    end

    test "clamps like every other gauge here" do
      assert [_track, %{end_deg: 360.0}] = arcs(%{value: 250})
      assert [_track_only] = arcs(%{value: -40})
    end

    test "a numeric string value reads as a number rather than crashing" do
      # The web attr is :any and parses strings; an unbraced sigil attr IS a
      # string, so <MishkaSemiCircleProgress value="72" /> used to raise.
      assert [_track, %{end_deg: end_deg}] = arcs(%{value: "72"})
      assert_in_delta end_deg, 180 + 180 * 0.72, 0.001

      assert [_track_only] = arcs(%{value: "nonsense"})
    end

    test "colour and thickness are overridable" do
      [track, indicator] = arcs(%{value: 50, color: 0xFF10B981, thickness: 20})

      assert indicator.color == 0xFF10B981
      assert track.width == 20
      assert_in_delta track.r, 140 / 2 - 20, 0.001
    end
  end

  describe "the readout" do
    # It is a real node, not a canvas text op — a canvas is a drawing, so a
    # painted readout is invisible to the platform and to a device test.
    test "is a real Text node stacked over the canvas, not a draw op" do
      assert [%{props: %{text: "72%"}}] = readouts(%{value: 72})
      assert canvas(%{value: 72}).props.draw |> Enum.all?(&(&1.op == :arc))
    end

    test "the stack centres both the canvas and the readout" do
      tree = MishkaSemiCircleProgress.semi_circle_progress(value: 72)
      stack = tree |> find_all(:box) |> Enum.find(&(&1.props[:width] == 140))

      assert stack.props.align == :center
      assert stack.props.height == 76
      assert Enum.map(stack.children, & &1.type) == [:canvas, :text]
    end

    test "value_text overrides the percentage" do
      assert [%{props: %{text: "3 / 5"}}] = readouts(%{value: 3, max: 5, value_text: "3 / 5"})
    end

    test "scales with the gauge, and uses font_weight rather than a dead weight" do
      [small] = readouts(%{value: 1, size: 100})
      [large] = readouts(%{value: 1, size: 200})

      assert large.props.text_size > small.props.text_size
      # `weight` on a Text is read by the parent as LAYOUT weight and does
      # nothing to the font; the bridges read `font_weight`.
      assert large.props.font_weight == :semibold
      refute Map.has_key?(large.props, :weight)
    end

    test "an optional label renders beneath the gauge as a real node" do
      tree = MishkaSemiCircleProgress.semi_circle_progress(value: 1, label: "BATTERY")

      assert text(tree) =~ "BATTERY"
    end

    test "each part is centred by its own Box, since a Column cannot align" do
      tree = MishkaSemiCircleProgress.semi_circle_progress(value: 1, label: "BATTERY")
      boxes = find_all(tree, :box)

      assert boxes != []
      assert Enum.all?(boxes, &(&1.props[:align] == :center))
      assert Enum.all?(find_all(tree, :column), &(&1.props[:align] == nil))
    end
  end

  test "expand/3 delegates to semi_circle_progress/1" do
    assert MishkaSemiCircleProgress.expand(%{value: 1}, [], %{screen: self()}) ==
             MishkaSemiCircleProgress.semi_circle_progress(value: 1)
  end

  test "every variant renders" do
    variants = [
      %{},
      %{value: 72},
      %{value: 3, max: 5, value_text: "3/5"},
      %{value: 50, label: "BATTERY", size: 200, thickness: 16},
      %{value: "72"}
    ]

    for props <- variants do
      # `canvas` is not in priv/tags/*.txt, so it has to be declared as extra.
      assert_renderable(MishkaSemiCircleProgress.semi_circle_progress(props), extra: [:canvas])
    end
  end
end
