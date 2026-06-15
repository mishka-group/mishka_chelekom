defmodule DevelopmentWeb.Showcase.Examples.Pagination do
  @moduledoc """
  Docs examples for the `pagination` component, taken faithfully from the Mishka source docs
  (`priv/demos/pagination_live.html.heex`). One section per variant (each across all colors), plus a
  section for every documented prop — mirroring the source 1:1.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from the
  DOM), so all examples never render at once. The source binds `total`/`active` from `@posts`
  (`%{total: 10, active: 1}`); here they are inlined as literals so the module is self-contained.
  """
  use DevelopmentWeb, :html

  @colors ~w(natural primary secondary success warning danger info silver misc dawn)

  def sections do
    [
      %{id: "base", title: "Base variant"},
      %{id: "default", title: "Default variant"},
      %{id: "outline", title: "Outline variant"},
      %{id: "transparent", title: "Transparent variant"},
      %{id: "gradient", title: "Gradient variant"},
      %{id: "subtle", title: "Subtle variant"},
      %{id: "shadow", title: "Shadow variant"},
      %{id: "inverted", title: "Inverted variant"},
      %{id: "grouped", title: "Grouped"},
      %{id: "radius", title: "Radius"},
      %{id: "sizes", title: "Sizes"},
      %{id: "space", title: "Space"},
      %{id: "separator", title: "Separator"},
      %{id: "prev_next", title: "Previous and next labels"},
      %{id: "first_last", title: "First and last labels"},
      %{id: "show_edges", title: "Show edges"},
      %{id: "hide_controls", title: "Hide controls"},
      %{id: "siblings", title: "Siblings"},
      %{id: "boundaries", title: "Boundaries"},
      %{id: "slots", title: "Start and end item slots"}
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

  def example(%{section: "default"} = assigns), do: variant_grid(assigns, "default")
  def example(%{section: "outline"} = assigns), do: variant_grid(assigns, "outline")
  def example(%{section: "transparent"} = assigns), do: variant_grid(assigns, "transparent")
  def example(%{section: "gradient"} = assigns), do: variant_grid(assigns, "gradient")
  def example(%{section: "subtle"} = assigns), do: variant_grid(assigns, "subtle")
  def example(%{section: "shadow"} = assigns), do: variant_grid(assigns, "shadow")
  def example(%{section: "inverted"} = assigns), do: variant_grid(assigns, "inverted")

  def example(%{section: "grouped"} = assigns) do
    assigns = assign(assigns, :colors, @colors)

    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination
        :for={c <- @colors}
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
    assigns =
      assign(assigns, :rows, [
        {"full", "info"},
        {"extra_small", "misc"},
        {"small", "warning"},
        {"medium", "success"},
        {"large", "primary"},
        {"extra_large", "secondary"},
        {"none", "danger"}
      ])

    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination
        :for={{r, c} <- @rows}
        total={10}
        active={1}
        size="small"
        rounded={r}
        color={c}
        variant="default"
      />
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
    assigns =
      assign(assigns, :rows, [
        {"extra_small", "misc"},
        {"small", "warning"},
        {"medium", "success"},
        {"large", "primary"},
        {"extra_large", "dawn"}
      ])

    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination
        :for={{s, c} <- @rows}
        total={10}
        active={1}
        size="small"
        space={s}
        color={c}
        variant="default"
      />
    </div>
    """
  end

  def example(%{section: "separator"} = assigns) do
    ~H"""
    <.pagination
      total={10}
      active={1}
      size="small"
      separator={%{type: :icon, value: "hero-hashtag"}}
      color="info"
    />
    """
  end

  def example(%{section: "prev_next"} = assigns) do
    ~H"""
    <.pagination
      total={10}
      active={1}
      size="small"
      next_label={%{type: :icon, value: "hero-chevron-double-right"}}
      previous_label={%{type: :icon, value: "hero-chevron-double-left"}}
      color="warning"
      variant="default"
    />
    """
  end

  def example(%{section: "first_last"} = assigns) do
    ~H"""
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
    """
  end

  def example(%{section: "show_edges"} = assigns) do
    ~H"""
    <.pagination total={10} active={1} size="small" show_edges />
    """
  end

  def example(%{section: "hide_controls"} = assigns) do
    ~H"""
    <.pagination total={10} active={1} size="small" hide_controls />
    """
  end

  def example(%{section: "siblings"} = assigns) do
    ~H"""
    <.pagination total={10} active={1} siblings={2} size="small" color="danger" variant="default" />
    """
  end

  def example(%{section: "boundaries"} = assigns) do
    ~H"""
    <.pagination total={10} active={1} boundaries={1} color="info" variant="default" size="small" />
    """
  end

  def example(%{section: "slots"} = assigns) do
    ~H"""
    <.pagination total={10} active={1} siblings={1} color="warning" variant="default" size="medium">
      <:start_items>First</:start_items>
      <:end_items>Last</:end_items>
    </.pagination>
    """
  end

  def example(assigns), do: ~H""

  defp variant_grid(assigns, variant) do
    assigns = assign(assigns, variant: variant, colors: @colors)

    ~H"""
    <div class="flex flex-col gap-4">
      <.pagination
        :for={c <- @colors}
        total={10}
        active={1}
        size="small"
        variant={@variant}
        color={c}
      />
    </div>
    """
  end
end
