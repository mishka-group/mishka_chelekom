defmodule DevelopmentWeb.Components.Headless.Textarea do
  @moduledoc """
  Headless **textarea** — a multi-line control that can grow with its content
  (Mantine Textarea parity).

  Wires up the same two ways as `text_input`: hand it a `Phoenix.HTML.FormField` via
  `field={@form[:bio]}` and it takes its `id`, `name`, `value` and errors from the form — errors
  only once `Phoenix.Component.used_input?/1` says the user has touched it — or pass `name`/`value`
  yourself.

  `autosize` is the one behaviour worth a hook: with it the textarea reports its own scroll height
  on every input and grows between `min_rows` and `max_rows` instead of showing a scrollbar. Without
  it there is no JS at all — `rows` is the native attribute and the browser does the rest.

  Parts: `textarea`. The root is the control box so a skin paints the border there and leaves the
  `<textarea>` transparent, which keeps a resize handle from cutting across the border.

  Ships **no** colors, sizing or spacing — style via `chelekom-textarea*` and the
  `data-invalid` / `data-valid` / `data-disabled` hooks.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/textarea
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Unique id; taken from the form field when one is given"

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "A form field struct — supplies id, name, value and errors"

  attr :name, :string, default: nil, doc: "Textarea name (ignored when `field` is given)"
  attr :value, :any, default: nil, doc: "Textarea value (ignored when `field` is given)"
  attr :errors, :list, default: [], doc: "Error messages; a non-empty list marks it invalid"
  attr :valid, :boolean, default: false, doc: "Mark the control valid (data-valid)"
  attr :disabled, :boolean, default: false, doc: "Disable the control (data-disabled)"
  attr :readonly, :boolean, default: false, doc: "Block editing but keep it focusable"
  attr :required, :boolean, default: false, doc: "Require a value for form submit"
  attr :placeholder, :string, default: nil, doc: "Placeholder text"
  attr :rows, :integer, default: nil, doc: "Visible rows (native)"

  attr :autosize, :boolean,
    default: false,
    doc: "Grow with the content between `min_rows` and `max_rows` (adds the Autosize hook)"

  attr :min_rows, :integer, default: 2, doc: "Smallest height while autosizing"
  attr :max_rows, :integer, default: nil, doc: "Largest height while autosizing; nil is unbounded"

  attr :resize, :string,
    default: "vertical",
    values: ~w(none vertical horizontal both),
    doc: "Native resize handle direction; forced to `none` while autosizing"

  attr :describedby, :string, default: nil, doc: "Id(s) of the description/error elements"
  attr :class, :any, default: nil, doc: "Extra classes for the control root"
  attr :textarea_class, :any, default: nil, doc: ~s|Extra classes for `data-part="textarea"`|

  attr :rest, :global,
    include: ~w(autocomplete autofocus form maxlength minlength spellcheck wrap),
    doc: "Any textarea/global attrs, e.g. phx-change"

  def textarea(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    # Every one of these has an `attr` default, so the key is already in assigns and `assign_new/3`
    # would never fire — see `text_input`.
    assigns
    |> assign(field: nil)
    |> assign(:id, assigns.id || field.id)
    |> assign(:name, assigns.name || field.name)
    |> assign(:value, if(is_nil(assigns.value), do: field.value, else: assigns.value))
    |> assign(:errors, errors)
    |> textarea()
  end

  def textarea(assigns) do
    assigns =
      assigns
      |> assign(:invalid?, assigns.errors != [])
      # A resize handle and an autosizing box fight each other — the handle sets an inline height
      # the hook then overwrites on the next keystroke.
      |> assign(:resize, if(assigns.autosize, do: "none", else: assigns.resize))

    ~H"""
    <div
      data-part="root"
      data-invalid={@invalid?}
      data-valid={@valid && !@invalid?}
      data-disabled={@disabled}
      data-readonly={@readonly}
      data-required={@required}
      data-autosize={@autosize}
      class={["chelekom-textarea", @class]}
    >
      <textarea
        id={@id}
        name={@name}
        rows={@rows || @min_rows}
        placeholder={@placeholder}
        disabled={@disabled}
        readonly={@readonly}
        required={@required}
        aria-invalid={@invalid? && "true"}
        aria-describedby={@describedby}
        phx-hook={@autosize && "Autosize"}
        data-min-rows={@autosize && @min_rows}
        data-max-rows={@autosize && @max_rows}
        data-part="textarea"
        data-resize={@resize}
        class={["chelekom-textarea__textarea", @textarea_class]}
        {@rest}
      >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
    </div>
    """
  end
end
