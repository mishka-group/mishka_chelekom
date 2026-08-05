defmodule DevelopmentWeb.Showcase.Examples.Overlay do
  @moduledoc """
  Docs examples for the `overlay` component, taken from the Mishka source docs
  (`mishka/.../docs/overlay_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "color", title: "Color"},
      %{id: "opacity", title: "Opacity"},
      %{id: "backdrop", title: "Backdrop"},
      %{id: "content", title: "Display content"}
    ]
  end

  def example(%{section: "color"} = assigns) do
    ~H"""
    <div class="relative h-96">
      <.overlay id="ex-overlay-color" color="dawn" opacity="almost_solid">
        <div class="flex justify-center items-center h-full">
          <div class="text-white">Dawn color...</div>
        </div>
      </.overlay>
    </div>
    """
  end

  def example(%{section: "opacity"} = assigns) do
    ~H"""
    <div class="relative h-96">
      <.overlay id="ex-overlay-opacity" color="silver" opacity="lightly_tinted">
        <div class="flex justify-center items-center h-full">
          <div class="text-white">Light color with Lightly Tinted opacity...</div>
        </div>
      </.overlay>
    </div>
    """
  end

  def example(%{section: "backdrop"} = assigns) do
    ~H"""
    <div class="relative h-96">
      <.overlay id="ex-overlay-backdrop" color="primary" opacity="tinted" backdrop="small">
        <div class="flex justify-center items-center h-full">
          <div class="text-white">Primary color with small value of backdrop...</div>
        </div>
      </.overlay>
    </div>
    """
  end

  def example(%{section: "content"} = assigns) do
    ~H"""
    <div class="relative h-96">
      <.overlay id="ex-overlay-content" color="silver" opacity="transparent" backdrop="small">
        <div class="flex justify-center items-center gap-4 h-full">
          <.spinner size="large" />
          <div>Misc color with small value of backdrop...</div>
        </div>
      </.overlay>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
