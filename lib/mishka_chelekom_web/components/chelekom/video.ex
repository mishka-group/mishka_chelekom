defmodule MishkaChelekom.Video do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :src, :string, default: nil, doc: ""
  attr :type, :string, default: "video/mp4", doc: ""
  attr :controls, :boolean, default: true, doc: ""
  attr :width, :string, default: "full", doc: ""
  attr :height, :string, default: "auto", doc: ""
  attr :ratio, :string, default: "auto", doc: ""
  attr :pip, :boolean, default: true, doc: "Enable Picture-in-Picture mode"
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def video(assigns) do
    ~H"""
    <video
      id={@id}
      class={[
        width_class(@width),
        height_class(@height),
        aspect_ratio(@ratio),
        @class
      ]}
      controls
      {@rest}
    >
      <source src={@src} type={@type}>
      Your browser does not support the video tag.
    </video>
    """
  end

  defp width_class("extra_small"), do: "w-3/12"
  defp width_class("small"), do: "w-5/12"
  defp width_class("medium"), do: "w-6/12"
  defp width_class("large"), do: "w-9/12"
  defp width_class("extra_large"), do: "w-11/12"
  defp width_class("full"), do: "w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")

  defp height_class("extra_small"), do: "h-60"
  defp height_class("small"), do: "h-64"
  defp height_class("medium"), do: "h-72"
  defp height_class("large"), do: "h-80"
  defp height_class("extra_large"), do: "h-96"
  defp height_class("auto"), do: "h-auto"
  defp height_class(params) when is_binary(params), do: params
  defp height_class(_), do: height_class("auto")

  defp aspect_ratio("auto"), do: "aspect-auto"
  defp aspect_ratio("square"), do: "aspect-square"
  defp aspect_ratio("video"), do: "aspect-video"
  defp aspect_ratio("4:3"), do: "aspect-[4/3]"
  defp aspect_ratio("3:2"), do: "aspect-[3/2]"
  defp aspect_ratio("21:9"), do: "aspect-[21/9]"
  defp aspect_ratio("1:1"), do: "aspect-[1/1]"
  defp aspect_ratio("9:16"), do: "aspect-[9/16]"
  defp aspect_ratio(params) when is_binary(params), do: params
  defp aspect_ratio(_), do: aspect_ratio("auto")

end
