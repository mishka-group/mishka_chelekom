defmodule MishkaChelekom.Image do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :src, :string, required: true, doc: ""
  attr :alt, :string, default: nil, doc: ""
  attr :srcset, :string, default: nil, doc: ""

  attr :loading, :string,
    values: ["eager", "lazy", nil],
    default: nil,
    doc: "eager: is default, lazy"

  attr :referrerpolicy, :string, default: nil, doc: ""

  attr :fetchpriority, :string,
    values: ["high", "low", "auto", nil],
    default: nil,
    doc: "high, low, auto is default"

  attr :width, :integer, default: nil, doc: ""
  attr :height, :integer, default: nil, doc: ""
  attr :sizes, :string, default: nil, doc: ""
  attr :ismap, :string, default: nil, doc: ""
  attr :decoding, :string, default: nil, doc: ""
  attr :rounded, :string, default: nil, doc: ""
  attr :shadow, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

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
