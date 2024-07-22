defmodule MishkaChelekom.Hr do
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

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :type, :string, values: ["dashed", "solid"], default: "solid", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""

  def hr(assigns) do
    ~H"""
    <hr id={@id}
      class={
        default_classes() ++
          [
            size_class(@size),
            @class
          ]
      }
      {@rest} />
    """
  end

  defp size_class("extra_small"), do: "border-b"
  defp size_class("small"), do: "border-b-2"
  defp size_class("medium"), do: "border-b-4"
  defp size_class("large"), do: "border-b-8"
  defp size_class("half"), do: "w/12"
  defp size_class("full_width"), do: "w-full"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_small")

  defp default_classes() do
    [
      "my-5 bg-gray-200 mx-auto",
    ]
  end
end
