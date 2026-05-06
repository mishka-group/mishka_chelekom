defmodule MishkaWeb.ChelekomLive.Docs.TypographyLive do
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
      |> assign(page_title: "Typography - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.h1>Heading Level 1</.h1>
    <.h2>Heading Level 2</.h2>
    <.h3>Heading Level 3</.h3>
    <.h4>Heading Level 4</.h4>
    <.h5>Heading Level 5</.h5>
    <.h6>Heading Level 6</.h6>
    <.p>Paragraph</.p>
    <.strong>Strong text</.strong>
    <.em>Emphasized text</.em>
    <.dl>Description list</.dl>
    <.dt>Definition term</.dt>
    <.dd>Definition description</.dd>
    <.abbr>Abbreviation</.abbr>
    <.figure>Figure</.figure>
    <.figcaption>Figure caption</.figcaption>
    <.mark>Highlighted text</.mark>
    <.small>Small text</.small>
    <.s>Strikethrough text</.s>
    <.u>Underlined text</.u>
    <.cite>Citation</.cite>
    <.del>Deleted text</.del>
    """
  end

  defp code_string(2) do
    """
    <.h1 color="base">Heading Level 1</.h1>
    <.h1 color="primary">Heading Level 1</.h1>
    <.h2 color="secondary">Heading Level 2</.h2>
    <.h2 color="natural">Heading Level 2</.h2>
    <.h3 color="dark">Heading Level 3</.h3>
    <.h4 color="success">Heading Level 4</.h4>
    <.h5 color="warning">Heading Level 5</.h5>
    <.h6 color="danger">Heading Level 6</.h6>
    <.p color="info">Paragraph</.p>
    <.strong color="silver">Strong text</.strong>
    <.em color="misc">Emphasized text</.em>
    <.dl color="dawn">Description list</.dl>
    <.dt color="inherit">Definition term</.dt>
    <.dd color="primary">Definition description</.dd>
    <.abbr color="secondary">Abbreviation</.abbr>
    """
  end

  defp code_string(3) do
    """
    <.p size="extra_small">Extra Small Paragraph</.p>
    <.p size="small">Small Paragraph</.p>
    <.p size="medium">Medium Paragraph</.p>
    <.p size="large">Large Paragraph</.p>
    <.p size="extra_large">Extra Large Paragraph</.p>
    <.p size="double_large">Double Large Paragraph</.p>
    <.p size="triple_large">Triple Large Paragraph</.p>
    <.p size="quadruple_large">Quadruple Large Paragraph</.p>
    """
  end

  defp code_string(4) do
    """
    <.p font_weight="font-bold">Extra Small Paragraph</.p>
    <.p font_weight="font-light">Small Paragraph</.p>
    <.p font_weight="font-black">Medium Paragraph</.p>
    """
  end

  defp component_config() do
    [
      name: "typography",
      args: [
        color: [
          "base",
          "primary",
          "white",
          "natural",
          "secondary",
          "dark",
          "success",
          "warning",
          "danger",
          "info",
          "silver",
          "misc",
          "dawn",
          "inherit"
        ],
        size: [
          "extra_small",
          "small",
          "medium",
          "large",
          "extra_large",
          "double_large",
          "triple_large",
          "quadruple_large"
        ],
        type: [
          "h1",
          "h2",
          "h3",
          "h4",
          "h5",
          "h6",
          "p",
          "strong",
          "em",
          "dl",
          "dt",
          "dd",
          "figure",
          "figcaption",
          "abbr",
          "mark",
          "small",
          "s",
          "u",
          "cite",
          "del"
        ],
        only: [
          "h1",
          "h2",
          "h3",
          "h4",
          "h5",
          "h6",
          "p",
          "strong",
          "em",
          "dl",
          "dt",
          "dd",
          "figure",
          "figcaption",
          "abbr",
          "mark",
          "small",
          "s",
          "u",
          "cite",
          "del"
        ],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/typography"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Typography component for Phoenix LiveView, offering customizable text elements and styles to enhance readability and user engagement.",
      keywords:
        "phoenix typography component, typography component, liveview typography component, elixir, liveview, mishka chelekom typography component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Typography - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Typography - Chelekom Phoenix & LiveView component",
      og_title: "Typography - Chelekom Phoenix & LiveView component",
      og_description:
        "Typography component for Phoenix LiveView, offering customizable text elements and styles to enhance readability and user engagement.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Typography - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Typography component for Phoenix LiveView, offering customizable text elements and styles to enhance readability and user engagement."
    }
  end
end
