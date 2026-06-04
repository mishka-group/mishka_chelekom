defmodule DevelopmentWeb.Components.Headless.Drawer do
  @moduledoc """
  Headless **drawer** — a focus-trapped panel that slides in from an edge.

  Same behavior as `dialog` (the shared `FocusTrap` engine: trigger opens, focus trapped,
  Escape / backdrop / `<:close>` dismiss, focus restored), with a `side` (left/right/top/bottom)
  exposed as `data-side` for your CSS slide animation. Style the `chelekom-drawer*` classes and
  `data-open`/`data-closed`/`data-side` state.
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :side, :string, default: "right", values: ~w(left right top bottom)
  attr :labelledby, :string, default: nil
  attr :describedby, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  slot :trigger
  slot :title
  slot :description
  slot :inner_block, required: true
  slot :close

  def drawer(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="FocusTrap"
      data-side={@side}
      class={["chelekom-drawer", @class]}
      data-open={@open}
      data-closed={!@open}
      {@rest}
    >
      <button :if={@trigger != []} type="button" data-part="trigger" class="chelekom-drawer__trigger">
        {render_slot(@trigger)}
      </button>

      <div data-part="backdrop" class="chelekom-drawer__backdrop" aria-hidden="true"></div>

      <div
        data-part="popup"
        role="dialog"
        aria-modal="true"
        aria-labelledby={@labelledby || (@title != [] && "#{@id}-title") || nil}
        aria-describedby={@describedby || (@description != [] && "#{@id}-desc") || nil}
        class="chelekom-drawer__popup"
        data-side={@side}
        tabindex="-1"
        data-open={@open}
        data-closed={!@open}
      >
        <h2 :if={@title != []} id={"#{@id}-title"} data-part="title" class="chelekom-drawer__title">
          {render_slot(@title)}
        </h2>
        <p
          :if={@description != []}
          id={"#{@id}-desc"}
          data-part="description"
          class="chelekom-drawer__description"
        >
          {render_slot(@description)}
        </p>
        <div data-part="content" class="chelekom-drawer__content">{render_slot(@inner_block)}</div>
        <div :if={@close != []} data-part="footer" class="chelekom-drawer__footer">
          {render_slot(@close)}
        </div>
      </div>
    </div>
    """
  end
end
