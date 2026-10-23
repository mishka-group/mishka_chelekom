defmodule MishkaMob.Showcase.PillPageTest do
  # async: false — the registry and composite registry are global (persistent_term).
  use Mob.ScreenCase, async: false

  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

  setup do
    Showcase.reset()
    Showcase.register_all()
    :ok
  end

  defp page do
    ComponentScreen
    |> mount_screen(%{slug: :pill})
    |> tree()
    |> Mob.Composite.expand(self())
  end

  # The token pills: the ones carrying a ✕, as the other examples do too but
  # only these are "Item n".
  defp tokens(tree) do
    tree
    |> find_all(:box)
    |> Enum.filter(&(&1.props[:corner_radius] == :radius_pill and text(&1) =~ "Item "))
  end

  defp label(pill), do: find(pill, :text)
  defp gap(pill), do: pill |> flatten() |> Enum.find(&(&1.type == :spacer))
  defp cross(pill), do: pill |> find_all(:text) |> Enum.find(&(&1.props[:text] == "✕"))

  # Three of these share a row, and a row does not wrap or shrink them: what the
  # row cannot hold is taken off the LAST pill, whose ✕ is the last thing
  # measured, and the glyph is clipped sideways. At the default 16sp and an 8dp
  # gap a pill is about 86dp, 274dp for the row, and a 360dp phone has 262dp
  # inside the example's box. 14sp and a 6dp gap are about 77dp, 247dp.
  describe "the token pills fit three to a row on a 360dp phone" do
    test "they are drawn at the compact size, label and ✕ alike" do
      pills = tokens(page())

      assert Enum.count_until(pills, 11) == 10

      for pill <- pills do
        assert label(pill).props.text_size == :sm
        assert cross(pill).props.text_size == :sm
      end
    end

    test "with a 6dp gap before the ✕" do
      for pill <- tokens(page()) do
        assert gap(pill).props.size == 6
      end
    end

    test "inside a box that pads 8dp rather than 16dp" do
      tree = page()

      box =
        tree
        |> find_all(:box, border_width: 1)
        |> Enum.find(fn box -> tokens(box) != [] end)

      assert box.props.padding == :space_sm
    end
  end

  test "three still share a row, which is what the e2e wraps on" do
    rows =
      page()
      |> find_all(:row)
      |> Enum.map(fn row ->
        Enum.filter(row.children, &(&1.props[:corner_radius] == :radius_pill))
      end)
      |> Enum.reject(&(&1 == [] or not Enum.all?(&1, fn pill -> text(pill) =~ "Item " end)))

    assert Enum.map(rows, &length/1) == [3, 3, 3, 1]
  end
end
