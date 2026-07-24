defmodule MishkaMob.Components.MishkaDrawerTest do
  # Unit tests for the Drawer composite. `use Mob.ScreenCase` is borrowed purely
  # for its tree queries (find / flatten / text / assert_renderable), which all
  # accept a raw `%{type:, ...}` node map — no screen needed.
  use Mob.ScreenCase, async: true

  import ExUnit.CaptureLog

  alias MishkaMob.Components.MishkaDrawer

  @scrim 0x99_00_00_00

  # Built at call time so `self()` is the test process (not the module loader).
  defp ctx, do: %{screen: self()}

  defp body,
    do: [%{type: :button, props: %{text: "Profile", on_tap: {self(), :profile}}, children: []}]

  # Realistic open props: an open drawer normally has an on_close dismiss path.
  defp p(extra \\ %{}), do: Map.merge(%{open: true, on_close: {self(), :close}}, extra)

  describe "closed" do
    test "renders nothing when open is false or absent" do
      empty = %{type: :column, props: %{}, children: []}
      assert MishkaDrawer.expand(%{open: false}, [], ctx()) == empty
      assert MishkaDrawer.expand(%{}, [], ctx()) == empty
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

    test "the panel absorbs stray taps so they don't leak to the scrim" do
      tree = MishkaDrawer.expand(p(%{side: :right}), body(), ctx())
      assert %{props: %{on_tap: {pid, :__mishka_drawer_ignore}}} = find(tree, :box, width: 320)
      assert pid == self()
    end

    test "scrim can be disabled" do
      tree = MishkaDrawer.expand(p(%{scrim: false}), body(), ctx())
      refute find(tree, :box, background: @scrim)
    end

    test "the drawer body children are spliced below the header" do
      tree = MishkaDrawer.expand(p(%{side: :right}), body(), ctx())
      assert find(tree, :button, text: "Profile")
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

    test "closed drawer expands to an empty, still-renderable node" do
      node = %{type: :mishka_drawer, props: %{open: false}, children: []}
      expanded = Mob.Composite.expand(node, self())
      assert_renderable(expanded)
    end
  end
end
