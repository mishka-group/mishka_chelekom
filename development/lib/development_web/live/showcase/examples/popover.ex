defmodule DevelopmentWeb.Showcase.Examples.Popover do
  @moduledoc """
  Docs examples for the `popover` component, taken from the Mishka source docs
  (`mishka/.../docs/popover_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "clickable", title: "Clickable popover"},
      %{id: "show-arrow", title: "Show arrow prop"},
      %{id: "variants", title: "Variants"},
      %{id: "position", title: "Position prop"},
      %{id: "size", title: "Size prop"},
      %{id: "padding", title: "Padding prop"},
      %{id: "width", title: "Width prop"},
      %{id: "rounded", title: "Rounded prop"}
    ]
  end

  def example(%{section: "clickable"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-5">
      <.popover
        id="ex-popover-clickable-1"
        clickable
        rounded="small"
        width="large"
        color="info"
        variant="default"
        padding="small"
      >
        <:trigger>
          <.button variant="outline" color="info" size="small">popover trigger</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-clickable-2"
        clickable
        space="small"
        rounded="large"
        color="natural"
        variant="bordered"
        width="quadruple_large"
        padding="large"
      >
        <:trigger>
          <.button
            color="warning"
            size="large"
            variant="transparent"
            icon="hero-question-mark-circle"
          />
        </:trigger>
        <:content>
          <h4 class="font-semibold">Activity growth - Incremental</h4>
          <span class="block text-xs">
            Report helps navigate cumulative growth of community activities. Ideally, the chart should have a growing trend.
          </span>
          <span class="text-blue-500">See more..</span>
        </:content>
      </.popover>
    </div>
    """
  end

  def example(%{section: "show-arrow"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-5">
      <.popover
        id="ex-popover-arrow-1"
        rounded="small"
        width="large"
        color="primary"
        variant="default"
        padding="small"
        show_arrow={false}
      >
        <:trigger>
          <.button variant="outline" color="primary" size="small">no arrow</.button>
        </:trigger>
        <:content>
          A popover without arrow
        </:content>
      </.popover>

      <.popover
        id="ex-popover-arrow-2"
        rounded="small"
        width="large"
        color="primary"
        variant="default"
        padding="small"
        show_arrow={true}
      >
        <:trigger>
          <.button variant="outline" color="primary" size="small">with arrow</.button>
        </:trigger>
        <:content>
          A popover with arrow
        </:content>
      </.popover>
    </div>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.popover id="ex-popover-variant-base" rounded="small" width="large" padding="small">
        <:trigger>
          <.button variant="outline" color="natural" size="small">base</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-variant-default"
        rounded="small"
        width="large"
        color="warning"
        variant="default"
        padding="small"
      >
        <:trigger>
          <.button size="small" variant="outline" color="warning">default</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-variant-shadow"
        rounded="small"
        width="large"
        color="danger"
        padding="small"
        variant="shadow"
      >
        <:trigger>
          <.button size="small" variant="outline" color="danger">shadow</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-variant-bordered"
        rounded="small"
        width="large"
        color="info"
        padding="small"
        variant="bordered"
      >
        <:trigger>
          <.button size="small" variant="outline" color="info">bordered</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-variant-gradient"
        rounded="small"
        width="large"
        color="misc"
        padding="small"
        variant="gradient"
      >
        <:trigger>
          <.button size="small" variant="outline" color="misc">gradient</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>
    </div>
    """
  end

  def example(%{section: "position"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.popover
        id="ex-popover-position-top"
        rounded="small"
        width="large"
        variant="default"
        color="danger"
        padding="small"
      >
        <:trigger>
          <.button variant="outline" color="info" size="small">Top (Default)</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-position-bottom"
        rounded="small"
        width="large"
        color="silver"
        variant="default"
        padding="small"
        position="bottom"
      >
        <:trigger>
          <.button variant="outline" color="dawn" size="small">Bottom</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-position-right"
        rounded="small"
        width="large"
        color="misc"
        variant="default"
        padding="small"
        position="right"
      >
        <:trigger>
          <.button variant="outline" color="danger" size="small">Right</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-position-left"
        rounded="small"
        width="large"
        color="dark"
        variant="default"
        padding="small"
        position="left"
      >
        <:trigger>
          <.button variant="outline" color="misc" size="small">Left</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>
    </div>
    """
  end

  def example(%{section: "size"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.popover
        id="ex-popover-size-xl"
        rounded="small"
        width="large"
        color="danger"
        variant="default"
        size="extra_large"
        padding="small"
      >
        <:trigger>
          <.button variant="outline" color="danger" size="small">Extra large</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-size-xs"
        rounded="small"
        width="large"
        color="info"
        variant="default"
        padding="small"
        size="extra_small"
        position="bottom"
      >
        <:trigger>
          <.button variant="outline" color="info" size="small">Extra small</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.popover
        id="ex-popover-padding-xl"
        width="large"
        variant="default"
        color="dawn"
        padding="extra_large"
      >
        <:trigger>
          <.button variant="outline" color="dawn" size="small">Extra large</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-padding-xs"
        width="large"
        variant="default"
        color="silver"
        padding="extra_small"
      >
        <:trigger>
          <.button variant="outline" color="silver" size="small">Extra small</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>
    </div>
    """
  end

  def example(%{section: "width"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.popover
        id="ex-popover-width-xl"
        variant="default"
        color="dawn"
        padding="small"
        width="quadruple_large"
      >
        <:trigger>
          <.button variant="outline" color="dawn" size="small">Quadruple large</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-width-xs"
        variant="default"
        color="silver"
        padding="small"
        width="extra_small"
      >
        <:trigger>
          <.button variant="outline" color="silver" size="small">Extra small</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-8">
      <.popover
        id="ex-popover-rounded-xl"
        width="large"
        color="primary"
        variant="default"
        padding="small"
        rounded="extra_large"
      >
        <:trigger>
          <.button variant="outline" color="warning" size="small">Extra large</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>

      <.popover
        id="ex-popover-rounded-xs"
        width="large"
        color="primary"
        variant="default"
        padding="small"
        rounded="extra_small"
      >
        <:trigger>
          <.button variant="outline" color="primary" size="small">Extra small</.button>
        </:trigger>
        <:content>
          Content within popover content component
        </:content>
      </.popover>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
