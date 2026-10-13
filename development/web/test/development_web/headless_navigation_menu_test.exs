defmodule DevelopmentWeb.HeadlessNavigationMenuTest do
  @moduledoc """
  Which items of the navigation menu are links and which open the shared popup.

  An item is a dropdown only when it has body content and no `href`. A CMS hands every slot entry an
  `inner_block`, even one written with nothing inside, so the `href` alone has to make the link.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.NavigationMenu

  defp body(text), do: fn _changed, _arg -> text end

  defp item(label, extra) do
    Map.merge(%{__slot__: :item, label: label, inner_block: nil}, extra)
  end

  defp menu(items) do
    doc(render_component(&NavigationMenu.navigation_menu/1, %{id: "nav", item: items}))
  end

  defp labels(doc, part) do
    doc
    |> LazyHTML.query("[data-part=list] [data-part=#{part}]")
    |> Enum.map(
      &(&1
        |> LazyHTML.text()
        |> String.trim()
        |> String.split("\n")
        |> hd()
        |> String.trim())
    )
  end

  test "an item with body content and no href is a trigger with its own content" do
    doc = menu([item("Overview", %{inner_block: body("Panel")})])

    assert labels(doc, "trigger") == ["Overview"]
    assert labels(doc, "link") == []
    assert doc |> LazyHTML.query("[data-part=content]") |> Enum.count() == 1
  end

  test "an item with an href is a link, whether or not it has an inner block" do
    doc =
      menu([
        item("Overview", %{inner_block: body("Panel")}),
        item("Releases", %{href: "/releases", inner_block: body("")}),
        item("GitHub", %{href: "https://github.com"})
      ])

    assert labels(doc, "trigger") == ["Overview"]
    assert labels(doc, "link") == ["Releases", "GitHub"]
    assert attr(doc, "[data-part=link]", "href") == "/releases"
    assert doc |> LazyHTML.query("[data-part=content]") |> Enum.count() == 1
  end

  test "an item with neither href nor content is a link to #" do
    doc = menu([item("Docs", %{})])

    assert labels(doc, "link") == ["Docs"]
    assert attr(doc, "[data-part=link]", "href") == "#"
  end

  test "the first trigger, not the first item, takes the roving tab stop" do
    doc =
      menu([
        item("Home", %{href: "/", inner_block: body("")}),
        item("Products", %{inner_block: body("Panel")})
      ])

    assert attr(doc, "[data-part=trigger]", "tabindex") == "0"
  end
end
