defmodule MishkaChelekom.Menu do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :menu_items, :list, default: [], doc: ""
  slot :inner_block, doc: ""
  attr :rest, :global, doc: ""

  def menu(assigns) do
    ~H"""
    <ul id={@id} class={@class} {@rest}>
      <li :for={menu_item <- @menu_items}>
        <MishkaChelekom.Button.button_link :if={Map.get(menu_item, :sub_items, []) == []} {menu_item} />

        <MishkaChelekom.Accordion.accordion
          :if={Map.get(menu_item, :sub_items, []) != []}
          padding="none"
          {Map.drop(menu_item, [:sub_items, :padding])}
        >
          <:item title={menu_item[:title]} icon_class={menu_item[:icon_class]} icon={menu_item[:icon]}>
            <.menu
              id={menu_item[:id]}
              class={menu_item[:padding]}
              menu_items={Map.get(menu_item, :sub_items, [])}
            />
          </:item>
        </MishkaChelekom.Accordion.accordion>
      </li>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end
end
