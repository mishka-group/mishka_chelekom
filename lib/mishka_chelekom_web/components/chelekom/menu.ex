defmodule MishkaChelekom.Menu do
  use Phoenix.Component
  import MishkaChelekom.Accordion, only: [accordion: 1]
  import MishkaChelekom.Button, only: [button_link: 1]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :menu_items, :list, default: [], doc: ""
  attr :space, :string, default: "small", doc: ""
  attr :padding, :string, default: "small", doc: ""
  slot :inner_block, doc: ""
  attr :rest, :global, doc: ""

  def menu(assigns) do
    ~H"""
    <ul
      id={@id}
      class={[
        padding_size(@padding),
        space_class(@space),
        @class
      ]}
      {@rest}
    >
      <li :for={menu_item <- @menu_items}>
        <.button_link
          :if={Map.get(menu_item, :sub_items, []) == []}
          font_weight={menu_item[:active] && "font-bold"}
          {menu_item}
        />
        <.accordion
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
        </.accordion>
      </li>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  defp padding_size("extra_small"), do: "p-2"
  defp padding_size("small"), do: "p-2.5"
  defp padding_size("medium"), do: "p-3"
  defp padding_size("large"), do: "p-3.5"
  defp padding_size("extra_large"), do: "p-4"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("extra_small")

  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: "space-y-0"
end
