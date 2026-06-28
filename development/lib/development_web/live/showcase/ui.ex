defmodule DevelopmentWeb.Showcase.UI do
  @moduledoc """
  Small, shared presentational building blocks for the showcase — a titled `section`, a
  copy-enabled `code_block`, and `attrs`/`slots` reference tables. Keeping them here keeps the
  styled and headless detail pages consistent and minimal.
  """
  use Phoenix.Component

  @doc "A quiet, titled content section."
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def section(assigns) do
    ~H"""
    <section class={["space-y-3", @class]}>
      <div>
        <h2 class="text-sm font-semibold uppercase tracking-wide text-[var(--c-base-content)]/50">{@title}</h2>
        <p :if={@subtitle} class="text-sm text-[var(--c-base-content)]/60 mt-0.5">{@subtitle}</p>
      </div>
      {render_slot(@inner_block)}
    </section>
    """
  end

  @doc "A small, quiet info callout for clarifying tips."
  slot :inner_block, required: true

  def tip(assigns) do
    ~H"""
    <div class="flex gap-2 rounded-lg bg-[var(--c-info)]/10 ring-1 ring-[var(--c-info)]/20 p-3 text-xs text-[var(--c-base-content)]/80 leading-relaxed">
      <span class="shrink-0">💡</span>
      <div>{render_slot(@inner_block)}</div>
    </div>
    """
  end

  @doc "A code block with a copy button (uses the `Copy` JS hook)."
  attr :code, :string, required: true
  attr :class, :any, default: nil

  attr :wrap, :boolean,
    default: false,
    doc: "Wrap long lines instead of scrolling them off-screen"

  def code_block(assigns) do
    ~H"""
    <div class={["group relative rounded-lg bg-[var(--c-base-300)]/70 ring-1 ring-[var(--c-base-content)]/5", @class]}>
      <button
        type="button"
        phx-hook="Copy"
        id={"copy-#{:erlang.phash2(@code)}"}
        data-clipboard={@code}
        class="absolute right-2 top-2 btn btn-xs btn-ghost opacity-0 group-hover:opacity-100 transition"
      >
        Copy
      </button>
      <pre class={[
        "text-xs leading-relaxed p-4",
        (@wrap && "whitespace-pre-wrap break-words") || "overflow-x-auto"
      ]}><code>{@code}</code></pre>
    </div>
    """
  end

  @doc "Attribute reference table from `JsonMeta.attrs/1`-shaped maps."
  attr :attrs, :list, required: true

  def attrs_table(assigns) do
    ~H"""
    <div :if={@attrs == []} class="text-sm text-[var(--c-base-content)]/50">No attributes documented.</div>
    <div :if={@attrs != []} class="overflow-x-auto rounded-lg ring-1 ring-[var(--c-base-content)]/5">
      <table class="table table-sm">
        <thead>
          <tr>
            <th>Attribute</th>
            <th>Type</th>
            <th>Default</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={a <- @attrs}>
            <td class="font-mono text-xs whitespace-nowrap">{a.name}</td>
            <td class="font-mono text-xs text-[var(--c-base-content)]/60">{a.type}</td>
            <td class="font-mono text-xs text-[var(--c-base-content)]/60">{a.default || "—"}</td>
            <td class="text-xs text-[var(--c-base-content)]/70">
              {a.doc}
              <div :if={is_list(a[:values]) and a.values != []} class="mt-1 flex flex-wrap gap-1">
                <span :for={v <- a.values} class="badge badge-xs badge-ghost font-mono">{v}</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc "Slot reference table from `JsonMeta.slots/1`-shaped maps."
  attr :slots, :list, required: true

  def slots_table(assigns) do
    ~H"""
    <div :if={@slots != []} class="overflow-x-auto rounded-lg ring-1 ring-[var(--c-base-content)]/5">
      <table class="table table-sm">
        <thead>
          <tr>
            <th>Slot</th>
            <th>Required</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={s <- @slots}>
            <td class="font-mono text-xs whitespace-nowrap">{s.name}</td>
            <td class="text-xs">{(s.required && "yes") || "no"}</td>
            <td class="text-xs text-[var(--c-base-content)]/70">{s.doc}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
