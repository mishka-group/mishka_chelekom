defmodule MishkaChelekom.Typography do
  use Phoenix.Component

  @colors [
    "primary",
    "secondary",
    "dark",
    "success",
    "warning",
    "danger",
    "info",
    "light",
    "misc",
    "dawn",
    "inherit"
  ]

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "quadruple_large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  @spec h1(map()) :: Phoenix.LiveView.Rendered.t()
  def h1(assigns) do
    ~H"""
    <h1
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h1>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "triple_large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  @spec h2(any()) :: Phoenix.LiveView.Rendered.t()
  def h2(assigns) do
    ~H"""
    <h2
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h2>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "double_large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def h3(assigns) do
    ~H"""
    <h3
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "extra_large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def h4(assigns) do
    ~H"""
    <h4
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h4>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def h5(assigns) do
    ~H"""
    <h5
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h5>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def h6(assigns) do
    ~H"""
    <h6
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h6>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def p(assigns) do
    ~H"""
    <p
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-bold", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def strong(assigns) do
    ~H"""
    <strong
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </strong>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def em(assigns) do
    ~H"""
    <em
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </em>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def dl(assigns) do
    ~H"""
    <dl
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </dl>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-bold", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def dt(assigns) do
    ~H"""
    <dt
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </dt>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def dd(assigns) do
    ~H"""
    <dd
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </dd>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def figure(assigns) do
    ~H"""
    <figure
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </figure>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def figcaption(assigns) do
    ~H"""
    <figcaption
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </figcaption>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def abbr(assigns) do
    ~H"""
    <abbr
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </abbr>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: "p-0.5 bg-rose-200", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def mark(assigns) do
    ~H"""
    <mark
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </mark>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def small(assigns) do
    ~H"""
    <small
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </small>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def s(assigns) do
    ~H"""
    <s
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </s>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def u(assigns) do
    ~H"""
    <u
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </u>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def cite(assigns) do
    ~H"""
    <cite
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </cite>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "inherit", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def del(assigns) do
    ~H"""
    <del
      id={@id}
      class={[
        color(@color),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </del>
    """
  end

  defp color("white") do
    "text-white"
  end

  defp color("primary") do
    "text-[#4363EC]"
  end

  defp color("secondary") do
    "text-[#6B6E7C]"
  end

  defp color("success") do
    "text-[#227A52]"
  end

  defp color("warning") do
    "text-[#FF8B08]"
  end

  defp color("danger") do
    "text-[#E73B3B]"
  end

  defp color("info") do
    "text-[#6663FD]"
  end

  defp color("misc") do
    "text-[#52059C]"
  end

  defp color("dawn") do
    "text-[#4D4137]"
  end

  defp color("light") do
    "text-[#707483]"
  end

  defp color("dark") do
    "text-[#1E1E1E]"
  end

  defp color("inherit") do
    "text-inherit"
  end

  defp color(params), do: params

  defp size_class("extra_small"), do: "text-xs"
  defp size_class("small"), do: "text-sm"
  defp size_class("medium"), do: "text-base"
  defp size_class("large"), do: "text-lg"
  defp size_class("extra_large"), do: "text-xl"
  defp size_class("double_large"), do: "text-2xl"
  defp size_class("triple_large"), do: "text-3xl"
  defp size_class("quadruple_large"), do: "text-4xl"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medoum")
end
