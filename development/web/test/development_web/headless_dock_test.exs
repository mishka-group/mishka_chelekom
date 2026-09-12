defmodule DevelopmentWeb.HeadlessDockTest do
  @moduledoc """
  The dock's element choice and its active/hidden-label semantics.

  The interesting decisions are all about what an item *becomes*: a link, a button, or plain text
  when it goes nowhere — and whether hiding the labels keeps them for a screen reader.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Dock

  defp items(overrides) do
    Enum.map(overrides, fn o ->
      Map.merge(%{inner_block: fn _, _ -> "icon" end, __slot__: :item}, o)
    end)
  end

  defp bar(assigns) do
    defaults = %{id: "d", item: items([%{label: "Home", href: "#"}])}
    doc(render_component(&Dock.dock/1, Map.merge(defaults, assigns)))
  end

  defp tags(doc), do: doc |> LazyHTML.query("[data-part=item]") |> LazyHTML.tag()

  test "the root is a named navigation landmark" do
    doc = bar(%{label: "Sections"})

    assert tag(doc, "[data-part=root]") == "nav"
    assert attr(doc, "[data-part=root]", "aria-label") == "Sections"
    assert attr(doc, "[data-part=root]", "data-position") == "bottom"
  end

  test "an item is a link, a button or plain text depending on what it does" do
    doc =
      bar(%{
        item:
          items([
            %{label: "Link", href: "/x"},
            %{label: "Nav", navigate: "/y"},
            %{label: "Patch", patch: "/z"},
            %{label: "Button", on_select: "pick"},
            %{label: "Nothing"}
          ])
      })

    assert tags(doc) == ~w(a a a button span)
  end

  test "a link carries the LiveView markers its kind implies" do
    doc = bar(%{item: items([%{label: "Nav", navigate: "/y"}, %{label: "Patch", patch: "/z"}])})

    kinds = doc |> LazyHTML.query("[data-part=item]") |> LazyHTML.attribute("data-phx-link")
    assert kinds == ~w(redirect patch)
  end

  test "the active item is announced as current, not merely coloured" do
    doc =
      bar(%{item: items([%{label: "A", href: "#"}, %{label: "B", href: "#", active: true}])})

    assert attr(doc, "[data-part=item][data-active]", "aria-current") == "page"

    currents =
      doc |> LazyHTML.query("[data-part=item][aria-current]") |> LazyHTML.attribute("data-index")

    assert currents == ["1"]
  end

  test "a button pushes its own index" do
    doc =
      bar(%{item: items([%{label: "A", on_select: "pick"}, %{label: "B", on_select: "pick"}])})

    clicks = doc |> LazyHTML.query("[data-part=item]") |> LazyHTML.attribute("phx-click")

    for {click, index} <- Enum.with_index(clicks) do
      assert click =~ ~s("index":#{index})
    end
  end

  test "a disabled item is inert to both the browser and assistive tech" do
    doc = bar(%{item: items([%{label: "A", on_select: "pick", disabled: true}])})

    assert has_attr?(doc, "[data-part=item]", "disabled")
    assert attr(doc, "[data-part=item]", "aria-disabled") == "true"
    refute has_attr?(doc, "[data-part=item]", "phx-click")
  end

  test "hiding the labels keeps them in the DOM for screen readers" do
    shown = bar(%{show_labels: true})
    refute has_attr?(shown, "[data-part=label]", "data-hidden")

    hidden = bar(%{show_labels: false})
    assert has_attr?(hidden, "[data-part=label]", "data-hidden")
    assert LazyHTML.query(hidden, "[data-part=label]") |> LazyHTML.text() == "Home"
  end

  test "the icon is decorative" do
    assert attr(bar(%{}), "[data-part=icon]", "aria-hidden") == "true"
  end

  test "contained is what lets a dock live inside a box instead of the viewport" do
    refute has_attr?(bar(%{}), "[data-part=root]", "data-contained")
    assert has_attr?(bar(%{contained: true}), "[data-part=root]", "data-contained")
  end

  test "position rides on the root for the skin to flip the border and the pill" do
    assert attr(bar(%{position: "top"}), "[data-part=root]", "data-position") == "top"
  end

  test "the showcase's panel dock reports which panel was picked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/dock")

    html =
      view
      |> element("#daisyui-dock-interactive [data-part=item][data-index='2']")
      |> render_click()

    assert html =~ "panel 2"
  end
end
