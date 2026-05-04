defmodule MishkaWeb.ChelekomLive.Docs.GalleryLive do
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
      |> assign(page_title: "Gallery - Chelekom Phoenix & LiveView component")
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
      |> assign(code_11: code_string(11))
      |> assign(code_12: code_string(12))
      |> assign(code_13: code_string(13))
      |> assign(code_14: code_string(14))
      |> assign(code_15: code_string(15))
      |> assign(code_16: code_string(16))
      |> assign(code_17: code_string(17))
      |> assign(code_18: code_string(18))
      |> assign(code_19: code_string(19))
      |> assign(code_20: code_string(20))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.gallery>
      <.gallery_media src="/path" alt="Mishka chelekom" />
      <.gallery_media src="/path" alt="Mishka chelekom" />
      <.gallery_media src="/path" alt="Mishka chelekom" />
    </.gallery>
    """
  end

  defp code_string(2) do
    """
    <.gallery>
      <.gallery_media shadow="extra_small" src="/path" />
      <.gallery_media shadow="small" src="/path" />
      <.gallery_media shadow="medium" src="/path" />
      <.gallery_media shadow="large" src="/path" />
      <.gallery_media shadow="extra_large" src="/path" />
    </.gallery>
    """
  end

  defp code_string(3) do
    """
    <.gallery>
      <.gallery_media rounded="extra_small" src="/path" />
      <.gallery_media rounded="small" src="/path" />
      <.gallery_media rounded="medium" src="/path" />
      <.gallery_media rounded="large" src="/path" />
      <.gallery_media rounded="extra_large" src="/path" />
    </.gallery>
    """
  end

  defp code_string(4) do
    """
     <.gallery>
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
    </.gallery>
    """
  end

  defp code_string(5) do
    """
    <.gallery type="masonry" cols="four">
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
      <.gallery_media src="/path" />
    </.gallery>
    """
  end

  defp code_string(6) do
    """
    <.gallery>
      <.gallery_media src="/path" />
      <.gallery cols="three">
        <.gallery_media src="/path" />
        <.gallery_media src="/path" />
        <.gallery_media src="/path" />
        <.gallery_media src="/path" />
        <.gallery_media src="/path" />
        <.gallery_media src="/path" />
        <.gallery_media src="/path" />
      </.gallery>
    </.gallery>
    """
  end

  defp code_string(7) do
    """
    <.gallery cols="one"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="two"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="three"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="four"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="five"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="six"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="seven"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="eight"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="nine"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="ten"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="eleven"><.gallery_media src="/path" /></.gallery>
    <.gallery cols="twelve"><.gallery_media src="/path" /></.gallery>
    """
  end

  defp code_string(8) do
    """
    <.gallery gap="extra_small"><.gallery_media src="/path" /></.gallery>
    <.gallery gap="small"><.gallery_media src="/path" /></.gallery>
    <.gallery gap="medium"><.gallery_media src="/path" /></.gallery>
    <.gallery gap="large"><.gallery_media src="/path" /></.gallery>
    <.gallery gap="extra_large"><.gallery_media src="/path" /></.gallery>
    <.gallery gap="double_large"><.gallery_media src="/path" /></.gallery>
    <.gallery gap="triple_large"><.gallery_media src="/path" /></.gallery>
    <.gallery gap="quadruple_large"><.gallery_media src="/path" /></.gallery>
    """
  end

  defp code_string(9) do
    """
    <.gallery animation="backdrop" animation_size="extra_small">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="backdrop" animation_size="small">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="backdrop" animation_size="medium">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="backdrop" animation_size="large">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="backdrop" animation_size="extra_large">
      <.gallery_media src="/path" />
    </.gallery>
    """
  end

  defp code_string(10) do
    """
    <.gallery animation="blur" animation_size="extra_small">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="blur" animation_size="small">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="blur" animation_size="medium">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="blur" animation_size="large">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="blur" animation_size="extra_large">
      <.gallery_media src="/path" />
    </.gallery>
    """
  end

  defp code_string(11) do
    """
    <.gallery animation="scale-up" animation_size="extra_small">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="scale-up" animation_size="small">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="scale-up" animation_size="medium">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="scale-up" animation_size="large">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="scale-up" animation_size="extra_large">
      <.gallery_media src="/path" />
    </.gallery>
    """
  end

  defp code_string(12) do
    """
    <.gallery animation="scale-down" animation_size="extra_small">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="scale-down" animation_size="small">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="scale-down" animation_size="medium">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="scale-down" animation_size="large">
      <.gallery_media src="/path" />
    </.gallery>

    <.gallery animation="scale-down" animation_size="extra_large">
      <.gallery_media src="/path" />
    </.gallery>
    """
  end

  defp code_string(13) do
    """
    <.filterable_gallery
      filters={["all", "Sky", "Sea"]}
      media={[
        %{src: "/path", alt: "", category: "Sea"},
        %{src: "/apth", alt: "", category: "Sky"},
        %{src: "/path", alt: "", category: "Sky"}
      ]}
    />
    """
  end

  defp code_string(14) do
    """
    <.filterable_gallery
      filters={["all", "Skies", "Ocean"]}
      media={[
        %{src: "/path", alt: "", category: "Skies"},
        %{src: "/path", alt: "", category: "Skies"},
        %{src: "/path", alt: "", category: "Ocean"}
      ]}
      >
      <:filter :let={filter}>
        <.button data-gallery-filter data-category={filter}>
          <%= filter %>
        </.button>
      </:filter>

      <:media_block :let={media}>
        <.gallery_media src={media.src} alt={media.alt} />
      </:media_block>
    </.filterable_gallery>
    """
  end

  defp code_string(15) do
    """
    <.filterable_gallery
      filters={["all", "Skies", "Ocean"]}
      media={[
        %{src: "/path", alt: "", category: "Skies"},
        %{src: "/path", alt: "", category: "Skies"},
        %{src: "/path", alt: "", category: "Ocean"}
      ]}
      >
      <:filter :let={filter}>
        <.button data-gallery-filter data-category={filter}>
          <%= filter %>
        </.button>
      </:filter>
    </.filterable_gallery>
    """
  end

  defp code_string(16) do
    """
    <.filterable_gallery gap="small" cols="four"></.filterable_gallery>
    """
  end

  defp code_string(17) do
    """
    <.filterable_gallery
      media={[
        %{src: "/path", alt: "", category: "Skies"},
        %{src: "/path", alt: "", category: "Skies"},
        %{src: "/path", alt: "", category: "Ocean"}
      ]}
      >
    </.filterable_gallery>
    """
  end

  defp code_string(18) do
    """
    <.filterable_gallery filters={["all", "Skies", "Ocean"]}></.filterable_gallery>
    """
  end

  defp code_string(19) do
    """
    <.filterable_gallery default_filter="All Images"></.filterable_gallery>
    """
  end

  defp code_string(20) do
    """
    <.filterable_gallery
      filters={["Skies", "Ocean"]}
      media={[
        %{src: "/path", alt: "", category: ["Skies", "Ocean"]},
        %{src: "/path", alt: "", category: "Skies"},
        %{src: "/path", alt: "", category: ""}
      ]}
      >
    </.filterable_gallery>
    """
  end

  defp component_config() do
    [
      name: "gallery",
      args: [
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        type: ["gallery", "gallery_media", "filterable_gallery"],
        only: ["gallery", "gallery_media", "filterable_gallery"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/gallery"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Customizable Phoenix LiveView gallery component for displaying images in different layouts, including default, masonry, and featured styles.",
      keywords:
        "phoenix gallery component, gallery component, liveview gallery component, elixir, liveview, mishka chelekom gallery component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Gallery - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Gallery - Chelekom Phoenix & LiveView component",
      og_title: "Gallery - Chelekom Phoenix & LiveView component",
      og_description:
        "Customizable Phoenix LiveView gallery component for displaying images in different layouts, including default, masonry, and featured styles.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Gallery - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Customizable Phoenix LiveView gallery component for displaying images in different layouts, including default, masonry, and featured styles."
    }
  end
end
