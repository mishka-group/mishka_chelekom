defmodule MishkaMob.Components.MishkaTreeTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaTree, MishkaTreeSelect}

  doctest MishkaMob.Components.MishkaTree

  @nodes [
    %{
      label: "lib",
      value: "lib",
      children: [
        %{
          label: "inner",
          value: "lib/inner",
          children: [%{label: "deep.ex", value: "lib/inner/deep.ex"}]
        },
        %{label: "top.ex", value: "lib/top.ex"}
      ]
    },
    %{label: "mix.exs", value: "mix.exs"}
  ]

  defp values(rows), do: Enum.map(rows, &elem(&1, 0).value)
  defp labels(tree), do: tree |> find_all(:text) |> Enum.map(& &1.props.text)

  describe "visible/2" do
    test "a collapsed tree is just its roots" do
      assert values(MishkaTree.visible(@nodes, [])) == ["lib", "mix.exs"]
    end

    test "expanding a node reveals only its direct children" do
      assert values(MishkaTree.visible(@nodes, ["lib"])) ==
               ["lib", "lib/inner", "lib/top.ex", "mix.exs"]
    end

    test "a grandchild needs its whole chain expanded" do
      # Expanding the inner node alone does nothing while its parent is closed.
      assert values(MishkaTree.visible(@nodes, ["lib/inner"])) == ["lib", "mix.exs"]

      # top.ex is inner's sibling, so it is visible too — depth-first order.
      assert values(MishkaTree.visible(@nodes, ["lib", "lib/inner"])) ==
               ["lib", "lib/inner", "lib/inner/deep.ex", "lib/top.ex", "mix.exs"]
    end

    test "reports depth, so the renderer never walks the tree again" do
      depths =
        @nodes
        |> MishkaTree.visible(["lib", "lib/inner"])
        |> Enum.map(fn {node, depth, _, _} -> {node.value, depth} end)

      assert depths == [
               {"lib", 0},
               {"lib/inner", 1},
               {"lib/inner/deep.ex", 2},
               {"lib/top.ex", 1},
               {"mix.exs", 0}
             ]
    end

    test "marks which rows can expand, and which are open" do
      rows = MishkaTree.visible(@nodes, ["lib"])

      assert Enum.map(rows, fn {_, _, expandable?, _} -> expandable? end) ==
               [true, true, false, false]

      assert Enum.map(rows, fn {_, _, _, expanded?} -> expanded? end) ==
               [true, false, false, false]
    end

    test "a childless node is never expandable, even if listed as expanded" do
      rows = MishkaTree.visible([%{label: "a", value: "a"}], ["a"])

      assert [{_, 0, false, false}] = rows
    end

    test "empty input yields no rows" do
      assert MishkaTree.visible([], []) == []
      assert MishkaTree.visible(nil, []) == []
    end
  end

  describe "check_state/3" do
    test "a parent is indeterminate when only some descendants are checked" do
      assert MishkaTree.check_state(@nodes, "lib", ["lib/top.ex"]) == :indeterminate
    end

    test "a parent is checked only when every descendant is" do
      all = ["lib/inner", "lib/inner/deep.ex", "lib/top.ex"]

      assert MishkaTree.check_state(@nodes, "lib", all) == :checked
      assert MishkaTree.check_state(@nodes, "lib", tl(all)) == :indeterminate
    end

    test "a parent with nothing checked is unchecked, whatever else is" do
      assert MishkaTree.check_state(@nodes, "lib", ["mix.exs"]) == :unchecked
    end

    test "a leaf just reports its own membership" do
      assert MishkaTree.check_state(@nodes, "mix.exs", ["mix.exs"]) == :checked
      assert MishkaTree.check_state(@nodes, "mix.exs", []) == :unchecked
    end

    test "an unknown value is unchecked rather than an error" do
      assert MishkaTree.check_state(@nodes, "nope", ["nope"]) == :unchecked
    end
  end

  describe "toggle_check/4" do
    test "checking a parent checks everything under it" do
      assert MishkaTree.toggle_check(@nodes, "lib", []) ==
               ["lib", "lib/inner", "lib/inner/deep.ex", "lib/top.ex"]
    end

    test "unchecking a fully checked parent clears the subtree and nothing else" do
      checked = ["mix.exs", "lib", "lib/inner", "lib/inner/deep.ex", "lib/top.ex"]

      assert MishkaTree.toggle_check(@nodes, "lib", checked) == ["mix.exs"]
    end

    test "a partially checked parent fills in rather than clearing" do
      # Indeterminate is not checked, so the tap completes the set.
      assert MishkaTree.toggle_check(@nodes, "lib", ["lib/top.ex"]) ==
               ["lib/top.ex", "lib", "lib/inner", "lib/inner/deep.ex"]
    end

    test "check_strictly touches only the node tapped" do
      assert MishkaTree.toggle_check(@nodes, "lib", [], strictly: true) == ["lib"]
    end

    test "never duplicates an already-checked value" do
      once = MishkaTree.toggle_check(@nodes, "lib", ["lib/inner"])

      assert Enum.uniq(once) == once
    end

    test "an unknown value still toggles itself" do
      assert MishkaTree.toggle_check(@nodes, "ghost", []) == ["ghost"]
    end
  end

  describe "toggle_expand/2" do
    test "adds and removes, preserving the rest" do
      assert MishkaTree.toggle_expand("a", ["b"]) == ["b", "a"]
      assert MishkaTree.toggle_expand("a", ["b", "a"]) == ["b"]
    end
  end

  describe "rendering" do
    test "renders one row per visible node, in order" do
      tree = MishkaTree.tree(nodes: @nodes, expanded: ["lib"])

      assert labels(tree) -- ["▸", "▾"] == ["lib", "inner", "top.ex", "mix.exs"]
    end

    test "the disclosure reflects and reverses the state" do
      closed = MishkaTree.tree(nodes: @nodes, on_expand: :open, on_collapse: :close)

      open =
        MishkaTree.tree(nodes: @nodes, expanded: ["lib"], on_expand: :open, on_collapse: :close)

      assert "▸" in labels(closed)
      assert "▾" in labels(open)

      taps = fn tree ->
        tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)
      end

      assert {self(), {:open, "lib"}} in taps.(closed)
      assert {self(), {:close, "lib"}} in taps.(open)
    end

    test "indentation grows with depth" do
      tree = MishkaTree.tree(nodes: @nodes, expanded: ["lib", "lib/inner"], level_offset: 20)

      offsets =
        tree
        |> find_all(:row)
        |> Enum.map(fn row ->
          row.children |> List.first() |> Map.get(:props) |> Map.get(:size)
        end)
        |> Enum.reject(&is_nil/1)

      assert offsets == [0, 20, 40, 20, 0]
    end

    test "a leaf reserves the arrow's width so labels line up" do
      tree = MishkaTree.tree(nodes: [%{label: "a", value: "a"}])
      sizes = tree |> find_all(:spacer) |> Enum.map(& &1.props[:size])

      assert 20 in sizes
    end

    test "checkboxes show all three states" do
      # The glyphs are MishkaCheckbox's, not the tree's own: a tick for checked,
      # a dash for mixed, nothing for unchecked. The tree used to draw ☑/⊟/☐
      # itself, which meant a checkbox in a tree looked nothing like one in a
      # form.
      tree = fn checked ->
        MishkaTree.tree(
          nodes: @nodes,
          expanded: ["lib"],
          checked: checked,
          with_checkboxes: true
        )
      end

      refute "✓" in labels(tree.([]))
      assert "–" in labels(tree.(["lib/top.ex"]))
      assert "✓" in labels(tree.(["lib/inner", "lib/inner/deep.ex", "lib/top.ex"]))
    end

    test "the checkbox IS the Checkbox component, and does not fill the row" do
      # Two things a glyph could not give us: the states differ by more than a
      # character (a filled :primary box when checked), and the checkbox has to
      # hug — it is one cell in a row, and filling pushes the label off the end.
      tree =
        MishkaTree.tree(
          nodes: @nodes,
          checked: ["mix.exs"],
          with_checkboxes: true
        )

      boxes =
        tree
        |> find_all(:row)
        |> Enum.filter(&(&1.props[:fill_width] == false and find(&1, :box)))

      refute Enum.empty?(boxes), "no Checkbox rows found in the tree"

      fills = boxes |> Enum.map(&find(&1, :box)) |> Enum.map(& &1.props[:background])
      assert :primary in fills, "a checked node should carry the Checkbox's filled indicator"
    end

    test "selection is styled, not just recorded" do
      tree = MishkaTree.tree(nodes: @nodes, selected: ["mix.exs"])
      label = tree |> find_all(:text) |> Enum.find(&(&1.props.text == "mix.exs"))

      assert label.props.text_color == :primary
      assert label.props.weight == :semibold
    end

    test "a disabled node is muted and wires nothing" do
      nodes = [%{label: "a", value: "a", disabled: true, children: [%{label: "b", value: "b"}]}]
      tree = MishkaTree.tree(nodes: nodes, on_select: :pick, on_expand: :open)

      assert tree |> find_all(:box) |> Enum.all?(&(&1.props[:on_tap] == nil))
      assert find(tree, :text).props.text_color == :muted
    end

    test "icons render beside the label when given" do
      tree = MishkaTree.tree(nodes: [%{label: "a", value: "a", icon: "📄"}])

      assert "📄" in labels(tree)
    end

    test "the expand icon can be turned off entirely" do
      tree = MishkaTree.tree(nodes: @nodes, with_expand_icon: false)

      refute "▸" in labels(tree)
    end

    test "guide lines appear per level, only below the root" do
      without = MishkaTree.tree(nodes: @nodes, expanded: ["lib"])
      with_lines = MishkaTree.tree(nodes: @nodes, expanded: ["lib"], with_lines: true)

      thin = fn tree -> tree |> find_all(:box) |> Enum.count(&(&1.props[:width] == 1)) end

      assert thin.(without) == 0
      # Two children at depth 1, one line each.
      assert thin.(with_lines) == 2
    end

    test "an empty tree renders an empty column rather than failing" do
      tree = MishkaTree.tree(nodes: [])

      assert tree.type == :column
      assert tree.children == []
    end
  end

  describe "tree select" do
    test "shows the placeholder until something is chosen" do
      assert text(MishkaTreeSelect.tree_select()) =~ "Select…"
      assert text(MishkaTreeSelect.tree_select(placeholder: "Pick one")) =~ "Pick one"
      assert text(MishkaTreeSelect.tree_select(label: "mix.exs")) =~ "mix.exs"
    end

    test "a placeholder is muted; a real selection is not" do
      empty = MishkaTreeSelect.tree_select()
      chosen = MishkaTreeSelect.tree_select(label: "mix.exs")

      assert find(empty, :text).props.text_color == :muted
      assert find(chosen, :text).props.text_color == :on_surface
    end

    test "the panel holds the children, and only when open" do
      child = [%{type: :text, props: %{text: "the tree"}, children: []}]

      refute text(MishkaTreeSelect.tree_select(%{}, child)) =~ "the tree"
      assert text(MishkaTreeSelect.tree_select(%{open: true}, child)) =~ "the tree"
    end

    test "the trigger reports taps and flips its glyph" do
      closed = MishkaTreeSelect.tree_select(on_toggle: :toggle)
      open = MishkaTreeSelect.tree_select(open: true, on_toggle: :toggle)

      assert find(closed, :box).props.on_tap == {self(), :toggle}
      assert text(closed) =~ "▾"
      assert text(open) =~ "▴"
    end

    test "disabled unwires the trigger" do
      tree = MishkaTreeSelect.tree_select(disabled: true, on_toggle: :toggle, label: "x")

      refute Map.has_key?(find(tree, :box).props, :on_tap)
      assert find(tree, :text).props.text_color == :muted
    end

    test "holds a real tree, not just text" do
      panel = [MishkaTree.tree(nodes: @nodes)]
      tree = MishkaTreeSelect.tree_select(%{open: true}, panel)

      assert text(tree) =~ "lib"
      assert text(tree) =~ "mix.exs"
    end
  end

  test "expand/3 delegates for both" do
    ctx = %{screen: self()}
    child = [%{type: :text, props: %{text: "x"}, children: []}]

    assert MishkaTree.expand(%{nodes: @nodes}, [], ctx) == MishkaTree.tree(nodes: @nodes)

    assert MishkaTreeSelect.expand(%{open: true}, child, ctx) ==
             MishkaTreeSelect.tree_select(%{open: true}, child)
  end

  test "every variant renders" do
    for props <- [
          %{},
          %{nodes: @nodes},
          %{nodes: @nodes, expanded: ["lib", "lib/inner"], with_lines: true},
          %{nodes: @nodes, expanded: ["lib"], with_checkboxes: true, checked: ["lib/top.ex"]},
          %{nodes: @nodes, selected: ["mix.exs"], with_expand_icon: false}
        ] do
      assert_renderable(MishkaTree.tree(props))
    end

    assert_renderable(
      MishkaTreeSelect.tree_select(%{open: true}, [MishkaTree.tree(nodes: @nodes)])
    )
  end
end
