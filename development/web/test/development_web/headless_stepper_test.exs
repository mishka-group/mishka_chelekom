defmodule DevelopmentWeb.HeadlessStepperTest do
  @moduledoc """
  The stepper's derived state and its selectability rules.

  `active` is a single number the whole component reads, so the tests sweep it across a flow rather
  than pinning one arrangement — the interesting cases are the first step, the last, and the
  boundary either side of the current one.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Stepper

  @labels ~w(Register Plan Purchase Receive)

  defp steps(overrides \\ %{}) do
    @labels
    |> Enum.with_index()
    |> Enum.map(fn {label, index} ->
      %{inner_block: nil, __slot__: :step, label: label}
      |> Map.merge(Map.get(overrides, index, %{}))
    end)
  end

  defp flow(assigns) do
    doc(render_component(&Stepper.stepper/1, Map.merge(%{id: "s", step: steps()}, assigns)))
  end

  defp states(doc), do: parts_attr(doc, "[data-part=step]", "data-state")

  defp parts_attr(doc, selector, name) do
    doc |> LazyHTML.query(selector) |> LazyHTML.attribute(name)
  end

  test "the root is an ordered list carrying its orientation" do
    doc = flow(%{orientation: "vertical", label: "Checkout"})

    assert tag(doc, "[data-part=root]") == "ol"
    assert attr(doc, "[data-part=root]", "aria-label") == "Checkout"
    assert attr(doc, "[data-part=root]", "data-orientation") == "vertical"
  end

  test "state is derived from active for every position in the flow" do
    for active <- 0..(length(@labels) - 1) do
      expected =
        Enum.map(0..(length(@labels) - 1), fn i ->
          cond do
            i < active -> "complete"
            i == active -> "current"
            true -> "incomplete"
          end
        end)

      assert states(flow(%{active: active})) == expected, "active=#{active}"
    end
  end

  test "exactly one step is aria-current, and it is the active one" do
    for active <- 0..(length(@labels) - 1) do
      doc = flow(%{active: active})
      currents = parts_attr(doc, "[data-part=step][aria-current]", "data-index")
      assert currents == [to_string(active)]
      assert parts_attr(doc, "[data-part=step][aria-current]", "aria-current") == ["step"]
    end
  end

  test "a step can override the derived state for a flow that is not linear" do
    doc = flow(%{active: 3, step: steps(%{1 => %{state: "incomplete"}})})
    assert states(doc) == ~w(complete incomplete complete current)
  end

  test "without on_select nothing is selectable" do
    doc = flow(%{active: 3})
    assert parts_attr(doc, "[data-part=action]", "data-part") == []
  end

  test "on_select makes every reached step an action, and no more" do
    for active <- 0..(length(@labels) - 1) do
      doc = flow(%{active: active, on_select: "pick"})
      actions = parts_attr(doc, "[data-part=step]:has([data-part=action])", "data-index")
      assert actions == Enum.map(0..active, &to_string/1), "active=#{active}"
    end
  end

  test "allow_next opens up the steps after the current one too" do
    doc = flow(%{active: 0, on_select: "pick", allow_next: true})
    assert length(parts_attr(doc, "[data-part=action]", "data-part")) == length(@labels)
  end

  test "a disabled step is never selectable, however it is reached" do
    doc =
      flow(%{
        active: 3,
        on_select: "pick",
        allow_next: true,
        step: steps(%{2 => %{disabled: true}})
      })

    refute "2" in parts_attr(doc, "[data-part=step]:has([data-part=action])", "data-index")
    assert has_attr?(doc, "[data-part=step][data-index='2']", "data-disabled")
  end

  test "the action pushes the step's own index" do
    doc = flow(%{active: 2, on_select: "pick"})
    clicks = parts_attr(doc, "[data-part=action]", "phx-click")

    for {click, index} <- Enum.with_index(clicks) do
      assert click =~ ~s("index":#{index}), "action #{index} should push its own index"
    end
  end

  test "the action is labelled by the step's own label" do
    doc = flow(%{active: 0, on_select: "pick"})
    assert attr(doc, "[data-part=action]", "aria-labelledby") == "s-label-0"
    assert attr(doc, "[data-part=label]", "id") == "s-label-0"
  end

  test "a step with a link is an anchor, reachable regardless of active" do
    doc = flow(%{active: 0, step: steps(%{3 => %{navigate: "/last"}})})

    assert tag(doc, "[data-part=action]") == "a"
    assert attr(doc, "[data-part=action]", "href") == "/last"
    assert attr(doc, "[data-part=action]", "data-phx-link") == "redirect"
  end

  test "the indicator is empty unless the step gives it content, so a skin can number it" do
    plain = flow(%{})

    assert LazyHTML.query(plain, "[data-part=indicator]") |> Enum.map(&LazyHTML.text/1) == [
             "",
             "",
             "",
             ""
           ]

    with_icon = flow(%{step: steps(%{0 => %{inner_block: fn _, _ -> "✓" end}})})

    assert with_icon |> LazyHTML.query("[data-part=indicator]") |> Enum.at(0) |> LazyHTML.text() ==
             "✓"
  end

  test "content rides on the indicator for the skin to draw instead of the number" do
    doc = flow(%{step: steps(%{0 => %{content: "?"}})})
    assert attr(doc, "[data-part=indicator]", "data-content") == "?"
  end

  test "horizontal_from is what makes the responsive form possible" do
    doc = flow(%{orientation: "vertical", horizontal_from: "lg"})
    assert attr(doc, "[data-part=root]", "data-orientation") == "vertical"
    assert attr(doc, "[data-part=root]", "data-orientation-from") == "lg"
  end

  test "the showcase's selectable flow reports the step that was clicked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/stepper")

    html =
      view
      |> element(
        "#daisyui-stepper-interactive [data-part=step][data-index='1'] [data-part=action]"
      )
      |> render_click()

    assert html =~ "step 1"
  end
end
