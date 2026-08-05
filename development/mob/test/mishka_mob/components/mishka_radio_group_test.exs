defmodule MishkaMob.Components.MishkaRadioGroupTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaRadioGroup
  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

  doctest MishkaMob.Components.MishkaRadioGroup

  defp opts do
    [
      MishkaRadioGroup.option(:free, "Free"),
      MishkaRadioGroup.option(:pro, "Pro"),
      MishkaRadioGroup.option(:team, "Team", disabled: true)
    ]
  end

  defp build(props),
    do: MishkaRadioGroup.radio_group(Map.merge(%{on_change: :plan}, props), opts())

  # each option renders as a Radio row
  defp rows(tree), do: find_all(tree, :row) |> Enum.filter(&(text(&1) != ""))

  describe "select/2" do
    test "a tap selects the tapped option" do
      assert MishkaRadioGroup.select(:a, :b) == :b
      assert MishkaRadioGroup.select(nil, :a) == :a
    end

    test "re-tapping the selection KEEPS it — a radio group cannot be cleared" do
      assert MishkaRadioGroup.select(:a, :a) == :a
    end
  end

  describe "selection" do
    test "exactly one option is checked" do
      tree = build(%{value: :pro})
      dots = tree |> find_all(:box) |> Enum.filter(&(&1.props[:border_width] == 2))

      assert length(dots) == 1
    end

    test "no value means nothing is checked" do
      tree = build(%{})

      assert tree |> find_all(:box) |> Enum.filter(&(&1.props[:border_width] == 2)) == []
    end

    test "every option label renders" do
      tree = build(%{value: :pro})

      for label <- ["Free", "Pro", "Team"], do: assert(text(tree) =~ label)
    end
  end

  describe "the group tag" do
    test "every option reports the same tag widened with its own id" do
      taps = build(%{value: :free}) |> rows() |> Enum.map(& &1.props[:on_tap])

      assert [{pid, {:plan, :free}}, {_, {:plan, :pro}}, nil] = taps
      assert pid == self()
    end

    test "no on_change means no option is tappable" do
      tree = MishkaRadioGroup.radio_group(%{value: :free}, opts())

      assert Enum.all?(rows(tree), &(&1.props[:on_tap] == nil))
    end
  end

  describe "disabled" do
    test "a single disabled option is inert while the rest work" do
      taps = build(%{value: :free}) |> rows() |> Enum.map(& &1.props[:on_tap])

      assert List.last(taps) == nil
      refute Enum.at(taps, 0) == nil
    end

    test "a disabled group cascades to every option" do
      tree = build(%{value: :free, disabled: true})

      assert Enum.all?(rows(tree), &(&1.props[:on_tap] == nil))
    end
  end

  describe "layout" do
    test "vertical by default, horizontal on request" do
      assert %{type: :column} = layout(build(%{}))
      assert %{type: :row} = layout(build(%{orientation: :horizontal}))
    end

    test "horizontal options hug; stacked options fill" do
      # Side by side, a filling option takes the whole row and pushes the rest
      # off-screen — the bug the horizontal e2e test caught. Stacked, filling is
      # what makes the label part of the tap target.
      #
      # option_rows, not rows/1: in a horizontal group the CONTAINER is a row
      # too, and it fills on purpose.
      assert Enum.all?(
               option_rows(build(%{orientation: :horizontal})),
               &(&1.props.fill_width == false)
             )

      assert Enum.all?(option_rows(build(%{})), &(&1.props.fill_width == true))
    end

    test "space sets the gap between options" do
      tree = build(%{space: 30})
      gaps = layout(tree).children |> Enum.filter(&(&1.type == :spacer))

      assert Enum.all?(gaps, &(&1.props.size == 30))
    end

    test "the label renders above the options, and is omitted when absent" do
      assert text(build(%{label: "PLAN"})) =~ "PLAN"
      assert hd(build(%{}).children).type != :text
    end

    test "colour and size reach every option" do
      tree = build(%{value: :free, color: 0xFF7C3AED, size: 30})

      assert Enum.any?(find_all(tree, :box), &(&1.props[:width] == 30))
      assert Enum.any?(find_all(tree, :box), &(&1.props[:border_color] == 0xFF7C3AED))
    end
  end

  describe "option test tags" do
    # The selection is a dot, not text, so a device test can only see it through
    # these tags — and it needs to name ONE option, hence the composed prefix.
    test "each option's ring is tagged <group>-<option>-<state>" do
      ids = build(%{id: "plan", value: :pro}) |> find_all(:box) |> Enum.map(& &1.props[:id])

      assert "plan-free-empty" in ids
      assert "plan-pro-selected" in ids
      assert "plan-team-empty" in ids
    end

    test "no group id leaves every option untagged" do
      ids = build(%{value: :pro}) |> find_all(:box) |> Enum.map(& &1.props[:id])

      assert Enum.all?(ids, &is_nil/1)
    end
  end

  describe "the option slot tag" do
    # What the sigil hands expand/3 for `<MishkaRadioGroupOption id={…} … />`:
    # a plain node with no module and no expander of its own.
    defp option_tag(id, label, props \\ %{}),
      do: %{
        type: :mishka_radio_group_option,
        props: Map.merge(%{id: id, label: label}, props),
        children: []
      }

    defp ctx, do: %{screen: self()}

    test "<MishkaRadioGroupOption> expands to exactly what option/3 builds" do
      # Interchangeable rather than merely similar: markup for options written
      # out, option/3 for options that come from data, and no way to tell from
      # the tree which one the caller reached for.
      by_tag =
        MishkaRadioGroup.expand(
          %{value: :pro, on_change: :plan, id: "plan"},
          [
            option_tag(:free, "Free"),
            option_tag(:pro, "Pro"),
            option_tag(:team, "Team", %{disabled: true})
          ],
          ctx()
        )

      by_function =
        MishkaRadioGroup.expand(%{value: :pro, on_change: :plan, id: "plan"}, opts(), ctx())

      assert by_tag == by_function
    end

    test "an option tag with no disabled prop is enabled, like option/2" do
      tree =
        MishkaRadioGroup.expand(
          %{value: :free, on_change: :plan},
          [option_tag(:pro, "Pro")],
          ctx()
        )

      assert [{_pid, {:plan, :pro}}] = rows(tree) |> Enum.map(& &1.props[:on_tap])
    end

    test "no option marker survives expansion" do
      tree =
        MishkaRadioGroup.expand(
          %{value: :free},
          [option_tag(:free, "Free"), MishkaRadioGroup.option(:pro, "Pro")],
          ctx()
        )

      # assert_renderable is blind to this: mix.exs whitelists the slot tag's
      # name, so the helper counts it renderable, while MobBridge's
      # `when (node.type)` has no branch for it and silently draws nothing. Only
      # naming the marker catches an expander that forgot to consume it.
      assert find_all(tree, :mishka_radio_group_option) == []
    end
  end

  # The gallery page is what RadioGroupTest.kt drives, and it is now written in
  # slot tags — so the page is where the tag form is proved end to end, through
  # the real composite pass rather than a hand-built child list.
  describe "the gallery page" do
    setup do
      Showcase.reset()
      Showcase.register_all()

      :ok
    end

    defp page, do: ComponentScreen |> mount_screen(%{slug: :radio_group}) |> expanded()

    defp expanded(view), do: Mob.Composite.expand(tree(view), self())

    defp ring_tags(tree),
      do: tree |> flatten() |> Enum.map(&get_in(&1, [:props, :id])) |> Enum.reject(&is_nil/1)

    test "every ring the device test names is still tagged" do
      tags = ring_tags(page())

      # The suffix is state, and RadioGroupTest taps its way through several
      # states — so name the ring, not the state it happens to be in at mount.
      # (`rg-off-pro` is `-selected` here and `-empty` by the time the device
      # test reads it, because that test first moves the plan off :pro.)
      for ring <- ~w(rg-plan-free rg-plan-pro rg-size-m rg-off-pro rg-off-free) do
        assert "#{ring}-empty" in tags or "#{ring}-selected" in tags,
               "the #{ring} ring is missing"
      end
    end

    test "no option marker reaches the renderer from the page either" do
      assert find_all(page(), :mishka_radio_group_option) == []
    end
  end

  test "expand/3 reads option children and ignores anything else" do
    stray = %{type: :text, props: %{text: "stray"}, children: []}
    tree = MishkaRadioGroup.expand(%{value: :free}, opts() ++ [stray], %{screen: self()})

    refute text(tree) =~ "stray"
    assert length(rows(tree)) == 3
  end

  test "every variant renders" do
    for props <- [%{}, %{value: :pro}, %{disabled: true}, %{orientation: :horizontal}] do
      assert_renderable(build(props))
    end
  end

  # the options container is the last child of the group column
  defp layout(tree), do: List.last(tree.children)

  # the option rows themselves — direct children of that container
  defp option_rows(tree), do: layout(tree).children |> Enum.filter(&(&1.type == :row))
end
