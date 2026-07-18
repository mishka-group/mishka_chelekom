defmodule DevelopmentWeb.Showcase.AngleSliderFormDemo do
  @moduledoc """
  Interactive `angle_slider` inside a Phoenix `<.form>`. The dial updates live on the client; on
  release it pushes `handle_event "angle"` (via `on_change`) so the server can rotate a preview, and
  Save submits the hidden field (`handle_event "save"`). Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.AngleSlider

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:angle, fn -> 45 end)
     |> assign_new(:saved, fn -> nil end)}
  end

  @impl true
  def handle_event("angle", %{"value" => value}, socket) do
    {:noreply, assign(socket, angle: to_int(value))}
  end

  def handle_event("save", %{"angle_demo" => %{"angle" => angle}}, socket) do
    {:noreply, assign(socket, saved: to_int(angle))}
  end

  defp to_int(v) when is_integer(v), do: v
  defp to_int(v) when is_binary(v), do: v |> Integer.parse() |> elem(0)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-8">
      <.form for={to_form(%{}, as: :angle_demo)} phx-target={@myself} phx-submit="save">
        <.angle_slider
          id={"#{@id}-dial"}
          name="angle_demo[angle]"
          value={@angle}
          step={1}
          on_change="angle"
          label="Gradient angle"
          class={dial()}
        />
        <button
          type="submit"
          class="mt-4 block rounded-md bg-[var(--c-primary)] px-3 py-1.5 text-sm font-medium text-primary-content"
        >
          Save
        </button>
      </.form>

      <div class="space-y-2">
        <div class="grid size-24 place-items-center rounded-xl border border-[var(--c-base-300)] bg-[var(--c-base-100)]">
          <div class="text-3xl leading-none transition-transform" style={"transform: rotate(#{@angle}deg)"}>
            ↑
          </div>
        </div>
        <p class="text-xs text-[var(--c-base-content)]/60">Preview (updates on release)</p>
        <p :if={@saved} class="text-sm font-medium text-[var(--c-success)]">
          ✓ Submitted: {@saved}°
        </p>
      </div>
    </div>
    """
  end

  defp dial do
    "relative block size-32 rounded-full border-2 border-[var(--c-base-300)] bg-[var(--c-base-100)] outline-none cursor-grab focus:ring-2 focus:ring-[var(--c-primary)]/40 data-[dragging]:cursor-grabbing " <>
      "[&_[data-part=thumb-layer]]:absolute [&_[data-part=thumb-layer]]:inset-0 " <>
      "[&_[data-part=thumb]]:absolute [&_[data-part=thumb]]:left-1/2 [&_[data-part=thumb]]:top-0 [&_[data-part=thumb]]:size-4 [&_[data-part=thumb]]:-translate-x-1/2 [&_[data-part=thumb]]:-translate-y-1/2 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:bg-[var(--c-primary)] [&_[data-part=thumb]]:shadow " <>
      "[&_[data-part=value]]:absolute [&_[data-part=value]]:inset-0 [&_[data-part=value]]:grid [&_[data-part=value]]:place-items-center [&_[data-part=value]]:text-sm [&_[data-part=value]]:font-medium [&_[data-part=value]]:text-[var(--c-base-content)]"
  end
end
