defmodule MishkaChelekom.CmsBundle.EditorHintsTest do
  @moduledoc """
  The bundle says which control an attribute wants, so the consumer stops guessing from its name.

  The case that forced this: `chelekom-icon` is the one component that is nothing but an icon, and it
  calls its attribute `name` — so every name-based guess downstream missed it and drew a text box on
  the one control where a picker matters most.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.CmsBundle.EditorHints

  defp component(name, attrs), do: %{"name" => name, "attrs" => attrs}
  defp attr(name, opts \\ %{}), do: %{"name" => name, "type" => "string", "opts" => opts}

  defp editor(component, index),
    do: get_in(component, ["attrs", Access.at(index), "opts", "editor"])

  describe "annotate/1" do
    test "an attribute named for an icon is hinted" do
      [result] =
        EditorHints.annotate([
          component("chelekom-alert", [attr("icon"), attr("dismiss_icon"), attr("title")])
        ])

      assert editor(result, 0) == "icon"
      assert editor(result, 1) == "icon"
      refute editor(result, 2)
    end

    # The whole reason this module exists.
    test "`name` on an icon component is hinted" do
      [result] = EditorHints.annotate([component("chelekom-icon", [attr("name"), attr("class")])])

      assert editor(result, 0) == "icon"
      refute editor(result, 1)
    end

    # `name` means something else everywhere else — a navbar's name is not an icon.
    test "`name` on anything else is left alone" do
      [result] = EditorHints.annotate([component("chelekom-navbar", [attr("name")])])

      refute editor(result, 0)
    end

    test "a hand-written hint is never overwritten" do
      [result] =
        EditorHints.annotate([component("chelekom-icon", [attr("name", %{"editor" => "text"})])])

      assert editor(result, 0) == "text"
    end

    test "everything else about the attribute survives" do
      [result] =
        EditorHints.annotate([
          component("chelekom-alert", [
            attr("icon", %{"default" => "hero-bell", "required" => true})
          ])
        ])

      assert get_in(result, ["attrs", Access.at(0), "opts", "default"]) == "hero-bell"
      assert get_in(result, ["attrs", Access.at(0), "opts", "required"]) == true
      assert editor(result, 0) == "icon"
    end

    test "a component with no attrs, or a malformed one, does not raise" do
      assert [%{"name" => "x", "attrs" => []}] = EditorHints.annotate([%{"name" => "x"}])
      assert [%{"attrs" => ["junk"]}] = EditorHints.annotate([component("x", ["junk"])])
    end
  end
end
