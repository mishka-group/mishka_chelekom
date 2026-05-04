defmodule MishkaWeb.ChelekomLive.Docs.CardLive do
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
      |> assign(page_title: "Card - Chelekom Phoenix & LiveView component")
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
      |> assign(code_21: code_string(21))
      |> assign(code_22: code_string(22))
      |> assign(code_23: code_string(23))
      |> assign(code_24: code_string(24))
      |> assign(code_25: code_string(25))
      |> assign(code_26: code_string(26))
      |> assign(code_27: code_string(27))
      |> assign(code_28: code_string(28))
      |> assign(code_29: code_string(29))
      |> assign(code_30: code_string(30))
      |> assign(code_31: code_string(31))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.card variant="default" color="natural"></.card>
    <.card variant="default" color="white"></.card>
    <.card variant="default" color="dark"></.card>
    <.card variant="default" color="primary"></.card>
    <.card variant="default" color="secondary"></.card>
    <.card variant="default" color="success"></.card>
    <.card variant="default" color="warning"></.card>
    <.card variant="default" color="danger"></.card>
    <.card variant="default" color="info"></.card>
    <.card variant="default" color="silver"></.card>
    <.card variant="default" color="misc"></.card>
    <.card variant="default" color="dawn"></.card>
    """
  end

  defp code_string(2) do
    """
    <.card color="natural" variant="outline"></.card>
    <.card color="primary" variant="outline"></.card>
    <.card color="secondary" variant="outline"></.card>
    <.card color="success" variant="outline"></.card>
    <.card color="warning" variant="outline"></.card>
    <.card color="danger" variant="outline"></.card>
    <.card color="info" variant="outline"></.card>
    <.card color="silver" variant="outline"></.card>
    <.card color="misc" variant="outline"></.card>
    <.card color="dawn" variant="outline"></.card>
    """
  end

  defp code_string(3) do
    """
    <.card color="natural" variant="shadow"></.card>
    <.card color="primary" variant="shadow"></.card>
    <.card color="secondary" variant="shadow"></.card>
    <.card color="success" variant="shadow"></.card>
    <.card color="warning" variant="shadow"></.card>
    <.card color="danger" variant="shadow"></.card>
    <.card color="info" variant="shadow"></.card>
    <.card color="silver" variant="shadow"></.card>
    <.card color="misc" variant="shadow"></.card>
    <.card color="dawn" variant="shadow"></.card>
    """
  end

  defp code_string(4) do
    """
    <.card color="natural" variant="bordered"></.card>
    <.card color="white" variant="bordered"></.card>
    <.card color="dark" variant="bordered"></.card>
    <.card color="primary" variant="bordered"></.card>
    <.card color="secondary" variant="bordered"></.card>
    <.card color="success" variant="bordered"></.card>
    <.card color="warning" variant="bordered"></.card>
    <.card color="danger" variant="bordered"></.card>
    <.card color="info" variant="bordered"></.card>
    <.card color="silver" variant="bordered"></.card>
    <.card color="misc" variant="bordered"></.card>
    <.card color="dawn" variant="bordered"></.card>
    """
  end

  defp code_string(5) do
    """
    <.card color="natural" variant="transparent"></.card>
    <.card color="primary" variant="transparent"></.card>
    <.card color="secondary" variant="transparent"></.card>
    <.card color="success" variant="transparent"></.card>
    <.card color="warning" variant="transparent"></.card>
    <.card color="danger" variant="transparent"></.card>
    <.card color="info" variant="transparent"></.card>
    <.card color="silver" variant="transparent"></.card>
    <.card color="misc" variant="transparent"></.card>
    <.card color="dawn" variant="transparent"></.card>
    """
  end

  defp code_string(6) do
    """
    <.card rounded="extra_small"></.card>
    <.card rounded="small"></.card>
    <.card rounded="medium"></.card>
    <.card rounded="large"></.card>
    <.card rounded="extra_large"></.card>
    """
  end

  defp code_string(7) do
    """
    <.card border="extra_small"></.card>
    <.card border="small"></.card>
    <.card border="medium"></.card>
    <.card border="large"></.card>
    <.card border="extra_large"></.card>
    """
  end

  defp code_string(8) do
    """
    <.card space="extra_small"></.card>
    <.card space="small"></.card>
    <.card space="medium"></.card>
    <.card space="large"></.card>
    <.card space="extra_large"></.card>
    """
  end

  defp code_string(9) do
    """
    <.card padding="extra_small"></.card>
    <.card padding="small"></.card>
    <.card padding="medium"></.card>
    <.card padding="large"></.card>
    <.card padding="extra_large"></.card>
    """
  end

  defp code_string(10) do
    """
    <.card class="font-thin"></.card>
    <.card class="font-extrasilver"></.card>
    <.card class="font-silver"></.card>
    <.card class="font-normal"></.card>
    <.card class="font-medium"></.card>
    <.card class="font-semibold"></.card>
    <.card class="font-bold"></.card>
    <.card class="font-extrabold"></.card>
    <.card class="font-black"></.card>
    """
  end

  defp code_string(11) do
    """
    <.card class="your_classes">
      <.card_content>
        <h3>
          This is a small text inside the h3.
        </h3>

        <div>
          Another small text inside the first div.
        </div>

        <.button size="small" color="danger">
          a button within card content
        </.button>
      </.card_content>
    </.card>
    """
  end

  defp code_string(12) do
    """
    <.card class="your_classes">
      <.card_content space="extra_small" class="your_classes">
        <h3>This is a small text inside the h3.</h3>
      </.card_content>
    </.card>

    <.card class="your_classes">
      <.card_content space="small" class="your_classes">
        <h3>This is a small text inside the h3.</h3>
      </.card_content>
    </.card>

    <.card class="your_classes">
      <.card_content space="medium" class="your_classes">
        <h3>This is a small text inside the h3.</h3>
      </.card_content>
    </.card>

    <.card class="your_classes">
      <.card_content space="large" class="your_classes">
        <h3>This is a small text inside the h3.</h3>
      </.card_content>
    </.card>

    <.card class="your_classes">
      <.card_content space="extra_large" class="your_classes">
        <h3>This is a small text inside the h3.</h3>
      </.card_content>
    </.card>
    """
  end

  defp code_string(13) do
    """
    <!--When you want to add padding to card contetn set card padding to none-->

    <.card class="your_classes" padding="none">
      <.card_content padding="extra_small" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes" padding="none">
      <.card_content padding="small" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes" padding="none">
      <.card_content padding="medium" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes" padding="none">
      <.card_content padding="large" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes" padding="none">
      <.card_content padding="extra_large" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes" padding="none">
      <.card_content padding="none " class="your_classes"></.card_content>
    </.card>
    """
  end

  defp code_string(14) do
    """
    <.card class="your_card_classes">
      <!--Put any text or HTML Between title component-->
      <.card_title class="your_classes"></.card_title>
    </.card>
    """
  end

  defp code_string(15) do
    """
    <.card class="your_card_classes">
      <.card_title title="Mishka Chelekom card title" class="your_classes" />
    </.card>
    """
  end

  defp code_string(16) do
    """
    <.card class="your_card_classes">
      <!--Use any heroicons.com icons inside icon prop-->
      <.card_title title="Card title prop" icon="hero-home" />
    </.card>
    """
  end

  defp code_string(17) do
    """
    <.card class="your_card_classes">
      <.card_title title="Mishka Chelekom card title prop" position="start" />
    </.card>

    <.card class="your_card_classes">
      <.card_title title="Mishka Chelekom card title prop" position="center" />
    </.card>

    <.card class="your_card_classes">
      <.card_title title="Mishka Chelekom card title prop" position="end" />
    </.card>

    <.card class="your_card_classes">
      <.card_title title="Mishka Chelekom card title prop" position="between" />
    </.card>

    <.card class="your_card_classes">
      <.card_title title="Mishka Chelekom card title prop" position="around" />
    </.card>
    """
  end

  defp code_string(18) do
    """
    <.card class="your_classes">
      <.card_content size="extra_small" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes">
      <.card_content size="small" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes">
      <.card_content size="medium" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes">
      <.card_content size="large" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes">
      <.card_content size="extra_large" class="your_classes"></.card_content>
    </.card>
    """
  end

  defp code_string(19) do
    """
    <!--When you want to add padding to card title set card padding to none-->
    <.card class="your_classes" padding="none">
      <.card_content padding="extra_small" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes" padding="none">
      <.card_content padding="small" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes" padding="none">
      <.card_content padding="medium" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes" padding="none">
      <.card_content padding="large" class="your_classes"></.card_content>
    </.card>

    <.card class="your_classes" padding="none">
      <.card_content padding="extra_large" class="your_classes"></.card_content>
    </.card>
    """
  end

  defp code_string(20) do
    """
    <.card>
      <.card_title title="Title" class="font-thin" />
    </.card>

    <.card>
      <.card_title title="Title" class="font-extrasilver" />
    </.card>

    <.card>
      <.card_title title="Title" class="font-silver" />
    </.card>

    <.card>
      <.card_title title="Title" class="font-normal" />
    </.card>

    <.card>
      <.card_title title="Title" class="font-medium" />
    </.card>

    <.card>
      <.card_title title="Title" class="font-semibold" />
    </.card>

    <.card>
      <.card_title title="Title" class="font-bold" />
    </.card>

    <.card>
      <.card_title title="Title" class="font-extrabold" />
    </.card>

    <.card>
      <.card_title title="Title" class="font-black" />
    </.card>
    """
  end

  defp code_string(21) do
    """
    <.card>
      <.card_media src="/path"/>
      <.card_content>
        <!--Content goes here-->
      </.card_content>
    </.card>
    """
  end

  defp code_string(22) do
    """
    <.card>
      <.card_media src="/path" />
    </.card>
    """
  end

  defp code_string(23) do
    """
    <.card>
      <.card_media src="/path" alt="card_image" />
    </.card>
    """
  end

  defp code_string(24) do
    """
    <.card>
      <.card_content>
        <.card_media src="/path" rounded="extra_small" />
        <.card_media src="/path" rounded="small" />
        <.card_media src="/path" rounded="medium" />
        <.card_media src="/path" rounded="large" />
        <.card_media src="/path" rounded="extra_large" />
      </.card_content>
    </.card>
    """
  end

  defp code_string(25) do
    """
    <.card>
      <.card_footer padding="large">
        Contne inside footer goes here
      </.card_footer>
    </.card>
    """
  end

  defp code_string(26) do
    """
    <.card>
      <.card_footer padding="large">
        Contne inside footer goes here
      </.card_footer>
    </.card>
    """
  end

  defp code_string(27) do
    """
    <.card padding="small" rounded="large">
      <.card_title class="flex items-center gap-2 justify-between">
        <.link navigate="/path">Mishka Chelekom</.link>
      </.card_title>

      <.hr />

      <.card_content space="large" class="text-sm">
        <.card_media rounded="large" src="/path" rounded="large" alt=""/>

        <p>Descriptions</p>
        <p>Descriptions</p>

        <div class="grid grid-cols-3 gap-2">
          <.card_media src="/path" rounded="large" alt=""/>
          <.card_media src="/path" rounded="large" alt=""/>
          <.card_media src="/path" rounded="large" alt=""/>
        </div>
      </.card_content>

      <.hr />

      <.card_footer >
        <.button class="w-full" color="info">See more</.button>
      </.card_footer>
    </.card>
    """
  end

  defp code_string(28) do
    """
    <.card color="natural" variant="gradient"></.card>
    <.card color="primary" variant="gradient"></.card>
    <.card color="secondary" variant="gradient"></.card>
    <.card color="success" variant="gradient"></.card>
    <.card color="warning" variant="gradient"></.card>
    <.card color="danger" variant="gradient"></.card>
    <.card color="info" variant="gradient"></.card>
    <.card color="silver" variant="gradient"></.card>
    <.card color="misc" variant="gradient"></.card>
    <.card color="dawn" variant="gradient"></.card>
    """
  end

  defp code_string(29) do
    """
    <.card>
      <.video controls>
        <:source src="/path" type="video/mp4" />
        <:source src="/path" type="video/webp" />
      </.video>

      <.card_content>
       Card Content
      </.card_content>
    </.card>
    """
  end

  defp code_string(30) do
    """
    <.card>
      <.card_media src="/path" />

      <.overlay color="dark" opacity="opaque">
        <.card_content class="flex items-center flex-col justify-center h-full">

          <h2>Camping Responsibly to Preserve Nature’s Beauty</h2>

          <.button_link size="extra_small">Read more</.button_link>
        </.card_content>
      </.overlay>
    </.card>
    """
  end

  defp code_string(31) do
    """
    <.card>
      <.card_content class="flex items-center flex-col justify-center h-full">

        <h2>Camping Responsibly to Preserve Nature’s Beauty</h2>

        <.button_link size="extra_small">Read more</.button_link>
      </.card_content>
    </.card>
    """
  end

  defp component_config() do
    [
      name: "card",
      args: [
        variant: ["default", "outline", "transparent", "shadow", "bordered", "gradient", "base"],
        color: [
          "base",
          "natural",
          "primary",
          "secondary",
          "success",
          "warning",
          "danger",
          "info",
          "silver",
          "misc",
          "dark",
          "white",
          "dawn"
        ],
        size: [
          "extra_small",
          "small",
          "medium",
          "large",
          "extra_large"
        ],
        space: [
          "extra_small",
          "small",
          "medium",
          "large",
          "extra_large",
          "double_large",
          "triple_large",
          "quadruple_large"
        ],
        padding: [
          "extra_small",
          "small",
          "medium",
          "large",
          "extra_large",
          "double_large",
          "triple_large",
          "quadruple_large",
          "none"
        ],
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        type: ["card", "card_title", "card_media", "card_content", "card_footer"],
        only: ["card", "card_title", "card_media", "card_content", "card_footer"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/card"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Customizable card components for Phoenix and Phoenix LiveView, offering flexible layouts with titles, media, content, and footers.",
      keywords:
        "phoenix card component, card component, liveview card component, elixir, liveview, mishka chelekom card component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Card - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Card - Chelekom Phoenix & LiveView component",
      og_title: "Card - Chelekom Phoenix & LiveView component",
      og_description: "",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Card - Chelekom Phoenix & LiveView component",
      twitter_description: ""
    }
  end
end
