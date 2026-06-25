defmodule DevelopmentWeb.Showcase.KitLive do
  @moduledoc """
  Demonstrates `MishkaChelekom.Kit` — the two ways to reuse existing components: `customize` a
  styled one (add/restyle colors & variants) and `skin` a headless one. Renders the Kit's generated
  wrappers live (via remote calls so they don't clash with the globally-imported originals) and
  shows the introspection. Classes are written verbatim in the Kit, so Tailwind scans them straight
  from `kit.ex` — no safelist.
  """
  use DevelopmentWeb, :live_view

  import DevelopmentWeb.Showcase.UI
  alias MishkaChelekom.Kit
  alias DevelopmentWeb.Kit, as: DemoKit
  alias DevelopmentWeb.Widgets

  @kit_path Path.expand("../../kit.ex", __DIR__)
  @external_resource @kit_path

  @code_button """
  customize :button do
    color :primary, "bg-rose-600! text-white!"          # replace the stock :primary
    color :brand,   "bg-linear-to-r! from-fuchsia-600! to-indigo-600! text-white!"   # add a new color
    variant :glow,  "shadow-[0_0_25px_currentColor]! ring-2!"   # add a new variant
    default color: "brand"
  end\
  """

  @code_alert """
  customize :alert do
    kind :brand, "bg-indigo-600! text-white!"    # the alert's colour lives in `kind` (an atom)
    default kind: :brand, variant: "default"
  end\
  """

  @code_ribbon """
  customize :ribbon do
    from {DevelopmentWeb.Widgets, :ribbon}   # an EXACT module/function — no naming convention
    base "plain"
    color :brand, "bg-fuchsia-600! text-white! ring-fuchsia-600!"
    default color: :brand
  end\
  """

  @code_accordion """
  customize :my_accordion do
    from :accordion                  # reuse the real *headless* accordion (it ships zero CSS)

    # the whole card — bg, border, rounded, dividers between items
    part :root,
         "rounded-2xl border border-base-300 bg-base-100 shadow-sm divide-y divide-base-200"

    # tint whichever item is open
    part :item,
         "[&_[data-part=item]:has([data-part=panel][data-open])]:bg-base-200/40"

    # header row + a chevron that flips open (one [&_[data-part=trigger]]: per utility)
    part :trigger,
         "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:justify-between
          [&_[data-part=trigger]]:px-4 [&_[data-part=trigger]]:py-3.5
          [&_[data-part=trigger]]:hover:bg-base-200/60
          [&_[data-part=trigger]]:after:content-['▾']
          [&_[data-part=trigger][aria-expanded=true]]:after:rotate-180"

    # the panel body — padding + muted text
    part :panel,
         "[&_[data-part=panel]]:px-4 [&_[data-part=panel]]:pb-4 [&_[data-part=panel]]:text-base-content/70"
  end\
  """

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Kit — customize")
     |> assign(:code_button, @code_button)
     |> assign(:code_alert, @code_alert)
     |> assign(:code_ribbon, @code_ribbon)
     |> assign(:code_accordion, @code_accordion)
     |> assign(
       :customizes,
       Enum.map(Kit.Info.customizes(DemoKit), &{&1.name, from_label(&1.name, &1.from)})
     )}
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

        <.kit_example
          title="Customize a styled component — :button"
          subtitle="Restyle an existing color, add a brand-new one, add a variant. Your classes win via the trailing ! — the real button component is never touched."
          code={@code_button}
        >
          <:result>
            <div class="space-y-4">
              <div class="space-y-1.5">
                <div class="text-[11px] text-base-content/50">restyle :primary — stock → Kit</div>
                <div class="flex flex-wrap items-center gap-2">
                  <.button color="primary" size="small">stock</.button>
                  <span class="text-base-content/30">→</span>
                  <DemoKit.button color="primary" size="small">Kit</DemoKit.button>
                </div>
              </div>
              <div class="space-y-1.5">
                <div class="text-[11px] text-base-content/50">
                  new :brand · new :glow · untouched :success
                </div>
                <div class="flex flex-wrap items-center gap-2">
                  <DemoKit.button color="brand" size="small">brand</DemoKit.button>
                  <DemoKit.button variant="glow" color="primary" size="small">glow</DemoKit.button>
                  <DemoKit.button color="success" size="small">success</DemoKit.button>
                </div>
              </div>
            </div>
          </:result>
        </.kit_example>

        <.kit_example
          title="Customize a different component — :alert"
          subtitle="Same component, a new kind value (an atom). Stock info vs the Kit's :brand kind (its new default)."
          code={@code_alert}
        >
          <:result>
            <div class="space-y-2">
              <.alert kind={:info} title="Stock">The stock info alert.</.alert>
              <DemoKit.alert>The Kit's brand alert — same component.</DemoKit.alert>
            </div>
          </:result>
        </.kit_example>

        <.kit_example
          title="Point at any module — explicit from target"
          subtitle="The naming convention is only the default. An explicit module/function tuple delegates to ANY target — here a hand-written DevelopmentWeb.Widgets.ribbon/1 that lives nowhere near Components, with no components namespace needed."
          code={@code_ribbon}
        >
          <:result>
            <div class="space-y-1.5">
              <div class="text-[11px] text-base-content/50">stock widget → Kit's :brand</div>
              <div class="flex flex-wrap items-center gap-2">
                <Widgets.ribbon>stock ribbon</Widgets.ribbon>
                <span class="text-base-content/30">→</span>
                <DemoKit.ribbon>Kit brand ribbon</DemoKit.ribbon>
              </div>
            </div>
          </:result>
        </.kit_example>

        <.kit_example
          title="Skin a headless component — :my_accordion"
          subtitle="Wrap the unstyled headless accordion and bake per-part classes in, under a new name. The headless component ships zero CSS on its own."
          code={@code_accordion}
        >
          <:result>
            <DemoKit.my_accordion id="kit-acc" class="w-full">
              <:item title="What did the Kit do?" open>
                Generated <code>my_accordion/1</code> — a wrapper of the real headless accordion, with
                the per-part classes baked right in. The page just calls it; no inline styling here.
              </:item>
              <:item title="Was the component changed?">No — the wrapper just delegates to it.</:item>
              <:item title="Where do the classes live?">
                In <code>kit.ex</code>, written whole — so Tailwind scans them straight from the file,
                no safelist.
              </:item>
            </DemoKit.my_accordion>
          </:result>
        </.kit_example>

        <section class="bg-base-100 rounded-box p-5 shadow-sm flex flex-wrap items-center gap-3 text-sm">
          <span class="text-[11px] uppercase tracking-wide font-semibold text-base-content/50">
            Generated wrappers
          </span>
          <span class="flex flex-wrap gap-1.5">
            <code :for={{n, f} <- @customizes} class="badge badge-sm badge-outline font-mono">
              {if is_nil(f), do: "<.#{n}>", else: "<.#{n}> ← #{f}"}
            </code>
          </span>
        </section>
      </main>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :code, :string, required: true
  slot :result, required: true

  defp kit_example(assigns) do
    ~H"""
    <section class="bg-base-100 rounded-box shadow-sm overflow-hidden">
      <div class="px-5 pt-5 pb-3 space-y-1 border-b border-base-200">
        <h2 class="font-semibold">{@title}</h2>
        <p :if={@subtitle} class="text-sm text-base-content/60 max-w-2xl">{@subtitle}</p>
      </div>
      <div class="grid lg:grid-cols-2">
        <div class="p-5 lg:border-r border-base-200">
          <div class="text-[11px] uppercase tracking-wide text-base-content/40 mb-2">customize</div>
          <.code_block code={@code} wrap />
        </div>
        <div class="p-5 bg-base-200/30">
          <div class="text-[11px] uppercase tracking-wide text-base-content/40 mb-3">result</div>
          {render_slot(@result)}
        </div>
      </div>
    </section>
    """
  end

  # Human-readable label for the generated-wrappers list: nil when it follows the name,
  # "Mod.fun" for an explicit {Module, :function} tuple, else the plain atom.
  defp from_label(name, from) when from in [nil, name], do: nil
  defp from_label(_name, {mod, fun}), do: "#{inspect(mod)}.#{fun}"
  defp from_label(_name, from), do: to_string(from)
end
