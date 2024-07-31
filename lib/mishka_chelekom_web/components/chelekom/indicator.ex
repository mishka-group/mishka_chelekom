defmodule MishkaChelekom.Indicator do
  use Phoenix.Component

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]

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

  @indicator_positions [
    "top_left",
    "top_center",
    "top_right",
    "middle_left",
    "middle_right",
    "bottom_left",
    "bottom_center",
    "bottom_right"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :size, :string, values: @sizes, default: "small", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "danger", doc: ""
  attr :rest, :global, include: ["pinging"] ++ @indicator_positions, doc: ""

  def indicator(%{rest: %{top_left: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "absolute -translate-y-1/2 -translate-x-1/2 right-auto top-0 left-0",
        !is_nil(@rest[:pinging]) && "[&>.indicator]:animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{top_center: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "absolute top-0 -translate-y-1/2 translate-x-1/2 right-1/2",
        !is_nil(@rest[:pinging]) && "[&>.indicator]:animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{top_right: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "absolute -translate-y-1/2 translate-x-1/2 left-auto top-0 right-0",
        !is_nil(@rest[:pinging]) && "[&>.indicator]:animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{middle_left: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "absolute -translate-y-1/2 -translate-x-1/2 right-auto left-0 top-2/4",
        !is_nil(@rest[:pinging]) && "[&>.indicator]:animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{middle_right: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "absolute -translate-y-1/2 translate-x-1/2 left-auto right-0 top-2/4",
        !is_nil(@rest[:pinging]) && "[&>.indicator]:animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{bottom_left: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "absolute translate-y-1/2 -translate-x-1/2 right-auto bottom-0 left-0",
        !is_nil(@rest[:pinging]) && "[&>.indicator]:animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{bottom_center: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "absolute translate-y-1/2 translate-x-1/2 bottom-0 right-1/2",
        !is_nil(@rest[:pinging]) && "[&>.indicator]:animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{bottom_right: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "absolute translate-y-1/2 translate-x-1/2 left-auto bottom-0 right-0",
        !is_nil(@rest[:pinging]) && "[&>.indicator]:animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        !is_nil(@rest[:pinging]) && "[&>.indicator]:animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  defp indicator_size("extra_small"), do: "!size-2"
  defp indicator_size("small"), do: "!size-2.5"
  defp indicator_size("medium"), do: "!size-3"
  defp indicator_size("large"), do: "!size-3.5"
  defp indicator_size("extra_large"), do: "!size-4"
  defp indicator_size(params) when is_binary(params), do: params
  defp indicator_size(nil), do: nil

  defp color_class("white") do
    "text-white hover:[&>li_a]:text-[#ededed]"
  end

  defp color_class("primary") do
    "text-[#4363EC] hover:[&>li_a]:text-[#072ed3]"
  end

  defp color_class("secondary") do
    "text-[#6B6E7C] hover:[&>li_a]:text-[#60636f]"
  end

  defp color_class("success") do
    "text-[#047857] hover:[&>li_a]:text-[#d4fde4] "
  end

  defp color_class("warning") do
    "text-[#FF8B08] hover:[&>li_a]:text-[#fff1cd]"
  end

  defp color_class("danger") do
    "text-[#E73B3B] hover:[&>li_a]:text-[#ffcdcd]"
  end

  defp color_class("info") do
    "text-[#004FC4] hover:[&>li_a]:text-[#cce1ff]"
  end

  defp color_class("misc") do
    "text-[#52059C] hover:[&>li_a]:text-[#ffe0ff]"
  end

  defp color_class("dawn") do
    "text-[#4D4137] hover:[&>li_a]:text-[#FFECDA]"
  end

  defp color_class("light") do
    "text-[#707483] hover:[&>li_a]:text-[#d2d8e9]"
  end

  defp color_class("dark") do
    "text-[#1E1E1E] hover:[&>li_a]:text-[#869093]"
  end

  defp drop_rest(rest) do
    all_rest =
      (["pinging"] ++ @indicator_positions)
      |> Enum.map(&if(is_binary(&1), do: String.to_atom(&1), else: &1))

    Map.drop(rest, all_rest)
  end
end
