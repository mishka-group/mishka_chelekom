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

  **Documentation:** https://mishka.tools/chelekom/docs/headless/toast
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

  attr :dedup_key, :string,
    default: nil,
    doc: "Stable key: re-triggering refreshes the matching toast instead of stacking a duplicate"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :trigger_class, :any, default: nil, doc: "Extra classes for the trigger button part"

  attr :viewport_class, :any,
    default: nil,
    doc: "Extra classes for the viewport part (the live region)"

  attr :toast_class, :any, default: nil, doc: "Extra classes for every toast part (the `<li>`)"
  attr :content_class, :any, default: nil, doc: "Extra classes for every toast content part"
  attr :close_class, :any, default: nil, doc: "Extra classes for every close button part"
  attr :close_label, :string, default: "Dismiss", doc: "Accessible label for the close button"
  attr :rest, :global

  slot :trigger, doc: "A button that creates a toast from the template on click"

  slot :close,
    doc:
      "Custom content for the close button (defaults to a × glyph; e.g. a Base UI 'Dismiss' label)"

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
      <button
        :if={@trigger != []}
        type="button"
        data-part="trigger"
        class={["chelekom-toast__trigger", @trigger_class]}
      >
        {render_slot(@trigger)}
      </button>

      <ol
        data-part="viewport"
        tabindex="-1"
        aria-live="polite"
        aria-atomic="false"
        class={["chelekom-toast__viewport", @viewport_class]}
      >
        <li
          :for={t <- @toast}
          data-part="toast"
          data-duration={t[:duration] || 5000}
          data-open
          class={["chelekom-toast__toast", @toast_class]}
        >
          <div data-part="content" class={["chelekom-toast__content", @content_class]}>
            {render_slot(t)}
            <button
              type="button"
              data-part="close"
              aria-label={@close_label}
              class={["chelekom-toast__close", @close_class]}
            >
              {if @close != [], do: render_slot(@close), else: "×"}
            </button>
          </div>
        </li>
      </ol>

      <template :if={@template != []} data-part="template">
        <li
          data-part="toast"
          data-toast-key={@dedup_key}
          data-duration={@duration}
          data-open
          class={["chelekom-toast__toast", @toast_class]}
        >
          <div data-part="content" class={["chelekom-toast__content", @content_class]}>
            {render_slot(@template)}
            <button
              type="button"
              data-part="close"
              aria-label={@close_label}
              class={["chelekom-toast__close", @close_class]}
            >
              {if @close != [], do: render_slot(@close), else: "×"}
            </button>
          </div>
        </li>
      </template>
    </div>
    """
  end
end
