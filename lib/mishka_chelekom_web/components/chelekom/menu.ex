defmodule MishkaChelekom.Menu do
  @moduledoc """
  The `MishkaChelekom.Menu` module is designed to render a hierarchical menu structure in
  Phoenix LiveView applications. It provides a versatile menu component capable of
  handling both simple and complex navigation systems with nested sub-menus.

  This module supports dynamic configuration of menu items through a list of maps,
  allowing for a wide range of customization options. Menu items can be rendered as
  standalone buttons or as expandable accordions containing nested sub-menus.
  The `MishkaChelekom.Menu` is ideal for creating multi-level navigation menus in
  applications with complex information architectures.

  The component integrates smoothly with other components from the `MishkaChelekom`
  library, such as `accordion` and `button_link`, to offer a consistent and cohesive
  UI experience. It also includes support for various padding and spacing options to
  control the layout and appearance of the menu.
  """
  use Phoenix.Component
  import MishkaChelekom.Accordion, only: [accordion: 1]
  import MishkaChelekom.Button, only: [button_link: 1]

  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :menu_items, :list, default: [], doc: "Determines menu items as a list of maps"
  attr :space, :string, default: "small", doc: "Space between items"
  attr :padding, :string, default: "small", doc: "Determines padding for items"

  slot :inner_block,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

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
