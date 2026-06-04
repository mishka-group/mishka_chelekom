defmodule DevelopmentWeb.Components.Headless.Popover do
  @moduledoc """
  Headless **popover** — a trigger that toggles an anchored, dismissable popup.

  Behavior via the shared `Popup` engine (click to toggle; outside-click / Escape close;
  light anchored positioning by `data-side`/`data-align`). ARIA: trigger `aria-expanded` +
  `aria-controls`; popup `role="dialog"`. Style via `chelekom-popover*` classes and
  `data-open`/`data-closed`.
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :side, :string, default: "bottom", values: ~w(top right bottom left)
  attr :align, :string, default: "center", values: ~w(start center end)
  attr :class, :any, default: nil
  attr :rest, :global

  slot :trigger, required: true
  slot :inner_block, required: true, doc: "Popup content"

  def popover(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Popup"
      data-side={@side}
      data-align={@align}
      class={["chelekom-popover", @class]}
      {@rest}
    >
      <button type="button" data-part="trigger" class="chelekom-popover__trigger">
        {render_slot(@trigger)}
      </button>
      <div
        id={"#{@id}-popup"}
        data-part="popup"
        role="dialog"
        data-closed
        class="chelekom-popover__popup"
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
