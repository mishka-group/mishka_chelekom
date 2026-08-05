defmodule MishkaMob.Components.MishkaSelectTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  import Mob.Sigil

  alias MishkaMob.Components.MishkaSelect, as: S

  doctest MishkaMob.Components.MishkaSelect

  defp opts do
    [
      S.option(:uk, "United Kingdom"),
      S.option(:ir, "Iran"),
      S.option(:jp, "Japan", disabled: true)
    ]
  end

  defp build(props),
    do: S.select(Map.merge(%{on_toggle: :open, on_select: :pick}, props), opts())

  describe "toggle/3" do
    test "single replaces and asks to close" do
      assert S.toggle(nil, :a, false) == {:a, true}
      assert S.toggle(:a, :b, false) == {:b, true}
    end

    test "re-picking the same single value keeps it — a select cannot be emptied by re-tapping" do
      assert S.toggle(:a, :a, false) == {:a, true}
    end

    test "multiple accumulates and stays open" do
      assert S.toggle([:a], :b, true) == {[:a, :b], false}
      assert S.toggle([], :a, true) == {[:a], false}
    end

    test "multiple un-picks an already chosen option" do
      assert S.toggle([:a, :b], :a, true) == {[:b], false}
    end

    test "a bare value in multiple mode is treated as a one-element list" do
      assert S.toggle(:a, :b, true) == {[:a, :b], false}
    end
  end

  describe "display/3" do
    test "falls back to the placeholder when nothing is chosen" do
      assert S.display(nil, [{:a, "Alpha"}], "Pick") == "Pick"
      assert S.display([], [{:a, "Alpha"}], "Pick") == "Pick"
    end

    test "shows the chosen label, and joins several" do
      assert S.display(:a, [{:a, "Alpha"}], "Pick") == "Alpha"
      assert S.display([:a, :b], [{:a, "Alpha"}, {:b, "Beta"}], "Pick") == "Alpha, Beta"
    end

    test "an unknown id shows itself rather than vanishing" do
      assert S.display(:ghost, [{:a, "Alpha"}], "Pick") == "ghost"
    end
  end

  describe "the trigger" do
    test "shows the placeholder muted, and the choice in full colour" do
      empty = find(build(%{placeholder: "Choose…"}), :text)
      chosen = find(build(%{value: :uk}), :text)

      assert empty.props.text == "Choose…"
      assert empty.props.text_color == :muted
      assert chosen.props.text == "United Kingdom"
      assert chosen.props.text_color == :on_surface
    end

    test "the chevron reflects open state" do
      assert text(build(%{})) =~ "▾"
      assert text(build(%{open: true})) =~ "▴"
    end

    test "carries the toggle handler, and none when disabled" do
      assert find(build(%{}), :box).props.on_tap == {self(), :open}
      refute Map.has_key?(find(build(%{disabled: true}), :box).props, :on_tap)
    end
  end

  describe "the list" do
    test "is absent while closed" do
      tree = build(%{})

      refute text(tree) =~ "Iran"
    end

    test "shows every option when open" do
      tree = build(%{open: true})

      for label <- ["United Kingdom", "Iran", "Japan"], do: assert(text(tree) =~ label)
    end

    test "ticks the chosen options" do
      single = build(%{open: true, value: :uk})
      multi = build(%{open: true, value: [:uk, :ir], multiple: true})

      assert text(single) =~ "✓"
      # one tick per chosen option
      assert length(String.split(text(multi), "✓")) - 1 == 2
    end

    test "each option carries its own id" do
      taps =
        build(%{open: true})
        |> find_all(:box)
        |> Enum.map(& &1.props[:on_tap])
        |> Enum.reject(&is_nil/1)

      assert Enum.member?(taps, {self(), {:pick, :uk}})
      assert Enum.member?(taps, {self(), {:pick, :ir}})
    end

    test "a disabled option is not tappable" do
      taps =
        build(%{open: true})
        |> find_all(:box)
        |> Enum.map(& &1.props[:on_tap])
        |> Enum.reject(&is_nil/1)

      refute Enum.member?(taps, {self(), {:pick, :jp}})
    end

    test "an empty option set renders no list even when open" do
      tree = S.select(%{open: true}, [])

      assert length(find_all(tree, :box)) == 1
    end
  end

  test "a label renders above the trigger" do
    assert text(build(%{label: "COUNTRY"})) =~ "COUNTRY"
  end

  test "expand/3 reads option children and ignores anything else" do
    stray = %{type: :text, props: %{text: "stray"}, children: []}
    tree = S.expand(%{open: true}, opts() ++ [stray], %{screen: self()})

    refute text(tree) =~ "stray"
    assert text(tree) =~ "Iran"
  end

  describe "groups" do
    defp grouped do
      [
        S.option(:cheese, "Cheese", group: "Classic"),
        S.option(:pepperoni, "Pepperoni", group: "Classic"),
        S.option(:mushroom, "Mushroom", group: "Veggie"),
        S.option(:onion, "Onion", group: "Veggie")
      ]
    end

    test "a heading renders above each run" do
      tree = S.select(%{open: true, value: :pepperoni}, grouped())

      assert text(tree) =~ "Classic"
      assert text(tree) =~ "Veggie"
    end

    test "CONSECUTIVE options group; the caller's order is the grouping" do
      # Two runs of the same name are two headings, not one merged bucket —
      # nothing is sorted underneath the caller.
      runs =
        S.group_runs([
          %{id: :a, group: "G"},
          %{id: :b, group: "H"},
          %{id: :c, group: "G"}
        ])

      assert Enum.map(runs, &elem(&1, 0)) == ["G", "H", "G"]
    end

    test "ungrouped options render with no heading at all" do
      plain = S.select(%{open: true}, [S.option(:a, "Alpha")])

      assert text(plain) =~ "Alpha"
      assert [{nil, _}] = S.group_runs([%{id: :a, group: nil}])
    end

    test "grouping does not change what an option reports" do
      tree = S.select(%{open: true, on_select: :pick}, grouped())
      taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

      assert {self(), {:pick, :cheese}} in taps
      assert {self(), {:pick, :onion}} in taps
    end
  end

  describe "test tags" do
    test "the trigger reports whether the list is open" do
      assert S.select(%{id: "pizza"}, []) |> find(:box) |> Map.fetch!(:props) |> Map.get(:id) ==
               "pizza-trigger-closed"

      assert S.select(%{id: "pizza", open: true}, [S.option(:a, "A")])
             |> find(:box)
             |> Map.fetch!(:props)
             |> Map.get(:id) == "pizza-trigger-open"
    end

    test "each option says whether it is the chosen one" do
      # The tick is a glyph, and a glyph cannot be attributed to one row among
      # several by a device test.
      ids =
        S.select(%{id: "pizza", open: true, value: :b}, [
          S.option(:a, "A"),
          S.option(:b, "B")
        ])
        |> find_all(:box)
        |> Enum.map(& &1.props[:id])

      assert "pizza-option-a-idle" in ids
      assert "pizza-option-b-selected" in ids
    end

    test "no id leaves the trigger and options untagged" do
      ids =
        S.select(%{open: true}, [S.option(:a, "A")])
        |> find_all(:box)
        |> Enum.map(& &1.props[:id])

      assert Enum.all?(ids, &is_nil/1)
    end
  end

  describe "the option slot tag" do
    test "<MishkaSelectOption> and option/3 name the same node type" do
      from_tag = ~MOB(<MishkaSelectOption id={:uk} label="United Kingdom" />)

      # option/3 fills in the defaults the tag simply omits, so compare what
      # the tag actually carries rather than the maps whole.
      assert from_tag.type == S.option(:uk, "United Kingdom").type
      assert from_tag.props.id == :uk
      assert from_tag.props.label == "United Kingdom"
    end

    test "a tag with no :disabled or :group is read as neither" do
      tree =
        S.select(%{id: "s", open: true, value: :uk}, [
          ~MOB(<MishkaSelectOption id={:uk} label="United Kingdom" />),
          ~MOB(<MishkaSelectOption id={:ir} label="Iran" />)
        ])

      ids = tree |> find_all(:box) |> Enum.map(& &1.props[:id])

      assert "s-option-uk-selected" in ids
      assert "s-option-ir-idle" in ids
    end

    test "no option marker reaches the renderer" do
      tree = S.select(%{id: "s", open: true}, [~MOB(<MishkaSelectOption id={:uk} label="UK" />)])

      # assert_renderable is blind to this: mix.exs whitelists the tag's name,
      # so it counts as renderable while MobBridge has no branch for it and
      # silently draws nothing.
      assert find_all(tree, :mishka_select_option) == []
      assert_renderable(tree)
    end
  end

  # The gallery page is what SelectTest.kt drives, and every option on it bar
  # the data-driven card is now written as a tag.
  describe "the gallery page" do
    alias MishkaMob.Showcase.Components.Select, as: Page

    setup do
      MishkaMob.Showcase.reset()
      MishkaMob.Showcase.register_all()

      :ok
    end

    defp cards do
      assigns = Page.mount(Mob.Socket.new(MishkaMob.Showcase.ComponentScreen)).assigns

      Enum.map(Page.examples(), &Mob.Composite.expand(&1.render.(assigns), self()))
    end

    test "every trigger the device test names survives expansion" do
      ids =
        cards()
        |> Enum.flat_map(&flatten/1)
        |> Enum.map(& &1.props[:id])
        |> Enum.reject(&is_nil/1)

      for tag <- ~w(sel-country-trigger-closed sel-lang-trigger-closed
                    sel-pizza-trigger-closed sel-off-trigger-closed) do
        assert tag in ids, "the #{tag} trigger is missing"
      end
    end

    test "no option marker reaches the renderer from the page either" do
      for card <- cards() do
        assert find_all(card, :mishka_select_option) == []
      end
    end
  end

  test "every variant renders" do
    for props <- [%{}, %{open: true}, %{value: :uk}, %{value: [:uk], multiple: true, open: true}] do
      assert_renderable(build(props))
    end
  end
end
