defmodule DevelopmentWeb.Showcase.Examples.List do
  @moduledoc """
  Docs examples for the `list` component, taken from the Mishka source docs
  (`mishka/.../docs/list_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "variants", title: "Variants"},
      %{id: "sizes", title: "Sizes"},
      %{id: "space", title: "Space"},
      %{id: "styles", title: "List styles"},
      %{id: "ordered", title: "Ordered and unordered"},
      %{id: "icons", title: "Items with icons"},
      %{id: "count", title: "Items with count"},
      %{id: "group", title: "List group"}
    ]
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-4 items-start">
      <.list unordered variant="bordered" color="primary">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>

      <.list unordered variant="default" color="misc" size="small">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>

      <.list unordered variant="outline" space="small" color="success" size="small">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>

      <.list unordered variant="bordered_separated" space="small" color="info" size="small">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>

      <.list unordered variant="shadow" space="small" size="small" color="danger">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>

      <.list unordered variant="gradient" space="small" size="small" color="primary">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-4 items-start">
      <.list unordered variant="bordered_separated" color="dawn" size="extra_small">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>

      <.list unordered variant="bordered_separated" color="dawn" size="extra_large">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>
    </div>
    """
  end

  def example(%{section: "space"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-4 items-start">
      <.list unordered variant="bordered_separated" space="extra_large" color="dawn" size="small">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>

      <.list unordered variant="bordered_separated" space="extra_small" color="dawn" size="small">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>
    </div>
    """
  end

  def example(%{section: "styles"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-4 items-start">
      <.list unordered variant="transparent" color="secondary" style="list-disc">
        <:item padding="small">Home</:item>
        <:item padding="small">Services</:item>
        <:item padding="small">About Us</:item>
        <:item padding="small">Contact</:item>
      </.list>
    </div>
    """
  end

  def example(%{section: "ordered"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-4 items-start">
      <.list unordered variant="transparent" size="small" ordered>
        <.li padding="small">Bookmark</.li>
        <.li padding="small">Tickets</.li>
        <.li padding="small">Favorits</.li>
      </.list>

      <.list unordered variant="transparent" size="small" style="list-disc">
        <.li padding="small">Bookmark</.li>
        <.li padding="small">Tickets</.li>
        <.li padding="small">Favorits</.li>
      </.list>

      <.list unordered variant="transparent" size="small">
        <.li padding="small">Bookmark</.li>
        <.li padding="small">Tickets</.li>
        <.li padding="small">Favorits</.li>
      </.list>
    </div>
    """
  end

  def example(%{section: "icons"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-4 items-start">
      <.list unordered color="danger" size="small">
        <.li padding="small" icon="hero-bookmark">Bookmark</.li>
        <.li padding="small" icon="hero-ticket">Tickets</.li>
        <.li padding="small" icon="hero-star">Favorits</.li>
      </.list>

      <.list unordered color="success" size="large">
        <.li padding="small" icon="hero-bookmark">Bookmark</.li>
        <.li padding="small" icon="hero-ticket">Tickets</.li>
        <.li padding="small" icon="hero-star">Favorits</.li>
      </.list>
    </div>
    """
  end

  def example(%{section: "count"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-4 items-start">
      <.list unordered color="primary">
        <:item padding="small" count={1}>Home</:item>
        <:item padding="small" count={2}>Services</:item>
        <:item padding="small" count={3}>About Us</:item>
        <:item padding="small" count={4}>Contact</:item>
      </.list>

      <.list unordered color="primary">
        <:item padding="small" count={1} count_separator="_">Home</:item>
        <:item padding="small" count={2} count_separator="_">Services</:item>
        <:item padding="small" count={3} count_separator="_">About Us</:item>
        <:item padding="small" count={4} count_separator="_">Contact</:item>
      </.list>
    </div>
    """
  end

  def example(%{section: "group"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-4 items-start">
      <.list_group variant="outline" color="warning" size="small">
        <.li padding="small">Home</.li>
        <.li padding="small">Services</.li>
        <.li padding="small">About Us</.li>
        <.li padding="small">Contact</.li>
      </.list_group>

      <.list_group variant="bordered_separated" color="info" size="small">
        <.li padding="small">Home</.li>
        <.li padding="small">Services</.li>
        <.li padding="small">About Us</.li>
        <.li padding="small">Contact</.li>
      </.list_group>

      <.list_group variant="default" hoverable color="danger" rounded="extra_large">
        <.li padding="small">Home</.li>
        <.li padding="small">Payments</.li>
        <.li padding="small">Settings</.li>
      </.list_group>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
