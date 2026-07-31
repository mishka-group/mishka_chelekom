defmodule MishkaMob.Components.MishkaAutocompleteTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaAutocomplete, MishkaPillsInput}

  doctest MishkaMob.Components.MishkaAutocomplete

  @cities ["Iran", "Ireland", "Italy", "Berlin"]

  describe "suggest/3" do
    test "prefix-matches by default — that is what autocomplete means" do
      assert MishkaAutocomplete.suggest(@cities, "ir") == ["Iran", "Ireland"]
      assert MishkaAutocomplete.suggest(@cities, "ran") == []
    end

    test "contains mode matches anywhere" do
      assert MishkaAutocomplete.suggest(@cities, "ran", mode: :contains) == ["Iran"]
    end

    test "an empty query offers everything" do
      assert MishkaAutocomplete.suggest(@cities, "") == @cities
      assert MishkaAutocomplete.suggest(@cities, nil) == @cities
    end

    test "an exact match suggests NOTHING — there is nothing left to complete" do
      assert MishkaAutocomplete.suggest(@cities, "Iran") == []
      assert MishkaAutocomplete.suggest(@cities, "iran") == []
    end

    test "is accent-insensitive, like the combobox it builds on" do
      assert MishkaAutocomplete.suggest(["Café", "Camp"], "caf") == ["Café"]
    end
  end

  describe "exact?/2" do
    test "true only for a full, case-insensitive match" do
      assert MishkaAutocomplete.exact?(["Iran"], "iran")
      assert MishkaAutocomplete.exact?(["Iran"], "IRAN")
      refute MishkaAutocomplete.exact?(["Iran"], "ir")
    end

    test "an empty query is never exact" do
      refute MishkaAutocomplete.exact?(["Iran"], "")
      refute MishkaAutocomplete.exact?(["Iran"], nil)
    end
  end

  describe "rendering" do
    test "the field shows the QUERY — not a blanked value" do
      tree = MishkaAutocomplete.autocomplete(query: "ir", suggestions: @cities, open: true)

      assert find(tree, :text_field).props.value == "ir"
    end

    test "only matching suggestions render" do
      tree = MishkaAutocomplete.autocomplete(query: "ir", suggestions: @cities, open: true)

      assert text(tree) =~ "Iran"
      assert text(tree) =~ "Ireland"
      refute text(tree) =~ "Berlin"
    end

    test "an exact query leaves nothing to suggest" do
      tree = MishkaAutocomplete.autocomplete(query: "Iran", suggestions: @cities, open: true)

      refute text(tree) =~ "Ireland"
    end

    test "choosing hands back the TEXT, not an id" do
      tree =
        MishkaAutocomplete.autocomplete(
          query: "ir",
          suggestions: @cities,
          open: true,
          on_select: :choose
        )

      taps = tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

      assert Enum.member?(taps, {self(), {:choose, "Iran"}})
    end

    test "no suggestions renders the empty message" do
      tree =
        MishkaAutocomplete.autocomplete(
          query: "zzz",
          suggestions: @cities,
          open: true,
          empty_text: "Nothing"
        )

      assert text(tree) =~ "Nothing"
    end
  end

  describe "pills input" do
    defp pills, do: [%{type: :text, props: %{text: "ada"}, children: []}]

    test "is a bordered control holding the caller's pills over a draft field" do
      tree = MishkaPillsInput.pills_input(%{}, pills())

      assert tree.type == :box
      assert tree.props.border_width == 1
      assert text(tree) =~ "ada"
      assert find(tree, :text_field)
    end

    test "owns nothing — arbitrary nodes pass straight through" do
      art = [%{type: :image, props: %{src: "u"}, children: []}]
      tree = MishkaPillsInput.pills_input(%{}, art)

      assert find(tree, :image).props.src == "u"
    end

    test "with no pills it is just the draft field" do
      tree = MishkaPillsInput.pills_input(%{}, [])

      assert find(tree, :text_field)
      assert find_all(tree, :row) == []
    end

    test "pills wrap onto a new row every per_row" do
      # A single Row runs off the edge — Mob has no flow layout, and nothing
      # clips or complains, so the seventh recipient simply vanished past the
      # border. The tree was valid either way, which is why this is asserted.
      tokens = for i <- 1..7, do: %{type: :text, props: %{text: "p#{i}"}, children: []}

      assert row_widths(MishkaPillsInput.pills_input(%{}, tokens)) == [3, 3, 1]
    end

    test "per_row is a prop, and 0 does not divide the pills into nothing" do
      tokens = for i <- 1..4, do: %{type: :text, props: %{text: "p#{i}"}, children: []}
      widths = &row_widths(MishkaPillsInput.pills_input(%{per_row: &1}, tokens))

      assert widths.(2) == [2, 2]
      assert widths.(10) == [4]
      # Enum.chunk_every/2 raises on 0 — one per row is the only sane reading.
      assert widths.(0) == [1, 1, 1, 1]
    end

    defp row_widths(tree) do
      tree
      |> find_all(:row)
      |> Enum.map(fn row -> Enum.count(row.children, &(&1.type == :text)) end)
      |> Enum.reject(&(&1 == 0))
    end

    test "typing and return report separately" do
      field =
        find(
          MishkaPillsInput.pills_input(%{on_draft: :typed, on_add: :commit}, pills()),
          :text_field
        )

      assert field.props.on_change == {self(), :typed}
      assert field.props.on_submit == {self(), :commit}
    end

    test "disabled unwires the draft" do
      field =
        MishkaPillsInput.pills_input(%{disabled: true, on_draft: :t, on_add: :c}, pills())
        |> find(:text_field)

      refute Map.has_key?(field.props, :on_change)
      refute Map.has_key?(field.props, :on_submit)
    end
  end

  test "expand/3 delegates for both" do
    assert MishkaAutocomplete.expand(%{query: "a"}, [], %{screen: self()}) ==
             MishkaAutocomplete.autocomplete(query: "a")

    assert MishkaPillsInput.expand(%{}, pills(), %{screen: self()}) ==
             MishkaPillsInput.pills_input(%{}, pills())
  end

  describe "the exact-match rule drops ONE suggestion, not the list" do
    test "a longer completion survives the query that names a shorter one" do
      # "Iran" is the answer for itself, but "Iranian Rial" is exactly what a
      # user typing a prefix is still looking for. Blanking the whole list threw
      # it away and then claimed there was nothing to suggest.
      tree =
        MishkaAutocomplete.autocomplete(
          query: "Iran",
          suggestions: ["Iran", "Iranian Rial"],
          open: true
        )

      assert text(tree) =~ "Iranian Rial"
      refute text(tree) =~ "No suggestions"
    end

    test "the exactly-named suggestion itself is gone" do
      tree =
        MishkaAutocomplete.autocomplete(
          query: "Iran",
          suggestions: ["Iran", "Iranian Rial"],
          open: true
        )

      # The completion is offered and the word already in the field is not. An
      # exact-text check, because "Iran" is a prefix of "Iranian Rial".
      assert text(tree) =~ "Iranian Rial"
      refute tree |> find_all(:text) |> Enum.any?(&(&1.props[:text] == "Iran"))
    end

    test "no panel at all when the exact match was the only thing left" do
      # "No suggestions" is information when nothing matches what you typed, and
      # a lie when the only match was dropped for already being the answer.
      tree = MishkaAutocomplete.autocomplete(query: "Iran", suggestions: ["Iran"], open: true)

      refute text(tree) =~ "No suggestions"
    end

    test "a query nothing matches still says so" do
      tree = MishkaAutocomplete.autocomplete(query: "zzzz", suggestions: ["Iran"], open: true)

      assert text(tree) =~ "No suggestions"
    end

    test "exact_match?/2 folds case and accents" do
      assert MishkaAutocomplete.exact_match?("Iran", "iran")
      assert MishkaAutocomplete.exact_match?("Café", "cafe")
      refute MishkaAutocomplete.exact_match?("Ireland", "iran")
      refute MishkaAutocomplete.exact_match?("Iran", "")
    end
  end

  describe "props reach the combobox" do
    test "id, on_focus and trigger are forwarded — the moduledoc used to deny id" do
      tree =
        MishkaAutocomplete.autocomplete(
          id: "ac",
          query: "Te",
          suggestions: ["Tehran"],
          open: true,
          clear: true,
          trigger: true,
          on_focus: :focused
        )

      ids = tree |> find_all(:box) |> Enum.map(& &1.props[:id])

      assert find(tree, :text_field).props.id == "ac-input"
      assert find(tree, :text_field).props.on_focus == {self(), :focused}
      assert "ac-on_clear" in ids
      assert "ac-on_toggle" in ids
    end
  end

  describe "the pills input's draft field" do
    test "draws no box, so no rule crosses the control" do
      field = find(MishkaPillsInput.pills_input(%{}, []), :text_field)

      assert field.props.underline == false
      assert field.props.background == :transparent
    end

    test "disabled actually disables it, not just its handler" do
      field = find(MishkaPillsInput.pills_input(%{disabled: true}, []), :text_field)

      # Withholding the handler stops the BEAM hearing about edits but leaves the
      # field focusable and editable — it looks live and goes nowhere.
      assert field.props.enabled == false
    end
  end

  test "every variant renders" do
    for props <- [
          %{},
          %{query: "ir", suggestions: @cities, open: true},
          %{query: "zzz", suggestions: @cities, open: true}
        ] do
      assert_renderable(MishkaAutocomplete.autocomplete(props))
    end

    assert_renderable(MishkaPillsInput.pills_input(%{}, pills()))
  end
end
