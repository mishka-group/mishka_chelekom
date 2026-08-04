defmodule MishkaMob.Components.MishkaMenuTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaMenu, MishkaPopover}

  defp items do
    [
      MishkaMenu.label("MANAGE"),
      MishkaMenu.item(:edit, "Edit", icon: "✎"),
      MishkaMenu.item(:archive, "Archive", disabled: true),
      MishkaMenu.separator(),
      MishkaMenu.item(:delete, "Delete", danger: true)
    ]
  end

  defp build(props \\ %{}),
    do: MishkaMenu.menu(Map.merge(%{open: true, on_select: :pick}, props), items())

  defp rows(tree), do: find_all(tree, :row)

  describe "open gate" do
    test "renders nothing when closed" do
      assert MishkaMenu.menu(%{}, items()) == %{type: :column, props: %{}, children: []}
    end
  end

  describe "the surface is the Popover's" do
    test "same shell, so a menu and a popover cannot drift apart" do
      tree = build()

      assert tree.props.border_color == MishkaPopover.panel(%{}, []).props.border_color
      assert tree.props.corner_radius == MishkaPopover.panel(%{}, []).props.corner_radius
    end

    test "but with a tighter default padding, because rows carry their own" do
      assert build().props.padding == 6
    end
  end

  describe "items" do
    test "every label renders" do
      tree = build()

      for label <- ["MANAGE", "Edit", "Archive", "Delete"], do: assert(text(tree) =~ label)
    end

    test "an icon renders before its label" do
      tree = build()
      row = rows(tree) |> Enum.find(&(text(&1) =~ "Edit"))

      assert [%{props: %{text: "✎"}}, %{type: :spacer}, %{props: %{text: "Edit"}}] = row.children
    end

    test "rows are tappable boxes, never Buttons (a Button centres its label)" do
      assert find_all(build(), :button) == []
    end

    test "each item reports the same tag widened with its own id" do
      taps =
        build()
        |> find_all(:box)
        |> Enum.map(& &1.props[:on_tap])
        |> Enum.reject(&is_nil/1)

      assert [{pid, {:pick, :edit}}, {_, {:pick, :delete}}] = taps
      assert pid == self()
    end

    test "a disabled item wires no handler and is muted" do
      tree = build()

      assert find(tree, :text, text: "Archive").props.text_color == :muted
    end

    test "no on_select means nothing is tappable" do
      tree = MishkaMenu.menu(%{open: true}, items())

      assert tree |> find_all(:box) |> Enum.all?(&(&1.props[:on_tap] == nil))
    end
  end

  describe "danger" do
    test "a destructive item is tinted so it does not look like the rest" do
      # :error, the theme token — not a hardcoded 0xFFDC2626. A literal red
      # ignores the theme and cannot be restyled, and a test asserting the
      # literal is exactly what keeps it there. mishka_field documents the same
      # fix; the menu never got it.
      assert find(build(), :text, text: "Delete").props.text_color == :error
    end

    test "the tint is overridable" do
      tree = build(%{danger_color: 0xFF991B1B})

      assert find(tree, :text, text: "Delete").props.text_color == 0xFF991B1B
    end

    test "a disabled danger item is muted, not red" do
      tree =
        MishkaMenu.menu(%{open: true}, [MishkaMenu.item(:x, "X", danger: true, disabled: true)])

      assert find(tree, :text, text: "X").props.text_color == :muted
    end
  end

  describe "structure" do
    test "a separator renders a divider line" do
      tree = build()
      lines = tree |> find_all(:box) |> Enum.filter(&(&1.props[:height] == 1))

      assert length(lines) == 1
    end

    test "a label is muted and small, and is not tappable" do
      tree = build()
      label = find(tree, :text, text: "MANAGE")

      assert label.props.text_color == :muted
      assert label.props.text_size == :xs
    end
  end

  test "expand/3 uses the tag's children as the items" do
    assert MishkaMenu.expand(%{open: true, on_select: :pick}, items(), %{screen: self()}) ==
             build()
  end

  test "every variant renders" do
    for props <- [%{open: true}, %{open: true, width: 200}, %{open: false}] do
      assert_renderable(MishkaMenu.menu(props, items()))
    end
  end

  describe "checkbox and radio rows" do
    test "carry an indicator glyph and fold the state into the tag" do
      on = MishkaMenu.checkbox(:grid, "Show grid", checked: true, test_id: "grid")
      off = MishkaMenu.checkbox(:grid, "Show grid", test_id: "grid")

      tree = MishkaMenu.menu(%{open: true}, [on, off])
      [checked, unchecked] = find_all(tree, :box) |> Enum.filter(&Map.has_key?(&1.props, :id))

      # The glyph says it to a human; the tag says it to a device test, which
      # cannot attribute a character to a row.
      assert checked.props.id == "grid-checked"
      assert unchecked.props.id == "grid-unchecked"
      assert text(tree) =~ "✓"
    end

    test "a radio shows a filled or hollow dot, and keeps its group name" do
      picked = MishkaMenu.radio(:by_name, "Name", "sort", checked: true, test_id: "r1")
      other = MishkaMenu.radio(:by_date, "Date", "sort", test_id: "r2")

      tree = MishkaMenu.menu(%{open: true}, [picked, other])

      assert text(tree) =~ "●"
      assert text(tree) =~ "○"
      assert picked.props.name == "sort"
    end

    test "both report through on_select like any other row" do
      tree =
        MishkaMenu.menu(%{open: true, on_select: :pick}, [
          MishkaMenu.checkbox(:grid, "Show grid"),
          MishkaMenu.radio(:by_name, "Name", "sort")
        ])

      taps = find_all(tree, :box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)
      assert taps == [{self(), {:pick, :grid}}, {self(), {:pick, :by_name}}]
    end
  end

  describe "submenu" do
    defp share(opts) do
      MishkaMenu.submenu(:share, "Share", opts)
    end

    test "closed, it is one row and its children are not rendered" do
      tree =
        MishkaMenu.menu(%{open: true}, [
          share(rows: [MishkaMenu.item(:link, "Copy link")])
        ])

      assert text(tree) =~ "Share"
      refute text(tree) =~ "Copy link"
      assert text(tree) =~ "▸"
    end

    test "open, its rows appear underneath, indented" do
      tree =
        MishkaMenu.menu(%{open: true}, [
          share(open: true, rows: [MishkaMenu.item(:link, "Copy link")])
        ])

      assert text(tree) =~ "Copy link"
      assert text(tree) =~ "▾"

      # Indented rather than flown out sideways: there is no hover on a touch
      # screen and no room beside a phone-width panel.
      assert Enum.any?(find_all(tree, :spacer), &(&1.props[:size] == 16))
    end

    test "the trigger reports its own id, so the screen decides what opens" do
      tree =
        MishkaMenu.menu(%{open: true, on_select: :pick}, [
          share(rows: [MishkaMenu.item(:link, "Copy link")])
        ])

      taps = find_all(tree, :box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)
      assert taps == [{self(), {:pick, :share}}]
    end

    test "its tag says whether it is open" do
      open = MishkaMenu.menu(%{open: true}, [share(open: true, test_id: "sub")])
      shut = MishkaMenu.menu(%{open: true}, [share(test_id: "sub")])

      assert find(open, :box, id: "sub-open")
      assert find(shut, :box, id: "sub-closed")
    end
  end

  test "no slot marker survives expansion, at any depth" do
    tree =
      MishkaMenu.menu(%{open: true}, [
        MishkaMenu.item(:edit, "Edit"),
        MishkaMenu.separator(),
        MishkaMenu.label("Sort by"),
        MishkaMenu.checkbox(:grid, "Show grid"),
        MishkaMenu.radio(:by_name, "Name", "sort"),
        MishkaMenu.submenu(:share, "Share",
          open: true,
          rows: [MishkaMenu.item(:link, "Copy link"), MishkaMenu.separator()]
        )
      ])

    # assert_renderable is blind here: mix.exs whitelists these names so the
    # helper considers them renderable, while MobBridge's `when (node.type)`
    # has no else branch and simply draws nothing. Only an explicit check
    # catches a marker the expander forgot to consume — and a submenu recurses,
    # so "at any depth" is the part that matters.
    for type <- MishkaMenu.slot_types() do
      assert find_all(tree, type) == [], "#{type} leaked to the renderer"
    end
  end
end
