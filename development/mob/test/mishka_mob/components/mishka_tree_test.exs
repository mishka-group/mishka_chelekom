defmodule MishkaMob.Components.MishkaTreeTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaTree, MishkaTreeSelect}
  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

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

  # Two headers that can never be selected, over leaves that can — plus one
  # disabled leaf, so a range has something to step over.
  @people [
    %{
      label: "DESIGN",
      value: "design",
      selectable: false,
      children: [
        %{label: "Ada", value: "ada"},
        %{label: "Bo", value: "bo"}
      ]
    },
    %{
      label: "ENGINEERING",
      value: "eng",
      selectable: false,
      children: [
        %{label: "Dee", value: "dee"},
        %{label: "Eve", value: "eve", disabled: true},
        %{label: "Fen", value: "fen"}
      ]
    }
  ]

  defp values(rows), do: Enum.map(rows, &elem(&1, 0).value)
  defp labels(tree), do: tree |> find_all(:text) |> Enum.map(& &1.props.text)

  # Every test tag in a rendered tree. The component says everything it knows
  # about state with a colour, a glyph or a drawn mark, so this list is the only
  # thing a device test can actually read — which makes it worth asserting on
  # directly rather than through whichever node happens to carry it.
  defp tags(tree) do
    tree |> flatten() |> Enum.map(& &1.props[:id]) |> Enum.reject(&is_nil/1)
  end

  defp node_with_tag(tree, tag) do
    tree |> flatten() |> Enum.find(&(&1.props[:id] == tag))
  end

  defp page(view), do: Mob.Composite.expand(tree(view), self())

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

      # The marks are DRAWN now, not typed, so count canvas lines rather than
      # look for glyph characters: two lines is a tick, one is a dash, none is
      # an empty box.
      marks = fn t ->
        t
        |> find_all(:canvas)
        |> Enum.map(&Enum.count(&1.props.draw, fn op -> op.op == :line end))
      end

      refute 2 in marks.(tree.([]))
      assert 1 in marks.(tree.(["lib/top.ex"]))
      assert 2 in marks.(tree.(["lib/inner", "lib/inner/deep.ex", "lib/top.ex"]))
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
      # `font_weight`, not `weight` — the bridges read the former for typography,
      # and the latter is a parent Row/Column layout weight that styles nothing.
      assert label.props.font_weight == :semibold
      refute Map.has_key?(label.props, :weight)
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

  describe "node kinds" do
    test "a branch that has not been fetched is still a branch" do
      # has_children is the whole async story: the node claims children it has
      # not got, so it must draw a disclosure and be tappable before there is
      # anything under it.
      nodes = [%{label: "assets", value: "assets", has_children: true}]

      assert [{_, 0, true, false}] = MishkaTree.visible(nodes, [])
      assert [{_, 0, true, true}] = MishkaTree.visible(nodes, ["assets"])
    end

    test "expanding an unfetched branch reveals nothing, and does not crash" do
      nodes = [%{label: "assets", value: "assets", has_children: true}]

      assert values(MishkaTree.visible(nodes, ["assets"])) == ["assets"]
    end

    test ":all opens every branch, including the unfetched ones" do
      assert values(MishkaTree.visible(@nodes, :all)) ==
               ["lib", "lib/inner", "lib/inner/deep.ex", "lib/top.ex", "mix.exs"]

      nodes = [%{label: "a", value: "a", has_children: true}]
      assert [{_, 0, true, true}] = MishkaTree.visible(nodes, :all)
    end

    test "expanded_values/1 is the list :all stands for" do
      assert MishkaTree.expanded_values(@nodes) == ["lib", "lib/inner"]
      assert MishkaTree.expanded_values([]) == []
    end

    test "a selectable: false header is never styled as selected" do
      # Passing its value in `selected` is not an error, it is simply ignored —
      # otherwise a header would flash selected on the render before whatever
      # owns the selection got a chance to reject it.
      tree = MishkaTree.tree(nodes: @people, expanded: :all, selected: ["design", "ada"])

      assert node_with_tag(tree, "tree-design-idle")
      assert node_with_tag(tree, "tree-ada-selected")
      assert node_with_tag(tree, "tree-ada-selected").props.text_color == :primary
    end
  end

  describe "what a tap means" do
    test "a branch expands and a leaf selects, with both wired" do
      tree =
        MishkaTree.tree(
          nodes: @nodes,
          expanded: ["lib"],
          on_expand: :open,
          on_collapse: :close,
          on_select: :pick
        )

      assert node_with_tag(tree, "tree-row-lib").props[:on_tap] == {self(), {:close, "lib"}}

      assert node_with_tag(tree, "tree-row-lib/top.ex").props[:on_tap] ==
               {self(), {:pick, "lib/top.ex"}}
    end

    test "expand_on_click: false hands the branch's row back to selection" do
      tree =
        MishkaTree.tree(
          nodes: @nodes,
          expand_on_click: false,
          on_expand: :open,
          on_select: :pick
        )

      assert node_with_tag(tree, "tree-row-lib").props[:on_tap] == {self(), {:pick, "lib"}}
      # The arrow keeps its own handler, so the branch is still reachable.
      assert node_with_tag(tree, "tree-toggle-lib").props[:on_tap] == {self(), {:open, "lib"}}
    end

    test "select_on_click: false leaves a leaf inert" do
      tree = MishkaTree.tree(nodes: @nodes, select_on_click: false, on_select: :pick)

      refute Map.has_key?(node_with_tag(tree, "tree-row-mix.exs").props, :on_tap)
    end

    test "a header toggles its branch even with expand_on_click off" do
      # The web is explicit about this: a selectable: false parent is a category
      # heading, and clicking it opens the branch rather than doing nothing.
      tree =
        MishkaTree.tree(
          nodes: @people,
          expand_on_click: false,
          on_expand: :open,
          on_select: :pick
        )

      assert node_with_tag(tree, "tree-row-design").props[:on_tap] == {self(), {:open, "design"}}
    end

    test "a wired tree never leaves a row that renders and does nothing" do
      # Half the trees in the wild carry on_expand and no on_select (checkbox
      # trees) or the reverse (pickers). Taking the branch unconditionally would
      # make every leaf of the first kind inert.
      checkboxy = MishkaTree.tree(nodes: @nodes, expanded: ["lib"], on_expand: :open)
      picker = MishkaTree.tree(nodes: @nodes, on_select: :pick)

      refute Map.has_key?(node_with_tag(checkboxy, "tree-row-lib/top.ex").props, :on_tap)
      assert node_with_tag(picker, "tree-row-lib").props[:on_tap] == {self(), {:pick, "lib"}}
    end

    test "an unfetched branch asks for its children instead of opening" do
      nodes = [%{label: "assets", value: "assets", has_children: true}]

      asking = MishkaTree.tree(nodes: nodes, on_expand: :open, on_load_children: :fetch)
      bare = MishkaTree.tree(nodes: nodes, on_expand: :open)

      assert node_with_tag(asking, "tree-row-assets").props[:on_tap] ==
               {self(), {:fetch, "assets"}}

      # Without on_load_children it falls back, so the branch still opens.
      assert node_with_tag(bare, "tree-row-assets").props[:on_tap] == {self(), {:open, "assets"}}
    end

    test "a fetched branch stops asking" do
      nodes = [
        %{
          label: "assets",
          value: "assets",
          has_children: true,
          children: [%{label: "a", value: "a"}]
        }
      ]

      tree = MishkaTree.tree(nodes: nodes, on_expand: :open, on_load_children: :fetch)

      assert node_with_tag(tree, "tree-row-assets").props[:on_tap] == {self(), {:open, "assets"}}
    end

    test "a disabled node wires neither a tap nor a hold" do
      nodes = [%{label: "a", value: "a", disabled: true, children: [%{label: "b", value: "b"}]}]

      tree =
        MishkaTree.tree(
          nodes: nodes,
          on_select: :pick,
          on_expand: :open,
          on_range_select: :range
        )

      row = node_with_tag(tree, "tree-row-a")

      refute Map.has_key?(row.props, :on_tap)
      refute Map.has_key?(row.props, :on_long_press)
    end
  end

  describe "long press is Shift+click" do
    test "a row reports on_range_select when held" do
      tree = MishkaTree.tree(nodes: @nodes, on_range_select: :range)

      assert node_with_tag(tree, "tree-row-mix.exs").props[:on_long_press] ==
               {self(), {:range, "mix.exs"}}
    end

    test "the plain tap survives the hold" do
      # combinedClickable takes both handles, so adding the range must not cost
      # the row the gesture it already had.
      tree = MishkaTree.tree(nodes: @nodes, on_select: :pick, on_range_select: :range)
      row = node_with_tag(tree, "tree-row-mix.exs")

      assert row.props[:on_tap] == {self(), {:pick, "mix.exs"}}
      assert row.props[:on_long_press] == {self(), {:range, "mix.exs"}}
    end

    test "allow_range_selection: false takes the hold away" do
      tree =
        MishkaTree.tree(nodes: @nodes, on_range_select: :range, allow_range_selection: false)

      refute Map.has_key?(node_with_tag(tree, "tree-row-mix.exs").props, :on_long_press)
    end

    test "a header cannot anchor a range it can never join" do
      tree = MishkaTree.tree(nodes: @people, expanded: :all, on_range_select: :range)

      refute Map.has_key?(node_with_tag(tree, "tree-row-design").props, :on_long_press)

      assert node_with_tag(tree, "tree-row-ada").props[:on_long_press] ==
               {self(), {:range, "ada"}}
    end
  end

  describe "toggle_select/3" do
    test "single selection replaces, and a second tap clears" do
      assert MishkaTree.toggle_select("b", ["a"]) == ["b"]
      assert MishkaTree.toggle_select("a", ["a"]) == []
    end

    test "single selection clears only when it IS the selection" do
      # ["a", "b"] is a multiple selection being tapped in single mode: the tap
      # collapses it to one rather than emptying it.
      assert MishkaTree.toggle_select("a", ["a", "b"]) == ["a"]
    end

    test "multiple adds and removes, keeping order" do
      assert MishkaTree.toggle_select("c", ["a", "b"], multiple: true) == ["a", "b", "c"]
      assert MishkaTree.toggle_select("a", ["a", "b"], multiple: true) == ["b"]
    end

    test "nil and non-lists are tolerated" do
      assert MishkaTree.toggle_select("a", nil) == ["a"]
    end
  end

  describe "select_range/4" do
    test "runs in visible order, whichever end you started from" do
      assert MishkaTree.select_range(@nodes, :all, "lib/inner", "mix.exs") ==
               ["lib/inner", "lib/inner/deep.ex", "lib/top.ex", "mix.exs"]

      assert MishkaTree.select_range(@nodes, :all, "mix.exs", "lib/inner") ==
               ["lib/inner", "lib/inner/deep.ex", "lib/top.ex", "mix.exs"]
    end

    test "steps over what cannot be selected" do
      # design and eng are headers; eve is disabled. All three sit inside the
      # run and none of them joins it.
      assert MishkaTree.select_range(@people, :all, "ada", "fen") == ["ada", "bo", "dee", "fen"]
    end

    test "only what is on screen can be dragged across" do
      assert MishkaTree.select_range(@nodes, [], "lib", "mix.exs") == ["lib", "mix.exs"]
    end

    test "with no anchor a hold is a selection of one" do
      assert MishkaTree.select_range(@nodes, :all, nil, "mix.exs") == ["mix.exs"]
    end

    test "a value that is not on screen selects nothing" do
      assert MishkaTree.select_range(@nodes, [], "lib", "lib/top.ex") == []
      assert MishkaTree.select_range(@nodes, [], nil, "lib/top.ex") == []
    end

    test "an anchor and a target on the same row is just that row" do
      assert MishkaTree.select_range(@nodes, :all, "lib/top.ex", "lib/top.ex") == ["lib/top.ex"]
    end
  end

  describe "test tags" do
    test "every part of every row is addressable" do
      tree = MishkaTree.tree(nodes: @nodes, expanded: ["lib"], with_checkboxes: true)

      assert "tree-row-lib" in tags(tree)
      assert "tree-toggle-lib" in tags(tree)
      assert "tree-check-lib" in tags(tree)
      assert "tree-lib-open" in tags(tree)
      assert "tree-lib-idle" in tags(tree)
      assert "tree-lib-empty" in tags(tree)
    end

    test "id prefixes everything, so two trees on a page never collide" do
      mine = MishkaTree.tree(nodes: @nodes, id: "files", with_checkboxes: true)

      assert "files-row-lib" in tags(mine)
      assert "files-toggle-lib" in tags(mine)
      assert "files-check-lib" in tags(mine)
      refute Enum.any?(tags(mine), &String.starts_with?(&1, "tree-"))
    end

    test "an atom id is as good as a string" do
      assert "files-row-mix.exs" in tags(MishkaTree.tree(nodes: @nodes, id: :files))
    end

    test "the arrow says which way it points, because the glyph cannot" do
      closed = MishkaTree.tree(nodes: @nodes)
      open = MishkaTree.tree(nodes: @nodes, expanded: ["lib"])

      assert "tree-lib-closed" in tags(closed)
      refute "tree-lib-open" in tags(closed)
      assert "tree-lib-open" in tags(open)
    end

    test "the tappable target keeps its name when the state changes" do
      # A target renamed by the act of using it can only be used once, which is
      # why the state lives on the glyph inside rather than on the Box itself.
      closed = MishkaTree.tree(nodes: @nodes, on_expand: :open, on_collapse: :close)

      open =
        MishkaTree.tree(nodes: @nodes, expanded: ["lib"], on_expand: :open, on_collapse: :close)

      assert "tree-toggle-lib" in tags(closed)
      assert "tree-toggle-lib" in tags(open)
      assert "tree-row-lib" in tags(closed)
      assert "tree-row-lib" in tags(open)
    end

    test "the label says whether it is selected, because the colour cannot" do
      tree = MishkaTree.tree(nodes: @nodes, selected: ["mix.exs"])

      assert "tree-mix.exs-selected" in tags(tree)
      assert "tree-lib-idle" in tags(tree)
    end

    test "the checkbox carries all three of its states" do
      states = fn checked ->
        MishkaTree.tree(
          nodes: @nodes,
          expanded: ["lib"],
          checked: checked,
          with_checkboxes: true
        )
        |> tags()
      end

      assert "tree-lib-empty" in states.([])
      assert "tree-lib-mixed" in states.(["lib/top.ex"])
      assert "tree-lib-checked" in states.(["lib/inner", "lib/inner/deep.ex", "lib/top.ex"])
    end
  end

  describe "the loader" do
    test "a busy row says so, and only that row" do
      nodes = [%{label: "assets", value: "assets", has_children: true}]

      busy = MishkaTree.tree(nodes: nodes, loading: ["assets"])
      idle = MishkaTree.tree(nodes: nodes)

      assert "tree-assets-loading" in tags(busy)
      refute "tree-assets-loading" in tags(idle)
    end

    test "the marker is a glyph, not an animation" do
      nodes = [%{label: "assets", value: "assets", has_children: true}]
      tree = MishkaTree.tree(nodes: nodes, loading: ["assets"])

      assert "…" in labels(tree)
    end

    test "the glyph is the port of the loader slot, so it is yours" do
      nodes = [%{label: "assets", value: "assets", has_children: true}]
      tree = MishkaTree.tree(nodes: nodes, loading: ["assets"], loader_icon: "⟳")

      assert "⟳" in labels(tree)
      refute "…" in labels(tree)
    end
  end

  describe "rendering, continued" do
    test "the disclosure glyphs are whatever you say they are" do
      tree =
        MishkaTree.tree(
          nodes: @nodes,
          expanded: ["lib"],
          expand_icon: "+",
          collapse_icon: "−"
        )

      assert "−" in labels(tree)
      assert "+" in labels(tree)
      refute "▾" in labels(tree)
    end

    test "the label is the row's one flexible child" do
      # Compose measures a Row's unweighted children first, in order, so an
      # unweighted label takes its intrinsic width and starves the meta beside
      # it. And a Text squeezed narrower than its content wraps character by
      # character, which is why max_lines is not optional.
      tree = MishkaTree.tree(nodes: [%{label: "app.ex", value: "a", meta: "12 KB"}])
      label = node_with_tag(tree, "tree-a-idle")

      assert label.props.max_lines == 1
      assert tree |> find_all(:box) |> Enum.any?(&(&1.props[:weight] == 1))
    end

    test "check_strictly reaches the indicator, not only the reducer" do
      # The prop used to stop at `toggle_check`: a strict tick went into the
      # list and the box it was made in stayed empty, because a parent's state
      # was always derived from its leaves.
      loose = MishkaTree.tree(nodes: @nodes, checked: ["lib"], with_checkboxes: true)

      strict =
        MishkaTree.tree(
          nodes: @nodes,
          checked: ["lib"],
          with_checkboxes: true,
          check_strictly: true
        )

      assert "tree-lib-empty" in tags(loose)
      assert "tree-lib-checked" in tags(strict)
    end

    test "level_offset scales the indent" do
      wide = MishkaTree.tree(nodes: @nodes, expanded: ["lib"], level_offset: 40)

      offsets =
        wide
        |> find_all(:row)
        |> Enum.map(&(&1.children |> List.first() |> Map.get(:props) |> Map.get(:size)))
        |> Enum.reject(&is_nil/1)

      assert offsets == [0, 40, 40, 0]
    end
  end

  describe "the showcase page" do
    setup do
      Showcase.reset()
      Showcase.register_all()
      :ok
    end

    test "each example carries its own id, so nothing collides" do
      page = page(mount_screen(ComponentScreen, %{slug: :tree}))
      tags = tags(page)

      assert "tree-row-lib" in tags
      assert "multi-row-ada" in tags
      assert "async-row-project" in tags
      assert "strict-row-lib" in tags
    end

    test "the whole page is something the native layer can draw" do
      assert_renderable(page(mount_screen(ComponentScreen, %{slug: :tree})), extra: [:canvas])
    end

    test "the reset controls are wired, not merely drawn" do
      # Both exist so a device test can put an example back the way it found it,
      # which is the only way tests on a screen that outlives them stay honest.
      page = page(mount_screen(ComponentScreen, %{slug: :tree}))

      assert node_with_tag(page, "multi-clear").props[:on_tap]
      assert node_with_tag(page, "async-reset").props[:on_tap]
    end

    test "exactly two trees use the default id" do
      # TreeTest.kt reaches the checkbox example by index — onAllNodesWithTag
      # (\"tree-toggle-lib\")[1]. A third default-id tree on this page would
      # silently point that index at the wrong example.
      page = page(mount_screen(ComponentScreen, %{slug: :tree}))

      assert Enum.count(tags(page), &(&1 == "tree-toggle-lib")) == 2
    end

    test "expanding one example leaves the others where they were" do
      view = mount_screen(ComponentScreen, %{slug: :tree})
      view = render_info(view, {:tap, {:t1_open, "test"}})

      assert assigns(view).t1_expanded == ["lib", "test"]
      assert assigns(view).t2_expanded == ["lib"]
    end

    test "a tap picks, and picks again to clear" do
      view = mount_screen(ComponentScreen, %{slug: :tree})
      view = render_info(view, {:tap, {:t1_pick, "mix.exs"}})

      assert assigns(view).t1_selected == ["mix.exs"]

      view = render_info(view, {:tap, {:t1_pick, "mix.exs"}})
      assert assigns(view).t1_selected == []
    end

    test "the multiple example accumulates, and a hold fills the run" do
      view = mount_screen(ComponentScreen, %{slug: :tree})
      view = render_info(view, {:tap, {:t3_pick, "ada"}})

      assert assigns(view).t3_selected == ["ada"]
      assert assigns(view).t3_anchor == "ada"

      view = render_info(view, {:tap, {:t3_range, "fen"}})

      # eng and design are headers and eve is disabled; none of them joins.
      assert assigns(view).t3_selected == ["ada", "bo", "cy", "dee", "fen"]
      assert "multi-ada-selected" in tags(page(view))
      assert "multi-eve-idle" in tags(page(view))
    end

    test "clear puts the multiple example back" do
      view = mount_screen(ComponentScreen, %{slug: :tree})
      view = render_info(view, {:tap, {:t3_pick, "ada"}})
      view = render_info(view, {:tap, :t3_clear})

      assert assigns(view).t3_selected == []
      assert assigns(view).t3_anchor == nil
    end

    test "the async example loads, shows a loader, then opens" do
      view = mount_screen(ComponentScreen, %{slug: :tree})

      assert "async-assets-closed" in tags(page(view))
      refute "async-assets-loading" in tags(page(view))

      view = render_info(view, {:tap, {:t4_fetch, "assets"}})

      # Still shut, and busy — the whole point of a separate event.
      assert assigns(view).t4_loading == ["assets"]
      assert "async-assets-loading" in tags(page(view))
      refute "async-assets-open" in tags(page(view))

      view = render_info(view, {:tap, {:t4_arrived, "assets"}})

      assert assigns(view).t4_loading == []
      assert "async-assets-open" in tags(page(view))
      assert "async-row-assets/logo.png" in tags(page(view))
    end

    test "forgetting the fetched children puts the loader back within reach" do
      view = mount_screen(ComponentScreen, %{slug: :tree})
      view = render_info(view, {:tap, {:t4_arrived, "assets"}})

      assert assigns(view).t4_loaded == true

      view = render_info(view, {:tap, :t4_reset})

      assert assigns(view).t4_loaded == false
      assert "async-assets-closed" in tags(page(view))
      refute "async-row-assets/logo.png" in tags(page(view))
    end

    test "the header in the async example opens rather than selecting" do
      view = mount_screen(ComponentScreen, %{slug: :tree})
      view = render_info(view, {:tap, {:t4_close, "project"}})

      assert assigns(view).t4_expanded == []
      refute "async-row-readme" in tags(page(view))
      assert assigns(view).t4_selected == []
    end

    test "the strict example does not cascade, and materialises :all" do
      view = mount_screen(ComponentScreen, %{slug: :tree})
      view = render_info(view, {:tap, {:t5_check, "lib"}})

      assert assigns(view).t5_checked == ["lib"]
      assert "strict-lib-checked" in tags(page(view))
      assert "strict-lib/mishka_mob.ex-empty" in tags(page(view))

      view = render_info(view, {:tap, {:t5_close, "lib"}})

      # :all became a real list first, so closing one branch left the rest open.
      assert assigns(view).t5_expanded == ["lib/mishka_mob", "test"]
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
      assert_renderable(MishkaTree.tree(props), extra: [:canvas])
    end

    assert_renderable(
      MishkaTreeSelect.tree_select(%{open: true}, [MishkaTree.tree(nodes: @nodes)])
    )
  end
end
