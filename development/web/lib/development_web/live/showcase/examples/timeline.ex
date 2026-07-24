defmodule DevelopmentWeb.Showcase.Examples.Timeline do
  @moduledoc """
  Docs examples for the `timeline` component, taken from the Mishka source docs
  (`mishka/.../docs/timeline_live.html.heex`). Section headers, no descriptions.

  The doc uses `~p"/images/mona-aghili.jpg"` assets that do not exist in this development
  showcase (only `logo.svg` is present), so — following the same convention as the
  `image`/`carousel` examples — remote `picsum.photos` placeholder URLs are used for the
  `image` / `<.image src=...>` references so the images actually render.

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
      %{id: "horizontal", title: "Horizontal"},
      %{id: "hide_last_line", title: "Hide last line"},
      %{id: "section", title: "Timeline section"},
      %{id: "line_size", title: "Section line size"},
      %{id: "size", title: "Section size"},
      %{id: "bullet_icon", title: "Section bullet icon"},
      %{id: "line_style", title: "Line style"}
    ]
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-8">
      <.timeline :for={c <- ~w(natural info success warning)} id={"ex-timeline-color-#{c}"} color={c}>
        <.timeline_section
          line_style="dashed"
          title="Initial Setup and Configuration"
          time="24 Oct, 2024"
          description="I set up the initial project structure for Mishka Chelekom, ensuring the environment was configured correctly for Phoenix LiveView."
        >
          <div class="mt-1 -ms-1 p-1 inline-flex items-center gap-x-2 text-xs">
            Mona Aghili
          </div>
        </.timeline_section>

        <.timeline_section
          title="Component Development and Testing"
          time="30 Oct, 2024"
          description="I developed several core components for Mishka Chelekom, including the timeline and card components."
        >
          <div class="mt-1 -ms-1 p-1 inline-flex items-center gap-x-2 text-xs">
            Mona Aghili
          </div>
        </.timeline_section>
      </.timeline>
    </div>
    """
  end

  def example(%{section: "horizontal"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.timeline id="ex-timeline-horizontal" color="info" horizontal>
        <.timeline_section horizontal title="Initial Setup" time="24 Oct, 2024"></.timeline_section>

        <.timeline_section horizontal title="Component Development" time="30 Oct, 2024">
        </.timeline_section>
      </.timeline>
    </div>
    """
  end

  def example(%{section: "hide_last_line"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-10">
      <.timeline id="ex-timeline-hide-1" color="misc" hide_last_line>
        <.timeline_section title="Initial Setup" time="24 Oct, 2024"></.timeline_section>

        <.timeline_section title="Component Development" time="30 Oct, 2024"></.timeline_section>
      </.timeline>
    </div>
    """
  end

  def example(%{section: "section"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.timeline id="ex-timeline-section">
        <.timeline_section
          title="Initial Setup and Configuration"
          time="24 Oct, 2024"
          description="I set up the initial project structure for Mishka Chelekom, ensuring the environment was configured correctly for Phoenix LiveView."
        >
          <div class="mt-1 -ms-1 p-1 inline-flex items-center gap-x-2 text-xs">
            Mona Aghili
          </div>
        </.timeline_section>

        <.timeline_section
          title="Component Development and Testing"
          time="30 Oct, 2024"
          description="I developed several core components for Mishka Chelekom, including the timeline and card components."
        >
          <div class="mt-1 -ms-1 p-1 inline-flex items-center gap-x-2 text-xs">
            Mona Aghili
          </div>
        </.timeline_section>

        <.timeline_section
          title="UI Enhancements and Final Review"
          time="10 Nov, 2024"
          description="I worked on refining the user interface for Mishka Chelekom, focusing on improving the accessibility and responsiveness of the components."
        >
          <div class="mt-1 -ms-1 p-1 inline-flex items-center gap-x-2 text-xs">
            Mona Aghili
          </div>
        </.timeline_section>
      </.timeline>
    </div>
    """
  end

  def example(%{section: "line_size"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.timeline id="ex-timeline-line-size-1">
        <.timeline_section
          line_size="extra_small"
          title="Initial Setup and Configuration"
          time="24 Oct, 2024"
          description="I set up the initial project structure for Mishka Chelekom, ensuring the environment was configured correctly for Phoenix LiveView."
        />
      </.timeline>
      <.timeline id="ex-timeline-line-size-2">
        <.timeline_section
          line_size="extra_large"
          title="Component Development and Testing"
          time="30 Oct, 2024"
          description="I developed several core components for Mishka Chelekom, including the timeline and card components."
        />
      </.timeline>
    </div>
    """
  end

  def example(%{section: "size"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.timeline id="ex-timeline-size">
        <.timeline_section
          size="extra_small"
          line_size="extra_small"
          title="Initial Setup and Configuration"
          time="24 Oct, 2024"
          description="I set up the initial project structure for Mishka Chelekom, ensuring the environment was configured correctly for Phoenix LiveView."
        />

        <.timeline_section
          line_size="extra_large"
          size="extra_large"
          title="Component Development and Testing"
          time="30 Oct, 2024"
          description="I developed several core components for Mishka Chelekom, including the timeline and card components."
        />
      </.timeline>
    </div>
    """
  end

  def example(%{section: "bullet_icon"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.timeline id="ex-timeline-bullet">
        <.timeline_section
          size="extra_large"
          bullet_icon="hero-beaker"
          line_size="extra_small"
          title="Initial Setup and Configuration"
          time="24 Oct, 2024"
          description="I set up the initial project structure for Mishka Chelekom, ensuring the environment was configured correctly for Phoenix LiveView."
        />

        <.timeline_section
          line_size="extra_large"
          size="extra_large"
          bullet_icon="hero-bolt"
          title="Component Development and Testing"
          time="30 Oct, 2024"
          description="I developed several core components for Mishka Chelekom, including the timeline and card components."
        />
      </.timeline>
    </div>
    """
  end

  def example(%{section: "line_style"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.timeline id="ex-timeline-line-style-h" color="success" horizontal>
        <.timeline_section
          horizontal
          title="Initial Setup"
          time="24 Oct, 2024"
          line_style="dashed"
          line_size="extra_large"
        >
        </.timeline_section>

        <.timeline_section
          horizontal
          title="Component Development"
          time="30 Oct, 2024"
          line_style="dotted"
        >
        </.timeline_section>
      </.timeline>

      <.timeline id="ex-timeline-line-style-v" color="warning">
        <.timeline_section
          time="Oct, 24"
          line_style="dashed"
          description="This is description of timeline section of mishka chelekom timeline component"
        />

        <.timeline_section
          time="Oct, 24"
          line_style="dotted"
          description="This is description of timeline section of mishka chelekom timeline component"
        />
      </.timeline>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
