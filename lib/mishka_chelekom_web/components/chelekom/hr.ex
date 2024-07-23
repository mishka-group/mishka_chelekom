defmodule MishkaChelekom.Hr do
  use Phoenix.Component
  import MishkaChelekomWeb.CoreComponents

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
  attr :size, :string, default: "extra_small", doc: ""
  attr :class, :string, default: nil, doc: ""

  def hr(assigns) do
    ~H"""
    <hr
      id={@id}
      class={
        default_classes() ++
          [
            size_class(@size),
            @class
          ]
      }
    />
    """
  end

  def hr_with_text(assigns) do
    ~H"""
    <div class="relative">
      <hr class="my-5 bg-gray-200 mx-auto" />
      <div class="bg-white absolute px-2 -top-1/2 -translate-y-1/2 left-1/2 -translate-x-1/2 whitespace-nowrap">
        Or
      </div>
    </div>
    """
  end

  def hr_with_icon(assigns) do
    ~H"""
    <div class="relative">
      <hr class="my-5 border-neutral-200 mx-auto" />
      <div class="bg-neutral-200 text-neutral-400 absolute px-2 -top-1/2 -translate-y-1/2 left-1/2 -translate-x-1/2 whitespace-nowrap">
        <.icon name="hero-link" class="w-5" />
      </div>
    </div>
    """
  end

  def hr_dashed(assigns) do
    ~H"""
      <hr class="my-5 border-dashed border-neutral-200 mx-auto w-1/2" />
    """
  end

  def hr_dotted(assigns) do
    ~H"""
      <hr class="my-5 border-t-[4px] border-dotted border-neutral-200 mx-auto" />
    """
  end

  defp size_class("extra_small"), do: "border-t"
  defp size_class("small"), do: "border-t-2"
  defp size_class("medium"), do: "border-t-[3px]"
  defp size_class("large"), do: "border-t-[4px]"
  defp size_class("half"), do: "w/12"
  defp size_class("full_width"), do: "w-full"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_small")

  defp default_classes() do
    [
      "my-5 border-gray-200 mx-auto"
    ]
  end
end
