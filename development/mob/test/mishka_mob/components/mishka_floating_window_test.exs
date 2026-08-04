defmodule MishkaMob.Components.MishkaFloatingWindowTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaFloatingIndicator, MishkaFloatingWindow}

  doctest MishkaMob.Components.MishkaFloatingWindow
  doctest MishkaMob.Components.MishkaFloatingIndicator

  # The stage every drag test folds against, and the window inside it.
  @stage {300, 220}
  @window %{x: 20, y: 10, width: 200, height: 120, bounds: @stage, id: "win"}

  defp taps(tree),
    do: tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

  defp tagged(tree, id), do: tree |> flatten() |> Enum.find(&(&1.props[:id] == id))

  # The title's own box, inside the strip's row and past the leading gutter.
  defp title_box(tree) do
    [row] = tagged(tree, "win-handle").children

    Enum.at(row.children, 1)
  end

  describe "nudge/2" do
    test "up subtracts, because screen y grows downwards" do
      assert MishkaFloatingWindow.nudge(%{x: 40, y: 40, step: 10}, :up) == {40, 30}
      assert MishkaFloatingWindow.nudge(%{x: 40, y: 40, step: 10}, :down) == {40, 50}
    end

    test "left and right move x, leaving y alone" do
      assert MishkaFloatingWindow.nudge(%{x: 40, y: 40, step: 10}, :left) == {30, 40}
      assert MishkaFloatingWindow.nudge(%{x: 40, y: 40, step: 10}, :right) == {50, 40}
    end

    test "step is read from the props — it used to be documented and ignored" do
      assert MishkaFloatingWindow.nudge(%{x: 0, y: 0, step: 5}, :right) == {5, 0}
      assert MishkaFloatingWindow.nudge(%{x: 0, y: 0, step: 50}, :right) == {50, 0}
    end

    test "the default step is 20" do
      assert MishkaFloatingWindow.nudge(%{x: 0, y: 40}, :up) == {0, 20}
    end

    test "bounds clamp the near edge at zero" do
      assert MishkaFloatingWindow.nudge(%{x: 0, y: 0, bounds: @stage}, :left) == {0, 0}
      assert MishkaFloatingWindow.nudge(%{x: 0, y: 0, bounds: @stage}, :up) == {0, 0}
    end

    test "the far edge is the stage MINUS the window, not the stage" do
      # A 300 wide stage and a 200 wide window: it stops at 100, with its right
      # edge on the stage's. Clamping to the stage itself would let it walk
      # two-thirds of the way out of view.
      props = Map.merge(@window, %{x: 95, y: 95, step: 20})

      assert MishkaFloatingWindow.nudge(props, :right) == {100, 95}
      assert MishkaFloatingWindow.nudge(props, :down) == {95, 100}
    end

    test "a window bigger than its stage is pinned at the origin rather than negative" do
      props = %{x: 0, y: 0, width: 400, height: 400, bounds: @stage}

      assert MishkaFloatingWindow.nudge(props, :right) == {0, 0}
      assert MishkaFloatingWindow.nudge(props, :down) == {0, 0}
    end

    test "without bounds it is unbounded, including negative" do
      assert MishkaFloatingWindow.nudge(%{x: 0, y: 0, step: 10}, :left) == {-10, 0}
    end

    test "an unknown direction is a no-op rather than an error" do
      assert MishkaFloatingWindow.nudge(%{x: 5, y: 5}, :sideways) == {5, 5}
    end

    test "repeated nudges accumulate and settle against the edge" do
      final =
        Enum.reduce(1..20, {0, 0}, fn _, {x, y} ->
          MishkaFloatingWindow.nudge(Map.merge(@window, %{x: x, y: y}), :right)
        end)

      assert final == {100, 0}
    end

    test "takes a keyword list too, since that is how a screen keeps its props" do
      assert MishkaFloatingWindow.nudge([x: 10, y: 10, step: 10], :right) == {20, 10}
    end
  end

  describe "drag/3" do
    test "a touch on the title bar takes hold, remembering where" do
      {position, grab} =
        MishkaFloatingWindow.drag(%{phase: :began, x: 60.0, y: 30.0}, nil, @window)

      # Nothing moves on :began — the anchor is the whole point, so the window
      # does not jump to centre itself under the finger.
      assert position == {20, 10}
      assert grab.offset == {40.0, 20.0}
    end

    test "a touch below the title bar engages nothing" do
      # A 48dp bar starting at y 10, so 58 is the last row that grabs.
      assert {_, grab} =
               MishkaFloatingWindow.drag(%{phase: :began, x: 60.0, y: 57.0}, nil, @window)

      assert grab

      assert MishkaFloatingWindow.drag(%{phase: :began, x: 60.0, y: 59.0}, nil, @window) ==
               {{20, 10}, nil}
    end

    test "a touch beside the window engages nothing" do
      for x <- [10.0, 240.0] do
        assert MishkaFloatingWindow.drag(%{phase: :began, x: x, y: 30.0}, nil, @window) ==
                 {{20, 10}, nil}
      end
    end

    test "dragging carries the grab offset, so the bar does not jump under the finger" do
      {_, grab} = MishkaFloatingWindow.drag(%{phase: :began, x: 60.0, y: 30.0}, nil, @window)

      {position, held} =
        MishkaFloatingWindow.drag(%{phase: :dragging, x: 90.0, y: 50.0}, grab, @window)

      assert position == {50.0, 30.0}
      assert held == grab
    end

    test "a drag that never took hold moves nothing" do
      assert MishkaFloatingWindow.drag(%{phase: :dragging, x: 200.0, y: 200.0}, nil, @window) ==
               {{20, 10}, nil}
    end

    test "the end of a drag clears the grab and keeps the position" do
      grab = %{offset: {40.0, 20.0}}

      assert MishkaFloatingWindow.drag(%{phase: :ended, x: 90.0, y: 50.0}, grab, @window) ==
               {{50.0, 30.0}, nil}
    end

    test "the position is clamped to the stage minus the window while dragging" do
      grab = %{offset: {0.0, 0.0}}

      assert {{100, 100}, _} =
               MishkaFloatingWindow.drag(%{phase: :dragging, x: 400.0, y: 400.0}, grab, @window)

      assert {{0, 0}, _} =
               MishkaFloatingWindow.drag(%{phase: :dragging, x: -50.0, y: -50.0}, grab, @window)
    end

    test "phase arrives as an ATOM, and a string is accepted too" do
      # Comparing the atom against "began" matched nothing, fell through to the
      # :dragging default, and the anchor was never set — the window looked
      # completely dead while the arithmetic was fine.
      atom = MishkaFloatingWindow.drag(%{phase: :began, x: 60.0, y: 30.0}, nil, @window)
      string = MishkaFloatingWindow.drag(%{phase: "began", x: 60.0, y: 30.0}, nil, @window)

      assert atom == string
      assert {_, %{offset: _}} = atom

      assert MishkaFloatingWindow.drag(
               %{phase: "ended", x: 90.0, y: 50.0},
               %{offset: {0.0, 0.0}},
               @window
             ) == {{90.0, 50.0}, nil}
    end

    test "a phase we do not recognise is treated as a move, not as an anchor" do
      grab = %{offset: {0.0, 0.0}}

      assert {{90.0, 50.0}, ^grab} =
               MishkaFloatingWindow.drag(%{phase: :whatever, x: 90.0, y: 50.0}, grab, @window)
    end

    test "reads x/y and ignores dx/dy" do
      # dx/dy are cumulative translation on iOS and per-sample deltas on
      # Android, so a fold built on them drifts on exactly one platform.
      grab = %{offset: {0.0, 0.0}}
      plain = MishkaFloatingWindow.drag(%{phase: :dragging, x: 60.0, y: 40.0}, grab, @window)

      lying =
        MishkaFloatingWindow.drag(
          %{phase: :dragging, x: 60.0, y: 40.0, dx: 999.0, dy: -999.0},
          grab,
          @window
        )

      assert plain == lying
      assert {{60.0, 40.0}, _} = plain
    end

    test "string keys survive a trip across a wire" do
      assert MishkaFloatingWindow.drag(
               %{"phase" => "began", "x" => 60.0, "y" => 30.0},
               nil,
               @window
             ) == MishkaFloatingWindow.drag(%{phase: :began, x: 60.0, y: 30.0}, nil, @window)
    end

    test "a payload missing its coordinates reads them as zero rather than crashing" do
      assert {_, nil} = MishkaFloatingWindow.drag(%{phase: :began}, nil, @window)
    end

    test "a round trip returns the window to where it started" do
      {_, grab} = MishkaFloatingWindow.drag(%{phase: :began, x: 60.0, y: 30.0}, nil, @window)

      {out, grab} =
        MishkaFloatingWindow.drag(%{phase: :dragging, x: 120.0, y: 60.0}, grab, @window)

      {back, nil} = MishkaFloatingWindow.drag(%{phase: :ended, x: 60.0, y: 30.0}, grab, @window)

      refute out == back
      assert back == {20.0, 10.0}
    end

    test "takes its props as a keyword list too" do
      props = Keyword.new(@window)

      assert {_, %{offset: {40.0, 20.0}}} =
               MishkaFloatingWindow.drag(%{phase: :began, x: 60.0, y: 30.0}, nil, props)
    end
  end

  describe "the drag surface" do
    test "is one static canvas the size of the stage" do
      tree = MishkaFloatingWindow.floating_window(Map.put(@window, :on_move, :move))
      canvas = find(tree, :canvas)

      # Static and stage-sized is the whole design: a canvas riding on the
      # window is a ruler sliding under the finger, and a canvas declared wider
      # than the space it gets has MobCanvas scale every op to fit.
      assert {canvas.props.width, canvas.props.height} == @stage
      assert {tree.props.width, tree.props.height} == @stage
    end

    test "carries on_drag, which only a :canvas can" do
      tree = MishkaFloatingWindow.floating_window(Map.put(@window, :on_move, :move))

      assert find(tree, :canvas).props.on_drag == {self(), :move}
    end

    test "is laid over the panel, so nothing opaque can block the gesture" do
      tree = MishkaFloatingWindow.floating_window(Map.put(@window, :on_move, :move))

      assert [:box, :canvas | _] = Enum.map(tree.children, & &1.type)
    end

    test "draws a filled rect — Mob.Canvas.rect STROKES by default" do
      tree = MishkaFloatingWindow.floating_window(Map.put(@window, :on_move, :move))

      assert [op] = find(tree, :canvas).props.draw
      assert op.fill == true
    end

    test "no bounds, no drag: the canvas has no honest size to be declared at" do
      tree = MishkaFloatingWindow.floating_window(%{x: 1, y: 2, on_move: :move, bounds: nil})

      refute find(tree, :canvas)
      assert tree.props.fill_width
    end

    test "no on_move, no drag surface — and then the body still takes taps" do
      refute find(MishkaFloatingWindow.floating_window(@window), :canvas)
    end

    test "is addressable by id, being a drawing with no text to query" do
      tree = MishkaFloatingWindow.floating_window(Map.put(@window, :on_move, :move))

      assert tagged(tree, "win-drag").type == :canvas
    end
  end

  describe "rendering" do
    test "the panel is positioned by offset and sized as a fixed rectangle" do
      panel = tagged(MishkaFloatingWindow.floating_window(@window), "win-window")

      assert {panel.props.offset_x, panel.props.offset_y} == {20, 10}
      assert {panel.props.width, panel.props.height} == {200, 120}
    end

    test "the defaults are a 260 by 180 window at the origin" do
      panel = tagged(MishkaFloatingWindow.floating_window(%{id: "w"}), "w-window")

      assert {panel.props.offset_x, panel.props.offset_y} == {0, 0}
      assert {panel.props.width, panel.props.height} == {260, 180}
    end

    test "the title bar shows the label; the body shows the children" do
      body = [%{type: :text, props: %{text: "contents"}, children: []}]
      tree = MishkaFloatingWindow.floating_window(%{label: "Inspector"}, body)

      assert text(tree) =~ "Inspector"
      assert text(tree) =~ "contents"
    end

    test "the title stops where the ✕ starts" do
      # The ✕ is an overlay at a computed offset, not a sibling of the label —
      # it has to be, to sit above the canvas — so a long title would run
      # underneath it if the row did not reserve the space.
      bare = title_box(MishkaFloatingWindow.floating_window(@window))
      closable = title_box(MishkaFloatingWindow.floating_window(Map.put(@window, :on_close, :c)))

      assert bare.props.width == 200 - 12 - 12
      assert closable.props.width == 200 - 12 - 48
    end

    test "a handle node replaces the label" do
      bar = %{type: :text, props: %{text: "build.log"}, children: []}
      tree = MishkaFloatingWindow.floating_window(%{label: "ignored", handle: bar})

      assert text(tree) =~ "build.log"
      refute text(tree) =~ "ignored"
    end

    test "the body starts below the chrome, and the chrome grows with the arrows" do
      plain = MishkaFloatingWindow.floating_window(@window)
      with_arrows = MishkaFloatingWindow.floating_window(Map.put(@window, :on_move, :move))

      assert tagged(plain, "win-body").props.offset_y == 10 + 48
      assert tagged(with_arrows, "win-body").props.offset_y == 10 + 96

      # Whatever the chrome takes, the body gets the rest of `height`.
      assert tagged(plain, "win-body").props.height == 120 - 48
      assert tagged(with_arrows, "win-body").props.height == 120 - 96
    end

    test "a window shorter than its own chrome gets a zero-height body, not a negative one" do
      tree = MishkaFloatingWindow.floating_window(%{id: "w", height: 20})

      assert tagged(tree, "w-body").props.height == 0
    end

    test "the body is a layer of its own, above the drag surface" do
      tree = MishkaFloatingWindow.floating_window(Map.put(@window, :on_move, :move))
      types = Enum.map(tree.children, & &1.type)
      body_index = Enum.find_index(tree.children, &(&1.props[:id] == "win-body"))

      # Anything a finger must tap has to sit above the canvas: the canvas
      # consumes the touch that starts on it, and on iOS a view with a
      # background blocks the gesture of the sibling beneath it.
      assert body_index > Enum.find_index(types, &(&1 == :canvas))
    end

    test "the close button appears only when wired, at the end of the title bar" do
      refute text(MishkaFloatingWindow.floating_window(%{})) =~ "✕"

      closable = MishkaFloatingWindow.floating_window(Map.put(@window, :on_close, :close))
      close = tagged(closable, "win-close")

      assert text(closable) =~ "✕"
      assert close.props.on_tap == {self(), :close}
      assert {close.props.offset_x, close.props.offset_y} == {20 + 200 - 48, 10}
      assert {close.props.width, close.props.height} == {48, 48}
    end

    test "each arrow reports its own direction" do
      tree = MishkaFloatingWindow.floating_window(Map.put(@window, :on_move, :move))

      for direction <- [:up, :down, :left, :right] do
        assert {self(), {:move, direction}} in taps(tree)
      end
    end

    test "the arrows are 48dp targets, laid along the row under the title bar" do
      tree = MishkaFloatingWindow.floating_window(Map.put(@window, :on_move, :move))

      arrows =
        for direction <- [:left, :up, :down, :right], do: tagged(tree, "win-nudge-#{direction}")

      # 4dp of padding round a glyph is about 20dp of target, which is a miss
      # more often than a tap. Material asks for 48.
      assert Enum.all?(arrows, &({&1.props.width, &1.props.height} == {48, 48}))
      assert Enum.map(arrows, & &1.props.offset_x) == [20, 68, 116, 164]
      assert Enum.all?(arrows, &(&1.props.offset_y == 10 + 48))
    end

    test "the arrows can be turned off while the drag stays" do
      tree =
        MishkaFloatingWindow.floating_window(
          Map.merge(@window, %{show_nudges: false, on_move: :move})
        )

      refute tagged(tree, "win-nudge-up")
      assert find(tree, :canvas)
    end

    test "an unwired arrow renders nothing at all" do
      # A control that renders perfectly and does nothing is the worst kind of
      # bug: invisible until a human taps it.
      tree = MishkaFloatingWindow.floating_window(Map.put(@window, :show_nudges, true))

      refute tagged(tree, "win-nudge-up")
      assert taps(tree) == []
    end

    test "the drag state is in the handle's tag, because a test cannot read a colour" do
      idle = MishkaFloatingWindow.floating_window(@window)
      held = MishkaFloatingWindow.floating_window(Map.put(@window, :dragging, true))

      assert tagged(idle, "win-handle").props.background == :surface_raised
      assert tagged(held, "win-handle-dragging").props.background == :primary
      refute tagged(held, "win-handle")
    end

    test "the label takes the ink that reads against the strip it sits on" do
      held =
        MishkaFloatingWindow.floating_window(Map.merge(@window, %{label: "W", dragging: true}))

      label = held |> find_all(:text) |> Enum.find(&(&1.props.text == "W"))

      # `font_weight`, not `weight` — the bridges read the former for typography,
      # and the latter is a parent layout weight that styles nothing.
      assert label.props.text_color == :on_primary
      assert label.props.font_weight == :semibold
      assert label.props.max_lines == 1
    end

    test "without an id nothing is tagged, and nothing crashes" do
      tree =
        MishkaFloatingWindow.floating_window(%{bounds: @stage, on_move: :move, on_close: :close})

      assert tree |> flatten() |> Enum.all?(&(&1.props[:id] == nil))
    end

    test "the root carries the id itself, like the web root does" do
      assert MishkaFloatingWindow.floating_window(@window).props.id == "win"
    end
  end

  describe "chrome_height/1" do
    test "is the title bar, plus the arrow row when there is one" do
      assert MishkaFloatingWindow.chrome_height(%{}) == 48
      assert MishkaFloatingWindow.chrome_height(%{on_move: :move}) == 96
      assert MishkaFloatingWindow.chrome_height(%{on_move: :move, show_nudges: false}) == 48
      assert MishkaFloatingWindow.chrome_height(on_move: :move) == 96
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
    bar = %{type: :text, props: %{text: "bar"}, children: []}

    for tree <- [
          MishkaFloatingWindow.floating_window(),
          MishkaFloatingWindow.floating_window(@window),
          MishkaFloatingWindow.floating_window(
            Map.merge(@window, %{label: "W", on_close: :c, on_move: :m, dragging: true})
          ),
          MishkaFloatingWindow.floating_window(Map.merge(@window, %{handle: bar, height: 10})),
          MishkaFloatingWindow.floating_window(%{show_nudges: false, on_move: :m}),
          MishkaFloatingIndicator.floating_indicator(),
          MishkaFloatingIndicator.floating_indicator(targets: @targets, active: :day),
          MishkaFloatingIndicator.floating_indicator(
            targets: @targets,
            orientation: :vertical,
            disabled: true
          )
        ] do
      # extra: [:canvas] — the drag surface is a canvas, and `:canvas` is not in
      # mob's priv/tags lists even though both bridges render one.
      assert_renderable(tree, extra: [:canvas])
    end
  end
end
