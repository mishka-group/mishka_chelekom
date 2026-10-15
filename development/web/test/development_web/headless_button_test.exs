defmodule DevelopmentWeb.HeadlessButtonTest do
  @moduledoc """
  The headless button is a link only when it has somewhere to go. A `navigate` or `patch` key that
  is present but nil — a conditional destination that came out empty — leaves it a `<button>`, or
  an `<a>` when an `href` is given.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.{Anchor, Button}

  defp label, do: [%{inner_block: fn _, _ -> "Go" end, __slot__: :inner_block}]

  defp button(assigns),
    do: doc(render_component(&Button.button/1, Map.put(assigns, :inner_block, label())))

  defp anchor(assigns),
    do: doc(render_component(&Anchor.anchor/1, Map.put(assigns, :inner_block, label())))

  test "a nil navigate or patch is still a button" do
    for keys <- [%{navigate: nil}, %{patch: nil}, %{navigate: nil, patch: nil}] do
      doc = button(keys)
      assert tag(doc, ".chelekom-button") == "button", inspect(keys)
      assert attr(doc, ".chelekom-button", "type") == "button", inspect(keys)
    end
  end

  test "a nil navigate or patch leaves the href in charge" do
    doc = button(%{navigate: nil, patch: nil, href: "/docs"})
    assert tag(doc, ".chelekom-button") == "a"
    assert attr(doc, ".chelekom-button", "href") == "/docs"
    refute has_attr?(doc, ".chelekom-button", "data-phx-link")
  end

  test "navigate and patch still render LiveView links" do
    assert attr(button(%{navigate: "/next"}), ".chelekom-button", "data-phx-link") == "redirect"
    assert attr(button(%{patch: "/here"}), ".chelekom-button", "data-phx-link") == "patch"
  end

  test "the anchor follows its href when navigate or patch is nil" do
    for keys <- [%{navigate: nil}, %{patch: nil}] do
      doc = anchor(Map.put(keys, :href, "/docs"))
      assert attr(doc, ".chelekom-anchor", "href") == "/docs", inspect(keys)
      refute has_attr?(doc, ".chelekom-anchor", "data-phx-link"), inspect(keys)
    end

    assert attr(anchor(%{navigate: "/next"}), ".chelekom-anchor", "data-phx-link") == "redirect"
  end
end
