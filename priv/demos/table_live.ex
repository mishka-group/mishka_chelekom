defmodule MishkaWeb.ChelekomLive.Docs.TableLive do
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
      |> assign(page_title: "Table - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.table color="natural" variant="outline"></.table>
    <.table color="primary" variant="default"></.table>
    <.table color="secondary" variant="shadow"></.table>
    <.table color="dark" variant="stripped"></.table>
    <.table color="success" variant="transparent"></.table>
    <.table color="warning" variant="hoverable"></.table>
    <.table color="danger" variant="stripped"></.table>
    <.table color="info" variant="outline"></.table>
    <.table color="silver" variant="default"></.table>
    <.table color="misc" variant="shadow"></.table>
    <.table color="dawn" variant="bordered"></.table>
    <.table color="silver" variant="transparent"></.table>
    <.table color="misc" variant="separated"></.table>
    <!--Base-->
    <.table></.table>
    """
  end

  defp code_string(2) do
    """
    <.table rounded="extra_small"></.table>
    <.table rounded="small"></.table>
    <.table rounded="medium"></.table>
    <.table rounded="large"></.table>
    <.table rounded="extra_large"></.table>
    """
  end

  defp code_string(3) do
    """
    <.table border="extra_small"></.table>
    <.table border="small"></.table>
    <.table border="medium"></.table>
    <.table border="large"></.table>
    <.table border="extra_large"></.table>
    """
  end

  defp code_string(4) do
    """
    <.table padding="extra_small"></.table>
    <.table padding="small"></.table>
    <.table padding="medium"></.table>
    <.table padding="large"></.table>
    <.table padding="extra_large"></.table>
    """
  end

  defp code_string(5) do
    """
    <.table text_size="extra_small"></.table>
    <.table text_size="small"></.table>
    <.table text_size="medium"></.table>
    <.table text_size="large"></.table>
    <.table text_size="extra_large"></.table>
    """
  end

  defp code_string(6) do
    """
    <.table text_position="left"></.table>
    <.table text_position="right"></.table>
    <.table text_position="center"></.table>
    <.table text_position="justify"></.table>
    <.table text_position="start"></.table>
    <.table text_position="end"></.table>
    """
  end

  defp code_string(7) do
    """
    <.table header_border="extra_small"></.table>
    <.table header_border="small"></.table>
    <.table header_border="medium"></.table>
    <.table header_border="large"></.table>
    <.table header_border="extra_large"></.table>
    """
  end

  defp code_string(8) do
    """
    <.table rows_border="extra_small"></.table>
    <.table rows_border="small"></.table>
    <.table rows_border="medium"></.table>
    <.table rows_border="large"></.table>
    <.table rows_border="extra_large"></.table>
    """
  end

  defp code_string(9) do
    """
    <.table cols_border="extra_small"></.table>
    <.table cols_border="small"></.table>
    <.table cols_border="medium"></.table>
    <.table cols_border="large"></.table>
    <.table cols_border="extra_large"></.table>
    """
  end

  defp code_string(10) do
    """
    <.table>
      <:header class="your_heading_classes">Name</:header>

      <:header class="your_heading_classes">Age</:header>

      <:header class="your_heading_classes">Address</:header>

      <:header class="your_heading_classes">Action</:header>
    </.table>
    """
  end

  defp code_string(11) do
    """
    <.table>
      <:header class="your_heading_classes">Name</:header>

      <:header class="your_heading_classes">Age</:header>

      <:header class="your_heading_classes">Address</:header>

      <:header icon="hero-pencil-square" icon_class="size-5"></:header>
    </.table>
    """
  end

  defp code_string(12) do
    """
    <.table>
      <:footer class="your_heading_classes">Name</:footer>

      <:footer class="your_heading_classes">Age</:footer>

      <:footer class="your_heading_classes">Address</:footer>
    </.table>
    """
  end

  defp code_string(13) do
    """
    <.table>
      <:footer class="your_heading_classes">Name</:footer>

      <:footer class="your_heading_classes">Age</:footer>

      <:footer class="your_heading_classes">Address</:footer>

      <:footer icon="hero-pencil-square" icon_class="size-5"></:footer>
    </.table>
    """
  end

  defp code_string(14) do
    """
    <.table
      header_border="extra_small"
      rows_border="extra_small"
      cols_border="extra_small"
    >
      <:header>Name</:header>
      <:header>Age</:header>
      <:header>Address</:header>
      <:header>Edit</:header>

      <.tr>
        <.td>Alice Johnson</.td>
        <.td>34</.td>
        <.td>No. 5 Broadway, New York, NY 10004, United States</.td>
        <.td><button>Edit</button></.td>
      </.tr>

      <.tr>
        <.td>Michael Scott</.td>
        <.td>45</.td>
        <.td>Scranton, No. 2 Paper Road</.td>
        <.td><button>Edit</button></.td>
      </.tr>

      <.tr>
        <.td>Emily Carter</.td>
        <.td>29</.td>
        <.td>San Francisco, No. 10 Bay Street</.td>
        <.td><button>Edit</button></.td>
      </.tr>
    </.table>
    """
  end

  defp code_string(15) do
    """
    <.table
      header_border="extra_small"
      rows_border="extra_small"
      cols_border="extra_small"
    >
      <:header>Name</:header>
      <:header>Age</:header>
      <:header>Address</:header>
      <:header>Edit</:header>

      <.tr>
        <.td>Alice Johnson</.td>
        <.td>34</.td>
        <.td>No. 5 Broadway, New York, NY 10004, United States</.td>
        <.td><button>Edit</button></.td>
      </.tr>

      <.tr>
        <.td>Michael Scott</.td>
        <.td>45</.td>
        <.td>Scranton, No. 2 Paper Road</.td>
        <.td><button>Edit</button></.td>
      </.tr>

      <.tr>
        <.td>Emily Carter</.td>
        <.td>29</.td>
        <.td>San Francisco, No. 10 Bay Street</.td>
        <.td><button>Edit</button></.td>
      </.tr>
    </.table>

    <.pagination
      total={@posts.total}
      active={@posts.active}
      siblings={1}
      color="dark"
      variant="default"
      size="small"
      class="mt-10"
    />
    """
  end

  defp code_string(16) do
    """
    <.table variant="separated" space="extra_small"></.table>
    <.table variant="separated" space="small"></.table>
    <.table variant="separated" space="medium"></.table>
    <.table variant="separated" space="large"></.table>
    <.table variant="separated" space="extra_large" rounded="large"></.table>
    """
  end

  defp code_string(17) do
    """
    <.table table_fixed></.table>
    """
  end

  defp component_config() do
    [
      name: "table",
      args: [
        variant: [
          "base",
          "outline",
          "default",
          "shadow",
          "bordered",
          "transparent",
          "hoverable",
          "stripped",
          "separated"
        ],
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
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        padding: ["extra_small", "small", "medium", "large", "extra_large"],
        type: ["table", "th", "tr", "td"],
        only: ["table", "th", "tr", "td"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/table"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Table component for Phoenix LiveView with support for styling, borders, text alignment, padding, and dynamic headers, footers, and cells.",
      keywords:
        "phoenix table component, table component, liveview table component, elixir, liveview, mishka chelekom table component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Table - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Table - Chelekom Phoenix & LiveView component",
      og_title: "Table - Chelekom Phoenix & LiveView component",
      og_description:
        "Table component for Phoenix LiveView with support for styling, borders, text alignment, padding, and dynamic headers, footers, and cells.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Table - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Table component for Phoenix LiveView with support for styling, borders, text alignment, padding, and dynamic headers, footers, and cells."
    }
  end
end
