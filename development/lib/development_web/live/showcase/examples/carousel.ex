defmodule DevelopmentWeb.Showcase.Examples.Carousel do
  @moduledoc """
  Docs examples for the `carousel` component, taken from the Mishka source docs
  (`mishka/.../docs/carousel_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  The doc uses `~p"/images/mishka-chelekom-media-N.jpg"` assets that do not exist in this
  development app, so the literal `image` strings below point at stable placeholder URLs instead.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "basic", title: "Slide slot"},
      %{id: "content", title: "Display content on the slide"},
      %{id: "content-position", title: "Position of content on each slide"},
      %{id: "overlay", title: "Overlay prop"},
      %{id: "size", title: "Size prop"},
      %{id: "indicator", title: "Indicator prop"},
      %{id: "autoplay", title: "Autoplay prop"}
    ]
  end

  def example(%{section: "basic"} = assigns) do
    ~H"""
    <div class="w-full max-w-2xl">
      <.carousel id="ex-carousel-1">
        <:slide image="https://picsum.photos/seed/chelekom-1/960/420" />
        <:slide image="https://picsum.photos/seed/chelekom-2/960/420" />
        <:slide image="https://picsum.photos/seed/chelekom-3/960/420" />
        <:slide image="https://picsum.photos/seed/chelekom-4/960/420" />
      </.carousel>
    </div>
    """
  end

  def example(%{section: "content"} = assigns) do
    ~H"""
    <div class="w-full max-w-2xl">
      <.carousel id="ex-carousel-2">
        <:slide
          image="https://picsum.photos/seed/chelekom-1/960/420"
          title="Mishka Chelekom Carousel"
        />
        <:slide
          image="https://picsum.photos/seed/chelekom-2/960/420"
          title="Easy to use"
          description="By simply using a few props, you can display the images you want and customize the content to fit your needs."
        />
        <:slide
          image="https://picsum.photos/seed/chelekom-3/960/420"
          description="Easily position your content anywhere on the carousel, whether it's at the top, bottom, center, or sides."
        />
      </.carousel>
    </div>
    """
  end

  def example(%{section: "content-position"} = assigns) do
    ~H"""
    <div class="w-full max-w-2xl">
      <.carousel id="ex-carousel-3">
        <:slide
          image="https://picsum.photos/seed/chelekom-1/960/420"
          title="Content position is set to around."
          content_position="around"
        />
        <:slide
          image="https://picsum.photos/seed/chelekom-2/960/420"
          title="Content position is set to start."
          content_position="start"
        />
        <:slide
          image="https://picsum.photos/seed/chelekom-3/960/420"
          description="Content position is set to end."
          content_position="end"
        />
        <:slide
          image="https://picsum.photos/seed/chelekom-4/960/420"
          description="Content position is set to center (default)."
          content_position="center"
        />
      </.carousel>
    </div>
    """
  end

  def example(%{section: "overlay"} = assigns) do
    ~H"""
    <div class="w-full max-w-2xl">
      <.carousel id="ex-carousel-4" overlay="primary">
        <:slide image="https://picsum.photos/seed/chelekom-1/960/420" title="Slide 1" />
        <:slide image="https://picsum.photos/seed/chelekom-2/960/420" title="Slide 2" />
        <:slide image="https://picsum.photos/seed/chelekom-3/960/420" title="Slide 3" />
        <:slide image="https://picsum.photos/seed/chelekom-4/960/420" title="Slide 4" />
      </.carousel>
    </div>
    """
  end

  def example(%{section: "size"} = assigns) do
    ~H"""
    <div class="w-full max-w-2xl">
      <.carousel id="ex-carousel-5" size="extra_small">
        <:slide
          image="https://picsum.photos/seed/chelekom-1/960/420"
          title="First Slide extra small size of carousel"
        />
        <:slide
          image="https://picsum.photos/seed/chelekom-2/960/420"
          title="Second Slide extra small size of carousel"
        />
        <:slide
          image="https://picsum.photos/seed/chelekom-3/960/420"
          title="Third slide extra small size of carousel"
        />
        <:slide
          image="https://picsum.photos/seed/chelekom-4/960/420"
          title="Fourth slide extra small size of carousel"
        />
      </.carousel>
    </div>
    """
  end

  def example(%{section: "indicator"} = assigns) do
    ~H"""
    <div class="w-full max-w-2xl">
      <.carousel id="ex-carousel-6" indicator>
        <:slide image="https://picsum.photos/seed/chelekom-1/960/420" />
        <:slide image="https://picsum.photos/seed/chelekom-2/960/420" />
        <:slide image="https://picsum.photos/seed/chelekom-3/960/420" />
        <:slide active image="https://picsum.photos/seed/chelekom-4/960/420" />
      </.carousel>
    </div>
    """
  end

  def example(%{section: "autoplay"} = assigns) do
    ~H"""
    <div class="w-full max-w-2xl">
      <.carousel id="ex-carousel-7" autoplay autoplay_interval={3000}>
        <:slide image="https://picsum.photos/seed/chelekom-1/960/420" />
        <:slide image="https://picsum.photos/seed/chelekom-2/960/420" />
        <:slide image="https://picsum.photos/seed/chelekom-3/960/420" />
        <:slide active image="https://picsum.photos/seed/chelekom-4/960/420" />
      </.carousel>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
