defmodule MishkaChelekom.Sidebar do
  use Phoenix.Component
  import MishkaChelekomComponents
  import MishkaChelekomWeb.Gettext
  alias Phoenix.LiveView.JS

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

  @variants [
    "default",
    "outline",
    "transparent",
    "shadow",
    "unbordered"
  ]

  @doc type: :component
  attr :id, :string, required: true, doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :rounded, :string, default: nil, doc: ""
  attr :position, :string, default: "start", doc: ""
  attr :hide_position, :string, default: nil, doc: ""
  attr :space, :string, default: nil, doc: ""
  attr :padding, :string, default: "none", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :on_hide, JS, default: %JS{}
  attr :on_show, JS, default: %JS{}
  attr :on_hide_away, JS, default: %JS{}
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  @spec sidebar(map()) :: Phoenix.LiveView.Rendered.t()
  def sidebar(assigns) do
    ~H"""
    <aside
      id={@id}
      phx-click-away={hide_sidebar(@on_hide_away, @id, @hide_position)}
      phx-remove={hide_sidebar(@id, @hide_position)}
      class={[
        "fixed h-screen transition-transform",
        border_class(@border, @position),
        hide_position(@hide_position),
        color_variant(@variant, @color),
        position_class(@position),
        size_class(@size),
        @class
      ]}
      aria-label="Sidebar"
      {@rest}
    >
      <div class="h-full overflow-y-auto">
        <div class="flex justify-end pt-2 px-2 mb-1 md:hidden">
          <button type="button" phx-click={JS.exec(@on_hide, "phx-remove", to: "##{@id}")}>
            <.icon name="hero-x-mark" />
            <span class="sr-only"><%= gettext("Close menu") %></span>
          </button>
        </div>
        <%= render_slot(@inner_block) %>
      </div>
    </aside>
    """
  end

  def show_sidebar(js \\ %JS{}, id, position) when is_binary(id) do
    JS.remove_class(js, hide_position(position), to: "##{id}")
    |> JS.add_class("transform-none", to: "##{id}")
  end

  def hide_sidebar(js \\ %JS{}, id, position) do
    JS.remove_class(js, "transform-none", to: "##{id}")
    |> JS.add_class(hide_position(position), to: "##{id}")
  end

  defp hide_position("left"), do: "-translate-x-full md:translate-x-0"
  defp hide_position("right"), do: "translate-x-full md:translate-x-0"
  defp hide_position(_), do: nil

  defp position_class("start"), do: "top-0 start-0"
  defp position_class("end"), do: "top-0 end-0"
  defp position_class(params) when is_binary(params), do: params
  defp position_class(_), do: position_class("start")

  defp border_class("none", _), do: "border-0"
  defp border_class("extra_small", "start"), do: "border-e"
  defp border_class("small", "start"), do: "border-e-2"
  defp border_class("medium", "start"), do: "border-e-[3px]"
  defp border_class("large", "start"), do: "border-e-4"
  defp border_class("extra_large", "start"), do: "border-e-[5px]"

  defp border_class("extra_small", "end"), do: "border-s"
  defp border_class("small", "end"), do: "border-s-2"
  defp border_class("medium", "end"), do: "border-s-[3px]"
  defp border_class("large", "end"), do: "border-s-4"
  defp border_class("extra_large", "end"), do: "border-s-[5px]"

  defp border_class(params, _) when is_binary(params), do: params
  defp border_class(_, _), do: border_class("extra_small", "start")

  defp size_class("extra_small"), do: "w-60"
  defp size_class("small"), do: "w-64"
  defp size_class("medium"), do: "w-72"
  defp size_class("large"), do: "w-80"
  defp size_class("extra_large"), do: "w-96"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("large")

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] "
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E]"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E] border-transparent"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white border-transparent"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white border-transparent"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-transparent"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-transparent"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-transparent"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483] border-transparent"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white border-transparent"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow-md"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow-md"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow-md"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow-md"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow-md"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow-md"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow-md"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow-md"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow-md"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow-md"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow-md"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white border-transparent"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC] border-transparent"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52] border-transparent"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD] border-transparent"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C] border-transparent"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483] border-transparent"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent"
  end
end
