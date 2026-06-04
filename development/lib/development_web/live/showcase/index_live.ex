defmodule DevelopmentWeb.Showcase.IndexLive do
  @moduledoc """
  Showcase landing page: every generated Mishka Chelekom component, grouped by category,
  with a quick summary of its styling dimensions and links to the interactive explorer and
  the official docs.
  """
  use DevelopmentWeb, :live_view

  alias DevelopmentWeb.Showcase.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:by_category, Catalog.by_category())
     |> assign(:count, Catalog.count())
     |> assign(:page_title, "Mishka Chelekom · Showcase")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
      <header class="bg-base-100 border-b border-base-300">
        <div class="max-w-6xl mx-auto px-6 py-10">
          <h1 class="text-4xl font-bold">Mishka Chelekom — Dev Harness</h1>
          <p class="mt-2 text-base-content/70">
            {@count} styled components on Phoenix 1.8 / LiveView 1.1 / Tailwind 4.
            Pick a component to explore its props live.
          </p>
          <.link navigate={~p"/showcase/headless"} class="btn btn-primary btn-sm mt-4">
            Explore the headless layer →
          </.link>
        </div>
      </header>

      <main class="max-w-6xl mx-auto px-6 py-8 space-y-10">
        <section :for={{category, components} <- @by_category}>
          <h2 class="text-xl font-semibold capitalize mb-4 flex items-center gap-2">
            {category}
            <span class="badge badge-neutral badge-sm">{length(components)}</span>
          </h2>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <.link
              :for={c <- components}
              navigate={~p"/showcase/#{c.name}"}
              class="block bg-base-100 rounded-box p-5 shadow-sm hover:shadow-md hover:ring-2 hover:ring-primary/40 transition"
            >
              <div class="font-semibold capitalize">{String.replace(c.name, "_", " ")}</div>
              <div class="mt-2 flex flex-wrap gap-1">
                <span :for={dim <- c.dims} class="badge badge-ghost badge-sm">
                  {dim.key} · {length(dim.values)}
                </span>
                <span :if={c.dims == []} class="text-xs text-base-content/50">structural</span>
              </div>
            </.link>
          </div>
        </section>
      </main>
    </div>
    """
  end
end
