defmodule DevelopmentWeb.Components.Headless.Collapsible do
  @moduledoc """
  Headless **collapsible** — a trigger button that shows/hides one region.

  Behavior is delegated to the shared `Disclosure` JS engine: the `<:trigger>` toggles a single
  panel via `aria-controls`. ARIA: trigger `aria-expanded` + `aria-controls`; panel `role="region"`
  + `aria-labelledby`. Options: `disabled` · `hidden_until_found` (find-in-page) · controlled `open`
  paired with `on_open_change`. The closed panel stays mounted (hidden) so the client engine can
  toggle it. Style via the `chelekom-collapsible*` classes and
  the data-attributes `data-open`/`data-closed`, `data-disabled`,
  `data-starting-style`/`data-ending-style` (transitions) and `--accordion-panel-height/width` —
  this component ships **no** colors or spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors aria relationships)"

  attr :open, :boolean,
    default: false,
    doc: "Open state (initial, or controlled when paired with on_open_change)"

  attr :disabled, :boolean, default: false, doc: "Disable the trigger"

  attr :hidden_until_found, :boolean,
    default: false,
    doc: ~s|Closed panel uses hidden="until-found" so the browser's find-in-page can reveal it|

  attr :value, :string,
    default: nil,
    doc: "Stable identity sent in change events (defaults to id)"

  attr :on_open_change, :string,
    default: nil,
    doc: "LiveView event pushed when the panel toggles ({value, open})"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :item_class, :any, default: nil, doc: "Extra classes for the item wrapper (data-part=item)"

  attr :trigger_class, :any,
    default: nil,
    doc: "Extra classes for the trigger button (data-part=trigger)"

  attr :panel_class, :any,
    default: nil,
    doc: "Extra classes for the panel region (data-part=panel)"

  attr :rest, :global

  slot :trigger, required: true, doc: "The toggle button label"
  slot :inner_block, required: true, doc: "The collapsible content"

  def collapsible(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Disclosure"
      data-disabled={@disabled}
      data-hidden-until-found={@hidden_until_found}
      class={["chelekom-collapsible", @class]}
      {@rest}
    >
      <div
        data-part="item"
        data-value={@value || @id}
        data-open={@open}
        data-disabled={@disabled}
        data-on-open-change={@on_open_change}
        class={["chelekom-collapsible__item", @item_class]}
      >
        <button
          type="button"
          id={"#{@id}-trigger"}
          data-part="trigger"
          data-disabled={@disabled}
          aria-controls={"#{@id}-panel"}
          aria-expanded={to_string(@open)}
          aria-disabled={@disabled && "true"}
          class={["chelekom-collapsible__trigger", @trigger_class]}
        >
          {render_slot(@trigger)}
        </button>
        <div
          id={"#{@id}-panel"}
          data-part="panel"
          role="region"
          aria-labelledby={"#{@id}-trigger"}
          data-open={@open}
          data-closed={!@open}
          hidden={!@open && panel_hidden(@hidden_until_found)}
          class={["chelekom-collapsible__panel", @panel_class]}
        >
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  # closed-panel `hidden`: "until-found" keeps text findable by the browser; otherwise a plain
  # boolean `hidden`. (Open panels render no `hidden` — the markup guards with `!@open`.)
  defp panel_hidden(true), do: "until-found"
  defp panel_hidden(_), do: true
end
