defmodule DevelopmentWeb.Showcase.Examples.Indicator do
  @moduledoc """
  Docs examples for the `indicator` component, taken from the Mishka source docs
  (`mishka/.../docs/indicator_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "overview", title: "Overview"},
      %{id: "colors", title: "Colors"},
      %{id: "pinging", title: "Pinging"},
      %{id: "sizes", title: "Sizes"},
      %{id: "positions", title: "Positions"}
    ]
  end

  def example(%{section: "overview"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-8">
      <.indicator color="base" size="extra_small" />
      <.indicator color="natural" size="extra_small" />
      <.indicator color="primary" size="medium" />
      <.indicator color="secondary" size="medium" />
      <.indicator color="warning" size="large" />
      <.indicator color="misc" size="large" />
      <.indicator color="dawn" size="extra_large" />
      <.indicator color="info" size="extra_large" />
      <.indicator color="success" size="extra_large" />
      <.indicator color="primary" pinging size="extra_small" />
      <.indicator color="danger" pinging size="small" />
      <.indicator color="warning" pinging size="medium" />
      <.indicator color="misc" pinging size="large" />
      <.indicator color="dawn" pinging size="extra_large" />
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-10 items-center">
      <.indicator size="extra_small" />
      <.indicator color="natural" size="extra_small" />
      <.indicator color="white" size="extra_small" />
      <.indicator color="primary" size="extra_small" />
      <.indicator color="secondary" size="extra_small" />
      <.indicator color="dark" size="extra_small" />
      <.indicator color="success" size="large" />
      <.indicator color="warning" size="large" />
      <.indicator color="danger" size="large" />
      <.indicator color="info" size="large" />
      <.indicator color="silver" size="extra_small" />
      <.indicator color="misc" size="extra_small" />
      <.indicator color="dawn" size="extra_small" />
    </div>
    """
  end

  def example(%{section: "pinging"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-10 items-center">
      <.indicator color="danger" size="extra_small" pinging />
      <.indicator color="misc" size="extra_small" pinging />
      <.indicator size="extra_small" pinging />
      <.indicator color="warning" size="large" pinging />
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-5 items-center">
      <.indicator size="large" />
      <.indicator color="primary" size="extra_small" />
      <.indicator color="dawn" size="small" />
      <.indicator color="misc" size="medium" />
      <.indicator color="silver" size="extra_large" />
    </div>
    """
  end

  def example(%{section: "positions"} = assigns) do
    ~H"""
    <div class="flex justify-center text-zinc-50 items-center relative bg-zinc-500 rounded w-60 h-20 mx-auto">
      <span>Indicator Wrapper</span>
      <.indicator color="info" pinging size="medium" top_left />
      <.indicator color="dawn" size="medium" top_center />
      <.indicator color="misc" pinging size="medium" top_right />
      <.indicator color="primary" size="medium" middle_left />
      <.indicator color="silver" size="medium" middle_right />
      <.indicator color="success" pinging size="medium" bottom_left />
      <.indicator color="secondary" size="medium" bottom_center />
      <.indicator color="warning" pinging size="medium" bottom_right />
    </div>
    """
  end

  def example(assigns), do: ~H""
end
