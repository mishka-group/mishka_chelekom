defmodule DevelopmentWeb.Showcase.ComponentLive do
  @moduledoc """
  Interactive prop explorer for a single Mishka Chelekom component.

  Controls are derived from the component's catalog `args` (variant/color/size/…). Changing
  a control updates a live preview (rendered via `DevelopmentWeb.Showcase.Preview`) and the
  copy-paste HEEx snippet.
  """
  use DevelopmentWeb, :live_view

  alias DevelopmentWeb.Showcase.{Catalog, Preview}

  @sample "Mishka Chelekom"

  @impl true
  def mount(%{"component" => name}, _session, socket) do
    case Catalog.get(name) do
      nil ->
        {:ok, socket |> put_flash(:error, "Unknown component: #{name}") |> push_navigate(to: ~p"/showcase")}

      component ->
        {:ok,
         socket
         |> assign(:component, component)
         |> assign(:all, Catalog.all())
         |> assign(:sample, @sample)
         |> assign(:form, to_form(%{}, as: :demo))
         |> assign(:props, default_props(component))
         |> assign(:page_title, "#{component.name} · Showcase")}
    end
  end

  @impl true
  def handle_event("update", params, socket) do
    keys = dim_keys(socket.assigns.component)

    props =
      for {k, v} <- params, k in keys, v not in [nil, ""], into: %{} do
        {String.to_existing_atom(k), v}
      end

    {:noreply, assign(socket, :props, props)}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, :props, default_props(socket.assigns.component))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex min-h-screen bg-base-200 text-base-content">
      <.nav all={@all} current={@component.name} />

      <main class="flex-1 min-w-0 p-6 lg:p-10 space-y-6">
        <header class="space-y-1">
          <.link navigate={~p"/showcase"} class="text-sm text-base-content/60 hover:underline">
            ← All components
          </.link>
          <h1 class="text-3xl font-bold capitalize">{String.replace(@component.name, "_", " ")}</h1>
          <p class="text-base-content/60">
            <span class="badge badge-sm">{@component.category}</span>
            <a :if={@component.doc_url} href={@component.doc_url} target="_blank" class="ml-2 link link-primary text-sm">
              Official docs ↗
            </a>
          </p>
        </header>

        <div class="grid grid-cols-1 xl:grid-cols-[20rem_1fr] gap-6">
          <section class="bg-base-100 rounded-box p-5 shadow-sm h-fit">
            <h2 class="font-semibold mb-3">Props</h2>
            <form :if={@component.dims != []} phx-change="update" class="space-y-3">
              <label :for={dim <- @component.dims} class="block">
                <span class="text-sm font-medium capitalize">{String.replace(dim.key, "_", " ")}</span>
                <select
                  name={dim.key}
                  class="select select-bordered select-sm w-full mt-1"
                >
                  <option :for={v <- dim.values} value={v} selected={@props[String.to_existing_atom(dim.key)] == v}>
                    {v}
                  </option>
                </select>
              </label>
            </form>
            <p :if={@component.dims == []} class="text-sm text-base-content/60">
              This component has no styling dimensions to tweak.
            </p>
            <button type="button" phx-click="reset" class="btn btn-ghost btn-sm mt-4 w-full">
              Reset
            </button>
          </section>

          <section class="space-y-6 min-w-0">
            <div class="bg-base-100 rounded-box p-8 shadow-sm">
              <div class="text-xs uppercase tracking-wide text-base-content/40 mb-4">Live preview</div>
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

            <div class="bg-base-300 rounded-box p-5 shadow-sm">
              <div class="text-xs uppercase tracking-wide text-base-content/50 mb-2">HEEx</div>
              <pre class="text-sm overflow-x-auto"><code>{snippet(@component.name, @props)}</code></pre>
            </div>
          </section>
        </div>
      </main>
    </div>
    """
  end

  defp nav(assigns) do
    ~H"""
    <aside class="w-60 shrink-0 bg-base-100 border-r border-base-300 h-screen sticky top-0 overflow-y-auto hidden md:block">
      <div class="p-4 font-bold text-lg border-b border-base-300">Chelekom</div>
      <ul class="menu menu-sm">
        <li :for={c <- @all}>
          <.link navigate={~p"/showcase/#{c.name}"} class={[@current == c.name && "active"]}>
            {String.replace(c.name, "_", " ")}
          </.link>
        </li>
      </ul>
    </aside>
    """
  end

  defp default_props(component) do
    for %{key: key, values: [first | _]} <- component.dims, into: %{} do
      {String.to_existing_atom(key), first}
    end
  end

  defp dim_keys(component), do: Enum.map(component.dims, & &1.key)

  defp snippet(name, props) when map_size(props) == 0, do: "<.#{name} />"

  defp snippet(name, props) do
    attrs =
      props
      |> Enum.sort()
      |> Enum.map_join("\n", fn {k, v} -> "  #{k}=\"#{v}\"" end)

    "<.#{name}\n#{attrs}\n>\n  #{@sample}\n</.#{name}>"
  end
end
