defmodule MishkaMob.Components.MishkaPreviewCardTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`, and the
  # gallery block below writes the global composite registry.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaPopover, MishkaPreviewCard, MishkaScroller}
  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

  defp footer, do: [%{type: :button, props: %{text: "Follow"}, children: []}]
  defp chip, do: [%{type: :text, props: %{text: "@shahryar"}, children: []}]

  defp card(extra \\ %{}) do
    MishkaPreviewCard.preview_card(
      Map.merge(%{open: true, title: "Shahryar", subtitle: "@shahryar", initials: "SH"}, extra),
      footer()
    )
  end

  defp ids(tree), do: tree |> flatten() |> Enum.map(& &1.props[:id]) |> Enum.reject(&is_nil/1)

  defp tagged?(tree, id), do: id in ids(tree)

  defp starting(tree, prefix),
    do: Enum.find(flatten(tree), &String.starts_with?(&1.props[:id] || "", prefix))

  defp popup(tree), do: starting(tree, "p-popup")
  defp arrow(tree), do: starting(tree, "p-arrow")

  describe "the closed card" do
    test "with no trigger it is still nothing at all" do
      assert MishkaPreviewCard.preview_card(%{title: "x"}) ==
               %{type: :column, props: %{}, children: []}
    end

    test "an id survives the closed state, because that is what proves it closed" do
      # A device test cannot assert the absence of a colour; it asserts that
      # `<id>-open` is gone and `<id>-closed` is there.
      tree = MishkaPreviewCard.preview_card(%{id: "p", title: "x"})

      assert tree.props.id == "p-closed"
      assert tree.children == []
    end

    test "the trigger renders while the card does not — it is what you hold" do
      tree = MishkaPreviewCard.preview_card(%{id: "p", trigger: chip(), on_hold: :hold})

      assert tree.props.id == "p-closed"
      assert text(tree) =~ "@shahryar"
      assert tagged?(tree, "p-trigger")
      refute tagged?(tree, "p-popup-bottom")
    end
  end

  describe "the trigger" do
    test "a long press is the touch hover, and reports the card's own id" do
      tree = MishkaPreviewCard.preview_card(%{id: "p", trigger: chip(), on_hold: :hold})

      assert find(tree, :box, id: "p-trigger").props[:on_long_press] == {self(), {:hold, "p"}}
    end

    test "a plain tap is a separate prop, so the hold cannot swallow the link" do
      tree =
        MishkaPreviewCard.preview_card(%{
          id: "p",
          trigger: chip(),
          on_hold: :hold,
          on_tap: :visit
        })

      trigger = find(tree, :box, id: "p-trigger")

      assert trigger.props[:on_tap] == {self(), {:visit, "p"}}
      assert trigger.props[:on_long_press] == {self(), {:hold, "p"}}
    end

    test "with no handler it carries no dead handler prop" do
      trigger =
        MishkaPreviewCard.preview_card(%{id: "p", trigger: chip()})
        |> find(:box, id: "p-trigger")

      refute Map.has_key?(trigger.props, :on_tap)
      refute Map.has_key?(trigger.props, :on_long_press)
    end

    test "trigger/3 is public, for a trigger the card cannot reach" do
      node =
        MishkaPreviewCard.trigger("elixir", chip(), on_hold: :peek, test_id: "elixir-trigger")

      assert node.props.id == "elixir-trigger"
      assert node.props.on_long_press == {self(), {:peek, "elixir"}}
      assert node.props.fill_width == true
    end

    test "a single node is accepted as well as a list" do
      tree = MishkaPreviewCard.preview_card(%{id: "p", trigger: hd(chip())})

      assert text(tree) =~ "@shahryar"
    end
  end

  describe "side" do
    test "bottom is the default: trigger, gap, then card" do
      tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, trigger: chip(), title: "T"})

      assert tree.type == :column
      assert tree.props.id == "p-open"
      assert Enum.map(tree.children, & &1.props[:id]) == ["p-trigger", nil, "p-popup-bottom"]
    end

    test "top puts the card first, so it sits over the trigger" do
      tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, side: :top, trigger: chip()})

      assert tree.type == :column
      assert Enum.map(tree.children, & &1.props[:id]) == ["p-popup-top", nil, "p-trigger"]
    end

    test "left and right lay the pair out as a Row" do
      for {side, order} <- [
            {:right, ["p-trigger", nil, "p-popup-right"]},
            {:left, ["p-popup-left", nil, "p-trigger"]}
          ] do
        tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, side: side, trigger: chip()})

        assert tree.type == :row
        assert Enum.map(tree.children, & &1.props[:id]) == order
      end
    end

    test "beside the trigger BOTH halves are weighted, so neither starves the other" do
      # A Box with neither a width nor fill_width fills its parent, and Compose
      # measures a Row's unweighted children first — an unweighted half would
      # take the whole row.
      tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, side: :right, trigger: chip()})
      trigger = find(tree, :box, id: "p-trigger")

      assert trigger.props[:weight] == 1
      assert popup(tree).props[:weight] == 1
      refute Map.has_key?(trigger.props, :fill_width)
    end

    test "above or below, the trigger fills the width and carries no weight" do
      tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, trigger: chip()})
      trigger = find(tree, :box, id: "p-trigger")

      assert trigger.props[:fill_width] == true
      refute Map.has_key?(trigger.props, :weight)
    end

    test "the side is folded into the popup's tag, since a position is not queryable" do
      for side <- [:top, :right, :bottom, :left] do
        tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, side: side})
        assert tagged?(tree, "p-popup-#{side}")
      end
    end

    test "the web's string values are accepted, and anything else falls back" do
      for {given, expected} <- [{"top", "top"}, {"nope", "bottom"}, {7, "bottom"}] do
        tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, side: given})
        assert tagged?(tree, "p-popup-#{expected}")
      end
    end
  end

  describe "the arrow" do
    test "is off unless asked for, exactly as the web slot is" do
      assert arrow(MishkaPreviewCard.preview_card(%{id: "p", open: true})) == nil
    end

    test "points BACK at the trigger, so the glyph is the opposite of the side" do
      for {side, glyph} <- [{:bottom, "▲"}, {:top, "▼"}, {:left, "▶"}, {:right, "◀"}] do
        tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, side: side, arrow: true})
        assert arrow(tree).props.text == glyph
      end
    end

    test "the alignment is folded into its tag, since a position is not queryable" do
      for align <- [:start, :center, :end] do
        tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, arrow: true, align: align})
        assert arrow(tree).props.id == "p-arrow-#{align}"
      end
    end

    test "align moves it along the edge with flexible spacers" do
      weights = fn align ->
        tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, arrow: true, align: align})
        row = find(tree, :row, fill_width: true)
        Enum.map(row.children, &{&1.type, &1.props[:size], &1.props[:weight]})
      end

      assert [{:spacer, 14, nil}, {:text, nil, nil}, {:spacer, nil, 1}] = weights.(:start)
      assert [{:spacer, nil, 1}, {:text, nil, nil}, {:spacer, nil, 1}] = weights.(:center)
      assert [{:spacer, nil, 1}, {:text, nil, nil}, {:spacer, 14, nil}] = weights.(:end)
    end

    test "beside the trigger it is the row's own alignment that places it" do
      # A Column has no horizontal alignment prop to hang `align` off, so on the
      # horizontal axis the root Row's vertical alignment is what moves it.
      for {align, value} <- [{:start, "top"}, {:center, "center"}, {:end, "bottom"}] do
        tree =
          MishkaPreviewCard.preview_card(%{
            id: "p",
            open: true,
            side: :right,
            align: align,
            arrow: true
          })

        assert tree.props.align == value
        assert arrow(tree).type == :text
      end
    end

    test "align_offset nudges it along the alignment axis, and only when non-zero" do
      vertical =
        MishkaPreviewCard.preview_card(%{id: "p", open: true, arrow: true, align_offset: 6})

      horizontal =
        MishkaPreviewCard.preview_card(%{
          id: "p",
          open: true,
          side: :left,
          arrow: true,
          align_offset: 6
        })

      assert arrow(vertical).props.offset_x == 6
      assert arrow(horizontal).props.offset_y == 6

      plain = MishkaPreviewCard.preview_card(%{id: "p", open: true, arrow: true})
      refute Map.has_key?(arrow(plain).props, :offset_x)
    end

    test "arrow_color is a token, never a hardcoded ink" do
      default = MishkaPreviewCard.preview_card(%{id: "p", open: true, arrow: true})

      tinted =
        MishkaPreviewCard.preview_card(%{id: "p", open: true, arrow: true, arrow_color: :primary})

      assert arrow(default).props.text_color == :border
      assert arrow(tinted).props.text_color == :primary
    end

    test "it is one line — a glyph squeezed narrow would wrap like any Text" do
      tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, arrow: true})

      assert arrow(tree).props.max_lines == 1
    end
  end

  describe "side_offset" do
    test "is the real gap between the trigger and the card" do
      tree =
        MishkaPreviewCard.preview_card(%{id: "p", open: true, trigger: chip(), side_offset: 20})

      assert Enum.at(tree.children, 1) == %{type: :spacer, props: %{size: 20}, children: []}
    end

    test "defaults to the web's 8" do
      tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, trigger: chip()})

      assert Enum.at(tree.children, 1).props.size == 8
    end

    test "zero closes the gap entirely" do
      tree =
        MishkaPreviewCard.preview_card(%{id: "p", open: true, trigger: chip(), side_offset: 0})

      assert Enum.map(tree.children, & &1.props[:id]) == ["p-trigger", "p-popup-bottom"]
    end

    test "with no trigger there is no pair to separate" do
      tree = MishkaPreviewCard.preview_card(%{id: "p", open: true, side_offset: 20})

      assert Enum.map(tree.children, & &1.props[:id]) == ["p-popup-bottom"]
    end
  end

  describe "the card" do
    test "uses the Popover surface, so it cannot drift from the other panels" do
      panel = MishkaPopover.panel(%{}, [])

      assert popup(card(%{id: "p"})).props.border_color == panel.props.border_color
      assert popup(card(%{id: "p"})).props.corner_radius == panel.props.corner_radius
    end

    test "renders title, subtitle, description and footer" do
      tree = card(%{description: "Builds things."})

      assert text(tree) =~ "Shahryar"
      assert text(tree) =~ "@shahryar"
      assert text(tree) =~ "Builds things."
      assert find(tree, :button, text: "Follow")
    end

    test "every part is addressable by tag, not by a page-wide text query" do
      tree = card(%{id: "p", description: "Builds things."})

      for suffix <- ~w(-open -popup-bottom -title -subtitle -description -avatar -footer) do
        assert tagged?(tree, "p" <> suffix), "missing p#{suffix}"
      end
    end

    test "without an id nothing carries a stray nil tag" do
      assert ids(card(%{description: "d"})) == []
    end

    test "every part is optional" do
      tree = MishkaPreviewCard.preview_card(%{open: true, title: "Ecto"})

      assert text(tree) =~ "Ecto"
      assert find_all(tree, :button) == []
    end

    test "no initials and no image means no avatar, not an empty circle" do
      bare = MishkaPreviewCard.preview_card(%{id: "p", open: true, title: "Ecto"})

      refute tagged?(bare, "p-avatar")
      assert tagged?(card(%{id: "p"}), "p-avatar")
    end

    test "the names carry the weight, so the avatar is not starved" do
      # Compose measures a Row's unweighted children first: a text column left
      # to fill the width would be measured before the avatar beside it.
      names = card() |> find_all(:box) |> Enum.find(&(&1.props[:weight] == 1))

      assert names
      assert text(names) =~ "Shahryar"
    end

    test "the names are one line each; only the body may wrap" do
      tree = card(%{id: "p", description: "A long body that is allowed to wrap."})

      assert find(tree, :text, id: "p-title").props.max_lines == 1
      assert find(tree, :text, id: "p-subtitle").props.max_lines == 1
      refute Map.has_key?(find(tree, :text, id: "p-description").props, :max_lines)
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

    test "popover props are forwarded to the panel" do
      tree = card(%{id: "p", padding: :space_lg, background: :surface_raised})

      assert popup(tree).props.padding == :space_lg
      assert popup(tree).props.background == :surface_raised
    end
  end

  describe "the composite tag" do
    setup do
      Mob.Composite.reset()
      Showcase.reset()
      Showcase.register_all()
      :ok
    end

    test "nodes handed in through the trigger PROP are still expanded" do
      # Mob.Composite walks children, not props — a composite passed as a prop
      # would reach the renderer unexpanded if it were not placed back into the
      # output tree, where the fixpoint pass finds it.
      node = %{
        type: :mishka_preview_card,
        props: %{
          id: "p",
          open: true,
          trigger: [%{type: :mishka_avatar, props: %{initials: "SH"}, children: []}]
        },
        children: []
      }

      tree = Mob.Composite.expand(node, self())

      assert_renderable(tree)
      assert text(tree) =~ "SH"
    end

    test "on_hold written as a bare tag still reaches the renderer wired" do
      node = %{
        type: :mishka_preview_card,
        props: %{id: "p", trigger: chip(), on_hold: :hold},
        children: []
      }

      tree = Mob.Composite.expand(node, self())

      assert find(tree, :box, id: "p-trigger").props.on_long_press == {self(), {:hold, "p"}}
    end
  end

  describe "the gallery page" do
    setup do
      Mob.Composite.reset()
      Showcase.reset()
      Showcase.register_all()
      :ok
    end

    defp page, do: mount_screen(ComponentScreen, %{slug: :preview_card})
    defp page_tags(view), do: view |> tree() |> Mob.Composite.expand(self()) |> ids()

    test "renders, and starts with every card closed" do
      view = page()

      assert_renderable(Mob.Composite.expand(tree(view), self()))
      tags = page_tags(view)

      assert "pc-elixir-closed" in tags
      assert "pc-phoenix-closed" in tags
      refute "pc-elixir-open" in tags
    end

    test "holding a name opens its card and nothing else's" do
      tags = page() |> render_info({:tap, {:pc_hold, "pc-elixir"}}) |> page_tags()

      assert "pc-elixir-open" in tags
      assert "pc-elixir-popup-bottom" in tags
      assert "pc-elixir-arrow-center" in tags
      assert "pc-phoenix-closed" in tags
      refute "pc-phoenix-open" in tags
    end

    test "holding the other one moves the card rather than opening a second" do
      tags =
        page()
        |> render_info({:tap, {:pc_hold, "pc-elixir"}})
        |> render_info({:tap, {:pc_hold, "pc-phoenix"}})
        |> page_tags()

      assert "pc-phoenix-open" in tags
      refute "pc-elixir-open" in tags
    end

    test "holding the open one closes it again" do
      tags =
        page()
        |> render_info({:tap, {:pc_hold, "pc-elixir"}})
        |> render_info({:tap, {:pc_hold, "pc-elixir"}})
        |> page_tags()

      assert "pc-elixir-closed" in tags
      refute "pc-elixir-open" in tags
    end

    test "a tap is not a hold — it visits, and leaves the card shut" do
      tags = page() |> render_info({:tap, {:pc_visit, "pc-elixir"}}) |> page_tags()

      assert "pc-visited-pc-elixir" in tags
      refute "pc-elixir-open" in tags
    end

    test "the footer button works, and says so in its tag" do
      view = render_info(page(), {:tap, {:pc_hold, "pc-elixir"}})
      assert "pc-elixir-follow-off" in page_tags(view)

      followed = render_info(view, {:tap, {:pc_follow, "pc-elixir"}})
      assert "pc-elixir-follow-on" in page_tags(followed)
      assert "pc-followed-pc-elixir" in page_tags(followed)
    end

    test "the side examples own their own assigns, so one hold moves one card" do
      view = render_info(page(), {:tap, {:pc_top_hold, "pc-top"}})
      tags = page_tags(view)

      assert "pc-top-popup-top" in tags
      assert "pc-top-arrow-end" in tags
      assert "pc-side-closed" in tags

      beside = view |> render_info({:tap, {:pc_side_hold, "pc-side"}}) |> page_tags()
      assert "pc-side-popup-right" in beside
      assert "pc-side-arrow-start" in beside
      assert "pc-top-popup-top" in beside
    end

    test "the pinned example needs no hold at all" do
      tags = page_tags(page())

      assert "pc-static-popup-bottom" in tags
      assert "pc-static-avatar" in tags
      assert "pc-bare-popup-bottom" in tags
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
    for extra <- [
          %{},
          %{description: "d"},
          %{image: "u"},
          %{id: "p", trigger: chip(), on_hold: :hold, arrow: true},
          %{id: "p", trigger: chip(), side: :top, align: :end, arrow: true},
          %{id: "p", trigger: chip(), side: :left, align: :start, arrow: true},
          %{id: "p", trigger: chip(), side: :right, align: :center, arrow: true, open: false}
        ] do
      assert_renderable(card(extra))
    end

    assert_renderable(MishkaScroller.scroller(%{on_next: :x}, rail()))
  end
end
