defmodule DevelopmentWeb.Components.Headless.ToggleGroup do
  @moduledoc """
  Headless **toggle group** — a toolbar of toggle buttons (single or multiple pressed).

  Two cooperating engines: `RovingTabindex` on the root `role="group"` (Left/Right arrows,
  Home/End, one `tabindex=0`) and `Toggle` on each item button (Click/Enter/Space flips
  `aria-pressed` and `data-on`/`data-off`). ARIA: root `role="group"`; items `role="button"`
  + `aria-pressed`. Style via `chelekom-toggle-group*` classes and `data-on`/`data-off`.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :class, :any, default: nil
  attr :rest, :global

  slot :item, required: true, doc: "A toggle button" do
    attr :value, :string, doc: "The value this toggle represents"
    attr :disabled, :boolean
  end

  def toggle_group(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="RovingTabindex"
      role="group"
      data-orientation="horizontal"
      class={["chelekom-toggle-group", @class]}
      {@rest}
    >
      <button
        :for={{item, i} <- Enum.with_index(@item)}
        type="button"
        id={"#{@id}-item-#{i}"}
        role="button"
        data-part="item"
        data-value={item[:value]}
        data-disabled={item[:disabled] || nil}
        phx-hook="Toggle"
        aria-pressed="false"
        data-off
        tabindex="-1"
        class="chelekom-toggle-group__item"
      >
        {render_slot(item)}
      </button>
    </div>
    """
  end
end
