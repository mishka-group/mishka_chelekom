defmodule DevelopmentWeb.Showcase.Examples.Badge do
  @moduledoc """
  Docs examples for the `badge` component, taken from the Mishka source docs
  (`mishka/.../docs/badge_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Base"},
      %{id: "variants", title: "Variants"},
      %{id: "colors", title: "Colors"},
      %{id: "sizes", title: "Sizes"},
      %{id: "radius", title: "Radius"},
      %{id: "icons", title: "Icons"},
      %{id: "indicator", title: "Indicator"},
      %{id: "circle", title: "Circle"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.badge>Base</.badge>
      <.badge size="small" rounded="medium">Base</.badge>
      <.badge size="medium" rounded="extra_large">Base</.badge>
      <.badge size="large">Base</.badge>
      <.badge size="extra_large" rounded="full">Base</.badge>
    </div>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.badge
        :for={v <- ~w(default outline transparent bordered gradient shadow)}
        variant={v}
        color="primary"
      >
        {String.capitalize(v)}
      </.badge>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.badge
        :for={c <- ~w(natural primary secondary success warning danger info silver misc dawn)}
        variant="default"
        color={c}
      >
        {String.capitalize(c)}
      </.badge>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.badge variant="bordered" color="secondary" size="extra_small">Extra Small</.badge>
      <.badge variant="bordered" color="secondary" size="small">Small</.badge>
      <.badge variant="bordered" color="secondary" size="medium">Medium</.badge>
      <.badge variant="bordered" color="secondary" size="large">Large</.badge>
      <.badge variant="bordered" color="secondary" size="extra_large">Extra Large</.badge>
    </div>
    """
  end

  def example(%{section: "radius"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.badge rounded="extra_small">Extra Small</.badge>
      <.badge rounded="small">Small</.badge>
      <.badge rounded="medium">Medium</.badge>
      <.badge rounded="large">Large</.badge>
      <.badge rounded="extra_large">Extra Large</.badge>
    </div>
    """
  end

  def example(%{section: "icons"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.badge variant="default" color="success" size="extra_small" icon="hero-arrow-trending-up">
        Up
      </.badge>
      <.badge variant="default" color="danger" size="extra_small" icon="hero-arrow-trending-down">
        Down
      </.badge>
      <.badge variant="default" color="info" size="extra_small" icon="hero-arrow-up-circle">
        Upload
      </.badge>
      <.badge variant="default" color="info" size="extra_small" icon="hero-inbox-solid">
        badge
      </.badge>
      <.badge color="info" size="extra_small" icon="hero-bell-slash">Notify</.badge>
    </div>
    """
  end

  def example(%{section: "indicator"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-6">
      <.badge variant="default" color="info" size="small" left_indicator>
        Left
      </.badge>
      <.badge variant="default" color="info" size="small" right_indicator indicator_size="small">
        Right
      </.badge>
      <.badge variant="default" color="info" size="small" top_left_indicator indicator_size="medium">
        Top Left
      </.badge>
      <.badge variant="default" color="danger" size="large" indicator pinging>
        Pinging
      </.badge>
    </div>
    """
  end

  def example(%{section: "circle"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.badge variant="default" color="misc" size="extra_small" circle>1</.badge>
      <.badge variant="default" color="misc" size="small" circle>2</.badge>
      <.badge variant="default" color="misc" size="medium" circle>3</.badge>
      <.badge variant="default" color="misc" size="large" circle>4</.badge>
      <.badge variant="default" color="misc" size="extra_large" rounded="full" circle>5</.badge>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
