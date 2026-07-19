defmodule DevelopmentWeb.Components.Headless.JsonInput do
  @moduledoc """
  Headless **json input** — a textarea for JSON with a server-validated error state (Mantine
  JsonInput parity).

  Renders a monospace-friendly `<textarea>`; parsing/formatting the JSON is the **server's** job in
  LiveView (`Jason.decode/1`) — no JS. Set `invalid` to reflect `data-invalid` for error styling, and
  bind `value` to a form field so a formatted value flows back on validate.

  Ships **no** styling — style via `chelekom-json-input` and the `data-invalid` hook.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/json_input
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"
  attr :name, :string, default: nil, doc: "Form field name"
  attr :value, :string, default: "", doc: "Current text"
  attr :placeholder, :string, default: nil, doc: "Placeholder"
  attr :rows, :integer, default: 6, doc: "Visible rows"
  attr :disabled, :boolean, default: false, doc: "Disable input"

  attr :invalid, :boolean,
    default: false,
    doc: "Reflects aria-invalid + data-invalid for error styling"

  attr :class, :any, default: nil, doc: "Extra classes"

  attr :rest, :global,
    include: ~w(autocomplete cols form maxlength minlength readonly required wrap),
    doc: "Any textarea/global attrs, e.g. phx-change, required"

  def json_input(assigns) do
    ~H"""
    <textarea
      id={@id}
      name={@name}
      rows={@rows}
      placeholder={@placeholder}
      disabled={@disabled}
      aria-invalid={@invalid && "true"}
      data-invalid={@invalid}
      spellcheck="false"
      class={["chelekom-json-input", @class]}
      {@rest}
    >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
    """
  end
end
