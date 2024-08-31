defmodule MishkaChelekom.Timeline do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :color, :string, default: "silver", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""
  slot :title, required: false, doc: ""

  #TODO: User cannot change color based on their need
  #TODO: CAnnot change size of bullet
  def timeline(assigns) do
    ~H"""
    <div class={[color_class(@color)]}>
      <div class="ps-2 my-2 first:mt-0">
        <div class="text-xs font-medium uppercase text-gray-500">
          <%= render_slot(@title) %>
        </div>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :line_width, :string, default: "extra_small", doc: ""
  attr :bullet_size, :string, default: "extra_small", doc: ""
  attr :line_gapped, :string, default: "gapped", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  def timeline_section(assigns) do
    ~H"""
    <div id={@id}
      class={[
        "flex gap-x-3",
        line_gapped(@line_gapped)
      ]}
    >
      <div class={[
        "timeline-vertical-line relative last:after:hidden after:absolute",
        "after:bottom-0 after:start-3.5 after:-translate-x-[0.5px]",
        line_width(@line_width)
      ]}>
        <div class="timeline-bullet-wrapper relative z-10 size-7 flex justify-center">
          <div
            class={[
              "rounded-full timeline-bullet",
              bullet_size(@bullet_size)
            ]}
          ></div>
        </div>
      </div>

      <div class="grow pt-0.5 pb-8">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp line_gapped("gapped"), do: "[&_.timeline-vertical-line]:after:top-7 [&_.timeline-bullet-wrapper]:items-center"
  defp line_gapped("none"), do: "[&_.timeline-vertical-line]:after:top-0"

defp line_width("extra_small"), do: "after:w-px"
defp line_width("small"), do: "after:w-0.5"
defp line_width("medium"), do: "after:w-1"
defp line_width("large"), do: "after:w-1.5"
defp line_width("extra_large"), do: "after:2"
defp line_width(params) when is_binary(params), do: params
defp line_width(_), do: line_width("extra_small")

defp bullet_size("extra_small"), do: "size-2"
defp bullet_size("small"), do: "size-2.5"
defp bullet_size("medium"), do: "size-3"
defp bullet_size("large"), do: "size-3.5"
defp bullet_size("extra_large"), do: "size-4"
defp bullet_size(params) when is_binary(params), do: params
defp bullet_size(_), do: bullet_size("extra_small")

  defp color_class("silver") do
    "[&_.timeline-bullet]:bg-[#DADADA] text-[#3E3E3E] [&_.timeline-vertical-line]:after:bg-[#DADADA]"
  end

  defp color_class("primary") do
    "[&_.timeline-bullet]:bg-[#2441de] text-white [&_.timeline-vertical-line]:after:bg-[#2441de]"
  end

  defp color_class("secondary") do
    "[&_.timeline-bullet]:bg-[#877C7C] text-white [&_.timeline-vertical-line]:after:bg-[#877C7C]"
  end

  defp color_class("success") do
    "[&_.timeline-bullet]:bg-[#6EE7B7] text-[#047857] [&_.timeline-vertical-line]:after:bg-[#6EE7B7]"
  end

  defp color_class("warning") do
    "[&_.timeline-bullet]:bg-[#FF8B08] text-[#FF8B08] [&_.timeline-vertical-line]:after:bg-[#FF8B08]"
  end

  defp color_class("danger") do
    "[&_.timeline-bullet]:bg-[#E73B3B] text-[#E73B3B] [&_.timeline-vertical-line]:after:bg-[#E73B3B]"
  end

  defp color_class("info") do
    "[&_.timeline-bullet]:bg-[#004FC4] text-[#004FC4] [&_.timeline-vertical-line]:after:bg-[#004FC4]"
  end

  defp color_class("misc") do
    "[&_.timeline-bullet]:bg-[#52059C] text-[#52059C] [&_.timeline-vertical-line]:after:bg-[#52059C]"
  end

  defp color_class("dawn") do
    "[&_.timeline-bullet]:bg-[#4D4137] text-[#4D4137] [&_.timeline-vertical-line]:after:bg-[#4D4137]"
  end

  defp color_class("light") do
    "[&_.timeline-bullet]:bg-[#707483] text-[#707483] [&_.timeline-vertical-line]:after:bg-[#707483]"
  end

  defp color_class("dark") do
    "[&_.timeline-bullet]:bg-[#1E1E1E] text-white [&_.timeline-vertical-line]:after:bg-[#1E1E1E]"
  end

  defp color_class(params) when is_binary(params), do: params
end
