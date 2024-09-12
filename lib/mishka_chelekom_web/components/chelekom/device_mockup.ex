defmodule MishkaChelekom.DeviceMockup do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, default: "silver", doc: ""
  attr :alt, :string, default: nil, doc: ""
  attr :image, :string, default: nil, doc: ""
  attr :image_class, :string, default: nil, doc: ""
  attr :rest, :global, include: ~w(android watch laptop iphone ipad imac), doc: ""
  slot :inner_block, doc: ""

  def device_mockup(%{rest: %{watch: true}} = assigns) do
    ~H"""
    <div class={[
      "w-fit",
      color_class(@color),
      @class
    ]}>
      <div class="mock-base relative mx-auto rounded-t-[2.5rem] h-[63px] max-w-[133px]"></div>
      <div class="mock-base relative mx-auto border-[10px] rounded-[2.5rem] h-[213px] w-[208px]">
        <div class="mock-base h-[41px] w-[6px] absolute -end-[16px] top-[40px] rounded-e-lg"></div>
        <div class="mock-base h-[32px] w-[6px] absolute -end-[16px] top-[88px] rounded-e-lg"></div>
        <div class="bg-[#1e1e1e] rounded-[2rem] overflow-hidden h-[193px] w-[188px]">
          <MishkaChelekom.Image.image :if={!is_nil(@image)} class={@image_class} src={@image} alt={@alt} />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
      <div class="mock-base relative mx-auto rounded-b-[2.5rem] h-[63px] max-w-[133px]"></div>
    </div>
    """
  end

  def device_mockup(%{rest: %{android: true}} = assigns) do
    ~H"""
     <div class={[
      "w-fit",
      color_class(@color),
      @class
    ]}>
      <div class="mock-base relative mx-auto border-[14px] rounded-xl h-[600px] w-[300px] shadow-xl">
        <div class="mock-base w-[148px] h-[18px] top-0 rounded-b-[1rem] left-1/2 -translate-x-1/2 absolute"></div>
        <div class="mock-base h-[32px] w-[3px] absolute -start-[17px] top-[72px] rounded-s-lg"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[124px] rounded-s-lg"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[178px] rounded-s-lg"></div>
        <div class="mock-base h-[64px] w-[3px] absolute -end-[17px] top-[142px] rounded-e-lg"></div>
        <div class="rounded-xl overflow-hidden w-[272px] h-[572px] bg-[#1e1e1e]">
          <MishkaChelekom.Image.image :if={!is_nil(@image)} class={@image_class} src={@image} alt={@alt} />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  def device_mockup(%{rest: %{laptop: true}} = assigns) do
    ~H"""
     <div class={[
      "w-fit",
      color_class(@color),
      @class
    ]}>
      <div class="mock-base relative mx-auto border-[8px] rounded-t-xl h-[172px] max-w-[301px] md:h-[294px] md:max-w-[512px]">
        <div class="rounded-lg overflow-hidden h-[156px] md:h-[278px] bg-[#1e1e1e]">
          <MishkaChelekom.Image.image :if={!is_nil(@image)} class={@image_class} src={@image} alt={@alt} />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
      <div class="mock-base relative mx-auto rounded-b-xl rounded-t-sm h-[17px] max-w-[351px] md:h-[21px] md:max-w-[597px]">
        <div class="mock-base absolute left-1/2 top-0 -translate-x-1/2 rounded-b-xl w-[56px] h-[5px] md:w-[96px] md:h-[8px]"></div>
      </div>
    </div>
    """
  end

  def device_mockup(%{rest: %{ipad: true}} = assigns) do
    ~H"""
    <div class={[
      "w-fit",
      color_class(@color),
      @class
    ]}>
      <div class="mock-base relative mx-auto border-[14px] rounded-[2.5rem] h-[454px] max-w-[341px] md:h-[682px] md:max-w-[512px]">
        <div class="mock-base h-[32px] w-[3px] absolute -start-[17px] top-[72px] rounded-s-lg"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[124px] rounded-s-lg"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[178px] rounded-s-lg"></div>
        <div class="mock-base h-[64px] w-[3px] absolute -end-[17px] top-[142px] rounded-e-lg"></div>
        <div class="bg-[#1e1e1e] rounded-[2rem] overflow-hidden h-[426px] md:h-[654px]">
          <MishkaChelekom.Image.image :if={!is_nil(@image)} class={@image_class} src={@image} alt={@alt} />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  def device_mockup(%{rest: %{imac: true}} = assigns) do
    ~H"""
     <div class={[
      "w-fit",
      color_class(@color),
      @class
    ]}>
      <div class="mock-base relative mx-auto border-[16px] rounded-t-xl h-[172px] max-w-[301px] md:h-[294px] md:max-w-[512px]">
          <div class="rounded-xl overflow-hidden h-[140px] md:h-[262px]">
          <MishkaChelekom.Image.image :if={!is_nil(@image)} class={@image_class} src={@image} alt={@alt} />
          <%= render_slot(@inner_block) %>
          </div>
      </div>
      <div class="mock-base relative mx-auto rounded-b-xl h-[24px] max-w-[301px] md:h-[42px] md:max-w-[512px]"></div>
      <div class="mock-base relative mx-auto rounded-b-xl h-[55px] max-w-[83px] md:h-[95px] md:max-w-[142px]"></div>
    </div>
    """
  end

  def device_mockup(assigns) do
    ~H"""
     <div class={[
      "w-fit",
      color_class(@color),
      @class
    ]}>
      <div class="mock-base relative mx-auto border-[14px] rounded-[2.5rem] h-[600px] w-[300px] shadow-xl">
        <div class="mock-base w-[148px] h-[18px] top-0 rounded-b-[1rem] left-1/2 -translate-x-1/2 absolute"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[124px] rounded-s-lg"></div>
        <div class="mock-base h-[46px] w-[3px] absolute -start-[17px] top-[178px] rounded-s-lg"></div>
        <div class="mock-base h-[64px] w-[3px] absolute -end-[17px] top-[142px] rounded-e-lg"></div>
        <div class="rounded-[2rem] overflow-hidden w-[272px] h-[572px]">
          <MishkaChelekom.Image.image :if={!is_nil(@image)} class={@image_class} src={@image} alt={@alt} />
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  defp color_class("white") do
    "[&_.mock-base]:bg-white [&_.mock-base]:border-[#f5f5f5]"
  end

  defp color_class("silver") do
    "[&_.mock-base]:bg-[#BFBFC1] [&_.mock-base]:border-[#959595]"
  end

  defp color_class("primary") do
    "[&_.mock-base]:bg-[#4363EC] [&_.mock-base]:border-[#2441de]"
  end

  defp color_class("secondary") do
    "[&_.mock-base]:bg-[#605B55] [&_.mock-base]:border-[#3A3730]"
  end

  defp color_class("success") do
    "[&_.mock-base]:bg-[#ECFEF3] [&_.mock-base]:border-[#6EE7B7]"
  end

  defp color_class("warning") do
    "[&_.mock-base]:bg-[#FFF8E6] [&_.mock-base]:border-[#FF8B08]"
  end

  defp color_class("danger") do
    "[&_.mock-base]:bg-[#FFE6E6] [&_.mock-base]:border-[#E73B3B]"
  end

  defp color_class("info") do
    "[&_.mock-base]:bg-[#E5F0FF] [&_.mock-base]:border-[#004FC4]"
  end

  defp color_class("misc") do
    "[&_.mock-base]:bg-[#FFE6FF] [&_.mock-base]:border-[#52059C]"
  end

  defp color_class("dawn") do
    "[&_.mock-base]:bg-[#FFECDA] [&_.mock-base]:border-[#4D4137]"
  end

  defp color_class("light") do
    "[&_.mock-base]:bg-[#E3E7F1] [&_.mock-base]:border-[#707483]"
  end

  defp color_class("dark") do
    "[&_.mock-base]:bg-[#1E1E1E] [&_.mock-base]:border-[#050404]"
  end
end
