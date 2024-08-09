defmodule MishkaChelekom.Alert do
  use Phoenix.Component
  import MishkaChelekomComponents
  import MishkaChelekomWeb.Gettext
  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-2 right-2 mr-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" /> <%= @title %>
      </p>

      <p class="mt-2 text-sm leading-5"><%= msg %></p>

      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
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


  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] [&>.indicator]:bg-[#3E3E3E] hover:bg-[#E8E8E8] hover:border-[#d9d9d9]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#2441de] [&>.indicator]:bg-white hover:bg-[#072ed3] hover:border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C] [&>.indicator]:bg-white hover:bg-[#60636f] hover:border-[#3d3f49]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7] [&>.indicator]:bg-[#047857] hover:bg-[#d4fde4] hover:border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08] [&>.indicator]:bg-[#FF8B08] hover:bg-[#fff1cd] hover:border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B] [&>.indicator]:bg-[#E73B3B] hover:bg-[#ffcdcd] hover:border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4] [&>.indicator]:bg-[#004FC4] hover:bg-[#cce1ff] hover:border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C] [&>.indicator]:bg-[#52059C] hover:bg-[#ffe0ff] hover:border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137] [&>.indicator]:bg-[#4D4137] hover:bg-[#ffdfc1] hover:border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483] [&>.indicator]:bg-[#707483] hover:bg-[#d2d8e9] hover:border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#050404] [&>.indicator]:bg-white hover:bg-[#111111] hover:border-[#050404]"
  end
  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white [&>.indicator]:bg-white hover:text-[#E8E8E8] hover:border-[#E8E8E8]"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] [&>.indicator]:bg-[#4363EC] hover:text-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C] [&>.indicator]:bg-[#6B6E7C] hover:text-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#6EE7B7] [&>.indicator]:bg-[#227A52] hover:text-[#50AF7A] hover:border-[#50AF7A]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08] [&>.indicator]:bg-[#FF8B08] hover:text-[#FFB045] hover:border-[#FFB045]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B] [&>.indicator]:bg-[#E73B3B] hover:text-[#F0756A] hover:border-[#F0756A]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4] [&>.indicator]:bg-[#004FC4] hover:text-[#3680DB] hover:border-[#3680DB]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C] [&>.indicator]:bg-[#52059C] hover:text-[#8535C3] hover:border-[#8535C3]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137] [&>.indicator]:bg-[#4D4137] hover:text-[#948474] hover:border-[#948474]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483] [&>.indicator]:bg-[#707483] hover:text-[#A0A5B4] hover:border-[#A0A5B4]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E] [&>.indicator]:bg-[#1E1E1E] hover:text-[#787878] hover:border-[#787878]"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E] border-transparent [&>.indicator]:bg-[#3E3E3E] hover:bg-[#E8E8E8]"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white border-transparent [&>.indicator]:bg-white hover:bg-[#072ed3]"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white border-transparent [&>.indicator]:bg-white hover:bg-[#60636f]"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent [&>.indicator]:bg-[#047857] hover:bg-[#d4fde4]"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent [&>.indicator]:bg-[#FF8B08] hover:bg-[#fff1cd]"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent [&>.indicator]:bg-[#E73B3B] hover:bg-[#ffcdcd]"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-transparent [&>.indicator]:bg-[#004FC4] hover:bg-[#cce1ff]"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-transparent [&>.indicator]:bg-[#52059C] hover:bg-[#ffe0ff]"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-transparent [&>.indicator]:bg-[#4D4137] hover:bg-[#ffdfc1]"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483] border-transparent [&>.indicator]:bg-[#707483] hover:bg-[#d2d8e9]"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white border-transparent [&>.indicator]:bg-white hover:bg-[#111111]"
  end
  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow [&>.indicator]:bg-[#3E3E3E] hover:bg-[#E8E8E8] hover:border-[#d9d9d9]"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow [&>.indicator]:bg-white hover:bg-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow [&>.indicator]:bg-white hover:bg-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow [&>.indicator]:bg-[#227A52] hover:bg-[#d4fde4] hover:border-[#d4fde4]"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow [&>.indicator]:bg-[#FF8B08] hover:bg-[#fff1cd] hover:border-[#fff1cd]"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow [&>.indicator]:bg-[#E73B3B] hover:bg-[#ffcdcd] hover:border-[#ffcdcd]"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow [&>.indicator]:bg-[#004FC4] hover:bg-[#cce1ff] hover:border-[#cce1ff]"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow [&>.indicator]:bg-[#52059C] hover:bg-[#ffe0ff] hover:border-[#ffe0ff]"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow [&>.indicator]:bg-[#4D4137] hover:bg-[#ffdfc1] hover:border-[#ffdfc1]"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow [&>.indicator]:bg-[#707483] hover:bg-[#d2d8e9] hover:border-[#d2d8e9]"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow [&>.indicator]:bg-white hover:bg-[#111111] hover:border-[#050404]"
  end

end
