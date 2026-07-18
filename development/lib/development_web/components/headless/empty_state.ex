defmodule DevelopmentWeb.Components.Headless.EmptyState do
  @moduledoc """
  Headless **empty state** — a presentational placeholder for empty views: no results,
  an empty inbox, a fresh list, a failed search (Mantine EmptyState parity).

  Anatomy: an optional `indicator` (icon/illustration), a `body` wrapping a `title` and
  `description`, any extra `inner_block` content, and an optional `actions` row. The
  `title` and `description` are plain-string shorthands; for richer content place markup
  in the default slot. Content alignment is exposed as `data-align` (`left`/`center`/`right`)
  on the root so you can flip layout entirely from CSS.

  Ships **no** colors, spacing or sizing — style via the `chelekom-empty-state*` classes
  and the `data-align` hook.

  WAI-ARIA APG: no formal pattern — an empty state is presentational, so the root is a plain
  `<div>` with no imposed role. When the empty state *appears dynamically* in response to a
  user action (e.g. a search returning nothing), give the root `role="status"` (or wrap it in an
  `aria-live="polite"` region) via `rest` so assistive tech announces it. The indicator is
  decorative; keep meaningful information in the title/description text.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/empty_state
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id for the root element"

  attr :align, :string,
    default: "center",
    values: ["left", "center", "right"],
    doc: "Content alignment; exposed as data-align"

  attr :title, :string,
    default: nil,
    doc: "Heading text (shorthand); omit to use the body slot instead"

  attr :description, :string, default: nil, doc: "Supporting text (shorthand)"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :indicator_class, :any, default: nil, doc: "Extra classes for the indicator part"
  attr :body_class, :any, default: nil, doc: "Extra classes for the body part"
  attr :title_class, :any, default: nil, doc: "Extra classes for the title part"
  attr :description_class, :any, default: nil, doc: "Extra classes for the description part"
  attr :actions_class, :any, default: nil, doc: "Extra classes for the actions part"
  attr :rest, :global

  slot :indicator, doc: "Icon or illustration shown above/beside the text (decorative)"
  slot :actions, doc: "Optional call-to-action buttons rendered after the body"
  slot :inner_block, doc: "Extra body content, rendered after the description"

  def empty_state(assigns) do
    ~H"""
    <div id={@id} data-align={@align} class={["chelekom-empty-state", @class]} {@rest}>
      <div
        :if={@indicator != []}
        data-part="indicator"
        aria-hidden="true"
        class={["chelekom-empty-state__indicator", @indicator_class]}
      >
        {render_slot(@indicator)}
      </div>
      <div
        :if={@title || @description || @inner_block != [] || @actions != []}
        data-part="body"
        class={["chelekom-empty-state__body", @body_class]}
      >
        <div
          :if={@title}
          data-part="title"
          class={["chelekom-empty-state__title", @title_class]}
        >
          {@title}
        </div>
        <div
          :if={@description}
          data-part="description"
          class={["chelekom-empty-state__description", @description_class]}
        >
          {@description}
        </div>
        {render_slot(@inner_block)}
        <div
          :if={@actions != []}
          data-part="actions"
          class={["chelekom-empty-state__actions", @actions_class]}
        >
          {render_slot(@actions)}
        </div>
      </div>
    </div>
    """
  end
end
