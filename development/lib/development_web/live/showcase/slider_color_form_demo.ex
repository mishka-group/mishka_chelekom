defmodule DevelopmentWeb.Showcase.SliderColorFormDemo do
  @moduledoc """
  Interactive `hue_slider` / `alpha_slider` inside a Phoenix `<.form>` (one module, `variant` picks
  which). The slider's `on_change` pushes the live value to the server (`handle_event "change"`), the
  hidden input submits it as `slider_demo[v]`, and `Save` echoes the submitted value. Not persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.HueSlider
  import DevelopmentWeb.Components.Headless.AlphaSlider

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:value, fn -> if assigns.variant == :hue, do: 200, else: 60 end)
     |> assign_new(:saved, fn -> nil end)}
  end

  @impl true
  def handle_event("change", %{"value" => v}, socket) do
    {:noreply, assign(socket, value: v)}
  end

  def handle_event("save", %{"slider_demo" => %{"v" => v}}, socket) do
    {:noreply, assign(socket, saved: v)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-xs">
      <.form
        for={to_form(%{"v" => @value}, as: :slider_demo)}
        phx-target={@myself}
        phx-submit="save"
      >
        <.hue_slider
          :if={@variant == :hue}
          id={"#{@id}-hue"}
          name="slider_demo[v]"
          value={@value}
          on_change="change"
          class={hue_class()}
        />
        <.alpha_slider
          :if={@variant == :alpha}
          id={"#{@id}-alpha"}
          name="slider_demo[v]"
          value={@value}
          color="#6d28d9"
          on_change="change"
          class={alpha_class()}
        />
        <div class="mt-3 flex items-center gap-3">
          <span
            class="inline-block size-6 rounded-full ring-1 ring-black/10"
            style={swatch_style(@variant, @value)}
          >
          </span>
          <code class="text-sm">{@value}{(@variant == :alpha && "%") || "°"}</code>
          <button
            type="submit"
            class="rounded-md bg-[var(--c-primary)] px-3 py-1.5 text-sm font-medium text-primary-content"
          >
            Save
          </button>
        </div>
      </.form>
      <p :if={@saved} class="mt-2 text-sm font-medium text-[var(--c-success)]">
        ✓ Saved {@saved} — submitted as <code>slider_demo[v]</code>
      </p>
    </div>
    """
  end

  defp swatch_style(:hue, v), do: "background-color: hsl(#{v}, 90%, 50%)"
  defp swatch_style(:alpha, v), do: "background-color: rgba(109, 40, 217, #{(v || 0) / 100})"

  defp hue_class do
    [
      "block w-full",
      "[&_[data-part=control]]:relative [&_[data-part=control]]:flex [&_[data-part=control]]:h-4 [&_[data-part=control]]:cursor-pointer [&_[data-part=control]]:items-center",
      "[&_[data-part=track]]:relative [&_[data-part=track]]:h-3 [&_[data-part=track]]:w-full [&_[data-part=track]]:rounded-full [&_[data-part=track]]:[background:linear-gradient(to_right,#f00,#ff0,#0f0,#0ff,#00f,#f0f,#f00)]",
      "[&_[data-part=indicator]]:hidden",
      "[&_[data-part=thumb]]:size-4 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:border-2 [&_[data-part=thumb]]:border-white [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:ring-1 [&_[data-part=thumb]]:ring-black/30 [&_[data-part=thumb]]:outline-none"
    ]
  end

  defp alpha_class do
    [
      "block w-full",
      "[&_[data-part=control]]:relative [&_[data-part=control]]:flex [&_[data-part=control]]:h-4 [&_[data-part=control]]:cursor-pointer [&_[data-part=control]]:items-center",
      "[&_[data-part=track]]:relative [&_[data-part=track]]:h-3 [&_[data-part=track]]:w-full [&_[data-part=track]]:overflow-hidden [&_[data-part=track]]:rounded-full [&_[data-part=track]]:[background-image:linear-gradient(to_right,transparent,var(--chelekom-alpha-color)),conic-gradient(#ccc_25%,#fff_0_50%,#ccc_0_75%,#fff_0)] [&_[data-part=track]]:[background-size:100%_100%,10px_10px]",
      "[&_[data-part=indicator]]:hidden",
      "[&_[data-part=thumb]]:size-4 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:border-2 [&_[data-part=thumb]]:border-white [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:ring-1 [&_[data-part=thumb]]:ring-black/30 [&_[data-part=thumb]]:outline-none"
    ]
  end
end
