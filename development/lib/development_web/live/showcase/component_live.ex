defmodule DevelopmentWeb.Showcase.ComponentLive do
  @moduledoc """
  A single standard (styled) component page. Left column documents it — description, real
  examples, how to author the same thing with the macro/Kit, and the full attribute/slot
  reference. The right column is a sticky, interactive preview driven by the component's catalog
  dimensions. Links across to the matching unstyled component when one exists.
  """
  use DevelopmentWeb, :live_view

  import DevelopmentWeb.Showcase.UI
  alias DevelopmentWeb.Showcase.{Catalog, Preview, Snippets, JsonMeta}

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
         # An upload config so the file_field preview's live/dropzone modes work (they render
         # <.live_file_input> / phx-drop-target and need a real Phoenix.LiveView.UploadConfig).
         # Following the mishka docs demo: accept images, a few entries. Harmless for other components.
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

  # The generated docs-examples module for a component (e.g. Examples.Button), or nil.
  defp examples_module(name) do
    mod = Module.concat([DevelopmentWeb.Showcase.Examples, Macro.camelize(name)])
    if Code.ensure_loaded?(mod) and function_exported?(mod, :sections, 0), do: mod
  end

  # Renders one open example section by delegating to the component's generated examples module.
  defp example(assigns), do: apply(assigns.mod, :example, [assigns])

  @impl true
  def handle_event("update", params, socket) do
    comp = socket.assigns.component
    by_attr = Map.new(comp.dims, &{&1.attr, &1})
    flag_names = MapSet.new(comp.flags, & &1.name)

    # Dims and flags live in separate <form>s, so each change only sends its own fields — merge into
    # the existing props rather than replacing. Checkboxes carry a hidden "false" so unticking works.
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

    # A flag toggles a `data-*` attr that several JS hooks read only ONCE, at mount, into a cached
    # config (e.g. the accordion's `multiple`, which the `Collapsible` hook reads in `getConfig/0`).
    # Patching the node in place leaves that cached config stale — the control appears dead. So when a
    # flag changes, bump the nonce to give the preview a fresh mount; dim/CSS changes re-render
    # correctly via a patch and stay cheap (no remount, so they don't reset the preview's open state).
    socket =
      if Enum.any?(Map.keys(params), &(&1 in flag_names)),
        do: update(socket, :preview_nonce, &(&1 + 1)),
        else: socket

    {:noreply, socket}
  end

  def handle_event("reset", _params, socket) do
    # Bumping the nonce changes the preview element's id, so LiveView replaces the DOM node entirely
    # rather than patching it. That restores any component a client-side action hid in place — e.g. a
    # toast/alert/banner dismissed via `hide_toast`/`hide_alert` (display:none on the same id, which a
    # plain re-render can't undo) — without a full page refresh.
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

  # File upload events for the file_field dropzone preview (mishka's file_live handlers). `validate`
  # fires on file select/drop — returning {:noreply} is enough for LiveView to track the entries.
  # `cancel-upload` is the dropzone's per-file close (X) button; it must call cancel_upload/3 to remove
  # the entry — the catch-all below would just no-op it, which is why the X did nothing.
  def handle_event("validate", _params, socket), do: {:noreply, socket}

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :showcase_file, ref)}
  end

  # The real Mishka components fire their own server events from interactive controls — a dismiss
  # button (`JS.push("dismiss") |> hide_toast(...)`), pagination/rating selection, etc. In a host app
  # the developer handles these to mutate their data; the showcase has no such data, and the visual
  # effect already happens client-side (the dismiss JS hides the element; Reset brings it back). So we
  # just acknowledge them — a catch-all keeps any current or future component-internal event from
  # crashing the explorer.
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 text-base-content">
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
              <p class="text-xs text-base-content/50">
                <span class="font-semibold text-base-content/70">1 ·</span> Customize it in your Kit
                (same value name ⇒ replace, new name ⇒ add):
              </p>
              <.code_block code={Snippets.customize(@component)} />
              <p class="text-xs text-base-content/50 mt-3">
                <span class="font-semibold text-base-content/70">2 ·</span>
                It generates a same-named wrapper — use it like the original:
              </p>
              <.code_block code={Snippets.customize_usage(@component)} />
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
              <div class="rounded-box ring-1 ring-base-content/5 divide-y divide-base-300 overflow-hidden">
                <div :for={s <- @example_sections}>
                  <button
                    type="button"
                    phx-click="toggle_example"
                    phx-value-id={s.id}
                    class="flex w-full items-center justify-between px-4 py-3 text-left text-sm font-medium hover:bg-base-100"
                  >
                    {s.title}
                    <span class={[
                      "text-base-content/40 transition-transform",
                      MapSet.member?(@open_examples, s.id) && "rotate-180"
                    ]}>
                      ▾
                    </span>
                  </button>
                  <div
                    :if={MapSet.member?(@open_examples, s.id)}
                    class="px-4 pb-5 pt-1 bg-base-100/40"
                  >
                    <.example mod={@examples_mod} section={s.id} />
                  </div>
                </div>
              </div>
            </.section>
          </div>

          <aside class="order-1 lg:order-2 lg:sticky lg:top-8 space-y-4">
            <div class="bg-base-100 rounded-box p-6 shadow-sm">
              <div class="text-xs uppercase tracking-wide text-base-content/40 mb-4">
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
              class="bg-base-100 rounded-box p-4 shadow-sm space-y-3"
            >
              <form :if={@component.dims != []} phx-change="update" class="space-y-2">
                <label :for={dim <- @component.dims} class="flex items-center justify-between gap-3">
                  <span class="text-sm capitalize text-base-content/70">
                    {String.replace(dim.key, "_", " ")}
                  </span>
                  <select name={dim.attr} class="select select-bordered select-xs w-40">
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
                class="space-y-1.5 border-t border-base-300 pt-3"
              >
                <div class="text-xs uppercase tracking-wide text-base-content/40">Props</div>
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
                    class="size-4 rounded border-base-300 accent-current"
                  />
                  <span class="text-sm capitalize text-base-content/70">
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
          class="flex items-stretch gap-4 border-t border-base-300 pt-6"
          aria-label="Component navigation"
        >
          <.link
            :if={@prev}
            navigate={~p"/showcase/#{@prev.name}"}
            class="group flex min-w-0 max-w-xs flex-col items-start gap-1 rounded-box border border-base-300 bg-base-100 px-5 py-4 shadow-sm transition-colors hover:border-primary"
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
            navigate={~p"/showcase/#{@next.name}"}
            class="group ml-auto flex min-w-0 max-w-xs flex-col items-end gap-1 rounded-box border border-base-300 bg-base-100 px-5 py-4 shadow-sm transition-colors hover:border-primary"
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

  defp page_header(assigns) do
    ~H"""
    <header class="space-y-2">
      <div class="flex items-center justify-between gap-4 flex-wrap">
        <.link navigate={~p"/showcase"} class="text-sm text-base-content/60 hover:underline">
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
      <p class="text-base-content/70 max-w-2xl">{@component.description}</p>
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

  # Per-component preview defaults so structural components show their good state. The combobox's
  # filled "default" variant renders solid cyan (the real Mishka primary accent) and the dropdown
  # is frozen by phx-update="ignore"; the BORDERED variant keeps the surface light while the Color
  # control stays meaningful, and searchable/multiple show its richer UX. The combobox preview also
  # uses a props-dependent id so the frozen dropdown subtree remounts when controls change.
  defp preview_override("combobox"), do: %{variant: "bordered", searchable: true, multiple: true}
  # Avatar's dims default to the first value (extra_small, square), and avatar_group `space` only
  # OVERLAPS (negative margins) — so tiny squares with overlap render as a broken blob where one
  # avatar hides the other. Default to a large, circular, lightly-overlapped stack (with rings in the
  # preview) so it reads as a real avatar group; every control stays adjustable from there.
  defp preview_override("avatar"), do: %{size: "large", rounded: "full", space: "small"}

  # Banner renders in-flow in the preview (see Preview.show) — give it visible rounding/border/padding
  # by default so the styling controls read clearly (dims `size`/`space` are dropped in Catalog).
  defp preview_override("banner"),
    do: %{variant: "bordered", rounded: "large", padding: "medium", border: "medium"}

  # Toast's `fixed` flag defaults to true, which pins it to a viewport corner (position:fixed) instead
  # of the preview box. Default it off so it renders in-flow where you can see it; the flag stays
  # toggleable to demo the fixed behaviour.
  defp preview_override("toast"), do: %{fixed: false}

  # Fieldset's `default` variant FILLS solid with the color, and the nested checkbox controls keep
  # their own dark label text — so labels blend into the fill and read poorly. Default to `outline`:
  # transparent background, colored border + legend, dark labels that stay legible. The colour is still
  # meaningful (border/legend/text take it); switch the variant to `default` for the filled look.
  defp preview_override("fieldset"), do: %{variant: "outline"}

  # Same reasoning as fieldset: form_wrapper's `default` fills solid (white text), so the fields/labels
  # inside read poorly. Default to `outline` so the form is legible; switch to `default` for the fill.
  defp preview_override("form_wrapper"), do: %{variant: "outline"}

  # native_select's `default` variant FILLS the select box with the color, and its focus ring is the
  # SAME color (ring-primary on bg-primary) → invisible. `bordered` gives a light tinted box with a
  # colored border + a contrasting focus ring, so the `ring` flag is actually visible on focus.
  defp preview_override("native_select"), do: %{variant: "bordered"}
  # jumbotron: a clean hero by default — `base` variant, roomy padding, and `space` so the stacked
  # heading/subtitle/CTAs breathe (all still adjustable via the controls).
  defp preview_override("jumbotron"), do: %{variant: "base", padding: "large", space: "medium"}
  # layout: start centered with a comfortable gap so the arranged boxes look intentional.
  defp preview_override("layout"), do: %{justify: "center", align: "center", gap: "medium"}
  # list: a clean bordered list with roomy rows, so `hoverable` reads clearly on hover.
  defp preview_override("list"), do: %{variant: "bordered", color: "natural", padding: "medium"}
  defp preview_override(_), do: %{}

  # Default the preview to options that actually show the component off: a color-bearing variant
  # and a vivid color, so changing controls is visibly meaningful (a `base`/`white` default looks
  # uncolored and reads as "broken").
  defp default_value(%{key: "variant", values: vals}),
    do: if("default" in vals, do: "default", else: hd(vals))

  defp default_value(%{key: "color", values: vals}),
    do: Enum.find(vals, hd(vals), &(&1 == "primary"))

  defp default_value(%{values: [first | _]}), do: first

  defp cast(v, :atom) when is_binary(v), do: String.to_atom(v)
  defp cast(v, _), do: v
end
