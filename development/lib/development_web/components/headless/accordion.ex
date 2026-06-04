defmodule DevelopmentWeb.Components.Headless.Accordion do
  @moduledoc """
  Headless **accordion** — a set of stacked disclosure items.

  Behavior via the shared `Disclosure` engine (`data-single` = only one panel open at a
  time). Each `<:item>` has a header button (`aria-expanded` + `aria-controls`) and a region
  panel. Style via `chelekom-accordion*` classes and `data-open`/`data-closed`.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/accordion/
  """
  use Phoenix.Component
  import Phoenix.LiveView.Utils, only: [random_id: 0]

  @doc type: :component
  attr :id, :string, required: true
  attr :single, :boolean, default: true, doc: "Only one item open at a time"
  attr :collapsible, :boolean, default: true, doc: "Allow the open item to be closed"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :item, required: true do
    attr :title, :string, required: true
    attr :open, :boolean
  end

  def accordion(assigns) do
    assigns =
      assign(
        assigns,
        :item,
        Enum.map(assigns.item, &Map.put_new(&1, :__id__, "#{assigns.id}-#{random_id()}"))
      )

    ~H"""
    <div
      id={@id}
      phx-hook="Disclosure"
      data-single={@single}
      data-collapsible={to_string(@collapsible)}
      class={["chelekom-accordion", @class]}
      {@rest}
    >
      <div :for={item <- @item} data-part="item" class="chelekom-accordion__item">
        <h3 class="chelekom-accordion__heading">
          <button
            type="button"
            id={"#{item.__id__}-trigger"}
            data-part="trigger"
            aria-controls={"#{item.__id__}-panel"}
            aria-expanded={to_string(item[:open] || false)}
            class="chelekom-accordion__trigger"
          >
            {item.title}
          </button>
        </h3>
        <div
          id={"#{item.__id__}-panel"}
          data-part="panel"
          role="region"
          aria-labelledby={"#{item.__id__}-trigger"}
          data-open={item[:open] || false}
          data-closed={!(item[:open] || false)}
          class="chelekom-accordion__panel"
        >
          {render_slot(item)}
        </div>
      </div>
    </div>
    """
  end
end
