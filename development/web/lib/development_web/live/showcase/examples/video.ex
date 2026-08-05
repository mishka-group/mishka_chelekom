defmodule DevelopmentWeb.Showcase.Examples.Video do
  @moduledoc """
  Docs examples for the `video` component, taken from the Mishka source docs
  (`mishka/.../docs/video_live.html.heex`). Section headers, no descriptions.

  The doc uses `~p"/images/flower.mp4"` and `~p"/images/title_anouncement.jpg"` assets
  that do not exist in this development showcase (only `logo.svg` is present), so —
  following the same convention as the `image`/`carousel` examples — a remote sample
  MP4 (and a placeholder poster image) are used so the videos actually render. The
  Base64-encoded WebVTT caption track is kept verbatim from the doc.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  @sample_src "https://www.w3schools.com/html/mov_bbb.mp4"
  @poster_src "https://picsum.photos/id/1018/640/360"
  @vtt_src "data:text/vtt;base64,V0VCVlRUCgowMDowMDowMC4wMDAgLS0+IDAwOjAwOjAwLjk5OSAgbGluZTo4MCUKSGlsZHkhCgowMDowMDowMS4wMDAgLS0+IDAwOjAwOjAxLjQ5OSBsaW5lOjgwJQpIb3cgYXJlIHlvdT8KCjAwOjAwOjAxLjUwMCAtLT4gMDA6MDA6MDIuOTk5IGxpbmU6ODAlClRlbGwgbWUsIGlzIHRoZSA8dT5sb3JkIG9mIHRoZSB1bml2ZXJzZTwvdT4gaW4/CgowMDowMDowMy4wMDAgLS0+IDAwOjAwOjA0LjI5OSBsaW5lOjgwJQpZZXMsIGhlJ3MgaW4gLSBpbiBhIGJhZCBodW1vcgoKMDA6MDA6MDQuMzAwIC0tPiAwMDowMDowNi4wMDAgbGluZTo4MCUKU29tZWJvZHkgbXVzdCd2ZSBzdG9sZW4gdGhlIGNyb3duIGpld2Vscwo="

  def sections do
    [
      %{id: "basic", title: "How to use"},
      %{id: "subtitle", title: "Add subtitle"},
      %{id: "thumbnail", title: "Thumbnail"},
      %{id: "width", title: "Width"},
      %{id: "height", title: "Height"},
      %{id: "rounded", title: "Rounded"},
      %{id: "caption-background", title: "Caption background"},
      %{id: "ratio", title: "Ratio"}
    ]
  end

  def example(%{section: "basic"} = assigns) do
    assigns = assign(assigns, src: @sample_src)

    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.video id="ex-video-basic" controls>
        <:source src={@src} type="video/mp4" />
      </.video>
    </div>
    """
  end

  def example(%{section: "subtitle"} = assigns) do
    assigns = assign(assigns, src: @sample_src, vtt: @vtt_src)

    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.video id="ex-video-subtitle" controls>
        <:source src={@src} type="video/mp4" />
        <:track label="English" kind="captions" srclang="en" src={@vtt} default />
      </.video>
    </div>
    """
  end

  def example(%{section: "thumbnail"} = assigns) do
    assigns = assign(assigns, src: @sample_src, poster: @poster_src)

    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.video id="ex-video-thumbnail" controls thumbnail={@poster}>
        <:source src={@src} type="video/mp4" />
      </.video>
    </div>
    """
  end

  def example(%{section: "width"} = assigns) do
    assigns = assign(assigns, src: @sample_src)

    ~H"""
    <div class="flex flex-col items-start gap-4">
      <.video id="ex-video-width" controls width="extra_large">
        <:source src={@src} type="video/mp4" />
      </.video>
    </div>
    """
  end

  def example(%{section: "height"} = assigns) do
    assigns = assign(assigns, src: @sample_src)

    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.video id="ex-video-height" controls height="medium">
        <:source src={@src} type="video/mp4" />
      </.video>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    assigns = assign(assigns, src: @sample_src)

    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.video id="ex-video-rounded" controls rounded="medium">
        <:source src={@src} type="video/mp4" />
      </.video>
    </div>
    """
  end

  def example(%{section: "caption-background"} = assigns) do
    assigns = assign(assigns, src: @sample_src, vtt: @vtt_src)

    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.video id="ex-video-caption-bg" controls caption_background="danger">
        <:source src={@src} type="video/mp4" />
        <:track label="English" kind="captions" srclang="en" src={@vtt} default />
      </.video>
    </div>
    """
  end

  def example(%{section: "ratio"} = assigns) do
    assigns = assign(assigns, src: @sample_src, vtt: @vtt_src)

    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.video id="ex-video-ratio" controls ratio="square">
        <:source src={@src} type="video/mp4" />
        <:track label="English" kind="captions" srclang="en" src={@vtt} default />
      </.video>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
