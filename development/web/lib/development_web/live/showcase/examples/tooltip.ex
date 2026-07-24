defmodule DevelopmentWeb.Showcase.Examples.Tooltip do
  @moduledoc """
  Docs examples for the `tooltip` component, taken from the Mishka source docs
  (`mishka/.../docs/tooltip_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "triggers", title: "Tooltip triggers"},
      %{id: "default", title: "Default variant"},
      %{id: "bordered", title: "Bordered variant"},
      %{id: "gradient", title: "Gradient variant"},
      %{id: "shadow", title: "Shadow variant"},
      %{id: "sizes", title: "Sizes"},
      %{id: "positions", title: "Positions"},
      %{id: "clickable", title: "Clickable"}
    ]
  end

  def example(%{section: "triggers"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center justify-center gap-8">
      <.tooltip
        position="top"
        text="Button trigger example"
        width="min-w-40"
        rounded="large"
        size="extra_small"
      >
        <:trigger>
          <.button class="leading-5" size="small" variant="outline" color="primary">
            Button Trigger
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        position="bottom"
        text="Icon trigger example"
        width="min-w-32"
        rounded="large"
        size="extra_small"
      >
        <:trigger>
          <.button size="leading-5 size-10" variant="outline" color="secondary">
            <.icon name="hero-chevron-right" class="size-5" />
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        position="right"
        text="Link trigger example"
        width="min-w-36"
        rounded="large"
        size="extra_small"
      >
        <:trigger>
          <.link class="text-blue-600 hover:text-blue-800 underline cursor-pointer">
            Link Trigger
          </.link>
        </:trigger>
      </.tooltip>

      <.tooltip
        position="left"
        text="Text trigger example"
        width="min-w-36"
        rounded="large"
        size="extra_small"
      >
        <:trigger>
          <span class="cursor-help border-b border-dotted border-gray-400">
            Hover over me
          </span>
        </:trigger>
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center gap-8">
      <.tooltip
        id="ex-tooltip-default-1"
        text="Content inside tooltip"
        position="bottom"
        variant="default"
        color="dawn"
      >
        <:trigger>
          <.button variant="outline" color="success" size="small">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-default-2"
        text="Content inside tooltip"
        position="top"
        variant="default"
        color="info"
      >
        <:trigger>
          <.button variant="outline" color="warning" size="small">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-default-3"
        text="Content inside tooltip"
        position="left"
        variant="default"
        color="misc"
      >
        <:trigger>
          <.button variant="outline" color="primary" size="small">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "bordered"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center gap-8">
      <.tooltip
        id="ex-tooltip-bordered-1"
        text="Content inside tooltip"
        position="bottom"
        color="dawn"
        variant="bordered"
      >
        <:trigger>
          <.button variant="outline" color="danger" size="small">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-bordered-2"
        text="Content inside tooltip"
        position="top"
        color="info"
        variant="bordered"
      >
        <:trigger>
          <.button variant="outline" size="small" color="natural">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-bordered-3"
        text="Content inside tooltip"
        position="left"
        color="misc"
        variant="bordered"
      >
        <:trigger>
          <.button variant="outline" color="misc" size="small">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "gradient"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center gap-8">
      <.tooltip
        id="ex-tooltip-gradient-1"
        text="Content inside tooltip"
        position="bottom"
        color="dawn"
        variant="gradient"
      >
        <:trigger>
          <.button variant="outline" color="dawn" size="small">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-gradient-2"
        text="Content inside tooltip"
        position="top"
        color="info"
        variant="gradient"
      >
        <:trigger>
          <.button variant="outline" size="small" color="secondary">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-gradient-3"
        text="Content inside tooltip"
        position="left"
        color="misc"
        variant="gradient"
      >
        <:trigger>
          <.button variant="outline" color="dawn" size="small">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "shadow"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center gap-8">
      <.tooltip
        id="ex-tooltip-shadow-1"
        text="Content inside tooltip"
        variant="shadow"
        position="bottom"
        color="success"
      >
        <:trigger>
          <.button variant="outline" color="silver" size="small">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-shadow-2"
        text="Content inside tooltip"
        variant="shadow"
        position="top"
        color="danger"
      >
        <:trigger>
          <.button variant="outline" color="danger" size="small">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-shadow-3"
        text="Content inside tooltip"
        variant="shadow"
        position="left"
        color="warning"
      >
        <:trigger>
          <.button variant="outline" color="info" size="small">
            tooltip
          </.button>
        </:trigger>
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center gap-8">
      <.tooltip
        id="ex-tooltip-size-1"
        text="Content inside tooltip"
        size="extra_large"
        position="bottom"
        variant="default"
        color="misc"
      >
        <:trigger>
          <.button variant="outline" color="info" size="small">
            Extra large size
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-size-2"
        text="Content inside tooltip"
        variant="shadow"
        size="small"
        position="top"
        color="misc"
      >
        <:trigger>
          <.button variant="outline" color="dawn" size="small">
            Small size
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-size-3"
        text="Content inside tooltip"
        size="large"
        position="left"
        variant="default"
        color="misc"
      >
        <:trigger>
          <.button variant="outline" color="danger" size="small">
            Large size
          </.button>
        </:trigger>
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "positions"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center gap-8">
      <.tooltip
        id="ex-tooltip-position-1"
        text="Bottom position"
        position="bottom"
        variant="default"
        color="misc"
      >
        <:trigger>
          <.button variant="outline" color="primary" size="small">
            Bottom tooltip position
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-position-2"
        text="Top Position"
        variant="shadow"
        position="top"
        color="misc"
      >
        <:trigger>
          <.button variant="outline" size="small" color="natural">
            Top tooltip position
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-position-3"
        text="Left Position"
        position="left"
        variant="default"
        color="misc"
      >
        <:trigger>
          <.button variant="outline" size="small" color="info">
            Left tooltip position
          </.button>
        </:trigger>
      </.tooltip>

      <.tooltip
        id="ex-tooltip-position-4"
        text="Right Position"
        position="right"
        variant="default"
        color="misc"
      >
        <:trigger>
          <.button variant="outline" color="silver" size="small">
            Right tooltip position
          </.button>
        </:trigger>
      </.tooltip>
    </div>
    """
  end

  def example(%{section: "clickable"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center gap-8">
      <.tooltip
        position="top"
        text="This is a clickable tooltip"
        width="min-w-40"
        rounded="large"
        size="extra_small"
        variant="default"
        clickable
        color="info"
      >
        <:trigger>
          <span class="cursor-pointer">Click me to see tooltip</span>
        </:trigger>
      </.tooltip>

      <.tooltip
        position="bottom"
        text="Click tooltip with inline display"
        width="min-w-32"
        rounded="medium"
        size="small"
        variant="shadow"
        clickable
        inline
        color="primary"
      >
        <:trigger>
          <span class="cursor-pointer text-blue-600 underline">
            Inline clickable tooltip
          </span>
        </:trigger>
      </.tooltip>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
