defmodule MishkaWeb.ChelekomLive.Docs.AvatarLive do
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
      |> assign(page_title: "Avatar - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_12: code_string(12))
      |> assign(code_13: code_string(13))
      |> assign(code_14: code_string(14))
      |> assign(code_15: code_string(15))
      |> assign(code_16: code_string(16))
      |> assign(code_17: code_string(17))
      |> assign(code_18: code_string(18))
      |> assign(code_19: code_string(19))
      |> assign(code_20: code_string(20))
      |> assign(code_21: code_string(21))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.avatar color="base"><:icon name="hero-star" /></.avatar>

    <.avatar color="natural"><:icon name="hero-star" /></.avatar>

    <.avatar border="extra_small" src="/path/to/iamge" />

    <.avatar color="natural">SB</.avatar>
    <.avatar color="white">SB</.avatar>
    <.avatar color="dark">SB</.avatar>
    <.avatar color="primary">SB</.avatar>
    <.avatar color="secondary">SB</.avatar>
    <.avatar color="warning">SB</.avatar>
    <.avatar color="misc">SB</.avatar>
    <.avatar color="dawn">SB</.avatar>
    <.avatar color="success">SB</.avatar>
    <.avatar color="danger">SB</.avatar>
    <.avatar color="info">SB</.avatar>
    <.avatar color="silver">SB</.avatar>
    """
  end

  defp code_string(12) do
    """
    <.avatar alt="alt text of image" color="dawn" src="/path/to/image" />
    """
  end

  defp code_string(13) do
    """
    <.avatar>
      <:icon name="hero-star" />
    </.avatar>
    """
  end

  defp code_string(14) do
    """
    <.avatar>
      IN
    </.avatar>
    """
  end

  defp code_string(15) do
    """
    <.avatar size="extra_small" color="silver">
      TG
    </.avatar>

    <.avatar size="small" src="path/to/image" />

    <.avatar size="medium" src="path/to/image" />

    <.avatar size="large">
      <:icon name="hero-users" color="dawn" />
    </.avatar>

    <.avatar size="extra_large">
      <:icon name="hero-star" color="misc" />
    </.avatar>
    """
  end

  defp code_string(16) do
    """
    <.avatar border="extra_small">
      TG
    </.avatar>

    <.avatar border="small" src="path/to/image" />

    <.avatar border="medium" >
      JJ
    </.avatar>

    <.avatar border="large">
      <:icon name="hero-photo" />
    </.avatar>

    <.avatar border="extra_large">
      <:icon name="hero-heart" />
    </.avatar>
    """
  end

  defp code_string(17) do
    """
    <.avatar rounded="extra_small">
      TG
    </.avatar>

    <.avatar rounded="small" src="path/to/image" />

    <.avatar rounded="medium" >
      JJ
    </.avatar>

    <.avatar rounded="large">
      <:icon name="hero-photo" />
    </.avatar>

    <.avatar rounded="extra_large">
      <:icon name="hero-heart" />
    </.avatar>
    """
  end

  defp code_string(18) do
    """
    <.avatar shadow="extra_small">
      TG
    </.avatar>

    <.avatar shadow="small" src="path/to/image" />

    <.avatar shadow="medium" >
      JJ
    </.avatar>

    <.avatar shadow="large">
      <:icon name="hero-photo" />
    </.avatar>

    <.avatar shadow="extra_large">
      <:icon name="hero-heart" />
    </.avatar>
    """
  end

  defp code_string(19) do
    """
    <.avatar>
      <:icon name="hero-users" />
      <.indicator size="small" color="danger" top_left />
    </.avatar>

    <.avatar>
      TG
      <.indicator size="small" color="misc" bottom_left />
    </.avatar>

    <.avatar src="/path/to/image">
      <:icon name="hero-heart" />
      <.indicator size="small" color="success" top_right pinging />
    </.avatar>
    """
  end

  defp code_string(20) do
    """
    <.avatar_group>
      <.avatar
        src="/path/to/image"
        size="large"
        border="extra_small"
        color="misc"
        rounded="full"
      />
      <.avatar
        src="/path/to/image"
        size="large"
        border="extra_small"
        color="misc"
        rounded="full"
      />
      <.avatar
        src="/path/to/image"
        size="large"
        border="extra_small"
        color="misc"
        rounded="full"
      />
      <.avatar
        src="/path/to/image"
        size="large"
        border="extra_small"
        color="misc"
        rounded="full"
      />
      <.avatar size="large" color="base" rounded="full" border="medium">
        +20
      </.avatar>
    </.avatar_group>
    """
  end

  defp code_string(21) do
    """
    <.avatar_group space="extra_small">
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar color="base">+20</.avatar>
    </.avatar_group>

    <.avatar_group space="small">
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar color="base">+20</.avatar>
    </.avatar_group>

    <.avatar_group space="medium">
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar color="base">+20</.avatar>
    </.avatar_group>

    <.avatar_group space="large">
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar color="base">+20</.avatar>
    </.avatar_group>

    <.avatar_group space="extra_large">
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar src="/path/to/image"/>
      <.avatar color="base">+20</.avatar>
    </.avatar_group>
    """
  end

  defp component_config() do
    [
      name: "avatar",
      args: [
        color: [
          "base",
          "natural",
          "white",
          "dark",
          "primary",
          "secondary",
          "success",
          "warning",
          "danger",
          "info",
          "silver",
          "misc",
          "dawn",
          "transparent"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
        type: ["avatar", "avatar_group"],
        only: ["avatar", "avatar_group"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/avatar"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive avatars and avatar groups for Phoenix and Phoenix LiveView, displaying profile images, initials, or fallback icons, with options to group avatars for a cohesive display.",
      keywords:
        "phoenix avatar component, avatar component, liveview avatar component, elixir, liveview, mishka chelekom avatar component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Avatar - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Avatar - Chelekom Phoenix & LiveView component",
      og_title: "Avatar - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive avatars and avatar groups for Phoenix and Phoenix LiveView, displaying profile images, initials, or fallback icons, with options to group avatars for a cohesive display.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Avatar - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive avatars and avatar groups for Phoenix and Phoenix LiveView, displaying profile images, initials, or fallback icons, with options to group avatars for a cohesive display."
    }
  end
end
