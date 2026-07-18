defmodule DevelopmentWeb.Components.Headless.NavLink do
  @moduledoc """
  Headless **nav link** — a navigation item, optionally with nested children (Mantine NavLink parity).

  A leaf renders a LiveView `<.link>` (`href`/`navigate`/`patch`) with `data-active` +
  `aria-current="page"` when `active`. When you pass a `children` slot it becomes a native
  `<details>` disclosure instead — **no JS** — so the parent toggles its nested links. Optional
  `icon` and `trailing` (e.g. a chevron) slots.

  Ships **no** styling — style via `chelekom-nav-link*` and the `data-active` / `[open]` hooks.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/nav_link
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"
  attr :label, :string, default: nil, doc: "Label text (or use the default slot)"
  attr :href, :string, default: nil, doc: "Leaf link href"
  attr :navigate, :string, default: nil, doc: "LiveView navigate"
  attr :patch, :string, default: nil, doc: "LiveView patch"

  attr :active, :boolean,
    default: false,
    doc: "Marks the item current (data-active + aria-current)"

  attr :default_opened, :boolean, default: false, doc: "Open nested children initially"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :label_class, :any, default: nil, doc: "Extra classes for the label row"
  attr :children_class, :any, default: nil, doc: "Extra classes for the nested container"
  attr :rest, :global

  slot :icon, doc: "Leading icon"
  slot :trailing, doc: "Trailing content (e.g. a chevron)"
  slot :inner_block, doc: "Label content (overrides the label attr)"
  slot :children, doc: "Nested nav links — when present, the item becomes a disclosure"

  def nav_link(assigns) do
    ~H"""
    <details
      :if={@children != []}
      id={@id}
      open={@default_opened}
      data-part="root"
      data-active={@active}
      class={["chelekom-nav-link", @class]}
      {@rest}
    >
      <summary data-part="control" class={["chelekom-nav-link__control", @label_class]}>
        <span :if={@icon != []} data-part="icon">{render_slot(@icon)}</span>
        <span data-part="label">{(@inner_block != [] && render_slot(@inner_block)) || @label}</span>
        <span :if={@trailing != []} data-part="trailing">{render_slot(@trailing)}</span>
      </summary>
      <div data-part="children" class={["chelekom-nav-link__children", @children_class]}>
        {render_slot(@children)}
      </div>
    </details>
    <.link
      :if={@children == []}
      id={@id}
      href={@href}
      navigate={@navigate}
      patch={@patch}
      data-part="link"
      data-active={@active}
      aria-current={@active && "page"}
      class={["chelekom-nav-link", @class]}
      {@rest}
    >
      <span :if={@icon != []} data-part="icon">{render_slot(@icon)}</span>
      <span data-part="label">{(@inner_block != [] && render_slot(@inner_block)) || @label}</span>
      <span :if={@trailing != []} data-part="trailing">{render_slot(@trailing)}</span>
    </.link>
    """
  end
end
