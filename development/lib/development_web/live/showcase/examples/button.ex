defmodule DevelopmentWeb.Showcase.Examples.Button do
  @moduledoc """
  Docs examples for the `button` component, taken from the Mishka source docs
  (`mishka/.../docs/button_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "colors", title: "Colors"},
      %{id: "variants", title: "Variants"},
      %{id: "sizes", title: "Sizes"},
      %{id: "icons", title: "Buttons with icons"},
      %{id: "group", title: "Button group"}
    ]
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <.button :for={c <- ~w(natural primary secondary success warning danger info)} color={c}>
        {String.capitalize(c)}
      </.button>
    </div>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <.button :for={v <- ~w(default outline transparent subtle shadow inverted)} variant={v} color="primary">
        {String.capitalize(v)}
      </.button>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <.button :for={s <- ~w(extra_small small medium large extra_large)} size={s} color="primary">
        {s}
      </.button>
    </div>
    """
  end

  def example(%{section: "icons"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <.button icon="hero-bookmark" color="primary">Save</.button>
      <.button icon="hero-trash" variant="outline" color="danger">Delete</.button>
      <.button icon="hero-arrow-right" variant="transparent" color="info" />
      <.button size="size-12" circle rounded="full" color="success" icon="hero-check" />
    </div>
    """
  end

  def example(%{section: "group"} = assigns) do
    ~H"""
    <.button_group color="natural">
      <.button variant="inverted" size="small" color="natural">Profile</.button>
      <.button variant="inverted" size="small" color="natural">Settings</.button>
      <.button variant="inverted" size="small" color="natural">Messages</.button>
    </.button_group>
    """
  end

  def example(assigns), do: ~H""
end
