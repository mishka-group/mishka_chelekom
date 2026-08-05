defmodule DevelopmentWeb.Components.Stat do
  @moduledoc """
  The `DevelopmentWeb.Components.Stat` module provides a stat / metric block component for
  Phoenix LiveView dashboards. Use `stat/1` for a single metric and
  `stat_group/1` to wrap several stats with consistent dividers and orientation.

  ## Features

  - **Customizable Appearance:** `default`, `shadow`, `bordered`, `gradient`, and `base`
  variants combined with the full Mishka color palette.
  - **Trend Indicator:** Each stat can show an `up` / `down` / `neutral` trend that tints
  the description with chelekom success / danger / natural tokens and adds a directional arrow.
  - **Slot-based extras:** `:figure` for an icon or image, `:actions` for buttons, and
  `:inner_block` for fully custom content.
  - **Group Layout:** `stat_group/1` arranges multiple stats horizontally, vertically, or
  responsively (vertical on small screens, horizontal on large).

  All colors and shadows resolve to the chelekom CSS-variable tokens, so the component
  automatically follows your `priv/mishka_chelekom/config.exs` overrides.

  **Documentation:** https://mishka.tools/chelekom/docs/stat
  """

  use Phoenix.Component
  import DevelopmentWeb.Components.Icon, only: [icon: 1]

  @doc """
  Renders a single `stat` block: figure (icon/image) + title + value + description + actions.

  ## Examples

  ```elixir
  <.stat
    title="Total revenue"
    value="$45,231.89"
    description="+20.1% from last month"
    trend="up"
    color="primary"
  >
    <:figure>
      <.icon name="hero-currency-dollar" />
    </:figure>
  </.stat>
  ```
  """
  @doc type: :component
  attr :id, :string, default: nil, doc: "A unique identifier"
  attr :class, :any, default: nil, doc: "Custom CSS class for the stat container"
  attr :title_class, :any, default: nil, doc: "Class for the title row"
  attr :value_class, :any, default: nil, doc: "Class for the value row"
  attr :description_class, :any, default: nil, doc: "Class for the description row"
  attr :figure_class, :any, default: nil, doc: "Class for the figure wrapper"
  attr :actions_class, :any, default: nil, doc: "Class for the actions wrapper"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :size, :string, default: "medium", doc: "Determines value text scale"
  attr :rounded, :string, default: "medium", doc: "Determines the border radius"
  attr :padding, :string, default: "medium", doc: "Determines container padding"
  attr :border, :string, default: "extra_small", doc: "Border thickness"

  attr :title, :string, default: nil, doc: "Stat title / label"
  attr :value, :string, default: nil, doc: "Primary numeric / metric value"
  attr :description, :string, default: nil, doc: "Description or subtitle"

  attr :trend, :string,
    default: nil,
    doc: "Trend direction for the description: \"up\", \"down\", \"neutral\""

  attr :figure_position, :string, default: "start", doc: "Figure position: start | end | top"

  attr :font_weight, :string,
    default: "font-medium",
    doc: "Tailwind font-weight class for the value"

  attr :rest, :global, doc: "Pass-through attributes"

  slot :figure, required: false, doc: "Icon or image displayed alongside the stat"
  slot :actions, required: false, doc: "Buttons or links shown below the description"

  slot :inner_block,
    required: false,
    doc: "Optional inner content rendered after the description"

  def stat(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "stat-base relative",
        "[&_.stat-title]:text-xs [&_.stat-title]:opacity-60 [&_.stat-title]:uppercase [&_.stat-title]:tracking-wide",
        "[&_.stat-desc]:text-xs [&_.stat-desc]:opacity-70 [&_.stat-desc]:flex [&_.stat-desc]:items-center [&_.stat-desc]:gap-1",
        "[&_.stat-actions]:mt-2",
        "[&_.stat-figure]:shrink-0 [&_.stat-figure]:opacity-80",
        figure_layout(@figure_position),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        padding_size(@padding),
        border_class(@border, @variant),
        size_class(@size),
        @class
      ]}
      {@rest}
    >
      <div :if={@figure != []} class={["stat-figure", figure_size(@size), @figure_class]}>
        {render_slot(@figure)}
      </div>

      <div class="stat-content flex-1 min-w-0 space-y-1">
        <div :if={@title} class={["stat-title", @title_class]}>{@title}</div>
        <div
          :if={@value}
          class={["stat-value text-2xl leading-tight", @font_weight, value_size(@size), @value_class]}
        >
          {@value}
        </div>
        <div
          :if={@description}
          class={["stat-desc", trend_class(@trend), @description_class]}
        >
          <.icon :if={@trend} name={trend_icon(@trend)} class="size-3.5 shrink-0" />
          {@description}
        </div>
        <div :if={@actions != []} class={["stat-actions", @actions_class]}>
          {render_slot(@actions)}
        </div>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc """
  Wraps a row of `stat/1` blocks with consistent borders/dividers and orientation.

  ## Examples

  ```elixir
  <.stat_group orientation="horizontal" divider variant="base">
    <.stat title="Downloads" value="31K" />
    <.stat title="New users" value="4,200" />
    <.stat title="New posts" value="1,200" />
  </.stat_group>
  ```
  """
  @doc type: :component
  attr :id, :string, default: nil
  attr :class, :any, default: nil

  attr :variant, :string, default: "base"
  attr :color, :string, default: "natural"
  attr :rounded, :string, default: "medium"
  attr :padding, :string, default: "none"

  attr :orientation, :string,
    default: "horizontal",
    doc: "horizontal | vertical | responsive (vertical < lg, horizontal >= lg)"

  attr :divider, :boolean, default: true, doc: "Adds dividing borders between stats"
  attr :rest, :global
  slot :inner_block, required: true

  def stat_group(assigns) do
    ~H"""
    <div
      id={@id}
      role="group"
      class={[
        "stat-group-base overflow-hidden",
        orientation_class(@orientation),
        @divider && divider_class(@orientation),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        padding_size(@padding),
        "[&>.stat-base]:flex-1",
        "[&>.stat-base]:!border-0 [&>.stat-base]:!rounded-none [&>.stat-base]:!shadow-none",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp orientation_class("horizontal"), do: "flex flex-row"
  defp orientation_class("vertical"), do: "flex flex-col"
  defp orientation_class("responsive"), do: "flex flex-col lg:flex-row"
  defp orientation_class(params) when is_binary(params), do: params

  defp divider_class("horizontal"),
    do:
      "[&>.stat-base+.stat-base]:!border-l [&>.stat-base+.stat-base]:border-base-border-light dark:[&>.stat-base+.stat-base]:border-base-border-dark"

  defp divider_class("vertical"),
    do:
      "[&>.stat-base+.stat-base]:!border-t [&>.stat-base+.stat-base]:border-base-border-light dark:[&>.stat-base+.stat-base]:border-base-border-dark"

  defp divider_class("responsive"),
    do:
      "[&>.stat-base+.stat-base]:!border-t [&>.stat-base+.stat-base]:border-base-border-light dark:[&>.stat-base+.stat-base]:border-base-border-dark lg:[&>.stat-base+.stat-base]:!border-t-0 lg:[&>.stat-base+.stat-base]:!border-l"

  defp divider_class(_), do: nil

  defp figure_layout("start"), do: "flex flex-row items-center gap-4"
  defp figure_layout("end"), do: "flex flex-row-reverse items-center gap-4"
  defp figure_layout("top"), do: "flex flex-col gap-2"
  defp figure_layout(params) when is_binary(params), do: params

  defp figure_size("extra_small"), do: "[&_.icon]:size-4 [&_svg]:size-4"
  defp figure_size("small"), do: "[&_.icon]:size-5 [&_svg]:size-5"
  defp figure_size("medium"), do: "[&_.icon]:size-7 [&_svg]:size-7"
  defp figure_size("large"), do: "[&_.icon]:size-9 [&_svg]:size-9"
  defp figure_size("extra_large"), do: "[&_.icon]:size-12 [&_svg]:size-12"
  defp figure_size(_), do: "[&_.icon]:size-7 [&_svg]:size-7"

  defp value_size("extra_small"), do: "text-base"
  defp value_size("small"), do: "text-lg"
  defp value_size("medium"), do: "text-2xl"
  defp value_size("large"), do: "text-3xl"
  defp value_size("extra_large"), do: "text-4xl"
  defp value_size(_), do: "text-2xl"

  defp size_class("extra_small"), do: "[&_.stat-title]:text-[10px]"

  defp size_class("small"), do: "[&_.stat-title]:text-[11px]"

  defp size_class("medium"), do: nil

  defp size_class("large"), do: "[&_.stat-title]:text-sm"

  defp size_class("extra_large"), do: "[&_.stat-title]:text-base"

  defp size_class(_), do: nil

  defp trend_class("up"), do: "!opacity-100 text-success-light dark:text-success-dark"
  defp trend_class("down"), do: "!opacity-100 text-danger-light dark:text-danger-dark"
  defp trend_class("neutral"), do: "!opacity-100 text-natural-light dark:text-natural-dark"
  defp trend_class(_), do: nil

  defp trend_icon("up"), do: "hero-arrow-trending-up"
  defp trend_icon("down"), do: "hero-arrow-trending-down"
  defp trend_icon("neutral"), do: "hero-minus"
  defp trend_icon(_), do: "hero-minus"

  defp padding_size("none"), do: "p-0"

  defp padding_size("extra_small"), do: "p-2"

  defp padding_size("small"), do: "p-3"

  defp padding_size("medium"), do: "p-4"

  defp padding_size("large"), do: "p-5"

  defp padding_size("extra_large"), do: "p-6"

  defp padding_size(params) when is_binary(params), do: params

  defp rounded_size("none"), do: "rounded-none"

  defp rounded_size("extra_small"), do: "rounded-sm"

  defp rounded_size("small"), do: "rounded"

  defp rounded_size("medium"), do: "rounded-md"

  defp rounded_size("large"), do: "rounded-lg"

  defp rounded_size("extra_large"), do: "rounded-xl"

  defp rounded_size("full"), do: "rounded-full"

  defp rounded_size(params) when is_binary(params), do: params

  defp border_class(_, variant) when variant in ["default", "shadow", "gradient"], do: nil
  defp border_class("none", _), do: "border-0"
  defp border_class("extra_small", _), do: "border"
  defp border_class("small", _), do: "border-2"
  defp border_class("medium", _), do: "border-[3px]"
  defp border_class("large", _), do: "border-4"
  defp border_class("extra_large", _), do: "border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "bg-white text-base-text-light border-base-border-light shadow-sm",
      "dark:bg-base-bg-dark dark:text-base-text-dark dark:border-base-border-dark"
    ]
  end

  defp color_variant("default", "white"), do: ["bg-white text-black"]

  defp color_variant("default", "dark"), do: ["bg-default-dark-bg text-white"]

  defp color_variant("default", "natural"),
    do: ["bg-natural-light text-white dark:bg-natural-dark dark:text-black"]

  defp color_variant("default", "primary"),
    do: ["bg-primary-light text-white dark:bg-primary-dark dark:text-black"]

  defp color_variant("default", "secondary"),
    do: ["bg-secondary-light text-white dark:bg-secondary-dark dark:text-black"]

  defp color_variant("default", "success"),
    do: ["bg-success-light text-white dark:bg-success-dark dark:text-black"]

  defp color_variant("default", "warning"),
    do: ["bg-warning-light text-white dark:bg-warning-dark dark:text-black"]

  defp color_variant("default", "danger"),
    do: ["bg-danger-light text-white dark:bg-danger-dark dark:text-black"]

  defp color_variant("default", "info"),
    do: ["bg-info-light text-white dark:bg-info-dark dark:text-black"]

  defp color_variant("default", "misc"),
    do: ["bg-misc-light text-white dark:bg-misc-dark dark:text-black"]

  defp color_variant("default", "dawn"),
    do: ["bg-dawn-light text-white dark:bg-dawn-dark dark:text-black"]

  defp color_variant("default", "silver"),
    do: ["bg-silver-light text-white dark:bg-silver-dark dark:text-black"]

  defp color_variant("shadow", "white"), do: ["bg-white text-black shadow-xl"]

  defp color_variant("shadow", "dark"),
    do: ["bg-default-dark-bg text-white shadow-xl dark:shadow-none"]

  defp color_variant("shadow", "natural") do
    [
      "bg-natural-light text-white dark:bg-natural-dark dark:text-black",
      "shadow-[0px_4px_6px_-4px_var(--color-shadow-natural)] shadow-[0px_10px_15px_-3px_var(--color-shadow-natural)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-primary-light text-white dark:bg-primary-dark dark:text-black",
      "shadow-[0px_4px_6px_-4px_var(--color-shadow-primary)] shadow-[0px_10px_15px_-3px_var(--color-shadow-primary)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-secondary-light text-white dark:bg-secondary-dark dark:text-black",
      "shadow-[0px_4px_6px_-4px_var(--color-shadow-secondary)] shadow-[0px_10px_15px_-3px_var(--color-shadow-secondary)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-success-light text-white dark:bg-success-dark dark:text-black",
      "shadow-[0px_4px_6px_-4px_var(--color-shadow-success)] shadow-[0px_10px_15px_-3px_var(--color-shadow-success)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-warning-light text-white dark:bg-warning-dark dark:text-black",
      "shadow-[0px_4px_6px_-4px_var(--color-shadow-warning)] shadow-[0px_10px_15px_-3px_var(--color-shadow-warning)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-danger-light text-white dark:bg-danger-dark dark:text-black",
      "shadow-[0px_4px_6px_-4px_var(--color-shadow-danger)] shadow-[0px_10px_15px_-3px_var(--color-shadow-danger)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-info-light text-white dark:bg-info-dark dark:text-black",
      "shadow-[0px_4px_6px_-4px_var(--color-shadow-info)] shadow-[0px_10px_15px_-3px_var(--color-shadow-info)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-misc-light text-white dark:bg-misc-dark dark:text-black",
      "shadow-[0px_4px_6px_-4px_var(--color-shadow-misc)] shadow-[0px_10px_15px_-3px_var(--color-shadow-misc)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-dawn-light text-white dark:bg-dawn-dark dark:text-black",
      "shadow-[0px_4px_6px_-4px_var(--color-shadow-dawn)] shadow-[0px_10px_15px_-3px_var(--color-shadow-dawn)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "bg-silver-light text-white dark:bg-silver-dark dark:text-black",
      "shadow-[0px_4px_6px_-4px_var(--color-shadow-silver)] shadow-[0px_10px_15px_-3px_var(--color-shadow-silver)] dark:shadow-none"
    ]
  end

  defp color_variant("bordered", "white"),
    do: ["bg-white text-black border-bordered-white-border"]

  defp color_variant("bordered", "dark"),
    do: ["bg-bordered-dark-bg text-white border-bordered-dark-border"]

  defp color_variant("bordered", "natural") do
    [
      "text-natural-bordered-text-light border-natural-bordered-text-light bg-natural-bordered-bg-light",
      "dark:text-natural-bordered-text-dark dark:border-natural-bordered-text-dark dark:bg-natural-bordered-bg-dark"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-primary-bordered-text-light border-primary-bordered-text-light bg-primary-bordered-bg-light",
      "dark:text-primary-bordered-text-dark dark:border-primary-bordered-text-dark dark:bg-primary-bordered-bg-dark"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-secondary-bordered-text-light border-secondary-bordered-text-light bg-secondary-bordered-bg-light",
      "dark:text-secondary-bordered-text-dark dark:border-secondary-bordered-text-dark dark:bg-secondary-bordered-bg-dark"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-success-bordered-text-light border-success-bordered-text-light bg-success-bordered-bg-light",
      "dark:text-success-bordered-text-dark dark:border-success-bordered-text-dark dark:bg-success-bordered-bg-dark"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-warning-bordered-text-light border-warning-bordered-text-light bg-warning-bordered-bg-light",
      "dark:text-warning-bordered-text-dark dark:border-warning-bordered-text-dark dark:bg-warning-bordered-bg-dark"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-danger-bordered-text-light border-danger-bordered-text-light bg-danger-bordered-bg-light",
      "dark:text-danger-bordered-text-dark dark:border-danger-bordered-text-dark dark:bg-danger-bordered-bg-dark"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-info-bordered-text-light border-info-bordered-text-light bg-info-bordered-bg-light",
      "dark:text-info-bordered-text-dark dark:border-info-bordered-text-dark dark:bg-info-bordered-bg-dark"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-misc-bordered-text-light border-misc-bordered-text-light bg-misc-bordered-bg-light",
      "dark:text-misc-bordered-text-dark dark:border-misc-bordered-text-dark dark:bg-misc-bordered-bg-dark"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-dawn-bordered-text-light border-dawn-bordered-text-light bg-dawn-bordered-bg-light",
      "dark:text-dawn-bordered-text-dark dark:border-dawn-bordered-text-dark dark:bg-dawn-bordered-bg-dark"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-silver-bordered-text-light border-silver-bordered-text-light bg-silver-bordered-bg-light",
      "dark:text-silver-bordered-text-dark dark:border-silver-bordered-text-dark dark:bg-silver-bordered-bg-dark"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "bg-gradient-to-br from-gradient-natural-from-light to-gradient-natural-to-light text-white",
      "dark:from-gradient-natural-from-dark dark:to-white dark:text-black"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "bg-gradient-to-br from-gradient-primary-from-light to-gradient-primary-to-light text-white",
      "dark:from-gradient-primary-from-dark dark:to-gradient-primary-to-dark dark:text-black"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "bg-gradient-to-br from-gradient-secondary-from-light to-gradient-secondary-to-light text-white",
      "dark:from-gradient-secondary-from-dark dark:to-gradient-secondary-to-dark dark:text-black"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "bg-gradient-to-br from-gradient-success-from-light to-gradient-success-to-light text-white",
      "dark:from-gradient-success-from-dark dark:to-gradient-success-to-dark dark:text-black"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "bg-gradient-to-br from-gradient-warning-from-light to-gradient-warning-to-light text-white",
      "dark:from-gradient-warning-from-dark dark:to-gradient-warning-to-dark dark:text-black"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "bg-gradient-to-br from-gradient-danger-from-light to-gradient-danger-to-light text-white",
      "dark:from-gradient-danger-from-dark dark:to-gradient-danger-to-dark dark:text-black"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "bg-gradient-to-br from-gradient-info-from-light to-gradient-info-to-light text-white",
      "dark:from-gradient-info-from-dark dark:to-gradient-info-to-dark dark:text-black"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "bg-gradient-to-br from-gradient-misc-from-light to-gradient-misc-to-light text-white",
      "dark:from-gradient-misc-from-dark dark:to-gradient-misc-to-dark dark:text-black"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "bg-gradient-to-br from-gradient-dawn-from-light to-gradient-dawn-to-light text-white",
      "dark:from-gradient-dawn-from-dark dark:to-gradient-dawn-to-dark dark:text-black"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "bg-gradient-to-br from-gradient-silver-from-light to-gradient-silver-to-light text-white",
      "dark:from-gradient-silver-from-dark dark:to-gradient-silver-to-dark dark:text-black"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params
end
