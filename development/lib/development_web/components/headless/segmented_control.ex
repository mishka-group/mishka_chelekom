defmodule DevelopmentWeb.Components.Headless.SegmentedControl do
  @moduledoc """
  Headless **segmented control** — a row of mutually-exclusive segments (Mantine SegmentedControl
  parity).

  Built on native radio inputs sharing a `name`, so selection, form submission and keyboard (Arrow
  keys) are all native — **no JS**. Visually hide the radios (style the `input` part, e.g.
  `sr-only`) and show the selected segment with the CSS `:has(:checked)` selector. `options` is a
  list of values (strings), `{label, value}` tuples, or `{label, value, disabled}` tuples for
  per-segment disabling.

  Ships **no** styling — style via `chelekom-segmented-control*`, `:has(:checked)` and `data-disabled`.

  WAI-ARIA APG: Radio group (the native radios carry the semantics).

  **Documentation:** https://mishka.tools/chelekom/docs/headless/segmented_control
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"
  attr :name, :string, default: nil, doc: "Form field name (shared across segments)"
  attr :value, :any, default: nil, doc: "Selected value"

  attr :options, :list,
    required: true,
    doc: "List of values (strings), {label, value} or {label, value, disabled} tuples"

  attr :label, :string, default: nil, doc: "Accessible group label (aria-label)"
  attr :disabled, :boolean, default: false, doc: "Disable the whole control"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :item_class, :any, default: nil, doc: "Extra classes for each segment"
  attr :input_class, :any, default: nil, doc: "Extra classes for the hidden radios (e.g. sr-only)"
  attr :rest, :global

  def segmented_control(assigns) do
    ~H"""
    <div
      id={@id}
      data-part="root"
      role="radiogroup"
      aria-label={@label}
      data-disabled={@disabled}
      class={["chelekom-segmented-control", @class]}
      {@rest}
    >
      <label
        :for={opt <- @options}
        data-part="item"
        data-disabled={@disabled || sc_disabled(opt)}
        class={["chelekom-segmented-control__item", @item_class]}
      >
        <input
          type="radio"
          name={@name}
          value={sc_value(opt)}
          checked={to_string(sc_value(opt)) == to_string(@value)}
          disabled={@disabled || sc_disabled(opt)}
          data-part="input"
          class={["chelekom-segmented-control__input", @input_class]}
        />
        <span data-part="label">{sc_label(opt)}</span>
      </label>
    </div>
    """
  end

  defp sc_value({_label, value, _disabled}), do: value
  defp sc_value({_label, value}), do: value
  defp sc_value(value), do: value
  defp sc_label({label, _value, _disabled}), do: label
  defp sc_label({label, _value}), do: label
  defp sc_label(value), do: value
  defp sc_disabled({_label, _value, disabled}), do: disabled
  defp sc_disabled(_), do: false
end
