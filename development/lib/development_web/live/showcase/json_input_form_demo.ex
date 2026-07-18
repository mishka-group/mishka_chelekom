defmodule DevelopmentWeb.Showcase.JsonInputFormDemo do
  @moduledoc """
  Interactive `json_input` inside a Phoenix `<.form>`: on submit the server parses the JSON with
  `Jason.decode/1` (`handle_event "format"`) and either pretty-prints it back into the field or shows
  the decode error and flags `data-invalid`. Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.JsonInput

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:value, fn -> ~s({"name":"Mishka","stars":42,"tags":["ui","phoenix"]}) end)
     |> assign_new(:result, fn -> nil end)}
  end

  @impl true
  def handle_event("format", %{"json_demo" => %{"json" => json}}, socket) do
    case Jason.decode(json) do
      {:ok, data} ->
        {:noreply, assign(socket, value: Jason.encode!(data, pretty: true), result: {:ok, "Valid JSON"})}

      {:error, error} ->
        {:noreply, assign(socket, value: json, result: {:error, Exception.message(error)})}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md">
      <.form
        for={to_form(%{"json" => @value}, as: :json_demo)}
        phx-target={@myself}
        phx-submit="format"
      >
        <.json_input
          id={"#{@id}-ta"}
          name="json_demo[json]"
          value={@value}
          invalid={match?({:error, _}, @result)}
          rows={7}
          class={jic()}
        />
        <button
          type="submit"
          class="mt-2 rounded-md bg-[var(--c-primary)] px-3 py-1.5 text-sm font-medium text-primary-content"
        >
          Validate &amp; format
        </button>
      </.form>
      <p
        :if={@result}
        class={[
          "mt-2 text-sm font-medium",
          (match?({:ok, _}, @result) && "text-[var(--c-success)]") || "text-[var(--c-error)]"
        ]}
      >
        {(match?({:ok, _}, @result) && "✓ ") || "✕ "}{elem(@result, 1)}
      </p>
    </div>
    """
  end

  defp jic do
    "w-full rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-2 font-mono text-sm outline-none focus:ring-2 focus:ring-[var(--c-primary)]/30 data-[invalid]:border-[var(--c-error)] data-[invalid]:ring-2 data-[invalid]:ring-[var(--c-error)]/30"
  end
end
