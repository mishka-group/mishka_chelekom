defmodule MishkaChelekom.Typography do
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
# Colors Array: ['#4363EC','#6B6E7C','#227A52','#FF8B08','#6663FD','#52059C','#4D4137','#707483','#1E1E1E']

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  @spec h1(map()) :: Phoenix.LiveView.Rendered.t()
  def h1(assigns) do
    ~H"""
    <h1
      id={@id}
      class={
          [
            "#1E1E1E",
            "text-4xl",
            @font_weight,
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h1>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  @spec h2(any()) :: Phoenix.LiveView.Rendered.t()
  def h2(assigns) do
    ~H"""
    <h2
      id={@id}
      class={
          [
            "#1E1E1E",
            "text-3xl",
            @font_weight,
            @class
          ]
      }
      {@rest}>
      <%= render_slot(@inner_block) %>
    </h2>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def h3(assigns) do
    ~H"""
    <h3
      id={@id}
      class={
          [
            "#1E1E1E",
            "text-2xl",
            @font_weight,
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def h4(assigns) do
    ~H"""
    <h4
      id={@id}
      class={
          [
            "#1E1E1E",
            "text-xl",
            @font_weight,
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h4>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def h5(assigns) do
    ~H"""
    <h5
    id={@id}
      class={
          [
            "#1E1E1E",
            "text-lg",
            @font_weight,
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </h5>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def h6(assigns) do
    ~H"""
    <h6
      id={@id}
      class={
          [
            "#1E1E1E",
            "text-base",
            @font_weight,
            @class
          ]
      }
      {@rest}>
      <%= render_slot(@inner_block) %>
    </h6>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def p(assigns) do
    ~H"""
    <p
      id={@id}
      class={
          [
            "#1E1E1E",
            "text-base",
            @font_weight,
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def strong(assigns) do
    ~H"""
      <strong
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </strong>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def em(assigns) do
    ~H"""
      <em
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </em>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def dl(assigns) do
    ~H"""
      <dl
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </dl>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-bold", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def dt(assigns) do
    ~H"""
      <dt
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </dt>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def dd(assigns) do
    ~H"""
      <dd
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </dd>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def figure(assigns) do
    ~H"""
    <figure
      id={@id}
      class={
          [
            "my-0 mx-4",
            "#1E1E1E",
            "text-base",
            @font_weight,
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </figure>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def figcaption(assigns) do
    ~H"""
    <figcaption
      id={@id}
      class={
          [
            "mt-1 mb-4 text-sm text-[#6c757d] before:content-['— '] before:block",
            "#1E1E1E",
            "text-base",
            @font_weight,
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </figcaption>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def abbr(assigns) do
    ~H"""
      <abbr
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </abbr>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def mark(assigns) do
    ~H"""
      <mark
        id={@id}
        class={
            [
              "text-sm p-0.5 bg-rose-200",
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </mark>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def small(assigns) do
    ~H"""
      <small
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </small>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def s(assigns) do
    ~H"""
      <s
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </s>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def u(assigns) do
    ~H"""
      <u
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </u>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def cite(assigns) do
    ~H"""
      <cite
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </cite>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def del(assigns) do
    ~H"""
      <del
        id={@id}
        class={
            [
              "#1E1E1E",
              "text-base",
              @font_weight,
              @class
            ]
        }
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </del>
    """
  end
end
