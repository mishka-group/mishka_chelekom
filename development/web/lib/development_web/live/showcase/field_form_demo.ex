defmodule DevelopmentWeb.Showcase.FieldFormDemo.Signup do
  @moduledoc """
  In-memory signup form for the headless `field` showcase. Backed by an Ecto
  `embedded_schema` + changeset — **validation only, never persisted** (no Repo,
  no database). Mirrors the no-persistence doc-form convention from the main
  Mishka source (`Mishka.Docs.Chelekom.User`).
  """
  use Ecto.Schema
  import Ecto.Changeset

  @roles ~w(developer designer manager)a

  @primary_key false
  embedded_schema do
    field(:name, :string)
    field(:email, :string)
    field(:age, :integer)
    field(:role, Ecto.Enum, values: @roles)
    field(:bio, :string)
  end

  def roles, do: @roles

  def changeset(signup, attrs) do
    signup
    |> cast(attrs, [:name, :email, :age, :role, :bio])
    |> validate_required([:name, :email, :role])
    |> validate_length(:name, min: 2, max: 40)
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      message: "must be a valid email address"
    )
    |> validate_number(:age,
      greater_than_or_equal_to: 18,
      less_than_or_equal_to: 120,
      message: "must be between 18 and 120"
    )
    |> validate_length(:bio, max: 160)
  end
end

