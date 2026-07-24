defmodule DevelopmentWeb.Showcase.Examples.Shape do
  @moduledoc """
  Docs examples for the `shape` component, taken from the Mishka source docs
  (`mishka/.../docs/shape_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "all-shapes", title: "All 15 shapes"},
      %{id: "sizes", title: "Sizes"},
      %{id: "half", title: "Half mode"},
      %{id: "content", title: "Custom content"}
    ]
  end

  def example(%{section: "all-shapes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-3 items-end">
      <div
        :for={
          shape <-
            ~w(squircle circle square heart star star_alt diamond pentagon hexagon hexagon_alt decagon triangle triangle_down triangle_left triangle_right)
        }
        class="flex flex-col items-center gap-2"
      >
        <.shape
          variant={shape}
          size="medium"
          class="bg-gradient-to-br from-primary-light to-misc-light dark:from-primary-dark dark:to-misc-dark"
        />
        <span class="text-[11px] font-mono opacity-70">{shape}</span>
      </div>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-3 items-end">
      <.shape
        :for={s <- ~w(extra_small small medium large extra_large)}
        variant="hexagon"
        size={s}
        class="bg-gradient-to-br from-primary-light to-info-light dark:from-primary-dark dark:to-info-dark"
      />
    </div>
    """
  end

  def example(%{section: "half"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-3">
      <.shape
        variant="hexagon"
        size="large"
        half="first"
        class="bg-success-light dark:bg-success-dark"
      />
      <.shape
        variant="hexagon"
        size="large"
        half="second"
        class="bg-danger-light dark:bg-danger-dark"
      />
    </div>
    """
  end

  def example(%{section: "content"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-3">
      <.shape variant="hexagon" size="large">
        <div class="bg-gradient-to-br from-primary-light to-primary-dark size-full flex items-center justify-center text-white font-bold">
          AB
        </div>
      </.shape>
      <.shape variant="star" size="large">
        <div class="bg-gradient-to-br from-warning-light to-danger-light size-full" />
      </.shape>
      <.shape variant="heart" size="large">
        <div class="bg-gradient-to-br from-danger-light to-misc-light size-full" />
      </.shape>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
