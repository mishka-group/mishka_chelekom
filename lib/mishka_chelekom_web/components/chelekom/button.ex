defmodule MishkaChelekom.Button do
  use Phoenix.Component
  import MishkaChelekomComponents

  @sizes [:extra_small, :small, :medium, :large, :extra_large]
  @variants [:default, :outline, :transparent, :subtle, :shadow]
  @colors [:white, :primary, :secondary, :dark, :success, :warning, :danger, :info, :light]

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :id, :string, default: nil, doc: ""
  attr :type, :string, values: ["button", "submit", "reset", nil], default: nil, doc: ""
  attr :variant, :atom, values: @variants, default: :default, doc: ""
  attr :color, :any, values: @colors, default: :white, doc: ""
  attr :rounded, :atom, values: @sizes ++ [:full], default: :large, doc: ""
  attr :size, :atom, values: @sizes ++ [:full_width], default: :large, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :rest, :global, include: ~w(disabled form name value right_icon left_icon), doc: ""
  slot :inner_block, required: true, doc: ""

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      id={@id}
      class={[
        "phx-submit-loading:opacity-75 inline-flex gap-2 items-center justify-center border",
        "py-2 px-4 font-normal transition-all ease-in-ou duration-100",
        "disabled:bg-opacity-60 disabled:border-opacity-60 disabled:cursor-not-allowed",
        "disabled:cursor-not-allowed",
        color_variant(@variant, @color),
        rounded_size(@rounded),
        size_class(@size),
        @class
      ]}
      {@rest}
    >
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
      <%= render_slot(@inner_block) %>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
    </button>
    """
  end

  defp color_variant(:default, :white) do
    "bg-white text-[#3E3E3E] border-[#DADADA]"
  end

  defp color_variant(:default, :primary) do
    "bg-[#4363EC] text-white border-[#4363EC]"
  end

  defp color_variant(:default, :secondary) do
    "bg-[#6B6E7C] text-white border-[#6B6E7C]"
  end

  defp color_variant(:default, :success) do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0]"
  end

  defp color_variant(:default, :warning) do
    "bg-[#FFD69F] text-[#995C0A] border-[#FFD69F]"
  end

  defp color_variant(:default, :danger) do
    "bg-[#FFB2B2] text-[#982525] border-[#FFB2B2]"
  end

  defp color_variant(:default, :info) do
    "bg-[#6663FD] text-[#103483] border-[#6663FD]"
  end

  defp color_variant(:default, :light) do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1]"
  end

  defp color_variant(:default, :dark) do
    "bg-[#1E1E1E] text-white border-[#1E1E1E]"
  end

  defp color_variant(:outline, :white) do
    "bg-transparent text-white border-white"
  end

  defp color_variant(:outline, :primary) do
    "bg-transparent text-[#4363EC] border-[#4363EC]"
  end

  defp color_variant(:outline, :secondary) do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C]"
  end

  defp color_variant(:outline, :success) do
    "bg-transparent text-[#227A52] border-[#227A52]"
  end

  defp color_variant(:outline, :warning) do
    "bg-transparent text-[#995C0A] border-[#995C0A]"
  end

  defp color_variant(:outline, :danger) do
    "bg-transparent text-[#982525] border-[#982525]"
  end

  defp color_variant(:outline, :info) do
    "bg-transparent text-[#6663FD] border-[#6663FD]"
  end

  defp color_variant(:outline, :light) do
    "bg-transparent text-[#707483] border-[#707483]"
  end

  defp color_variant(:outline, :dark) do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E]"
  end

  defp color_variant(:transparent, :white) do
    "bg-transparent text-white border-transparent"
  end

  defp color_variant(:transparent, :primary) do
    "bg-transparent text-[#4363EC] border-transparent"
  end

  defp color_variant(:transparent, :secondary) do
    "bg-transparent text-[#6B6E7C] border--transparent"
  end

  defp color_variant(:transparent, :success) do
    "bg-transparent text-[#227A52] border-transparent"
  end

  defp color_variant(:transparent, :warning) do
    "bg-transparent text-[#995C0A] border-transparent"
  end

  defp color_variant(:transparent, :danger) do
    "bg-transparent text-[#982525] border-transparent"
  end

  defp color_variant(:transparent, :info) do
    "bg-transparent text-[#6663FD] border-transparent"
  end

  defp color_variant(:transparent, :light) do
    "bg-transparent text-[#707483] border-transparent"
  end

  defp color_variant(:transparent, :dark) do
    "bg-transparent text-[#1E1E1E] border-transparent"
  end

  defp color_variant(:subtle, :white) do
    "bg-transparent text-white border-transparent hover:bg-white hover:text-[#3E3E3E]"
  end

  defp color_variant(:subtle, :primary) do
    "bg-transparent text-[#4363EC] border-transparent hover:bg-[#4363EC] hover:text-white"
  end

  defp color_variant(:subtle, :secondary) do
    "bg-transparent text-[#6B6E7C] border--transparent hover:bg-[#6B6E7C] hover:text-white"
  end

  defp color_variant(:subtle, :success) do
    "bg-transparent text-[#227A52] border-transparent hover:bg-[#AFEAD0] hover:text-[#227A52]"
  end

  defp color_variant(:subtle, :warning) do
    "bg-transparent text-[#982525] border-transparent hover:bg-[#FFD69F] hover:text-[#995C0A]"
  end

  defp color_variant(:subtle, :danger) do
    "bg-transparent text-[#FFB2B2] border-transparent hover:bg-[#FFB2B2] hover:text-[#982525]"
  end

  defp color_variant(:subtle, :info) do
    "bg-transparent text-[#6663FD] border-transparent hover:bg-[#6663FD] hover:text-[#103483]"
  end

  defp color_variant(:subtle, :light) do
    "bg-transparent text-[#707483] border-transparent hover:bg-[#E3E7F1] hover:text-[#E3E7F1]"
  end

  defp color_variant(:subtle, :dark) do
    "bg-transparent text-[#1E1E1E] border-transparent hover:bg-[#E3E7F1] hover:text-white"
  end

  defp color_variant(:shadow, :white) do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow shadow-sm"
  end

  defp color_variant(:shadow, :primary) do
    "bg-[#4363EC] text-white border-[#4363EC] shadow shadow-sm"
  end

  defp color_variant(:shadow, :secondary) do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow shadow-sm"
  end

  defp color_variant(:shadow, :success) do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow shadow-sm"
  end

  defp color_variant(:shadow, :warning) do
    "bg-[#FFD69F] text-[#995C0A] border-[#FFD69F] shadow shadow-sm"
  end

  defp color_variant(:shadow, :danger) do
    "bg-[#FFB2B2] text-[#982525] border-[#FFB2B2] shadow shadow-sm"
  end

  defp color_variant(:shadow, :info) do
    "bg-[#6663FD] text-[#103483] border-[#6663FD] shadow shadow-sm"
  end

  defp color_variant(:shadow, :light) do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow shadow-sm"
  end

  defp color_variant(:shadow, :dark) do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow shadow-sm"
  end

  defp color_variant(_, _), do: color_variant(:default, :white)

  defp rounded_size(nil), do: rounded_size(:large)
  defp rounded_size(:extra_small), do: "rounded-sm"
  defp rounded_size(:small), do: "rounded"
  defp rounded_size(:medium), do: "rounded-md"
  defp rounded_size(:large), do: "rounded-lg"
  defp rounded_size(:extra_large), do: "rounded-xl"
  defp rounded_size(:full), do: "rounded-full"
  defp rounded_size(:none), do: "rounded-none"

  defp size_class(nil), do: size_class(:medium)
  defp size_class(:extra_small), do: "py-1 px-2 text-xs"
  defp size_class(:small), do: "py-1.5 px-3 text-sm"
  defp size_class(:medium), do: "py-2 px-4 text-base"
  defp size_class(:large), do: "py-2.5 px-5 text-lg"
  defp size_class(:extra_large), do: "py-3 px-5 text-xl"
  defp size_class(:full_width), do: "py-2 px-4 w-full text-base"

  defp icon_position(nil, _), do: false
  defp icon_position(_icon, %{left_icon: true}), do: "left"
  defp icon_position(_icon, %{right_icon: true}), do: "right"
  defp icon_position(_icon, _), do: "left"
end
