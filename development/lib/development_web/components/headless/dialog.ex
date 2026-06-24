defmodule DevelopmentWeb.Components.Headless.Dialog do
  @moduledoc """
  Headless **dialog** — unstyled markup + WAI-ARIA wiring + focus management, with full
  Base UI parity.

  Behavior is delegated to the shared `FocusTrap` JS engine: the `<:trigger>` opens the
  dialog, focus is trapped inside the popup (when modal), and Escape / an outside click /
  `<:close>` buttons close it, restoring focus to the opener. You can also drive `open` from
  the server and listen with `on_open_change`.

  `modal` controls the interaction model:
    * `true` (default) — focus trapped, background scroll locked, a backdrop dims the page.
    * `"trap-focus"` — focus trapped, but the page stays scrollable and outside pointers work.
    * `false` — no trap, no scroll lock, no backdrop; an outside click still dismisses.

  Anatomy (named slots / parts): `trigger`, `backdrop` (auto, modal only), `viewport`,
  `popup`, `title`, `description`, inner content, `close`. Style via the `chelekom-dialog*`
  classes and the `data-open`/`data-closed`/`data-modal`/`data-nested`/`data-starting-style`
  state — this component ships **no** colors or spacing.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors aria relationships)"
  attr :open, :boolean, default: false, doc: "Initial/controlled open state"
  attr :modal, :any, default: true, doc: "true | false | \"trap-focus\" — focus trap / scroll lock / backdrop"
  attr :dismissible, :boolean, default: true, doc: "Whether an outside click dismisses"
  attr :close_on_escape, :boolean, default: true, doc: "Whether Escape closes"
  attr :disabled, :boolean, default: false, doc: "Disable the trigger (data-disabled)"
  attr :on_open_change, :string, default: nil, doc: "LiveView event pushed on open/close ({open})"
  attr :on_open_change_target, :string, default: nil, doc: "Optional pushEventTo target for on_open_change"
  attr :initial_focus, :string, default: nil, doc: "Selector focused on open (default: first focusable)"
  attr :final_focus, :string, default: nil, doc: "Selector focused on close (default: the opener)"
  attr :labelledby, :string, default: nil, doc: "Override aria-labelledby"
  attr :describedby, :string, default: nil, doc: "Override aria-describedby"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :trigger, doc: "The element that opens the dialog"
  slot :title, doc: "Accessible title (wired to aria-labelledby)"
  slot :description, doc: "Accessible description (wired to aria-describedby)"
  slot :inner_block, required: true, doc: "Dialog body"
  slot :close, doc: "Footer / close actions (use data-close on a button to close)"

  def dialog(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="FocusTrap"
      data-modal={to_string(@modal)}
      data-close-on-escape={to_string(@close_on_escape)}
      data-close-on-outside={to_string(@dismissible)}
      data-on-open-change={@on_open_change}
      data-on-open-change-target={@on_open_change_target}
      data-initial-focus={@initial_focus}
      data-final-focus={@final_focus}
      class={["chelekom-dialog", @class]}
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
        class="chelekom-dialog__trigger"
      >
        {render_slot(@trigger)}
      </button>

      <div
        :if={@modal != false}
        data-part="backdrop"
        class="chelekom-dialog__backdrop"
        aria-hidden="true"
      >
      </div>

      <div data-part="viewport" class="chelekom-dialog__viewport">
        <div
          data-part="popup"
          role="dialog"
          aria-modal={if @modal == true, do: "true"}
          aria-labelledby={@labelledby || (@title != [] && "#{@id}-title") || nil}
          aria-describedby={@describedby || (@description != [] && "#{@id}-desc") || nil}
          class="chelekom-dialog__popup"
          data-modal={to_string(@modal)}
          tabindex="-1"
          data-open={@open}
          data-closed={!@open}
        >
          <h2 :if={@title != []} id={"#{@id}-title"} data-part="title" class="chelekom-dialog__title">
            {render_slot(@title)}
          </h2>
          <p
            :if={@description != []}
            id={"#{@id}-desc"}
            data-part="description"
            class="chelekom-dialog__description"
          >
            {render_slot(@description)}
          </p>
          <div data-part="content" class="chelekom-dialog__content">{render_slot(@inner_block)}</div>
          <div :if={@close != []} data-part="footer" class="chelekom-dialog__footer">
            {render_slot(@close)}
          </div>
        </div>
      </div>
    </div>
    """
  end
end
