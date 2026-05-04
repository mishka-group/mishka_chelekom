defmodule MishkaWeb.ChelekomLive.Docs.StatLive do
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
    CustomInlineCode
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Stat - Chelekom Phoenix & LiveView component")
     |> assign(seo_tags: seo_tags())
     |> assign(code_basic: code(:basic))
     |> assign(code_figure: code(:figure))
     |> assign(code_trend: code(:trend))
     |> assign(code_actions: code(:actions))
     |> assign(code_variants: code(:variants))
     |> assign(code_sizes: code(:sizes))
     |> assign(code_group: code(:group))
     |> assign(code_orientation: code(:orientation))
     |> assign(code_responsive: code(:responsive))
     |> assign(code_dashboard: code(:dashboard))}
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp code(:basic) do
    """
    <.stat title="Total revenue" value="$45,231.89" description="Last 30 days" />
    """
  end

  defp code(:figure) do
    """
    <.stat title="Total likes" value="25.6K" description="From all platforms" color="primary">
      <:figure>
        <.icon name="hero-heart" />
      </:figure>
    </.stat>
    """
  end

  defp code(:trend) do
    """
    <.stat title="MRR" value="$12,400" description="20.1% from last month" trend="up" />
    <.stat title="Churn" value="3.2%" description="0.4% from last month" trend="down" />
    <.stat title="ARPU" value="$84" description="Flat vs last month" trend="neutral" />
    """
  end

  defp code(:actions) do
    """
    <.stat title="Account balance" value="$89,400">
      <:actions>
        <.button color="success" size="small">Add funds</.button>
      </:actions>
    </.stat>
    """
  end

  defp code(:variants) do
    """
    <.stat variant="default" color="primary" title="Visits" value="42K" description="This week" />
    <.stat variant="shadow" color="success" title="Sales" value="$2.3K" description="Up 12%" />
    <.stat variant="bordered" color="info" title="Signups" value="1,204" description="Today" />
    <.stat variant="gradient" color="misc" title="Revenue" value="$98K" description="MTD" />
    <.stat variant="base" title="Latency" value="248ms" description="p95" />
    """
  end

  defp code(:sizes) do
    """
    <.stat size="extra_small" title="XS" value="42" />
    <.stat size="small" title="SM" value="42" />
    <.stat size="medium" title="MD" value="42" />
    <.stat size="large" title="LG" value="42" />
    <.stat size="extra_large" title="XL" value="42" />
    """
  end

  defp code(:group) do
    """
    <.stat_group>
      <.stat title="Downloads" value="31K" description="Last 30 days" />
      <.stat title="New users" value="4,200" description="+12% MoM" trend="up" />
      <.stat title="New posts" value="1,200" description="-3% MoM" trend="down" />
    </.stat_group>
    """
  end

  defp code(:orientation) do
    """
    <.stat_group orientation="horizontal">...</.stat_group>
    <.stat_group orientation="vertical">...</.stat_group>
    <.stat_group orientation="responsive">...</.stat_group>
    """
  end

  defp code(:responsive) do
    """
    <.stat_group orientation="responsive" variant="bordered" color="primary">
      <.stat title="Total" value="89.4K" />
      <.stat title="Avg time" value="4m 32s" />
      <.stat title="Bounce" value="38%" />
    </.stat_group>
    """
  end

  defp code(:dashboard) do
    """
    <.stat_group variant="base">
      <.stat title="Revenue" value="$89,400" description="20.1% from last month" trend="up" color="success">
        <:figure><.icon name="hero-currency-dollar" /></:figure>
      </.stat>
      <.stat title="Subscriptions" value="2,340" description="180 from last month" trend="up" color="primary">
        <:figure><.icon name="hero-user-group" /></:figure>
      </.stat>
      <.stat title="Active now" value="573" description="201 since last hour" trend="up" color="info">
        <:figure><.icon name="hero-bolt" /></:figure>
      </.stat>
    </.stat_group>
    """
  end

  defp component_config() do
    [
      name: "stat",
      args: [
        variant: ["default", "shadow", "bordered", "gradient", "base"],
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
          "silver",
          "misc",
          "dawn"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: ["none", "extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["none", "extra_small", "small", "medium", "large", "extra_large", "full"],
        only: ["stat"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: ["icon"]
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/stat"
    page_image_url = MishkaWeb.Endpoint.url() <> "/images/docs/chelekom/stat.png"

    %{
      description:
        "Metric / KPI block component for Phoenix LiveView dashboards with full Chelekom design-system tokens, trend indicators, and grouped layouts.",
      keywords:
        "phoenix stat component, kpi component, metric component, liveview stat, mishka chelekom stat",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Stat - Chelekom",
      twitter_image_alt: "Stat - Chelekom",
      og_title: "Stat - Chelekom Phoenix & LiveView component",
      og_description:
        "Metric / KPI blocks with trend indicators, full chelekom palette, and grouped layouts.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Stat - Chelekom",
      twitter_description:
        "Metric / KPI blocks with trend indicators, full chelekom palette, and grouped layouts."
    }
  end
end
