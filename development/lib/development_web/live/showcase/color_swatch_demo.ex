defmodule DevelopmentWeb.Showcase.ColorSwatchDemo do
  @moduledoc """
  What a color swatch is *for*: the visible half of a color choice. Each swatch sits in a `<label>`
  wrapping a visually-hidden native radio, so this is an ordinary Phoenix form — the selected ring
  is pure CSS (`:has(:checked)`, instant) while `phx-change` hands the value to the server.
  Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.ColorSwatch

  @palette [
    {"Red", "#fa5252"},
    {"Orange", "#fd7e14"},
    {"Yellow", "#fab005"},
    {"Green", "#40c057"},
    {"Teal", "#12b886"},
    {"Blue", "#228be6"},
    {"Violet", "#7048e8"},
    {"Pink", "#e64980"}
  ]

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(palette: @palette)
     |> assign_new(:color, fn -> "#228be6" end)}
  end

  @impl true
  def handle_event("pick", %{"swatch_demo" => %{"color" => color}}, socket) do
    {:noreply, assign(socket, color: color)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={%{}}
        as={:swatch_demo}
        id={"#{@id}-swatch-form"}
        phx-target={@myself}
        phx-change="pick"
      >
        <div class="flex flex-wrap items-center gap-2">
          <label :for={{name, hex} <- @palette} class={label_class()}>
            <input
              type="radio"
              name="swatch_demo[color]"
              value={hex}
              checked={hex == @color}
              class="sr-only"
            />
            <.color_swatch
              color={hex}
              label={name}
              class="inline-flex size-8 items-center justify-center rounded-full ring-1 ring-black/10"
            >
              <svg
                data-part="check"
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 20 20"
                fill="currentColor"
                class="size-4 text-white opacity-0 drop-shadow"
              >
                <path
                  fill-rule="evenodd"
                  d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 0 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z"
                  clip-rule="evenodd"
                />
              </svg>
            </.color_swatch>
          </label>
        </div>
      </.form>
      <p class="mt-3 flex items-center gap-2 text-xs text-[var(--c-base-content)]/50">
        Submits as <code>swatch_demo[color]</code>
        —
        <.color_swatch color={@color} class="inline-block size-3 rounded-full ring-1 ring-black/10" />
        {selected_name(@palette, @color)} ({@color})
      </p>
    </div>
    """
  end

  defp selected_name(palette, hex) do
    Enum.find_value(palette, "custom", fn {name, value} -> value == hex && name end)
  end

  defp label_class do
    [
      "inline-flex cursor-pointer rounded-full p-0.5",
      "has-[:checked]:ring-2 has-[:checked]:ring-[var(--c-base-content)]/60",
      "has-[:focus-visible]:ring-2 has-[:focus-visible]:ring-[var(--c-primary)]",
      "[&:has(:checked)_[data-part=check]]:opacity-100"
    ]
  end
end
