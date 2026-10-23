defmodule MishkaMob.Showcase.FloatingWindowPageTest do
  # async: false — the registry and composite registry are global (persistent_term).
  use Mob.ScreenCase, async: false

  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

  # The body's own Column pads `:space_md` on every side, and the default theme
  # spells that 16dp. It comes out of the top AND the bottom of the body box.
  @body_padding 16

  # A line of body text is 24dp on Material even at a small text_size, and a
  # padded, bordered button is a line plus 8dp each side plus the border: 42dp.
  @line 24
  @button 42
  @gap 8

  setup do
    Showcase.reset()
    Showcase.register_all()
    :ok
  end

  defp page do
    ComponentScreen
    |> mount_screen(%{slug: :floating_window})
    |> tree()
    |> Mob.Composite.expand(self())
  end

  defp tagged(tree, id), do: tree |> flatten() |> Enum.find(&(&1.props[:id] == id))

  # What the window leaves its content once the chrome and the body's padding
  # are paid for — the number a body's text is clipped to.
  defp room(tree, id) do
    tagged(tree, id <> "-body").props.height - 2 * @body_padding
  end

  # The windows whose bodies were drawn cut off: the body's box was shorter than
  # the text and the button in it, and a body is clipped, never scrolled.
  describe "every body has room for what is in it" do
    test "the nudge window holds its line" do
      assert room(page(), "step") >= @line
    end

    test "the closable window holds its line, the gap and the Ping button" do
      assert room(page(), "closable") >= @line + @gap + @button
    end

    test "the custom-handle window holds the two lines its text wraps to" do
      assert room(page(), "custom") >= 2 * @line
    end
  end

  test "the Ping button is laid out with its label" do
    ping = tagged(page(), "closable-ping")

    assert text(ping) =~ "Ping"
    assert ping.props.on_tap
  end

  describe "the box each window floats in" do
    test "holds the closable and the custom window with their bottoms inside it" do
      tree = page()

      for id <- ["closable", "custom"] do
        stage = tree |> tagged(id) |> then(&parent_of(tree, &1))
        panel = tagged(tree, id <> "-window")

        assert stage.props.height >= panel.props.offset_y + panel.props.height,
               "the #{id} window is taller than the box it floats in"
      end
    end

    test "leaves the nudge window one step to move down" do
      tree = page()

      root = tagged(tree, "step")
      panel = tagged(tree, "step-window")

      # The arrows move it by `step` (20), and the e2e taps down once.
      assert root.props.height - panel.props.height >= 20
    end
  end

  defp parent_of(tree, node), do: tree |> flatten() |> Enum.find(&(node in &1.children))
end
