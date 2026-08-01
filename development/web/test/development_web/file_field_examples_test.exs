defmodule DevelopmentWeb.FileFieldExamplesTest do
  @moduledoc """
  Drives the "Live examples" section at the bottom of `/showcase/file_field`.

  Regression cover for issue #496: `live_file_input/1` hardcodes `id={@upload.ref}` and only then
  spreads `@rest`, so a caller-supplied `id` lands as a *second* `id` attribute that the HTML
  parser drops. The component used to point its `<label for>` at that discarded id — and a
  `for` that resolves to nothing leaves the label with no labeled control at all (it does NOT
  fall back to the input it wraps), so clicking the dropzone never opened the file picker.

  Every example below deliberately passes an explicit `id`, which is the shape that used to
  break. Queries use LazyHTML (LiveView 1.1 dropped Floki).
  """
  use DevelopmentWeb.ConnCase
  import Phoenix.LiveViewTest
  alias DevelopmentWeb.Showcase.Examples.FileField

  @path "/showcase/file_field"

  defp query(html, selector), do: html |> LazyHTML.from_document() |> LazyHTML.query(selector)

  defp attr(html, selector, name),
    do: html |> query(selector) |> LazyHTML.attribute(name) |> List.first()

  defp open(view, section) do
    view
    |> element(~s(button[phx-click="toggle_example"][phx-value-id="#{section}"]))
    |> render_click()
  end

  defp section_ids, do: Enum.map(FileField.sections(), & &1.id)

  test "the examples accordion lists every documented section", %{conn: conn} do
    {:ok, _view, html} = live(conn, @path)

    for %{id: id, title: title} <- FileField.sections() do
      assert html =~ title

      assert html |> query(~s(button[phx-value-id="#{id}"])) |> Enum.any?(),
             "missing examples section: #{id}"
    end
  end

  @dropzones %{
    "dropzone" => "ex-file_field-dropzone-form",
    "dropzone_image" => "ex-file_field-dropzone-image-form"
  }

  for {section, form_id} <- @dropzones do
    test "the #{section} label points at a file input that actually exists", %{conn: conn} do
      {:ok, view, _html} = live(conn, @path)
      html = open(view, unquote(section))
      label = ~s(form##{unquote(form_id)} label.dropzone-wrapper)

      ref = attr(html, ~s(#{label} input[type="file"]), "id")
      for_attr = attr(html, label, "for")

      # LiveView names the input after the upload ref; anything else means the id was discarded.
      assert ref =~ ~r/^phx-/
      assert for_attr == ref

      assert html |> query(~s(input[type="file"][id="#{for_attr}"])) |> Enum.any?(),
             "label[for=#{inspect(for_attr)}] resolves to nothing — the dropzone is unclickable"

      # The drop target and the click target must be the same upload.
      assert attr(html, label, "phx-drop-target") == for_attr
    end
  end

  test "the live input with a label is associated with the real input id", %{conn: conn} do
    {:ok, view, _html} = live(conn, @path)
    html = open(view, "live_label")

    ref = attr(html, ~s(form#ex-file_field-live-form input[type="file"]), "id")

    assert ref =~ ~r/^phx-/
    assert attr(html, "form#ex-file_field-live-form label", "for") == ref
  end

  test "the plain (non-live) field still labels its own id", %{conn: conn} do
    {:ok, view, _html} = live(conn, @path)
    html = open(view, "base")

    id = attr(html, ~s(input[type="file"][id^="ex-file_field-color-"]), "id")

    assert id
    assert attr(html, ~s(label[for="#{id}"]), "for") == id
  end

  test "with every section open, no label points at a missing element", %{conn: conn} do
    html = fully_open_page(conn)

    fors = html |> query("label[for]") |> LazyHTML.attribute("for") |> Enum.uniq()

    assert length(fors) >= length(section_ids())

    for f <- fors do
      assert html |> query(~s([id="#{f}"])) |> Enum.any?(),
             "label[for=#{inspect(f)}] resolves to nothing — clicking it does nothing"
    end
  end

  test "two forms with their own uploads keep every id distinct", %{conn: conn} do
    {:ok, view, _html} = live(conn, @path)
    html = open(view, "two_forms")

    forms = ["ex-file_field-form-a", "ex-file_field-form-b"]

    refs =
      forms
      |> Enum.flat_map(
        &(html
          |> query(~s(form##{&1} input[type="file"]))
          |> LazyHTML.attribute("id"))
      )

    # one dropzone + one plain field per form, all four distinct
    assert length(refs) == 4
    assert Enum.uniq(refs) == refs

    # Each dropzone must label the input inside its OWN form, not the other one's.
    for form_id <- forms do
      scope = ~s(form##{form_id})

      assert attr(html, "#{scope} label.dropzone-wrapper", "for") ==
               attr(html, ~s(#{scope} label.dropzone-wrapper input[type="file"]), "id")
    end
  end

  test "the whole page renders no duplicate id", %{conn: conn} do
    ids = conn |> fully_open_page() |> query("[id]") |> LazyHTML.attribute("id")

    assert ids != []
    assert ids -- Enum.uniq(ids) == [], "duplicate id(s): #{inspect(ids -- Enum.uniq(ids))}"
  end

  test "every bound form on the page carries an id", %{conn: conn} do
    forms = conn |> fully_open_page() |> query("form[phx-change], form[phx-submit]")
    ids = LazyHTML.attribute(forms, "id")

    assert Enum.any?(forms)

    # LazyHTML omits the attribute entirely when absent, so a short list *is* the failure.
    assert length(ids) == Enum.count(forms),
           "a form with phx-change/phx-submit is missing an id"

    assert Enum.all?(ids, &(&1 not in [nil, ""]))
  end

  defp fully_open_page(conn) do
    {:ok, view, _html} = live(conn, @path)
    Enum.reduce(section_ids(), nil, fn section, _acc -> open(view, section) end)
  end
end
