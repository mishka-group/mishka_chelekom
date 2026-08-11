defmodule MishkaChelekom.CmsBundle.EditorHintsTest do
  @moduledoc """
  The bundle says which control an attribute wants, so the consumer stops guessing from its name.

  The case that forced this: `chelekom-icon` is the one component that is nothing but an icon, and it
  calls its attribute `name` — so every name-based guess downstream missed it and drew a text box on
  the one control where a picker matters most.

  The rest of the rules are the same shape, and so are their limits: each test that asserts a hint is
  paired with one that asserts silence, because an attribute this module says nothing about falls
  back to a heuristic that is usually right, and one it says the wrong thing about cannot be argued
  with.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.CmsBundle.EditorHints

  defp component(name, attrs), do: %{"name" => name, "attrs" => attrs}

  defp attr(name, opts \\ %{}, type \\ "string"),
    do: %{"name" => name, "type" => type, "opts" => opts}

  defp editor(component, index),
    do: get_in(component, ["attrs", Access.at(index), "opts", "editor"])

  defp annotate(name, attrs) do
    [result] = EditorHints.annotate([component(name, attrs)])
    result
  end

  describe "annotate/1" do
    test "an attribute named for an icon is hinted" do
      result = annotate("chelekom-alert", [attr("icon"), attr("dismiss_icon"), attr("title")])

      assert editor(result, 0) == "icon"
      assert editor(result, 1) == "icon"
      refute editor(result, 2)
    end

    # The whole reason this module exists.
    test "`name` on an icon component is hinted" do
      result = annotate("chelekom-icon", [attr("name"), attr("class")])

      assert editor(result, 0) == "icon"
      refute editor(result, 1)
    end

    # `name` means something else everywhere else — a navbar's name is not an icon.
    test "`name` on anything else is left alone" do
      assert annotate("chelekom-navbar", [attr("name")]) |> editor(0) == nil
    end

    test "a hand-written hint is never overwritten" do
      result = annotate("chelekom-icon", [attr("name", %{"editor" => "text"})])

      assert editor(result, 0) == "text"
    end

    # And for the rules added after it: a kit author who writes `url` on a `src` means `url`.
    test "a hand-written hint wins over every rule, not just the icon one" do
      result =
        annotate("chelekom-image", [
          attr("src", %{"editor" => "url"}),
          attr("icon_class", %{"editor" => "icon"})
        ])

      assert editor(result, 0) == "url"
      assert editor(result, 1) == "icon"
    end

    test "everything else about the attribute survives" do
      result =
        annotate("chelekom-alert", [attr("icon", %{"default" => "hero-bell", "required" => true})])

      assert get_in(result, ["attrs", Access.at(0), "opts", "default"]) == "hero-bell"
      assert get_in(result, ["attrs", Access.at(0), "opts", "required"]) == true
      assert editor(result, 0) == "icon"
    end

    test "a component with no attrs, or a malformed one, does not raise" do
      assert [%{"name" => "x", "attrs" => []}] = EditorHints.annotate([%{"name" => "x"}])
      assert [%{"attrs" => ["junk"]}] = EditorHints.annotate([component("x", ["junk"])])
    end
  end

  describe "the text override" do
    # A class that styles an icon is a Tailwind class, and the guess it would otherwise get — an icon
    # picker — is the most confidently wrong answer in the whole kit.
    test "a name that qualifies a control word is text, not that control" do
      result =
        annotate("chelekom-timeline-section", [
          attr("icon_class"),
          attr("image_class"),
          attr("error_icon_class"),
          attr("icon_wrapper_class")
        ])

      assert Enum.map(0..3, &editor(result, &1)) == List.duplicate("text", 4)
    end

    # `<.link patch={@link}>{@link_title}</.link>` — one of these is the address, the other is the
    # words printed on it.
    test "a link's title is text and its path is a url" do
      result = annotate("chelekom-content-item", [attr("link_title"), attr("link")])

      assert editor(result, 0) == "text"
      assert editor(result, 1) == "url"
    end

    # There is no control word in either, so there is nothing to override: `class` and `label_class`
    # are already drawn as text boxes by every consumer that reads names at all.
    test "a class that names no control is left alone" do
      result = annotate("chelekom-card", [attr("class"), attr("label_class")])

      refute editor(result, 0)
      refute editor(result, 1)
    end

    # Every hint is authoritative, so on an attribute that already carries its options any of them —
    # the `text` override included — would replace the dropdown rather than refine it.
    test "nothing is claimed over an attribute that ships its own values" do
      result =
        annotate("chelekom-badge", [
          attr("icon_class", %{"values" => ["sm", "lg"]}),
          attr("icon", %{"values" => ["hero-star", "hero-bell"]})
        ])

      refute editor(result, 0)
      refute editor(result, 1)
    end
  end

  describe "media and url" do
    test "the names this kit uses for a picture are hinted" do
      result =
        annotate("chelekom-image", [attr("src"), attr("image"), attr("thumbnail")])

      assert Enum.map(0..2, &editor(result, &1)) == List.duplicate("media", 3)
    end

    # The rule that decides it: `image_url` is a picture the author picks, not a link they type.
    test "media wins over url" do
      assert annotate("chelekom-card", [attr("image_url")]) |> editor(0) == "media"
    end

    # `srcset` is a list of images with width descriptors, which no single-file picker can produce,
    # and `alt` is the sentence describing the picture rather than the picture.
    test "the neighbours of a picture are not pictures" do
      result = annotate("chelekom-image", [attr("srcset"), attr("alt")])

      refute editor(result, 0)
      refute editor(result, 1)
    end

    test "an address typed by hand is hinted" do
      result =
        annotate("chelekom-button-link", [attr("href"), attr("navigate"), attr("patch")])

      assert Enum.map(0..2, &editor(result, &1)) == List.duplicate("url", 3)
    end

    test "the value of a url field is a url" do
      assert annotate("chelekom-url-field", [attr("value", %{}, "any")]) |> editor(0) == "url"
    end
  end

  describe "the field components that name their own control" do
    # The kit's one real colour: `<input type="color" value={@value}>`.
    test "the value of a colour field is a colour" do
      assert annotate("chelekom-color-field", [attr("value", %{}, "any")]) |> editor(0) == "color"
    end

    # Ninety-odd attributes are called `color` and every one is a vocabulary — `primary`, `natural` —
    # already carrying the list that makes a dropdown. A swatch there would be wrong every time.
    test "the kit's `color` vocabulary is not a swatch" do
      result =
        annotate("chelekom-card", [
          attr("color", %{"values" => ["natural", "primary", "danger"], "default" => "natural"})
        ])

      refute editor(result, 0)
    end

    test "the value of a number or range field is a number" do
      assert annotate("chelekom-number-field", [attr("value", %{}, "any")]) |> editor(0) ==
               "number"

      assert annotate("chelekom-range-field", [attr("value", %{}, "any")]) |> editor(0) ==
               "number"
    end

    # `:integer` says it better than a hint can, because the type carries min, max and step with it.
    test "a number the type already states is left to the type" do
      result = annotate("chelekom-pagination", [attr("total", %{}, "integer")])

      refute editor(result, 0)
    end

    test "the value of a textarea field is prose" do
      assert annotate("chelekom-textarea-field", [attr("value", %{}, "any")]) |> editor(0) ==
               "textarea"
    end

    # Same attribute name, ordinary one-line input.
    test "the value of every other field is left alone" do
      result = annotate("chelekom-text-field", [attr("value", %{}, "any")])

      refute editor(result, 0)
    end
  end

  describe "thin evidence" do
    # The kit's own doc for `description` is "Determines a short description", and it renders on one
    # line. Nothing here is enough to claim a control, so nothing is claimed.
    test "prose-ish names are left to the consumer" do
      result =
        annotate("chelekom-stat", [
          attr("description"),
          attr("title"),
          attr("text"),
          attr("media_size"),
          attr("placeholder")
        ])

      assert Enum.map(0..4, &editor(result, &1)) == List.duplicate(nil, 5)
    end

    # A flag that says whether an icon spins is a switch, and the type already said so. Read ahead of
    # the type, the hint drew an icon picker on a boolean.
    test "a boolean about an icon is a switch, not an icon" do
      result =
        annotate("chelekom-speed-dial", [attr("icon_animated", %{}, "boolean"), attr("icon")])

      refute editor(result, 0)
      assert editor(result, 1) == "icon"
    end

    # The same precedence, asserted rather than assumed: a shape the consumer draws from the type
    # cannot be improved by a hint read from the name, only overruled.
    test "a struct or a global is left to its type whatever it is called" do
      result =
        annotate("chelekom-file-field", [attr("src", %{}, "struct"), attr("href", %{}, "global")])

      refute editor(result, 0)
      refute editor(result, 1)
    end
  end
end
