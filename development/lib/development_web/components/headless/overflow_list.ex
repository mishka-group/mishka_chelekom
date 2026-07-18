defmodule DevelopmentWeb.Components.Headless.OverflowList do
  @moduledoc """
  Headless **overflow list** — lay items out on a single row and collapse the ones that don't fit
  into a `+N` counter.

  The `OverflowList` JS hook watches the container with a `ResizeObserver`: overflowing `item` parts
  get `data-hidden` and the `counter` is revealed with the hidden count written into
  `counter-value`. At least `min_visible` items are always kept. Provide `on_change` to receive the
  hidden count on the server whenever it changes.

  Ships **no** styling — style via `chelekom-overflow-list` and hide `[data-hidden]` parts yourself.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/overflow_list
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the OverflowList hook)"
  attr :min_visible, :integer, default: 1, doc: "Minimum items to always keep visible"

  attr :on_change, :string,
    default: nil,
    doc: "Event pushed with %{hidden: n} when the count changes"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :item_class, :any, default: nil, doc: "Extra classes for each item"
  attr :counter_class, :any, default: nil, doc: "Extra classes for the counter"
  attr :rest, :global

  slot :item, required: true, doc: "One entry per list item (order = priority)"

  def overflow_list(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="OverflowList"
      data-min-visible={@min_visible}
      data-on-change={@on_change}
      class={["chelekom-overflow-list", @class]}
      {@rest}
    >
      <span
        :for={item <- @item}
        data-part="item"
        class={["chelekom-overflow-list__item", @item_class]}
      >{render_slot(item)}</span>
      <span
        data-part="counter"
        data-hidden=""
        class={["chelekom-overflow-list__counter", @counter_class]}
      >
        +<span data-part="counter-value">0</span>
      </span>
    </div>
    """
  end
end
