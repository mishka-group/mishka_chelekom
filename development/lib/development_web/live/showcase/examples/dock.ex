defmodule DevelopmentWeb.Showcase.Examples.Dock do
  @moduledoc """
  Docs examples for the `dock` component, taken from the Mishka source docs
  (`mishka/.../docs/dock_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Base Color & Variant"},
      %{id: "default", title: "Default variant"},
      %{id: "shadow", title: "Shadow variant"},
      %{id: "bordered", title: "Bordered variant"},
      %{id: "gradient", title: "Gradient variant"},
      %{id: "sizes", title: "Sizes"},
      %{id: "rounded", title: "Rounded"},
      %{id: "labels-badges", title: "Labels, badges & item colors"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <.dock id="ex-dock-base">
      <:item icon="hero-home" label="Home" navigate="/" active />
      <:item icon="hero-inbox" label="Inbox" navigate="/" />
      <:item icon="hero-cog-6-tooth" label="Settings" navigate="/" />
    </.dock>
    """
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.dock :for={c <- ~w(primary natural success danger)} id={"ex-dock-default-#{c}"} variant="default" color={c}>
        <:item icon="hero-home" label="Home" navigate="/" active />
        <:item icon="hero-inbox" label="Inbox" navigate="/" />
        <:item icon="hero-cog-6-tooth" label="Settings" navigate="/" />
      </.dock>
    </div>
    """
  end

  def example(%{section: "shadow"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.dock :for={c <- ~w(primary misc)} id={"ex-dock-shadow-#{c}"} variant="shadow" color={c}>
        <:item icon="hero-home" label="Home" navigate="/" active />
        <:item icon="hero-inbox" label="Inbox" navigate="/" />
        <:item icon="hero-cog-6-tooth" label="Settings" navigate="/" />
      </.dock>
    </div>
    """
  end

  def example(%{section: "bordered"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.dock id="ex-dock-bordered-success" variant="bordered" color="success">
        <:item icon="hero-home" label="Home" navigate="/" active />
        <:item icon="hero-inbox" label="Inbox" navigate="/" />
        <:item icon="hero-cog-6-tooth" label="Settings" navigate="/" />
      </.dock>
      <.dock id="ex-dock-bordered-info" variant="bordered" color="info" rounded="full">
        <:item icon="hero-home" label="Home" navigate="/" />
        <:item icon="hero-inbox" label="Inbox" navigate="/" active />
        <:item icon="hero-cog-6-tooth" label="Settings" navigate="/" />
      </.dock>
    </div>
    """
  end

  def example(%{section: "gradient"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.dock :for={c <- ~w(misc primary)} id={"ex-dock-gradient-#{c}"} variant="gradient" color={c}>
        <:item icon="hero-home" label="Home" navigate="/" active />
        <:item icon="hero-inbox" label="Inbox" navigate="/" />
        <:item icon="hero-cog-6-tooth" label="Settings" navigate="/" />
      </.dock>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.dock
        :for={s <- ~w(extra_small small medium large extra_large)}
        id={"ex-dock-size-#{s}"}
        size={s}
      >
        <:item icon="hero-home" label="Home" navigate="/" active />
        <:item icon="hero-inbox" label="Inbox" navigate="/" />
        <:item icon="hero-cog-6-tooth" label="Settings" navigate="/" />
      </.dock>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.dock
        :for={r <- ~w(none extra_small small medium large extra_large full)}
        id={"ex-dock-rounded-#{r}"}
        rounded={r}
      >
        <:item icon="hero-home" label="Home" navigate="/" active />
        <:item icon="hero-inbox" label="Inbox" navigate="/" />
        <:item icon="hero-cog-6-tooth" label="Settings" navigate="/" />
      </.dock>
    </div>
    """
  end

  def example(%{section: "labels-badges"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.dock id="ex-dock-no-labels" show_labels={false} rounded="full" size="large">
        <:item icon="hero-home" navigate="/" active />
        <:item icon="hero-magnifying-glass" navigate="/search" />
        <:item icon="hero-user" navigate="/profile" />
      </.dock>
      <.dock id="ex-dock-with-badge">
        <:item icon="hero-home" label="Home" navigate="/" />
        <:item icon="hero-inbox" label="Inbox" navigate="/" badge="3" active />
        <:item icon="hero-bell" label="Alerts" navigate="/" badge="9+" />
      </.dock>
      <.dock id="ex-dock-item-color" variant="bordered" rounded="large">
        <:item icon="hero-home" label="Home" navigate="/" color="primary" />
        <:item icon="hero-heart" label="Saved" navigate="/" color="danger" />
        <:item icon="hero-bolt" label="Quick" navigate="/" color="warning" />
      </.dock>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
