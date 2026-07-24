defmodule MishkaMob.Components.MishkaPreviewCardTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaPopover, MishkaPreviewCard, MishkaScroller}

  defp footer, do: [%{type: :button, props: %{text: "Follow"}, children: []}]

  defp card(extra \\ %{}) do
    MishkaPreviewCard.preview_card(
      Map.merge(%{open: true, title: "Shahryar", subtitle: "@shahryar", initials: "SH"}, extra),
      footer()
    )
  end

  describe "the card" do
    test "renders nothing when closed" do
      assert MishkaPreviewCard.preview_card(%{title: "x"}) ==
               %{type: :column, props: %{}, children: []}
    end

    test "uses the Popover surface, so it cannot drift from the other panels" do
      assert card().props.border_color == MishkaPopover.panel(%{}, []).props.border_color
      assert card().props.corner_radius == MishkaPopover.panel(%{}, []).props.corner_radius
    end

    test "renders title, subtitle, description and footer" do
      tree = card(%{description: "Builds things."})

      assert text(tree) =~ "Shahryar"
      assert text(tree) =~ "@shahryar"
      assert text(tree) =~ "Builds things."
      assert find(tree, :button, text: "Follow")
    end

    test "every part is optional" do
      tree = MishkaPreviewCard.preview_card(%{open: true, title: "Ecto"})

      assert text(tree) =~ "Ecto"
      assert find_all(tree, :button) == []
    end

    test "the avatar carries the initials and its colour" do
      tree = card(%{avatar_color: 0xFF7C3AED})

      assert text(tree) =~ "SH"
      assert tree |> find_all(:box) |> Enum.any?(&(&1.props[:background] == 0xFF7C3AED))
    end

    test "an image avatar renders an Image over the initials" do
      tree = card(%{image: "https://example.com/me.png"})

      assert find(tree, :image).props.src == "https://example.com/me.png"
    end
  end

  describe "the scroller" do
    defp rail, do: [%{type: :text, props: %{text: "items"}, children: []}]

    test "is a horizontal scroll area" do
      tree = MishkaScroller.scroller(%{}, rail())

      assert find(tree, :scroll).props.axis == "horizontal"
    end

    test "an id is passed through so the screen can address the live widget" do
      assert find(MishkaScroller.scroller(%{id: "gallery"}, rail()), :scroll).props.id ==
               "gallery"
    end

    test "the arrows emit events rather than pretending to scroll" do
      tree = MishkaScroller.scroller(%{on_prev: :back, on_next: :fwd}, rail())

      taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)
      assert taps == [{self(), :back}, {self(), :fwd}]
    end

    test "arrows with no handler render disabled, not inert-looking-enabled" do
      tree = MishkaScroller.scroller(%{}, rail())

      assert tree |> find_all(:box) |> Enum.all?(&(&1.props[:on_tap] == nil))
      # the glyphs are still there, muted
      assert text(tree) =~ "‹"
      assert text(tree) =~ "›"
    end

    test "controls: false drops them entirely" do
      tree = MishkaScroller.scroller(%{controls: false}, rail())

      refute text(tree) =~ "‹"
      assert tree.type in [:scroll, :box]
    end

    test "height bounds the rail" do
      tree = MishkaScroller.scroller(%{height: 80}, rail())

      assert tree |> find_all(:box) |> Enum.any?(&(&1.props[:height] == 80))
    end
  end

  test "expand/3 delegates for both" do
    assert MishkaPreviewCard.expand(%{open: true, title: "x"}, footer(), %{screen: self()}) ==
             MishkaPreviewCard.preview_card(%{open: true, title: "x"}, footer())

    assert MishkaScroller.expand(%{}, rail(), %{screen: self()}) ==
             MishkaScroller.scroller(%{}, rail())
  end

  test "every variant renders" do
    for extra <- [%{}, %{description: "d"}, %{image: "u"}] do
      assert_renderable(card(extra))
    end

    assert_renderable(MishkaScroller.scroller(%{on_next: :x}, rail()))
  end
end
