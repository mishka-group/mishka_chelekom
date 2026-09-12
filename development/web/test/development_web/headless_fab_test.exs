defmodule DevelopmentWeb.HeadlessFabTest do
  @moduledoc """
  The fab's trigger semantics and its slot-driven shape.

  The opening and closing belong to the shared `Popup` engine and are verified in a browser; what
  is pinned here is the markup that engine needs, and the choices daisyUI's `:focus-within` version
  cannot express — a real button, a menu that only exists when there is something in it.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Fab

  defp icon, do: [%{inner_block: fn _, _ -> "+" end, __slot__: :icon}]

  defp actions(list) do
    Enum.map(list, fn a ->
      Map.merge(%{inner_block: fn _, _ -> "i" end, __slot__: :action}, a)
    end)
  end

  defp dial(assigns) do
    defaults = %{id: "f", label: "Actions", icon: icon(), action: []}
    doc(render_component(&Fab.fab/1, Map.merge(defaults, assigns)))
  end

  test "the trigger is a real button, not a div pretending to be one" do
    doc = dial(%{action: actions([%{label: "Share"}])})

    assert tag(doc, "[data-part=trigger]") == "button"
    assert attr(doc, "[data-part=trigger]", "type") == "button"
    assert attr(doc, "[data-part=trigger]", "aria-label") == "Actions"
  end

  test "with actions the trigger owns a menu and reports its state" do
    doc = dial(%{action: actions([%{label: "Share"}, %{label: "Copy"}])})

    assert attr(doc, "[data-part=trigger]", "aria-haspopup") == "true"
    assert attr(doc, "[data-part=trigger]", "aria-expanded") == "false"
    assert attr(doc, "[data-part=trigger]", "aria-controls") == "f-actions"
    assert attr(doc, "[data-part=popup]", "id") == "f-actions"
    assert attr(doc, "[data-part=popup]", "role") == "menu"
    # Closed until the engine says otherwise.
    assert has_attr?(doc, "[data-part=popup]", "data-closed")
  end

  test "a lone fab renders no menu at all, and claims none" do
    doc = dial(%{action: []})

    assert LazyHTML.query(doc, "[data-part=popup]") |> LazyHTML.to_tree() == []
    refute has_attr?(doc, "[data-part=trigger]", "aria-haspopup")
    refute has_attr?(doc, "[data-part=trigger]", "aria-expanded")
  end

  test "every action is a menu item that says what it does" do
    doc = dial(%{action: actions([%{label: "Share"}, %{label: "Copy"}, %{label: "Edit"}])})

    items = LazyHTML.query(doc, "[data-part=action]")
    assert LazyHTML.attribute(items, "role") |> Enum.uniq() == ["menuitem"]
    assert LazyHTML.attribute(items, "aria-label") == ~w(Share Copy Edit)
    assert LazyHTML.attribute(items, "data-index") == ~w(0 1 2)
  end

  test "an action becomes a link when it has somewhere to go" do
    doc =
      dial(%{
        action: actions([%{label: "Docs", href: "/docs"}, %{label: "Home", navigate: "/"}])
      })

    assert LazyHTML.query(doc, "[data-part=action]") |> LazyHTML.tag() == ~w(a a)
    assert attr(doc, "[data-part=action]", "href") == "/docs"
  end

  test "a disabled action is inert to the browser and to the click handler" do
    doc = dial(%{action: actions([%{label: "Share", on_click: "share", disabled: true}])})

    assert has_attr?(doc, "[data-part=action]", "disabled")
    assert has_attr?(doc, "[data-part=action]", "data-disabled")
    refute has_attr?(doc, "[data-part=action]", "phx-click")
  end

  test "a visible label is opt-in, and the action is announced either way" do
    quiet = dial(%{action: actions([%{label: "Share"}])})
    assert LazyHTML.query(quiet, "[data-part=label]") |> LazyHTML.to_tree() == []
    assert attr(quiet, "[data-part=action]", "aria-label") == "Share"

    loud = dial(%{action: actions([%{label: "Share", show_label: true}])})
    assert LazyHTML.query(loud, "[data-part=label]") |> LazyHTML.text() == "Share"
    assert attr(loud, "[data-part=label]", "aria-hidden") == "true"
  end

  test "a close icon renames the trigger, since it no longer opens anything" do
    plain = dial(%{action: actions([%{label: "Share"}])})
    assert attr(plain, "[data-part=trigger]", "aria-label") == "Actions"

    doc =
      dial(%{
        action: actions([%{label: "Share"}]),
        close_icon: [%{inner_block: fn _, _ -> "x" end, __slot__: :close_icon}]
      })

    assert attr(doc, "[data-part=trigger]", "aria-label") == "Close"

    states =
      doc
      |> LazyHTML.query("[data-part=trigger] [data-part=icon]")
      |> LazyHTML.attribute("data-state")

    assert states == ~w(closed open)
  end

  test "a main action rides in the menu as its own part" do
    doc =
      dial(%{
        action: actions([%{label: "Share"}]),
        main_action: [
          %{inner_block: fn _, _ -> "m" end, __slot__: :main_action, label: "Compose"}
        ]
      })

    assert attr(doc, "[data-part=main-action]", "aria-label") == "Compose"
    assert attr(doc, "[data-part=main-action]", "role") == "menuitem"
  end

  test "direction picks the side the shared engine places the menu on" do
    for {direction, side} <- [
          {"up", "top"},
          {"down", "bottom"},
          {"left", "left"},
          {"right", "right"}
        ] do
      doc = dial(%{direction: direction, action: actions([%{label: "A"}])})
      assert attr(doc, "[data-part=root]", "data-side") == side, direction
      assert attr(doc, "[data-part=root]", "data-direction") == direction
    end

    # Flower is a layout the skin draws, not a placement the engine understands.
    flower = dial(%{direction: "flower", action: actions([%{label: "A"}])})
    assert attr(flower, "[data-part=root]", "data-direction") == "flower"
  end

  test "contained is what lets more than one fab share a page" do
    refute has_attr?(dial(%{}), "[data-part=root]", "data-contained")
    assert has_attr?(dial(%{contained: true}), "[data-part=root]", "data-contained")
  end

  test "every fab in the showcase is contained, or they would stack in one corner" do
    {:ok, _view, html} = live(build_conn(), "/showcase/headless-daisyui/fab")

    roots =
      html
      |> LazyHTML.from_document()
      |> LazyHTML.query("[data-part=root].chelekom-fab")

    assert length(LazyHTML.to_tree(roots)) >= 9
    assert Enum.all?(roots, &(LazyHTML.attribute(&1, "data-contained") != []))
  end
end
