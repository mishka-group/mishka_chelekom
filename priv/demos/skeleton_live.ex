defmodule MishkaWeb.ChelekomLive.Docs.SkeletonLive do
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
      |> assign(page_title: "Skeleton - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_6: code_string(6))
      |> assign(code_7: code_string(7))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.skeleton color="base" />
    <.skeleton color="white" />
    <.skeleton color="primary" />
    <.skeleton color="silver" />
    <.skeleton color="secondary" />
    <.skeleton color="dark" />
    <.skeleton color="success" />
    <.skeleton color="warning" />
    <.skeleton color="danger" />
    <.skeleton color="natural" />
    <.skeleton color="misc" />
    <.skeleton color="info" />
    <.skeleton color="dawn" />
    """
  end

  defp code_string(2) do
    """
    <.skeleton animated />
    """
  end

  defp code_string(3) do
    """
    <.skeleton visible />
    <.skeleton visible={false} />
    """
  end

  defp code_string(4) do
    """
    <.skeleton height="extra_small" />
    <.skeleton height="small" />
    <.skeleton height="medium" />
    <.skeleton height="large" />
    <.skeleton height="extra_large" />
    <.skeleton height="h-[0.54rem]" />
    <.skeleton height="h-[2.5px]" />
    """
  end

  defp code_string(5) do
    """
    <.skeleton width="extra_small" />
    <.skeleton width="small" />
    <.skeleton width="medium" />
    <.skeleton width="large" />
    <.skeleton width="extra_large" />
    <.skeleton width="full" />
    <.skeleton width="w-[201px]" />
    <.skeleton width="w-[5.6rem]" />
    """
  end

  defp code_string(6) do
    """
    <.skeleton width="extra_small" />
    <.skeleton width="small" />
    <.skeleton width="medium" />
    <.skeleton width="large" />
    <.skeleton width="extra_large" />
    <.skeleton width="full" />
    <.skeleton width="none" />
    """
  end

  defp code_string(7) do
    """
    <div class="flex items-center gap-3 p-3 rounded-lg bg-indigo-800">
      <.skeleton width="w-14" height="h-14" color="silver" class="shrink-0" rounded="full" animated/>
      <div class="space-y-2 flex-1">
        <.skeleton height="small" color="silver" animated />
        <.skeleton height="small" width="w-32 md:w-96" color="silver" animated />
        <.skeleton height="small" width="w-28 md:w-80" color="silver" animated />
        <.skeleton height="small" width="w-24 md:w-72" color="silver" animated />
      </div>
    </div>
    """
  end

  defp component_config() do
    [
      name: "skeleton",
      args: [
        color: [
          "base",
          "natural",
          "white",
          "primary",
          "secondary",
          "dark",
          "success",
          "warning",
          "danger",
          "info",
          "misc",
          "dawn",
          "silver"
        ],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
        only: ["skeleton"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/skeleton"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description: "",
      keywords:
        "phoenix skeleton component, skeleton component, liveview skeleton component, elixir, liveview, mishka chelekom skeleton component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Skeleton - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Skeleton - Chelekom Phoenix & LiveView component",
      og_title: "Skeleton - Chelekom Phoenix & LiveView component",
      og_description:
        "Skeleton component for Phoenix LiveView, offering visual placeholders to indicate loading content with options for size, color, and animations.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Skeleton - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Skeleton component for Phoenix LiveView, offering visual placeholders to indicate loading content with options for size, color, and animations."
    }
  end
end
