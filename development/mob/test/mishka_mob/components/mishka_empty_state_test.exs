defmodule MishkaMob.Components.MishkaEmptyStateTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaEmptyState, as: ES

  defp actions, do: [%{type: :button, props: %{text: "New"}, children: []}]

  describe "layout" do
    test "centred wraps the block in a centring Box" do
      tree = ES.empty_state(title: "No messages")

      assert tree.type == :box
      assert tree.props.align == :center
    end

    test "leading lays the indicator beside the text" do
      tree = ES.empty_state(align: :leading, indicator: "🔍", title: "No results")

      assert tree.type == :row
      assert text(tree) =~ "🔍"
      assert text(tree) =~ "No results"
    end

    test "padding is overridable on the centred layout" do
      assert ES.empty_state(title: "x", padding: :space_sm).props.padding == :space_sm
    end
  end

  describe "parts are optional" do
    test "title only" do
      tree = ES.empty_state(title: "Nothing here")

      assert text(tree) =~ "Nothing here"
      assert find_all(tree, :button) == []
    end

    test "description only" do
      assert text(ES.empty_state(description: "Nothing to see")) =~ "Nothing to see"
    end

    test "an indicator glyph renders, and is absent when not given" do
      assert text(ES.empty_state(indicator: "📭", title: "x")) =~ "📭"
      refute text(ES.empty_state(title: "x")) =~ "📭"
    end

    test "nothing at all still renders" do
      assert_renderable(ES.empty_state())
    end
  end

  describe "actions" do
    test "render beneath the text when given" do
      tree = ES.empty_state(%{title: "x"}, [], actions())

      assert find(tree, :button, text: "New")
    end

    test "no actions means no actions row" do
      tree = ES.empty_state(%{title: "x"}, [], [])

      assert find_all(tree, :button) == []
    end
  end

  test "indicator nodes replace the glyph" do
    art = [%{type: :text, props: %{text: "★"}, children: []}]
    tree = ES.empty_state(%{indicator: "📭", title: "x"}, art, [])

    assert text(tree) =~ "★"
    refute text(tree) =~ "📭"
  end

  describe "slots" do
    defp slot(type, children), do: %{type: type, props: %{}, children: children}

    test "<MishkaEmptyStateActions> supplies the actions row" do
      tree =
        ES.expand(
          %{title: "x"},
          [slot(:mishka_empty_state_actions, actions())],
          %{screen: self()}
        )

      assert find(tree, :button, text: "New")
      # The marker itself is consumed — it must never reach the renderer,
      # which has no idea what to draw for it.
      assert find_all(tree, :mishka_empty_state_actions) == []
    end

    test "<MishkaEmptyStateIndicator> replaces the glyph" do
      art = [%{type: :text, props: %{text: "★"}, children: []}]

      tree =
        ES.expand(
          %{indicator: "📭", title: "x"},
          [slot(:mishka_empty_state_indicator, art)],
          %{screen: self()}
        )

      assert text(tree) =~ "★"
      refute text(tree) =~ "📭"
    end

    test "bare children are the inner block, rendered after the description" do
      extra = [%{type: :text, props: %{text: "footnote"}, children: []}]
      tree = ES.expand(%{title: "x", description: "d"}, extra, %{screen: self()})

      assert text(tree) =~ "footnote"
    end

    test "the slot wins over the actions prop" do
      from_prop = [%{type: :button, props: %{text: "Prop"}, children: []}]

      tree =
        ES.expand(
          %{title: "x", actions: from_prop},
          [slot(:mishka_empty_state_actions, actions())],
          %{screen: self()}
        )

      assert find(tree, :button, text: "New")
      refute find(tree, :button, text: "Prop")
    end

    test "the actions prop still works with no slot given" do
      tree = ES.expand(%{title: "x", actions: actions()}, [], %{screen: self()})

      assert find(tree, :button, text: "New")
    end

    test "actions are spaced by the component, not by the caller" do
      two = actions() ++ [%{type: :button, props: %{text: "Import"}, children: []}]
      tree = ES.expand(%{title: "x"}, [slot(:mishka_empty_state_actions, two)], %{screen: self()})

      row = find(tree, :row)
      assert Enum.map(row.children, & &1.type) == [:button, :spacer, :button]
    end
  end

  describe "id" do
    test "tags the block and fans out to the parts that have no other handle" do
      tree =
        ES.empty_state(
          id: "es",
          indicator: "📭",
          title: "No messages",
          description: "Anything you receive lands here."
        )

      assert tree.props.id == "es"
      assert find(tree, :text, text: "📭").props.id == "es-indicator"
      assert find(tree, :text, text: "No messages").props.id == "es-title"

      assert find(tree, :text, text: "Anything you receive lands here.").props.id ==
               "es-description"
    end

    test "the leading layout tags the same parts" do
      tree = ES.empty_state(id: "es", align: :leading, indicator: "🔍", title: "No results")

      assert tree.type == :row
      assert tree.props.id == "es"
      assert find(tree, :text, text: "🔍").props.id == "es-indicator"
      assert find(tree, :text, text: "No results").props.id == "es-title"
    end

    test "a part that is not rendered is not tagged, and nothing is without an id" do
      tree = ES.empty_state(id: "es", title: "Only a title")

      assert Enum.map(find_all(tree, :text), & &1.props.id) == ["es-title"]

      plain = ES.empty_state(indicator: "x", title: "t", description: "d")
      refute Map.has_key?(plain.props, :id)
      assert find_all(plain, :text) |> Enum.all?(&(not Map.has_key?(&1.props, :id)))
    end
  end

  test "every variant renders" do
    for props <- [%{}, %{title: "t"}, %{align: :leading, title: "t"}, %{indicator: "x"}] do
      assert_renderable(ES.empty_state(props))
    end
  end
end
