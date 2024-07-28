defmodule MishkaChelekom.List do
  use Phoenix.Component

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

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def ul(assigns) do
    ~H"""
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def li(assigns) do
    ~H"""
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def ol(assigns) do
    ~H"""
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500"><%= item.title %></dt>
          
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  def list_group(assigns) do
    ~H"""
    """
  end
end
