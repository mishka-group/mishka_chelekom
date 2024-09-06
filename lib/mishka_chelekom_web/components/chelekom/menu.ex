defmodule MishkaChelekom.Menu do
  use Phoenix.Component
  import MishkaChelekomComponents

  @variants [
    "default",
    "filled",
    "outline",
    "seperated",
    "tinted_split",
    "transparent"
  ]

  @colors [
    "white",
    "primary",
    "secondary",
    "dark",
    "success",
    "warning",
    "danger",
    "info",
    "light",
    "misc",
    "dawn"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :title, :string, required: true, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :space, :string, default: nil, doc: ""
  attr :image, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :variant, :string, values: @variants, default: "filled", doc: ""
  attr :chevron_icon, :string, default: "hero-chevron-right", doc: ""
  slot :item, validate_attrs: false
  attr :rest, :global, doc: ""
  slot :inner_block, doc: ""

  def menu(assigns) do
    ~H"""
    <ul class="bg-red-300">
      <li>
      <a>Dashaboard</a>
      </li>
      <li>
      <a>Inbox</a>
      </li>
      <li>
          <MishkaChelekom.Accordion.accordion id="accordion1" color="transparent">
              <:item title="Menu item">
                  <ul>
                      <li>Products</li>
                      <li>Billing</li>
                      <li>Invoice</li>
                  </ul>
              </:item>
          </MishkaChelekom.Accordion.accordion>
      </li>
    </ul>

    """
  end
end
