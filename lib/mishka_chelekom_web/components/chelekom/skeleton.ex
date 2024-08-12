defmodule MishkaChelekom.Skeleton do
  use Phoenix.Component

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, default: "silver", doc: ""
  attr :height, :string, default: "extra_small", doc: ""
  attr :width, :string, default: "full", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "small", doc: ""
  attr :visible, :boolean, default: true, doc: ""
  attr :rest, :global, include: ~w(animated), doc: ""

  def skeleton(assigns) do
    ~H"""
    <div
      :if={@visible}
      role="status"
      id={@id}
      class={[
        rounded_size(@rounded),
        width_class(@width),
        height_class(@height),
        color_class(@color),
        @rest[:animated] && "animate-pulse",
        @class
      ]}
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

  defp color_class("white"), do: "bg-white"
  defp color_class("silver"), do: "bg-[#e9ecef]"
  defp color_class("primary"), do: "bg-[#4363EC]"
  defp color_class("secondary"), do: "bg-[#6B6E7C]"
  defp color_class("success"), do: "bg-[#D2F6E0]"
  defp color_class("warning"), do: "bg-[#FBF0D0]"
  defp color_class("danger"), do: "bg-[#FCD4D4]"
  defp color_class("info"), do: "bg-[#D9E8FC]"
  defp color_class("misc"), do: "bg-[#FFD8FF]"
  defp color_class("dawn"), do: "bg-[#FCE7D2]"
  defp color_class("light"), do: "bg-[#E3E7F1]"
  defp color_class("dark"), do: "bg-[#1E1E1E]"
  defp color_class(params) when is_binary(params), do: params
end
