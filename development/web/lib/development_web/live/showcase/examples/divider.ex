defmodule DevelopmentWeb.Showcase.Examples.Divider do
  @moduledoc """
  Docs examples for the `divider` component, taken from the Mishka source docs
  (`mishka/.../docs/divider_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "types", title: "Types"},
      %{id: "colors", title: "Colors"},
      %{id: "sizes", title: "Sizes"},
      %{id: "width", title: "Width"},
      %{id: "margin", title: "Margin"},
      %{id: "variation", title: "Variation"},
      %{id: "text", title: "Text slot"},
      %{id: "icons", title: "Icon slot"}
    ]
  end

  def example(%{section: "types"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6 w-full">
      <.divider id="ex-divider-type-1" color="silver" type="dashed" />
      <.divider id="ex-divider-type-2" color="warning" type="dotted" />
      <.hr id="ex-divider-type-3" color="info" type="solid" />
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6 w-full">
      <.divider
        :for={c <- ~w(base primary secondary success warning danger info misc dawn silver natural)}
        id={"ex-divider-color-#{c}"}
        color={c}
      />
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6 w-full">
      <.divider id="ex-divider-size-1" color="info" size="extra_small" />
      <.divider id="ex-divider-size-2" color="info" size="small" />
      <.divider id="ex-divider-size-3" color="dawn" size="medium" />
      <.divider id="ex-divider-size-4" color="misc" size="large" />
      <.divider id="ex-divider-size-5" color="silver" size="extra_large" />
    </div>
    """
  end

  def example(%{section: "width"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6 w-full">
      <.divider id="ex-divider-width-1" color="silver" width="half" />
      <.divider id="ex-divider-width-2" width="full" />
    </div>
    """
  end

  def example(%{section: "margin"} = assigns) do
    ~H"""
    <div class="flex flex-col w-full">
      <.divider id="ex-divider-margin-1" color="natural" margin="extra_small" />
      <.divider id="ex-divider-margin-2" color="info" margin="small" />
      <.divider id="ex-divider-margin-3" color="silver" margin="medium" />
      <.divider id="ex-divider-margin-4" color="dawn" margin="large" />
      <.divider id="ex-divider-margin-5" color="misc" margin="extra_large" />
    </div>
    """
  end

  def example(%{section: "variation"} = assigns) do
    ~H"""
    <div class="h-[200px] flex items-start gap-10 w-full">
      <.divider id="ex-divider-var-1" variation="vertical" color="info" height="h-full" />
      <.divider id="ex-divider-var-2" variation="vertical" color="natural" height="half" />
      <.divider id="ex-divider-var-3" variation="vertical" height="h-1/3" />
    </div>
    """
  end

  def example(%{section: "text"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6 w-full">
      <.divider id="ex-divider-text-1" type="dashed" size="small" color="natural" position="right">
        <:text>Or</:text>
      </.divider>
      <.divider id="ex-divider-text-2" size="small" color="success" position="left">
        <:text>Or</:text>
      </.divider>
      <.divider id="ex-divider-text-3" type="dotted" size="small" color="warning" position="middle">
        <:text>Or</:text>
      </.divider>
    </div>
    """
  end

  def example(%{section: "icons"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6 w-full">
      <.divider id="ex-divider-icon-1" type="dashed" size="small" color="danger" position="right">
        <:icon name="hero-circle-stack" />
      </.divider>
      <.divider id="ex-divider-icon-2" size="small" color="misc" position="left">
        <:icon name="hero-star" />
      </.divider>
      <.divider id="ex-divider-icon-3" type="dotted" size="small" color="dawn" position="middle">
        <:icon name="hero-beaker" />
      </.divider>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
