defmodule DevelopmentWeb.Components.Headless.Field do
  @moduledoc """
  Headless **field** — a form-field wrapper composing a label, control,
  description and error messages.

  Pure markup: no JS. Wraps an arbitrary control (`inner_block`) together with
  an optional `<label>` (wired via `for`), an optional description and a list of
  error messages. Style via the `chelekom-field*` classes — this component ships
  **no** colors, spacing or typography.

  No formal WAI-ARIA APG pattern; pair `for`/control `id` and `aria-describedby`
  on your control to associate the description and errors.
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Anchors the description/error ids"
  attr :for, :string, default: nil, doc: "Associates the label with the control id"
  attr :label, :string, default: nil, doc: "Visible label text"
  attr :errors, :list, default: [], doc: "List of error messages to display"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :inner_block, required: true, doc: "The form control"
  slot :description, doc: "Optional help text describing the control"

  def field(assigns) do
    ~H"""
    <div id={@id} class={["chelekom-field", @class]} {@rest}>
      <label :if={@label} for={@for} data-part="label" class="chelekom-field__label">
        {@label}
      </label>

      <div data-part="control" class="chelekom-field__control">
        {render_slot(@inner_block)}
      </div>

      <p
        :if={@description != []}
        id={@id && "#{@id}-desc"}
        data-part="description"
        class="chelekom-field__description"
      >
        {render_slot(@description)}
      </p>

      <p
        :for={msg <- @errors}
        data-part="error"
        class="chelekom-field__error"
      >
        {msg}
      </p>
    </div>
    """
  end
end
