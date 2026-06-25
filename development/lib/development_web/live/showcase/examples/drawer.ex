defmodule DevelopmentWeb.Showcase.Examples.Drawer do
  @moduledoc """
  Docs examples for the `drawer` component, taken from the Mishka source docs
  (`mishka/.../docs/drawer_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  The drawer slides off-screen until opened. Each example sets `show={true}` so the component's
  internal `phx-mounted` hook opens it when the section mounts — no external JS commands needed.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "default", title: "Default Variant"},
      %{id: "outline", title: "Outline Variant"},
      %{id: "transparent", title: "Transparent Variant"},
      %{id: "bordered", title: "Bordered Variant"},
      %{id: "gradient", title: "Gradient Variant"},
      %{id: "sizes", title: "Sizes"},
      %{id: "title", title: "Title"},
      %{id: "header", title: "Header slot"}
    ]
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="relative min-h-48">
      <.drawer
        id="ex-drawer-default"
        variant="default"
        color="natural"
        position="left"
        size="small"
        show={true}
      >
        <ul>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Favorites</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Settings</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Profile</li>
        </ul>
      </.drawer>
    </div>
    """
  end

  def example(%{section: "outline"} = assigns) do
    ~H"""
    <div class="relative min-h-48">
      <.drawer
        id="ex-drawer-outline"
        variant="outline"
        color="primary"
        position="left"
        size="small"
        show={true}
      >
        <ul>
          <li class="py-2 px-3 hover:bg-blue-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-blue-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-blue-400 cursor-pointer">Favorites</li>
          <li class="py-2 px-3 hover:bg-blue-400 cursor-pointer">Settings</li>
          <li class="py-2 px-3 hover:bg-blue-400 cursor-pointer">Profile</li>
        </ul>
      </.drawer>
    </div>
    """
  end

  def example(%{section: "transparent"} = assigns) do
    ~H"""
    <div class="relative min-h-48">
      <.drawer
        id="ex-drawer-transparent"
        variant="transparent"
        color="secondary"
        position="left"
        size="small"
        show={true}
      >
        <ul>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Favorites</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Settings</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Profile</li>
        </ul>
      </.drawer>
    </div>
    """
  end

  def example(%{section: "bordered"} = assigns) do
    ~H"""
    <div class="relative min-h-48">
      <.drawer
        id="ex-drawer-bordered"
        variant="bordered"
        color="secondary"
        position="left"
        size="small"
        show={true}
      >
        <ul>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Favorites</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Settings</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Profile</li>
        </ul>
      </.drawer>
    </div>
    """
  end

  def example(%{section: "gradient"} = assigns) do
    ~H"""
    <div class="relative min-h-48">
      <.drawer
        id="ex-drawer-gradient"
        variant="gradient"
        color="secondary"
        position="left"
        size="small"
        show={true}
      >
        <ul>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Favorites</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Settings</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Profile</li>
        </ul>
      </.drawer>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="relative min-h-48">
      <.drawer id="ex-drawer-size" position="left" size="medium" show={true}>
        <ul>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Favorites</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Settings</li>
          <li class="py-2 px-3 hover:bg-purple-400 cursor-pointer">Profile</li>
        </ul>
      </.drawer>
    </div>
    """
  end

  def example(%{section: "title"} = assigns) do
    ~H"""
    <div class="relative min-h-48">
      <.drawer id="ex-drawer-title" position="left" title="Drawer component" show={true}>
        <ul>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Favorites</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Settings</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Profile</li>
        </ul>
      </.drawer>
    </div>
    """
  end

  def example(%{section: "header"} = assigns) do
    ~H"""
    <div class="relative min-h-48">
      <.drawer id="ex-drawer-header" position="left" show={true}>
        <:header>
          <p class="text-rose-400">Content inside header slot</p>
        </:header>

        <ul>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Home</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Inbox</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Favorites</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Settings</li>
          <li class="py-2 px-3 hover:bg-stone-400 cursor-pointer">Profile</li>
        </ul>
      </.drawer>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
