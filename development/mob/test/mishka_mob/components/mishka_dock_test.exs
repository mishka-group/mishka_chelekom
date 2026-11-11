defmodule MishkaMob.Components.MishkaDockTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaDock, MishkaDockItem}

  defp item(icon), do: MishkaDockItem.dock_item(%{icon: icon})

  describe "the bar" do
    test "is a fill-width Row holding the bar and the optional action" do
      fab = %{type: :box, props: %{width: 64, height: 64}, children: []}
      node = MishkaDock.dock(%{fab: fab}, [item("a")])

      assert node.type == :row
      assert node.props.fill_width == true
      assert [bar, ^fab] = node.children
      assert bar.type == :box
      assert bar.props.height == 64
      assert bar.props.corner_radius == :radius_pill
      assert [%{type: :row}] = bar.children
    end

    test "bar props come from the dock props and are absent when unset" do
      node = MishkaDock.dock(%{background: 0xFF112233, shadow: "0 1 2 0 #00000000"}, [])

      [bar] = node.children
      assert bar.props.background == 0xFF112233
      assert bar.props.shadow == "0 1 2 0 #00000000"
      refute Map.has_key?(bar.props, :border_width)
    end

    test "height and corner_radius are overridable" do
      node = MishkaDock.dock(%{height: 56, corner_radius: 28}, [])

      [bar] = node.children
      assert bar.props.height == 56
      assert bar.props.corner_radius == 28
    end

    test "padding is forwarded to the dock row" do
      node = MishkaDock.dock(%{padding_left: 18, padding_bottom: 30}, [])

      assert node.props.padding_left == 18
      assert node.props.padding_bottom == 30
    end

    test "renders" do
      assert_renderable(MishkaDock.dock(%{background: :surface_raised}, [item("a"), item("b")]))
    end
  end

  describe "an item" do
    test "takes an equal share and centres its glyph in a well" do
      node = MishkaDockItem.dock_item(%{icon: "a"})

      assert node.type == :box
      assert node.props.weight == 1.0
      assert node.props.align == :center

      assert [well] = node.children
      assert well.type == :box
      assert well.props.width == 46
      assert well.props.height == 46
      assert well.props.corner_radius == 23.0
    end

    test "the active look comes from the active props" do
      node =
        MishkaDockItem.dock_item(%{
          icon: "a",
          active: true,
          background: 0xFF000000,
          active_background: 0xFFEFECE7,
          color: 0xFF111111,
          active_color: 0xFF1A1917
        })

      assert [well] = node.children
      assert well.props.background == 0xFFEFECE7
      assert text_color(well) == 0xFF1A1917
    end

    test "the inactive look is the unprefixed props" do
      node =
        MishkaDockItem.dock_item(%{
          icon: "a",
          background: 0x00000000,
          active_background: 0xFFEFECE7,
          color: 0xFF111111,
          active_color: 0xFF1A1917
        })

      assert [well] = node.children
      assert well.props.background == 0x00000000
      assert text_color(well) == 0xFF111111
    end

    test "an unset active_* falls back to the unprefixed prop" do
      node =
        MishkaDockItem.dock_item(%{
          icon: "a",
          active: true,
          background: 0xFF000000,
          color: 0xFF111111
        })

      assert [well] = node.children
      assert well.props.background == 0xFF000000
      assert text_color(well) == 0xFF111111
    end

    test "on_tap is widened" do
      assert MishkaDockItem.dock_item(%{on_tap: :home}).props.on_tap == {self(), :home}
    end

    test "renders" do
      assert_renderable(MishkaDockItem.dock_item(%{icon: "a", on_tap: :a}))
    end
  end

  test "expand/3 delegates" do
    children = [item("a")]

    assert MishkaDock.expand(%{background: :surface}, children, %{screen: self()}) ==
             MishkaDock.dock(%{background: :surface}, children)

    assert MishkaDockItem.expand(%{icon: "a"}, [], %{screen: self()}) ==
             MishkaDockItem.dock_item(%{icon: "a"})
  end

  defp text_color(well) do
    well
    |> find_all(:text)
    |> hd()
    |> Map.get(:props)
    |> Map.get(:text_color)
  end
end
