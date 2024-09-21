defmodule MishkaChelekom.DeviceMockup do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "A unique identifier is used to manage state and interaction"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "silver", doc: ""
  attr :alt, :string, default: nil, doc: ""
  attr :type, :string, default: "iphone", doc: "android watch laptop iphone ipad imac"
  attr :image, :string, default: nil, doc: ""
  attr :image_class, :string, default: nil, doc: ""
  attr :rest, :global, include: ~w(android watch laptop iphone ipad imac), doc: ""
  slot :inner_block, doc: ""

  def device_mockup(%{type: "watch"} = assigns) do
    ~H"""
    <div class={["w-fit", color_class(@color), @class]}>
      <div class="mock-base relative mx-auto rounded-t-[2.5rem] h-[63px] max-w-[133px]"></div>
      <div class="mock-base relative mx-auto border-[10px] rounded-[2.5rem] h-[213px] w-[208px]">
        <div class="mock-base h-[41px] w-[6px] absolute -end-[16px] top-[40px] rounded-e-lg"></div>
        <div class="mock-base h-[32px] w-[6px] absolute -end-[16px] top-[88px] rounded-e-lg"></div>
        <div class="bg-white rounded-[2rem] overflow-hidden h-[193px] w-[188px]">
          <MishkaChelekom.Image.image
            :if={!is_nil(@image)}
            class={@image_class || "h-[193px] w-[188px]"}
            src={@image}
            alt={@alt}
          />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
      <div class="mock-base relative mx-auto rounded-b-[2.5rem] h-[63px] max-w-[133px]"></div>
    </div>
    """
  end

  def device_mockup(%{type: "android"} = assigns) do
    ~H"""
    <div class={["w-fit", color_class(@color), @class]}>
      <div class="mock-base relative mx-auto border-[14px] rounded-xl h-[600px] w-[300px] shadow-xl">
        <div class="mock-base w-[148px] h-[18px] top-0 rounded-b-[1rem] left-1/2 -translate-x-1/2 absolute">
        </div>
        <div class="mock-base h-[32px] w-[3px] absolute -start-[17px] top-[72px] rounded-s-lg"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[124px] rounded-s-lg"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[178px] rounded-s-lg"></div>
        <div class="mock-base h-[64px] w-[3px] absolute -end-[17px] top-[142px] rounded-e-lg"></div>
        <div class="rounded overflow-hidden w-[272px] h-[572px] bg-white">
          <MishkaChelekom.Image.image
            :if={!is_nil(@image)}
            class={@image_class || "w-[272px] h-[572px]"}
            src={@image}
            alt={@alt}
          />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  def device_mockup(%{type: "laptop"} = assigns) do
    ~H"""
    <div class={["w-fit", color_class(@color), @class]}>
      <div class="mock-base relative mx-auto border-[8px] rounded-t-xl h-[172px] max-w-[301px] md:h-[294px] md:max-w-[512px]">
        <div class="rounded overflow-hidden h-[156px] md:h-[278px] bg-white">
          <MishkaChelekom.Image.image
            :if={!is_nil(@image)}
            class={@image_class || "h-[140px] md:h-[262px] w-full"}
            src={@image}
            alt={@alt}
          />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
      <div class="mock-darker-base relative mx-auto rounded-b-xl rounded-t-sm h-[17px] max-w-[351px] md:h-[21px] md:max-w-[597px]">
        <div class="mock-base absolute left-1/2 top-0 -translate-x-1/2 rounded-b-xl w-[56px] h-[5px] md:w-[96px] md:h-[8px]">
        </div>
      </div>
    </div>
    """
  end

  def device_mockup(%{type: "ipad"} = assigns) do
    ~H"""
    <div class={["w-fit", color_class(@color), @class]}>
      <div class="mock-base relative mx-auto border-[14px] rounded-[2.5rem] h-[454px] max-w-[341px] md:h-[682px] md:max-w-[512px]">
        <div class="mock-base h-[32px] w-[3px] absolute -start-[17px] top-[72px] rounded-s-lg"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[124px] rounded-s-lg"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[178px] rounded-s-lg"></div>
        <div class="mock-base h-[64px] w-[3px] absolute -end-[17px] top-[142px] rounded-e-lg"></div>
        <div class="bg-white rounded-3xl overflow-hidden h-[426px] md:h-[654px]">
          <MishkaChelekom.Image.image
            :if={!is_nil(@image)}
            class={@image_class || "h-[426px] md:h-[654px]"}
            src={@image}
            alt={@alt}
          />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  def device_mockup(%{type: "imac"} = assigns) do
    ~H"""
    <div class={["w-fit", color_class(@color), @class]}>
      <div class="mock-base relative mx-auto border-[16px] rounded-t-xl h-[172px] max-w-[301px] md:h-[294px] md:max-w-[512px]">
        <div class="overflow-hidden h-[140px] md:h-[262px]">
          <MishkaChelekom.Image.image
            :if={!is_nil(@image)}
            class={@image_class || "h-[140px] md:h-[262px] w-full"}
            src={@image}
            alt={@alt}
          />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
      <div class="mock-darker-base relative mx-auto rounded-b-xl h-[24px] max-w-[301px] md:h-[42px] md:max-w-[512px]">
      </div>
      <div class="mock-base relative mx-auto rounded-b-xl h-[55px] max-w-[83px] md:h-[95px] md:max-w-[142px]">
      </div>
    </div>
    """
  end

  def device_mockup(assigns) do
    ~H"""
    <div class={["w-fit", color_class(@color), @class]}>
      <div class="mock-base relative mx-auto border-[14px] rounded-[2.5rem] h-[600px] w-[300px] shadow-xl">
        <div class="mock-base w-[148px] h-[18px] top-0 rounded-b-[1rem] left-1/2 -translate-x-1/2 absolute">
        </div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[124px] rounded-s-lg"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[178px] rounded-s-lg"></div>
        <div class="mock-base h-[64px] w-[3px] absolute -end-[17px] top-[142px] rounded-e-lg"></div>
        <div class="bg-white rounded-3xl overflow-hidden w-[272px] h-[572px]">
          <MishkaChelekom.Image.image
            :if={!is_nil(@image)}
            class={@image_class || "w-[272px] h-[572px]"}
            src={@image}
            alt={@alt}
          />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  defp color_class("white") do
    "[&_.mock-base]:bg-white [&_.mock-darker-base]:bg-[#f5f5f5] [&_.mock-base]:border-[#f5f5f5]"
  end

  defp color_class("silver") do
    "[&_.mock-base]:bg-[#BFBFC1] [&_.mock-darker-base]:bg-[#959595] [&_.mock-base]:border-[#959595]"
  end

  defp color_class("primary") do
    "[&_.mock-base]:bg-[#576cde] [&_.mock-darker-base]:bg-[#2441de] [&_.mock-base]:border-[#2441de]"
  end

  defp color_class("secondary") do
    "[&_.mock-base]:bg-[#878CA9] [&_.mock-darker-base]:bg-[#3D404C] [&_.mock-base]:border-[#3D404C]"
  end

  defp color_class("success") do
    "[&_.mock-base]:bg-[#bce8cd] [&_.mock-darker-base]:bg-[#6EE7B7] [&_.mock-base]:border-[#6EE7B7]"
  end

  defp color_class("warning") do
    "[&_.mock-base]:bg-[#e3be94] [&_.mock-darker-base]:bg-[#FF8B08] [&_.mock-base]:border-[#FF8B08]"
  end

  defp color_class("danger") do
    "[&_.mock-base]:bg-[#e68c8c] [&_.mock-darker-base]:bg-[#d44e4e] [&_.mock-base]:border-[#d44e4e]"
  end

  defp color_class("info") do
    "[&_.mock-base]:bg-[#799dd4] [&_.mock-darker-base]:bg-[#004FC4] [&_.mock-base]:border-[#004FC4]"
  end

  defp color_class("misc") do
    "[&_.mock-base]:bg-[#a574d4] [&_.mock-darker-base]:bg-[#52059C] [&_.mock-base]:border-[#52059C]"
  end

  defp color_class("dawn") do
    "[&_.mock-base]:bg-[#bda28c] [&_.mock-darker-base]:bg-[#4D4137] [&_.mock-base]:border-[#4D4137]"
  end

  defp color_class("light") do
    "[&_.mock-base]:bg-[#a8abba] [&_.mock-darker-base]:bg-[#707483] [&_.mock-base]:border-[#707483]"
  end

  defp color_class("dark") do
    "[&_.mock-base]:bg-[#454545] [&_.mock-darker-base]:bg-[#1E1E1E] [&_.mock-base]:border-[#1E1E1E]"
  end
end
