defmodule MishkaChelekom.Badge do
  use Phoenix.Component
  import MishkaChelekomWeb.CoreComponents

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
    values: ["default", "bordered"],
    default: "default",
    doc: ""

  attr :size, :string, default: "large", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "large", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :border, :string, doc: ""

  slot :notification, required: false do
    attr :type, :string, values: ["left", "right", "top_right", "top_left"]
    attr :count, :string
    attr :color, :string, values: @colors
  end

  attr :rest, :global, include: ~w(right_dismiss left_dismiss right_icon left_icon), doc: ""
  slot :inner_block, required: false, doc: ""

  def badge(assigns) do
    ~H"""
    <div
          class="shadow-sm shadow-neutral-500/10 inline-flex gap-1.5 items-center border border-neutral-500 rounded px-2 py-0.5"
        >
          <span>pills</span>
          <button class="h-fit">
            <.icon name="hero-arrow-trending-up" class="w-3 h-3" />
          </button>
        </div>
    """
  end

  def pill(assigns) do
    ~H"""
      <div
          class="shadow-sm inline-flex gap-1.5 items-center shadow-neutral-500/10 border border-neutral-500 rounded-full px-2 py-0.5"
        >
          <span>pills</span>
      </div>
    """
  end

  def pill_close(assigns) do
    ~H"""
    <div
          class="shadow-sm shadow-neutral-500/10 inline-flex gap-1.5 items-center border border-neutral-500 rounded px-2 py-0.5"
        >
          <span>pills</span>
          <button class="shrink-0 h-fit">
            <.icon name="hero-x-mark" class="w-3 h-3" />
          </button>
    </div>
    """
  end
end
