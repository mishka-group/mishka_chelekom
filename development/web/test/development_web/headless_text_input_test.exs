defmodule DevelopmentWeb.HeadlessTextInputTest do
  @moduledoc """
  The headless text input inside a real Phoenix form.

  The rest of the headless line takes an explicit `name`/`value`. This one also accepts a
  `Phoenix.HTML.FormField`, which is what a Phoenix developer actually reaches for, so what has to
  hold is the derivation: the id, the name and the value come off the form, the caller can still
  override any one of them, and an error only surfaces once `Phoenix.Component.used_input?/1` says
  the user has had a chance to cause it.

  The forms are built the way a LiveView builds them — `to_form/2` over params — rather than from
  fixed strings, so a change in how Phoenix names or nests fields fails here instead of shipping.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.Component, only: [to_form: 2]
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.TextInput

  @errors [email: {"must have the @ sign", []}]

  defp profile(params), do: to_form(params, as: :profile, errors: @errors)

  test "takes its id, name and value from the field" do
    f = profile(%{"email" => "nope"})
    doc = doc(render_component(&TextInput.text_input/1, id: nil, field: f[:email], type: "email"))

    assert attr(doc, "input", "id") == f[:email].id
    assert attr(doc, "input", "name") == f[:email].name
    assert attr(doc, "input", "value") == "nope"
    assert attr(doc, "input", "type") == "email"
  end

  test "an explicit id, name or value still wins over the field" do
    f = profile(%{"email" => "nope"})

    doc =
      doc(
        render_component(&TextInput.text_input/1,
          field: f[:email],
          id: "my-id",
          name: "my_name",
          value: "mine@example.com"
        )
      )

    assert attr(doc, "input", "id") == "my-id"
    assert attr(doc, "input", "name") == "my_name"
    assert attr(doc, "input", "value") == "mine@example.com"
  end

  test "a pristine field carries its error but does not show it" do
    f = profile(%{})
    assert f[:email].errors != [], "the fixture must have an error to gate"

    doc = doc(render_component(&TextInput.text_input/1, id: nil, field: f[:email]))

    refute has_attr?(doc, "input", "aria-invalid")
    refute has_attr?(doc, "[data-part=root]", "data-invalid")
  end

  test "a used field is marked invalid" do
    doc =
      doc(
        render_component(&TextInput.text_input/1,
          id: nil,
          field: profile(%{"email" => "x"})[:email]
        )
      )

    assert attr(doc, "input", "aria-invalid") == "true"
    assert has_attr?(doc, "[data-part=root]", "data-invalid")
  end

  test "validity is a tri-state — valid and invalid never appear together" do
    valid = doc(render_component(&TextInput.text_input/1, id: "v", name: "v", valid: true))
    assert has_attr?(valid, "[data-part=root]", "data-valid")
    refute has_attr?(valid, "[data-part=root]", "data-invalid")

    both =
      doc(
        render_component(&TextInput.text_input/1, id: "b", name: "b", valid: true, errors: ["no"])
      )

    assert has_attr?(both, "[data-part=root]", "data-invalid")
    refute has_attr?(both, "[data-part=root]", "data-valid")
  end

  test "sections render as their own parts, in order" do
    doc =
      doc(
        render_component(&TextInput.text_input/1, %{
          id: "s",
          name: "s",
          start_section: [%{inner_block: fn _, _ -> "https://" end, __slot__: :start_section}],
          end_section: [%{inner_block: fn _, _ -> ".com" end, __slot__: :end_section}]
        })
      )

    assert parts(doc, "[data-part]") == ["root", "start-section", "input", "end-section"]
  end

  test "the showcase form echoes the params the field derived", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/text_input")

    html = view |> form("#daisyui-input-form") |> render_submit()

    # The names came from `to_form(..., as: :touched)`, so they must arrive nested under it.
    assert html =~ "touched"
    assert html =~ "email"
  end
end
