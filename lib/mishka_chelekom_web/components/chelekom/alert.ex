defmodule MishkaChelekom.Alert do
  use Phoenix.Component
  import MishkaChelekomComponents
  import MishkaChelekomWeb.Gettext
  alias Phoenix.LiveView.JS

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @variants [
    "default",
    "outline",
    "shadow",
    "unbordered"
  ]

  @positions [
    "top_left",
    "top_right",
    "bottom_left",
    "bottom_right"
  ]

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil

  attr :kind, :atom,
    values: [
      :info,
      :danger,
      :success,
      :white,
      :primary,
      :secondary,
      :misc,
      :warning,
      :dark,
      :light,
      :dawn
    ],
    doc: "used for styling and flash lookup"

  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :position, :string, values: @positions ++ [nil], default: nil, doc: ""
  attr :width, :string, default: "medium", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "small", doc: ""

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)
    IO.inspect(Phoenix.Flash.get(assigns.flash, assigns.kind), label: "-==-=-=-=>")
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "z-50 px-2 py-1.5",
        color_variant(@variant, @kind),
        rounded_size(@rounded),
        width_class(@width),
        position_class(@position)
      ]}
      {@rest}
    >
      <div class="flex items-center justify-between gap-2">
        <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
          <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
          <.icon :if={@kind == :danger} name="hero-exclamation-circle-mini" class="h-4 w-4" /> <%= @title %>
        </p>

        <p class="mt-2 text-sm leading-5"><%= msg %></p>

        <button type="button" class="group p-2" aria-label={gettext("close")}>
          <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        <%= gettext("Attempting to reconnect") %>
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        <%= gettext("Hang in there while we get back on track") %>
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size("none"), do: "rounded-none"

  defp width_class("extra_small"), do: "w-60"
  defp width_class("small"), do: "w-64"
  defp width_class("medium"), do: "w-72"
  defp width_class("large"), do: "w-80"
  defp width_class("extra_large"), do: "w-96"
  defp width_class("full"), do: "w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("medium")

  defp position_class("top_left"), do: "fixed top-2 left-0 ml-2"
  defp position_class("top_right"), do: "fixed top-2 right-0 mr-2"
  defp position_class("bottom_left"), do: "fixed bottom-2 left-0 ml-2"
  defp position_class("bottom_right"), do: "fixed bottom-2 right-0 mr-2"
  defp position_class(params) when is_binary(params), do: params
  defp position_class(nil), do: nil

  defp color_variant("default", :white) do
    "bg-white text-[#3E3E3E] border border-[#DADADA] hover:[&>button]:text-[#787878]"
  end

  defp color_variant("default", :primary) do
    "bg-[#4363EC] text-white border border-[#2441de] hover:[&>button]:text-[#072ed3]"
  end

  defp color_variant("default", :secondary) do
    "bg-[#6B6E7C] text-white border border-[#877C7C] hover:[&>button]:text-[#60636f]"
  end

  defp color_variant("default", :success) do
    "bg-[#ECFEF3] text-[#047857] border border-[#6EE7B7] hover:[&>button]:text-[#50AF7A]"
  end

  defp color_variant("default", :warning) do
    "bg-[#FFF8E6] text-[#FF8B08] border border-[#FF8B08] hover:[&>button]:text-[#FFB045]"
  end

  defp color_variant("default", :danger) do
    "bg-[#FFE6E6] text-[#E73B3B] border border-[#E73B3B] hover:[&>button]:text-[#F0756A]"
  end

  defp color_variant("default", :info) do
    "bg-[#E5F0FF] text-[#004FC4] border border-[#004FC4] hover:[&>button]:text-[#3680DB]"
  end

  defp color_variant("default", :misc) do
    "bg-[#FFE6FF] text-[#52059C] border border-[#52059C] hover:[&>button]:text-[#8535C3]"
  end

  defp color_variant("default", :dawn) do
    "bg-[#FFECDA] text-[#4D4137] border border-[#4D4137] hover:[&>button]:text-[#948474]"
  end

  defp color_variant("default", :light) do
    "bg-[#E3E7F1] text-[#707483] border border-[#707483] hover:[&>button]:text-[#A0A5B4]"
  end

  defp color_variant("default", :dark) do
    "bg-[#1E1E1E] text-white border border-[#050404] hover:[&>button]:text-[#787878]"
  end

  defp color_variant("outline", :white) do
    "bg-white text-white border border-white hover:[&>button]:text-[#787878]"
  end

  defp color_variant("outline", :primary) do
    "bg-white text-[#4363EC] border border-[#4363EC] hover:[&>button]:text-[#072ed3] "
  end

  defp color_variant("outline", :secondary) do
    "bg-white text-[#6B6E7C] border border-[#6B6E7C] hover:[&>button]:text-[#60636f]"
  end

  defp color_variant("outline", :success) do
    "bg-white text-[#227A52] border border-[#6EE7B7] hover:[&>button]:text-[#50AF7A]"
  end

  defp color_variant("outline", :warning) do
    "bg-white text-[#FF8B08] border border-[#FF8B08] hover:[&>button]:text-[#FFB045]"
  end

  defp color_variant("outline", :danger) do
    "bg-white text-[#E73B3B] border border-[#E73B3B] hover:[&>button]:text-[#F0756A]"
  end

  defp color_variant("outline", :info) do
    "bg-white text-[#004FC4] border border-[#004FC4] hover:[&>button]:text-[#3680DB]"
  end

  defp color_variant("outline", :misc) do
    "bg-white text-[#52059C] border border-[#52059C] hover:[&>button]:text-[#8535C3]"
  end

  defp color_variant("outline", "dawn") do
    "bg-white text-[#4D4137] border border-[#4D4137] hover:[&>button]:text-[#FFECDA]"
  end

  defp color_variant("outline", :light) do
    "bg-white text-[#707483] border border-[#707483] hover:[&>button]:text-[#A0A5B4]"
  end

  defp color_variant("outline", :dark) do
    "bg-white text-[#1E1E1E] border border-[#1E1E1E] hover:[&>button]:text-[#787878]"
  end

  defp color_variant("unbordered", :white) do
    "bg-white text-[#3E3E3E] border border-transparent hover:[&>button]:text-[#787878]"
  end

  defp color_variant("unbordered", :primary) do
    "bg-[#4363EC] text-white border border-transparent hover:[&>button]:text-[#072ed3]"
  end

  defp color_variant("unbordered", :secondary) do
    "bg-[#6B6E7C] text-white border border-transparent hover:[&>button]:text-[#60636f]"
  end

  defp color_variant("unbordered", :success) do
    "bg-[#ECFEF3] text-[#047857] border border-transparent hover:[&>button]:text-[#50AF7A]"
  end

  defp color_variant("unbordered", :warning) do
    "bg-[#FFF8E6] text-[#FF8B08] border border-transparent hover:[&>button]:text-[#FFB045]"
  end

  defp color_variant("unbordered", :danger) do
    "bg-[#FFE6E6] text-[#E73B3B] border border-transparent hover:[&>button]:text-[#F0756A]"
  end

  defp color_variant("unbordered", :info) do
    "bg-[#E5F0FF] text-[#004FC4] border border-transparent hover:[&>button]:text-[#3680DB]"
  end

  defp color_variant("unbordered", :misc) do
    "bg-[#FFE6FF] text-[#52059C] border border-transparent hover:[&>button]:text-[#8535C3]"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border border-transparent hover:[&>button]:text-[#FFECDA]"
  end

  defp color_variant("unbordered", :light) do
    "bg-[#E3E7F1] text-[#707483] border border-transparent hover:[&>button]:text-[#A0A5B4]"
  end

  defp color_variant("unbordered", :dark) do
    "bg-[#1E1E1E] text-white border border-transparent hover:[&>button]:text-[#787878]"
  end

  defp color_variant("transparent", :white) do
    "bg-white text-white border border-transparent hover:[&>button]:text-[#787878]"
  end

  defp color_variant("transparent", :primary) do
    "bg-white text-[#4363EC] border border-transparent hover:[&>button]:text-[#072ed3]"
  end

  defp color_variant("transparent", :secondary) do
    "bg-white text-[#6B6E7C] border border-transparent hover:[&>button]:text-[#60636f]"
  end

  defp color_variant("transparent", :success) do
    "bg-white text-[#227A52] border border-transparent hover:[&>button]:text-[#50AF7A]"
  end

  defp color_variant("transparent", :warning) do
    "bg-white text-[#FF8B08] border border-transparent hover:[&>button]:text-[#FFB045]"
  end

  defp color_variant("transparent", :danger) do
    "bg-white text-[#E73B3B] border border-transparent hover:[&>button]:text-[#F0756A]"
  end

  defp color_variant("transparent", :info) do
    "bg-white text-[#6663FD] border border-transparent hover:[&>button]:text-[#3680DB]"
  end

  defp color_variant("transparent", :misc) do
    "bg-white text-[#52059C] border border-transparent hover:[&>button]:text-[#8535C3]"
  end

  defp color_variant("transparent", "dawn") do
    "bg-white text-[#4D4137] border border-transparent hover:[&>button]:text-[#FFECDA]"
  end

  defp color_variant("transparent", :light) do
    "bg-white text-[#707483] border border-transparent hover:[&>button]:text-[#A0A5B4]"
  end

  defp color_variant("transparent", :dark) do
    "bg-white text-[#1E1E1E] border border-transparent hover:[&>button]:text-[#787878]"
  end

  defp color_variant("shadow", :white) do
    "bg-white text-[#3E3E3E] border border-[#DADADA] shadow hover:[&>button]:text-[#787878]"
  end

  defp color_variant("shadow", :primary) do
    "bg-[#4363EC] text-white border border-[#4363EC] shadow hover:[&>button]:text-[#072ed3]"
  end

  defp color_variant("shadow", :secondary) do
    "bg-[#6B6E7C] text-white border border-[#6B6E7C] shadow hover:[&>button]:text-[#60636f]"
  end

  defp color_variant("shadow", :success) do
    "bg-[#AFEAD0] text-[#227A52] border border-[#AFEAD0] shadow hover:[&>button]:text-[#50AF7A]"
  end

  defp color_variant("shadow", :warning) do
    "bg-[#FFF8E6] text-[#FF8B08] border border-[#FFF8E6] shadow hover:[&>button]:text-[#FFB045]"
  end

  defp color_variant("shadow", :danger) do
    "bg-[#FFE6E6] text-[#E73B3B] border border-[#FFE6E6] shadow hover:[&>button]:text-[#F0756A]"
  end

  defp color_variant("shadow", :info) do
    "bg-[#E5F0FF] text-[#004FC4] border border-[#E5F0FF] shadow hover:[&>button]:text-[#3680DB]"
  end

  defp color_variant("shadow", :misc) do
    "bg-[#FFE6FF] text-[#52059C] border border-[#FFE6FF] shadow hover:[&>button]:text-[#8535C3]"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border border-[#FFECDA] shadow hover:[&>button]:text-[#FFECDA]"
  end

  defp color_variant("shadow", :light) do
    "bg-[#E3E7F1] text-[#707483] border border-[#E3E7F1] shadow hover:[&>button]:text-[#A0A5B4]"
  end

  defp color_variant("shadow", :dark) do
    "bg-[#1E1E1E] text-white border border-[#1E1E1E] shadow hover:[&>button]:text-[#787878]"
  end
end
