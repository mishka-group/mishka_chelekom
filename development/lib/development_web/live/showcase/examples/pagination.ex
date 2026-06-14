defmodule DevelopmentWeb.Showcase.Examples.Pagination do
  @moduledoc """
  Docs examples for the `pagination` component, taken from the Mishka source docs
  (`mishka/.../docs/pagination_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  The doc binds `total`/`active` from `@posts` (`%{total: 10, active: 1}`); here they are inlined
  as literals so the module is self-contained.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Base variant"},
      %{id: "variants", title: "Variants"},
      %{id: "grouped", title: "Grouped"},
      %{id: "radius", title: "Radius"},
      %{id: "sizes", title: "Sizes"},
      %{id: "space", title: "Space"},
      %{id: "labels", title: "Labels and edges"},
      %{id: "siblings", title: "Siblings, boundaries and slots"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.pagination total={10} active={1} size="small" />
      <.pagination total={10} active={1} variant="transparent" color="natural" size="small" />
      <.pagination total={10} active={1} color="natural" variant="subtle" size="small" />
    </div>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination
        :for={v <- ~w(default outline transparent gradient subtle shadow inverted)}
        total={10}
        active={1}
        size="small"
        variant={v}
        color="primary"
      />
    </div>
    """
  end

  def example(%{section: "grouped"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination
        :for={c <- ~w(natural primary secondary success warning danger info)}
        total={10}
        active={1}
        size="small"
        grouped
        color={c}
        variant="default"
      />
    </div>
    """
  end

  def example(%{section: "radius"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination total={10} active={1} size="small" rounded="full" color="info" variant="default" />
      <.pagination
        total={10}
        active={1}
        size="small"
        rounded="extra_small"
        color="misc"
        variant="default"
      />
      <.pagination
        total={10}
        active={1}
        size="small"
        rounded="small"
        color="warning"
        variant="default"
      />
      <.pagination
        total={10}
        active={1}
        size="small"
        rounded="medium"
        color="success"
        variant="default"
      />
      <.pagination
        total={10}
        active={1}
        size="small"
        rounded="large"
        color="primary"
        variant="default"
      />
      <.pagination
        total={10}
        active={1}
        size="small"
        rounded="extra_large"
        color="secondary"
        variant="default"
      />
      <.pagination total={10} active={1} size="small" rounded="none" color="danger" variant="default" />
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination total={10} active={1} size="extra_small" color="misc" />
      <.pagination total={10} active={1} size="small" variant="default" color="warning" />
      <.pagination total={10} active={1} size="medium" variant="default" color="success" />
      <.pagination total={10} active={1} size="large" variant="default" color="primary" />
      <.pagination total={10} active={1} size="extra_large" color="dawn" variant="default" />
    </div>
    """
  end

  def example(%{section: "space"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination
        :for={s <- ~w(extra_small small medium large extra_large)}
        total={10}
        active={1}
        size="small"
        space={s}
        color="primary"
        variant="default"
      />
    </div>
    """
  end

  def example(%{section: "labels"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination
        total={10}
        active={1}
        size="small"
        separator={%{type: :icon, value: "hero-hashtag"}}
        color="info"
      />
      <.pagination
        total={10}
        active={1}
        size="small"
        next_label={%{type: :icon, value: "hero-chevron-double-right"}}
        previous_label={%{type: :icon, value: "hero-chevron-double-left"}}
        color="warning"
        variant="default"
      />
      <.pagination
        total={10}
        active={1}
        size="small"
        show_edges
        first_label={%{type: :icon, value: "hero-chevron-left"}}
        last_label={%{type: :icon, value: "hero-chevron-right"}}
        color="danger"
        variant="default"
      />
      <.pagination total={10} active={1} size="small" hide_controls />
    </div>
    """
  end

  def example(%{section: "siblings"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination total={10} active={1} siblings={2} size="small" color="danger" variant="default" />
      <.pagination total={10} active={1} boundaries={1} color="info" variant="default" size="small" />
      <.pagination total={10} active={1} siblings={1} color="warning" variant="default" size="medium">
        <:start_items>First</:start_items>
        <:end_items>Last</:end_items>
      </.pagination>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
