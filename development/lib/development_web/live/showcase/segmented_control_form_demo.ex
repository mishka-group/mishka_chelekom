defmodule DevelopmentWeb.Showcase.SegmentedControlFormDemo do
  @moduledoc """
  Interactive `segmented_control` inside a Phoenix `<.form phx-change>`: selecting a segment fires the
  native change, the server records it (`handle_event "pick"`) and echoes the value; it submits as
  `sc_demo[view]`. Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.SegmentedControl

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_new(:value, fn -> "grid" end)}
  end

  @impl true
  def handle_event("pick", %{"sc_demo" => %{"view" => v}}, socket) do
    {:noreply, assign(socket, value: v)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={to_form(%{"view" => @value}, as: :sc_demo)} phx-target={@myself} phx-change="pick">
        <.segmented_control
          id={"#{@id}-sc"}
          name="sc_demo[view]"
          value={@value}
          options={[{"Grid", "grid"}, {"List", "list"}, {"Table", "table"}]}
          label="View"
          class={scc()}
        />
      </.form>
      <p class="mt-2 text-sm text-[var(--c-base-content)]/60">
        Selected (server): <strong>{@value}</strong> — submits as <code>sc_demo[view]</code>
      </p>
    </div>
    """
  end

  defp scc do
    [
      "inline-flex rounded-lg bg-[var(--c-base-200)] p-1",
      "[&_[data-part=item]]:relative [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:rounded-md [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1 [&_[data-part=item]]:text-sm [&_[data-part=item]]:text-[var(--c-base-content)]/70",
      "[&_[data-part=item]:has(:checked)]:bg-[var(--c-base-100)] [&_[data-part=item]:has(:checked)]:font-medium [&_[data-part=item]:has(:checked)]:text-[var(--c-base-content)] [&_[data-part=item]:has(:checked)]:shadow-sm",
      "[&_[data-part=item]:has(:focus-visible)]:ring-2 [&_[data-part=item]:has(:focus-visible)]:ring-[var(--c-primary)]/40"
    ]
  end
end
