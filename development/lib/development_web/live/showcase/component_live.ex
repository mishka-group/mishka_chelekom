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
        {:ok,
         socket
         |> assign(:component, component)
         |> assign(:sample, @sample)
         |> assign(:form, to_form(%{}, as: :demo))
         |> assign(:props, default_props(component))
         |> assign(:examples, JsonMeta.examples(name))
         |> assign(:attrs, JsonMeta.attrs(name))
         |> assign(:slots, JsonMeta.slots(name))
         |> assign(:deps, JsonMeta.dependencies(name))
         |> assign(:page_title, "#{component.name} · Standard")}
    end
  end

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
          dim = by_attr[k] -> if v in [nil, ""], do: acc, else: Map.put(acc, String.to_atom(k), cast(v, dim.type))
          k in flag_names -> Map.put(acc, String.to_atom(k), v == "true")
          true -> acc
        end
      end)

    {:noreply, assign(socket, :props, Map.merge(socket.assigns.props, parsed))}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, :props, default_props(socket.assigns.component))}
  end

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
                The real <code>&lt;.{@component.name}&gt;</code> is never touched — the Kit generates
                a thin wrapper that delegates to it. Feed <code>MyAppWeb.Kit.safelist()</code> to
                Tailwind so your new classes survive purge.
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
          </div>

          <aside class="order-1 lg:order-2 lg:sticky lg:top-8 space-y-4">
            <div class="bg-base-100 rounded-box p-6 shadow-sm">
              <div class="text-xs uppercase tracking-wide text-base-content/40 mb-4">
                Live preview
              </div>
              <div class="flex flex-wrap items-center justify-center gap-4 min-h-24">
                <Preview.show
                  component={@component.name}
                  id={"showcase-#{@component.name}"}
                  props={@props}
                  form={@form}
                  sample={@sample}
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
    dims = for dim <- component.dims, into: %{}, do: {String.to_atom(dim.attr), cast(default_value(dim), dim.type)}
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
