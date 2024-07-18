defmodule MishkaChelekom.Button do
  use Phoenix.Component
  import MishkaChelekomComponents

  @sizes [:extra_small, :small, :medium, :large, :extra_large]
  @variants [:default, :outline, :transparent, :subtle, :shadow]
  @colors [:white, :primary, :secondary, :dark]

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
        "py-2 px-4 font-normal",
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
  end

  defp color_variant(:default, :secondary) do
  end

  defp color_variant(:default, :dark) do
  end

  defp color_variant(:outline, :white) do
  end

  defp color_variant(:outline, :primary) do
  end

  defp color_variant(:outline, :secondary) do
  end

  defp color_variant(:outline, :dark) do
  end

  defp color_variant(:transparent, :white) do
  end

  defp color_variant(:transparent, :primary) do
  end

  defp color_variant(:transparent, :secondary) do
  end

  defp color_variant(:transparent, :dark) do
  end

  defp color_variant(:outline, :dark) do
  end

  defp color_variant(:subtle, :white) do
  end

  defp color_variant(:subtle, :primary) do
  end

  defp color_variant(:subtle, :secondary) do
  end

  defp color_variant(:subtle, :dark) do
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
