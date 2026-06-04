defmodule DevelopmentWeb.Components.Headless.Toast do
  @moduledoc """
  Headless **toast** — an `aria-live` region that announces transient messages.

  Behavior via the shared `ToastRegion` JS engine: each `<:toast>` is an
  `[data-part="toast"]` that auto-dismisses after `data-duration` ms (default `5000`;
  `0` disables) and exposes a `[data-part="dismiss"]` button for manual close. The root
  is a polite, non-atomic live region so newly streamed toasts are announced without
  re-reading the whole region. Style via `chelekom-toast*` classes and the
  `data-open` / `data-closed` state attributes — this component ships **no** colors or spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/alert/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors the live region)"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :toast, doc: "A single toast message" do
    attr :duration, :integer, doc: "Auto-dismiss delay in ms (default 5000; 0 disables)"
  end

  def toast(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="ToastRegion"
      aria-live="polite"
      aria-atomic="false"
      class={["chelekom-toast", @class]}
      {@rest}
    >
      <div
        :for={t <- @toast}
        data-part="toast"
        role="status"
        data-duration={t[:duration] || 5000}
        data-open
        class="chelekom-toast__toast"
      >
        {render_slot(t)}
        <button
          type="button"
          data-part="dismiss"
          aria-label="Dismiss"
          class="chelekom-toast__dismiss"
        >
          ×
        </button>
      </div>
    </div>
    """
  end
end
