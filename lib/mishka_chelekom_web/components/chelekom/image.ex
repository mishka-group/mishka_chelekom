defmodule MishkaChelekom.Image do
  @moduledoc """
  The `MishkaChelekom.Image` module provides a component for rendering images in a Phoenix application.
  It supports various attributes to control the display, loading behavior, and styling of the image.

  This module simplifies the use of images with various configurations and styling
  options in a Phoenix application.
  """

  use Phoenix.Component

  @doc """
  Renders an image component with various customization options such as border `radius`, `shadow`,
  and `loading` behavior.

  It supports additional attributes like width, height, and srcset for responsive images.

  ## Examples

  ```elixir
  <MishkaChelekom.Image.image src="https://example.com/1.jpg" />

  <MishkaChelekom.Image.image src="https://example.com/1.jpg" loading="lazy"/>

  <MishkaChelekom.Image.image shadow="large" src="https://example.com/1.jpg" width={100} height={100}/>

  <MishkaChelekom.Image.image rounded="full" src="https://example.com/1.jpg" width={100} height={100}/>

  <MishkaChelekom.Image.image
    fetchpriority="low"
    rounded="rounded-3xl"
    shadow="extra_large"
    src="https://example.com/1.jpg"
  />
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :src, :string, required: true, doc: "Media link"
  attr :alt, :string, default: nil, doc: "Media link description"
  attr :srcset, :string, default: nil, doc: "Allows you to specify a list of different images"

  attr :loading, :string,
    values: ["eager", "lazy", nil],
    default: nil,
    doc: "eager: is default, lazy"

  attr :referrerpolicy, :string, default: nil, doc: ""

  attr :fetchpriority, :string,
    values: ["high", "low", "auto", nil],
    default: nil,
    doc: "high, low, auto is default"

  attr :width, :integer, default: nil, doc: "Determines width style"
  attr :height, :integer, default: nil, doc: "Determines width height"

  attr :sizes, :string,
    default: nil,
    doc:
      "Specifies the intended display size of the image in the layout for different viewport conditions"

  attr :ismap, :string, default: nil, doc: "Make the image act as a server-side image map"

  attr :decoding, :string,
    default: nil,
    doc:
      "Refers to the process of converting encoded or encrypted data back into its original format"

  attr :rounded, :string, default: nil, doc: "Determines the border radius"
  attr :shadow, :string, default: nil, doc: "Determines shadow style"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def image(assigns) do
    ~H"""
    <img
      id={@id}
      src={@src}
      alt={@alt}
      width={@width}
      height={@height}
      srcset={@srcset}
      sizes={@sizes}
      loading={@loading}
      ismap={@ismap}
      decoding={@decoding}
      fetchpriority={@fetchpriority}
      referrerpolicy={@referrerpolicy}
      class={[
        "max-w-full",
        rounded_size(@rounded),
        shadow_size(@shadow),
        @class
      ]}
      {@rest}
    />
    """
  end

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: nil

  defp shadow_size("extra_small"), do: "shadow-sm"
  defp shadow_size("small"), do: "shadow"
  defp shadow_size("medium"), do: "shadow-md"
  defp shadow_size("large"), do: "shadow-lg"
  defp shadow_size("extra_large"), do: "shadow-xl"
  defp shadow_size(params) when is_binary(params), do: params
  defp shadow_size(_), do: nil
end
