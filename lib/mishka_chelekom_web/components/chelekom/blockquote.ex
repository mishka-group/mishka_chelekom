defmodule MishkaChelekom.Blockquote do
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

  @doc type: :component
  attr :id, :string, default: nil, doc: ""

  attr :variant, :string,
    values: ["default", "outline", "transparent", "unbordered", "shadow"],
    default: "default",
    doc: ""

  attr :size, :string, default: "extra_small", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "small", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :title, required: false do
    attr :icon, :string, required: false
  end

  slot :content, required: false
  slot :inner_block, required: false, doc: ""

  def blockquote(assigns) do
    ~H"""
    <figure class="space-y-3">
      <blockquote class="border-s-4 border-gray-300 bg-gray-50 p-2 italic">
        Lorem ipsum, dolor sit amet consectetur adipisicing elit. Rem nihil commodi, facere voluptatum dolores tempora vero soluta harum nam esse
      </blockquote>
      <figcaption class="flex items-center justify-center mt-6 space-x-3 rtl:space-x-reverse">
          <img class="w-6 h-6 rounded-full" src="https://flowbite.com/docs/images/people/profile-picture-5.jpg" alt="">
          <div class="flex items-center divide-x-2 rtl:divide-x-reverse divide-gray-500">
            <cite class="pe-3">Text</cite>
            <cite class="ps-3">Text</cite>
          </div>
      </figcaption>
    </figure>
    """
  end
end
