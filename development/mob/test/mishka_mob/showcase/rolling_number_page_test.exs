defmodule MishkaMob.Showcase.RollingNumberPageTest do
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
    view = mount_screen(ComponentScreen, %{slug: :rolling_number})

    view |> tree() |> Mob.Composite.expand(self())
  end

  defp button(tree, label), do: find(tree, :button, text: label)

  describe "the buttons" do
    # On a 385dp phone half the example's row is about 150dp. Take the Button's
    # own 24dp padding on each side and the 8dp the node pads itself with, and
    # what is left for "Roll to 1,284" is about 84dp: the label drew as
    # "Roll to 1,…". The example now stacks them, so each gets the whole row.
    test "Roll and Reset are not halves of a row" do
      tree = page()

      for row <- find_all(tree, :row) do
        buttons = Enum.filter(row.children, &(&1.type == :button))

        assert Enum.count_until(buttons, 2) < 2,
               "a row shares its width between #{inspect(Enum.map(buttons, & &1.props.text))}"
      end
    end

    test "each takes the full width, not a weight" do
      tree = page()

      for label <- ["Roll to 1,284", "Reset", "Roll down to 42"] do
        node = button(tree, label)

        assert node.props.fill_width == true, "#{label} does not fill its column"

        # A weight in a Column shares HEIGHT, which is what a leftover from the
        # Row version would silently do.
        refute Map.has_key?(node.props, :weight), "#{label} still carries a weight"
      end
    end
  end

  test "the stacked buttons are still wired to the screen" do
    tree = page()

    assert {_pid, :rn_roll} = button(tree, "Roll to 1,284").props.on_tap
    assert {_pid, :rn_reset} = button(tree, "Reset").props.on_tap
    assert {_pid, :rn_down} = button(tree, "Roll down to 42").props.on_tap
  end

  test "tapping Roll starts the count and Reset puts it back" do
    view =
      ComponentScreen
      |> mount_screen(%{slug: :rolling_number})
      |> render_info({:tap, :rn_roll})

    assert assigns(view).rn_value > 0

    view = render_info(view, {:tap, :rn_reset})

    assert assigns(view).rn_value == 0
  end
end
