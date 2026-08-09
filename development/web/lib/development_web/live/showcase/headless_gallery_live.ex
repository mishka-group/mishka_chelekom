defmodule DevelopmentWeb.Showcase.HeadlessGalleryLive do
  @moduledoc """
  Examples gallery for the headless components, in two skins.

  Routes:
    * `/showcase/headless-baseui[/:component]` — Base UI's own demos, ported. Every part is painted
      inline with utility classes, so the markup shows exactly which hooks a headless component
      exposes.
    * `/showcase/headless-daisyui[/:component]` — the same components with the generated daisyUI
      skin (`mix mishka.ui.gen.headless <name> --skin daisyui`) doing the painting, so the markup
      carries no styling at all.

  The skin buttons in the header switch between them for the component you are looking at. Each
  example is a centered, live (testable) preview with the copy-paste HEEx behind a "Show code"
  toggle.
  """
  use DevelopmentWeb, :live_view

  alias DevelopmentWeb.Showcase.{
    HeadlessBaseUIExamples,
    HeadlessCatalog,
    HeadlessDaisyUIExamples,
    HeadlessPreview
  }

  import DevelopmentWeb.Showcase.UI, only: [code_block: 1]

  @impl true
  def mount(_params, _session, socket), do: {:ok, assign(socket, submitted: nil)}

  @impl true
  def handle_params(params, _uri, socket) do
    skin =
      if socket.assigns.live_action in [:daisyui_index, :daisyui_show],
        do: :daisyui,
        else: :baseui

    case params do
      %{"component" => name} ->
        case HeadlessCatalog.get(name) do
          nil -> {:noreply, push_navigate(socket, to: index_path(skin))}
          c -> {:noreply, assign(socket, mode: :show, skin: skin, component: c, catalog: nil)}
        end

      _ ->
        {:noreply,
         assign(socket, mode: :index, skin: skin, component: nil, catalog: catalog(skin))}
    end
  end

  @impl true
  def handle_event("daisyui_select_submit", params, socket) do
    {:noreply, assign(socket, submitted: Map.get(params, "apple") || "nothing")}
  end

  def handle_event(event, params, socket)
      when event in ~w(daisyui_switch_submit daisyui_checkbox_submit) do
    on = params |> Map.filter(fn {_k, v} -> v not in [nil, "", "false"] end) |> Map.keys()
    {:noreply, assign(socket, submitted: Enum.join(Enum.sort(on), ", "))}
  end

  # The daisyUI gallery only lists what actually ships a skin fragment today.
  defp catalog(:daisyui) do
    skinned = HeadlessDaisyUIExamples.components()
    Enum.filter(HeadlessCatalog.all(), &(&1.name in skinned))
  end

  defp catalog(:baseui), do: HeadlessCatalog.all()

  defp index_path(:daisyui), do: ~p"/showcase/headless-daisyui"
  defp index_path(:baseui), do: ~p"/showcase/headless-baseui"

  defp component_path(:daisyui, name), do: ~p"/showcase/headless-daisyui/#{name}"
  defp component_path(:baseui, name), do: ~p"/showcase/headless-baseui/#{name}"

  defp skin_label(:daisyui), do: "daisyUI skin"
  defp skin_label(:baseui), do: "Base UI examples"

  # ── single component ──────────────────────────────────────────────────────
  @impl true
  def render(%{mode: :show} = assigns) do
    ~H"""
    <div
      data-skin={@skin == :daisyui && "daisyui"}
      class="min-h-screen bg-[var(--c-base-200)] text-[var(--c-base-content)]"
    >
      <main class="mx-auto max-w-3xl space-y-6 px-4 py-10">
        <.link
          navigate={~p"/showcase/headless/#{@component.name}"}
          class="text-sm text-[var(--c-base-content)]/60 hover:underline"
        >
          ← {String.replace(@component.name, "_", " ")} page
        </.link>

        <header class="space-y-3">
          <div class="flex flex-wrap items-center justify-between gap-3">
            <h1 class="text-2xl font-bold">
              <span class="capitalize">{String.replace(@component.name, "_", " ")}</span>
              <span class="text-[var(--c-base-content)]/40">— {skin_label(@skin)}</span>
            </h1>
            <.skin_switch skin={@skin} component={@component.name} />
          </div>
          <p class="text-sm text-[var(--c-base-content)]/60">{@component.description}</p>
        </header>

        <.component_examples component={@component.name} skin={@skin} submitted={@submitted} />

        <.link
          navigate={~p"/showcase/headless/#{@component.name}"}
          class="block pt-2 text-sm text-[var(--c-base-content)]/60 hover:underline"
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
    <div
      data-skin={@skin == :daisyui && "daisyui"}
      class="min-h-screen bg-[var(--c-base-200)] text-[var(--c-base-content)]"
    >
      <header class="sticky top-0 z-30 border-b border-[var(--c-base-300)] bg-[var(--c-base-100)]/90 backdrop-blur">
        <div class="mx-auto flex max-w-3xl items-center justify-between gap-4 px-4 py-3">
          <.link
            navigate={~p"/showcase/headless"}
            class="text-sm text-[var(--c-base-content)]/60 hover:underline"
          >
            ← Headless components
          </.link>
          <.skin_switch skin={@skin} component={nil} />
        </div>
        <nav class="mx-auto max-w-3xl overflow-x-auto px-4 pb-2">
          <div class="flex flex-wrap gap-1.5">
            <.link
              :for={c <- @catalog}
              navigate={component_path(@skin, c.name)}
              class="rounded-full border border-[var(--c-base-300)] px-2.5 py-0.5 text-xs capitalize text-[var(--c-base-content)]/70 hover:bg-[var(--c-base-200)]"
            >
              {String.replace(c.name, "_", " ")}
            </.link>
          </div>
        </nav>
      </header>

      <main class="mx-auto max-w-3xl space-y-16 px-4 py-10">
        <p :if={@skin == :baseui} class="text-center text-sm text-[var(--c-base-content)]/60">
          Every headless component, Base-UI style — preview in the center, copy-paste HEEx under <strong>Show code</strong>. The previews are live: open the menus/dialogs/popovers to test them.
        </p>
        <p :if={@skin == :daisyui} class="text-center text-sm text-[var(--c-base-content)]/60">
          The same components, painted by the generated daisyUI skin. Open <strong>Show code</strong>
          and compare it with the Base UI gallery: identical behavior, but the markup here carries no styling classes — the stylesheet does all of it.
        </p>

        <section :for={c <- @catalog} id={"sec-#{c.name}"} class="scroll-mt-24 space-y-4">
          <div class="space-y-1">
            <h2 class="text-xl font-semibold capitalize">
              <.link navigate={component_path(@skin, c.name)} class="hover:underline">
                {String.replace(c.name, "_", " ")}
              </.link>
            </h2>
            <p class="text-sm text-[var(--c-base-content)]/60">{c.description}</p>
          </div>
          <.component_examples component={c.name} skin={@skin} submitted={@submitted} />
        </section>
      </main>
    </div>
    """
  end

  # ── skin switch ───────────────────────────────────────────────────────────
  attr :skin, :atom, required: true
  attr :component, :any, default: nil

  defp skin_switch(assigns) do
    ~H"""
    <div class="inline-flex overflow-hidden rounded-lg border border-[var(--c-base-300)] text-sm">
      <.link
        :for={skin <- [:baseui, :daisyui]}
        navigate={if @component, do: component_path(skin, @component), else: index_path(skin)}
        aria-current={@skin == skin && "page"}
        class={[
          "px-3 py-1.5 font-medium",
          if(@skin == skin,
            do: "bg-[var(--c-primary)] text-[var(--c-primary-content)]",
            else:
              "bg-[var(--c-base-100)] text-[var(--c-base-content)]/70 hover:bg-[var(--c-base-200)]"
          )
        ]}
      >
        {if skin == :daisyui, do: "daisyUI", else: "Base UI"}
      </.link>
    </div>
    """
  end

  # ── the example card(s) for one component (preview + Show code) ───────────
  attr :component, :string, required: true
  attr :skin, :atom, required: true
  attr :submitted, :any, default: nil

  defp component_examples(%{skin: :daisyui} = assigns) do
    ~H"""
    <div :if={HeadlessDaisyUIExamples.has?(@component)} class="space-y-6">
      <div
        :for={{id, title, desc} <- HeadlessDaisyUIExamples.sections(@component)}
        class="space-y-2"
      >
        <div class="space-y-0.5">
          <h3 class="text-sm font-semibold">{title}</h3>
          <p class="text-xs text-[var(--c-base-content)]/50">{desc}</p>
        </div>
        <.example_card
          kind={:daisyui}
          section={id}
          preview_id={"d-#{id}"}
          code={HeadlessDaisyUIExamples.source(id)}
        />
        <p
          :if={@submitted && String.ends_with?(id, "-form")}
          class="text-center text-xs font-medium text-[var(--c-success)]"
        >
          Submitted: {@submitted}
        </p>
      </div>
    </div>

    <p
      :if={!HeadlessDaisyUIExamples.has?(@component)}
      class="rounded-2xl border border-dashed border-[var(--c-base-300)] p-6 text-center text-sm text-[var(--c-base-content)]/50"
    >
      No daisyUI skin for this component yet — add
      <code>priv/headless/skins/daisyui/{@component}.css.eex</code>
      and it shows up here.
    </p>
    """
  end

  defp component_examples(assigns) do
    ~H"""
    <div :if={HeadlessBaseUIExamples.has?(@component)} class="space-y-6">
      <div :for={{id, title, desc} <- HeadlessBaseUIExamples.sections(@component)} class="space-y-2">
        <div class="space-y-0.5">
          <h3 class="text-sm font-semibold">{title}</h3>
          <p class="text-xs text-[var(--c-base-content)]/50">{desc}</p>
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
    <div class="rounded-2xl border border-[var(--c-base-300)] bg-[var(--c-base-100)]">
      <p
        :if={@label}
        class="border-b border-[var(--c-base-300)] px-4 py-2 text-xs font-medium text-[var(--c-base-content)]/50"
      >
        {@label}
      </p>
      <div class="flex min-h-[16rem] flex-wrap items-center justify-center gap-6 p-10">
        <HeadlessBaseUIExamples.example :if={@kind == :baseui} section={@section} />
        <HeadlessDaisyUIExamples.example :if={@kind == :daisyui} section={@section} />
        <HeadlessPreview.show :if={@kind == :show} component={@component} id={@preview_id} />
        <HeadlessPreview.examples :if={@kind == :examples} component={@component} id={@preview_id} />
      </div>
      <details
        :if={@code}
        class="group overflow-hidden rounded-b-2xl border-t border-[var(--c-base-300)]"
      >
        <summary class="cursor-pointer list-none px-4 py-2.5 text-center text-sm font-medium text-[var(--c-base-content)]/60 hover:text-[var(--c-base-content)]">
          <span class="group-open:hidden">▸ Show code</span>
          <span class="hidden group-open:inline">▾ Hide code</span>
        </summary>
        <div class="border-t border-[var(--c-base-300)]">
          <.code_block code={@code} wrap />
        </div>
      </details>
    </div>
    """
  end
end
