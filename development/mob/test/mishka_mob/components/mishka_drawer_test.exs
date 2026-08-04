defmodule MishkaMob.Components.MishkaDrawerTest do
  # Unit tests for the Drawer composite. `use Mob.ScreenCase` is borrowed purely
  # for its tree queries (find / flatten / text / assert_renderable), which all
  # accept a raw `%{type:, ...}` node map — no screen needed.
  use Mob.ScreenCase, async: true

  import ExUnit.CaptureLog

  alias MishkaMob.Components.MishkaDrawer

  doctest MishkaMob.Components.MishkaDrawer

  @scrim 0x99_00_00_00

  # Built at call time so `self()` is the test process (not the module loader).
  defp ctx, do: %{screen: self()}

  defp body,
    do: [%{type: :button, props: %{text: "Profile", on_tap: {self(), :profile}}, children: []}]

  # A slot marker as the sigil builds one: no module, no expander, and its
  # subtree intact. Written by hand rather than through ~MOB so the test states
  # the exact node the parent has to recognise.
  defp trigger_tag(props), do: trigger_tag(props, [])

  defp trigger_tag(props, children),
    do: %{type: :mishka_drawer_trigger, props: props, children: children}

  # Realistic open props: an open drawer normally has an on_close dismiss path.
  defp p(extra \\ %{}), do: Map.merge(%{open: true, on_close: {self(), :close}}, extra)

  # Every node in the tree carrying an :id, as a plain list of tags.
  defp tags(tree) do
    tree |> flatten() |> Enum.map(&Map.get(&1.props, :id)) |> Enum.reject(&is_nil/1)
  end

  defp tagged(tree, id), do: Enum.find(flatten(tree), &(Map.get(&1.props, :id) == id))

  # The header row, found by the ✕ sitting DIRECTLY in it — `find(tree, :row)`
  # would return the positioner, which is also a fill-width row, comes first,
  # and contains the header (and so the ✕) somewhere below it.
  defp header(tree) do
    Enum.find(flatten(tree), fn node ->
      node.type == :row and Enum.any?(node.children, &(&1.type == :button))
    end)
  end

  # A whole gesture in one call: down at `from`, up at `to`, in the axis the
  # side implies. Returns the settled state.
  defp gesture(from, to, props) do
    props = Map.new(props)
    axis = if Map.get(props, :side, :right) in [:top, :bottom], do: :y, else: :x

    {_, grab} = MishkaDrawer.swipe(%{axis => from, phase: :began}, nil, props)
    {state, nil} = MishkaDrawer.swipe(%{axis => to, phase: :ended}, grab, props)
    state
  end

  describe "closed" do
    test "renders nothing when open is false or absent" do
      empty = %{type: :column, props: %{}, children: []}
      assert MishkaDrawer.expand(%{open: false}, [], ctx()) == empty
      assert MishkaDrawer.expand(%{}, [], ctx()) == empty
    end

    test "swipe_area renders an edge patch instead of nothing" do
      tree = MishkaDrawer.expand(%{open: false, swipe_area: true, side: :left}, [], ctx())

      canvas = find(tree, :canvas)
      assert canvas.props.width == 16
      assert canvas.props.height == 320
    end

    test "the swipe area is pinned to the drawer's own edge" do
      left = MishkaDrawer.expand(%{open: false, swipe_area: true, side: :left}, [], ctx())
      right = MishkaDrawer.expand(%{open: false, swipe_area: true, side: :right}, [], ctx())

      # Left puts the patch before the filler, right puts it after — the same
      # positioner rule the open panel follows.
      assert %{children: [%{type: :column}, %{type: :spacer}]} =
               find(left, :row, fill_width: true)

      assert %{children: [%{type: :spacer}, %{type: :column}]} =
               find(right, :row, fill_width: true)
    end

    test "a horizontal swipe area is laid out across the edge, not along it" do
      tree = MishkaDrawer.expand(%{open: false, swipe_area: true, side: :bottom}, [], ctx())

      canvas = find(tree, :canvas)
      assert canvas.props.width == 320
      assert canvas.props.height == 16
    end

    test "the swipe area carries on_swipe as a canvas drag" do
      tree =
        MishkaDrawer.expand(
          %{open: false, swipe_area: true, side: :left, on_swipe: {self(), :edge}},
          [],
          ctx()
        )

      assert find(tree, :canvas).props.on_drag == {self(), :edge}
    end

    test "a closed drawer with no swipe area has no test tags at all" do
      tree = MishkaDrawer.expand(%{open: false, id: "menu"}, [], ctx())
      assert tags(tree) == []
    end
  end

  describe "open" do
    test "root is a fill Box stacking scrim + panel" do
      tree = MishkaDrawer.expand(p(%{side: :right}), body(), ctx())

      assert %{
               type: :box,
               props: %{fill_width: true, fill_height: true},
               children: [%{type: :box}, %{type: :row}]
             } = tree
    end

    test "scrim is a translucent Box that dismisses on tap" do
      tree = MishkaDrawer.expand(p(), body(), ctx())

      assert %{props: %{on_tap: {pid, :close}}} = find(tree, :box, background: @scrim)
      assert pid == self()
    end

    test "left/right panel is a fixed-width Box sized from :size" do
      for {size, px} <- [xs: 240, sm: 256, md: 288, lg: 320, xl: 384] do
        tree = MishkaDrawer.expand(p(%{side: :left, size: size}), body(), ctx())
        assert find(tree, :box, width: px), "expected a #{px}px panel for size #{size}"
      end
    end

    test "size defaults to :lg (320)" do
      tree = MishkaDrawer.expand(p(%{side: :right}), body(), ctx())
      assert find(tree, :box, width: 320)
    end

    test "panel width is exact — padding sits on the inner column, not the width-locked Box" do
      tree = MishkaDrawer.expand(p(%{side: :right, size: :lg}), body(), ctx())
      box = find(tree, :box, width: 320)

      refute Map.has_key?(box.props, :padding)

      assert %{children: [%{type: :column, props: %{padding: :space_lg, fill_height: true}}]} =
               box
    end

    test "right drawer pushes the panel with a leading Spacer" do
      tree = MishkaDrawer.expand(p(%{side: :right}), body(), ctx())

      assert %{children: [%{type: :spacer}, %{type: :box, props: %{width: 320}}]} =
               find(tree, :row, fill_width: true)
    end

    test "left drawer pushes the panel with a trailing Spacer" do
      tree = MishkaDrawer.expand(p(%{side: :left}), body(), ctx())

      assert %{children: [%{type: :box, props: %{width: 320}}, %{type: :spacer}]} =
               find(tree, :row, fill_width: true)
    end

    test "the push Spacer carries weight:1 so it flexes on Android (not just iOS)" do
      # A size-less Spacer is zero-width on Compose; weight is what makes it
      # fill. Regression guard for the right/bottom-render-at-wrong-edge bug.
      for side <- [:left, :right, :top, :bottom] do
        tree = MishkaDrawer.expand(p(%{side: side}), body(), ctx())

        spacer =
          Enum.find(flatten(tree), &(&1.type == :spacer and Map.get(&1.props, :weight) == 1))

        assert spacer, "expected a weight:1 push Spacer for side #{side}"
      end
    end

    test "bottom drawer is a full-width, content-height sheet (no fixed width)" do
      tree = MishkaDrawer.expand(p(%{side: :bottom}), body(), ctx())

      # positioner (child 1) is a fill-height column holding [spacer, panel].
      # The panel is a Column (not a Box) so it fills width on Compose.
      assert %{children: [_scrim, positioner]} = tree

      assert %{
               type: :column,
               props: %{fill_height: true},
               children: [%{type: :spacer}, %{type: :column, props: panel_props}]
             } = positioner

      assert panel_props.fill_width
      refute Map.has_key?(panel_props, :width)
      refute Map.has_key?(panel_props, :height)
    end

    test "scrim_color overrides the backdrop fill" do
      tree = MishkaDrawer.expand(p(%{scrim_color: 0x66_00_00_00}), body(), ctx())
      assert find(tree, :box, background: 0x66_00_00_00)
      refute find(tree, :box, background: @scrim)
    end

    test "padding overrides the inner content padding" do
      tree = MishkaDrawer.expand(p(%{side: :right, padding: :space_sm}), body(), ctx())
      assert find(tree, :column, padding: :space_sm, fill_height: true)
    end

    test "corner_radius rounds the panel Box (and is absent by default)" do
      plain = MishkaDrawer.expand(p(%{side: :right}), body(), ctx())
      refute Map.has_key?(find(plain, :box, width: 320).props, :corner_radius)

      rounded = MishkaDrawer.expand(p(%{side: :right, corner_radius: :radius_lg}), body(), ctx())
      assert %{props: %{corner_radius: :radius_lg}} = find(rounded, :box, width: 320)
    end

    test "header: false suppresses the built-in title + ✕ (custom chrome)" do
      tree = MishkaDrawer.expand(p(%{title: "Menu", header: false}), body(), ctx())

      refute text(tree) =~ "Menu"
      refute find(tree, :button, text: "✕")
      # the caller's body is still rendered, and the backdrop still dismisses
      assert find(tree, :button, text: "Profile")
      assert find(tree, :box, background: @scrim)
    end

    test "renders the title and a ✕ close button wired to on_close" do
      tree = MishkaDrawer.expand(p(%{title: "Menu"}), body(), ctx())

      assert text(tree) =~ "Menu"
      assert %{props: %{on_tap: {pid, :close}}} = find(tree, :button, text: "✕")
      assert pid == self()
    end

    test "the title is capped to one line so it cannot wrap character by character" do
      tree = MishkaDrawer.expand(p(%{title: "A very long drawer title"}), body(), ctx())

      assert find(tree, :text, text: "A very long drawer title").props.max_lines == 1
    end

    test "the title/✕ row gives the title a weighted slot" do
      # Compose measures a Row's unweighted children first, so an unweighted
      # title would claim the whole row and starve the ✕ to nothing.
      tree = MishkaDrawer.expand(p(%{title: "Menu"}), body(), ctx())

      assert %{children: [%{type: :box, props: %{weight: 1}}, %{type: :button}]} = header(tree)
    end

    test "description renders under the title" do
      tree = MishkaDrawer.expand(p(%{title: "Menu", description: "Pick one"}), body(), ctx())

      assert text(tree) =~ "Pick one"
      assert find(tree, :text, text: "Pick one").props.text_color == :muted
    end

    test "a description with no title still renders" do
      tree = MishkaDrawer.expand(p(%{description: "Pick one"}), body(), ctx())
      assert text(tree) =~ "Pick one"
    end

    test "a bare ✕ with no title is pushed to the trailing edge" do
      tree = MishkaDrawer.expand(p(), body(), ctx())

      assert %{children: [%{type: :spacer, props: %{weight: 1}}, %{type: :button}]} = header(tree)
    end

    test "omits the ✕ close button when on_close is absent (no dead control)" do
      {tree, _log} =
        with_log(fn ->
          MishkaDrawer.expand(%{open: true, side: :left, title: "Menu"}, body(), ctx())
        end)

      assert text(tree) =~ "Menu"
      refute find(tree, :button, text: "✕")
    end

    test "warns when opened without a dismiss handler" do
      {_tree, log} = with_log(fn -> MishkaDrawer.expand(%{open: true}, body(), ctx()) end)
      assert log =~ "on_close"
    end

    test "does not warn when a swipe can dismiss it" do
      {_tree, log} =
        with_log(fn ->
          MishkaDrawer.expand(%{open: true, handle: true, on_swipe: :s}, body(), ctx())
        end)

      refute log =~ "MishkaDrawer"
    end

    test "the panel absorbs stray taps so they don't leak to the scrim" do
      tree = MishkaDrawer.expand(p(%{side: :right}), body(), ctx())
      assert %{props: %{on_tap: {pid, :__mishka_drawer_ignore}}} = find(tree, :box, width: 320)
      assert pid == self()
    end

    test "scrim can be disabled" do
      tree = MishkaDrawer.expand(p(%{scrim: false}), body(), ctx())
      refute find(tree, :box, background: @scrim)
    end

    test "dismissible: false keeps the backdrop but makes it absorb instead of close" do
      tree = MishkaDrawer.expand(p(%{dismissible: false}), body(), ctx())
      scrim = find(tree, :box, background: @scrim)

      # It must still absorb: a backdrop with no handler has no hit shape, so
      # taps would fall through to the page behind a supposedly modal panel.
      assert scrim.props.on_tap == {self(), :__mishka_drawer_ignore}
      # …and the ✕ still closes, exactly as `dismissible` governs only the
      # outside click on the web.
      assert %{props: %{on_tap: {_pid, :close}}} = find(tree, :button, text: "✕")
    end

    test "the drawer body children are spliced below the header" do
      tree = MishkaDrawer.expand(p(%{side: :right}), body(), ctx())
      assert find(tree, :button, text: "Profile")
    end
  end

  describe "the drag handle" do
    test "is absent unless asked for" do
      tree = MishkaDrawer.expand(p(%{side: :bottom}), body(), ctx())
      refute find(tree, :canvas)
    end

    test "is a canvas — the only node type that carries on_drag" do
      tree =
        MishkaDrawer.expand(p(%{side: :bottom, handle: true, on_swipe: :sheet}), body(), ctx())

      canvas = find(tree, :canvas)
      assert canvas.props.on_drag == {self(), :sheet}
      assert canvas.props.width == 160
      assert canvas.props.height == 40
    end

    test "renders without a handler when on_swipe is absent, rather than vanishing" do
      tree = MishkaDrawer.expand(p(%{side: :bottom, handle: true}), body(), ctx())

      canvas = find(tree, :canvas)
      refute Map.has_key?(canvas.props, :on_drag)
    end

    test "the pill is drawn filled — Mob.Canvas.rect strokes by default" do
      tree = MishkaDrawer.expand(p(%{side: :bottom, handle: true}), body(), ctx())

      assert [%{op: :rect, fill: true}] = find(tree, :canvas).props.draw
    end

    test "the pill lies across the drag axis, so its shape says which way to pull" do
      sheet = MishkaDrawer.expand(p(%{side: :bottom, handle: true}), body(), ctx())
      side = MishkaDrawer.expand(p(%{side: :right, handle: true}), body(), ctx())

      assert [%{w: wide, h: thin}] = find(sheet, :canvas).props.draw
      assert wide > thin

      assert [%{w: narrow, h: tall}] = find(side, :canvas).props.draw
      assert tall > narrow
    end

    test "handle_color overrides the pill's ink (canvas ops take ints, not tokens)" do
      tree =
        MishkaDrawer.expand(
          p(%{side: :bottom, handle: true, handle_color: 0xFF00FF00}),
          body(),
          ctx()
        )

      assert [%{color: 0xFF00FF00}] = find(tree, :canvas).props.draw
    end

    test "sits at the top of a bottom sheet and at the bottom of a top sheet" do
      # Whichever edge is free — the one a thumb reaches, not the one against
      # the screen edge.
      bottom = MishkaDrawer.expand(p(%{side: :bottom, handle: true}), body(), ctx())
      top = MishkaDrawer.expand(p(%{side: :top, handle: true}), body(), ctx())

      assert %{children: [%{type: :column, props: %{padding: _}, children: bottom_body}]} =
               find(bottom, :column, fill_width: true, background: :surface)

      assert %{children: [%{type: :column, props: %{padding: _}, children: top_body}]} =
               find(top, :column, fill_width: true, background: :surface)

      assert hd(bottom_body).type == :row
      assert find(hd(bottom_body), :canvas)
      assert find(List.last(top_body), :canvas)
    end

    test "is centred by weighted Spacers, which fill on both platforms" do
      tree = MishkaDrawer.expand(p(%{side: :bottom, handle: true}), body(), ctx())
      strip = Enum.find(flatten(tree), &(&1.type == :row and find(&1, :canvas)))

      assert %{
               children: [
                 %{type: :spacer, props: %{weight: 1}},
                 %{type: :canvas},
                 %{type: :spacer, props: %{weight: 1}}
               ]
             } =
               strip
    end
  end

  describe "snap points" do
    @sheet %{side: :bottom, snap_points: [180, 300, 440]}

    test "size the sheet, smallest first by default" do
      tree = MishkaDrawer.expand(p(@sheet), body(), ctx())

      assert find(tree, :column, fill_width: true, height: 180)
    end

    test "snap picks the active height" do
      tree = MishkaDrawer.expand(p(Map.put(@sheet, :snap, 440)), body(), ctx())

      assert find(tree, :column, fill_width: true, height: 440)
    end

    test "the inner column fills the snapped height so padding stays inside it" do
      tree = MishkaDrawer.expand(p(@sheet), body(), ctx())
      panel = find(tree, :column, height: 180)

      assert %{children: [%{type: :column, props: %{fill_height: true, padding: :space_lg}}]} =
               panel
    end

    test "fractions resolve against extent" do
      props = p(%{side: :bottom, snap_points: [0.4, 0.76], extent: 500})
      tree = MishkaDrawer.expand(props, body(), ctx())

      assert find(tree, :column, fill_width: true, height: 200.0)
    end

    test "a fraction with no extent is dropped, loudly" do
      {tree, log} =
        with_log(fn ->
          MishkaDrawer.expand(p(%{side: :bottom, snap_points: [0.4]}), body(), ctx())
        end)

      assert log =~ "extent"

      refute Map.has_key?(
               find(tree, :column, fill_width: true, background: :surface).props,
               :height
             )
    end

    test "are ignored on a side drawer, which is sized by :size" do
      tree = MishkaDrawer.expand(p(%{side: :left, snap_points: [180, 300]}), body(), ctx())

      panel = find(tree, :box, width: 320)
      refute Map.has_key?(panel.props, :height)
    end
  end

  describe "test tags" do
    @tagged %{
      id: "sheet",
      side: :bottom,
      title: "Filters",
      description: "Narrow it down",
      handle: true,
      snap_points: [180, 300],
      on_swipe: :sheet
    }

    test "every part of an open drawer is addressable" do
      tree = MishkaDrawer.expand(p(@tagged), body(), ctx())

      for tag <- ~w(sheet sheet-scrim sheet-panel sheet-title sheet-description sheet-close
                    sheet-handle) do
        assert tagged(tree, tag), "expected a node tagged #{tag}"
      end
    end

    test "the active snap point rides in a tag, because a height cannot be read as an index" do
      first = MishkaDrawer.expand(p(@tagged), body(), ctx())
      second = MishkaDrawer.expand(p(Map.put(@tagged, :snap, 300)), body(), ctx())

      assert tagged(first, "sheet-snap-1")
      refute tagged(first, "sheet-snap-2")
      assert tagged(second, "sheet-snap-2")
    end

    test "the snap tag sits on the handle's row, so the handle's own tag stays stable" do
      tree = MishkaDrawer.expand(p(@tagged), body(), ctx())

      assert tagged(tree, "sheet-handle").type == :canvas
      assert tagged(tree, "sheet-snap-1").type == :row
    end

    test "a drawer with no snap points has no snap tag" do
      tree = MishkaDrawer.expand(p(%{id: "menu", handle: true}), body(), ctx())

      refute Enum.any?(tags(tree), &String.contains?(&1, "-snap-"))
    end

    test "the swipe area is addressable while the drawer is closed" do
      tree = MishkaDrawer.expand(%{id: "edge", open: false, swipe_area: true}, [], ctx())

      assert tagged(tree, "edge-swipe-area").type == :canvas
    end

    test "no id means no tags — nothing is invented" do
      tree = MishkaDrawer.expand(p(%{title: "Menu", handle: true}), body(), ctx())
      assert tags(tree) == []
    end

    test "the root tag is the open/closed signal, since a closed drawer draws nothing" do
      open = MishkaDrawer.expand(p(%{id: "menu"}), body(), ctx())
      closed = MishkaDrawer.expand(%{id: "menu", open: false}, body(), ctx())

      assert tagged(open, "menu")
      refute tagged(closed, "menu")
    end
  end

  describe "trigger/2" do
    test "a string builds a button wired to on_open" do
      node = MishkaDrawer.trigger("Open", on_open: :open_menu, test_id: "menu-trigger")

      assert node.type == :button
      assert node.props.text == "Open"
      assert node.props.on_tap == {self(), :open_menu}
      assert node.props.id == "menu-trigger"
    end

    test "a list of nodes builds a tappable Box around them" do
      children = [%{type: :text, props: %{text: "Account"}, children: []}]
      node = MishkaDrawer.trigger(children, on_open: :open_menu)

      assert node.type == :box
      assert node.children == children
      assert node.props.on_tap == {self(), :open_menu}
    end

    test "an already-wired target is left alone" do
      node = MishkaDrawer.trigger("Open", on_open: {self(), :open_menu})
      assert node.props.on_tap == {self(), :open_menu}
    end

    test "with no on_open it is inert rather than broken" do
      node = MishkaDrawer.trigger("Open")

      refute Map.has_key?(node.props, :on_tap)
      refute Map.has_key?(node.props, :id)
    end

    test "weight is opt-in — a weighted button alone in a column collapses" do
      refute Map.has_key?(MishkaDrawer.trigger("Open").props, :weight)
      assert MishkaDrawer.trigger("Open", weight: 1).props.weight == 1
    end
  end

  describe "slot tags" do
    test "the trigger tag builds exactly the node trigger/2 builds" do
      tag =
        trigger_tag(%{label: "Open", on_open: :open_menu, id: "menu-trigger", weight: 1})

      assert MishkaDrawer.expand(%{open: false}, [tag], ctx()) ==
               MishkaDrawer.trigger("Open",
                 on_open: :open_menu,
                 test_id: "menu-trigger",
                 weight: 1
               )
    end

    test "a trigger tag with children builds the tappable-Box form, node for node" do
      children = [%{type: :text, props: %{text: "Account"}, children: []}]
      tag = trigger_tag(%{on_open: :open_menu}, children)

      assert MishkaDrawer.expand(%{open: false}, [tag], ctx()) ==
               MishkaDrawer.trigger(children, on_open: :open_menu)
    end

    test "the tag's on_open is wired by the PARENT — a marker's props are not auto-wired" do
      # Mob.Composite widens the tag it dispatches on, and a slot tag has no
      # expander to dispatch to, so `on_open` arrives as the bare atom it was
      # written as. Composing it by hand would give {{pid, tag}, …}.
      tree =
        MishkaDrawer.expand(%{open: false}, [trigger_tag(%{label: "Open", on_open: :go})], ctx())

      assert tree.props.on_tap == {self(), :go}
    end

    test "two triggers share a Column rather than one of them being dropped" do
      tags = [
        trigger_tag(%{label: "One", on_open: :a}),
        trigger_tag(%{label: "Two", on_open: :b})
      ]

      tree = MishkaDrawer.expand(%{open: false}, tags, ctx())

      # A Button carries its label in props rather than in a Text child, so the
      # labels are read from there rather than through text/1.
      assert %{type: :column, children: [first, second]} = tree
      assert {first.props.text, second.props.text} == {"One", "Two"}
      assert {first.props.on_tap, second.props.on_tap} == {{self(), :a}, {self(), :b}}
    end

    test "the trigger is what a CLOSED drawer draws, and an open one draws the panel instead" do
      tag = trigger_tag(%{label: "Open", on_open: :go, id: "menu-open"})

      closed = MishkaDrawer.expand(%{open: false, id: "menu"}, [tag | body()], ctx())
      open = MishkaDrawer.expand(p(%{id: "menu"}), [tag | body()], ctx())

      assert tagged(closed, "menu-open")
      refute tagged(closed, "menu-panel")

      # While open the panel covers the page, so there is nothing for a trigger
      # to do and nothing it could be tapped through.
      refute tagged(open, "menu-open")
      assert tagged(open, "menu-panel")
    end

    test "a trigger beats the swipe area, which wants the screen edge rather than the flow" do
      tag = trigger_tag(%{label: "Open", on_open: :go})
      tree = MishkaDrawer.expand(%{open: false, swipe_area: true, side: :left}, [tag], ctx())

      assert tree.type == :button
      refute find(tree, :canvas)
    end

    test "the footer tag and footer/1 are the same node, so the two forms expand alike" do
      rows = [%{type: :button, props: %{text: "Done", on_tap: {self(), :done}}, children: []}]
      tag = %{type: :mishka_drawer_footer, props: %{}, children: rows}

      assert MishkaDrawer.footer(rows) == tag

      assert MishkaDrawer.expand(p(), [tag], ctx()) ==
               MishkaDrawer.expand(p(), [MishkaDrawer.footer(rows)], ctx())
    end

    test "footer/1 takes one node or a bare string as well as a list" do
      row = %{type: :button, props: %{text: "Done"}, children: []}

      assert MishkaDrawer.footer(row).children == [row]

      tree = MishkaDrawer.expand(p(), [MishkaDrawer.footer("Signed in as shahryar")], ctx())
      assert text(tree) =~ "Signed in as shahryar"
      assert find(tree, :text, text: "Signed in as shahryar").props.text_color == :muted
    end

    test "the footer is the panel's last block, below the caller's body" do
      tree =
        MishkaDrawer.expand(
          p(%{id: "sheet", side: :bottom}),
          body() ++ [MishkaDrawer.footer([%{type: :text, props: %{text: "Bye"}, children: []}])],
          ctx()
        )

      block = tagged(tree, "sheet-footer")
      assert block.type == :column
      assert text(block) == "Bye"

      # …and it is genuinely last: the body button comes before it.
      panel = find(tree, :column, fill_width: true, background: :surface)
      assert %{children: [%{children: inner}]} = panel
      assert List.last(inner) == block
    end

    test "a panel with a determined height pushes its footer to the floor" do
      footer = MishkaDrawer.footer([%{type: :text, props: %{text: "Bye"}, children: []}])

      # A side drawer is full-height, and so is a sheet parked on a snap point.
      for props <- [%{side: :left}, %{side: :bottom, snap_points: [180, 300]}] do
        tree = MishkaDrawer.expand(p(props), body() ++ [footer], ctx())
        column = Enum.find(flatten(tree), &(&1.type == :column and Map.get(&1.props, :padding)))

        assert Enum.any?(
                 column.children,
                 &(&1.type == :spacer and Map.get(&1.props, :weight) == 1)
               ),
               "expected a pushing Spacer for #{inspect(props)}"
      end
    end

    test "a hugging sheet does not push — an iOS Spacer would stretch it open" do
      footer = MishkaDrawer.footer([%{type: :text, props: %{text: "Bye"}, children: []}])
      tree = MishkaDrawer.expand(p(%{side: :bottom}), body() ++ [footer], ctx())

      column = Enum.find(flatten(tree), &(&1.type == :column and Map.get(&1.props, :padding)))

      refute Enum.any?(column.children, &(&1.type == :spacer and Map.get(&1.props, :weight) == 1))
    end

    test "no id means no footer tag, exactly like every other part" do
      tree = MishkaDrawer.expand(p(), [MishkaDrawer.footer("Bye")], ctx())
      assert tags(tree) == []
    end

    test "no slot marker survives expansion — the leak would be silent" do
      # A marker that reaches the renderer draws NOTHING and says nothing: the
      # tag names are whitelisted in mix.exs, so assert_renderable passes them.
      children =
        [
          trigger_tag(%{label: "Open", on_open: :go}) | body()
        ] ++ [MishkaDrawer.footer("Bye")]

      for props <- [p(), %{open: false}, %{open: false, swipe_area: true}] do
        tree = MishkaDrawer.expand(props, children, ctx())

        assert find_all(tree, :mishka_drawer_trigger) == []
        assert find_all(tree, :mishka_drawer_footer) == []
      end
    end

    test "slot_types/0 names every marker the drawer claims" do
      assert MishkaDrawer.slot_types() == [:mishka_drawer_trigger, :mishka_drawer_footer]
    end
  end

  describe "swipe/3" do
    test "began anchors the gesture and changes nothing" do
      {state, grab} =
        MishkaDrawer.swipe(%{phase: :began, y: 30.0}, nil, open: true, side: :bottom)

      assert state.open?
      assert grab.at == 30.0
    end

    test "dragging changes nothing — the panel settles on release" do
      {_, grab} = MishkaDrawer.swipe(%{phase: :began, y: 0.0}, nil, open: true, side: :bottom)

      {state, kept} =
        MishkaDrawer.swipe(%{phase: :dragging, y: 500.0}, grab, open: true, side: :bottom)

      assert state.open?
      assert kept == grab
    end

    test "a drag past the threshold toward the drawer's edge dismisses it" do
      refute gesture(0.0, 100.0, side: :bottom, open: true).open?
      refute gesture(0.0, -100.0, side: :top, open: true).open?
      refute gesture(0.0, 100.0, side: :right, open: true).open?
      refute gesture(0.0, -100.0, side: :left, open: true).open?
    end

    test "a drag AWAY from the edge never dismisses" do
      assert gesture(0.0, -300.0, side: :bottom, open: true).open?
      assert gesture(0.0, 300.0, side: :left, open: true).open?
    end

    test "threshold is the dividing line, and is tunable" do
      assert gesture(0.0, 63.0, side: :bottom, open: true).open?
      refute gesture(0.0, 65.0, side: :bottom, open: true).open?
      assert gesture(0.0, 65.0, side: :bottom, open: true, threshold: 200).open?
    end

    test "swipe_direction overrides the edge the side implies" do
      # A bottom sheet told to dismiss rightwards reads x, not y, so a downward
      # drag leaves it alone.
      props = [side: :bottom, open: true, swipe_direction: :right]

      {_, grab} = MishkaDrawer.swipe(%{phase: :began, x: 0.0}, nil, props)
      {state, _} = MishkaDrawer.swipe(%{phase: :ended, x: 200.0}, grab, props)
      refute state.open?
    end

    test "a gesture with no anchor leaves the drawer alone" do
      {state, grab} =
        MishkaDrawer.swipe(%{phase: :ended, y: 900.0}, nil, open: true, side: :bottom)

      assert state.open?
      assert grab == nil
    end

    test "phase arrives as an atom from the NIF, and as a string across a wire" do
      atom = gesture(0.0, 100.0, side: :bottom, open: true)

      {_, grab} =
        MishkaDrawer.swipe(%{"phase" => "began", "y" => 0.0}, nil, open: true, side: :bottom)

      {string, _} =
        MishkaDrawer.swipe(%{"phase" => "ended", "y" => 100.0}, grab, open: true, side: :bottom)

      assert atom == string
    end

    test "only x/y are read — dx/dy differ per platform and must never be used" do
      # iOS sends cumulative translation and Android per-sample deltas, so a
      # payload whose dx is huge but whose x never moved is not a swipe.
      props = [side: :right, open: true]

      {_, grab} = MishkaDrawer.swipe(%{phase: :began, x: 10.0, dx: 0.0}, nil, props)
      {state, _} = MishkaDrawer.swipe(%{phase: :ended, x: 10.0, dx: 900.0}, grab, props)

      assert state.open?
    end
  end

  describe "swipe/3 with snap points" do
    @sheet [side: :bottom, open: true, snap_points: [180, 300, 440], snap: 440]

    test "a downward drag steps to the nearest smaller point" do
      assert gesture(0.0, 150.0, @sheet).snap == 300
    end

    test "an upward drag grows the sheet" do
      assert gesture(0.0, -150.0, Keyword.put(@sheet, :snap, 180)).snap == 300
    end

    test "dragging below the smallest point dismisses" do
      settled = gesture(0.0, 400.0, Keyword.put(@sheet, :snap, 180))

      refute settled.open?
    end

    test "a sheet above the smallest point is not dismissed by one long flick" do
      settled = gesture(0.0, 500.0, @sheet)

      # 500 below 440 is under the smallest point, so without sequential this is
      # a dismissal — the point of the flag is that it is not.
      refute gesture(0.0, 500.0, @sheet).open?
      assert settled.snap == 440 or not settled.open?

      sequential = gesture(0.0, 500.0, Keyword.put(@sheet, :snap_sequential, true))
      assert sequential.open?
      assert sequential.snap == 300
    end

    test "snap_sequential moves one point per flick, however far the finger goes" do
      props = Keyword.put(@sheet, :snap_sequential, true)

      assert gesture(0.0, 300.0, props).snap == 300
      assert gesture(0.0, -300.0, Keyword.put(props, :snap, 180)).snap == 300
    end

    test "without it, a long flick may skip a point" do
      assert gesture(0.0, 260.0, @sheet).snap == 180
    end

    test "a small drag settles back on the point it started from" do
      assert gesture(0.0, 20.0, @sheet).snap == 440
    end
  end

  describe "swipe/3 from the edge area" do
    test "an inward drag opens a closed drawer" do
      assert gesture(0.0, 100.0, side: :left, open: false).open?
      assert gesture(0.0, -100.0, side: :right, open: false).open?
      assert gesture(0.0, -100.0, side: :bottom, open: false).open?
    end

    test "an outward drag does not" do
      refute gesture(0.0, -100.0, side: :left, open: false).open?
    end

    test "a short drag does not" do
      refute gesture(0.0, 30.0, side: :left, open: false).open?
    end

    test "opening lands on the default snap point" do
      opened = gesture(0.0, -200.0, side: :bottom, open: false, snap_points: [180, 300])

      assert opened.open?
      assert opened.snap == 180
    end
  end

  describe "snap_heights/1 and snap_index/1" do
    test "sorts, resolves fractions, and drops what it cannot resolve" do
      assert MishkaDrawer.snap_heights(%{snap_points: [440, 180]}) == [180, 440]
      assert MishkaDrawer.snap_heights(%{snap_points: [0.5], extent: 400}) == [200.0]
      assert MishkaDrawer.snap_heights(%{snap_points: [0.5]}) == []
      assert MishkaDrawer.snap_heights(%{}) == []
    end

    test "the index is 1-based and follows the sorted order" do
      assert MishkaDrawer.snap_index(%{snap_points: [440, 180], snap: 440}) == 2
      assert MishkaDrawer.snap_index(%{snap_points: [440, 180]}) == 1
      assert MishkaDrawer.snap_index(%{snap_points: [180], snap: 999}) == nil
      assert MishkaDrawer.snap_index(%{}) == nil
    end
  end

  describe "dismiss_direction/1" do
    test "follows the side unless told otherwise" do
      assert MishkaDrawer.dismiss_direction(%{side: :left}) == :left
      assert MishkaDrawer.dismiss_direction(%{side: :top}) == :up
      assert MishkaDrawer.dismiss_direction(%{}) == :right
      assert MishkaDrawer.dismiss_direction(%{side: :top, swipe_direction: :left}) == :left
      assert MishkaDrawer.dismiss_direction(%{side: "top"}) == :up
    end
  end

  describe "through the composite pipeline (registration + event injection)" do
    setup do
      Mob.Composite.register(:mishka_drawer, {MishkaDrawer, :expand})
      :ok
    end

    test "a <MishkaDrawer> node expands to a fully renderable native tree" do
      node = %{
        type: :mishka_drawer,
        props: %{open: true, side: :left, title: "Menu", on_close: :close_it},
        children: [%{type: :text, props: %{text: "Hi"}, children: []}]
      }

      expanded = Mob.Composite.expand(node, self())

      # No composite tag survives; every node is native-renderable.
      refute Enum.any?(flatten(expanded), &(&1.type == :mishka_drawer))
      assert_renderable(expanded)

      # A bare-atom on_close got auto-injected to a {pid, tag} target.
      assert %{props: %{on_tap: {pid, :close_it}}} = find(expanded, :box, background: @scrim)
      assert pid == self()
    end

    test "a sheet with a handle and snap points is renderable too" do
      node = %{
        type: :mishka_drawer,
        props: %{
          id: "sheet",
          open: true,
          side: :bottom,
          handle: true,
          snap_points: [180, 300],
          on_swipe: :sheet_swipe,
          on_close: :close_it
        },
        children: []
      }

      expanded = Mob.Composite.expand(node, self())

      assert_renderable(expanded, extra: [:canvas])
      assert find(expanded, :canvas).props.on_drag == {self(), :sheet_swipe}
    end

    test "an edge swipe area is renderable while the drawer is closed" do
      node = %{
        type: :mishka_drawer,
        props: %{id: "edge", open: false, swipe_area: true, side: :left, on_swipe: :edge},
        children: []
      }

      expanded = Mob.Composite.expand(node, self())

      assert_renderable(expanded, extra: [:canvas])
      assert find(expanded, :canvas).props.on_drag == {self(), :edge}
    end

    test "slot tags written as markup are consumed on the way through" do
      children = [
        %{type: :mishka_drawer_trigger, props: %{label: "Menu", on_open: :open_it}, children: []},
        %{type: :text, props: %{text: "Hi"}, children: []},
        %{
          type: :mishka_drawer_footer,
          props: %{},
          children: [%{type: :text, props: %{text: "Bye"}, children: []}]
        }
      ]

      open =
        Mob.Composite.expand(
          %{
            type: :mishka_drawer,
            props: %{id: "menu", open: true, side: :left, on_close: :close_it},
            children: children
          },
          self()
        )

      closed =
        Mob.Composite.expand(
          %{type: :mishka_drawer, props: %{id: "menu", open: false}, children: children},
          self()
        )

      for tree <- [open, closed] do
        assert find_all(tree, :mishka_drawer_trigger) == []
        assert find_all(tree, :mishka_drawer_footer) == []
        assert_renderable(tree)
      end

      assert tagged(open, "menu-footer")
      assert text(open) =~ "Bye"
      # The closed drawer is its trigger, and the tag's bare atom came out wired.
      assert closed.props.on_tap == {self(), :open_it}
    end

    test "closed drawer expands to an empty, still-renderable node" do
      node = %{type: :mishka_drawer, props: %{open: false}, children: []}
      expanded = Mob.Composite.expand(node, self())
      assert_renderable(expanded)
    end
  end
end
