defmodule DevelopmentWeb.Showcase.HeadlessLive do
  @moduledoc """
  Showcase for the headless component layer: unstyled markup + ARIA + behavior hooks.
  Index at `/showcase/headless`, live examples at `/showcase/headless/:component`.
  """
  use DevelopmentWeb, :live_view

  alias DevelopmentWeb.Showcase.{HeadlessCatalog, HeadlessPreview}

  @impl true
  def mount(_params, _session, socket), do: {:ok, assign(socket, :catalog, HeadlessCatalog.all())}

  @impl true
  def handle_params(%{"component" => name}, _uri, socket) do
    case HeadlessCatalog.get(name) do
      nil -> {:noreply, push_navigate(socket, to: ~p"/showcase/headless")}
      comp -> {:noreply, assign(socket, component: comp, page_title: "headless #{name}")}
    end
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, component: nil, page_title: "Headless components")}
  end

  @impl true
  def render(%{component: nil} = assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
      <header class="bg-base-100 border-b border-base-300">
        <div class="max-w-5xl mx-auto px-6 py-10">
          <.link navigate={~p"/showcase"} class="text-sm text-base-content/60 hover:underline">
            ← Styled components
          </.link>
          <h1 class="text-4xl font-bold mt-1">Headless components</h1>
          <p class="mt-2 text-base-content/70">
            Unstyled markup + full WAI-ARIA wiring + a shared JS behavior core.
            Bring your own CSS — target the <code>chelekom-*</code> classes and
            <code>data-*</code> state.
          </p>
        </div>
      </header>
      <main class="max-w-5xl mx-auto px-6 py-8 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <.link
          :for={c <- @catalog}
          navigate={~p"/showcase/headless/#{c.name}"}
          class="block bg-base-100 rounded-box p-5 shadow-sm hover:ring-2 hover:ring-primary/40 transition"
        >
          <div class="font-semibold capitalize">{c.name}</div>
          <div class="text-xs text-base-content/60 mt-1">{c.pattern}</div>
          <div class="mt-2 flex flex-wrap gap-1">
            <span :for={h <- c.hooks} class="badge badge-ghost badge-sm">{h}</span>
          </div>
        </.link>
      </main>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
      <main class="max-w-4xl mx-auto px-6 py-8 space-y-6">
        <header class="space-y-1">
          <.link navigate={~p"/showcase/headless"} class="text-sm text-base-content/60 hover:underline">
            ← All headless
          </.link>
          <h1 class="text-3xl font-bold capitalize">{@component.name}</h1>
          <p class="text-base-content/60">
            <span class="badge badge-sm">{@component.category}</span>
            <span class="ml-2 text-sm">APG: {@component.pattern}</span>
            <span :for={h <- @component.hooks} class="badge badge-ghost badge-sm ml-1">{h}</span>
          </p>
        </header>

        <div class="bg-base-100 rounded-box p-8 shadow-sm">
          <div class="text-xs uppercase tracking-wide text-base-content/40 mb-4">
            Live preview (try keyboard + mouse)
          </div>
          <div class="flex flex-wrap items-start gap-4 min-h-32">
            <HeadlessPreview.show component={@component.name} id={"hl-#{@component.name}"} />
          </div>
        </div>

        <div class="bg-base-300 rounded-box p-5 text-sm">
          Headless components ship <strong>no colors or spacing</strong>. The classes you see in
          this preview are added by the showcase for legibility only — in your app you style the
          <code>chelekom-{@component.name}*</code> hooks and <code>data-open</code>/<code>data-closed</code> state.
        </div>
      </main>
    </div>
    """
  end
end
