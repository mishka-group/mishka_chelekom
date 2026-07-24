defmodule DevelopmentWeb.Showcase.EditorEnginesDemo do
  @moduledoc """
  The same `editor` component backed by each of its four engines, side by side.

  In a real app you generate ONE of these — `mix mishka.ui.gen.headless editor --lib <name>` — and
  the engine installs as `editor.js` under the `Editor` hook. The harness vendors all four under
  distinct hook names purely so they can be compared here; that is what the `hook` attr is for.

  Note what does NOT change between them: the markup, the attrs, the hidden-mirror form wiring and
  the `data-*` state. Only `format` differs, because each engine produces a different document.
  """
  use DevelopmentWeb, :live_component

  import DevelopmentWeb.Components.Headless.Editor

  @engines [
    %{
      lib: "tiptap",
      hook: "Editor",
      format: "json",
      title: "TipTap 3 — rich text",
      blurb: "The default. Stores the ProseMirror document as JSON.",
      value: nil
    },
    %{
      lib: "lexical",
      hook: "EditorLexical",
      format: "json",
      title: "Lexical — rich text",
      blurb: "Meta's engine. Also JSON; teardown is manual (setRootElement(nil)).",
      value: nil
    },
    %{
      lib: "code_mirror",
      hook: "EditorCodeMirror",
      format: "text",
      title: "CodeMirror 6 — code",
      blurb: "Syntax highlighting, line numbers. The document is plain text.",
      value: "export const sum = (a, b) => a + b;\n"
    },
    %{
      lib: "milk_down",
      hook: "EditorMilkDown",
      format: "markdown",
      title: "Milkdown 7 — markdown",
      blurb: "Round-trips real markdown source, not HTML.",
      value: "# Hello\n\nSome **markdown** with a [link](https://mishka.tools).\n"
    }
  ]

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(engines: @engines)
     |> assign_new(:values, fn -> Map.new(@engines, &{&1.lib, &1.value}) end)}
  end

  @impl true
  def handle_event("changed", %{"lib" => lib} = params, socket) do
    value = get_in(params, ["engine", "value"])
    {:noreply, assign(socket, values: Map.put(socket.assigns.values, lib, value))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div :for={engine <- @engines} class="space-y-1">
        <div class="flex items-baseline justify-between gap-2">
          <h4 class="text-sm font-semibold">{engine.title}</h4>
          <code class="text-[0.7rem] text-[var(--c-base-content)]/50">
            --lib {engine.lib} · format="{engine.format}"
          </code>
        </div>
        <p class="text-xs text-[var(--c-base-content)]/60">{engine.blurb}</p>

        <.form
          for={%{}}
          as={:engine}
          id={"#{@id}-#{engine.lib}-form"}
          phx-target={@myself}
          phx-change="changed"
          phx-value-lib={engine.lib}
        >
          <input type="hidden" name="lib" value={engine.lib} />
          <.editor
            id={"#{@id}-#{engine.lib}"}
            hook={engine.hook}
            name="engine[value]"
            format={engine.format}
            value={@values[engine.lib]}
            placeholder="Type here…"
            class={editor_class()}
            surface_class={surface_class(engine.format)}
          />
        </.form>

        <p class="text-[0.7rem] text-[var(--c-base-content)]/50">
          server sees <strong>{String.length(@values[engine.lib] || "")}</strong> chars
        </p>
      </div>
    </div>
    """
  end

  defp editor_class do
    "w-full rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] " <>
      "data-[focused]:ring-2 data-[focused]:ring-[var(--c-primary)]/30"
  end

  # Headless ships no typography, so each demo supplies its own. The code engine wants a mono
  # face and no prose spacing; the prose engines want headings and lists to look like headings
  # and lists.
  defp surface_class("text") do
    "min-h-28 text-sm [&_.cm-editor]:min-h-28 [&_.cm-scroller]:font-mono " <>
      "[&_.cm-gutters]:bg-[var(--c-base-200)] [&_.cm-gutters]:text-[var(--c-base-content)]/40 " <>
      "[&_.cm-activeLine]:bg-[var(--c-primary)]/5"
  end

  defp surface_class(_) do
    "min-h-28 p-3 text-sm leading-6 outline-none before:text-[var(--c-base-content)]/40 " <>
      "[&_h1]:mt-2 [&_h1]:mb-1 [&_h1]:text-xl [&_h1]:font-bold " <>
      "[&_h2]:mt-2 [&_h2]:mb-1 [&_h2]:text-lg [&_h2]:font-semibold " <>
      "[&_p]:my-1 [&_ul]:my-1 [&_ul]:list-disc [&_ul]:pl-6 [&_ol]:my-1 [&_ol]:list-decimal [&_ol]:pl-6 " <>
      "[&_blockquote]:my-2 [&_blockquote]:border-l-2 [&_blockquote]:border-[var(--c-base-300)] [&_blockquote]:pl-3 " <>
      "[&_code]:rounded [&_code]:bg-[var(--c-base-200)] [&_code]:px-1 [&_code]:font-mono [&_code]:text-[0.85em] " <>
      "[&_a]:text-[var(--c-primary)] [&_a]:underline"
  end
end
