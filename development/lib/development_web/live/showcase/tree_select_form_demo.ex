defmodule DevelopmentWeb.Showcase.TreeSelectFormDemo do
  @moduledoc """
  `tree_select` composing a `tree` in a popover. Selecting a node pushes the tree's `on_select`
  (`handle_event "select"`), which updates the shown label and a hidden form field; Save submits the
  chosen value (`handle_event "save"`). Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.TreeSelect
  import DevelopmentWeb.Components.Headless.Tree

  @nodes [
    %{
      label: "Design",
      value: "design",
      children: [
        %{label: "Wireframes", value: "wireframes"},
        %{label: "Mockups", value: "mockups"}
      ]
    },
    %{
      label: "Engineering",
      value: "engineering",
      children: [
        %{
          label: "Frontend",
          value: "frontend",
          children: [
            %{label: "LiveView", value: "liveview"},
            %{label: "Tailwind", value: "tailwind"}
          ]
        },
        %{label: "Backend", value: "backend"}
      ]
    },
    %{label: "Docs", value: "docs"}
  ]

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:nodes, @nodes)
     |> assign_new(:value, fn -> nil end)
     |> assign_new(:label, fn -> nil end)
     |> assign_new(:saved, fn -> nil end)}
  end

  @impl true
  def handle_event("select", %{"values" => values}, socket) do
    value = List.first(values)
    {:noreply, assign(socket, value: value, label: label_for(value))}
  end

  def handle_event("save", %{"tree_demo" => %{"node" => node}}, socket) do
    {:noreply, assign(socket, saved: node)}
  end

  defp label_for(nil), do: nil
  defp label_for(value), do: Map.get(labels(), value)

  defp labels, do: Map.new(flatten(@nodes))

  defp flatten(nodes) do
    Enum.flat_map(nodes, fn node ->
      [{node.value, node.label} | flatten(Map.get(node, :children) || [])]
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-sm space-y-3">
      <.form for={to_form(%{}, as: :tree_demo)} phx-target={@myself} phx-submit="save">
        <input type="hidden" name="tree_demo[node]" value={@value || ""} />
        <.tree_select
          id={"#{@id}-ts"}
          label={@label}
          placeholder="Choose a category…"
          class="relative inline-block w-64"
          trigger_class="flex w-full items-center justify-between gap-2 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-3 py-1.5 text-sm hover:bg-[var(--c-base-200)]"
          value_class="truncate data-[placeholder]:text-[var(--c-base-content)]/50"
          panel_class="absolute left-0 z-20 mt-2 max-h-64 w-64 overflow-auto rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-2 shadow-lg"
        >
          <.tree
            id={"#{@id}-tree"}
            nodes={@nodes}
            selected={(@value && [@value]) || []}
            expanded={:all}
            select_on_click
            multiple={false}
            on_select="select"
            on_target={@myself}
            aria_label="Categories"
            class="text-sm select-none"
            label_class="flex items-center gap-1 rounded px-2 py-1 cursor-pointer [padding-left:calc(var(--label-offset)+0.5rem)] hover:bg-[var(--c-base-200)] data-[selected]:bg-[var(--c-primary)]/10 data-[selected]:font-medium data-[selected]:text-[var(--c-primary)]"
            label_text_class="truncate"
            expand_icon_class="inline-block w-3 text-center text-[var(--c-base-content)]/50"
          >
            <:expand_icon>▸</:expand_icon>
          </.tree>
        </.tree_select>
        <button
          type="submit"
          class="mt-3 block rounded-md bg-[var(--c-primary)] px-3 py-1.5 text-sm font-medium text-primary-content"
        >
          Save
        </button>
      </.form>
      <p :if={@saved} class="text-sm">
        <span class="text-[var(--c-base-content)]/60">Saved value:</span>
        <span class="font-mono">{@saved}</span>
      </p>
    </div>
    """
  end
end
