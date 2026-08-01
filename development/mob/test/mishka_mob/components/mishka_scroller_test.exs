defmodule MishkaMob.Components.MishkaScrollerTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`, so two
  # concurrent ScreenCase files race to start it (see mishka_accordion_test).
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaScroller

  defp all(node, type) do
    here = if node.type == type, do: [node], else: []
    here ++ Enum.flat_map(node.children || [], &all(&1, type))
  end

  describe "rail" do
    test "is a horizontal scroll area carrying the id, so it can be addressed" do
      scroll =
        MishkaScroller.scroller(%{id: "gallery"}, [%{type: :row, props: %{}, children: []}])

      assert %{props: %{axis: "horizontal", id: "gallery"}} = find(scroll, :scroll)
    end

    test "height bounds the rail" do
      assert %{props: %{height: 76}} =
               MishkaScroller.scroller(%{id: "g", height: 76}, []) |> find(:box)
    end

    test "controls: false is the rail alone — no arrows, no wrapper" do
      bare = MishkaScroller.scroller(%{id: "g", controls: false}, [])

      assert all(bare, :button) == []
      assert bare.type == :scroll
    end
  end

  describe "arrows" do
    # An arrow is an ActionIcon: a Box with an `on_tap`, not a Button. "Disabled"
    # there means the handler is simply omitted, which for a Box is genuinely
    # inert — a Box with no on_tap takes no clickable modifier at all.
    defp arrows(node), do: node |> all(:box) |> Enum.filter(&(&1.props[:width] == 40))

    test "carry their tags in reading order — prev first" do
      wired = MishkaScroller.scroller(%{id: "g", on_prev: :back, on_next: :fwd}, [])

      # `Event.handler/1` pre-widens a tag to {screen_pid, tag} on the way out,
      # so the wire value is the pair, not the bare atom.
      assert wired |> arrows() |> Enum.map(&elem(&1.props[:on_tap], 1)) == [:back, :fwd]
    end

    test "are tagged from the rail's id, because a glyph is not a handle" do
      tagged = MishkaScroller.scroller(%{id: "gallery", on_prev: :a, on_next: :b}, [])

      assert tagged |> arrows() |> Enum.map(& &1.props[:id]) == ["gallery-prev", "gallery-next"]
      assert MishkaScroller.arrow_ids("gallery") == {"gallery-prev", "gallery-next"}

      # No rail id, no arrow tags — nothing invents one.
      assert MishkaScroller.scroller(%{on_prev: :a}, [])
             |> arrows()
             |> Enum.all?(&(not Map.has_key?(&1.props, :id)))
    end

    test "with no handler an arrow still renders, but nothing can fire it" do
      bare = MishkaScroller.scroller(%{id: "g"}, []) |> arrows()

      assert length(bare) == 2
      assert Enum.all?(bare, &(not Map.has_key?(&1.props, :on_tap)))

      # It still says which way it points — an invisible control would be worse
      # than an inert one.
      assert text(MishkaScroller.scroller(%{id: "g"}, [])) =~ "‹"
    end
  end

  describe "nudge/3" do
    # The rail's offset lives in the native widget, so nudging is a side effect
    # with nothing to assign. Off-device there is no NIF at all: `:mob_nif`
    # raises `not_loaded`, and the whole point of rescuing that is so a pressed
    # arrow degrades to "nothing moved" instead of killing the screen — which is
    # what an iOS release build would otherwise do, where the scroll NIFs are
    # compiled out (IOS_TODO item 14).
    test "reports :unsupported rather than raising when the scroll NIF is absent" do
      assert MishkaScroller.nudge("gallery", :next) == :unsupported
      assert MishkaScroller.nudge("gallery", :prev, step: 120) == :unsupported
    end

    test "only accepts a real direction" do
      assert_raise FunctionClauseError, fn -> MishkaScroller.nudge("gallery", :sideways) end
    end
  end

  test "the rail renders" do
    assert_renderable(MishkaScroller.scroller(%{id: "g", on_prev: :a, on_next: :b}, []))
  end
end
