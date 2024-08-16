defmodule MishkaChelekom.Spinner do
  use Phoenix.Component

  @sizes [
    "extra_small",
    "small",
    "medium",
    "large",
    "extra_large",
    "double_large",
    "triple_large",
    "quadruple_large"
  ]
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

  @spinner_types [
    "oval",
    "dots",
    "bars",
    "flliped",
    "pinging",
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, values: @sizes, default: "small", doc: ""
  attr :rest, :global, include: @spinner_types, doc: ""

  def spinner(%{rest: %{dots: true}} = assigns) do
    ~H"""
    <div
      id={@id}
      class={
          [
            "w-fit flex space-x-2 justify-center items-center",
            dot_size(@size),
            color_class(@color)
          ]
      }
      role="status"
      aria-label="loading"
    >
      <span class='sr-only'>Loading...</span>
      <div class='rounded-full animate-bounce'></div>
      <div class='rounded-full animate-bounce [animation-delay:-0.2s]'></div>
      <div class='rounded-full animate-bounce [animation-delay:-0.4s]'></div>
    </div>
    """
  end

  def spinner(%{rest: %{bars: true}} = assigns) do
    ~H"""
    <div
      id={@id}
      class={
          [
            "w-fit flex gap-2",
            bar_size(@size),
            color_class(@color)
          ]
      }
      role="status"
      aria-label="loading"
    >
      <span class="sr-only">Loading...</span>
      <div class='rounded-sm animate-bounce [animation-delay:-0.4s]'></div>
      <div class='rounded-sm animate-bounce [animation-delay:-0.2s]'></div>
      <div class='rounded-sm animate-bounce'></div>
    </div>
    """
  end

  def spinner(%{rest: %{pinging: true}} = assigns) do
    ~H"""
    <div
      id={@id}
      class={
          [
            pinging_size(@size),
            pinging_color(@color)
          ]
      }
      role="status"
      aria-label="loading"
    >
      <span class="sr-only">Loading...</span>
      <svg viewBox="0 0 45 45" xmlns="http://www.w3.org/2000/svg">
        <g fill="none" fill-rule="evenodd" transform="translate(1 1)" stroke-width="2">
          <circle cx="22" cy="22" r="6" stroke-opacity="0">
            <animate attributeName="r" begin="1.5s" dur="3s" values="6;22" calcMode="linear" repeatCount="indefinite">
            </animate>
            <animate attributeName="stroke-opacity" begin="1.5s" dur="3s" values="1;0" calcMode="linear" repeatCount="indefinite">
            </animate>
            <animate attributeName="stroke-width" begin="1.5s" dur="3s" values="2;0" calcMode="linear" repeatCount="indefinite">
            </animate>
          </circle>
          <circle cx="22" cy="22" r="6" stroke-opacity="0">
            <animate attributeName="r" begin="3s" dur="3s" values="6;22" calcMode="linear" repeatCount="indefinite">
            </animate>
            <animate attributeName="stroke-opacity" begin="3s" dur="3s" values="1;0" calcMode="linear" repeatCount="indefinite">
            </animate>
            <animate attributeName="stroke-width" begin="3s" dur="3s" values="2;0" calcMode="linear" repeatCount="indefinite">
            </animate>
          </circle>
          <circle cx="22" cy="22" r="8">
            <animate attributeName="r" begin="0s" dur="1.5s" values="6;1;2;3;4;5;6" calcMode="linear" repeatCount="indefinite">
            </animate>
          </circle>
        </g>
      </svg>
    </div>
    """
  end

  def spinner(assigns) do
    ~H"""
    <div
      id={@id}
      class={
          [
            "animate-spin border-t-transparent rounded-full border-current",
            default_size_class(@size),
            text_color(@color),
            @class
          ]
      }
      role="status"
      aria-label="loading"
    >
      <span class="sr-only">Loading...</span>
    </div>
    """
  end

  defp dot_size("extra_small"), do: "[&>div]:size-1"
  defp dot_size("small"), do: "[&>div]:size-1.5"
  defp dot_size("medium"), do: "[&>div]:size-2"
  defp dot_size("large"), do: "[&>div]:size-2.5"
  defp dot_size("extra_large"), do: "[&>div]:size-3"
  defp dot_size("double_large"), do: "[&>div]:size-3.5"
  defp dot_size("triple_large"), do: "[&>div]:size-4"
  defp dot_size("quadruple_large"), do: "[&>div]:size-5"

  defp bar_size("extra_small"), do: "[&>div]:w-1 [&>div]:h-5"
  defp bar_size("small"), do: "[&>div]:w-1 [&>div]:h-6"
  defp bar_size("medium"), do: "[&>div]:w-1.5 [&>div]:h-7"
  defp bar_size("large"), do: "[&>div]:w-1.5 [&>div]:h-8"
  defp bar_size("extra_large"), do: "[&>div]:w-2 [&>div]:h-9"
  defp bar_size("double_large"), do: "[&>div]:w-2 [&>div]:h-10"
  defp bar_size("triple_large"), do: "[&>div]:w-2.5 [&>div]:h-11"
  defp bar_size("quadruple_large"), do: "[&>div]:w-2.5 [&>div]:h-12"

  defp pinging_size("extra_small"), do: "[&>svgsize:w-6"
  defp pinging_size("small"), do: "[&>svg]:size-7"
  defp pinging_size("medium"), do: "[&>svg]:size-8"
  defp pinging_size("large"), do: "[&>svg]:size-9"
  defp pinging_size("extra_large"), do: "[&>svg]:size-10"
  defp pinging_size("double_large"), do: "[&>svg]:size-12"
  defp pinging_size("triple_large"), do: "[&>svg]:size-14"
  defp pinging_size("quadruple_large"), do: "[&>svg]:size-16"

  defp default_size_class("extra_small"), do: "size-3.5 border-2"
  defp default_size_class("small"), do: "size-4 border-[3px]"
  defp default_size_class("medium"), do: "size-5 border-4"
  defp default_size_class("large"), do: "size-6 border-[5px]"
  defp default_size_class("extra_large"), do: "size-7 border-[5px]"
  defp default_size_class("double_large"), do: "size-8 border-[5px]"
  defp default_size_class("triple_large"), do: "size-9 border-[6px]"
  defp default_size_class("quadruple_large"), do: "size-10 border-[6px]"

  defp text_color("white") do
    "text-white"
  end

  defp text_color("primary") do
    "text-[#2441de]"
  end

  defp text_color("secondary") do
    "text-[#877C7C]"
  end

  defp text_color("success") do
    "text-[#6EE7B7]"
  end

  defp text_color("warning") do
    "text-[#FF8B08]"
  end

  defp text_color("danger") do
    "text-[#E73B3B]"
  end

  defp text_color("info") do
    "text-[#004FC4]"
  end

  defp text_color("misc") do
    "text-[#52059C]"
  end

  defp text_color("dawn") do
    "text-[#4D4137]"
  end

  defp text_color("light") do
    "text-[#707483]"
  end

  defp text_color("dark") do
    "text-[#050404]"
  end

  defp color_class("white") do
    "[&>div]:bg-white"
  end

  defp color_class("primary") do
    "[&>div]:bg-[#2441de]"
  end

  defp color_class("secondary") do
    "[&>div]:bg-[#877C7C]"
  end

  defp color_class("success") do
    "[&>div]:bg-[#6EE7B7]"
  end

  defp color_class("warning") do
    "[&>div]:bg-[#FF8B08]"
  end

  defp color_class("danger") do
    "[&>div]:bg-[#E73B3B]"
  end

  defp color_class("info") do
    "[&>div]:bg-[#004FC4]"
  end

  defp color_class("misc") do
    "[&>div]:bg-[#52059C]"
  end

  defp color_class("dawn") do
    "[&>div]:bg-[#4D4137]"
  end

  defp color_class("light") do
    "[&>div]:bg-[#707483]"
  end

  defp color_class("dark") do
    "[&>div]:bg-[#050404]"
  end

  defp pinging_color("white") do
    "[&>svg]:stroke-white"
  end

  defp pinging_color("primary") do
    "[&>svg]:stroke-[#2441de]"
  end

  defp pinging_color("secondary") do
    "[&>svg]:stroke-[#877C7C]"
  end

  defp pinging_color("success") do
    "[&>svg]:stroke-[#6EE7B7]"
  end

  defp pinging_color("warning") do
    "[&>svg]:stroke-[#FF8B08]"
  end

  defp pinging_color("danger") do
    "[&>svg]:stroke-[#E73B3B]"
  end

  defp pinging_color("info") do
    "[&>svg]:stroke-[#004FC4]"
  end

  defp pinging_color("misc") do
    "[&>svg]:stroke-[#52059C]"
  end

  defp pinging_color("dawn") do
    "[&>svg]:stroke-[#4D4137]"
  end

  defp pinging_color("light") do
    "[&>svg]:stroke-[#707483]"
  end

  defp pinging_color("dark") do
    "[&>svg]:stroke-[#050404]"
  end

end
