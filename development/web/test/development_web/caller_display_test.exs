defmodule DevelopmentWeb.CallerDisplayTest do
  @moduledoc """
  A display utility in the caller's `class` replaces the component's own.

  Tailwind writes display utilities in name order, so `inline-flex` comes after `hidden` and wins
  wherever both are on one element, whatever the order of the class list. A component that keeps
  its own display beside the caller's could never be hidden with `class="hidden md:flex"`.
  """
  use ExUnit.Case, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.{
    Avatar,
    Badge,
    Button,
    Indicator,
    Layout,
    Shape,
    Spinner,
    Stat,
    Table
  }

  @displays ~w(block inline-block inline flex inline-flex table inline-table table-caption
    table-cell table-column table-column-group table-footer-group table-header-group
    table-row-group table-row flow-root grid inline-grid contents list-item hidden)

  defp slot(text), do: [%{inner_block: fn _, _ -> text end, __slot__: :inner_block}]

  # {component, assigns it needs, the display it draws when the caller names none, its parent}
  defp components do
    [
      {&Button.button/1, %{inner_block: slot("Save")}, "inline-flex", :div},
      {&Button.button_link/1, %{navigate: "/", inner_block: slot("Home")}, "inline-flex", :div},
      {&Button.input_button/1, %{value: "Send"}, "inline-block", :div},
      {&Button.button_group/1, %{inner_block: slot("")}, "flex", :div},
      {&Badge.badge/1, %{inner_block: slot("New")}, "inline-flex", :div},
      {&Shape.shape/1, %{}, "inline-block", :div},
      {&Table.tr/1, %{inner_block: slot("")}, "table-row", :tbody},
      {&Layout.flex/1, %{inner_block: slot("")}, "flex", :div},
      {&Layout.grid/1, %{inner_block: slot("")}, "grid", :div},
      {&Avatar.avatar_group/1, %{inner_block: slot("")}, "flex", :div},
      {&Indicator.indicator/1, %{}, "block", :div},
      {&Spinner.spinner/1, %{type: "dots"}, "flex", :div},
      {&Stat.stat_group/1, %{inner_block: slot("")}, "flex", :div}
    ]
  end

  defp root_classes(component, assigns, parent) do
    component
    |> render_component(assigns)
    |> parse(parent)
    |> LazyHTML.query("#test-root > *")
    |> LazyHTML.attribute("class")
    |> List.first()
    |> String.split()
  end

  # A `<tr>` outside a table is dropped by the HTML parser.
  defp parse(html, :tbody),
    do: LazyHTML.from_fragment(~s|<table><tbody id="test-root">| <> html <> "</tbody></table>")

  defp parse(html, :div), do: doc(html)

  defp displays(classes), do: Enum.filter(classes, &(&1 in @displays))

  test "without a display in the caller's class, a component keeps its own" do
    for {component, assigns, own, parent} <- components() do
      assert displays(root_classes(component, assigns, parent)) == [own], inspect(component)
    end
  end

  test "a caller's hidden is the only display left, so it hides the component" do
    for {component, assigns, _own, parent} <- components() do
      classes = root_classes(component, Map.put(assigns, :class, "hidden md:flex"), parent)

      assert displays(classes) == ["hidden"], inspect(component)
      assert "md:flex" in classes, inspect(component)
    end
  end

  test "any display utility the caller names replaces the component's" do
    for {component, assigns, _own, parent} <- components(), display <- ~w(block grid contents) do
      classes = root_classes(component, Map.put(assigns, :class, ["px-2", display]), parent)
      assert displays(classes) == [display], "#{inspect(component)} with #{display}"
    end
  end

  test "a display behind a variant leaves the component's own in place" do
    for {component, assigns, own, parent} <- components() do
      classes = root_classes(component, Map.put(assigns, :class, "max-md:hidden"), parent)
      assert displays(classes) == [own], inspect(component)
    end
  end

  test "a button's display attribute steps aside for a display in its class" do
    assigns = %{inner_block: slot("Save"), display: "block"}

    assert displays(root_classes(&Button.button/1, assigns, :div)) == ["block"]

    hidden = Map.put(assigns, :class, "hidden")
    assert displays(root_classes(&Button.button/1, hidden, :div)) == ["hidden"]
  end
end
