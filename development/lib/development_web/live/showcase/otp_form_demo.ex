defmodule DevelopmentWeb.Showcase.OtpFormDemo do
  @moduledoc """
  A self-contained `live_component` showing the headless `otp_field` inside a real `<form>`: the code
  is submitted to the server (the OTP's hidden input carries it as `code`) and validated there.
  `auto_submit` fires the submit automatically once every slot is filled. Nothing is persisted — the
  expected code is "123456".
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.OtpField

  @expected "123456"

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_new(:result, fn -> nil end)}
  end

  @impl true
  def handle_event("verify", %{"code" => code}, socket) do
    result =
      cond do
        String.length(code) < 6 -> {:error, "Enter all 6 digits."}
        code == @expected -> {:ok, code}
        true -> {:error, "Incorrect code — this demo expects #{@expected}."}
      end

    {:noreply, assign(socket, result: result)}
  end

  def handle_event("reset", _params, socket) do
    # The slots are client-owned (phx-update="ignore"), so clear them via the hook's set channel.
    {:noreply,
     socket
     |> assign(result: nil)
     |> push_event("chelekom:otp", %{id: "#{socket.assigns.id}-code", value: ""})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form phx-target={@myself} phx-submit="verify" class="space-y-3">
        <.otp_field id={"#{@id}-code"} name="code" length={6} auto_submit class={fc()} />
        <div class="flex flex-wrap items-center gap-3">
          <button
            type="submit"
            class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
          >
            Verify
          </button>
          <button
            type="button"
            phx-target={@myself}
            phx-click="reset"
            class="rounded-md border border-base-300 px-4 py-1.5 text-sm"
          >
            Reset
          </button>
          <span class="text-xs text-base-content/40">
            Auto-submits when all 6 digits are entered · try <code>123456</code>
          </span>
        </div>
      </form>

      <div
        :if={match?({:ok, _}, @result)}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ Verified — code {elem(@result, 1)} accepted (not persisted)
      </div>
      <div
        :if={match?({:error, _}, @result)}
        class="mt-3 rounded-md border border-error/40 bg-error/10 p-3 text-sm font-medium text-error"
      >
        {elem(@result, 1)}
      </div>
    </div>
    """
  end

  defp fc do
    [
      "flex items-center gap-2",
      "[&_[data-part=input]]:size-11 [&_[data-part=input]]:rounded-md [&_[data-part=input]]:border [&_[data-part=input]]:border-base-300 [&_[data-part=input]]:bg-base-100 [&_[data-part=input]]:text-center [&_[data-part=input]]:text-lg [&_[data-part=input]]:tabular-nums [&_[data-part=input]]:outline-none",
      "[&_[data-part=input]:focus]:border-primary [&_[data-part=input]:focus]:ring-2 [&_[data-part=input]:focus]:ring-primary/30",
      "[&_[data-part=input][data-filled]]:border-base-content/40",
      "[&[data-complete]_[data-part=input]]:border-success"
    ]
  end
end
