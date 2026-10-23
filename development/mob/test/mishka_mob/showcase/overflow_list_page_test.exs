defmodule MishkaMob.Showcase.OverflowListPageTest do
  # async: false — the registry and composite registry are global (persistent_term).
  use Mob.ScreenCase, async: false

  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

  setup do
    Showcase.reset()
    Showcase.register_all()
    :ok
  end

  defp mounted, do: mount_screen(ComponentScreen, %{slug: :overflow_list})

  defp expanded(view), do: view |> tree() |> Mob.Composite.expand(self())

  defp shown(view, list) do
    view
    |> expanded()
    |> flatten()
    |> Enum.filter(&String.starts_with?(to_string(&1.props[:id]), list <> "-item-"))
    |> Enum.map(&(&1.props[:text] || text(&1)))
  end

  # Each tap adds an item to a row whose width the page cannot measure. "LiveView"
  # as the fourth item did not fit a 385dp phone, so the first tap showed it as
  # "Li…". The short labels leave room for several taps.
  describe "the tap-to-reveal example" do
    test "starts on three short labels" do
      assert shown(mounted(), "more") == ["Elixir", "Beam", "OTP"]
    end

    test "one tap reveals one more, and it is still a short one" do
      view = render_info(mounted(), {:tap, :more})

      assert shown(view, "more") == ["Elixir", "Beam", "OTP", "Mob"]
    end

    test "it stops revealing at the labels there are" do
      view = Enum.reduce(1..20, mounted(), fn _, acc -> render_info(acc, {:tap, :more}) end)

      assert Enum.count_until(shown(view, "more"), 8) == 7
      assert assigns(view).visible == 7
    end
  end

  test "the other lists keep the long labels" do
    assert shown(mounted(), "langs") == ["Design", "Phoenix", "Elixir"]
  end
end
