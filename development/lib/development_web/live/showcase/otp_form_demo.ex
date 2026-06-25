defmodule DevelopmentWeb.Showcase.OtpFormDemo do
  @moduledoc """
  A self-contained `live_component` showing the headless `otp_field` inside a Phoenix `<.form>`
  with a (schemaless) Ecto changeset: the OTP is a normal form field (`name={f[:code].name}`), so the
  code submits as `params["otp"]["code"]` and is validated by the changeset. `auto_submit` fires the
  form once every slot is filled. Nothing is persisted — the expected code is "123456".
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.OtpField
  import Ecto.Changeset

  @expected "123456"

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(changeset(%{}), as: :otp) end)
     |> assign_new(:verified, fn -> false end)}
  end

  @impl true
  def handle_event("verify", %{"otp" => params}, socket) do
    changeset = changeset(params)

    if changeset.valid? do
      {:noreply, assign(socket, form: to_form(changeset, as: :otp), verified: true)}
    else
      {:noreply,
       assign(socket, form: to_form(changeset, as: :otp, action: :verify), verified: false)}
    end
  end

  def handle_event("reset", _params, socket) do
    # The slots are client-owned (phx-update="ignore"), so clear them via the hook's set channel.
    {:noreply,
     socket
     |> assign(form: to_form(changeset(%{}), as: :otp), verified: false)
     |> push_event("chelekom:otp", %{id: "#{socket.assigns.id}-code", value: ""})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="verify">
        <.otp_field
          id={"#{@id}-code"}
          name={f[:code].name}
          value={f[:code].value}
          length={6}
          auto_submit
          class={fc()}
        />
        <p :for={{msg, _} <- f[:code].errors} class="mt-2 text-sm font-medium text-error">{msg}</p>

        <div class="mt-3 flex flex-wrap items-center gap-3">
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
      </.form>

      <div
        :if={@verified}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ Verified — code accepted (not persisted)
      </div>
    </div>
    """
  end

  # Schemaless Ecto changeset — no schema module, no database.
  defp changeset(params) do
    {%{}, %{code: :string}}
    |> cast(params, [:code])
    |> validate_required([:code])
    |> validate_format(:code, ~r/^\d{6}$/, message: "must be 6 digits")
    |> validate_inclusion(:code, [@expected],
      message: "incorrect code — this demo expects #{@expected}"
    )
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
