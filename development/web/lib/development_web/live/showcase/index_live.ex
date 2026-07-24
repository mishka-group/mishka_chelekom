defmodule DevelopmentWeb.Showcase.IndexLive do
  @moduledoc """
  Showcase landing page. A full-width header introduces the three ways Mishka Chelekom ships UI
  (standard, unstyled, macro/Kit), then two columns list every standard and unstyled component,
  grouped by category, each linking to its own page.
  """
  use DevelopmentWeb, :live_view

  alias DevelopmentWeb.Showcase.{Catalog, HeadlessCatalog}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Mishka Chelekom — Components")
     |> assign(:standard, Catalog.by_category())
     |> assign(:standard_count, Catalog.count())
     |> assign(:unstyled, HeadlessCatalog.by_category())
     |> assign(:unstyled_count, length(HeadlessCatalog.all()))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-[var(--c-base-200)] text-[var(--c-base-content)]">
      <header class="bg-[var(--c-base-100)] border-b border-[var(--c-base-300)]">
        <div class="max-w-6xl mx-auto px-6 py-12 space-y-8">
          <div class="space-y-2">
            <h1 class="text-4xl font-bold tracking-tight">Mishka Chelekom</h1>
            <p class="text-lg text-[var(--c-base-content)]/70 max-w-2xl">
              One UI library, three ways to ship — finished components, accessible unstyled
              behaviour, or a Kit to customize and reuse either.
            </p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <.approach
              title="Standard"
              accent="border-[var(--c-primary)]"
              count={@standard_count}
              desc="Finished, designed components — colors, sizes and variants baked in."
              code="mix mishka.ui.gen.component button"
            />
            <.approach
              title="Unstyled"
              accent="border-[var(--c-secondary)]"
              count={@unstyled_count}
              desc="Behaviour + accessibility, no styling. Correct ARIA, keyboard and JS — bring your own CSS."
              code="mix mishka.ui.gen.headless dialog"
            />
            <div class="bg-[var(--c-base-200)]/60 rounded-lg p-5 border-l-4 border-[var(--c-accent)] space-y-2">
              <div class="font-semibold">Kit</div>
              <p class="text-sm text-[var(--c-base-content)]/70">
                A Spark DSL to <strong>customize</strong> a styled component (add/restyle colors &amp;
                variants) or <strong>skin</strong> a headless one — reusing what's already there.
              </p>
              <div class="flex gap-2 pt-1">
                <.link navigate={~p"/showcase/kit"} class="btn btn-xs btn-outline">
                  Explore the Kit →
                </.link>
              </div>
            </div>
          </div>
        </div>
      </header>

      <main class="max-w-6xl mx-auto px-6 py-10 grid grid-cols-1 lg:grid-cols-2 gap-x-12 gap-y-10">
        <.column
          heading="Standard"
          badge="badge-primary"
          count={@standard_count}
          groups={@standard}
          href={fn name -> ~p"/showcase/#{name}" end}
        />
        <.column
          heading="Unstyled"
          badge="badge-secondary"
          count={@unstyled_count}
          groups={@unstyled}
          href={fn name -> ~p"/showcase/headless/#{name}" end}
        />
      </main>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :accent, :string, required: true
  attr :count, :integer, required: true
  attr :desc, :string, required: true
  attr :code, :string, required: true

  defp approach(assigns) do
    ~H"""
    <div class={["bg-[var(--c-base-200)]/60 rounded-lg p-5 border-l-4 space-y-2", @accent]}>
      <div class="font-semibold flex items-center gap-2">
        {@title} <span class="badge badge-sm">{@count}</span>
      </div>
      <p class="text-sm text-[var(--c-base-content)]/70">{@desc}</p>
      <code class="block text-xs bg-[var(--c-base-300)]/70 rounded px-2 py-1 overflow-x-auto">
        {@code}
      </code>
    </div>
    """
  end

  attr :heading, :string, required: true
  attr :badge, :string, required: true
  attr :count, :integer, required: true
  attr :groups, :list, required: true
  attr :href, :any, required: true

  defp column(assigns) do
    ~H"""
    <div class="space-y-6">
      <h2 class="text-xl font-bold flex items-center gap-2">
        {@heading} <span class={["badge badge-sm", @badge]}>{@count}</span>
      </h2>
      <div :for={{category, items} <- @groups} class="space-y-2">
        <h3 class="text-xs font-semibold uppercase tracking-wide text-[var(--c-base-content)]/40">
          {category}
        </h3>
        <ul class="grid grid-cols-2 gap-1">
          <li :for={c <- items}>
            <.link
              navigate={@href.(c.name)}
              class="group flex items-center gap-1.5 rounded px-2 py-1 text-sm hover:bg-[var(--c-base-100)]"
            >
              <span class="capitalize truncate">{String.replace(c.name, "_", " ")}</span>
              <span
                :if={c.sibling}
                class="text-xs text-[var(--c-base-content)]/30 group-hover:text-[var(--c-base-content)]/50"
                title="has a linked counterpart"
              >
                ⇄
              </span>
            </.link>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
