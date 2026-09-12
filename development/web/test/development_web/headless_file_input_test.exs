defmodule DevelopmentWeb.HeadlessFileInputTest do
  @moduledoc """
  The headless file input inside a real Phoenix form.

  This control is the odd one out: the input *is* the root, because `::file-selector-button` — the
  browser's own button, and the visible half of the control — only exists on the input. The tests
  pin that, and the `[]` suffix a multi-file field needs before Plug will build a list.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.Component, only: [to_form: 2]
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.FileInput

  defp upload_form(params), do: to_form(params, as: :upload)

  test "a single-file input keeps the form's name" do
    f = upload_form(%{})
    doc = doc(render_component(&FileInput.file_input/1, id: nil, field: f[:avatar]))

    assert attr(doc, "input", "type") == "file"
    assert attr(doc, "input", "id") == f[:avatar].id
    assert attr(doc, "input", "name") == f[:avatar].name
    refute has_attr?(doc, "input", "multiple")
  end

  test "a multiple-file input gains the [] Plug needs to build a list" do
    f = upload_form(%{})

    doc =
      doc(render_component(&FileInput.file_input/1, id: nil, field: f[:gallery], multiple: true))

    assert attr(doc, "input", "name") == f[:gallery].name <> "[]"
    assert has_attr?(doc, "input", "multiple")
  end

  test "the input is the root, so a skin's classes reach ::file-selector-button" do
    doc =
      doc(render_component(&FileInput.file_input/1, id: "f", name: "f", class: "d-file-input-sm"))

    assert tag(doc, "[data-part=input]") == "input"
    class = attr(doc, "input", "class")
    assert class =~ "chelekom-file-input"
    assert class =~ "d-file-input-sm"
  end

  test "disabled is reflected for CSS as well as for the browser" do
    doc = doc(render_component(&FileInput.file_input/1, id: "f", name: "f", disabled: true))

    assert has_attr?(doc, "input", "disabled")
    assert has_attr?(doc, "input", "data-disabled")
  end

  test "the showcase form posts both the single and the list field", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/showcase/headless-daisyui/file_input")

    html = view |> element("#daisyui-file-form") |> render()

    assert html =~ ~s|name="upload[attachment]"|
    assert html =~ ~s|name="upload[gallery][]"|
  end
end
