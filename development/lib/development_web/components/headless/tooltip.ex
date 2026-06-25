defmodule DevelopmentWeb.Components.Headless.Tooltip do
  @moduledoc """
  Headless **tooltip** (Base UI parity) — a hover/focus popup that describes its trigger.

  Behavior is driven by the dedicated `Tooltip` JS engine: pointer-enter (after `delay`) or
  focus reveals a `role="tooltip"` popup anchored to the trigger by `side`/`align`/offset
  (edge-flip + viewport clamp, repositioned on scroll/resize); pointer-leave (after
  `close_delay`), blur, or Escape close it. It is **non-modal** and never steals focus.

  Options: `hoverable` (whether the pointer can move into the popup), `disabled`,
  `track_cursor_axis` (the popup follows the cursor on `x`/`y`/`both`), and a shared delay
  `group` — once one tooltip in a group is open, the others open instantly for a moment.

  ARIA: trigger `aria-describedby` points to the popup; popup `role="tooltip"`. Style the
  `chelekom-tooltip*` classes and the `data-open`/`data-closed`/`data-side`/`data-align`/
  `data-popup-open`/`data-starting-style` state — this component ships **no** colors/spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/tooltip/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors aria relationships)"
  attr :open, :boolean, default: false, doc: "Initial/controlled open state"
  attr :side, :string, default: "top", values: ~w(top right bottom left), doc: "Preferred side"
  attr :align, :string, default: "center", values: ~w(start center end), doc: "Alignment along the side"
  attr :side_offset, :integer, default: 6, doc: "Gap between trigger and popup (px)"
  attr :align_offset, :integer, default: 0, doc: "Offset along the alignment axis (px)"
  attr :delay, :integer, default: 600, doc: "Hover open delay (ms)"
  attr :close_delay, :integer, default: 0, doc: "Hover/blur close delay (ms)"
  attr :hoverable, :boolean, default: true, doc: "Whether the pointer can move into the popup"
  attr :disabled, :boolean, default: false, doc: "Disable the tooltip"
  attr :track_cursor_axis, :string, default: "none", values: ~w(none x y both), doc: "Follow the cursor along an axis"
  attr :group, :string, default: nil, doc: "Shared delay group: warm groups open instantly"
  attr :close_on_escape, :boolean, default: true, doc: "Whether Escape closes"
  attr :on_open_change, :string, default: nil, doc: "LiveView event pushed on open/close ({open})"
  attr :on_open_change_target, :string, default: nil, doc: "Optional pushEventTo target for on_open_change"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :trigger, required: true, doc: "The element described by the tooltip"
  slot :inner_block, required: true, doc: "Tooltip content"

  def tooltip(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Tooltip"
      data-side={@side}
      data-align={@align}
      data-side-offset={@side_offset}
      data-align-offset={@align_offset}
      data-delay={@delay}
      data-close-delay={@close_delay}
      data-hoverable={to_string(@hoverable)}
      data-disabled={to_string(@disabled)}
      data-track-cursor-axis={@track_cursor_axis}
      data-group={@group}
      data-close-on-escape={to_string(@close_on_escape)}
      data-on-open-change={@on_open_change}
      data-on-open-change-target={@on_open_change_target}
      class={["chelekom-tooltip", @class]}
      data-open={@open}
      data-closed={!@open}
      {@rest}
    >
      <span
        data-part="trigger"
        tabindex="0"
        aria-describedby={"#{@id}-popup"}
        class="chelekom-tooltip__trigger"
      >
        {render_slot(@trigger)}
      </span>
      <div
        id={"#{@id}-popup"}
        data-part="popup"
        role="tooltip"
        class="chelekom-tooltip__popup"
        data-closed
        hidden
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