defmodule DevelopmentWeb.Showcase.FieldFormDemo do
  @moduledoc """
  A self-contained `live_component` that drives a full `<.form>` with the stateless
  headless `field` — realtime validation on change + validation on submit, via an
  Ecto embedded changeset. **Nothing is saved anywhere.** Embedded in the `field`
  showcase "Examples" section to prove the component works inside a real form.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.Field
  alias DevelopmentWeb.Showcase.FieldFormDemo.Signup

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(Signup.changeset(%Signup{}, %{}), as: :signup) end)
     |> assign_new(:saved, fn -> nil end)}
  end

  @impl true
  def handle_event("validate", %{"signup" => params}, socket) do
    form =
      %Signup{}
      |> Signup.changeset(params)
      |> to_form(action: :validate, as: :signup)

    {:noreply, assign(socket, form: form, saved: nil)}
  end

  def handle_event("save", %{"signup" => params}, socket) do
    case %Signup{} |> Signup.changeset(params) |> Ecto.Changeset.apply_action(:insert) do
      {:ok, data} ->
        # Validation passed — show the cast struct, but DO NOT persist it anywhere.
        {:noreply,
         assign(socket,
           saved: data,
           form: to_form(Signup.changeset(%Signup{}, params), as: :signup)
         )}

      {:error, changeset} ->
        {:noreply,
         assign(socket, saved: nil, form: to_form(changeset, action: :insert, as: :signup))}
    end
  end

  def handle_event("reset", _params, socket) do
    {:noreply,
     assign(socket, saved: nil, form: to_form(Signup.changeset(%Signup{}, %{}), as: :signup))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id={"#{@id}-field-form"}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-4"
      >
        <.field
          :let={f}
          id={"#{@id}-name"}
          name={@form[:name].name}
          label="Full name"
          errors={errs(@form[:name])}
          valid={validity(@form[:name])}
          class={fc()}
        >
          <input
            type="text"
            id={f.id}
            name={f.name}
            value={@form[:name].value}
            aria-describedby={f.describedby}
            aria-invalid={f.invalid && "true"}
            placeholder="Ada Lovelace"
            class={input_cls()}
          />
          <:description>Between 2 and 40 characters.</:description>
        </.field>

        <.field
          :let={f}
          id={"#{@id}-email"}
          name={@form[:email].name}
          label="Email address"
          errors={errs(@form[:email])}
          valid={validity(@form[:email])}
          class={fc()}
        >
          <input
            type="text"
            id={f.id}
            name={f.name}
            value={@form[:email].value}
            aria-describedby={f.describedby}
            aria-invalid={f.invalid && "true"}
            placeholder="ada@example.com"
            class={input_cls()}
          />
          <:description>We'll only use this to send account notifications.</:description>
        </.field>

        <.field
          :let={f}
          id={"#{@id}-age"}
          name={@form[:age].name}
          label="Age"
          errors={errs(@form[:age])}
          valid={validity(@form[:age])}
          class={fc()}
        >
          <input
            type="number"
            id={f.id}
            name={f.name}
            value={@form[:age].value}
            min="18"
            max="120"
            step="1"
            aria-describedby={f.describedby}
            aria-invalid={f.invalid && "true"}
            placeholder="18"
            class={input_cls()}
          />
          <:description>Optional — must be 18 or older.</:description>
        </.field>

        <.field
          :let={f}
          id={"#{@id}-role"}
          name={@form[:role].name}
          label="Role"
          errors={errs(@form[:role])}
          valid={validity(@form[:role])}
          class={fc()}
        >
          <select
            id={f.id}
            name={f.name}
            aria-describedby={f.describedby}
            aria-invalid={f.invalid && "true"}
            class={input_cls()}
          >
            <option value="">Choose a role…</option>
            <option
              :for={r <- Signup.roles()}
              value={r}
              selected={to_string(@form[:role].value) == to_string(r)}
            >
              {String.capitalize(to_string(r))}
            </option>
          </select>
        </.field>

        <.field
          :let={f}
          id={"#{@id}-bio"}
          name={@form[:bio].name}
          label="Short bio"
          errors={errs(@form[:bio])}
          valid={validity(@form[:bio])}
          class={fc()}
        >
          <textarea
            id={f.id}
            name={f.name}
            rows="3"
            aria-describedby={f.describedby}
            aria-invalid={f.invalid && "true"}
            placeholder="A sentence or two…"
            class={input_cls()}
          >{@form[:bio].value}</textarea>
          <:description>Up to 160 characters.</:description>
        </.field>

        <.field :let={f} id={"#{@id}-plan"} label="Plan" disabled class={fc()}>
          <input
            type="text"
            id={f.id}
            value="Free — contact sales to upgrade"
            disabled={f.disabled}
            class={input_cls()}
          />
          <:description>
            A disabled field — note the dimmed <code>data-disabled</code> state.
          </:description>
        </.field>

        <div class="flex flex-wrap items-center gap-3 pt-1">
          <button
            type="submit"
            class="rounded-md bg-[var(--c-primary)] px-4 py-1.5 text-sm font-medium text-primary-content"
          >
            Create account
          </button>
          <button
            type="button"
            phx-target={@myself}
            phx-click="reset"
            class="rounded-md border border-[var(--c-base-300)] px-4 py-1.5 text-sm"
          >
            Reset
          </button>
          <span class="text-xs text-[var(--c-base-content)]/40">
            Nothing is saved — validation only.
          </span>
        </div>
      </.form>

      <div
        :if={@saved}
        class="mt-4 rounded-md border border-[var(--c-success)]/40 bg-[var(--c-success)]/10 p-3 text-sm"
      >
        <p class="font-medium text-[var(--c-success)]">✓ Validated (not persisted)</p>
        <pre class="mt-1 overflow-x-auto text-xs text-[var(--c-base-content)]/70">{format_saved(@saved)}</pre>
      </div>
    </div>
    """
  end

  # Show changeset errors only for fields the user has actually interacted with (or after submit).
  defp errs(field) do
    if used_input?(field), do: Enum.map(field.errors, &translate_error/1), else: []
  end

  # Validity tri-state (mirrors Base UI): nil = pristine (untouched → neither data-valid nor
  # data-invalid), true = touched & passing (data-valid), false = touched & failing (data-invalid).
  defp validity(field) do
    cond do
      not used_input?(field) -> nil
      field.errors == [] -> true
      true -> false
    end
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp format_saved(%Signup{} = s) do
    s
    |> Map.from_struct()
    |> Enum.map_join("\n", fn {k, v} -> "#{k}: #{inspect(v)}" end)
  end

  # Showcase-only styling — the headless field ships none. Maps the field's state
  # data-attributes (set by the Field engine) onto visible styles.
  defp fc do
    [
      "[&_[data-part=label]]:mb-1 [&_[data-part=label]]:block [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium",
      "[&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-xs [&_[data-part=description]]:text-[var(--c-base-content)]/60",
      "[&_[data-part=error]]:mt-1 [&_[data-part=error]]:text-xs [&_[data-part=error]]:text-[var(--c-error)]",
      "[&[data-invalid]_.ffd-ctl]:border-[var(--c-error)]",
      # success state (data-valid) — green control + a ✓ after the label
      "[&[data-valid]_.ffd-ctl]:border-[var(--c-success)]",
      "[&[data-valid]_[data-part=label]]:after:content-['_✓'] [&[data-valid]_[data-part=label]]:after:text-[var(--c-success)]",
      "[&[data-focused]_.ffd-ctl]:ring-2 [&[data-focused]_.ffd-ctl]:ring-[var(--c-primary)]/30",
      "[&[data-disabled]]:opacity-60"
    ]
  end

  defp input_cls do
    "ffd-ctl w-full rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-3 py-1.5 text-sm outline-none"
  end
end
