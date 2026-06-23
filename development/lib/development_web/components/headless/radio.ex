defmodule DevelopmentWeb.Components.Headless.Radio do
  @moduledoc """
  Headless **radio** — a single radio control (label + native input + indicator), Base UI parity.

  Wraps a native `<input type="radio">` (native grouping, keyboard and form submission) and exposes
  Base UI's styling surface as **live data-attributes** via the `Radio` hook: the root and the
  `indicator` carry `data-checked` / `data-unchecked` (kept in sync as the selection moves between
  radios of the same `name`), plus `data-disabled` / `data-readonly` / `data-required` from the props.
  `readonly` is emulated (native radios ignore the attribute) by cancelling the click.

  Use several with a shared `name` (a native group) or compose inside `radio_group` / `field`. Style
  the `chelekom-radio*` classes and the `data-*` hooks — ships **no** styling.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/radio/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Id of the native input (the label derives {id}-root)"
  attr :name, :string, default: nil, doc: "Shared name forms the native radio group"
  attr :value, :string, default: nil, doc: "This radio's submitted value"
  attr :checked, :boolean, default: false, doc: "Whether this radio is selected"
  attr :disabled, :boolean, default: false, doc: "Ignore interaction (data-disabled)"
  attr :readonly, :boolean, default: false, doc: "Block selection but stay focusable (data-readonly)"
  attr :required, :boolean, default: false, doc: "Require a selection for form submit (data-required)"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :inner_block, required: true, doc: "The radio label"

  def radio(assigns) do
    ~H"""
    <label
      id={"#{@id}-root"}
      phx-hook="Radio"
      class={["chelekom-radio", @class]}
      data-checked={@checked}
      data-unchecked={!@checked}
      data-disabled={@disabled}
      data-readonly={@readonly}
      data-required={@required}
      {@rest}
    >
      <input
        type="radio"
        id={@id}
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
        required={@required}
        aria-readonly={@readonly && "true"}
        data-part="input"
        class="chelekom-radio__input"
      />
      <span
        data-part="indicator"
        class="chelekom-radio__indicator"
        aria-hidden="true"
        data-checked={@checked}
        data-unchecked={!@checked}
      >
      </span>
      <span data-part="label" class="chelekom-radio__label">{render_slot(@inner_block)}</span>
    </label>
    """
  end
end
