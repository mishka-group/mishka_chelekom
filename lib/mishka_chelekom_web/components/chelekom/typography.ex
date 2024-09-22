defmodule MishkaChelekom.Typography do
  @moduledoc """
  The `MishkaChelekom.Typography` module provides components for rendering
  typographic elements in a Phoenix application.

  This module offers various components such as headings (h1 to h6), paragraphs, and other
  text-related HTML elements. Each component allows customization of attributes such
  as `id`, `color`, `size`, and `font_weight`, enabling developers to create styled
  text elements that align with the design requirements of their applications.

  The components are designed to work seamlessly with HEEx templates, supporting slots for
  rendering dynamic content.
  """
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

  @doc """
  The `h1` component renders a large header text with customizable size, color, and other styling options.
  It is used to display primary headings in your layout.

  ## Examples

  ```elixir
  <.h1>Heading 1</.h1>
  <.h1 color="primary" size="large">Primary Heading 1</.h1>
  <.h1 class="custom-class" font_weight="font-bold">Bold Heading 1</.h1>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "quadruple_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `h2` component renders a large header text with customizable size, color, and other styling options.
  It is used to display primary headings in your layout.

  ## Examples

  ```elixir
  <.h2>Heading 2</.h2>
  <.h2 color="primary" size="large">Primary Heading 2</.h2>
  <.h2 class="custom-class" font_weight="font-bold">Bold Heading 2</.h1>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "triple_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `h1` component renders a large header text with customizable size, color, and other styling options.
  It is used to display primary headings in your layout.

  ## Examples

  ```elixir
  <.h3>Heading 3</.h3>
  <.h3 color="primary" size="large">Primary Heading 3</.h3>
  <.h3 class="custom-class" font_weight="font-bold">Bold Heading 3</.h3>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "double_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  @doc type: :component
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

  @doc """
  The `h4` component renders a large header text with customizable size, color, and other styling options.
  It is used to display primary headings in your layout.

  ## Examples

  ```elixir
  <.h4>Heading 4</.h4>
  <.h4 color="primary" size="large">Primary Heading 4</.h4>
  <.h4 class="custom-class" font_weight="font-bold">Bold Heading 4</.h4>
  ```
  """
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  @doc type: :component
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

  @doc """
  The `h1` component renders a large header text with customizable size, color, and other styling options.
  It is used to display primary headings in your layout.

  ## Examples

  ```elixir
  <.h5>Heading 5</.h5>
  <.h5 color="primary" size="large">Primary Heading 5</.h5>
  <.h5 class="custom-class" font_weight="font-bold">Bold Heading 5</.h5>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `h6` component renders a large header text with customizable size, color, and other styling options.
  It is used to display primary headings in your layout.

  ## Examples

  ```elixir
  <.h6>Heading 6</.h6>
  <.h6 color="primary" size="large">Primary Heading 6</.h6>
  <.h6 class="custom-class" font_weight="font-bold">Bold Heading 6</.h6>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `p` component is used to render a paragraph with customizable size, color, and other
  styling options.

  It helps in displaying regular text content within your layout.

  ## Examples

  ```elixir
  <.p>Here is the paragraph.</.p>
  <.p color="primary" size="large">This is a primary colored paragraph with a larger size.</.p>
  <.p><.strong>This is Strong</.strong></.p>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `strong` component is used to emphasize important text by rendering it in a bold style.

  It allows customization of color, size, and additional styles.

  ## Examples

  ```elixir
  <.strong>This is Strong</.strong>
  <.strong color="primary" size="large">
    This is a primary colored strong text with a larger size.
  </.strong>
  <.strong class="custom-class">This is strong text with custom styling.</.strong>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-bold",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `em` component is used to emphasize text, rendering it in italics to indicate importance or stress.

  It allows customization of color, size, and additional styles.

  ## Examples

  ```elixir
  <.p><.em>This is Em</.em></.p>

  <.em color="primary" size="large">
    This is emphasized text with a primary color and larger size.
  </.em>

  <.em class="custom-class">
    This is emphasized text with custom styling.
  </.em>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `dl` component represents a description list, typically used for name-value pairs such as
  terms and definitions. It can be styled with custom colors, sizes, and other attributes.

  ## Examples

  ```elixir
  <.dl>
    <.dt>Coffee</.dt>
    <.dd>Black hot drink</.dd>
    <.dt>Milk</.dt>
    <.dd>White cold drink</.dd>
  </.dl>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `dt` component represents a term or name in a description list (`dl`). It is typically used in
  conjunction with the `dd` component to display a description or definition for the term.

  ## Examples

  ```elixir
  <.dt>Coffee</.dt>
  <.dd>Black hot drink</.dd>
  <.dt>Milk</.dt>
  <.dd>White cold drink</.dd>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-bold",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `dd` component represents the description or definition of a term in a description
  list (`dl`).

  It is typically used with the `dt` component to create a complete term-description structure.

  ## Examples

  ```elixir
  <.dl>
    <.dt>Coffee</.dt>
    <.dd>Black hot drink</.dd>
    <.dt>Milk</.dt>
    <.dd>White cold drink</.dd>
  </.dl>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `figure` component is used to group content, such as an image and its caption,
  as a single unit.

  It is typically used in conjunction with the `figcaption` component to provide a caption
  or description for the content.

  ## Examples

  ```elixir
  <.figure>
    <.p>Content of Figure</.p>

    <.figcaption>
      Someone famous in <cite title="Source Title">Source Title</cite>
    </.figcaption>
  </.figure>

  <.figure size="large" color="secondary">
    <img src="https://example.com/image.jpg" alt="Example image" />
    <.figcaption>
      A beautiful scenery captured during summer.
    </.figcaption>
  </.figure>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `figcaption` component is used to add a caption or description to a `figure` element.

  It is typically placed inside a `figure` component to provide context or credit for
  the enclosed content, such as an image or illustration.

  ## Examples

  ```elixir
  <.figcaption>
    Someone famous in <cite title="Source Title">Source Title</cite>
  </.figcaption>

  <.figure>
    <img src="https://example.com/image.jpg" alt="Example image" />
    <.figcaption>
      A beautiful scenery captured during summer.
    </.figcaption>
  </.figure>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `abbr` component is used to display an abbreviation or acronym, providing a way to
  define or explain the shortened text using the `title` attribute.

  ## Examples

  ```elixir
  <.abbr title="HyperText Markup Language">HTML</.abbr>

  <.p>
    The standard language for creating web pages is
    <.abbr title="HyperText Markup Language">HTML</.abbr>.
  </.p>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `mark` component is used to highlight text, typically by applying a background color to
  the wrapped content.

  ## Examples

  ```elixir
  <.p><.mark>This is highlighted text</.mark> inside a paragraph.</.p>

  <.mark>Highlighted text with default styles.</.mark>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string,
    default: "p-0.5 bg-rose-200",
    doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `small` component is used for rendering small-sized text with various
  styling options such as color, size, and weight.

  ## Examples

  ```elixir
  <.small>This is small text</.small>

  <.small color="primary" font_weight="font-bold">This is bold primary small text</.small>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `s` component is used to render text with a strikethrough style, r
  epresenting content that is no longer relevant or accurate.

  ## Examples

  ```elixir
  <.p><.s>This is strikethrough text</.s></.p>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `u` component is used to underline text content.

  It allows customization through attributes such as color, size, and font weight.

  ## Examples

  ```elixir
  <.p><.u>This is u</.u></.p>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `cite` component is used to reference the title of a work or to indicate a citation.
  It allows customization through attributes such as color, size, and font weight.

  ## Examples

  ```elixir
  <.p>
    <.cite>
      Source Title
    </.cite>
  </.p>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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

  @doc """
  The `del` component is used to represent text that has been deleted or marked for removal.

  It supports attributes for customizing color, size, and font weight.

  ## Examples

  ```elixir
  <.del>This text is marked for deletion.</.del>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "inherit", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

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
