defmodule DevelopmentWeb.Components.Headless.CloseButton do
  @moduledoc """
  Headless **close button** — an icon-only button for dismissing dialogs, drawers,
  alerts, chips and toasts (Mantine CloseButton parity).

  Renders a `<button>` that always carries an accessible `aria-label` (default
  "Close") since it has no visible text. Provide your own icon in the default slot,
  or it falls back to a built-in ✕ glyph. `disabled` reflects to `data-disabled`.

  Ships **no** colors, sizing or spacing — style via `chelekom-close-button` and the
  `data-disabled` hook. Wire the click yourself (`phx-click`, `JS.exec`, …) through
  the global attributes.

  WAI-ARIA APG: Button pattern. Keep the `label` meaningful (e.g. "Close dialog").

  **Documentation:** https://mishka.tools/chelekom/docs/headless/close_button
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"

  attr :label, :string,
    default: "Close",
    doc: "Accessible label (aria-label) for the icon-only button"

  attr :disabled, :boolean, default: false, doc: "Disable the button (also sets data-disabled)"
  attr :class, :any, default: nil, doc: "Extra classes for the button"
  attr :rest, :global, doc: "Any button/global attrs, e.g. phx-click"

  slot :inner_block, doc: "Custom icon; falls back to a built-in ✕ when empty"

  def close_button(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      aria-label={@label}
      disabled={@disabled}
      data-disabled={@disabled}
      class={["chelekom-close-button", @class]}
      {@rest}
    >
      <span :if={@inner_block == []} data-part="icon" aria-hidden="true">✕</span>
      {render_slot(@inner_block)}
    </button>
    """
  end
end
