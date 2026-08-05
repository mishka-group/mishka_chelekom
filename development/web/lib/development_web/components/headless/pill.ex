defmodule DevelopmentWeb.Components.Headless.Pill do
  @moduledoc """
  Headless **pill** — a compact tag/token, optionally with a remove button
  (Mantine Pill parity).

  Renders a `<span>` holding the `label` content and, when `with_remove` is set, a
  trailing `remove` `<button>` carrying an accessible `aria-label` (default "Remove")
  and firing `on_remove` (a `phx-click` event or `JS` command). Use it to render
  selected values in tag/multiselect inputs or read-only token lists. `disabled`
  reflects to `data-disabled`.

  Ships **no** colors, spacing or shape — style via `chelekom-pill*` and the
  `data-disabled` hook.

  WAI-ARIA APG: no formal pattern (the pill is presentational); the remove control is
  a Button — keep its `remove_label` specific, e.g. "Remove React".

  **Documentation:** https://mishka.tools/chelekom/docs/headless/pill
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"
  attr :with_remove, :boolean, default: false, doc: "Render a trailing remove button"
  attr :on_remove, :any, default: nil, doc: "phx-click event or JS command for the remove button"
  attr :remove_label, :string, default: "Remove", doc: "aria-label for the remove button"
  attr :disabled, :boolean, default: false, doc: "Disable the pill (also sets data-disabled)"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :label_class, :any, default: nil, doc: "Extra classes for the label part"
  attr :remove_class, :any, default: nil, doc: "Extra classes for the remove button"
  attr :rest, :global

  slot :inner_block, required: true, doc: "The pill content"

  def pill(assigns) do
    ~H"""
    <span data-part="root" data-disabled={@disabled} class={["chelekom-pill", @class]} {@rest}>
      <span data-part="label" class={["chelekom-pill__label", @label_class]}>
        {render_slot(@inner_block)}
      </span>
      <button
        :if={@with_remove}
        type="button"
        data-part="remove"
        aria-label={@remove_label}
        disabled={@disabled}
        phx-click={@on_remove}
        class={["chelekom-pill__remove", @remove_class]}
      >
        <span aria-hidden="true">×</span>
      </button>
    </span>
    """
  end
end
