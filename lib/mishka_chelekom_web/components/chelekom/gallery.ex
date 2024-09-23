defmodule MishkaChelekom.Gallery do
  @moduledoc """
  The `MishkaChelekom.Gallery` module provides a customizable gallery component for displaying
  media content in a structured and visually appealing layout.

  It supports various styles, including default, masonry, and featured galleries,
  with options to control the number of columns, gaps, and additional styling.

  ### Features:

  - **Gallery Types:** Choose between "default", "masonry", and "featured" gallery layouts.
  - **Customizable Columns and Gaps:** Configure the number of columns and spacing between gallery items.
  - **Flexible Media Display:** Includes a `gallery_media` component for displaying individual
  media items with options for styling, shadow, and border radius.

  This component is ideal for showcasing images, videos, or other media content in a grid
  or masonry layout, offering a clean and flexible way to present visual elements on a web page.
  """

  use Phoenix.Component

  @doc """
  Renders a `gallery` component that supports various layout types including default grid,
  masonry, and featured styles.

  You can customize the number of columns and gaps between items to achieve the desired layout.

  ## Examples

  ```elixir
  <.gallery type="masonary" cols="four" gap="large">
    <.gallery_media src="https://example.com/gallery/masonry/image.jpg" />
    <.gallery_media src="https://example.com/gallery/masonry/image-2.jpg" />
    <.gallery_media src="https://example.com/gallery/masonry/image-3.jpg" />
    <.gallery_media src="https://example.com/gallery/masonry/image-4.jpg" />
    <.gallery_media src="https://example.com/gallery/masonry/image-5.jpg" />
    <.gallery_media src="https://example.com/gallery/masonry/image-6.jpg" />
    <.gallery_media src="https://example.com/gallery/masonry/image-7.jpg" />
    <.gallery_media src="https://example.com/gallery/masonry/image-8.jpg" />
    <.gallery_media src="https://example.com/gallery/masonry/image-1.jpg" />
  </.gallery>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :type, :string, values: ["default", "masonary", "featured"], default: "default", doc: ""
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :cols, :string, default: nil, doc: "Determines cols of elements"
  attr :gap, :string, default: nil, doc: "Determines gap between elements"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def gallery(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        (@type == "masonary" && "gallery-masonary") || "grid",
        grid_gap(@gap),
        @type == "masonary" && column_class(@cols),
        grid_cols(@cols) != "masonary" && grid_cols(@cols),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a `gallery_media` component within a gallery, which typically includes images.
  You can customize the border radius and shadow style of the media element.

  ## Examples

  ```elixir
  <.gallery_media src="https://example.com/gallery/masonry/image.jpg" />
  <.gallery_media src="https://example.com/gallery/masonry/image-2.jpg" rounded="large" shadow="shadow-lg" />
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :src, :string, default: nil, doc: "Media link"
  attr :alt, :string, default: "", doc: "Media link description"
  attr :rounded, :string, default: "none", doc: "Determines the border radius"
  attr :shadow, :string, default: "shadow-none", doc: "Determines shadow style"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def gallery_media(assigns) do
    ~H"""
    <div id={@id}>
      <img
        class={[
          "gallery-media h-auto max-w-full",
          rounded_size(@rounded),
          shadow_class(@shadow),
          @class
        ]}
        src={@src}
        alt={@alt}
        {@rest}
      />
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

  defp shadow_class("extra_small"), do: "shadow-sm"
  defp shadow_class("small"), do: "shadow"
  defp shadow_class("medium"), do: "shadow-md"
  defp shadow_class("large"), do: "shadow-lg"
  defp shadow_class("extra_large"), do: "shadow-xl"
  defp shadow_class("none"), do: "shadow-none"
  defp shadow_class(params) when is_binary(params), do: params
  defp shadow_class(_), do: shadow_class("none")

  defp grid_cols("one"), do: "grid-cols-1"
  defp grid_cols("two"), do: "grid-cols-2"
  defp grid_cols("three"), do: "grid-cols-2 md:grid-cols-3"
  defp grid_cols("four"), do: "grid-cols-2 md:grid-cols-4"
  defp grid_cols("five"), do: "grid-cols-2 md:grid-cols-5"
  defp grid_cols("six"), do: "grid-cols-2 md:grid-cols-6"
  defp grid_cols("seven"), do: "grid-cols-2 md:grid-cols-7"
  defp grid_cols("eight"), do: "grid-cols-2 md:grid-cols-8"
  defp grid_cols("nine"), do: "grid-cols-2 md:grid-cols-9"
  defp grid_cols("ten"), do: "grid-cols-2 md:grid-cols-10"
  defp grid_cols("eleven"), do: "grid-cols-2 md:grid-cols-11"
  defp grid_cols("twelve"), do: "grid-cols-2 md:grid-cols-12"
  defp grid_cols(params) when is_binary(params), do: params
  defp grid_cols(_), do: nil

  defp column_class("one"), do: "columns-1"
  defp column_class("two"), do: "columns-2"
  defp column_class("three"), do: "columns-2 md:columns-3"
  defp column_class("four"), do: "columns-2 md:columns-4"
  defp column_class("five"), do: "columns-2 md:columns-5"
  defp column_class("six"), do: "columns-2 md:columns-6"
  defp column_class("seven"), do: "columns-2 md:columns-7"
  defp column_class("eight"), do: "columns-2 md:columns-8"
  defp column_class("nine"), do: "columns-2 md:columns-9"
  defp column_class("ten"), do: "columns-2 md:columns-10"
  defp column_class("eleven"), do: "columns-2 md:columns-11"
  defp column_class("twelve"), do: "columns-2 md:columns-12"
  defp column_class(params) when is_binary(params), do: params
  defp column_class(_), do: column_class("one")

  defp grid_gap("extra_small"), do: "gap-1 [&.gallery-masonary_.gallery-media]:mb-1"
  defp grid_gap("small"), do: "gap-2 [&.gallery-masonary_.gallery-media]:mb-2"
  defp grid_gap("medium"), do: "gap-3 [&.gallery-masonary_.gallery-media]:mb-3"
  defp grid_gap("large"), do: "gap-4 [&.gallery-masonary_.gallery-media]:mb-4"
  defp grid_gap("extra_large"), do: "gap-5 [&.gallery-masonary_.gallery-media]:mb-5"
  defp grid_gap("double_large"), do: "gap-6 [&.gallery-masonary_.gallery-media]:mb-6"
  defp grid_gap("triple_large"), do: "gap-7 [&.gallery-masonary_.gallery-media]:mb-7"
  defp grid_gap("quadruple_large"), do: "gap-8 [&.gallery-masonary_.gallery-media]:mb-8"
  defp grid_gap(params) when is_binary(params), do: params
  defp grid_gap(_), do: nil
end
