defmodule MishkaMob.Components.MishkaThemeIconTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaMarquee, MishkaThemeIcon}
  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

  defp icon(props, children \\ []), do: MishkaThemeIcon.theme_icon(props, children)

  defp tags(tree),
    do: tree |> find_all(:box) |> Enum.map(& &1.props[:id]) |> Enum.reject(&is_nil/1)

  defp canvas_ops(tree), do: find(tree, :canvas).props.draw

  describe "the container" do
    test "is one fixed square that centres its icon" do
      tree = icon(%{size: :lg})

      assert tree.type == :box
      assert tree.props.width == 40
      assert tree.props.height == 40
      assert tree.props.align == :center
    end

    test "the named size scale is the web's, in dp" do
      for {token, dp} <- MishkaThemeIcon.sizes() do
        assert icon(%{size: token}).props.width == dp
      end
    end

    test "a number is a size" do
      assert icon(%{size: 64}).props.width == 64
    end

    test "an unknown size token falls back to md rather than serialising as a string" do
      assert icon(%{size: :enormous}).props.width == MishkaThemeIcon.sizes().md
    end

    test "radius tokens land on the four the theme carries" do
      assert icon(%{radius: :none}).props.corner_radius == 0
      assert icon(%{radius: :sm}).props.corner_radius == :radius_sm
      assert icon(%{radius: :md}).props.corner_radius == :radius_md
      assert icon(%{radius: :lg}).props.corner_radius == :radius_lg
      assert icon(%{radius: :full}).props.corner_radius == :radius_pill
      assert icon(%{radius: 3}).props.corner_radius == 3
    end
  end

  describe "the icon" do
    test "the glyph shorthand is sized and tinted by the container" do
      glyph = find(icon(%{icon: "★", size: :xl}), :text)

      assert glyph.props.text == "★"
      assert glyph.props.text_size == round(48 * 0.55)
      assert glyph.props.text_color == :on_primary
    end

    test "the glyph is capped at one line, so a narrow box cannot stack its letters" do
      assert find(icon(%{icon: "AB", size: :xs}), :text).props.max_lines == 1
    end

    test "icon_color overrides whatever the variant chose" do
      assert find(icon(%{icon: "★", icon_color: :error}), :text).props.text_color == :error
    end

    test "children are the icon, and they win over the shorthand" do
      mine = %{type: :text, props: %{text: "mine"}, children: []}

      assert text(icon(%{icon: "★"}, [mine])) == "mine"
    end

    test "with neither children nor a glyph the container is empty, not broken" do
      assert icon(%{}).children == []
    end
  end

  describe "variants" do
    test "filled is a solid fill with its on_ partner on the glyph" do
      tree = icon(%{icon: "★", variant: :filled, color: :error})

      assert tree.props.background == :error
      assert find(tree, :text).props.text_color == :on_error
    end

    test "light is the colour mixed with transparency, which needs a number" do
      background = icon(%{variant: :light, color: 0xFF3366FF}).props.background

      assert background == 0x303366FF
    end

    test "a light token resolves through the active theme rather than serialising as an atom" do
      background = icon(%{variant: :light, color: :primary}).props.background

      assert is_integer(background)
      assert Bitwise.>>>(background, 24) == 0x30
    end

    test "outline is a border and no fill" do
      tree = icon(%{icon: "★", variant: :outline, color: :primary})

      refute Map.has_key?(tree.props, :background)
      assert tree.props.border_color == :primary
      assert tree.props.border_width == 1
      assert find(tree, :text).props.text_color == :primary
    end

    test "subtle is nothing but the glyph" do
      tree = icon(%{icon: "★", variant: :subtle, color: :primary})

      refute Map.has_key?(tree.props, :background)
      refute Map.has_key?(tree.props, :border_color)
      assert find(tree, :text).props.text_color == :primary
    end

    test "white is the theme's surface, because that is what white means in a themed app" do
      assert icon(%{variant: :white}).props.background == :surface
    end

    test "default is the neutral chip: raised surface, bordered, on_surface glyph" do
      tree = icon(%{icon: "★", variant: :default, color: :error})

      assert tree.props.background == :surface_raised
      assert tree.props.border_color == :border
      assert find(tree, :text).props.text_color == :on_surface
    end

    test "an unknown variant falls back to filled" do
      assert icon(%{variant: :ghost}).props.background == :primary
    end
  end

  describe "the glyph colour on a filled container" do
    test "each semantic token gets its on_ partner" do
      for {color, on} <- [
            {:primary, :on_primary},
            {:secondary, :on_secondary},
            {:error, :on_error},
            {:surface, :on_surface},
            {:background, :on_background}
          ] do
        assert find(icon(%{icon: "★", color: color}), :text).props.text_color == on
      end
    end

    test "a token with no partner still gets a readable default" do
      assert find(icon(%{icon: "★", color: :muted}), :text).props.text_color == :on_primary
    end

    test "a raw colour picks black or white by luminance" do
      assert find(icon(%{icon: "★", color: 0xFFFDE047}), :text).props.text_color == :black
      assert find(icon(%{icon: "★", color: 0xFF1E3A8A}), :text).props.text_color == :white
    end
  end

  describe "the gradient" do
    test "is drawn into a canvas sized exactly to the icon" do
      canvas = find(icon(%{variant: :gradient, size: :lg}), :canvas)

      assert canvas.props.width == 40
      assert canvas.props.height == 40
    end

    test "no other variant draws anything" do
      assert find(icon(%{variant: :filled}), :canvas) == nil
    end

    test "the canvas is painted behind the icon, not over it" do
      tree = icon(%{icon: "★", variant: :gradient})

      assert [%{type: :canvas} | _] = tree.children
    end

    test "runs from the first endpoint to the second" do
      ops = canvas_ops(icon(%{variant: :gradient, gradient: {0xFF000000, 0xFFFFFFFF}}))

      assert List.first(ops).color < 0xFF111111
      assert List.last(ops).color > 0xFFEEEEEE
    end

    test "every band is a filled quad, so the bands tile without a seam" do
      ops = canvas_ops(icon(%{variant: :gradient}))

      assert Enum.all?(ops, &(&1.op == :path and &1.fill == true))
      assert Enum.all?(ops, &(length(&1.points) == 4))
    end

    test "neighbouring bands share their edge exactly" do
      ops = canvas_ops(icon(%{variant: :gradient, radius: :full}))

      ops
      |> Enum.zip(tl(ops))
      |> Enum.each(fn {left, right} ->
        [_, top_right, bottom_right, _] = left.points
        [top_left, _, _, bottom_left] = right.points

        assert top_right == top_left
        assert bottom_right == bottom_left
      end)
    end

    test "the bands follow the rounded silhouette — inset at the ends, square in the middle" do
      ops = canvas_ops(icon(%{variant: :gradient, size: 40, radius: :full}))
      top_left = fn op -> op |> Map.fetch!(:points) |> hd() |> List.last() end

      assert top_left.(List.first(ops)) > 0
      assert top_left.(Enum.at(ops, div(length(ops), 2))) == 0.0
    end

    test "a square icon has no inset at all" do
      ops = canvas_ops(icon(%{variant: :gradient, size: 32, radius: :none}))

      assert Enum.all?(ops, fn op ->
               Enum.all?(op.points, fn [_x, y] -> y == 0.0 or y == 32 end)
             end)
    end

    test "the endpoints may be a tuple, a map or a keyword list" do
      tuple = canvas_ops(icon(%{variant: :gradient, gradient: {0xFF000000, 0xFFFFFFFF}}))
      map = canvas_ops(icon(%{variant: :gradient, gradient: %{from: 0xFF000000, to: 0xFFFFFFFF}}))
      kw = canvas_ops(icon(%{variant: :gradient, gradient: [from: 0xFF000000, to: 0xFFFFFFFF]}))

      assert Enum.map(tuple, & &1.color) == Enum.map(map, & &1.color)
      assert Enum.map(tuple, & &1.color) == Enum.map(kw, & &1.color)
    end

    test "tokens are endpoints too — they resolve on the BEAM because mixing needs numbers" do
      ops = canvas_ops(icon(%{variant: :gradient, gradient: {:primary, :error}}))

      assert Enum.all?(ops, &is_integer(&1.color))
      assert List.first(ops).color != List.last(ops).color
    end
  end

  describe "ids and testTags" do
    test "the container carries the id, and markers spell out what is only a colour" do
      assert tags(icon(%{id: "ti", variant: :light, label: "Save"})) ==
               ["ti", "ti-light", "ti-labelled"]
    end

    test "an unlabelled icon says so, so a test can assert the negative" do
      assert "ti-decorative" in tags(icon(%{id: "ti"}))
    end

    test "an empty label is not a label" do
      assert "ti-decorative" in tags(icon(%{id: "ti", label: ""}))
    end

    test "the variant marker names the variant" do
      for variant <- MishkaThemeIcon.variants() do
        assert "ti-#{variant}" in tags(icon(%{id: "ti", variant: variant}))
      end
    end

    test "without an id there are no markers and the icon sits straight in the container" do
      tree = icon(%{icon: "★"})

      assert tags(tree) == []
      assert [%{type: :text}] = tree.children
    end

    test "the markers hug their content and recentre it" do
      marker = find(icon(%{id: "ti", icon: "★"}), :box, id: "ti-filled")

      assert marker.props.fill_width == false
      assert marker.props.align == :center
    end
  end

  describe "events" do
    test "on_tap is widened to the shape the renderer registers" do
      assert icon(%{on_tap: :star}).props.on_tap == {self(), :star}
    end

    test "a long press carries the label — the touch equivalent of a hover title" do
      tree = icon(%{on_long_press: :hold, label: "Deploy"})

      assert tree.props.on_long_press == {self(), {:hold, "Deploy"}}
    end

    test "an unlabelled long press still reports, with nil for the label" do
      assert icon(%{on_long_press: :hold}).props.on_long_press == {self(), {:hold, nil}}
    end

    test "an already-wired tag is left alone, so the composite path composes correctly" do
      assert icon(%{on_tap: {self(), {:pick, :dark}}}).props.on_tap == {self(), {:pick, :dark}}
    end

    test "no handler means no prop at all rather than a nil the native side must read" do
      props = icon(%{}).props

      refute Map.has_key?(props, :on_tap)
      refute Map.has_key?(props, :on_long_press)
    end
  end

  test "expand/3 delegates, children and all" do
    child = [%{type: :text, props: %{text: "x"}, children: []}]

    assert MishkaThemeIcon.expand(%{variant: :light}, child, %{screen: self()}) ==
             MishkaThemeIcon.theme_icon(%{variant: :light}, child)
  end

  test "every variant renders" do
    for variant <- MishkaThemeIcon.variants() do
      assert_renderable(icon(%{icon: "★", variant: variant, id: "ti", label: "Save"}),
        extra: [:canvas]
      )
    end
  end

  # The gallery renders every example into one scrolling column, so a device test
  # can only tell two of them apart by their tags. These assert the tags exist
  # and that each one moves for its own reason.
  describe "the showcase page" do
    setup do
      Showcase.reset()
      Showcase.register_all()
      :ok
    end

    defp page, do: mount_screen(ComponentScreen, %{slug: :theme_icon})
    defp expanded(view), do: Mob.Composite.expand(tree(view), self())

    defp page_tags(view) do
      view |> expanded() |> flatten() |> Enum.map(& &1.props[:id]) |> Enum.reject(&is_nil/1)
    end

    test "renders, canvas and all" do
      assert_renderable(expanded(page()), extra: [:canvas])
    end

    test "every example is addressable by tag" do
      tags = page_tags(page())

      for tag <- [
            "ti-basic",
            "ti-var-filled",
            "ti-var-gradient",
            "ti-size-xs",
            "ti-size-xl",
            "ti-radius-full",
            "ti-color-error",
            "ti-color-raw",
            "ti-grad-round",
            "ti-meaning",
            "ti-drawn",
            "ti-sw-light"
          ] do
        assert tag in tags, "the page has no #{tag}"
      end
    end

    test "the tag path wires its handlers — a bare atom would render and do nothing" do
      boxes = page() |> expanded() |> find_all(:box)

      assert Enum.any?(boxes, &(&1.props[:on_tap] == {self(), :ti_tap}))
      assert Enum.any?(boxes, &(&1.props[:on_long_press] == {self(), {:ti_hold, "Deploy"}}))
    end

    test "the icons that convey something say which they are" do
      tags = page_tags(page())

      assert "ti-meaning-labelled" in tags
      assert "ti-plain-decorative" in tags
      refute "ti-plain-labelled" in tags
    end

    test "tapping the star moves only the star's own count" do
      view = page()
      assert "ti-taps-0" in page_tags(view)

      tapped = render_info(view, {:tap, :ti_tap})

      assert assigns(tapped).ti_taps == 1
      assert "ti-taps-1" in page_tags(tapped)
    end

    test "holding the labelled icon reports what it means" do
      held = render_info(page(), {:tap, {:ti_hold, "Deploy"}})

      assert assigns(held).ti_held == "Deploy"
      assert "ti-held-deploy" in page_tags(held)
    end

    test "the switcher fills exactly one option, and it is the chosen one" do
      view = render_info(page(), {:tap, {:ti_theme, :light}})
      tags = page_tags(view)

      assert "ti-sw-light-filled" in tags
      assert "ti-sw-dark-subtle" in tags
      refute "ti-sw-dark-filled" in tags
    end
  end

  describe "marquee" do
    defp content, do: [%{type: :text, props: %{text: "ticker"}, children: []}]

    test "is a horizontal scroller — the animation is not ported" do
      tree = MishkaMarquee.marquee(%{}, content())

      assert find(tree, :scroll).props.axis == "horizontal"
    end

    test "repeats the content, the way the web version does for a seamless loop" do
      once = MishkaMarquee.marquee(%{repeat: 1}, content())
      thrice = MishkaMarquee.marquee(%{repeat: 3}, content())

      assert length(find_all(once, :text)) == 1
      assert length(find_all(thrice, :text)) == 3
    end

    test "repeats are separated by the space gap, with no trailing gap" do
      tree = MishkaMarquee.marquee(%{repeat: 3, space: 40}, content())
      row = find(tree, :row)

      gaps = Enum.filter(row.children, &(&1.type == :spacer))
      assert length(gaps) == 2
      assert Enum.all?(gaps, &(&1.props.size == 40))
    end

    test "a repeat below one still renders the content once" do
      assert length(find_all(MishkaMarquee.marquee(%{repeat: 0}, content()), :text)) == 1
    end

    test "height and id are passed to the scroller" do
      tree = MishkaMarquee.marquee(%{height: 40, id: "ticker"}, content())

      assert find(tree, :scroll).props.id == "ticker"
      assert tree |> find_all(:box) |> Enum.any?(&(&1.props[:height] == 40))
    end

    test "expand/3 delegates" do
      assert MishkaMarquee.expand(%{}, content(), %{screen: self()}) ==
               MishkaMarquee.marquee(%{}, content())
    end

    test "renders" do
      assert_renderable(MishkaMarquee.marquee(%{repeat: 2}, content()))
    end
  end
end
