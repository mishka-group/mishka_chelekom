defmodule MishkaMob.Components.MishkaThemeIconTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaMarquee, MishkaThemeIcon}

  defp options(tree), do: Enum.filter(tree.children, &(&1.type == :box))

  describe "theme switcher" do
    test "renders one option per theme, with its glyph and label" do
      tree = MishkaThemeIcon.theme_icon(%{})

      assert length(options(tree)) == length(MishkaThemeIcon.themes())
      assert text(tree) =~ "Light"
      assert text(tree) =~ "Dark"
      assert text(tree) =~ "System"
    end

    test "only the active option is tinted" do
      fills =
        MishkaThemeIcon.theme_icon(%{active: :dark})
        |> options()
        |> Enum.map(& &1.props.background)

      assert fills == [:surface_raised, :primary, :surface_raised]
    end

    test "with no active theme nothing is tinted" do
      fills = MishkaThemeIcon.theme_icon(%{}) |> options() |> Enum.map(& &1.props.background)

      assert Enum.all?(fills, &(&1 == :surface_raised))
    end

    test "each option reports the same tag widened with its own key" do
      taps =
        MishkaThemeIcon.theme_icon(%{on_select: :set})
        |> options()
        |> Enum.map(& &1.props[:on_tap])

      assert [{pid, {:set, :light}}, {_, {:set, :dark}}, {_, {:set, :system}}] = taps
      assert pid == self()
    end

    test "no on_select leaves them inert" do
      tree = MishkaThemeIcon.theme_icon(%{})

      assert Enum.all?(options(tree), &(&1.props[:on_tap] == nil))
    end

    test "show_labels: false keeps the glyphs and drops the text" do
      tree = MishkaThemeIcon.theme_icon(%{show_labels: false})

      refute text(tree) =~ "Light"
      assert text(tree) =~ "☀️"
    end

    test "the option set is overridable" do
      tree = MishkaThemeIcon.theme_icon(%{options: [{:sepia, "📜", "Sepia"}]})

      assert length(options(tree)) == 1
      assert text(tree) =~ "Sepia"
    end

    test "the active tint is overridable" do
      tree = MishkaThemeIcon.theme_icon(%{active: :light, color: 0xFF7C3AED})

      assert hd(options(tree)).props.background == 0xFF7C3AED
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
  end

  test "expand/3 delegates for both" do
    assert MishkaThemeIcon.expand(%{active: :dark}, [], %{screen: self()}) ==
             MishkaThemeIcon.theme_icon(%{active: :dark})

    assert MishkaMarquee.expand(%{}, content(), %{screen: self()}) ==
             MishkaMarquee.marquee(%{}, content())
  end

  test "every variant renders" do
    for props <- [%{}, %{active: :dark}, %{show_labels: false}] do
      assert_renderable(MishkaThemeIcon.theme_icon(props))
    end

    assert_renderable(MishkaMarquee.marquee(%{repeat: 2}, content()))
  end
end
