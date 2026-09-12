defmodule DevelopmentWeb.HeadlessThemeControllerTest do
  @moduledoc """
  The theme controller's markup contract.

  Applying and remembering a theme is the hook's job and is verified in a browser; what has to hold
  here is the shape the hook depends on — native inputs, one option per theme, and the extra value
  a switch needs so it has something to switch *back* to.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.ThemeController

  defp themes(values) do
    Enum.map(values, fn value ->
      %{inner_block: nil, __slot__: :option, value: value}
    end)
  end

  defp picker(assigns) do
    defaults = %{id: "t", option: themes(~w(light dark))}
    doc(render_component(&ThemeController.theme_controller/1, Map.merge(defaults, assigns)))
  end

  defp values(doc),
    do: doc |> LazyHTML.query("[data-part=input]") |> LazyHTML.attribute("data-value")

  test "the root tells the hook where to paint, what to store under, and what to push" do
    doc = picker(%{target: "#preview", storage_key: "site-theme", on_change: "themed"})

    assert attr(doc, "[data-part=root]", "data-target") == "#preview"
    assert attr(doc, "[data-part=root]", "data-storage-key") == "site-theme"
    assert attr(doc, "[data-part=root]", "data-on-change") == "themed"
    assert attr(doc, "[data-part=root]", "phx-hook") == "ThemeController"
  end

  test "the storage key and the input name fall back to the id" do
    doc = picker(%{id: "site"})

    assert attr(doc, "[data-part=root]", "data-storage-key") == "site"
    assert attr(doc, "[data-part=input]", "name") == "site"
  end

  test "an empty storage key is honoured, for a controller that should not remember" do
    doc = picker(%{storage_key: ""})
    assert attr(doc, "[data-part=root]", "data-storage-key") == ""
  end

  test "themes render as native radios, one per option, inside their own labels" do
    doc = picker(%{option: themes(~w(light dark retro cyberpunk))})

    assert attr(doc, "[data-part=root]", "role") == "radiogroup"
    assert tag(doc, "[data-part=option]") == "label"

    assert doc |> LazyHTML.query("[data-part=input]") |> LazyHTML.attribute("type") |> Enum.uniq() ==
             ["radio"]

    assert values(doc) == ~w(light dark retro cyberpunk)
  end

  test "the selected theme is marked on the option as well as the input" do
    doc = picker(%{option: themes(~w(light dark)), value: "dark"})

    assert attr(doc, "[data-part=option][data-checked]", "data-value") == "dark"
    assert has_attr?(doc, "[data-part=input][value=dark]", "checked")
    refute has_attr?(doc, "[data-part=input][value=light]", "checked")
  end

  test "a switch is one checkbox that knows both themes" do
    doc = picker(%{option: themes(~w(light dark)), switch: true})

    assert attr(doc, "[data-part=input]", "type") == "checkbox"
    assert values(doc) == ["dark"]
    # Without the off value the switch would have nothing to go back to.
    assert attr(doc, "[data-part=input]", "data-unchecked-value") == "light"
    # A lone checkbox is not a radio group.
    refute has_attr?(doc, "[data-part=root]", "role")
  end

  test "a switch over three themes still only offers the first two" do
    doc = picker(%{option: themes(~w(light dark retro)), switch: true})

    assert values(doc) == ["dark"]
    assert attr(doc, "[data-part=input]", "data-unchecked-value") == "light"
  end

  test "the system option is opt-in and comes last" do
    plain = picker(%{})
    refute "system" in values(plain)

    doc = picker(%{system: true, system_label: "Auto"})
    assert values(doc) == ~w(light dark system)

    assert doc |> LazyHTML.query("[data-part=label]") |> Enum.map(&LazyHTML.text/1) |> List.last() ==
             "Auto"
  end

  test "a label falls back to the theme's own name, and a slot body replaces it" do
    plain = picker(%{option: themes(~w(light dark))})

    assert plain |> LazyHTML.query("[data-part=label]") |> Enum.map(&LazyHTML.text/1) ==
             ~w(light dark)

    named =
      picker(%{option: [%{inner_block: nil, __slot__: :option, value: "dark", label: "Night"}]})

    assert LazyHTML.query(named, "[data-part=label]") |> LazyHTML.text() == "Night"

    slotted =
      picker(%{
        option: [%{inner_block: fn _, _ -> "🌙" end, __slot__: :option, value: "dark"}]
      })

    assert LazyHTML.query(slotted, "[data-part=label]") |> LazyHTML.text() == "🌙"
  end

  test "every showcase controller targets its own box, never the page" do
    # A gallery of controllers that all painted `:root` would fight, and the last click would win
    # the whole page.
    {:ok, _view, html} = live(build_conn(), "/showcase/headless-daisyui/theme_controller")

    targets =
      html
      |> LazyHTML.from_document()
      |> LazyHTML.query("[data-part=root][data-target]")
      |> LazyHTML.attribute("data-target")

    assert length(targets) >= 10

    assert Enum.all?(targets, &String.starts_with?(&1, "#")),
           "a controller escaped its preview box"
  end
end
