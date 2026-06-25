defmodule DevelopmentWeb.Showcase.Examples.Breadcrumb do
  @moduledoc """
  Docs examples for the `breadcrumb` component, taken from the Mishka source docs
  (`mishka/.../docs/breadcrumb_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "item-slot", title: "How to use item slot"},
      %{id: "item-link", title: "Link prop of item slot"},
      %{id: "item-icon", title: "Add icon to each item slot"},
      %{id: "colors", title: "Colors"},
      %{id: "sizes", title: "Sizes"},
      %{id: "separator-icon", title: "Separator icon"},
      %{id: "separator-text", title: "Separator text"}
    ]
  end

  def example(%{section: "item-slot"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.breadcrumb id="ex-breadcrumb-item-slot">
        <:item link="/chelekom">Mishka Chelekom</:item>
        <:item link="/chelekom/docs/accordion">Accordion</:item>
        <:item link="/chelekom/docs/alert">Alert</:item>
      </.breadcrumb>
    </div>
    """
  end

  def example(%{section: "item-link"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.breadcrumb id="ex-breadcrumb-item-link" color="warning">
        <:item title="Mishka chelekom link prop of item1" link="/chelekom">Link1</:item>
        <:item title="Mishka chelekom link prop of item2" link="/chelekom">Link2</:item>
        <:item>No link</:item>
      </.breadcrumb>
    </div>
    """
  end

  def example(%{section: "item-icon"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.breadcrumb id="ex-breadcrumb-item-icon" color="warning">
        <:item icon="hero-cloud" link="/chelekom">Mishka Chelekom</:item>
        <:item icon="hero-circle-stack" link="/chelekom/docs/accordion">Accordion</:item>
        <:item icon="hero-envelope" link="/chelekom/docs/alert">Alert</:item>
      </.breadcrumb>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.breadcrumb
        :for={c <- ~w(base misc natural dawn silver info warning primary success secondary danger)}
        id={"ex-breadcrumb-color-#{c}"}
        color={c}
      >
        <:item>Mishka Chelekom</:item>
        <:item>Accordion</:item>
        <:item>Alert</:item>
      </.breadcrumb>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.breadcrumb
        :for={s <- ~w(extra_small small medium large extra_large)}
        id={"ex-breadcrumb-size-#{s}"}
        color="silver"
        size={s}
      >
        <:item>Mishka Chelekom</:item>
        <:item>Image</:item>
        <:item>Gallery</:item>
      </.breadcrumb>
    </div>
    """
  end

  def example(%{section: "separator-icon"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.breadcrumb color="silver" id="ex-breadcrumb-separator-icon" separator_icon="hero-star">
        <:item>Mishka Chelekom</:item>
        <:item>Image</:item>
        <:item>Gallery</:item>
      </.breadcrumb>
    </div>
    """
  end

  def example(%{section: "separator-text"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.breadcrumb color="silver" id="ex-breadcrumb-separator-text" separator_text="_">
        <:item>Mishka Chelekom</:item>
        <:item>Image</:item>
        <:item>Gallery</:item>
      </.breadcrumb>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
