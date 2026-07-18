defmodule DevelopmentWeb.Showcase.ColorPickerFormDemo do
  @moduledoc """
  Interactive `color_picker` inside a Phoenix `<.form>`: the picker's `on_change` pushes the live hex
  to the server (`handle_event "pick"`), the hidden input submits it as `picker_demo[color]`, and
  `Save` echoes the submitted value. Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.ColorPicker

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:color, fn -> "#8b5cf6" end)
     |> assign_new(:saved, fn -> nil end)}
  end

  @impl true
  def handle_event("pick", %{"value" => hex}, socket) do
    {:noreply, assign(socket, color: hex)}
  end

  def handle_event("save", %{"picker_demo" => %{"color" => color}}, socket) do
    {:noreply, assign(socket, saved: color)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={to_form(%{"color" => @color}, as: :picker_demo)}
        phx-target={@myself}
        phx-submit="save"
      >
        <.color_picker
          id={"#{@id}-picker"}
          name="picker_demo[color]"
          value={@color}
          on_change="pick"
          class={pc()}
        />
        <div class="mt-3 flex items-center gap-3">
          <span
            class="inline-block size-6 rounded-full ring-1 ring-black/10"
            style={"background-color: #{@color}"}
          >
          </span>
          <code class="text-sm">{@color}</code>
          <button
            type="submit"
            class="rounded-md bg-[var(--c-primary)] px-3 py-1.5 text-sm font-medium text-primary-content"
          >
            Save
          </button>
        </div>
      </.form>
      <p :if={@saved} class="mt-2 text-sm font-medium text-[var(--c-success)]">
        ✓ Saved {@saved} — submitted as <code>picker_demo[color]</code>
      </p>
    </div>
    """
  end

  defp pc do
    [
      "w-56 space-y-3",
      "[&_[data-part=area]]:relative [&_[data-part=area]]:h-36 [&_[data-part=area]]:w-full [&_[data-part=area]]:cursor-crosshair [&_[data-part=area]]:rounded-lg [&_[data-part=area]]:ring-1 [&_[data-part=area]]:ring-black/10",
      "[&_[data-part=area-thumb]]:size-3.5 [&_[data-part=area-thumb]]:rounded-full [&_[data-part=area-thumb]]:border-2 [&_[data-part=area-thumb]]:border-white [&_[data-part=area-thumb]]:shadow [&_[data-part=area-thumb]]:ring-1 [&_[data-part=area-thumb]]:ring-black/30",
      "[&_[data-part=controls]]:flex [&_[data-part=controls]]:items-center [&_[data-part=controls]]:gap-3",
      "[&_[data-part=preview]]:size-8 [&_[data-part=preview]]:shrink-0 [&_[data-part=preview]]:rounded-full [&_[data-part=preview]]:ring-1 [&_[data-part=preview]]:ring-black/10",
      "[&_[data-part=hue]]:h-3 [&_[data-part=hue]]:w-full [&_[data-part=hue]]:cursor-pointer [&_[data-part=hue]]:appearance-none [&_[data-part=hue]]:rounded-full [&_[data-part=hue]]:[background:linear-gradient(to_right,#f00,#ff0,#0f0,#0ff,#00f,#f0f,#f00)]"
    ]
  end
end
