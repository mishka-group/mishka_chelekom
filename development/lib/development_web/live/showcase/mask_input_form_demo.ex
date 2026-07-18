defmodule DevelopmentWeb.Showcase.MaskInputFormDemo do
  @moduledoc """
  Interactive `mask_input` inside a Phoenix `<.form>`: the `MaskInput` hook formats each field as you
  type (client-side), and on submit the already-masked values arrive on the server (`handle_event
  "save"`) where they're echoed back. Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.MaskInput

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:phone, fn -> "" end)
     |> assign_new(:expiry, fn -> "" end)
     |> assign_new(:saved, fn -> nil end)}
  end

  @impl true
  def handle_event("save", %{"mask_demo" => %{"phone" => phone, "expiry" => expiry}}, socket) do
    {:noreply, assign(socket, phone: phone, expiry: expiry, saved: {phone, expiry})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md">
      <.form for={to_form(%{}, as: :mask_demo)} phx-target={@myself} phx-submit="save" class="space-y-3">
        <label class="block">
          <span class="mb-1 block text-sm font-medium">Phone</span>
          <.mask_input
            id={"#{@id}-phone"}
            name="mask_demo[phone]"
            value={@phone}
            mask="(999) 999-9999"
            placeholder="(___) ___-____"
            inputmode="numeric"
            class={mic()}
          />
        </label>
        <label class="block">
          <span class="mb-1 block text-sm font-medium">Card expiry (MM/YY)</span>
          <.mask_input
            id={"#{@id}-expiry"}
            name="mask_demo[expiry]"
            value={@expiry}
            mask="99/99"
            placeholder="MM/YY"
            inputmode="numeric"
            class={mic()}
          />
        </label>
        <button
          type="submit"
          class="rounded-md bg-[var(--c-primary)] px-3 py-1.5 text-sm font-medium text-primary-content"
        >
          Save
        </button>
      </.form>
      <p :if={@saved} class="mt-3 text-sm text-[var(--c-base-content)]/70">
        Submitted (masked): <span class="font-mono">{elem(@saved, 0) |> blank("—")}</span>
        · <span class="font-mono">{elem(@saved, 1) |> blank("—")}</span>
      </p>
    </div>
    """
  end

  defp blank("", fallback), do: fallback
  defp blank(value, _fallback), do: value

  defp mic do
    "w-full rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-3 py-1.5 text-sm outline-none focus:ring-2 focus:ring-[var(--c-primary)]/30"
  end
end
