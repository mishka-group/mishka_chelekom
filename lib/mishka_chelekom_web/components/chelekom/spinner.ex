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
    "default",
    "dots",
    "bars",
    "pinging"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :type, :string, values: @spinner_types, default: "default", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, values: @sizes, default: "small", doc: ""
  attr :rest, :global

  def spinner(assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        default_class(@type),
        size_class(@type, @size),
        color_class(@color),
        @class
      ]}
      role="status"
      aria-label="loading"
      {@rest}
    >
      <.spinner_content type={@type} />
    </span>
    """
  end

  attr :type, :string, values: @spinner_types

  defp spinner_content(%{type: "pinging"} = assigns) do
    ~H"""
    <span class="sr-only">Loading...</span>
    <svg viewBox="0 0 45 45" xmlns="http://www.w3.org/2000/svg">
      <g fill="none" fill-rule="evenodd" transform="translate(1 1)" stroke-width="2">
        <circle cx="22" cy="22" r="6" stroke-opacity="0">
          <animate
            attributeName="r"
            begin="1.5s"
            dur="3s"
            values="6;22"
            calcMode="linear"
            repeatCount="indefinite"
          >
          </animate>
          <animate
            attributeName="stroke-opacity"
            begin="1.5s"
            dur="3s"
            values="1;0"
            calcMode="linear"
            repeatCount="indefinite"
          >
          </animate>
          <animate
            attributeName="stroke-width"
            begin="1.5s"
            dur="3s"
            values="2;0"
            calcMode="linear"
            repeatCount="indefinite"
          >
          </animate>
        </circle>
        <circle cx="22" cy="22" r="6" stroke-opacity="0">
          <animate
            attributeName="r"
            begin="3s"
            dur="3s"
            values="6;22"
            calcMode="linear"
            repeatCount="indefinite"
          >
          </animate>
          <animate
            attributeName="stroke-opacity"
            begin="3s"
            dur="3s"
            values="1;0"
            calcMode="linear"
            repeatCount="indefinite"
          >
          </animate>
          <animate
            attributeName="stroke-width"
            begin="3s"
            dur="3s"
            values="2;0"
            calcMode="linear"
            repeatCount="indefinite"
          >
          </animate>
        </circle>
        <circle cx="22" cy="22" r="8">
          <animate
            attributeName="r"
            begin="0s"
            dur="1.5s"
            values="6;1;2;3;4;5;6"
            calcMode="linear"
            repeatCount="indefinite"
          >
          </animate>
        </circle>
      </g>
    </svg>
    """
  end

  defp spinner_content(%{type: "dots"} = assigns) do
    ~H"""
    <span class="sr-only">Loading...</span>
    <span class="block rounded-full animate-bounce"></span>
    <span class="block rounded-full animate-bounce [animation-delay:-0.2s]"></span>
    <span class="block rounded-full animate-bounce [animation-delay:-0.4s]"></span>
    """
  end

  defp spinner_content(%{type: "bars"} = assigns) do
    ~H"""
    <span class="sr-only">Loading...</span>
    <span class="block rounded-sm animate-bounce [animation-delay:-0.4s]"></span>
    <span class="block rounded-sm animate-bounce [animation-delay:-0.2s]"></span>
    <span class="block rounded-sm animate-bounce"></span>
    """
  end

  defp spinner_content(assigns) do
    ~H"""
    <span class="sr-only">Loading...</span>
    """
  end

  defp default_class("dots") do
    "w-fit flex space-x-2 justify-center items-center"
  end

  defp default_class("bars") do
    "w-fit flex gap-2"
  end

  defp default_class("pinging"), do: "block"

  defp default_class(_) do
    "animate-spin border-t-transparent rounded-full border-current block"
  end

  defp size_class("dots", "extra_small"), do: "[&>span]:size-1"
  defp size_class("dots", "small"), do: "[&>span]:size-1.5"
  defp size_class("dots", "medium"), do: "[&>span]:size-2"
  defp size_class("dots", "large"), do: "[&>span]:size-2.5"
  defp size_class("dots", "extra_large"), do: "[&>span]:size-3"
  defp size_class("dots", "double_large"), do: "[&>span]:size-3.5"
  defp size_class("dots", "triple_large"), do: "[&>span]:size-4"
  defp size_class("dots", "quadruple_large"), do: "[&>span]:size-5"

  defp size_class("bars", "extra_small"), do: "[&>span]:w-1 [&>span]:h-5"
  defp size_class("bars", "small"), do: "[&>span]:w-1 [&>span]:h-6"
  defp size_class("bars", "medium"), do: "[&>span]:w-1.5 [&>span]:h-7"
  defp size_class("bars", "large"), do: "[&>span]:w-1.5 [&>span]:h-8"
  defp size_class("bars", "extra_large"), do: "[&>span]:w-2 [&>span]:h-9"
  defp size_class("bars", "double_large"), do: "[&>span]:w-2 [&>span]:h-10"
  defp size_class("bars", "triple_large"), do: "[&>span]:w-2.5 [&>span]:h-11"
  defp size_class("bars", "quadruple_large"), do: "[&>span]:w-2.5 [&>span]:h-12"

  defp size_class("pinging", "extra_small"), do: "[&>svgsize:w-6"
  defp size_class("pinging", "small"), do: "[&>svg]:size-7"
  defp size_class("pinging", "medium"), do: "[&>svg]:size-8"
  defp size_class("pinging", "large"), do: "[&>svg]:size-9"
  defp size_class("pinging", "extra_large"), do: "[&>svg]:size-10"
  defp size_class("pinging", "double_large"), do: "[&>svg]:size-12"
  defp size_class("pinging", "triple_large"), do: "[&>svg]:size-14"
  defp size_class("pinging", "quadruple_large"), do: "[&>svg]:size-16"

  defp size_class("default", "extra_small"), do: "size-3.5 border-2"
  defp size_class("default", "small"), do: "size-4 border-[3px]"
  defp size_class("default", "medium"), do: "size-5 border-4"
  defp size_class("default", "large"), do: "size-6 border-[5px]"
  defp size_class("default", "extra_large"), do: "size-7 border-[5px]"
  defp size_class("default", "double_large"), do: "size-8 border-[5px]"
  defp size_class("default", "triple_large"), do: "size-9 border-[6px]"
  defp size_class("default", "quadruple_large"), do: "size-10 border-[6px]"
  defp size_class(_, _), do: size_class("default", "small")

  defp color_class("white") do
    "[&>span]:bg-white [&>svg]:stroke-white text-white"
  end

  defp color_class("primary") do
    "[&>span]:bg-[#2441de] [&>svg]:stroke-[#2441de] text-[#2441de]"
  end

  defp color_class("secondary") do
    "[&>span]:bg-[#877C7C] [&>svg]:stroke-[#877C7C] text-[#877C7C]"
  end

  defp color_class("success") do
    "[&>span]:bg-[#6EE7B7] [&>svg]:stroke-[#6EE7B7] text-[#6EE7B7]"
  end

  defp color_class("warning") do
    "[&>span]:bg-[#FF8B08] [&>svg]:stroke-[#FF8B08] text-[#FF8B08]"
  end

  defp color_class("danger") do
    "[&>span]:bg-[#E73B3B] [&>svg]:stroke-[#E73B3B] text-[#E73B3B]"
  end

  defp color_class("info") do
    "[&>span]:bg-[#004FC4] [&>svg]:stroke-[#004FC4] text-[#004FC4]"
  end

  defp color_class("misc") do
    "[&>span]:bg-[#52059C] [&>svg]:stroke-[#52059C] text-[#52059C]"
  end

  defp color_class("dawn") do
    "[&>span]:bg-[#4D4137] [&>svg]:stroke-[#4D4137] text-[#4D4137]"
  end

  defp color_class("light") do
    "[&>span]:bg-[#707483] [&>svg]:stroke-[#707483] text-[#707483]"
  end

  defp color_class("dark") do
    "[&>span]:bg-[#050404] [&>svg]:stroke-[#050404] text-[#050404]"
  end
end
