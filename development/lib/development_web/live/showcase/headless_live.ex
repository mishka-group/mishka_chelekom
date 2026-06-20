defmodule DevelopmentWeb.Showcase.HeadlessLive do
  @moduledoc """
  A single unstyled (headless) component page. Left column documents the accessibility contract —
  anatomy parts, ARIA pattern, keyboard/focus behaviour, state attributes — and how to author it
  from a Kit. The right column is a sticky live preview (the only styling is added for legibility).
  Links across to the matching standard component when one exists. Index at `/showcase/headless`.
  """
  use DevelopmentWeb, :live_view

  import DevelopmentWeb.Showcase.UI

  alias DevelopmentWeb.Showcase.{
    HeadlessCatalog,
    HeadlessPreview,
    HeadlessApi,
    HeadlessKitDemo,
    Snippets
  }

  @impl true
  def mount(_params, _session, socket), do: {:ok, assign(socket, :catalog, HeadlessCatalog.all())}

  @impl true
  def handle_params(%{"component" => name}, _uri, socket) do
    case HeadlessCatalog.get(name) do
      nil ->
        {:noreply, push_navigate(socket, to: ~p"/showcase/headless")}

      comp ->
        {prev, next} = HeadlessCatalog.neighbors(name)

        {:noreply,
         socket
         |> assign(:component, comp)
         |> assign(:prev, prev)
         |> assign(:next, next)
         |> assign(:api, HeadlessApi.parse(name))
         |> assign(:usage, HeadlessApi.usage(name))
         |> assign(:module, HeadlessApi.module(name))
         |> assign(:page_title, "#{name} · Unstyled")}
    end
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, component: nil, page_title: "Unstyled components")}
  end

  @impl true
  def render(%{component: nil} = assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
      <main class="max-w-5xl mx-auto px-6 py-10 space-y-6">
        <.link navigate={~p"/showcase"} class="text-sm text-base-content/60 hover:underline">
          ← All components
        </.link>
        <h1 class="text-3xl font-bold">Unstyled components</h1>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          <.link
            :for={c <- @catalog}
            navigate={~p"/showcase/headless/#{c.name}"}
            class="block bg-base-100 rounded-box p-4 shadow-sm hover:ring-2 hover:ring-secondary/40 transition"
          >
            <div class="font-semibold capitalize">{String.replace(c.name, "_", " ")}</div>
            <div class="text-xs text-base-content/60 mt-1 line-clamp-2">{c.description}</div>
          </.link>
        </div>
      </main>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
      <div class="max-w-6xl mx-auto px-6 py-8 space-y-6">
        <header class="space-y-2">
          <div class="flex items-center justify-between gap-4 flex-wrap">
            <.link
              navigate={~p"/showcase/headless"}
              class="text-sm text-base-content/60 hover:underline"
            >
              ← All unstyled
            </.link>
            <div class="flex items-center gap-3 text-sm">
              <.link
                :if={@component.sibling}
                navigate={~p"/showcase/#{@component.sibling}"}
                class="badge badge-primary badge-outline gap-1"
              >
                ⇄ standard: {String.replace(@component.sibling, "_", " ")}
              </.link>
              <a
                :if={@component.doc_url}
                href={@component.doc_url}
                target="_blank"
                class="link link-primary"
              >
                ARIA pattern ↗
              </a>
            </div>
          </div>
          <h1 class="text-3xl font-bold capitalize">{String.replace(@component.name, "_", " ")}</h1>
          <p class="text-base-content/70 max-w-2xl">{@component.description}</p>
          <div class="flex flex-wrap items-center gap-1.5">
            <span class="badge badge-sm">{@component.category}</span>
            <span class="badge badge-sm badge-ghost">APG: {@component.pattern}</span>
            <span :for={h <- @component.hooks} class="badge badge-sm badge-ghost">hook: {h}</span>
          </div>
        </header>

        <div class="grid grid-cols-1 lg:grid-cols-[1fr_22rem] gap-10 items-start">
          <div class="min-w-0 space-y-10 order-2 lg:order-1">
            <.section
              title="Usage"
              subtitle="Use the generated component directly in a Phoenix template."
            >
              <p class="text-xs text-base-content/50">
                Generated into <code>{@module}</code> — import it, then:
              </p>
              <.code_block code={@usage} />
            </.section>

            <.section
              title="Anatomy"
              subtitle="The parts the component renders, with their semantics."
            >
              <.parts_table anatomy={@component.anatomy} />
            </.section>

            <.section :if={@component.keyboard != [] or @component.focus} title="Keyboard & focus">
              <ul class="text-sm space-y-1 text-base-content/80">
                <li :for={k <- @component.keyboard} class="flex gap-2">
                  <span class="text-base-content/40">›</span> {k}
                </li>
                <li :if={@component.focus} class="flex gap-2">
                  <span class="text-base-content/40">›</span> {@component.focus}
                </li>
              </ul>
            </.section>

            <.section :if={@component.state != []} title="State attributes">
              <div class="flex flex-wrap gap-2">
                <span :for={s <- @component.state} class="badge badge-outline font-mono">{s}</span>
              </div>
            </.section>

            <.section :if={@api.attrs != []} title="Attributes">
              <.attrs_table attrs={@api.attrs} />
            </.section>

            <.section :if={@api.slots != []} title="Slots">
              <.slots_table slots={@api.slots} />
            </.section>

            <.section
              title="Customize it"
              subtitle="Style its parts under a new name, from a Kit — `part` rules ⇒ headless."
            >
              <.code_block code={
                HeadlessKitDemo.code(@component.name) || Snippets.customize_headless(@component)
              } />
              <details :if={HeadlessKitDemo.available?(@component.name)} class="mt-4">
                <summary class="cursor-pointer select-none text-xs font-medium text-base-content/50 hover:text-base-content/80">
                  <span class="font-semibold text-base-content/70">→</span>
                  Show the result, rendered live by a real Kit
                </summary>
                <div class="mt-2 rounded-box ring-1 ring-base-content/5 bg-base-100 p-4">
                  <HeadlessKitDemo.demo component={@component.name} />
                </div>
              </details>
              <.tip>
                Same <code>customize</code>
                verb as styled components — the <code>part</code>
                rules tell the macro it's headless. It generates
                <code>&lt;.my_{@component.name}&gt;</code>
                as a thin wrapper that delegates to the real component (untouched) and applies your
                per-part classes as <code>[&amp;_[data-part=…]]:</code>
                variants. Feed <code>MyAppWeb.Kit.safelist()</code>
                to Tailwind so they survive purge.
              </.tip>
            </.section>
          </div>

          <aside class="order-1 lg:order-2 lg:sticky lg:top-8 space-y-4">
            <div class="bg-base-100 rounded-box p-6 shadow-sm">
              <div class="text-xs uppercase tracking-wide text-base-content/40 mb-4">
                Live preview — try keyboard + mouse
              </div>
              <div class="flex flex-wrap items-start gap-4 min-h-32">
                <HeadlessPreview.show component={@component.name} id={"hl-#{@component.name}"} />
              </div>
            </div>
            <details
              :if={HeadlessPreview.source(@component.name)}
              class="bg-base-100 rounded-box shadow-sm"
            >
              <summary class="cursor-pointer select-none px-6 py-3 text-xs font-medium uppercase tracking-wide text-base-content/50 hover:text-base-content/80">
                Code — copy &amp; paste
              </summary>
              <div class="px-4 pb-4">
                <.code_block code={HeadlessPreview.source(@component.name)} wrap />
              </div>
            </details>
            <div class="bg-base-300/70 rounded-box p-4 text-xs text-base-content/70">
              Ships <strong>no colors or spacing</strong>. The classes here are showcase-only — in
              your app you style the <code>chelekom-{@component.name}*</code>
              hooks and <code>data-*</code>
              state.
            </div>
          </aside>
        </div>

        <section
          :if={HeadlessPreview.has_examples?(@component.name)}
          class="space-y-4 border-t border-base-300 pt-6"
        >
          <div>
            <h2 class="text-xl font-semibold">Examples</h2>
            <p class="text-sm text-base-content/60">
              More worked patterns for this component — click to expand.
            </p>
          </div>
          <HeadlessPreview.examples component={@component.name} id={"hl-ex-#{@component.name}"} />
        </section>

        <nav
          :if={@prev || @next}
          class="flex items-stretch gap-4 border-t border-base-300 pt-6"
          aria-label="Component navigation"
        >
          <.link
            :if={@prev}
            navigate={~p"/showcase/headless/#{@prev.name}"}
            class="group flex min-w-0 max-w-xs flex-col items-start gap-1 rounded-box border border-base-300 bg-base-100 px-5 py-4 shadow-sm transition-colors hover:border-secondary"
          >
            <span class="flex items-center gap-1 text-xs uppercase tracking-wide text-base-content/40">
              <span class="transition-transform group-hover:-translate-x-0.5">←</span> Previous
            </span>
            <span class="w-full truncate text-left font-semibold capitalize">
              {String.replace(@prev.name, "_", " ")}
            </span>
          </.link>

          <.link
            :if={@next}
            navigate={~p"/showcase/headless/#{@next.name}"}
            class="group ml-auto flex min-w-0 max-w-xs flex-col items-end gap-1 rounded-box border border-base-300 bg-base-100 px-5 py-4 shadow-sm transition-colors hover:border-secondary"
          >
            <span class="flex items-center gap-1 text-xs uppercase tracking-wide text-base-content/40">
              Next <span class="transition-transform group-hover:translate-x-0.5">→</span>
            </span>
            <span class="w-full truncate text-right font-semibold capitalize">
              {String.replace(@next.name, "_", " ")}
            </span>
          </.link>
        </nav>
      </div>
    </div>
    """
  end

  attr :anatomy, :any, required: true

  defp parts_table(assigns) do
    assigns = assign(assigns, :rows, anatomy_rows(assigns.anatomy))

    ~H"""
    <div :if={@rows == []} class="text-sm text-base-content/50">Anatomy not documented.</div>
    <div :if={@rows != []} class="overflow-x-auto rounded-box ring-1 ring-base-content/5">
      <table class="table table-sm">
        <thead>
          <tr>
            <th>Part</th>
            <th>Element</th>
            <th>Role</th>
            <th>ARIA</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={r <- @rows}>
            <td class="font-mono text-xs whitespace-nowrap">{r.name}</td>
            <td class="font-mono text-xs text-base-content/60">&lt;{r.element}&gt;</td>
            <td class="font-mono text-xs text-base-content/60">{r.role || "—"}</td>
            <td class="text-xs text-base-content/70">
              <span :for={a <- r.aria} class="badge badge-xs badge-ghost font-mono mr-1">{a}</span>
              <span :if={r.aria == []}>—</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp anatomy_rows(anatomy) when is_list(anatomy) do
    root = if r = anatomy[:root], do: [row("root", r)], else: []
    parts = for {name, opts} <- anatomy[:parts] || [], do: row(name, opts)
    root ++ parts
  end

  defp anatomy_rows(_), do: []

  defp row(name, opts) do
    %{
      name: to_string(name),
      element: opts[:element] || "div",
      role: opts[:role],
      aria: (opts[:aria] || []) ++ (opts[:data_attributes] || [])
    }
  end
end
