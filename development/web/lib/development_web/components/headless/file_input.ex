defmodule DevelopmentWeb.Components.Headless.FileInput do
  @moduledoc """
  Headless **file input** — the native file picker, wired for plain forms *and* LiveView uploads.

  Unlike the other form controls this one is not wrapped: the styled element is the `<input>`
  itself, because `::file-selector-button` is the only way to reach the browser's own button and
  that pseudo-element only exists on the input. So the root *is* the input, and a skin's modifier
  classes go straight on it.

  Three ways in, in order of specificity. `upload={@uploads.avatar}` renders
  `Phoenix.Component.live_file_input/1` and LiveView owns the name, the `accept` list and the
  multiple flag — passing them yourself would only contradict it. `field={@form[:attachment]}` takes
  the id and name from the form. Otherwise pass `name` yourself.

  Errors follow the same rule as the other fields — they surface only once
  `Phoenix.Component.used_input?/1` says the user has touched the field — with one addition: an
  upload's own `entry.errors` are always live, since a rejected file is the user having already
  acted.

  Ships **no** colors, sizing or spacing — style via `chelekom-file-input` and the
  `data-invalid` / `data-disabled` hooks.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/file_input
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "Unique id; taken from the form field or upload when given"

  attr :upload, :any,
    default: nil,
    doc:
      "A `Phoenix.LiveView.UploadConfig` — renders a live file input and owns name/accept/multiple"

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "A form field struct — supplies id, name and errors"

  attr :name, :string, default: nil, doc: "Input name (ignored when `upload` or `field` is given)"
  attr :accept, :string, default: nil, doc: "Comma-separated file types (ignored when `upload`)"
  attr :multiple, :boolean, default: false, doc: "Accept several files (ignored when `upload`)"
  attr :errors, :list, default: [], doc: "Error messages; a non-empty list marks it invalid"
  attr :disabled, :boolean, default: false, doc: "Disable the picker (data-disabled)"
  attr :required, :boolean, default: false, doc: "Require a file for form submit"
  attr :describedby, :string, default: nil, doc: "Id(s) of the description/error elements"
  attr :class, :any, default: nil, doc: "Extra classes for the input"
  attr :rest, :global, include: ~w(capture form), doc: "Any input/global attrs"

  def file_input(%{upload: %Phoenix.LiveView.UploadConfig{}} = assigns) do
    assigns = assign(assigns, :invalid?, assigns.errors != [] || assigns.upload.errors != [])

    ~H"""
    <.live_file_input
      upload={@upload}
      aria-invalid={@invalid? && "true"}
      aria-describedby={@describedby}
      data-part="input"
      data-invalid={@invalid?}
      data-disabled={@disabled}
      class={["chelekom-file-input", @class]}
      {@rest}
    />
    """
  end

  def file_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    # Both have an `attr` default, so the key is already in assigns and `assign_new/3` would never
    # fire — see `text_input`.
    assigns
    |> assign(field: nil)
    |> assign(:id, assigns.id || field.id)
    # A multi-file input posts an array, and Plug only builds one when the name says so.
    |> assign(
      :name,
      assigns.name || if(assigns.multiple, do: field.name <> "[]", else: field.name)
    )
    |> assign(:errors, errors)
    |> file_input()
  end

  def file_input(assigns) do
    assigns = assign(assigns, :invalid?, assigns.errors != [])

    ~H"""
    <input
      id={@id}
      type="file"
      name={@name}
      accept={@accept}
      multiple={@multiple}
      disabled={@disabled}
      required={@required}
      aria-invalid={@invalid? && "true"}
      aria-describedby={@describedby}
      data-part="input"
      data-invalid={@invalid?}
      data-disabled={@disabled}
      class={["chelekom-file-input", @class]}
      {@rest}
    />
    """
  end
end
