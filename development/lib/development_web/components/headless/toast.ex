defmodule DevelopmentWeb.Components.Headless.Toast do
  @moduledoc """
  Headless **toast** — a stacking notification region (Base UI parity).

  The `[data-part="viewport"]` is a polite `aria-live` region that **stacks** toasts: newest in
  front, older ones peeking behind; hovering or focusing the viewport **expands** them into a full
  list and pauses auto-dismiss. Behaviour via the shared `ToastRegion` engine.

  Two ways to create toasts: render `<:toast>` slots up front (static / LiveView-streamed), or give
  a `<:trigger>` button + a `<:template>` — the engine clones a new toast on each click, filling any
  `data-toast-count` element with a running number. Each toast auto-dismisses after `duration` ms
  (default 5000; `0` = sticky) and carries a `[data-part="close"]` button.

  The engine writes the stacking vars — `--toast-index` (0=front), `--toast-offset-y`,
  `--toast-height` (on each toast) and `--toast-frontmost-height` (on the viewport) — and toggles
  `data-expanded` / `data-limited` / `data-behind` / `data-starting-style` / `data-ending-style`;
  your CSS does the transforms. Ships **no** colors or spacing — style via `chelekom-toast*`.

  WAI-ARIA: https://www.w3.org/TR/wai-aria-1.2/#aria-live
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors the live region)"

  attr :limit, :integer,
    default: 3,
    doc: "Max toasts shown before older ones are marked `data-limited`"

  attr :duration, :integer,
    default: 5000,
    doc: "Auto-dismiss (ms) for toasts created from the template (`0` disables)"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :trigger, doc: "A button that creates a toast from the template on click"

  slot :template,
    doc: "Content for a dynamically-created toast (use `data-toast-count` for a running number)"

  slot :toast, doc: "A static toast, rendered up front" do
    attr :duration, :integer, doc: "Auto-dismiss delay in ms (default 5000; 0 disables)"
  end

  def toast(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="ToastRegion"
      data-part="root"
      data-limit={@limit}
      class={["chelekom-toast", @class]}
      {@rest}
    >
      <button :if={@trigger != []} type="button" data-part="trigger" class="chelekom-toast__trigger">
        {render_slot(@trigger)}
      </button>

      <ol
        data-part="viewport"
        tabindex="-1"
        aria-live="polite"
        aria-atomic="false"
        class="chelekom-toast__viewport"
      >
        <li
          :for={t <- @toast}
          data-part="toast"
          data-duration={t[:duration] || 5000}
          data-open
          class="chelekom-toast__toast"
        >
          <div data-part="content" class="chelekom-toast__content">
            {render_slot(t)}
            <button
              type="button"
              data-part="close"
              aria-label="Dismiss"
              class="chelekom-toast__close"
            >
              ×
            </button>
          </div>
        </li>
      </ol>

      <template :if={@template != []} data-part="template">
        <li data-part="toast" data-duration={@duration} data-open class="chelekom-toast__toast">
          <div data-part="content" class="chelekom-toast__content">
            {render_slot(@template)}
            <button
              type="button"
              data-part="close"
              aria-label="Dismiss"
              class="chelekom-toast__close"
            >
              ×
            </button>
          </div>
        </li>
      </template>
    </div>
    """
  end
end
