defmodule DevelopmentWeb.Showcase.Examples.Rating do
  @moduledoc """
  Docs examples for the `rating` component, taken from the Mishka source docs
  (`mishka/.../docs/rating_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "count", title: "Count"},
      %{id: "select", title: "Select"},
      %{id: "colors", title: "Colors"},
      %{id: "gap", title: "Gap"},
      %{id: "sizes", title: "Sizes"},
      %{id: "disabled", title: "Disabled"}
    ]
  end

  def example(%{section: "count"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.rating size="small" count={6} select={2} />
      <.rating size="small" count={8} interactive />
    </div>
    """
  end

  def example(%{section: "select"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.rating size="large" />
      <.rating size="large" select={3} />
      <.rating size="large" select={5} interactive />
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.rating size="extra_small" color="base" select={4} />
      <.rating size="extra_small" color="natural" select={3} />
      <.rating size="extra_small" color="white" select={3} />
      <.rating size="extra_small" color="primary" select={1} />
      <.rating size="extra_small" color="secondary" select={2} />
      <.rating size="extra_small" color="success" select={5} />
      <.rating size="extra_small" color="warning" select={1} />
      <.rating size="extra_small" color="danger" select={4} />
      <.rating size="extra_small" color="info" select={5} />
      <.rating size="extra_small" color="misc" select={1} />
      <.rating size="extra_small" color="dawn" select={2} />
      <.rating size="extra_small" color="silver" select={4} />
      <.rating size="extra_small" color="dark" select={3} />
    </div>
    """
  end

  def example(%{section: "gap"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.rating size="extra_small" color="white" select={3} gap="extra_small" />
      <.rating size="extra_small" color="primary" select={3} gap="small" />
      <.rating size="extra_small" color="secondary" select={3} gap="medium" />
      <.rating size="extra_small" color="success" select={3} gap="large" />
      <.rating size="extra_small" color="warning" select={3} gap="extra_large" />
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.rating select={3} size="extra_small" />
      <.rating select={3} size="small" />
      <.rating select={3} size="medium" />
      <.rating select={3} size="large" />
      <.rating select={3} size="extra_large" />
      <.rating select={3} size="double_large" />
      <.rating select={3} size="triple_large" />
      <.rating select={3} size="quadruple_large" />
    </div>
    """
  end

  def example(%{section: "disabled"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.rating select={3} size="large" disabled />
      <.rating id="ex-rating-disabled-interactive" select={2} size="large" interactive disabled />
    </div>
    """
  end

  def example(assigns), do: ~H""
end
