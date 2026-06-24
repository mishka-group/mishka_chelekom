defmodule DevelopmentWeb.Showcase.FormDemoHelpers do
  @moduledoc "Shared bits for the headless form demos (validation only — nothing is persisted)."

  import Phoenix.Component, only: [used_input?: 1]

  # Translate a {msg, opts} changeset error to a string (no gettext needed here).
  def err({msg, opts}) do
    Enum.reduce(opts, msg, fn {k, v}, acc -> String.replace(acc, "%{#{k}}", to_string(v)) end)
  end

  # A field's translated errors, but ONLY once the user has actually touched it (or after submit) —
  # so `phx-change` validation doesn't flag fields the user hasn't reached yet. See `used_input?/1`.
  def field_errors(field) do
    if used_input?(field), do: Enum.map(field.errors, &err/1), else: []
  end
end

defmodule DevelopmentWeb.Showcase.NumberFieldFormDemo do
  @moduledoc "number_field inside a `<.form>` — submits the raw number, validated by a changeset."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.NumberField
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{}), as: :order) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"order" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do:
        {:noreply,
         assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :order))},
      else:
        {:noreply,
         assign(socket, saved: nil, form: to_form(changeset, as: :order, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save" class="space-y-3">
        <label class="block text-sm font-medium">Quantity (1–10)</label>
        <NumberField.number_field
          id={"#{@id}-qty"}
          name={f[:qty].name}
          value={f[:qty].value}
          min="1"
          max="10"
          step="1"
          phx-update="ignore"
          class="inline-flex items-center rounded-md border border-base-300 [&_[data-part=decrement]]:px-3 [&_[data-part=decrement]]:py-1.5 [&_[data-part=decrement]]:text-lg [&_[data-part=decrement]]:hover:bg-base-200 [&_[data-part=increment]]:px-3 [&_[data-part=increment]]:py-1.5 [&_[data-part=increment]]:text-lg [&_[data-part=increment]]:hover:bg-base-200 [&_[data-part=input]]:w-16 [&_[data-part=input]]:border-x [&_[data-part=input]]:border-base-300 [&_[data-part=input]]:py-1.5 [&_[data-part=input]]:text-center [&_[data-part=input]]:outline-none"
        />
        <p :for={e <- f[:qty].errors} class="text-sm text-error">{H.err(e)}</p>
        <button
          type="submit"
          class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
        >
          Order
        </button>
      </.form>
      <div
        :if={@saved}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ Ordered quantity {@saved.qty} (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    # default the field to 1 (the valid range is 1–10)
    {%{qty: 1}, %{qty: :integer}}
    |> cast(p, [:qty])
    |> validate_required([:qty])
    |> validate_number(:qty, greater_than_or_equal_to: 1, less_than_or_equal_to: 10)
  end
end

defmodule DevelopmentWeb.Showcase.ComboboxFormDemo do
  @moduledoc "combobox inside a `<.form>` — submits the selected value (hidden input)."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Combobox
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{}), as: :pick) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"pick" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do:
        {:noreply,
         assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :pick))},
      else:
        {:noreply, assign(socket, saved: nil, form: to_form(changeset, as: :pick, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save" class="space-y-3">
        <label class="block text-sm font-medium">Favorite fruit (required)</label>
        <Combobox.combobox
          id={"#{@id}-fruit"}
          name={f[:fruit].name}
          value={f[:fruit].value}
          placeholder="Search fruit…"
          clear
          phx-update="ignore"
          class={combo_class()}
        >
          <:option value="apple">Apple</:option>
          <:option value="banana">Banana</:option>
          <:option value="cherry">Cherry</:option>
          <:empty>No fruit found.</:empty>
        </Combobox.combobox>
        <p :for={e <- f[:fruit].errors} class="text-sm text-error">{H.err(e)}</p>
        <button
          type="submit"
          class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
        >
          Save
        </button>
      </.form>
      <div
        :if={@saved}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ Picked {@saved.fruit} (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{fruit: :string}}
    |> cast(p, [:fruit])
    |> validate_required([:fruit], message: "please pick a fruit")
  end

  defp combo_class do
    [
      "relative w-64",
      "[&_[data-part=control]]:flex [&_[data-part=control]]:items-center [&_[data-part=control]]:rounded-md [&_[data-part=control]]:border [&_[data-part=control]]:border-base-300 [&_[data-part=control]]:bg-base-100 [&_[data-part=control]]:px-2 [&_[data-part=control]]:py-1",
      "[&_[data-part=input]]:flex-1 [&_[data-part=input]]:border-0 [&_[data-part=input]]:bg-transparent [&_[data-part=input]]:px-1 [&_[data-part=input]]:text-sm [&_[data-part=input]]:outline-none",
      "[&_[data-part=clear]]:px-1 [&_[data-part=clear]]:text-base-content/40 [&_[data-part=clear][data-hidden]]:hidden",
      "[&_[data-part=popup]]:absolute [&_[data-part=popup]]:left-0 [&_[data-part=popup]]:right-0 [&_[data-part=popup]]:top-full [&_[data-part=popup]]:z-10 [&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:max-h-56 [&_[data-part=popup]]:overflow-auto [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[data-part=popup][data-closed]]:hidden",
      "[&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:rounded [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item][data-highlighted]]:bg-base-200 [&_[data-part=item][data-selected]]:font-semibold",
      "[&_[data-part=empty]]:px-3 [&_[data-part=empty]]:py-2 [&_[data-part=empty]]:text-sm [&_[data-part=empty]]:text-base-content/50"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.CheckboxGroupFormDemo do
  @moduledoc "checkbox_group inside a `<.form>` — submits the checked values as name[] (a list)."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.CheckboxGroup
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{}), as: :prefs) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"prefs" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do:
        {:noreply,
         assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :prefs))},
      else:
        {:noreply,
         assign(socket, saved: nil, form: to_form(changeset, as: :prefs, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save" class="space-y-3">
        <CheckboxGroup.checkbox_group
          id={"#{@id}-toppings"}
          name={f[:toppings].name}
          phx-update="ignore"
          class={cg_class()}
        >
          <:label>Pizza toppings (pick at least one)</:label>
          <:item value="cheese">Cheese</:item>
          <:item value="mushroom">Mushroom</:item>
          <:item value="pepperoni">Pepperoni</:item>
        </CheckboxGroup.checkbox_group>
        <p :for={e <- f[:toppings].errors} class="text-sm text-error">{H.err(e)}</p>
        <button
          type="submit"
          class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
        >
          Save
        </button>
      </.form>
      <div
        :if={@saved}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ Toppings: {Enum.join(@saved.toppings, ", ")} (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{toppings: {:array, :string}}}
    |> cast(p, [:toppings])
    |> validate_required([:toppings], message: "pick at least one topping")
    |> validate_length(:toppings, min: 1, message: "pick at least one topping")
  end

  defp cg_class do
    [
      "flex w-64 flex-col gap-1 rounded-md border border-base-300 p-3",
      "[&_[data-part=label]]:mb-1 [&_[data-part=label]]:block [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-semibold",
      "[&_[data-part=item]]:flex [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded [&_[data-part=item]]:px-2 [&_[data-part=item]]:py-1 [&_[data-part=item]]:text-sm",
      "[&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-5 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded [&_[data-part=indicator]]:border [&_[data-part=indicator]]:border-base-300 [&_[data-part=indicator]]:text-xs [&_[data-part=indicator]]:text-base-100",
      "[&_[data-part=indicator][data-checked]]:border-base-content [&_[data-part=indicator][data-checked]]:bg-base-content [&_[data-part=indicator][data-checked]]:after:content-['✓']"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.CheckboxFormDemo do
  @moduledoc """
  checkbox inside a `<.form>` — a boolean "accept terms". Note the hidden `false` input before the
  checkbox: headless checkbox submits its `value` only when checked, so the hidden input supplies
  `false` when unchecked (the same trick Phoenix's `<.input type="checkbox">` uses).
  """
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Checkbox
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{}), as: :signup) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"signup" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do:
        {:noreply,
         assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :signup))},
      else:
        {:noreply,
         assign(socket, saved: nil, form: to_form(changeset, as: :signup, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save" class="space-y-3">
        <div class="flex items-start gap-2">
          <input type="hidden" name={f[:terms].name} value="false" />
          <Checkbox.checkbox
            id={"#{@id}-terms"}
            name={f[:terms].name}
            value="true"
            checked={f[:terms].value in [true, "true"]}
            phx-update="ignore"
            class={cb_class()}
          >
            I accept the terms and conditions
          </Checkbox.checkbox>
        </div>
        <p :for={e <- f[:terms].errors} class="text-sm text-error">{H.err(e)}</p>
        <button
          type="submit"
          class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
        >
          Sign up
        </button>
      </.form>
      <div
        :if={@saved}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ Signed up — terms accepted (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{terms: :boolean}}
    |> cast(p, [:terms])
    |> validate_acceptance(:terms, message: "you must accept the terms")
  end

  defp cb_class do
    [
      "inline-flex cursor-pointer items-center gap-2",
      "[&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-5 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded [&_[data-part=indicator]]:border [&_[data-part=indicator]]:border-base-300 [&_[data-part=indicator]]:text-xs [&_[data-part=indicator]]:text-base-100",
      "[&_[data-part=indicator][data-checked]]:border-base-content [&_[data-part=indicator][data-checked]]:bg-base-content [&_[data-part=indicator][data-checked]]:after:content-['✓']",
      "[&_[data-part=label]]:text-sm"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.AutocompleteFormDemo do
  @moduledoc "autocomplete inside a `<.form>` — submits the selected value (hidden input), like combobox."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Autocomplete
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{}), as: :search) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"search" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do:
        {:noreply,
         assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :search))},
      else:
        {:noreply,
         assign(socket, saved: nil, form: to_form(changeset, as: :search, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save" class="space-y-3">
        <label class="block text-sm font-medium">City (required)</label>
        <Autocomplete.autocomplete
          id={"#{@id}-city"}
          name={f[:city].name}
          value={f[:city].value}
          placeholder="Search city…"
          clear
          auto_highlight
          phx-update="ignore"
          class={ac_class()}
        >
          <:option value="London">London</:option>
          <:option value="Paris">Paris</:option>
          <:option value="Tokyo">Tokyo</:option>
          <:option value="New York">New York</:option>
          <:empty>No matches.</:empty>
        </Autocomplete.autocomplete>
        <p :for={e <- f[:city].errors} class="text-sm text-error">{H.err(e)}</p>
        <button
          type="submit"
          class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
        >
          Save
        </button>
      </.form>
      <div
        :if={@saved}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ City: {@saved.city} (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{city: :string}}
    |> cast(p, [:city])
    |> validate_required([:city], message: "please pick a city")
  end

  defp ac_class do
    [
      "relative w-64",
      "[&_[data-part=input]]:w-full [&_[data-part=input]]:rounded-md [&_[data-part=input]]:border [&_[data-part=input]]:border-base-300 [&_[data-part=input]]:px-3 [&_[data-part=input]]:py-1.5 [&_[data-part=input]]:pr-8 [&_[data-part=input]]:outline-none",
      "[&_[data-part=clear]]:absolute [&_[data-part=clear]]:right-2 [&_[data-part=clear]]:top-1.5 [&_[data-part=clear]]:text-base-content/40 [&_[data-part=clear][data-hidden]]:hidden",
      "[&_[data-part=popup]]:absolute [&_[data-part=popup]]:left-0 [&_[data-part=popup]]:right-0 [&_[data-part=popup]]:top-full [&_[data-part=popup]]:z-10 [&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:max-h-56 [&_[data-part=popup]]:overflow-auto [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[data-part=popup][data-closed]]:hidden",
      "[&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:rounded [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item][data-highlighted]]:bg-base-200 [&_[data-part=item][aria-selected=true]]:font-semibold",
      "[&_[data-part=empty]]:px-3 [&_[data-part=empty]]:py-2 [&_[data-part=empty]]:text-sm [&_[data-part=empty]]:text-base-content/50"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.FieldsetFormDemo do
  @moduledoc "fieldset inside a `<.form>` — groups native inputs that submit; validates on change."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Fieldset
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{}), as: :addr) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("validate", %{"addr" => p}, socket),
    do: {:noreply, assign(socket, form: to_form(cs(p), as: :addr, action: :validate), saved: nil)}

  def handle_event("save", %{"addr" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do:
        {:noreply,
         assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :addr))},
      else:
        {:noreply, assign(socket, saved: nil, form: to_form(changeset, as: :addr, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-3"
      >
        <Fieldset.fieldset id={"#{@id}-fs"} class={fs_class()}>
          <:legend>Shipping address</:legend>
          <div class="space-y-2">
            <label class="block text-sm">
              <span class="mb-1 block text-base-content/70">Street</span>
              <input
                type="text"
                name={f[:street].name}
                value={f[:street].value}
                class="w-full rounded-md border border-base-300 px-3 py-1.5"
              />
              <span :for={msg <- H.field_errors(f[:street])} class="mt-1 block text-xs text-error">
                {msg}
              </span>
            </label>
            <label class="block text-sm">
              <span class="mb-1 block text-base-content/70">City</span>
              <input
                type="text"
                name={f[:city].name}
                value={f[:city].value}
                class="w-full rounded-md border border-base-300 px-3 py-1.5"
              />
              <span :for={msg <- H.field_errors(f[:city])} class="mt-1 block text-xs text-error">
                {msg}
              </span>
            </label>
          </div>
        </Fieldset.fieldset>
        <button
          type="submit"
          class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
        >
          Save
        </button>
      </.form>
      <div
        :if={@saved}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ {@saved.street}, {@saved.city} (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{street: :string, city: :string}}
    |> cast(p, [:street, :city])
    |> validate_required([:street, :city])
  end

  defp fs_class do
    [
      "w-72 rounded-md border border-base-300 p-4",
      "[&_[data-part=legend]]:mb-2 [&_[data-part=legend]]:text-sm [&_[data-part=legend]]:font-semibold",
      "[&[data-disabled]]:opacity-60"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.RadioFormDemo do
  @moduledoc "radio inside a `<.form>` — a native radio group submits the chosen value, validated."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Radio
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @plans [{"free", "Free"}, {"pro", "Pro"}, {"enterprise", "Enterprise"}]

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign(:plans, @plans)
       |> assign_new(:form, fn -> to_form(cs(%{}), as: :sub) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"sub" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do:
        {:noreply,
         assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :sub))},
      else:
        {:noreply, assign(socket, saved: nil, form: to_form(changeset, as: :sub, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save" class="space-y-3">
        <fieldset class="flex flex-col gap-2">
          <legend class="mb-1 text-sm font-medium">Plan (required)</legend>
          <Radio.radio
            :for={{v, label} <- @plans}
            id={"#{@id}-#{v}"}
            name={f[:plan].name}
            value={v}
            checked={to_string(f[:plan].value) == v}
            class={rc()}
          >
            {label}
          </Radio.radio>
        </fieldset>
        <p :for={msg <- H.field_errors(f[:plan])} class="text-sm text-error">{msg}</p>
        <button
          type="submit"
          class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
        >
          Subscribe
        </button>
      </.form>
      <div
        :if={@saved}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ Subscribed to the {@saved.plan} plan (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{plan: :string}}
    |> cast(p, [:plan])
    |> validate_required([:plan], message: "please choose a plan")
    |> validate_inclusion(:plan, Enum.map(@plans, &elem(&1, 0)))
  end

  defp rc do
    [
      "inline-flex cursor-pointer items-center gap-2 [&[data-disabled]]:opacity-50",
      "[&_[data-part=input]]:sr-only",
      "[&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-4 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:border [&_[data-part=indicator]]:border-base-300",
      "[&_[data-part=indicator][data-checked]]:border-primary [&_[data-part=indicator][data-checked]]:after:size-2 [&_[data-part=indicator][data-checked]]:after:rounded-full [&_[data-part=indicator][data-checked]]:after:bg-primary [&_[data-part=indicator][data-checked]]:after:content-['']",
      "[&_[data-part=label]]:text-sm [&[data-checked]_[data-part=label]]:font-medium"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.RadioGroupFormDemo do
  @moduledoc "radio_group inside a `<.form>` — the roving group submits the selected value, validated."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.RadioGroup
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @plans [{"free", "Free"}, {"pro", "Pro"}, {"enterprise", "Enterprise"}]

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign(:plans, @plans)
       |> assign_new(:form, fn -> to_form(cs(%{}), as: :sub) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"sub" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do:
        {:noreply,
         assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :sub))},
      else:
        {:noreply, assign(socket, saved: nil, form: to_form(changeset, as: :sub, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save" class="space-y-3">
        <span class="block text-sm font-medium">Plan (required)</span>
        <RadioGroup.radio_group
          id={"#{@id}-plan"}
          name={f[:plan].name}
          value={f[:plan].value}
          class={rgc()}
        >
          <:option :for={{v, label} <- @plans} value={v}>{label}</:option>
        </RadioGroup.radio_group>
        <p :for={msg <- H.field_errors(f[:plan])} class="text-sm text-error">{msg}</p>
        <button
          type="submit"
          class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
        >
          Subscribe
        </button>
      </.form>
      <div
        :if={@saved}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ Subscribed to the {@saved.plan} plan (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{plan: :string}}
    |> cast(p, [:plan])
    |> validate_required([:plan], message: "please choose a plan")
    |> validate_inclusion(:plan, Enum.map(@plans, &elem(&1, 0)))
  end

  defp rgc do
    [
      "w-64 space-y-2",
      "[&_[data-part=item]]:flex [&_[data-part=item]]:w-full [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded-md [&_[data-part=item]]:border [&_[data-part=item]]:border-base-300 [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-2 [&_[data-part=item]]:text-left",
      "[&_[data-part=item]]:before:size-4 [&_[data-part=item]]:before:shrink-0 [&_[data-part=item]]:before:rounded-full [&_[data-part=item]]:before:border [&_[data-part=item]]:before:border-base-300 [&_[data-part=item]]:before:content-['']",
      "[&_[data-part=item][data-checked]]:border-primary [&_[data-part=item][data-checked]]:font-semibold [&_[data-part=item][data-checked]]:before:border-[5px] [&_[data-part=item][data-checked]]:before:border-primary",
      "[&_[data-part=item][data-highlighted]]:ring-2 [&_[data-part=item][data-highlighted]]:ring-primary/40 [&_[data-part=item][data-highlighted]]:outline-none"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.SelectFormDemo do
  @moduledoc "select inside a `<.form>` — the listbox's hidden input submits the chosen value, validated."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Select
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @countries [
    {"us", "United States"},
    {"gb", "United Kingdom"},
    {"de", "Germany"},
    {"jp", "Japan"}
  ]

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign(:countries, @countries)
       |> assign_new(:form, fn -> to_form(cs(%{}), as: :ship) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"ship" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do:
        {:noreply,
         assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :ship))},
      else:
        {:noreply, assign(socket, saved: nil, form: to_form(changeset, as: :ship, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save" class="space-y-3">
        <label class="block text-sm font-medium">Ship to (required)</label>
        <Select.select
          id={"#{@id}-country"}
          name={f[:country].name}
          value={f[:country].value}
          placeholder="Choose a country…"
          class={sc()}
        >
          <:option :for={{v, label} <- @countries} value={v}>{label}</:option>
        </Select.select>
        <p :for={msg <- H.field_errors(f[:country])} class="text-sm text-error">{msg}</p>
        <button
          type="submit"
          class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
        >
          Continue
        </button>
      </.form>
      <div
        :if={@saved}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ Shipping to {@saved.country} (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{country: :string}}
    |> cast(p, [:country])
    |> validate_required([:country], message: "please choose a country")
    |> validate_inclusion(:country, Enum.map(@countries, &elem(&1, 0)))
  end

  defp sc do
    [
      "relative inline-block",
      "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:min-w-56 [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:gap-2 [&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:bg-base-100 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-left",
      "[&_[data-part=value][data-placeholder]]:text-base-content/40",
      "[&_[data-part=icon]]:text-base-content/50 [&_[data-part=icon][data-popup-open]]:rotate-180",
      "[&_[data-part=positioner]]:relative",
      "[&_[data-part=popup]]:absolute [&_[data-part=popup]]:left-0 [&_[data-part=popup]]:right-0 [&_[data-part=popup]]:top-full [&_[data-part=popup]]:z-10 [&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:max-h-60 [&_[data-part=popup]]:overflow-auto [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[data-part=popup][data-closed]]:hidden",
      "[&_[data-part=item]]:flex [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded [&_[data-part=item]]:px-2 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:outline-none [&_[data-part=item][data-highlighted]]:bg-base-200 [&_[data-part=item][data-selected]]:font-semibold",
      "[&_[data-part=item-indicator]]:w-4 [&_[data-part=item-indicator]]:shrink-0 [&_[data-part=item-indicator]]:text-xs [&_[data-part=item-indicator]]:opacity-0 [&_[data-part=item][data-selected]_[data-part=item-indicator]]:opacity-100"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.SliderFormDemo do
  @moduledoc "slider inside a `<.form>` — the thumb's hidden input submits the value, validated."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Slider
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{"budget" => "40"}), as: :prefs) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"prefs" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do:
        # On success, reset the form back to its default (40) — the common "form clears after save"
        # pattern. The slider snaps back to 40 (the hook re-positions); @saved keeps what was saved.
        {:noreply,
         assign(socket,
           saved: apply_changes(changeset),
           form: to_form(cs(%{"budget" => "40"}), as: :prefs)
         )},
      else:
        {:noreply,
         assign(socket, saved: nil, form: to_form(changeset, as: :prefs, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save" class="space-y-4">
        <div>
          <label class="mb-2 block text-sm font-medium">Monthly budget (10–80, multiples of 5)</label>
          <Slider.slider
            id={"#{@id}-budget"}
            name={f[:budget].name}
            value={f[:budget].value}
            min={10}
            max={80}
            step={5}
            show_value
            class={slc()}
          />
        </div>
        <p :for={msg <- H.field_errors(f[:budget])} class="text-sm text-error">{msg}</p>
        <button
          type="submit"
          class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content"
        >
          Save budget
        </button>
      </.form>
      <div
        :if={@saved}
        class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success"
      >
        ✓ Budget set to {@saved.budget} (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{budget: :integer}}
    |> cast(p, [:budget])
    |> validate_required([:budget])
    |> validate_number(:budget, greater_than_or_equal_to: 10, less_than_or_equal_to: 80)
  end

  defp slc do
    [
      "inline-block",
      "[&_[data-part=value]]:mb-1 [&_[data-part=value]]:block [&_[data-part=value]]:text-sm [&_[data-part=value]]:tabular-nums [&_[data-part=value]]:text-base-content/70",
      "[&_[data-part=control]]:flex [&_[data-part=control]]:w-64 [&_[data-part=control]]:items-center [&_[data-part=control]]:touch-none [&_[data-part=control]]:select-none [&_[data-part=control]]:py-3",
      "[&_[data-part=track]]:relative [&_[data-part=track]]:h-1.5 [&_[data-part=track]]:w-full [&_[data-part=track]]:rounded-full [&_[data-part=track]]:bg-base-300",
      "[&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-primary",
      "[&_[data-part=thumb]]:size-4 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:border [&_[data-part=thumb]]:border-base-300 [&_[data-part=thumb]]:bg-base-100 [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:cursor-grab [&_[data-part=thumb]]:outline-none focus:[&_[data-part=thumb]]:ring-2 focus:[&_[data-part=thumb]]:ring-primary"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.SliderRangeFormDemo do
  @moduledoc "range slider inside a `<.form>` — two thumbs submit an array; Phoenix-ready value handling."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Slider
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{"price" => [20, 60]}), as: :filters) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"filters" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      # On success, reset the range back to its default [20, 60] (both thumbs re-position).
      do: {:noreply, assign(socket, saved: apply_changes(changeset), form: to_form(cs(%{"price" => [20, 60]}), as: :filters))},
      else: {:noreply, assign(socket, saved: nil, form: to_form(changeset, as: :filters, action: :save))}
  end

  def handle_event("reset", _params, socket),
    do: {:noreply, assign(socket, saved: nil, form: to_form(cs(%{"price" => [20, 60]}), as: :filters))}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-submit="save" :let={f} class="space-y-4">
        <label class="block text-sm font-medium">Price range ($0–$100, two thumbs)</label>
        <Slider.slider
          id={"#{@id}-price"}
          name={f[:price].name}
          values={f[:price].value}
          min={0}
          max={100}
          step={5}
          min_steps_between_values={1}
          show_value
          class={slc()}
        />
        <p :for={msg <- H.field_errors(f[:price])} class="text-sm text-error">{msg}</p>
        <div class="flex gap-2">
          <button type="submit" class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content">
            Apply filter
          </button>
          <button
            type="button"
            phx-target={@myself}
            phx-click="reset"
            class="rounded-md border border-base-300 px-4 py-1.5 text-sm font-medium"
          >
            Reset
          </button>
        </div>
      </.form>
      <div :if={@saved} class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success">
        ✓ Filtering ${Enum.at(@saved.price, 0)}–${Enum.at(@saved.price, 1)} (not persisted)
      </div>
    </div>
    """
  end

  defp slc do
    [
      "inline-block",
      "[&_[data-part=value]]:mb-1 [&_[data-part=value]]:block [&_[data-part=value]]:text-sm [&_[data-part=value]]:tabular-nums [&_[data-part=value]]:text-base-content/70",
      "[&_[data-part=control]]:flex [&_[data-part=control]]:w-64 [&_[data-part=control]]:items-center [&_[data-part=control]]:touch-none [&_[data-part=control]]:select-none [&_[data-part=control]]:py-3",
      "[&_[data-part=track]]:relative [&_[data-part=track]]:h-1.5 [&_[data-part=track]]:w-full [&_[data-part=track]]:rounded-full [&_[data-part=track]]:bg-base-300",
      "[&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-primary",
      "[&_[data-part=thumb]]:size-4 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:border [&_[data-part=thumb]]:border-base-300 [&_[data-part=thumb]]:bg-base-100 [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:cursor-grab [&_[data-part=thumb]]:outline-none focus:[&_[data-part=thumb]]:ring-2 focus:[&_[data-part=thumb]]:ring-primary"
    ]
  end

  defp cs(p) do
    {%{}, %{price: {:array, :integer}}}
    |> cast(p, [:price])
    |> validate_required([:price])
    |> validate_price()
  end

  # Both bounds present, within 0–100, low ≤ high.
  defp validate_price(changeset) do
    case get_field(changeset, :price) do
      [lo, hi] when lo >= 0 and hi <= 100 and lo <= hi -> changeset
      nil -> changeset
      _ -> add_error(changeset, :price, "pick two values between 0 and 100 (low ≤ high)")
    end
  end
end

defmodule DevelopmentWeb.Showcase.SwitchFormDemo do
  @moduledoc "switch inside a `<.form>` — value/unchecked_value submit a boolean; terms must be on."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Switch
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{"notify" => "true", "terms" => "false"}), as: :prefs) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("save", %{"prefs" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do: {:noreply, assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :prefs))},
      else: {:noreply, assign(socket, saved: nil, form: to_form(changeset, as: :prefs, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-submit="save" :let={f} class="space-y-4">
        <div class="flex items-center gap-3">
          <Switch.switch
            id={"#{@id}-notify"}
            name={f[:notify].name}
            value="true"
            unchecked_value="false"
            checked={f[:notify].value in [true, "true"]}
            class={sw()}
          />
          <span class="text-sm font-medium">Email notifications</span>
        </div>
        <div>
          <div class="flex items-center gap-3">
            <Switch.switch
              id={"#{@id}-terms"}
              name={f[:terms].name}
              value="true"
              unchecked_value="false"
              checked={f[:terms].value in [true, "true"]}
              class={sw()}
            />
            <span class="text-sm font-medium">I accept the terms (required)</span>
          </div>
          <p :for={msg <- H.field_errors(f[:terms])} class="mt-1 text-sm text-error">{msg}</p>
        </div>
        <button type="submit" class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content">
          Save settings
        </button>
      </.form>
      <div :if={@saved} class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success">
        ✓ Saved — notifications {if @saved.notify, do: "on", else: "off"}, terms accepted (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{notify: :boolean, terms: :boolean}}
    |> cast(p, [:notify, :terms])
    |> validate_acceptance(:terms, message: "you must accept the terms to continue")
  end

  defp sw do
    [
      "relative inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full border border-base-300 transition-colors",
      "[&[data-checked]]:bg-primary [&[data-unchecked]]:bg-base-300",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/40",
      "[&_[data-part=thumb]]:absolute [&_[data-part=thumb]]:left-0.5 [&_[data-part=thumb]]:size-5 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:bg-base-100 [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:transition-transform [&_[data-part=thumb][data-checked]]:translate-x-5"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.ToggleFormDemo do
  @moduledoc "toggle inside a `<.form>` — opt-in `name` makes it submit a boolean (hidden checkbox)."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Toggle
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{"public" => "false"}), as: :prefs) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("validate", %{"prefs" => p}, socket),
    do: {:noreply, assign(socket, form: to_form(cs(p), as: :prefs))}

  @impl true
  def handle_event("save", %{"prefs" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do: {:noreply, assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :prefs))},
      else: {:noreply, assign(socket, saved: nil, form: to_form(changeset, as: :prefs, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save" :let={f} class="space-y-4">
        <div class="flex items-center gap-3">
          <Toggle.toggle
            id={"#{@id}-public"}
            name={f[:public].name}
            value="true"
            unchecked_value="false"
            pressed={f[:public].value in [true, "true"]}
            class={tc()}
          >
            <span class="hidden data-[pressed]:inline">🌐 Public</span>
            <span class="data-[pressed]:hidden">🔒 Private</span>
          </Toggle.toggle>
          <span class="text-sm font-medium">Profile visibility</span>
        </div>
        <button type="submit" class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content">
          Save settings
        </button>
      </.form>
      <div :if={@saved} class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success">
        ✓ Profile is {if @saved.public, do: "public 🌐", else: "private 🔒"} (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p), do: {%{}, %{public: :boolean}} |> cast(p, [:public])

  defp tc do
    [
      "inline-flex items-center gap-2 rounded-md border border-base-300 bg-base-100 px-3 py-1.5 text-sm transition-colors",
      "data-[pressed]:border-primary data-[pressed]:bg-primary data-[pressed]:text-primary-content",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/40"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.ToggleGroupFormDemo do
  @moduledoc "toggle_group in a `<.form>` — single-select submits a value, multiple submits name[]."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.ToggleGroup
  import Ecto.Changeset
  alias DevelopmentWeb.Showcase.FormDemoHelpers, as: H

  @aligns ~w(left center right)
  @styles ~w(bold italic underline)

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:form, fn -> to_form(cs(%{"align" => "center", "styles" => ["bold"]}), as: :fmt) end)
       |> assign_new(:saved, fn -> nil end)}

  @impl true
  def handle_event("validate", %{"fmt" => p}, socket),
    do: {:noreply, assign(socket, form: to_form(cs(p), as: :fmt))}

  @impl true
  def handle_event("save", %{"fmt" => p}, socket) do
    changeset = cs(p)

    if changeset.valid?,
      do: {:noreply, assign(socket, saved: apply_changes(changeset), form: to_form(changeset, as: :fmt))},
      else: {:noreply, assign(socket, saved: nil, form: to_form(changeset, as: :fmt, action: :save))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save" :let={f} class="space-y-4">
        <div>
          <span class="mb-1.5 block text-sm font-medium">Alignment (single, required)</span>
          <ToggleGroup.toggle_group id={"#{@id}-align"} name={f[:align].name} value={f[:align].value} class={tgc()}>
            <:item value="left">Left</:item>
            <:item value="center">Center</:item>
            <:item value="right">Right</:item>
          </ToggleGroup.toggle_group>
          <p :for={msg <- H.field_errors(f[:align])} class="mt-1 text-sm text-error">{msg}</p>
        </div>
        <div>
          <span class="mb-1.5 block text-sm font-medium">Styles (multiple, optional)</span>
          <ToggleGroup.toggle_group id={"#{@id}-styles"} name={f[:styles].name} multiple value={f[:styles].value} class={tgc()}>
            <:item value="bold">Bold</:item>
            <:item value="italic">Italic</:item>
            <:item value="underline">Underline</:item>
          </ToggleGroup.toggle_group>
        </div>
        <button type="submit" class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-primary-content">
          Apply formatting
        </button>
      </.form>
      <div :if={@saved} class="mt-3 rounded-md border border-success/40 bg-success/10 p-3 text-sm font-medium text-success">
        ✓ {@saved.align} · {(@saved.styles == [] && "no styles") || Enum.join(@saved.styles, ", ")} (not persisted)
      </div>
    </div>
    """
  end

  defp cs(p) do
    {%{}, %{align: :string, styles: {:array, :string}}}
    |> cast(p, [:align, :styles])
    |> validate_required([:align], message: "pick an alignment")
    |> validate_inclusion(:align, @aligns)
    |> validate_subset(:styles, @styles)
  end

  defp tgc do
    [
      "inline-flex gap-1 rounded-md border border-base-300 bg-base-100 p-1",
      "[&_[data-part=item]]:rounded [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item]]:text-base-content [&_[data-part=item]]:outline-none [&_[data-part=item]]:not-data-disabled:hover:bg-base-200",
      "[&_[data-part=item][data-pressed]]:bg-primary [&_[data-part=item][data-pressed]]:text-primary-content",
      "[&_[data-part=item]]:focus-visible:ring-2 [&_[data-part=item]]:focus-visible:ring-primary/40"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.TabsServerDemo do
  @moduledoc "tabs pushing the active tab to the server (on_change) and being controlled by it (value)."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.Tabs

  @tabs [{"overview", "Overview"}, {"activity", "Activity"}, {"settings", "Settings"}]

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign(:tabs, @tabs)
       |> assign_new(:active, fn -> "overview" end)
       |> assign_new(:switches, fn -> 0 end)}

  @impl true
  def handle_event("switch", %{"value" => v}, socket),
    do: {:noreply, assign(socket, active: v, switches: socket.assigns.switches + 1)}

  def handle_event("set", %{"v" => v}, socket),
    do: {:noreply, assign(socket, active: v, switches: socket.assigns.switches + 1)}

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <Tabs.tabs
        id={"#{@id}-tabs"}
        value={@active}
        on_change="switch"
        on_change_target={"##{@id}"}
        class={tc()}
      >
        <:tab :for={{v, label} <- @tabs} value={v}>{label}</:tab>
        <:panel :for={{v, _} <- @tabs} value={v}>
          Server-rendered panel for <strong>{v}</strong>.
        </:panel>
      </Tabs.tabs>

      <div class="mt-3 flex items-center justify-between rounded-md border border-base-300 bg-base-100 px-3 py-2 text-sm">
        <span>Server active tab: <strong>{@active}</strong> · {@switches} switches</span>
        <button
          type="button"
          phx-target={@myself}
          phx-click="set"
          phx-value-v="settings"
          class="rounded bg-primary px-2.5 py-1 text-xs font-medium text-primary-content"
        >
          Set to Settings (from server)
        </button>
      </div>
    </div>
    """
  end

  defp tc do
    [
      "w-full",
      "[&_[data-part=tablist]]:relative [&_[data-part=tablist]]:flex [&_[data-part=tablist]]:gap-1 [&_[data-part=tablist]]:border-b [&_[data-part=tablist]]:border-base-300",
      "[&_[data-part=tab]]:px-3 [&_[data-part=tab]]:py-1.5 [&_[data-part=tab]]:text-sm [&_[data-part=tab]]:text-base-content/60 [&_[data-part=tab]]:outline-none [&_[data-part=tab][data-active]]:text-base-content [&_[data-part=tab][data-active]]:font-semibold",
      "[&_[data-part=indicator]]:absolute [&_[data-part=indicator]]:-bottom-px [&_[data-part=indicator]]:left-0 [&_[data-part=indicator]]:h-0.5 [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-primary [&_[data-part=indicator]]:[width:var(--active-tab-width)] [&_[data-part=indicator]]:[translate:var(--active-tab-left)_0] [&_[data-part=indicator]]:transition-[translate,width] [&_[data-part=indicator]]:duration-200",
      "[&_[data-part=panel]]:bg-base-100 [&_[data-part=panel]]:p-3 [&_[data-part=panel]]:text-sm"
    ]
  end
end

defmodule DevelopmentWeb.Showcase.AlertDialogDemo do
  @moduledoc "alert dialog driving a server action — confirm deletes an item (and on_open_change tracks it)."
  use DevelopmentWeb, :live_component
  alias DevelopmentWeb.Components.Headless.AlertDialog

  @impl true
  def update(assigns, socket),
    do:
      {:ok,
       socket
       |> assign(assigns)
       |> assign_new(:items, fn -> 3 end)
       |> assign_new(:opened, fn -> 0 end)
       |> assign_new(:open, fn -> false end)}

  @impl true
  def handle_event("delete", _p, socket), do: {:noreply, assign(socket, items: max(0, socket.assigns.items - 1))}

  # Controlled: track `open` so the on_open_change re-render confirms the open state
  # (instead of resetting data-open and closing the dialog).
  def handle_event("toggled", %{"open" => true}, socket),
    do: {:noreply, assign(socket, open: true, opened: socket.assigns.opened + 1)}

  def handle_event("toggled", %{"open" => false}, socket), do: {:noreply, assign(socket, open: false)}

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="space-y-2">
      <p class="text-sm">Items remaining: <strong>{@items}</strong> · opened {@opened}×</p>
      <AlertDialog.alert_dialog
        id={"#{@id}-dlg"}
        open={@open}
        on_open_change="toggled"
        on_open_change_target={"##{@id}"}
        class={adc()}
      >
        <:trigger>Delete an item…</:trigger>
        <:title>Delete this item?</:title>
        <:description>This permanently removes the item. This action cannot be undone.</:description>
        <:actions>
          <button class="rounded-md border border-base-300 px-3 py-1.5 text-sm" data-close>Cancel</button>
          <button
            class="rounded-md bg-error px-3 py-1.5 text-sm font-medium text-error-content"
            data-close
            phx-target={@myself}
            phx-click="delete"
          >
            Delete
          </button>
        </:actions>
      </AlertDialog.alert_dialog>
    </div>
    """
  end

  defp adc do
    [
      "[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger][data-popup-open]]:bg-base-200",
      "[&_[data-part=backdrop]]:fixed [&_[data-part=backdrop]]:inset-0 [&_[data-part=backdrop]]:z-40 [&_[data-part=backdrop]]:bg-black/40",
      "[&_[data-part=popup]]:fixed [&_[data-part=popup]]:left-1/2 [&_[data-part=popup]]:top-1/2 [&_[data-part=popup]]:z-50 [&_[data-part=popup]]:w-80 [&_[data-part=popup]]:-translate-x-1/2 [&_[data-part=popup]]:-translate-y-1/2 [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-6 [&_[data-part=popup]]:shadow-xl",
      "[&_[data-part=title]]:text-lg [&_[data-part=title]]:font-semibold [&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-sm [&_[data-part=description]]:text-base-content/70",
      "[&_[data-part=actions]]:mt-4 [&_[data-part=actions]]:flex [&_[data-part=actions]]:justify-end [&_[data-part=actions]]:gap-2"
    ]
  end
end
