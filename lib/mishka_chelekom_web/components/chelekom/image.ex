defmodule MishkaChelekom.Image do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :src, :string, default: nil, doc: ""
  attr :alt, :string, default: nil, doc: ""
  attr :srcset, :string, default: nil, doc: ""
  attr :loading, :string, default: nil, doc: "eager, lazya"
  attr :referrerpolicy, :string, default: nil, doc: "eager, lazya"
  attr :width, :string, default: nil, doc: ""
  attr :height, :string, default: nil, doc: ""
  attr :sizes, :string, default: nil, doc: ""
  attr :ismap, :string, default: nil, doc: ""
  attr :decoding, :string, default: nil, doc: ""
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
      referrerpolicy={@referrerpolicy}
      class={[
        "max-w-full",
        @class
      ]}
    />
    """
  end
end
