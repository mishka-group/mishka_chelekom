defmodule DevelopmentWeb.Showcase.HeadlessGalleryLive do
  @moduledoc """
  Base-UI-style examples gallery for the headless components.

  Two modes:
    * `/showcase/headless-baseui` — every component on one centered page (jump nav at the top).
    * `/showcase/headless-baseui/:component` — just one component's examples, with a back link
      to that component's page.

  Each example is a centered, live (testable) preview with the copy-paste HEEx behind a
  "Show code" toggle — mirroring base-ui.com, but with our Phoenix headless components.
  """
  use DevelopmentWeb, :live_view

  alias DevelopmentWeb.Showcase.{HeadlessCatalog, HeadlessPreview, HeadlessBaseUIExamples}
  import DevelopmentWeb.Showcase.UI, only: [code_block: 1]

  @impl true
  def mount(_params, _session, socket), do: {:ok, socket}

  @impl true
  def handle_params(%{"component" => name}, _uri, socket) do
    case HeadlessCatalog.get(name) do
      nil -> {:noreply, push_navigate(socket, to: ~p"/showcase/headless-baseui")}
      c -> {:noreply, assign(socket, mode: :show, component: c, catalog: nil)}
    end
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, mode: :index, component: nil, catalog: HeadlessCatalog.all())}
  end

  # ── single component ──────────────────────────────────────────────────────
  @impl true
  def render(%{mode: :show} = assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
      <main class="mx-auto max-w-3xl space-y-6 px-4 py-10">
        <.link
          navigate={~p"/showcase/headless/#{@component.name}"}
          class="text-sm text-base-content/60 hover:underline"
        >
          ← {String.replace(@component.name, "_", " ")} page
        </.link>

        <header class="space-y-1">
          <h1 class="text-2xl font-bold capitalize">
            {String.replace(@component.name, "_", " ")}
            <span class="text-base-content/40">— Base UI examples</span>
          </h1>
          <p class="text-sm text-base-content/60">{@component.description}</p>
        </header>

        <.component_examples component={@component.name} />

        <.link
          navigate={~p"/showcase/headless/#{@component.name}"}
          class="block pt-2 text-sm text-base-content/60 hover:underline"
        >
          ← Back to {String.replace(@component.name, "_", " ")}
        </.link>
      </main>
    </div>
    """
  end

  # ── all components ────────────────────────────────────────────────────────
  def render(%{mode: :index} = assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
      <header class="sticky top-0 z-30 border-b border-base-300 bg-base-100/90 backdrop-blur">
        <div class="mx-auto flex max-w-3xl items-center justify-between gap-4 px-4 py-3">
          <.link
            navigate={~p"/showcase/headless"}
            class="text-sm text-base-content/60 hover:underline"
          >
            ← Headless components
          </.link>
          <span class="text-sm font-semibold">Base UI examples</span>
        </div>
        <nav class="mx-auto max-w-3xl overflow-x-auto px-4 pb-2">
          <div class="flex flex-wrap gap-1.5">
            <.link
              :for={c <- @catalog}
              navigate={~p"/showcase/headless-baseui/#{c.name}"}
              class="rounded-full border border-base-300 px-2.5 py-0.5 text-xs capitalize text-base-content/70 hover:bg-base-200"
            >
              {String.replace(c.name, "_", " ")}
            </.link>
          </div>
        </nav>
      </header>

      <main class="mx-auto max-w-3xl space-y-16 px-4 py-10">
        <p class="text-center text-sm text-base-content/60">
          Every headless component, Base-UI style — preview in the center, copy-paste HEEx under <strong>Show code</strong>. The previews are live: open the menus/dialogs/popovers to test them.
        </p>

        <section :for={c <- @catalog} id={"sec-#{c.name}"} class="scroll-mt-24 space-y-4">
          <div class="space-y-1">
            <h2 class="text-xl font-semibold capitalize">
              <.link navigate={~p"/showcase/headless-baseui/#{c.name}"} class="hover:underline">
                {String.replace(c.name, "_", " ")}
              </.link>
            </h2>
            <p class="text-sm text-base-content/60">{c.description}</p>
          </div>
          <.component_examples component={c.name} />
        </section>
      </main>
    </div>
    """
  end

  # ── the example card(s) for one component (preview + Show code) ───────────
  attr :component, :string, required: true

  defp component_examples(assigns) do
    ~H"""
    <div :if={HeadlessBaseUIExamples.has?(@component)} class="space-y-6">
      <div :for={{id, title, desc} <- HeadlessBaseUIExamples.sections(@component)} class="space-y-2">
        <div class="space-y-0.5">
          <h3 class="text-sm font-semibold">{title}</h3>
          <p class="text-xs text-base-content/50">{desc}</p>
        </div>
        <.example_card
          kind={:baseui}
          section={id}
          preview_id={"g-#{id}"}
          code={HeadlessBaseUIExamples.source(id)}
        />
      </div>
    </div>

    <div :if={!HeadlessBaseUIExamples.has?(@component)} class="space-y-4">
      <.example_card
        preview_id={"g-#{@component}"}
        code={HeadlessPreview.source(@component)}
        component={@component}
        kind={:show}
      />
      <.example_card
        :if={HeadlessPreview.has_examples?(@component)}
        preview_id={"gx-#{@component}"}
        label="More examples — forms & server-driven patterns"
        component={@component}
        kind={:examples}
      />
    </div>
    """
  end

  attr :preview_id, :string, required: true
  attr :component, :string, default: nil
  attr :section, :string, default: nil
  attr :code, :any, default: nil
  attr :label, :string, default: nil
  attr :kind, :atom, default: :show

  defp example_card(assigns) do
    ~H"""
    <div class="rounded-2xl border border-base-300 bg-base-100">
      <p
        :if={@label}
        class="border-b border-base-300 px-4 py-2 text-xs font-medium text-base-content/50"
      >
        {@label}
      </p>
      <div class="flex min-h-[16rem] flex-wrap items-center justify-center gap-6 p-10">
        <HeadlessBaseUIExamples.example :if={@kind == :baseui} section={@section} />
        <HeadlessPreview.show :if={@kind == :show} component={@component} id={@preview_id} />
        <HeadlessPreview.examples :if={@kind == :examples} component={@component} id={@preview_id} />
      </div>
      <details :if={@code} class="group overflow-hidden rounded-b-2xl border-t border-base-300">
        <summary class="cursor-pointer list-none px-4 py-2.5 text-center text-sm font-medium text-base-content/60 hover:text-base-content">
          <span class="group-open:hidden">▸ Show code</span>
          <span class="hidden group-open:inline">▾ Hide code</span>
        </summary>
        <div class="border-t border-base-300">
          <.code_block code={@code} wrap />
        </div>
      </details>
    </div>
    """
  end
end
