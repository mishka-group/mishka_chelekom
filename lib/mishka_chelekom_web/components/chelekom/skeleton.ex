defmodule MishkaChelekom.Skeleton do
  use Phoenix.Component

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, default: "bg-gray-300", doc: ""
  attr :height, :string, default: "extra_small", doc: ""
  attr :width, :string, default: "full", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "small", doc: ""
  attr :rest, :global, doc: ""

  def skeleton(assigns) do
    ~H"""
    <div role="status" id={@id}
      class={[
        "animate-pulse",
        rounded_size(@rounded),
        width_class(@width),
        height_class(@height),
        @color,
        @class
      ]}
      {@rest}
    >

    </div>
    """
  end

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size("none"), do: "rounded-none"

  defp height_class("extra_small"), do: "h-1"
  defp height_class("small"), do: "h-2"
  defp height_class("medium"), do: "h-3"
  defp height_class("large"), do: "h-4"
  defp height_class("extra_large"), do: "h-5"
  defp height_class(params) when is_binary(params), do: params
  defp height_class(_), do: height_class("extra_small")

  defp width_class("extra_small"), do: "w-60"
  defp width_class("small"), do: "w-64"
  defp width_class("medium"), do: "w-72"
  defp width_class("large"), do: "w-80"
  defp width_class("extra_large"), do: "w-96"
  defp width_class("full"), do: "w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")
end
