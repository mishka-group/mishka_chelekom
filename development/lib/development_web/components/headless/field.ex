defmodule DevelopmentWeb.Components.Headless.Field do
  @moduledoc """
  Headless **field** — a form-field wrapper composing a label, control,
  description and error messages (Base UI parity).

  Wraps an arbitrary control together with an optional `<label>`, an optional
  description and a list of error messages, and does the **a11y wiring for you**:
  it derives stable ids, points `<label for>` at the control, and assembles a
  single `aria-describedby` from the description **and** every error. Because the
  control is caller-supplied, those values are handed back through the default
  slot as a `:let` map — spread them onto your input:

      <.field id="email" name="email" label="Email" errors={@errors} :let={f}>
        <input
          id={f.id}
          name={f.name}
          aria-describedby={f.describedby}
          aria-invalid={f.invalid && "true"}
          disabled={f.disabled}
        />
        <:description>We'll never share it.</:description>
      </.field>

  **State attributes** (for CSS, like Base UI): the root reflects
  `data-disabled` and `data-invalid` (server-derived from `disabled`/`errors`),
  and the `Field` JS hook tracks the control to toggle `data-focused`,
  `data-touched` (sticky after first blur), `data-dirty` (value changed) and
  `data-filled` (value non-empty). Style via the `chelekom-field*` classes and
  the `data-*` hooks — this component ships **no** colors, spacing or typography.

  **Validation is server-driven.** Pass changeset errors via `errors`; achieve
  Base UI's `validationMode` by putting `phx-change`/`phx-blur` on your control.
  The client validation engine (`validate`, `match`, debounce) is intentionally
  not ported — LiveView validates server-side.
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id; anchors the control/description/error ids"
  attr :for, :string, default: nil, doc: "Override the control id the label points at"
  attr :name, :string, default: nil, doc: "Control name, handed back via the slot's :let map"
  attr :label, :string, default: nil, doc: "Visible label text"
  attr :errors, :list, default: [], doc: "List of error messages to display"
  attr :disabled, :boolean, default: false, doc: "Mark the field disabled (data-disabled; suppresses invalid)"
  attr :invalid, :boolean, default: nil, doc: "Override validity; nil derives it from errors"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :inner_block, required: true, doc: "The form control. Receives :let %{id, name, describedby, invalid, disabled}"
  slot :description, doc: "Optional help text describing the control"

  def field(assigns) do
    invalid = if assigns.invalid == nil, do: assigns.errors != [], else: assigns.invalid
    invalid = invalid && not assigns.disabled

    control_id = assigns[:for] || "#{assigns.id}-control"
    desc_id = "#{assigns.id}-desc"

    describedby =
      [
        assigns.description != [] && desc_id
        | assigns.errors |> Enum.with_index() |> Enum.map(fn {_m, i} -> "#{assigns.id}-error-#{i}" end)
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assign(assigns,
        invalid: invalid,
        control_id: control_id,
        desc_id: desc_id,
        describedby: (describedby != "" && describedby) || nil
      )

    ~H"""
    <div
      id={@id}
      phx-hook="Field"
      data-disabled={@disabled}
      data-invalid={@invalid}
      class={["chelekom-field", @class]}
      {@rest}
    >
      <label :if={@label} for={@control_id} data-part="label" class="chelekom-field__label">
        {@label}
      </label>

      <div data-part="control" class="chelekom-field__control">
        {render_slot(@inner_block, %{
          id: @control_id,
          name: @name,
          describedby: @describedby,
          invalid: @invalid,
          disabled: @disabled
        })}
      </div>

      <p
        :if={@description != []}
        id={@desc_id}
        data-part="description"
        class="chelekom-field__description"
      >
        {render_slot(@description)}
      </p>

      <p
        :for={{msg, i} <- Enum.with_index(@errors)}
        id={"#{@id}-error-#{i}"}
        data-part="error"
        class="chelekom-field__error"
      >
        {msg}
      </p>
    </div>
    """
  end
end
