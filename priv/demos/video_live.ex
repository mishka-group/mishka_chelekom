defmodule MishkaWeb.ChelekomLive.Docs.VideoLive do
  use MishkaWeb, :live_view

  import MishkaWeb.Components.{
    CustomNav,
    CustomInfo,
    CustomTableContent,
    CustomTable,
    CustomSearch,
    CustomTypography,
    CustomCodeWrapper,
    CustomCliProps,
    CustomInlineCode,
    CustomBlock
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Video - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_6: code_string(6))
      |> assign(code_7: code_string(7))
      |> assign(code_8: code_string(8))
      |> assign(code_9: code_string(9))
      |> assign(code_10: code_string(10))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.video controls>
      <:source src="/path" type="video/webm" />
      <:source src="/path" type="video/mp4" />
    </.video>
    """
  end

  defp code_string(2) do
    """
    <.video controls>
      <:source src="/path" type="video/webm" />
      <:source src="/path" type="video/mp4" />
      <:track kind="captions" srclang="en" src="/path" default />
    </.video>
    """
  end

  defp code_string(3) do
    """
    <.video thumbnail="/path" controls>
      <:source src="/path" type="video/webm" />
      <:source src="/path" type="video/mp4" />
    </.video>
    """
  end

  defp code_string(4) do
    """
    <.video width="extra_small" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video width="small" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video width="medium" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video width="large" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video width="extra_large" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video width="full" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    """
  end

  defp code_string(5) do
    """
    <.video height="extra_small" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video height="small" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video height="medium" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video height="large" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video height="extra_large" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    """
  end

  defp code_string(6) do
    """
    <.video rounded="extra_small" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video rounded="small" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video rounded="medium" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video rounded="large" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    <.video rounded="extra_large" controls>
      <:source src="/path" type="video/mp4" />
    </.video>

    """
  end

  defp code_string(7) do
    """
    <.video thumbnail="/path" caption_background="extra_small">
      <:source src="/path" type="video/mp4" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="small">
      <:source src="/path" type="video/mp4" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="medium">
      <:source src="/path" type="video/mp4" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="large">
      <:source src="/path" type="video/mp4" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="extra_large">
      <:source src="/path" type="video/mp4" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="double_large">
      <:source src="/path" type="video/mp4" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="triple_large">
      <:source src="/path" type="video/mp4" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="quadruple_large">
      <:source src="/path" type="video/mp4" />
      <:track kind="captions" src="/path" default />
    </.video>

    """
  end

  defp code_string(8) do
    """
    <.video thumbnail="/path" caption_background="white">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="primary">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="secondary">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="dark">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="success">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="warning">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="danger">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="info">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="silver">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="misc">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="dawn">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_background="silver">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    """
  end

  defp code_string(9) do
    """
    <.video thumbnail="/path" caption_opacity="transparent">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_opacity="translucent">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_opacity="semi_transparent">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_opacity="lightly_tinted">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_opacity="tinted">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_opacity="semi_opaque">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_opacity="opaque">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_opacity="heavily_tinted">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_opacity="almost_solid">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" caption_opacity="solid">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    """
  end

  defp code_string(10) do
    """
    <.video thumbnail="/path" ratio="auto">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" ratio="square">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" ratio="video">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" ratio="4:3">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" ratio="3:2">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    <.video thumbnail="/path" ratio="21:9">
      <:source src="/path" type="video/webm" />
      <:track kind="captions" src="/path" default />
    </.video>

    """
  end

  defp component_config() do
    [
      name: "video",
      args: [
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        only: ["video"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/video"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive video playback for Phoenix and Phoenix LiveView, supporting multiple sources, subtitles, and thumbnails.",
      keywords:
        "phoenix video component, video component, liveview video component, elixir, liveview, mishka chelekom video component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Video - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Video - Chelekom Phoenix & LiveView component",
      og_title: "Video - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive video playback for Phoenix and Phoenix LiveView, supporting multiple sources, subtitles, and thumbnails.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Video - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive video playback for Phoenix and Phoenix LiveView, supporting multiple sources, subtitles, and thumbnails."
    }
  end
end
