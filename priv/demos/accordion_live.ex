defmodule MishkaWeb.ChelekomLive.Docs.AccordionLive do
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
      |> assign(page_title: "Accordion - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_6: code_string(6))
      |> assign(code_7: code_string(7))
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

  def handle_event("accordion-handler", _params, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <!-- a unique id is required for each .accordion -->
    <.accordion id="example">
      <:item
        id="item1"
        title="Custom Accordion Item one"
        description="Description of slot"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="item2"
        title="Custom Accordion Item two"
        description="Description of slot"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>

    <.accordion id="example-one" initial_open={["icon1"]}>
      <:item
        id="icon1"
        title="Custom Accordion Item one"
        description="Description of slot"
        icon="hero-chat-bubble-left-right-solid"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="icon2"
        title="Custom Accordion Item two"
        description="Description of slot"
        icon="hero-chat-bubble-oval-left-ellipsis-solid"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(2) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-two" color="secondary">
      <:item
        id="sec1"
        title="Default variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="sec2"
        title="Default variant item two"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(3) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-three" variant="outline">
      <:item
        id="out1"
        title="outline variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="out2"
        title="outline variant item two"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(4) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-four" variant="bordered">
      <:item
        id="bord1"
        title="bordered variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="bord2"
        title="bordered variant item two"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(5) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-five" variant="outline_separated">
      <:item
        id="osep1"
        title="outline_separated variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="osep2"
        title="outline_separated variant item two"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(6) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-six" variant="bordered_separated">
      <:item
        id="bsep1"
        title="Bordered separated variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="bsep2"
        title="Bordered separated variant item two"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(7) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-seven" variant="transparent">
      <:item
        id="trans1"
        title="Transparent variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="trans2"
        title="Transparent variant item two"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(9) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-nine" padding="medium">
      <:item
        id="pad1"
        title="outline variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="pad2"
        title="outline variant item two"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(10) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-ten" size="large" lazy={true}>
      <:item
        id="size1"
        title="Size prop item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="size2"
        title="Size prop item two"
      >
        <!--Content goes here-->
      </:item>

      <:item
        id="size3"
        title="Size prop item three (lazy loaded)"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(11) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-11" space="large">
      <:item
        id="space1"
        title="Space prop item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="space2"
        title="Space prop item two"
      >
        <!--Content goes here-->
      </:item>

      <:item
        id="space3"
        title="Space prop item three"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(12) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-12" rounded="small">
      <:item
        id="round1"
        title="Rounded prop item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        id="round2"
        title="Rounded prop item two"
      >
        <!--Content goes here-->
      </:item>

      <:item
        id="round3"
        title="Rounded prop item three"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(13) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-13" media_size="extra_small">
      <:item
        title="Media size prop item one"
        image="/path/to/image"
      >
       <!--Content goes here-->
      </:item>

      <:item
        title="Media size prop item two"
        image="/path/to/image"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(14) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="example-14" chevron_icon="hero-cog-8-tooth">
      <:item
        id="chev1"
        title="Chevron prop item one"
      >
       <!--Content goes here-->
      </:item>
    </.accordion>

    <.accordion id="example-15" chevron_position="left">
      <:item
        id="chev2"
        title="Left chevron item one"
      >
       <!--Content goes here-->
      </:item>
    </.accordion>

    <.accordion id="example-16" collapsible={false} open={true}>
      <:item
        id="chev3"
        title="Non-collapsible item one"
      >
       <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(15) do
    """
    <!-- JavaScript-powered accordion with server events -->
    <.accordion id="server-events-accordion" server_events={true} event_handler="my-component">
      <:item
        id="item1"
        title="Server Events prop item one"
      >
       <!--Content goes here-->
      </:item>
      <:item
        id="item2"
        title="Server Events prop item two"
      >
       <!--Content goes here-->
      </:item>
      <:item
        id="item3"
        title="Server Events prop item three"
      >
       <!--Content goes here-->
      </:item>
    </.accordion>

    <!-- Multiple panels open and custom duration -->
    <.accordion id="multiple-accordion" multiple={true} duration={300}>
      <:item
        id="multi1"
        title="Multiple accordion item one"
      >
       <!--Content goes here-->
      </:item>
      <:item
        id="multi2"
        title="Multiple accordion item two"
      >
       <!--Content goes here-->
      </:item>
      <:item
        id="multi3"
        title="Multiple accordion item three"
      >
       <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(16) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="unique_id" variant="shadow">
      <:item
        title="Shadow variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        title="Shadow variant item two"
      >
        <!--Content goes here-->
      </:item>

      <:item
        title="Shadow variant item three"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(17) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="unique_id" variant="gradient">
      <:item
        title="Gradient variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        title="Gradient variant item two"
      >
        <!--Content goes here-->
      </:item>

      <:item
        title="Gradient variant item three"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(18) do
    """
    <!-- a unique id is required for each .accordion -->

    <.accordion id="unique_id" variant="base">
      <:item
        title="Tinted Split variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        title="Tinted Split variant item two"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>

    <.accordion id="unique_id" variant="base_separated">
      <:item
        title="Tinted Split variant item one"
      >
       <!--Content goes here-->
      </:item>

      <:item
        title="Tinted Split variant item two"
      >
        <!--Content goes here-->
      </:item>
    </.accordion>
    """
  end

  defp code_string(19) do
    """
    <!-- Multiple items with initial open state -->
    <.accordion
      id="example-multiple-open"
      variant="bordered_separated"
      color="primary"
      multiple={true}
      initial_open={["item1", "item3"]}
    >
      <:item
        id="item1"
        title="First Item (Initially Open)"
        icon="hero-document-text"
      >
       This is the first accordion item that is initially open.
      </:item>

      <:item
        id="item2"
        title="Second Item (Initially Closed)"
        icon="hero-cog-6-tooth"
      >
        This item starts closed and can be opened by clicking.
      </:item>

      <:item
        id="item3"
        title="Third Item (Initially Open)"
        icon="hero-star"
      >
        This is another initially open item.
      </:item>

      <:item
        id="item4"
        title="Fourth Item (Initially Closed)"
        icon="hero-heart"
      >
        This final item demonstrates the complete flexibility.
      </:item>
    </.accordion>
    """
  end

  defp code_string(20) do
    """
    <!-- Server events integration -->
    <.accordion
      id="server-events-accordion"
      variant="outline_separated"
      color="info"
      server_events={true}
      event_handler="accordion-handler"
      space="medium"
    >
      <:item
        id="analytics"
        title="Analytics Tracking"
        description="Track user interactions with server events"
        icon="hero-chart-bar"
      >
       When this item is opened or closed, an event is sent to the LiveView server.
      </:item>

      <:item
        id="notifications"
        title="Real-time Notifications"
        description="Trigger server actions on accordion interactions"
        icon="hero-bell"
      >
        Server events enable real-time features like notifications and updates.
      </:item>

      <:item
        id="sync"
        title="State Synchronization"
        description="Keep server and client state in sync"
        icon="hero-arrow-path"
      >
        Perfect for maintaining consistent state across components.
      </:item>
    </.accordion>
    """
  end

  defp component_config() do
    [
      name: "accordion",
      args: [
        variant: [
          "base",
          "base_separated",
          "default",
          "bordered",
          "bordered_separated",
          "outline",
          "outline_separated",
          "shadow",
          "gradient",
          "transparent"
        ],
        color: [
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
        padding: ["extra_small", "small", "medium", "large", "extra_large", "zero"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["none", "extra_small", "small", "medium", "large", "extra_large"],
        border: ["none", "extra_small", "small", "medium", "large", "extra_large"],
        media_size: ["extra_small", "small", "medium", "large", "extra_large"]
      ],
      optional: [],
      necessary: ["icon"]
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/accordion"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Fully featured accordion component for Phoenix LiveView, offering collapsible sections with both custom components and native HTML tags for optimal performance and browser compatibility.",
      keywords:
        "phoenix accordion component, accordion component, liveview accordion component, elixir, liveview, mishka chelekom accordion component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Accordion - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Accordion - Chelekom Phoenix & LiveView component",
      og_title: "Accordion - Chelekom Phoenix & LiveView component",
      og_description:
        "Fully featured accordion component for Phoenix LiveView, offering collapsible sections with both custom components and native HTML tags for optimal performance and browser compatibility.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Accordion - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Fully featured accordion component for Phoenix LiveView, offering collapsible sections with both custom components and native HTML tags for optimal performance and browser compatibility."
    }
  end
end
