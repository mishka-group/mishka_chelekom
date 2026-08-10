defmodule DevelopmentWeb.HeadlessTextareaTest do
  @moduledoc """
  The headless textarea inside a real Phoenix form.

  Two things are easy to get wrong and are therefore pinned here: a textarea's value is text
  content, not an attribute, and the Autosize hook must be opt-in — a textarea that ships a hook it
  does not need costs every page that renders one.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.Component, only: [to_form: 2]
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Textarea

  @errors [bio: {"should be at most %{count} characters", [count: 5]}]

  defp profile(params), do: to_form(params, as: :profile, errors: @errors)

  test "takes its id, name and value from the field" do
    f = profile(%{"bio" => "Elixir developer"})
    doc = doc(render_component(&Textarea.textarea/1, id: nil, field: f[:bio]))

    assert attr(doc, "textarea", "id") == f[:bio].id
    assert attr(doc, "textarea", "name") == f[:bio].name
  end

  test "renders the value as text content, not an attribute" do
    f = profile(%{"bio" => "Elixir developer"})
    doc = doc(render_component(&Textarea.textarea/1, id: nil, field: f[:bio]))

    assert LazyHTML.text(doc) =~ "Elixir developer"
    refute has_attr?(doc, "textarea", "value")
  end

  test "a pristine field is not marked invalid; a used one is" do
    pristine = doc(render_component(&Textarea.textarea/1, id: nil, field: profile(%{})[:bio]))
    refute has_attr?(pristine, "[data-part=root]", "data-invalid")

    used =
      doc(
        render_component(&Textarea.textarea/1,
          id: nil,
          field: profile(%{"bio" => "toolong"})[:bio]
        )
      )

    assert attr(used, "textarea", "aria-invalid") == "true"
    assert has_attr?(used, "[data-part=root]", "data-invalid")
  end

  test "autosize is the only thing that adds a hook" do
    plain = doc(render_component(&Textarea.textarea/1, id: "p", name: "p"))
    refute has_attr?(plain, "textarea", "phx-hook")

    auto =
      doc(render_component(&Textarea.textarea/1, id: "a", name: "a", autosize: true, max_rows: 6))

    assert attr(auto, "textarea", "phx-hook") == "Autosize"
    assert attr(auto, "textarea", "data-max-rows") == "6"
    # A resize handle would fight the hook for the inline height.
    assert attr(auto, "textarea", "data-resize") == "none"
  end

  test "rows falls back to min_rows so an autosizing box starts at its floor" do
    doc =
      doc(render_component(&Textarea.textarea/1, id: "a", name: "a", autosize: true, min_rows: 4))

    assert attr(doc, "textarea", "rows") == "4"

    explicit =
      doc(render_component(&Textarea.textarea/1, id: "b", name: "b", rows: 7, min_rows: 4))

    assert attr(explicit, "textarea", "rows") == "7"
  end

  test "the showcase form pushes a change on every keystroke", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/textarea")

    html =
      view
      |> form("#daisyui-textarea-form-el")
      |> render_change(%{"profile" => %{"bio" => "hello"}})

    assert html =~ "5 characters"
  end
end
