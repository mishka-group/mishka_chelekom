defmodule DevelopmentWeb.HeadlessRadioGroupTest do
  @moduledoc """
  The radio group's own contract, over and above the single `radio`.

  The group is what makes a set of radios usable: one tab stop, an orientation the engine's arrow
  keys follow, and a hidden input that carries the choice into a form.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.RadioGroup

  defp options(values) do
    Enum.map(values, fn
      {value, opts} ->
        Map.merge(%{inner_block: fn _, _ -> value end, __slot__: :option, value: value}, opts)

      value ->
        %{inner_block: fn _, _ -> value end, __slot__: :option, value: value}
    end)
  end

  defp group(assigns) do
    defaults = %{id: "g", option: options(~w(solo team enterprise))}
    doc(render_component(&RadioGroup.radio_group/1, Map.merge(defaults, assigns)))
  end

  test "orientation is exposed and reaches the attribute the engine reads" do
    assert attr(group(%{}), "[role=radiogroup]", "data-orientation") == "vertical"

    assert attr(group(%{orientation: "horizontal"}), "[role=radiogroup]", "data-orientation") ==
             "horizontal"
  end

  test "the group is one tab stop, on the selected option" do
    doc = group(%{value: "team"})
    tabindexes = doc |> LazyHTML.query("[data-part=item]") |> LazyHTML.attribute("tabindex")

    assert Enum.count(tabindexes, &(&1 == "0")) == 1
    assert attr(doc, ~s|[data-part=item][aria-checked="true"]|, "tabindex") == "0"
  end

  test "with nothing selected the first enabled option is the tab stop" do
    doc = group(%{option: options([{"solo", %{disabled: true}}, "team", "enterprise"])})

    tabbable =
      doc
      |> LazyHTML.query(~s|[data-part=item][tabindex="0"]|)
      |> LazyHTML.attribute("data-value")

    assert tabbable == ["team"], "a disabled option must not be the way into the group"
  end

  test "exactly one option is checked, and it is the value" do
    doc = group(%{value: "enterprise"})

    checked =
      doc
      |> LazyHTML.query(~s|[data-part=item][aria-checked="true"]|)
      |> LazyHTML.attribute("data-value")

    assert checked == ["enterprise"]
  end

  test "disabling the group and disabling one option are different things" do
    whole = group(%{disabled: true})
    assert has_attr?(whole, "[role=radiogroup]", "data-disabled")

    one = group(%{option: options(["solo", {"team", %{disabled: true}}])})
    refute has_attr?(one, "[role=radiogroup]", "data-disabled")
    assert attr(one, "[data-part=item][data-disabled]", "data-value") == "team"
  end

  test "readonly freezes the selection without removing the group from the tab order" do
    doc = group(%{readonly: true, value: "team"})

    assert attr(doc, "[role=radiogroup]", "aria-readonly") == "true"
    assert attr(doc, ~s|[data-part=item][aria-checked="true"]|, "tabindex") == "0"
  end

  test "the hidden input is what carries the choice into a form" do
    doc = group(%{name: "plan", value: "team"})

    assert attr(doc, "input[type=hidden]", "name") == "plan"
    assert attr(doc, "input[type=hidden]", "value") == "team"
  end

  test "the showcase form reports the plan that was picked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/radio_group")

    html =
      view
      |> form("#daisyui-radio-group-form-el")
      |> render_change(%{"plan_form" => "enterprise"})

    assert html =~ "plan enterprise"
  end
end
