defmodule MishkaMob.Components.MishkaAccordionTest do
  # Unit tests for the Accordion composite. `use Mob.ScreenCase` is borrowed for
  # its tree queries (find / find_all / text / assert_renderable), which accept a
  # raw `%{type:, ...}` node map — no screen needed.
  #
  # async: false — ScreenCase's setup starts the globally-named `Mob.State`, so
  # two concurrent ScreenCase files race to start it and the loser dies with
  # `{:already_started, pid}`. Only one such file can be async.
  use Mob.ScreenCase, async: false

  import ExUnit.CaptureLog

  alias MishkaMob.Components.MishkaAccordion

  doctest MishkaMob.Components.MishkaAccordion

  # Built at call time so `self()` is the test process.
  defp ctx, do: %{screen: self()}

  defp item(id, title, extra \\ %{}) do
    %{
      type: :mishka_accordion_item,
      props: Map.merge(%{id: id, title: title}, extra),
      children: [%{type: :text, props: %{text: "#{id} body"}, children: []}]
    }
  end

  defp items, do: [item(:a, "First"), item(:b, "Second"), item(:c, "Third")]

  # Realistic props: an accordion is inert without an on_toggle (and logs a warning).
  defp p(extra \\ %{}), do: Map.merge(%{open: [], on_toggle: {self(), :toggle}}, extra)

  defp expand(props \\ nil, children \\ nil),
    do: MishkaAccordion.expand(props || p(), children || items(), ctx())

  # Every item renders as a fill-width box; the gaps between them are spacers.
  defp item_boxes(tree), do: Enum.filter(tree.children, &(&1.type == :box))

  describe "toggle/3 — the state semantics the web engine owns" do
    test "opening a closed item, one at a time by default" do
      assert MishkaAccordion.toggle([], :a) == [:a]
      assert MishkaAccordion.toggle([:a], :b) == [:b]
    end

    test "multiple lets panels accumulate, preserving order" do
      assert MishkaAccordion.toggle([:a], :b, multiple: true) == [:a, :b]
      assert MishkaAccordion.toggle([:a, :b], :c, multiple: true) == [:a, :b, :c]
    end

    test "collapsible closes the open item; false keeps one always open" do
      assert MishkaAccordion.toggle([:a], :a) == []
      assert MishkaAccordion.toggle([:a], :a, collapsible: false) == [:a]
    end

    test "with collapsible: false another item still takes over the slot" do
      assert MishkaAccordion.toggle([:a], :b, collapsible: false) == [:b]
    end

    test "multiple + collapsible: false closes nothing but still opens" do
      assert MishkaAccordion.toggle([:a, :b], :a, multiple: true, collapsible: false) == [:a, :b]
      assert MishkaAccordion.toggle([:a], :b, multiple: true, collapsible: false) == [:a, :b]
    end

    test "re-opening an already-open item under multiple does not duplicate it" do
      assert MishkaAccordion.toggle([:a], :a, multiple: true) == []
    end

    test "ids can be any term" do
      assert MishkaAccordion.toggle([], "faq-1") == ["faq-1"]
      assert MishkaAccordion.toggle([1], 2, multiple: true) == [1, 2]
    end
  end

  describe "structure" do
    test "renders one item box per item and stays renderable" do
      tree = expand()

      assert tree.type == :column
      assert length(item_boxes(tree)) == 3
      assert_renderable(tree)
    end

    test "ignores children that are not accordion items" do
      stray = %{type: :text, props: %{text: "stray"}, children: []}
      tree = expand(p(), [item(:a, "First"), stray])

      assert length(item_boxes(tree)) == 1
      refute text(tree) =~ "stray"
    end

    test "renders nothing but an empty column when there are no items" do
      assert MishkaAccordion.expand(p(), [], ctx()) == %{
               type: :column,
               props: %{fill_width: true},
               children: []
             }
    end

    test "items are separated by the space gap, and space: 0 joins them" do
      spacers = fn tree -> Enum.filter(tree.children, &(&1.type == :spacer)) end

      assert [%{props: %{size: 8}}, %{props: %{size: 8}}] = spacers.(expand())
      assert [%{props: %{size: 0}}, %{props: %{size: 0}}] = spacers.(expand(p(%{space: 0})))
    end
  end

  describe "open / closed panels" do
    test "only open items render their panel body" do
      tree = expand(p(%{open: [:b]}))

      assert text(tree) =~ "b body"
      refute text(tree) =~ "a body"
      refute text(tree) =~ "c body"
    end

    test "headers always render, open or not" do
      tree = expand()
      assert text(tree) =~ "First"
      assert text(tree) =~ "Second"
    end

    test "several panels can be open at once" do
      tree = expand(p(%{open: [:a, :c]}))

      assert text(tree) =~ "a body"
      assert text(tree) =~ "c body"
      refute text(tree) =~ "b body"
    end

    test "the chevron reflects state and can be hidden" do
      open = expand(p(%{open: [:a]}))
      assert text(open) =~ "▾"
      assert text(open) =~ "▸"

      hidden = expand(p(%{open: [:a], chevron: false}))
      refute text(hidden) =~ "▾"
      refute text(hidden) =~ "▸"
      # hiding the indicator must not hide the content
      assert text(hidden) =~ "First"
      assert text(hidden) =~ "a body"
    end
  end

  describe "triggers" do
    test "a trigger is a tappable Box, never a Button (a Button centres its label)" do
      tree = expand()

      assert find_all(tree, :button) == []
      # every item's first child row sits in a box carrying the tap
      assert Enum.count(find_all(tree, :box), &Map.has_key?(&1.props, :on_tap)) == 3
    end

    test "the tap tag carries the item id so one handler serves every item" do
      tree = expand()
      tags = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

      assert tags == [{self(), {:toggle, :a}}, {self(), {:toggle, :b}}, {self(), {:toggle, :c}}]
    end

    test "an item id falls back to its 0-based index" do
      children = [
        %{type: :mishka_accordion_item, props: %{title: "No id"}, children: []},
        %{type: :mishka_accordion_item, props: %{title: "Also none"}, children: []}
      ]

      tags =
        expand(p(), children)
        |> find_all(:box)
        |> Enum.map(& &1.props[:on_tap])
        |> Enum.reject(&is_nil/1)

      assert tags == [{self(), {:toggle, 0}}, {self(), {:toggle, 1}}]
    end

    test "without on_toggle the triggers are inert and it says so" do
      log =
        capture_log(fn ->
          tree = MishkaAccordion.expand(%{open: []}, items(), ctx())
          assert Enum.all?(find_all(tree, :box), &(&1.props[:on_tap] == nil))
        end)

      assert log =~ "no `on_toggle`"
    end

    test "an empty accordion does not warn" do
      assert capture_log(fn -> MishkaAccordion.expand(%{open: []}, [], ctx()) end) == ""
    end
  end

  describe "disabled" do
    test "a disabled item wires no tap and renders muted" do
      tree = expand(p(), [item(:a, "First"), item(:b, "Nope", %{disabled: true})])

      taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)
      assert taps == [{self(), {:toggle, :a}}]

      assert find(tree, :text, text: "Nope").props.text_color == :muted
      assert find(tree, :text, text: "First").props.text_color == :on_surface
    end

    test "disabling the root cascades to every item" do
      tree = expand(p(%{disabled: true}))

      assert Enum.all?(find_all(tree, :box), &(&1.props[:on_tap] == nil))
      assert find(tree, :text, text: "First").props.text_color == :muted
    end

    test "a disabled item still shows its panel when open" do
      tree = expand(p(%{open: [:b]}), [item(:a, "First"), item(:b, "Nope", %{disabled: true})])
      assert text(tree) =~ "b body"
    end
  end

  describe "styling props" do
    test "defaults: raised surface, rounded, padded" do
      [first | _] = item_boxes(expand())

      assert first.props.background == :surface_raised
      assert first.props.corner_radius == :radius_md
      assert find(first, :box, padding: :space_md)
    end

    test "background / corner_radius / padding are overridable" do
      tree = expand(p(%{background: 0xFF7C3AED, corner_radius: 4, padding: :space_lg}))
      [first | _] = item_boxes(tree)

      assert first.props.background == 0xFF7C3AED
      assert first.props.corner_radius == 4
      assert find(first, :box, padding: :space_lg)
    end
  end
end
