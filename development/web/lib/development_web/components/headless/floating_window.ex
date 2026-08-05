defmodule DevelopmentWeb.Components.Headless.FloatingWindow do
  @moduledoc """
  Headless **floating window** — a draggable panel positioned inside its nearest positioned ancestor
  (Mantine FloatingWindow parity).

  Drag the `handle` to move the window — or focus it and use the arrow keys (10px, or 1px with
  Shift), the keyboard alternative WCAG 2.5.7 asks for. The `FloatingWindow` JS hook clamps the
  window inside the offset parent, mirrors the position into `data-x` / `data-y`, and (when
  `on_move` is set) pushes the new coordinates to the server on release / key move. Interactive
  controls inside the handle (like a close button) don't start a drag.

  The root must be **positioned** — put it inside a `position: relative` stage and give it
  `absolute`. Ships **no** styling otherwise — style via `chelekom-floating-window` and its parts.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/floating_window
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the FloatingWindow hook)"
  attr :x, :integer, default: 0, doc: "Initial left offset in px (within the stage)"
  attr :y, :integer, default: 0, doc: "Initial top offset in px (within the stage)"
  attr :on_move, :string, default: nil, doc: "Event pushed with %{x: _, y: _} on release"
  attr :label, :string, default: nil, doc: "Accessible label (role=dialog)"
  attr :handle_label, :string, default: "Move window", doc: "Accessible label for the drag handle"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :handle_class, :any, default: nil, doc: "Extra classes for the handle"
  attr :body_class, :any, default: nil, doc: "Extra classes for the body"
  attr :rest, :global

  slot :handle, doc: "Drag-handle content (e.g. a title bar)"
  slot :inner_block, required: true, doc: "Window body"

  def floating_window(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="FloatingWindow"
      role="dialog"
      aria-label={@label}
      data-part="window"
      data-x={@x}
      data-y={@y}
      data-on-move={@on_move}
      class={["chelekom-floating-window", @class]}
      {@rest}
    >
      <div
        data-part="handle"
        role="button"
        tabindex="0"
        aria-label={@handle_label}
        aria-roledescription="draggable window handle"
        class={["chelekom-floating-window__handle", @handle_class]}
      >
        {render_slot(@handle)}
      </div>
      <div data-part="body" class={["chelekom-floating-window__body", @body_class]}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
