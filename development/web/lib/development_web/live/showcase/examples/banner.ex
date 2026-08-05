defmodule DevelopmentWeb.Showcase.Examples.Banner do
  @moduledoc """
  Docs examples for the `banner` component, taken from the Mishka source docs
  (`mishka/.../docs/banner_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  Note: the generated `<.banner>` renders `fixed z-50` (a screen-pinned overlay). The doc shows
  banners one at a time via a `@banner_pos` toggle. For an inline showcase we pass
  `class="!static !w-full"` so each banner flows in the column instead of overlapping the viewport.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "variants", title: "Variants"},
      %{id: "colors", title: "Colors"},
      %{id: "border", title: "Border size"},
      %{id: "border_position", title: "Border position"},
      %{id: "rounded", title: "Rounded"},
      %{id: "padding", title: "Padding"},
      %{id: "font_weight", title: "Font weight"}
    ]
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.banner
        :for={v <- ~w(base default outline shadow bordered transparent gradient)}
        id={"ex-banner-variant-#{v}"}
        variant={v}
        color="primary"
        class="!static !w-full"
      >
        {String.capitalize(v)} variant
      </.banner>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.banner
        :for={c <- ~w(natural primary secondary success warning danger info silver misc dawn)}
        id={"ex-banner-color-#{c}"}
        variant="default"
        color={c}
        class="!static !w-full"
      >
        {String.capitalize(c)} banner
      </.banner>
    </div>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.banner
        :for={b <- ~w(extra_small small medium large extra_large)}
        id={"ex-banner-border-#{b}"}
        variant="default"
        color="info"
        border={b}
        class="!static !w-full"
      >
        Border {b}
      </.banner>
    </div>
    """
  end

  def example(%{section: "border_position"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.banner
        :for={p <- ~w(top bottom full none)}
        id={"ex-banner-border-pos-#{p}"}
        variant="default"
        color="secondary"
        border="medium"
        border_position={p}
        class="!static !w-full"
      >
        Border position {p}
      </.banner>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.banner
        :for={r <- ~w(extra_small small medium large extra_large)}
        id={"ex-banner-rounded-#{r}"}
        variant="default"
        color="success"
        rounded={r}
        rounded_position="all"
        class="!static !w-full"
      >
        Rounded {r}
      </.banner>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.banner
        :for={p <- ~w(extra_small small medium large extra_large)}
        id={"ex-banner-padding-#{p}"}
        variant="default"
        color="dawn"
        padding={p}
        class="!static !w-full"
      >
        Padding {p}
      </.banner>
    </div>
    """
  end

  def example(%{section: "font_weight"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.banner
        id="ex-banner-font-thin"
        variant="default"
        color="primary"
        font_weight="font-thin"
        class="!static !w-full"
      >
        Font thin
      </.banner>
      <.banner
        id="ex-banner-font-medium"
        variant="default"
        color="secondary"
        font_weight="font-medium"
        class="!static !w-full"
      >
        Font medium
      </.banner>
      <.banner
        id="ex-banner-font-black"
        variant="default"
        color="warning"
        font_weight="font-black"
        class="!static !w-full"
      >
        Font black
      </.banner>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
