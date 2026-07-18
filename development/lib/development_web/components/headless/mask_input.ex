defmodule DevelopmentWeb.Components.Headless.MaskInput do
  @moduledoc """
  Headless **mask input** — a text field that formats itself to a pattern as you type (Mantine
  MaskInput parity).

  The `mask` pattern uses `9` for a digit, `a` for a letter, `*` for an alphanumeric, and treats
  every other character as a literal that is inserted automatically — e.g. `(999) 999-9999`,
  `99/99/9999`, `aaa-9999`. The `MaskInput` JS hook re-formats the value on every keystroke; the
  masked value is what submits with the form, so validation/parsing stay the **server's** job.

  Ships **no** styling — style via `chelekom-mask-input`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/mask_input
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the MaskInput hook)"
  attr :name, :string, default: nil, doc: "Form field name"
  attr :value, :string, default: "", doc: "Current value (already masked)"

  attr :mask, :string,
    required: true,
    doc: "Mask pattern: 9=digit, a=letter, *=alnum, others literal"

  attr :placeholder, :string, default: nil, doc: "Placeholder"
  attr :inputmode, :string, default: nil, doc: "Hint for on-screen keyboards, e.g. \"numeric\""
  attr :disabled, :boolean, default: false, doc: "Disable input"
  attr :class, :any, default: nil, doc: "Extra classes"
  attr :rest, :global

  def mask_input(assigns) do
    ~H"""
    <input
      id={@id}
      type="text"
      name={@name}
      value={@value}
      placeholder={@placeholder}
      inputmode={@inputmode}
      disabled={@disabled}
      autocomplete="off"
      phx-hook="MaskInput"
      data-mask={@mask}
      class={["chelekom-mask-input", @class]}
      {@rest}
    />
    """
  end
end
