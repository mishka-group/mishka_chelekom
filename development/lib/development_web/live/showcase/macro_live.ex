defmodule DevelopmentWeb.Showcase.MacroLive do
  @moduledoc """
  Demonstrates the `MishkaChelekom.Component` macro: one declarative `component/2` producing a
  styled button (live variant controls) and a headless disclosure — both shown with their
  declaration source.
  """
  use DevelopmentWeb, :live_view

  import DevelopmentWeb.MacroComponents

  @decl_button """
  component :m_button,
    tag: :button,
    base: "inline-flex items-center font-medium rounded-md",
    variants: [
      color: [primary: "bg-primary text-primary-content", ghost: "...", danger: "..."],
      size:  [sm: "h-8 px-3 text-xs", md: "h-9 px-4 text-sm", lg: "h-11 px-6"]
    ],
    defaults: [color: :primary, size: :md]
  """

  @decl_disclosure """
  component :m_disclosure,
    headless: true,
    hook: "Disclosure",
    parts: [
      trigger: [tag: :button, id: true, slot: true,
                aria: [controls: {:ref, :panel}, expanded: "false"]],
      panel:   [tag: :div, id: true, role: "region", state: true,
                aria: [labelledby: {:ref, :trigger}], slot: :inner_block]
    ]
  """

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       color: :primary,
       size: :md,
       page_title: "component macro",
       decl_button: @decl_button,
       decl_disclosure: @decl_disclosure
     )}
  end

  @impl true
  def handle_event("update", %{"color" => c, "size" => s}, socket) do
    {:noreply, assign(socket, color: String.to_existing_atom(c), size: String.to_existing_atom(s))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
      <main class="max-w-4xl mx-auto px-6 py-8 space-y-8">
        <header class="space-y-1">
          <.link navigate={~p"/showcase"} class="text-sm text-base-content/60 hover:underline">
            ← Showcase
          </.link>
          <h1 class="text-3xl font-bold">The <code>component</code> macro</h1>
          <p class="text-base-content/70">
            One declarative block → a real component. Styled (variants + overrides + merge) and
            headless (parts + ARIA + hook), from the same macro.
          </p>
        </header>

        <section class="bg-base-100 rounded-box p-6 shadow-sm space-y-4">
          <h2 class="font-semibold">Styled — <code>m_button</code></h2>
          <form phx-change="update" class="flex gap-4">
            <label class="text-sm">color
              <select name="color" class="select select-bordered select-sm ml-1">
                <option :for={c <- ~w(primary ghost danger)} value={c} selected={to_string(@color) == c}>{c}</option>
              </select>
            </label>
            <label class="text-sm">size
              <select name="size" class="select select-bordered select-sm ml-1">
                <option :for={s <- ~w(sm md lg)} value={s} selected={to_string(@size) == s}>{s}</option>
              </select>
            </label>
          </form>
          <div class="p-6 bg-base-200 rounded-box flex justify-center">
            <.m_button color={@color} size={@size}>Save changes</.m_button>
          </div>
          <pre class="text-xs bg-base-300 rounded-box p-4 overflow-x-auto"><code>{@decl_button}</code></pre>
        </section>

        <section class="bg-base-100 rounded-box p-6 shadow-sm space-y-4">
          <h2 class="font-semibold">Headless — <code>m_disclosure</code></h2>
          <div class="p-6 bg-base-200 rounded-box">
            <.m_disclosure
              id="macro-disc"
              class="w-80 [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-2 [&_[data-part=trigger]]:text-left [&_[data-part=panel]]:mt-2 [&_[data-part=panel]]:rounded-md [&_[data-part=panel]]:border [&_[data-part=panel]]:border-base-300 [&_[data-part=panel]]:p-3 [&_[data-part=panel]]:text-sm"
            >
              <:trigger>What did the macro generate?</:trigger>
              Full ARIA wiring (aria-controls/expanded/labelledby), data-part hooks,
              paired-presence data-open/data-closed, and the Disclosure JS hook — all from the
              parts block. You style the chelekom-m_disclosure* classes.
            </.m_disclosure>
          </div>
          <pre class="text-xs bg-base-300 rounded-box p-4 overflow-x-auto"><code>{@decl_disclosure}</code></pre>
        </section>
      </main>
    </div>
    """
  end
end
