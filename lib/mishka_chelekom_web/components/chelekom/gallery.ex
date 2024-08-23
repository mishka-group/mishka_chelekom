defmodule MishkaChelekom.Gallery do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :cols, :string, default: nil, doc: ""
  attr :gap, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def gallery(assigns) do
    ~H"""
      <div
        id={@id}
        class={[
          "grid",
          grid_cols(@cols),
          grid_gap(@gap)
        ]}
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </div>
    """
  end

  #TODO: Media can have shadow and border and radius

  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :cols, :string, default: nil, doc: ""
  attr :gap, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def gallery_masonary(assigns) do
    ~H"""
      <div
        id={@id}
        class={[
          "grid",
          grid_cols(@cols),
          grid_gap(@gap)
        ]}
        {@rest}
      >
        <div class="grid gap-4">
         <.gallery_media src="https://flowbite.s3.amazonaws.com/docs/gallery/square/image-2.jpg" />
        </div>
      </div>
    """
  end

  attr :class, :string, default: nil, doc: ""
  attr :src, :string, default: nil, doc: ""
  attr :alt, :string, default: "", doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def gallery_media(assigns) do
    ~H"""
      <div
        class={[
          "grid",
          grid_cols(@cols),
          grid_gap(@gap)
        ]}
        {@rest}
      >
        <div>
          <img class="w-full" src={@src} alt={@alt} />
        </div>
      </div>
    """
  end

  defp grid_cols("one"), do: "grid-cols-1"
  defp grid_cols("two"), do: "grid-cols-2"
  defp grid_cols("three"), do: "grid-cols-3"
  defp grid_cols("four"), do: "grid-cols-4"
  defp grid_cols("five"), do: "grid-cols-5"
  defp grid_cols("six"), do: "grid-cols-6"
  defp grid_cols("seven"), do: "grid-cols-7"
  defp grid_cols("eight"), do: "grid-cols-8"
  defp grid_cols("nine"), do: "grid-cols-9"
  defp grid_cols("ten"), do: "grid-cols-10"
  defp grid_cols("eleven"), do: "grid-cols-11"
  defp grid_cols("twelve"), do: "grid-cols-12"
  defp grid_cols(params) when is_binary(params), do: params
  defp grid_cols(_), do: nil

  defp grid_gap("extra_small"), do: "gap-1"
  defp grid_gap("small"), do: "gap-2"
  defp grid_gap("medium"), do: "gap-3"
  defp grid_gap("large"), do: "gap-4"
  defp grid_gap("extra_large"), do: "gap-5"
  defp grid_gap("double_large"), do: "gap-6"
  defp grid_gap("triple_large"), do: "gap-7"
  defp grid_gap("quadruple_large"), do: "gap-8"
  defp grid_gap(params) when is_binary(params), do: params
  defp grid_gap(_), do: nil
end
