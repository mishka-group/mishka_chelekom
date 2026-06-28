defmodule DevelopmentWeb.Showcase.ComponentLive do
  @moduledoc """
  A single standard (styled) component page. Left column documents it — description, real
  examples, how to author the same thing with the macro/Kit, and the full attribute/slot
  reference. The right column is a sticky, interactive preview driven by the component's catalog
  dimensions. Links across to the matching unstyled component when one exists.
  """
  use DevelopmentWeb, :live_view

  import DevelopmentWeb.Showcase.UI
  alias DevelopmentWeb.Showcase.{Catalog, Preview, Snippets, JsonMeta, ExampleSource, KitDemo}

  @sample "Mishka Chelekom"

  @impl true
  def mount(%{"component" => name}, _session, socket) do
    case Catalog.get(name) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Unknown component: #{name}")
         |> push_navigate(to: ~p"/showcase")}

      component ->
        ex_mod = examples_module(name)
        {prev, next} = Catalog.neighbors(name)

        {:ok,
         socket
         |> allow_upload(:showcase_file,
           accept: ~w(.jpg .jpeg .png .gif .webp),
           max_entries: 3,
           max_file_size: 5_000_000
         )
         |> assign(:component, component)
         |> assign(:prev, prev)
         |> assign(:next, next)
         |> assign(:sample, @sample)
         |> assign(:form, to_form(%{}, as: :demo))
         |> assign(:props, default_props(component))
         |> assign(:examples, JsonMeta.examples(name))
         |> assign(:attrs, JsonMeta.attrs(name))
         |> assign(:slots, JsonMeta.slots(name))
         |> assign(:deps, JsonMeta.dependencies(name))
         |> assign(:examples_mod, ex_mod)
         |> assign(:example_sections, (ex_mod && ex_mod.sections()) || [])
         |> assign(:open_examples, MapSet.new())
         |> assign(:preview_nonce, 0)
         |> assign(:page_title, "#{component.name} · Standard")}
    end
  end

  defp examples_module(name) do
    mod = Module.concat([DevelopmentWeb.Showcase.Examples, Macro.camelize(name)])
    if Code.ensure_loaded?(mod) and function_exported?(mod, :sections, 0), do: mod
  end

  defp example(assigns), do: apply(assigns.mod, :example, [assigns])

  defp example_code(assigns) do
    assigns = assign(assigns, :code, ExampleSource.code(assigns.mod, assigns.section))

    ~H"""
    <details :if={@code} class="mt-4">
      <summary class="cursor-pointer select-none text-xs font-medium text-[var(--c-base-content)]/50 hover:text-[var(--c-base-content)]/80">
        Show code
      </summary>
      <div class="mt-2">
        <.code_block code={@code} wrap />
      </div>
    </details>
    """
  end

  @impl true
  def handle_event("update", params, socket) do
    comp = socket.assigns.component
    by_attr = Map.new(comp.dims, &{&1.attr, &1})
    flag_names = MapSet.new(comp.flags, & &1.name)

    parsed =
      Enum.reduce(params, %{}, fn {k, v}, acc ->
        cond do
          dim = by_attr[k] ->
            if v in [nil, ""], do: acc, else: Map.put(acc, String.to_atom(k), cast(v, dim.type))

          k in flag_names ->
            Map.put(acc, String.to_atom(k), v == "true")

          true ->
            acc
        end
      end)

    socket = assign(socket, :props, Map.merge(socket.assigns.props, parsed))

    socket =
      if Enum.any?(Map.keys(params), &(&1 in flag_names)),
        do: update(socket, :preview_nonce, &(&1 + 1)),
        else: socket

    {:noreply, socket}
  end

  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(:props, default_props(socket.assigns.component))
     |> update(:preview_nonce, &(&1 + 1))}
  end

  def handle_event("toggle_example", %{"id" => id}, socket) do
    open = socket.assigns.open_examples
    open = if MapSet.member?(open, id), do: MapSet.delete(open, id), else: MapSet.put(open, id)
    {:noreply, assign(socket, :open_examples, open)}
  end

  def handle_event("validate", _params, socket), do: {:noreply, socket}

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :showcase_file, ref)}
  end

  def handle_event("rating", %{"number" => n}, socket) do
    {:noreply, assign(socket, :props, Map.put(socket.assigns.props, :select, n))}
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-[var(--c-base-200)] text-[var(--c-base-content)]">
      <div class="max-w-6xl mx-auto px-6 py-8 space-y-6">
        <.page_header component={@component} />

        <div class="grid grid-cols-1 lg:grid-cols-[1fr_22rem] gap-10 items-start">
          <div class="min-w-0 space-y-10 order-2 lg:order-1">
            <.section
              :if={@examples != []}
              title="Examples"
              subtitle="Real, production-ready snippets."
            >
              <.code_block :for={ex <- @examples} code={ex} />
            </.section>

            <.section
              title="Customize it"
              subtitle="Reuse this component — add or restyle its colors & variants from a Kit."
            >
              <p class="text-xs text-[var(--c-base-content)]/50">
                <span class="font-semibold text-[var(--c-base-content)]/70">1 ·</span> Customize it in your Kit
                (same value name ⇒ replace, new name ⇒ add):
              </p>
              <.code_block code={Snippets.customize(@component)} />
              <p class="text-xs text-[var(--c-base-content)]/50 mt-3">
                <span class="font-semibold text-[var(--c-base-content)]/70">2 ·</span>
                It generates a same-named wrapper — use it like the original:
              </p>
              <.code_block code={Snippets.customize_usage(@component)} />
              <details :if={KitDemo.available?(@component.name)} class="mt-4">
                <summary class="cursor-pointer select-none text-xs font-medium text-[var(--c-base-content)]/50 hover:text-[var(--c-base-content)]/80">
                  <span class="font-semibold text-[var(--c-base-content)]/70">3 ·</span>
                  Show the result, rendered live by a real Kit
                </summary>
                <div class="mt-2 rounded-lg ring-1 ring-[var(--c-base-content)]/5 bg-[var(--c-base-100)] p-4">
                  <KitDemo.demo component={@component.name} />
                </div>
              </details>
              <.tip>
                The real <code>&lt;.{@component.name}&gt;</code>
                is never touched — the Kit generates a
                thin wrapper that delegates to it. Write your classes whole, with a trailing
                <code>!</code>
                so they win over the component's defaults
                (e.g. <code>"bg-brand-500!"</code>); Tailwind scans them straight from your Kit module —
                no safelist needed.
              </.tip>
            </.section>

            <.section title="Attributes">
              <.attrs_table attrs={@attrs} />
            </.section>

            <.section :if={@slots != []} title="Slots">
              <.slots_table slots={@slots} />
            </.section>

            <.section :if={@deps != []} title="Depends on">
              <div class="flex flex-wrap gap-2">
                <.link
                  :for={d <- @deps}
                  navigate={~p"/showcase/#{d}"}
                  class="badge badge-outline hover:badge-primary capitalize"
                >
                  {String.replace(d, "_", " ")}
                </.link>
              </div>
            </.section>

            <.section
              :if={@example_sections != []}
              title="Live examples"
              subtitle="From the Mishka docs — click a section to render it; collapsing removes it from the page."
            >
              <div class="rounded-lg ring-1 ring-[var(--c-base-content)]/5 divide-y divide-[var(--c-base-300)] overflow-hidden">
                <div :for={s <- @example_sections}>
                  <button
                    type="button"
                    phx-click="toggle_example"
                    phx-value-id={s.id}
                    class="flex w-full items-center justify-between px-4 py-3 text-left text-sm font-medium hover:bg-[var(--c-base-100)]"
                  >
                    {s.title}
                    <span class={[
                      "text-[var(--c-base-content)]/40 transition-transform",
                      MapSet.member?(@open_examples, s.id) && "rotate-180"
                    ]}>
                      ▾
                    </span>
                  </button>
                  <div
                    :if={MapSet.member?(@open_examples, s.id)}
                    class="px-4 pb-5 pt-1 bg-[var(--c-base-100)]/40"
                  >
                    <.example mod={@examples_mod} section={s.id} />
                    <.example_code mod={@examples_mod} section={s.id} />
                  </div>
                </div>
              </div>
            </.section>
          </div>

          <aside class="order-1 lg:order-2 lg:sticky lg:top-8 space-y-4">
            <div class="bg-[var(--c-base-100)] rounded-lg p-6 shadow-sm">
              <div class="text-xs uppercase tracking-wide text-[var(--c-base-content)]/40 mb-4">
                Live preview
              </div>
              <div class="flex flex-wrap items-center justify-center gap-4 min-h-24">
                <Preview.show
                  component={@component.name}
                  id={"showcase-#{@component.name}-#{@preview_nonce}"}
                  props={@props}
                  form={@form}
                  sample={@sample}
                  uploads={@uploads}
                />
              </div>
            </div>

            <div
              :if={@component.dims != [] or @component.flags != []}
              class="bg-[var(--c-base-100)] rounded-lg p-4 shadow-sm space-y-3"
            >
              <form :if={@component.dims != []} phx-change="update" class="space-y-2">
                <label :for={dim <- @component.dims} class="flex items-center justify-between gap-3">
                  <span class="text-sm capitalize text-[var(--c-base-content)]/70">
                    {String.replace(dim.key, "_", " ")}
                  </span>
                  <span :if={Map.get(dim, :kind) == :range} class="flex w-40 items-center gap-2">
                    <input
                      type="range"
                      name={dim.attr}
                      min={dim.min}
                      max={dim.max}
                      step={dim.step}
                      value={@props[String.to_atom(dim.attr)]}
                      class="range range-xs flex-1"
                    />
                    <span class="w-7 text-right text-xs tabular-nums text-[var(--c-base-content)]/70">
                      {@props[String.to_atom(dim.attr)]}
                    </span>
                  </span>
                  <select
                    :if={Map.get(dim, :kind) != :range}
                    name={dim.attr}
                    class="select select-bordered select-xs w-40"
                  >
                    <option
                      :for={v <- dim.values}
                      value={v}
                      selected={to_string(@props[String.to_atom(dim.attr)]) == v}
                    >
                      {v}
                    </option>
                  </select>
                </label>
              </form>

              <form
                :if={@component.flags != []}
                phx-change="update"
                class="space-y-1.5 border-t border-[var(--c-base-300)] pt-3"
              >
                <div class="text-xs uppercase tracking-wide text-[var(--c-base-content)]/40">Props</div>
                <label
                  :for={flag <- @component.flags}
                  class="flex items-center gap-2 cursor-pointer"
                >
                  <input type="hidden" name={flag.name} value="false" />
                  <input
                    type="checkbox"
                    name={flag.name}
                    value="true"
                    checked={@props[String.to_atom(flag.name)] == true}
                    class="size-4 rounded border-[var(--c-base-300)] accent-current"
                  />
                  <span class="text-sm capitalize text-[var(--c-base-content)]/70">
                    {String.replace(flag.name, "_", " ")}
                  </span>
                </label>
              </form>

              <button type="button" phx-click="reset" class="btn btn-ghost btn-xs w-full">
                Reset
              </button>
            </div>

            <.code_block code={Snippets.usage(@component.name, @props)} />
          </aside>
        </div>

        <nav
          :if={@prev || @next}
          class="flex items-stretch gap-4 border-t border-[var(--c-base-300)] pt-6"
          aria-label="Component navigation"
        >
          <.link
            :if={@prev}
            navigate={~p"/showcase/#{@prev.name}"}
            class="group flex min-w-0 max-w-xs flex-col items-start gap-1 rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-5 py-4 shadow-sm transition-colors hover:border-[var(--c-primary)]"
          >
            <span class="flex items-center gap-1 text-xs uppercase tracking-wide text-[var(--c-base-content)]/40">
              <span class="transition-transform group-hover:-translate-x-0.5">←</span> Previous
            </span>
            <span class="w-full truncate text-left font-semibold capitalize">
              {String.replace(@prev.name, "_", " ")}
            </span>
          </.link>

          <.link
            :if={@next}
            navigate={~p"/showcase/#{@next.name}"}
            class="group ml-auto flex min-w-0 max-w-xs flex-col items-end gap-1 rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-5 py-4 shadow-sm transition-colors hover:border-[var(--c-primary)]"
          >
            <span class="flex items-center gap-1 text-xs uppercase tracking-wide text-[var(--c-base-content)]/40">
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

  defp page_header(assigns) do
    ~H"""
    <header class="space-y-2">
      <div class="flex items-center justify-between gap-4 flex-wrap">
        <.link navigate={~p"/showcase"} class="text-sm text-[var(--c-base-content)]/60 hover:underline">
          ← All components
        </.link>
        <div class="flex items-center gap-3 text-sm">
          <.link
            :if={@component.sibling}
            navigate={~p"/showcase/headless/#{@component.sibling}"}
            class="badge badge-secondary badge-outline gap-1"
          >
            ⇄ unstyled: {String.replace(@component.sibling, "_", " ")}
          </.link>
          <a
            :if={@component.doc_url}
            href={@component.doc_url}
            target="_blank"
            class="link link-primary"
          >
            Official docs ↗
          </a>
        </div>
      </div>
      <h1 class="text-3xl font-bold capitalize">{String.replace(@component.name, "_", " ")}</h1>
      <p class="text-[var(--c-base-content)]/70 max-w-2xl">{@component.description}</p>
      <span class="badge badge-sm">{@component.category}</span>
    </header>
    """
  end

  defp default_props(component) do
    dims =
      for dim <- component.dims,
          into: %{},
          do: {String.to_atom(dim.attr), cast(default_value(dim), dim.type)}

    flags = for flag <- component.flags, into: %{}, do: {String.to_atom(flag.name), flag.default}

    dims
    |> Map.merge(flags)
    |> Map.merge(preview_override(component.name))
  end

  defp preview_override("combobox"), do: %{variant: "bordered", searchable: true, multiple: true}
  defp preview_override("avatar"), do: %{size: "large", rounded: "full", space: "small"}

  defp preview_override("banner"),
    do: %{variant: "bordered", rounded: "large", padding: "medium", border: "medium"}

  defp preview_override("toast"), do: %{fixed: false}

  defp preview_override("fieldset"), do: %{variant: "outline"}

  defp preview_override("form_wrapper"), do: %{variant: "outline"}

  defp preview_override("native_select"), do: %{variant: "bordered"}
  defp preview_override("jumbotron"), do: %{variant: "base", padding: "large", space: "medium"}
  defp preview_override("layout"), do: %{justify: "center", align: "center", gap: "medium"}
  defp preview_override("list"), do: %{variant: "bordered", color: "natural", padding: "medium"}
  defp preview_override("rating"), do: %{interactive: true}
  defp preview_override("shape"), do: %{size: "large"}
  defp preview_override("table"), do: %{variant: "base", color: "natural", padding: "small"}

  defp preview_override("table_content"),
    do: %{variant: "base", color: "primary", size: "medium", padding: "medium", space: "small"}

  defp preview_override("timeline"), do: %{color: "primary", size: "medium"}
  defp preview_override("gallery"), do: %{cols: "three", gap: "small", rounded: "medium"}

  defp preview_override("dropdown"),
    do: %{variant: "default", color: "primary", position: "bottom"}

  defp preview_override("image"), do: %{rounded: "medium"}
  defp preview_override("typography"), do: %{color: "natural", size: "medium"}
  defp preview_override("stepper"), do: %{vertical: true}

  defp preview_override("stat"),
    do: %{trend: "up", variant: "base", size: "medium", rounded: "medium", padding: "medium"}

  defp preview_override("dock"), do: %{variant: "shadow", color: "primary", rounded: "large"}
  defp preview_override("footer"), do: %{variant: "default", color: "natural"}

  defp preview_override("mega_menu"),
    do: %{variant: "base", color: "natural", rounded: "large", padding: "small", space: "small"}

  defp preview_override("sidebar"), do: %{hide_position: "left"}

  defp preview_override("drawer"),
    do: %{variant: "default", color: "primary", size: "small", position: "left", show: true}

  defp preview_override("modal"), do: %{show: true}

  defp preview_override("overlay"),
    do: %{color: "base", opacity: "semi_opaque", backdrop: "small"}

  defp preview_override("popover"),
    do: %{
      variant: "default",
      color: "primary",
      rounded: "medium",
      padding: "small",
      width: "large",
      space: "small"
    }

  defp preview_override("tooltip"), do: %{position: "bottom"}
  defp preview_override(_), do: %{}

  defp default_value(%{key: "variant", values: vals}),
    do: if("default" in vals, do: "default", else: hd(vals))

  defp default_value(%{key: "color", values: vals}),
    do: Enum.find(vals, hd(vals), &(&1 == "primary"))

  defp default_value(%{kind: :range} = dim), do: dim[:default] || dim[:min] || 0
  defp default_value(%{values: [first | _]}), do: first

  defp cast(v, :atom) when is_binary(v), do: String.to_atom(v)

  defp cast(v, :integer) when is_binary(v) do
    case Integer.parse(v) do
      {n, _} -> n
      :error -> 0
    end
  end

  defp cast(v, :float) when is_binary(v) do
    case Float.parse(v) do
      {f, _} -> f
      :error -> 0.0
    end
  end

  defp cast(v, _), do: v
end
