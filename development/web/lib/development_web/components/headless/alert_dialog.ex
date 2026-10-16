defmodule DevelopmentWeb.Components.Headless.AlertDialog do
  @moduledoc """
  Headless **alert dialog** — an unstyled confirmation dialog with WAI-ARIA wiring + focus management.

  Behavior is delegated to the shared `FocusTrap` JS engine: the `<:trigger>` opens the
  dialog, focus is trapped inside the popup, and Escape / `<:actions>` buttons close it,
  restoring focus to the opener. Unlike a plain dialog, the root sets
  `data-close-on-outside="false"` — an alert dialog requires an explicit choice, so a
  backdrop click does **not** dismiss it. You can also drive `open` from the server.

  Anatomy (named slots / parts): `trigger`, `backdrop` (auto), `popup`, `title` (req),
  `description` (req), inner content, `actions` (put `data-close` on a button to close).
  Style via the `chelekom-alert-dialog*` classes and the `data-open` / `data-closed` state
  attributes — this component ships **no** colors or spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/alertdialog/

  **Documentation:** https://mishka.tools/chelekom/docs/headless/alert-dialog
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors aria relationships)"
  attr :open, :boolean, default: false, doc: "Initial/controlled open state"
  attr :disabled, :boolean, default: false, doc: "Disable the trigger (data-disabled)"
  attr :on_open_change, :string, default: nil, doc: "LiveView event pushed on open/close ({open})"

  attr :on_open_change_target, :string,
    default: nil,
    doc: "Optional pushEventTo target (LiveComponent selector)"

  attr :labelledby, :string, default: nil, doc: "Override aria-labelledby"
  attr :describedby, :string, default: nil, doc: "Override aria-describedby"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :trigger_class, :any, default: nil, doc: "Extra classes for the trigger button"
  attr :backdrop_class, :any, default: nil, doc: "Extra classes for the backdrop"
  attr :popup_class, :any, default: nil, doc: "Extra classes for the popup"
  attr :title_class, :any, default: nil, doc: "Extra classes for the title"
  attr :description_class, :any, default: nil, doc: "Extra classes for the description"
  attr :content_class, :any, default: nil, doc: "Extra classes for the inner content"
  attr :actions_class, :any, default: nil, doc: "Extra classes for the actions footer"
  attr :rest, :global

  slot :trigger, doc: "The element that opens the alert dialog"
  slot :title, required: true, doc: "Accessible title (wired to aria-labelledby)"
  slot :description, required: true, doc: "Accessible description (wired to aria-describedby)"
  slot :inner_block, doc: "Alert dialog body"

  slot :actions,
    doc: "Footer with the confirm/cancel buttons (use data-close on a button to close)"

  def alert_dialog(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="FocusTrap"
      data-close-on-outside="false"
      data-on-open-change={@on_open_change}
      data-on-open-change-target={@on_open_change_target}
      class={["chelekom-alert-dialog", @class]}
      data-open={@open}
      data-closed={!@open}
      {@rest}
    >
      <button
        :if={@trigger != []}
        type="button"
        data-part="trigger"
        disabled={@disabled}
        data-disabled={@disabled}
        data-popup-open={@open}
        class={["chelekom-alert-dialog__trigger", @trigger_class]}
      >
        {render_slot(@trigger)}
      </button>

      <div
        data-part="backdrop"
        class={["chelekom-alert-dialog__backdrop", @backdrop_class]}
        aria-hidden="true"
      >
      </div>

      <div
        data-part="popup"
        role="alertdialog"
        aria-modal="true"
        aria-labelledby={@labelledby || "#{@id}-title"}
        aria-describedby={@describedby || "#{@id}-desc"}
        class={["chelekom-alert-dialog__popup", @popup_class]}
        tabindex="-1"
        data-open={@open}
        data-closed={!@open}
      >
        <h2
          id={"#{@id}-title"}
          data-part="title"
          class={["chelekom-alert-dialog__title", @title_class]}
        >
          {render_slot(@title)}
        </h2>
        <p
          id={"#{@id}-desc"}
          data-part="description"
          class={["chelekom-alert-dialog__description", @description_class]}
        >
          {render_slot(@description)}
        </p>
        <div
          :if={@inner_block != []}
          data-part="content"
          class={["chelekom-alert-dialog__content", @content_class]}
        >
          {render_slot(@inner_block)}
        </div>
        <div
          :if={@actions != []}
          data-part="actions"
          class={["chelekom-alert-dialog__actions", @actions_class]}
        >
          {render_slot(@actions)}
        </div>
      </div>
    </div>
    """
  end
end
