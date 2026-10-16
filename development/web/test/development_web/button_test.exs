defmodule DevelopmentWeb.ButtonTest do
  @moduledoc """
  A `button_link` goes where its first non-nil destination says. A `navigate` or `patch` key that
  is present but nil used to win over an `href`, and the link fell back to `href="#"`.
  """
  use ExUnit.Case, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Button

  defp link(assigns) do
    assigns = Map.put(assigns, :inner_block, [%{inner_block: fn _, _ -> "Go" end}])
    doc(render_component(&Button.button_link/1, assigns))
  end

  test "a nil navigate or patch leaves the href in charge" do
    for key <- [:navigate, :patch] do
      doc = link(%{key => nil, href: "/docs"})
      assert attr(doc, "a", "href") == "/docs", "#{key}: nil"
      refute has_attr?(doc, "a", "data-phx-link"), "#{key}: nil"
    end

    doc = link(%{navigate: nil, patch: "/here", href: "/docs"})
    assert attr(doc, "a", "href") == "/here"
    assert attr(doc, "a", "data-phx-link") == "patch"
  end

  test "navigate and patch still render LiveView links" do
    assert attr(link(%{navigate: "/next"}), "a", "data-phx-link") == "redirect"
    assert attr(link(%{patch: "/here"}), "a", "data-phx-link") == "patch"
    assert attr(link(%{href: "/docs"}), "a", "href") == "/docs"
  end
end
