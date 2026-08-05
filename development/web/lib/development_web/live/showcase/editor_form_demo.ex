defmodule DevelopmentWeb.Showcase.EditorFormDemo do
  @moduledoc """
  `editor` inside a Phoenix `<.form>`. The engine mirrors the document into a hidden textarea and
  dispatches `input`, so `phx-change "validate"` fires as you type (debounced in the engine) and
  Save submits it as `post[body]`. The toolbar buttons are plain `<button data-editor-command>` —
  the engine wires them and marks the active ones with `data-active`. Nothing is persisted.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.Editor

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:body, fn -> nil end)
     |> assign_new(:saved, fn -> nil end)}
  end

  @impl true
  def handle_event("validate", %{"post" => %{"body" => body}}, socket) do
    {:noreply, assign(socket, body: body)}
  end

  def handle_event("save", %{"post" => %{"body" => body}}, socket) do
    {:noreply, assign(socket, saved: body)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl space-y-3">
      <.form
        for={to_form(%{"body" => @body}, as: :post)}
        id={"#{@id}-form"}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.editor
          id={"#{@id}-ed"}
          name="post[body]"
          value={@body}
          placeholder="Write something…"
          class={editor_class()}
          toolbar_class={toolbar_class()}
          surface_class={surface_class()}
        >
          <:toolbar>
            <button :for={{cmd, label} <- marks()} type="button" data-editor-command={cmd}>
              {label}
            </button>
            <span class="mx-1 w-px self-stretch bg-[var(--c-base-300)]"></span>
            <button :for={{cmd, label} <- blocks()} type="button" data-editor-command={cmd}>
              {label}
            </button>
          </:toolbar>
        </.editor>

        <button
          type="submit"
          class="mt-3 rounded-md bg-[var(--c-primary)] px-3 py-1.5 text-sm font-medium text-primary-content"
        >
          Save
        </button>
      </.form>

      <p class="text-xs text-[var(--c-base-content)]/50">
        Live length (server sees every edit): <strong>{String.length(@body || "")}</strong>
        chars of <code>post[body]</code>
      </p>

      <details :if={@saved} open class="rounded-md border border-[var(--c-base-300)] p-3">
        <summary class="cursor-pointer text-sm font-medium">Submitted document</summary>
        <pre class="mt-2 overflow-x-auto text-xs whitespace-pre-wrap">{@saved}</pre>
      </details>
    </div>
    """
  end

  defp marks, do: [{"bold", "B"}, {"italic", "I"}, {"strike", "S"}, {"code", "</>"}]

  defp blocks,
    do: [
      {"h1", "H1"},
      {"h2", "H2"},
      {"bullet_list", "• List"},
      {"ordered_list", "1. List"},
      {"blockquote", "❝"},
      {"undo", "↶"},
      {"redo", "↷"}
    ]

  defp editor_class do
    "rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] " <>
      "data-[focused]:ring-2 data-[focused]:ring-[var(--c-primary)]/30"
  end

  defp toolbar_class do
    "flex flex-wrap items-center gap-1 border-b border-[var(--c-base-300)] p-1.5 " <>
      "[&>button]:rounded [&>button]:px-2 [&>button]:py-1 [&>button]:text-sm " <>
      "[&>button]:text-[var(--c-base-content)]/70 [&>button:hover]:bg-[var(--c-base-200)] " <>
      "[&>button[data-active]]:bg-[var(--c-primary)]/10 [&>button[data-active]]:text-[var(--c-primary)] " <>
      "[&>button[data-active]]:font-semibold"
  end

  # The editor ships no typography (headless CSS is functional-only), so under Tailwind Preflight
  # headings/lists/quotes render flat. This is the consuming app's job — here is one way to do it.
  defp surface_class do
    "min-h-40 p-3 text-sm leading-6 outline-none " <>
      "[&_h1]:mt-2 [&_h1]:mb-1 [&_h1]:text-2xl [&_h1]:font-bold " <>
      "[&_h2]:mt-2 [&_h2]:mb-1 [&_h2]:text-xl [&_h2]:font-semibold " <>
      "[&_p]:my-1 " <>
      "[&_ul]:my-1 [&_ul]:list-disc [&_ul]:pl-6 " <>
      "[&_ol]:my-1 [&_ol]:list-decimal [&_ol]:pl-6 " <>
      "[&_blockquote]:my-2 [&_blockquote]:border-l-2 [&_blockquote]:border-[var(--c-base-300)] [&_blockquote]:pl-3 [&_blockquote]:text-[var(--c-base-content)]/70 " <>
      "[&_code]:rounded [&_code]:bg-[var(--c-base-200)] [&_code]:px-1 [&_code]:font-mono [&_code]:text-[0.85em] " <>
      "[&_pre]:my-2 [&_pre]:overflow-x-auto [&_pre]:rounded [&_pre]:bg-[var(--c-base-200)] [&_pre]:p-2 " <>
      "before:text-[var(--c-base-content)]/40"
  end
end
