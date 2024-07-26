defmodule MishkaChelekom.Accordion do
  use Phoenix.Component
  @sizes ["extra_small", "small", "medium", "large", "extra_large"]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :space, :string, values: @sizes ++ ["none"], default: "small", doc: ""

  def native_accordion(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        default_classes() ++
          [
            space_class(@space),
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class("none"), do: "space-x-0"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("small")

  defp default_classes() do
    [
      ""
    ]
  end
end
