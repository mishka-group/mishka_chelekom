defmodule DevelopmentWeb.Showcase.KitLive do
  @moduledoc """
  Demonstrates `MishkaChelekom.Kit` — the two ways to reuse existing components: `customize` a
  styled one (add/restyle colors & variants) and `skin` a headless one. Renders the Kit's generated
  wrappers live (via remote calls so they don't clash with the globally-imported originals) and
  shows the introspection + Tailwind safelist.
  """
  use DevelopmentWeb, :live_view

  import DevelopmentWeb.Showcase.UI
  alias MishkaChelekom.Kit
  alias DevelopmentWeb.Kit, as: DemoKit

  @kit_path Path.expand("../../kit.ex", __DIR__)
  @external_resource @kit_path
  @source @kit_path
          |> File.read!()
          |> String.split("use MishkaChelekom.Kit\n", parts: 2)
          |> List.last()
          |> String.trim_trailing("end\n")
          |> String.trim()

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Kit — customize")
     |> assign(:source, @source)
     |> assign(:safelist, Kit.safelist(DemoKit))
     |> assign(:customizes, Enum.map(Kit.Info.customizes(DemoKit), &{&1.name, &1.from || &1.name}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
      <main class="max-w-5xl mx-auto px-6 py-8 space-y-8">
        <header class="space-y-1">
          <.link navigate={~p"/showcase"} class="text-sm text-base-content/60 hover:underline">
            ← All components
          </.link>
          <h1 class="text-3xl font-bold">The <code>Kit</code> — reuse &amp; customize</h1>
          <p class="text-base-content/70 max-w-2xl">
            One Spark DSL with two moves: <strong>customize</strong> an existing styled component
            (add/restyle colors &amp; variants) and <strong>skin</strong> an existing headless one.
            Each generates a thin wrapper that delegates to the real component — nothing is built
            from scratch, and the component files are never touched.
          </p>
        </header>

        <section class="bg-base-100 rounded-box p-6 shadow-sm space-y-3">
          <h2 class="text-sm font-semibold uppercase tracking-wide text-base-content/50">The Kit</h2>
          <.code_block code={@source} />
        </section>

        <section class="bg-base-100 rounded-box p-6 shadow-sm space-y-4">
          <h2 class="text-sm font-semibold uppercase tracking-wide text-base-content/50">
            Live — generated wrappers
          </h2>

          <div class="space-y-2">
            <div class="text-sm font-medium">customize :button — new brand color + glow variant</div>
            <div class="flex flex-wrap items-center gap-3">
              <DemoKit.button color="brand">Brand gradient</DemoKit.button>
              <DemoKit.button variant="glow" color="primary">Glow</DemoKit.button>
              <DemoKit.button color="success">Untouched success</DemoKit.button>
            </div>
          </div>

          <div class="space-y-2">
            <div class="text-sm font-medium">
              customize :alert — new brand <code>kind</code> (atom)
            </div>
            <DemoKit.alert>A brand-coloured alert, same component.</DemoKit.alert>
          </div>

          <div class="space-y-2">
            <div class="text-sm font-medium">
              skin :my_accordion — styled accordion from the headless one
            </div>
            <DemoKit.my_accordion
              id="kit-acc"
              class="w-full max-w-md border border-base-300 rounded-box divide-y divide-base-300 [&_[data-part=trigger]]:px-3 [&_[data-part=panel]]:px-3"
            >
              <:item title="What did the Kit do?">
                It generated <code>my_accordion/1</code> as a wrapper of the real headless accordion,
                with the per-part classes baked in.
              </:item>
              <:item title="Was the component changed?">No — the wrapper just delegates to it.</:item>
            </DemoKit.my_accordion>
          </div>
        </section>

        <section class="grid md:grid-cols-2 gap-6">
          <div class="bg-base-100 rounded-box p-6 shadow-sm space-y-3">
            <h2 class="text-sm font-semibold uppercase tracking-wide text-base-content/50">
              🤖 Introspection
            </h2>
            <div class="text-sm">
              <strong>customizes:</strong>
              {Enum.map_join(@customizes, ", ", fn {n, f} -> if(n == f, do: "#{n}", else: "#{n} ← #{f}") end)}
            </div>
          </div>

          <div class="bg-base-100 rounded-box p-6 shadow-sm space-y-3">
            <h2 class="text-sm font-semibold uppercase tracking-wide text-base-content/50">
              🏭 Tailwind safelist
            </h2>
            <p class="text-xs text-base-content/60">
              <code>Kit.safelist/1</code> — feed to Tailwind so runtime classes survive purge.
            </p>
            <div class="flex flex-wrap gap-1">
              <span :for={c <- @safelist} class="badge badge-xs badge-outline font-mono">{c}</span>
            </div>
          </div>
        </section>
      </main>
    </div>
    """
  end
end
