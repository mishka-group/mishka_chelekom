defmodule DevelopmentWeb.Showcase.ColorInputFormDemo do
  @moduledoc """
  `color_input` inside a Phoenix `<.form>`. The picker mirrors the hex into a hidden input and
  dispatches an `input` event, so `phx-change "validate"` fires on every change (drag, hue, or typing
  a hex) and the server tracks the color live. Save stores it (`handle_event "save"`). Nothing is
  persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.ColorInput

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:color, fn -> "#22c55e" end)
     |> assign_new(:saved, fn -> nil end)}
  end

  @impl true
  def handle_event("validate", %{"color_demo" => %{"color" => color}}, socket) do
    {:noreply, assign(socket, color: color)}
  end

  def handle_event("save", %{"color_demo" => %{"color" => color}}, socket) do
    {:noreply, assign(socket, saved: color)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-sm space-y-3">
      <.form
        for={to_form(%{"color" => @color}, as: :color_demo)}
        id={"#{@id}-ci-form"}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.color_input
          id={"#{@id}-ci"}
          name="color_demo[color]"
          value={@color}
          label="Brand color"
          class="relative inline-block w-56"
          control_class="flex items-center gap-2 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-2 py-1.5 focus-within:ring-2 focus-within:ring-[var(--c-primary)]/30"
          preview_class="size-5 shrink-0 rounded border border-[var(--c-base-300)]"
          text_class="w-24 bg-transparent font-mono text-sm outline-none"
          trigger_class="ml-auto rounded p-1 text-[var(--c-base-content)]/50 hover:bg-[var(--c-base-200)]"
          panel_class="absolute left-0 z-20 mt-2 w-56 rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-3 shadow-lg"
          area_class="relative h-36 w-full cursor-crosshair rounded-md"
          thumb_class="block size-3 rounded-full border-2 border-white shadow"
          hue_class="mt-3 w-full"
        />
        <button
          type="submit"
          class="mt-3 block rounded-md bg-[var(--c-primary)] px-3 py-1.5 text-sm font-medium text-primary-content"
        >
          Save
        </button>
      </.form>
      <p :if={@saved} class="text-sm">
        <span class="text-[var(--c-base-content)]/60">Saved:</span>
        <span class="font-mono">{@saved}</span>
        <span
          class="ml-1 inline-block size-3 rounded-full align-middle"
          style={"background:#{@saved}"}
        ></span>
      </p>
    </div>
    """
  end
end
