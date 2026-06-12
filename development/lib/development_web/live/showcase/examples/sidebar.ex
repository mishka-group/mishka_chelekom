defmodule DevelopmentWeb.Showcase.Examples.Sidebar do
  @moduledoc """
  Docs examples for the `sidebar` component, taken from the Mishka source docs
  (`mishka/.../docs/sidebar_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  Note: in the real docs each sidebar is toggled by socket state / JS commands and rendered as a
  full-screen `fixed h-screen` overlay. For an always-on, self-contained showcase we drop the
  toggle gating and override the positioning (`!relative !h-auto`, fixed width) via the `class`
  prop so the sidebars render inline within their accordion section instead of overlapping the page.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "overview", title: "Overview"},
      %{id: "variant-colors", title: "Variant and color"},
      %{id: "border", title: "Border"},
      %{id: "size", title: "Size"},
      %{id: "position", title: "Position"},
      %{id: "minimize", title: "Minimize"},
      %{id: "item-slot", title: "Item slot"}
    ]
  end

  def example(%{section: "overview"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-6">
      <.sidebar
        id="ex-sidebar-overview"
        size="medium"
        hide_position="left"
        list_wrapper_class="ps-2.5"
        class="!relative !h-auto !z-0 max-h-72 w-64 rounded"
      >
        <:item icon="hero-home" label="Dashboard" link="/" class="mb-3 text-[14px]" />
        <:item icon="hero-envelope" label="Messages" link="/" class="mb-3 text-[14px]" />
        <:item icon="hero-star" label="Bookmarks" link="/" class="mb-3 text-[14px]" />
        <:item icon="hero-user-group" label="Teams" link="/" class="mb-3 text-[14px]" />
        <:item icon="hero-calendar" label="Calendar" link="/" class="mb-3 text-[14px]" />
        <:item icon="hero-cog-6-tooth" label="Settings" link="/" class="mb-3 text-[14px]" />
        <:item icon="hero-user-circle" label="Profile" link="/" class="mb-3 text-[14px]" />
      </.sidebar>
    </div>
    """
  end

  def example(%{section: "variant-colors"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-6">
      <.sidebar id="ex-sidebar-base" hide_position="left" class="!relative !h-auto !z-0 max-h-72 w-64 rounded">
        <:item icon="hero-home" icon_class="size-6" label="Dashboard" link="/" class="mb-3" />
        <:item icon="hero-envelope" icon_class="size-6" label="Messages" link="/" class="mb-3" />
        <:item icon="hero-star" icon_class="size-6" label="Bookmarks" link="/" class="mb-3" />
        <:item icon="hero-user-group" icon_class="size-6" label="Teams" link="/" class="mb-3" />
        <:item icon="hero-cog-6-tooth" icon_class="size-6" label="Settings" link="/" class="mb-3" />
      </.sidebar>

      <.sidebar
        id="ex-sidebar-silver"
        color="silver"
        variant="default"
        position="end"
        hide_position="right"
        class="!relative !h-auto !z-0 max-h-72 w-64 rounded"
      >
        <ul>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Favorits</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Projects</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Settings</li>
        </ul>
      </.sidebar>
    </div>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-6">
      <.sidebar
        id="ex-sidebar-border-sm"
        color="info"
        border="extra_small"
        variant="bordered"
        hide_position="left"
        class="!relative !h-auto !z-0 max-h-72 w-64 rounded"
      >
        <ul>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Projects</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Settings</li>
        </ul>
      </.sidebar>

      <.sidebar
        id="ex-sidebar-border-lg"
        color="misc"
        border="extra_large"
        position="end"
        variant="bordered"
        hide_position="right"
        class="!relative !h-auto !z-0 max-h-72 w-64 rounded"
      >
        <ul>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Projects</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Settings</li>
        </ul>
      </.sidebar>
    </div>
    """
  end

  def example(%{section: "size"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-6">
      <.sidebar
        id="ex-sidebar-size-xs"
        color="info"
        variant="default"
        size="extra_small"
        hide_position="left"
        class="!relative !h-auto !z-0 max-h-72 rounded"
      >
        <ul>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Projects</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Settings</li>
        </ul>
      </.sidebar>

      <.sidebar
        id="ex-sidebar-size-xl"
        color="misc"
        size="extra_large"
        position="end"
        variant="default"
        hide_position="right"
        class="!relative !h-auto !z-0 max-h-72 rounded"
      >
        <ul>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Projects</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Settings</li>
        </ul>
      </.sidebar>
    </div>
    """
  end

  def example(%{section: "position"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-6">
      <.sidebar
        id="ex-sidebar-pos-start"
        variant="default"
        color="info"
        border="extra_small"
        hide_position="left"
        class="!relative !h-auto !z-0 max-h-72 w-64 rounded"
      >
        <ul>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Projects</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Settings</li>
        </ul>
      </.sidebar>

      <.sidebar
        id="ex-sidebar-pos-end"
        color="misc"
        variant="default"
        border="extra_large"
        position="end"
        hide_position="right"
        class="!relative !h-auto !z-0 max-h-72 w-64 rounded"
      >
        <ul>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Projects</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Settings</li>
        </ul>
      </.sidebar>
    </div>
    """
  end

  def example(%{section: "minimize"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-6">
      <.sidebar
        id="ex-sidebar-minimize"
        border="extra_small"
        hide_position="left"
        minimize
        class="!relative !h-auto !z-0 max-h-72 w-64 rounded"
      >
        <:item icon="hero-home" icon_class="size-6" label="Dashboard" link="/" class="mb-3" />
        <:item icon="hero-envelope" icon_class="size-6" label="Messages" link="/" class="mb-3" />
        <:item icon="hero-star" icon_class="size-6" label="Bookmarks" link="/" class="mb-3" />
        <:item icon="hero-user-group" icon_class="size-6" label="Teams" link="/" class="mb-3" />
        <:item icon="hero-calendar" icon_class="size-6" label="Calendar" link="/" class="mb-3" />
        <:item icon="hero-cog-6-tooth" icon_class="size-6" label="Settings" link="/" class="mb-3" />
        <:item icon="hero-user-circle" icon_class="size-6" label="Profile" link="/" class="mb-3" />
      </.sidebar>
    </div>
    """
  end

  def example(%{section: "item-slot"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-6">
      <.sidebar
        id="ex-sidebar-items"
        color="primary"
        variant="default"
        hide_position="left"
        list_wrapper_class="ps-2.5"
        class="!relative !h-auto !z-0 max-h-72 w-64 rounded"
      >
        <:item icon="hero-home" icon_class="size-6" label="Dashboard" link="/" class="mb-3" />
        <:item icon="hero-document-text" icon_class="size-6" label="Reports" link="/" class="mb-3" />
        <:item icon="hero-briefcase" icon_class="size-6" label="Projects" link="/" class="mb-3" />
        <:item icon="hero-chart-bar" icon_class="size-6" label="Analytics" link="/" class="mb-3" />
        <:item icon="hero-shield-check" icon_class="size-6" label="Security" link="/" class="mb-3" />
      </.sidebar>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
