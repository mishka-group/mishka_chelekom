defmodule DevelopmentWeb.Showcase.EditorControlDemo do
  @moduledoc """
  The server driving an editor that lives behind `phx-update="ignore"`.

  Two things are being demonstrated, and both are things a normal re-render cannot do:

    * **Setting content** — the surface is ignored, so re-rendering `value` would not reach it.
      `push_event("chelekom:editor", %{id: ..., value: ...})` is the one channel in. The event
      name is global and filtered by id in the payload, so several editors can coexist.

    * **Toggling editable** — `data-*` IS merged on an ignored element, so flipping `editable`
      re-renders through to the engine, which reconfigures in place. The document, cursor and
      undo history all survive; nothing is rebuilt.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.Editor

  @samples %{
    "empty" => ~s({"type":"doc","content":[{"type":"paragraph"}]}),
    "hello" =>
      ~s({"type":"doc","content":[{"type":"heading","attrs":{"level":2},"content":[{"type":"text","text":"Pushed from the server"}]},{"type":"paragraph","content":[{"type":"text","text":"This document was set with push_event/3, not a re-render."}]}]}),
    "list" =>
      ~s({"type":"doc","content":[{"type":"bulletList","content":[{"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"one"}]}]},{"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"two"}]}]}]}]})
  }

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_new(:editable, fn -> true end)}
  end

  @impl true
  def handle_event("push", %{"sample" => sample}, socket) do
    {:noreply,
     push_event(socket, "chelekom:editor", %{
       id: "#{socket.assigns.id}-ed",
       value: Map.fetch!(@samples, sample)
     })}
  end

  def handle_event("toggle_editable", _params, socket) do
    {:noreply, assign(socket, editable: !socket.assigns.editable)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-3">
      <div class="flex flex-wrap items-center gap-2">
        <button
          :for={
            {sample, label} <- [
              {"hello", "Push a heading"},
              {"list", "Push a list"},
              {"empty", "Clear"}
            ]
          }
          type="button"
          phx-click="push"
          phx-value-sample={sample}
          phx-target={@myself}
          class="rounded-md border border-[var(--c-base-300)] px-2.5 py-1 text-sm hover:bg-[var(--c-base-200)]"
        >
          {label}
        </button>

        <button
          type="button"
          phx-click="toggle_editable"
          phx-target={@myself}
          class="ml-auto rounded-md border border-[var(--c-base-300)] px-2.5 py-1 text-sm hover:bg-[var(--c-base-200)]"
        >
          {(@editable && "Make read-only") || "Make editable"}
        </button>
      </div>

      <.editor
        id={"#{@id}-ed"}
        placeholder="Type, then push content from the server — or lock it."
        editable={@editable}
        class={"w-full rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] " <>
               "data-[focused]:ring-2 data-[focused]:ring-[var(--c-primary)]/30 " <>
               "data-[readonly]:opacity-70"}
        surface_class={surface_class()}
      />

      <p class="text-xs text-[var(--c-base-content)]/50">
        editable: <strong>{to_string(@editable)}</strong>
        — flipped through <code>data-editable</code>, the only attribute kind that crosses an
        ignored boundary. Type first, then toggle: your text and cursor survive.
      </p>
    </div>
    """
  end

  defp surface_class do
    "min-h-32 p-3 text-sm leading-6 outline-none before:text-[var(--c-base-content)]/40 " <>
      "[&_h2]:mt-2 [&_h2]:mb-1 [&_h2]:text-lg [&_h2]:font-semibold " <>
      "[&_p]:my-1 [&_ul]:my-1 [&_ul]:list-disc [&_ul]:pl-6"
  end
end
