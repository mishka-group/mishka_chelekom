defmodule MishkaWeb.ChelekomLive.Docs.ListLive do
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
      |> assign(page_title: "List - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.list unordered variant="bordered" color="natiral"></.list>

    <.list unordered variant="bordered" color="white"></.list>

    <.ul variant="bordered" color="primary"></.ul>

    <.ul variant="bordered" color="secondary"></.ul>

    <.list_group variant="bordered" color="dark"></.list_group>

    <.list_group variant="bordered" color="success"></.list_group>

    <.list_group variant="bordered" color="warning"></.list_group>

    <.list unordered variant="bordered" color="danger"></.list>

    <.list unordered variant="bordered" color="info"></.list>

    <.ol variant="bordered" color="silver"></.ol>

    <.ol variant="bordered" color="misc"></.ol>

    <.list unordered variant="bordered" color="dawn"></.list>
    """
  end

  defp code_string(2) do
    """
    <.list_group variant="default" color="natural"></.list_group>

    <.list_group variant="default" color="white"></.list_group>

    <.list_group variant="default" color="primary"></.list_group>

    <.list_group variant="default" color="secondary"></.list_group>

    <.list_group variant="default" color="dark"></.list_group>

    <.ol variant="default" color="success"></.ol>

    <.ol variant="default" color="warning"></.ol>

    <.ol variant="default" color="danger"></.ol>

    <.ul variant="default" color="info"></.ul>

    <.ul variant="default" color="silver"></.ul>

    <.list variant="default" color="misc"></.list>

    <.list unordered variant="default" color="dawn"></.list>
    """
  end

  defp code_string(3) do
    """
    <.list unordered variant="outline_separated" color="natural"></.list>

    <.list unordered variant="outline_separated" color="primary"></.list>

    <.list_group variant="outline_separated" color="secondary"></.list_group>

    <.list_group variant="outline_separated" color="success"></.list_group>

    <.list unordered variant="outline_separated" color="warning"></.list>

    <.ol variant="outline_separated" color="danger"></.ol>

    <.ol variant="outline_separated" color="info"></.ol>

    <.list unordered variant="outline_separated" color="silver"></.list>

    <.ul variant="outline_separated" color="misc"></.ul>

    <.ul variant="outline_separated" color="dawn"></.ul>
    """
  end

  defp code_string(4) do
    """
    <.list_group variant="outline" color="natural"></.list_group>

    <.list_group variant="outline" color="primary"></.list_group>

    <.list_group variant="outline" color="secondary"></.list_group>

    <.list_group variant="outline" color="success"></.list_group>

    <.list_group variant="outline" color="warning"></.list_group>

    <.list_group variant="outline" color="danger"></.list_group>

    <.list_group variant="outline" color="info"></.list_group>

    <.list_group variant="outline" color="silver"></.list_group>

    <.list_group variant="outline" color="misc"></.list_group>

    <.list_group variant="outline" color="dawn"></.list_group>
    """
  end

  defp code_string(5) do
    """
    <.list_group variant="bordered_separated" color="natural"></.list_group>

    <.list_group variant="bordered_separated" color="primary"></.list_group>

    <.list_group variant="bordered_separated" color="secondary"></.list_group>

    <.list_group variant="bordered_separated" color="success"></.list_group>

    <.list_group variant="bordered_separated" color="warning"></.list_group>

    <.list_group variant="bordered_separated" color="danger"></.list_group>

    <.list_group variant="bordered_separated" color="info"></.list_group>

    <.list_group variant="bordered_separated" color="silver"></.list_group>

    <.list_group variant="bordered_separated" color="misc"></.list_group>

    <.list_group variant="bordered_separated" color="dawn"></.list_group>
    """
  end

  defp code_string(6) do
    """
    <.list_group variant="transparent" color="natural"></.list_group>

    <.list_group variant="transparent" color="primary"></.list_group>

    <.list_group variant="transparent" color="secondary"></.list_group>

    <.list_group variant="transparent" color="success"></.list_group>

    <.list_group variant="transparent" color="warning"></.list_group>

    <.list_group variant="transparent" color="danger"></.list_group>

    <.list_group variant="transparent" color="info"></.list_group>

    <.list_group variant="transparent" color="silver"></.list_group>

    <.list_group variant="transparent" color="misc"></.list_group>

    <.list_group variant="transparent" color="dawn"></.list_group>
    """
  end

  defp code_string(7) do
    """
    <.list unordered size="extra_small"></.list>

    <.list unordered size="small"></.list>

    <.list unordered size="medium"></.list>

    <.list unordered size="large"></.list>

    <.list unordered size="extra_large"></.list>
    """
  end

  defp code_string(8) do
    """
    <.list unordered space="extra_small"></.list>

    <.list unordered space="small"></.list>

    <.list unordered space="medium"></.list>

    <.list unordered space="large"></.list>

    <.list unordered space="extra_large"></.list>
    """
  end

  defp code_string(9) do
    """
    <.list unordered font_weight="font-thin"></.list>

    <.ol font_weight="font-normal"></.ol>

    <.list_group font_weight="font-medium"></.list_group>

    <.ul font_weight="font-bold"></.ul>

    <.list unordered font_weight="font-extrabold"></.list>
    """
  end

  defp code_string(10) do
    """
    <.list unordered variant="transparent" style="list-disc">
      <:item>Home</:item>
      <:item>Services</:item>
      <:item>About Us</:item>
      <:item>Contact</:item>
    </.list>
    """
  end

  defp code_string(11) do
    """
    <.list unordered>
      <:item>Home</:item>
      <:item>Services</:item>
      <:item>About Us</:item>
      <:item>Contact</:item>
    </.list>
    """
  end

  defp code_string(12) do
    """
    <.list unordered>
      <.li>Home</.li>
      <.li>Services</.li>
      <.li>About Us</.li>
      <.li>Contact</.li>
    </.list>

    <.list_group>
      <.li>Home</.li>
      <.li>Services</.li>
      <.li>About Us</.li>
      <.li>Contact</.li>
    </.list_group>
    """
  end

  defp code_string(13) do
    """
    <.list unordered>
      <.li count={1}>Home</.li>
      <.li count={2}>Services</.li>
      <.li count={3}>About Us</.li>
      <.li count={4}>Contact</.li>
    </.list>

    <.list_group>
      <.li count={1}>Home</.li>
      <.li count={2}>Services</.li>
      <.li count={3}>About Us</.li>
      <.li count={4}>Contact</.li>
    </.list_group>
    """
  end

  defp code_string(14) do
    """
    <.list unordered>
      <.li count_separator="_" count={1}>Home</.li>
      <.li count_separator="_" count={2}>Services</.li>
      <.li count_separator="_" count={3}>About Us</.li>
      <.li count_separator="_" count={4}>Contact</.li>
    </.list>

    <.list_group>
      <.li count_separator="_" count={1}>Home</.li>
      <.li count_separator="_" count={2}>Services</.li>
      <.li count_separator="_" count={3}>About Us</.li>
      <.li count_separator="_" count={4}>Contact</.li>
    </.list_group>
    """
  end

  defp code_string(15) do
    """
    <.list unordered>
      <.li icon="hero-bookmark">Bookmark</.li>
      <.li icon="hero-ticket">Tickets</.li>
      <.li icon="hero-star">Favorits</.li>
    </.list>
    """
  end

  defp code_string(16) do
    """
    <.list unordered>
      <.li icon_class="size-8 me-3.5 text-red-900" icon="hero-bookmark">Bookmark</.li>
      <.li icon_class="size-8 me-3.5 text-red-900" icon="hero-ticket">Tickets</.li>
      <.li icon_class="size-8 me-3.5 text-red-900" icon="hero-star">Favorits</.li>
    </.list>
    """
  end

  defp code_string(17) do
    """
    <.list unordered>
      <.li padding="extra_small"></.li>

      <.li padding="small"></.li>

      <.li padding="medium"></.li>

      <.li padding="large"></.li>

      <.li padding="extra_large"></.li>
    </.list>
    """
  end

  defp code_string(18) do
    """
    <.ul>
      <.li></.li>

      <.li></.li>

      <.li></.li>

      <.li></.li>

      <.li></.li>
    </.ul>
    """
  end

  defp code_string(19) do
    """
    <.ol>
      <.li></.li>

      <.li></.li>

      <.li></.li>
    </.ol>
    """
  end

  defp code_string(20) do
    """
    <.ol width="extra_small"></.ol>

    <.ol width="small"></.ol>

    <.ul width="medium"></.ul>

    <.ul width="large"></.ul>

    <.list_group width="extra_large"></.list_group>
    """
  end

  defp code_string(21) do
    """
    <.list_group>
      <.li>Home</.li>
      <.li>Payments</.li>
      <.li>Settings</.li>
    </.list_group>
    """
  end

  defp code_string(22) do
    """
    <.list_group rounded="extra_small"></.list_group>

    <.list_group rounded="small"></.list_group>

    <.list_group rounded="medium"></.list_group>

    <.list_group rounded="large"></.list_group>

    <.list_group rounded="extra_large"></.list_group>

    <.list_group rounded="full"></.list_group>

    <.list_group rounded="none"></.list_group>
    """
  end

  defp code_string(23) do
    """
    <.list_group padding="extra_small"></.list_group>

    <.list_group padding="small"></.list_group>

    <.list_group padding="medium"></.list_group>

    <.list_group padding="large"></.list_group>

    <.list_group padding="extra_large"></.list_group>

    <.list_group padding="full"></.list_group>

    <.list_group padding="none"></.list_group>
    """
  end

  defp code_string(24) do
    """
    <.ul style="list-disc">
      <li>First level list item</li>
      <li>First level list item</li>
      <li>First level list item</li>
      <.list space="small" ordered>
        <:item>Second level list item</:item>
        <:item>Second level list item</:item>
        <.list space="large" unordered style="list-disc">
          <:item>Third level list item</:item>
          <:item>Third level list item</:item>
          <:item>Third level list item</:item>
        </.list>
      </.list>
    </.ul>
    """
  end

  defp code_string(25) do
    """
    <.list ordered>
      <.li></.li>
      <.li></.li>
    </.list>

    <.list ordered>
      <:item></:item>
      <:item></:item>
      <:item></:item>
    </.list>

    <.list unordered>
      <:item></:item>
      <:item></:item>
      <:item></:item>
    </.list>

    <.list unordered style="list-disc">
      <li></li>
      <li></li>
      <li></li>
    </.list>
    """
  end

  defp code_string(26) do
    """
    <.list_group variant="shadow" color="natural"></.list_group>

    <.list_group variant="shadow" color="primary"></.list_group>

    <.list_group variant="shadow" color="secondary"></.list_group>

    <.list_group variant="shadow" color="success"></.list_group>

    <.list_group variant="shadow" color="warning"></.list_group>

    <.list_group variant="shadow" color="danger"></.list_group>

    <.list_group variant="shadow" color="info"></.list_group>

    <.list_group variant="shadow" color="silver"></.list_group>

    <.list_group variant="shadow" color="misc"></.list_group>

    <.list_group variant="shadow" color="dawn"></.list_group>
    """
  end

  defp code_string(27) do
    """
    <.list_group variant="gradient" color="natural"></.list_group>

    <.list_group variant="gradient" color="primary"></.list_group>

    <.list_group variant="gradient" color="secondary"></.list_group>

    <.list_group variant="gradient" color="success"></.list_group>

    <.list_group variant="gradient" color="warning"></.list_group>

    <.list_group variant="gradient" color="danger"></.list_group>

    <.list_group variant="gradient" color="info"></.list_group>

    <.list_group variant="gradient" color="silver"></.list_group>

    <.list_group variant="gradient" color="misc"></.list_group>

    <.list_group variant="gradient" color="dawn"></.list_group>
    """
  end

  defp code_string(28) do
    """
    <.list_group variant="default" hoverable></.list_group>

    <.list_group variant="gradient" hoverable></.list_group>

    <.list_group variant="bordered" hoverable></.list_group>
    """
  end

  defp code_string(29) do
    """
    <.list unordered variant="base" color="base"></.list>

    <.ul variant="base" color="base"></.ul>

    <.list_group variant="base" color="base"></.list_group>

    <.ol variant="base" color="base"></.ol>

    <.list variant="base_separated" space="small" color="base">
      <:item>Home</:item>
      <:item>Services</:item>
      <:item>About Us</:item>
      <:item>Contact</:item>
    </.list>
    """
  end

  defp component_config() do
    [
      name: "list",
      args: [
        variant: [
          "default",
          "bordered",
          "outline",
          "shadow",
          "gradient",
          "outline_separated",
          "bordered_separated",
          "transparent",
          "base",
          "base_separated"
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
          "silver",
          "misc",
          "dawn"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
        type: ["list", "li", "ul", "ol", "list_group"],
        only: ["list", "li", "ul", "ol", "list_group"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/list"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Customizable list and list group components in Phoenix LiveView, styled lists with various options like colors, sizes, variants, and spacing to enhance content organization.",
      keywords:
        "phoenix list component, list component, liveview list component, elixir, liveview, mishka chelekom list component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "List - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "List - Chelekom Phoenix & LiveView component",
      og_title: "List - Chelekom Phoenix & LiveView component",
      og_description:
        "Customizable list and list group components in Phoenix LiveView, styled lists with various options like colors, sizes, variants, and spacing to enhance content organization.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "List - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Customizable list and list group components in Phoenix LiveView, styled lists with various options like colors, sizes, variants, and spacing to enhance content organization."
    }
  end
end
