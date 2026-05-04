defmodule MishkaWeb.ChelekomLive.Docs.AlertLive do
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
      |> assign(page_title: "Alert - Chelekom Phoenix & LiveView component", flash_pos: "none")
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
      |> put_flash(:error, "The error for flash group")
      |> put_flash(:info, "The info for flash group")

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("flash_position", %{"pos" => pos}, socket)
      when pos in ["top_left", "top_right", "bottom_right", "bottom_left"] do
    {:noreply, assign(socket, flash_pos: pos)}
  end

  defp code_string(1) do
    """
    <.alert varinat="default" kind={:natural}>Natural</.alert>

    <.alert varinat="default" kind={:white}>White</.alert>

    <.alert varinat="default" kind={:pridarkmary}>Dark</.alert>

    <.alert varinat="default" kind={:primary}>Primary</.alert>

    <.alert varinat="default" kind={:secondary}>Secondary</.alert>

    <.alert varinat="default" kind={:success}>Success</.alert>

    <.alert varinat="default" kind={:warning}>Warning</.alert>

    <.alert varinat="default" kind={:danger}>Danger</.alert>

    <.alert varinat="default" kind={:info}>Info</.alert>

    <.alert varinat="default" kind={:silver}>Silver</.alert>

    <.alert varinat="default" kind={:misc}>Misc</.alert>

    <.alert varinat="default" kind={:dawn}>Dawn</.alert>
    """
  end

  defp code_string(2) do
    """
    <.alert variant="outline" kind={:natural}>Natural</.alert>

    <.alert variant="outline" kind={:primary}>Primary</.alert>

    <.alert variant="outline" kind={:secondary}>Secondary</.alert>

    <.alert variant="outline" kind={:success}>Success</.alert>

    <.alert variant="outline" kind={:warning}>Warning</.alert>

    <.alert variant="outline" kind={:danger}>Danger</.alert>

    <.alert variant="outline" kind={:info}>Info</.alert>

    <.alert variant="outline" kind={:silver}>Silver</.alert>

    <.alert variant="outline" kind={:misc}>Misc</.alert>

    <.alert variant="outline" kind={:dawn}>Dawn</.alert>
    """
  end

  defp code_string(3) do
    """
    <.alert variant="shadow" kind={:natural}>Natural</.alert>

    <.alert variant="shadow" kind={:primary}>Primary</.alert>

    <.alert variant="shadow" kind={:secondary}>Secondary</.alert>

    <.alert variant="shadow" kind={:success}>Success</.alert>

    <.alert variant="shadow" kind={:warning}>Warning</.alert>

    <.alert variant="shadow" kind={:danger}>Danger</.alert>

    <.alert variant="shadow" kind={:info}>Info</.alert>

    <.alert variant="shadow" kind={:silver}>Silver</.alert>

    <.alert variant="shadow" kind={:misc}>Misc</.alert>

    <.alert variant="shadow" kind={:dawn}>Dawn</.alert>
    """
  end

  defp code_string(5) do
    """
    <.flash type="custom" kind={:natural}>Natural</.flash>

    <.flash type="custom" kind={:primary}>Primary</.flash>

    <.flash type="custom" kind={:secondary}>Secondary</.flash>

    <.flash type="custom" kind={:success}>Success</.flash>

    <.flash type="custom" kind={:warning}>Warning</.flash>

    <.flash type="custom" kind={:danger}>Danger</.flash>

    <.flash type="custom" kind={:info}>Info</.flash>

    <.flash type="custom" kind={:silver}>Silver</.flash>

    <.flash type="custom" kind={:misc}>Misc</.flash>

    <.flash type="custom" kind={:dawn}>Dawn</.flash>
    """
  end

  defp code_string(6) do
    """
    <.flash_group position="top_left" flash={@flash} />

    <.flash_group position="top_right" flash={@flash} />

    <.flash_group position="bottom_left" flash={@flash} />

    <.flash_group position="bottom_right" flash={@flash} />
    """
  end

  defp code_string(7) do
    """
    <.alert position="top_left" kind={:natural}>Posistion</.alert>

    <.alert position="top_right" kind={:primary}>Posistion</.alert>

    <.alert position="bottom_left" kind={:secondary}>Posistion</.alert>

    <.alert position="bottom_right" kind={:silver}>Posistion</.alert>

    <!--The default position is nil, so you don’t need to pass it-->
      <.alert position={nil} kind={:success}>Success</.alert>
    """
  end

  defp code_string(8) do
    """
    <!--Default is w-full, you don’t need to pass it-->
    <.alert kind={:warning}>Default position(nil)</.alert>

    <.alert kind={:warning} width="extra_small">Extra small</.alert>

    <.alert kind={:warning} width="small">small</.alert>

    <.alert kind={:warning} width="medium">Medium</.alert>

    <.alert kind={:warning} width="large">Large</.alert>

    <.alert kind={:warning} width="extra_large">Extra large</.alert>
    """
  end

  defp code_string(4) do
    """
    <.alert kind={:danger} border="extra_small">Extra small</.alert>

    <.alert kind={:info} border="small">small</.alert>

    <.alert kind={:warning} border="medium">Medium</.alert>

    <.alert kind={:misc} border="large">Large</.alert>

    <.alert kind={:dawn} border="extra_large">Extra large</.alert>
    """
  end

  defp code_string(9) do
    """
    <.alert kind={:warning} rounded="extra_small">Extra small</.alert>

    <.alert kind={:warning} rounded="small">small</.alert>

    <.alert kind={:warning} rounded="medium">Medium</.alert>

    <.alert kind={:warning} rounded="large">Large</.alert>

    <.alert kind={:warning} rounded="extra_large">Extra large</.alert>
    """
  end

  defp code_string(10) do
    """
    <.alert kind={:warning} title="This is title" icon="hero-home" />

    <.flash type="custom" kind={:error} title="This is flash title" />
    """
  end

  defp code_string(11) do
    """
    <.alert kind={:warning} font_weight="font-bold">Extra small</.alert>

    <.alert kind={:danger} font_weight="font-thin">small</.alert>

    <.alert kind={:silver} font_weight="font-Silver">Medium</.alert>

    <.flash type="custom" kind={:misc} font_weight="font-semibold">Large</.flash>

    <.flash type="custom" kind={:dawn} font_weight="font-normal">Extra large</.flash>
    """
  end

  defp code_string(12) do
    """
    <.alert variant="bordered" kind={:natural}>Natural</.alert>

    <.alert variant="bordered" kind={:white}>White</.alert>

    <.alert variant="bordered" kind={:dark}>Dark</.alert>

    <.alert variant="bordered" kind={:primary}>Primary</.alert>

    <.alert variant="bordered" kind={:secondary}>Secondary</.alert>

    <.alert variant="bordered" kind={:success}>Success</.alert>

    <.alert variant="bordered" kind={:warning}>Warning</.alert>

    <.alert variant="bordered" kind={:danger}>Danger</.alert>

    <.alert variant="bordered" kind={:info}>Info</.alert>

    <.alert variant="bordered" kind={:silver}>Silver</.alert>

    <.alert variant="bordered" kind={:misc}>Misc</.alert>

    <.alert variant="bordered" kind={:dawn}>Dawn</.alert>
    """
  end

  defp code_string(13) do
    """
    <.alert variant="gradient" kind={:natural}>Natural</.alert>

    <.alert variant="gradient" kind={:primary}>Primary</.alert>

    <.alert variant="gradient" kind={:secondary}>Secondary</.alert>

    <.alert variant="gradient" kind={:success}>Success</.alert>

    <.alert variant="gradient" kind={:warning}>Warning</.alert>

    <.alert variant="gradient" kind={:danger}>Danger</.alert>

    <.alert variant="gradient" kind={:info}>Info</.alert>

    <.alert variant="gradient" kind={:silver}>Silver</.alert>

    <.alert variant="gradient" kind={:misc}>Misc</.alert>

    <.alert variant="gradient" kind={:dawn}>Dawn</.alert>
    """
  end

  defp code_string(14) do
    """
    <.alert variant="base">Base</.alert>
    """
  end

  defp code_string(15) do
    """
    <.flash type="custom" content_class="custom_class"></.flash>

    <.flash type="custom" title_class="custom_class"></.flash>

    <.flash type="custom" button_class="custom_class"></.flash>
    """
  end

  defp code_string(16) do
    """
    <.alert title_class="custom_class"></.alert>
    """
  end

  defp code_string(17) do
    """
    <.alert kind={:warning} padding="extra_small">Extra small</.alert>

    <.alert kind={:warning} padding="small">small</.alert>

    <.alert kind={:warning} padding="medium">Medium</.alert>

    <.alert kind={:warning} padding="large">Large</.alert>

    <.alert kind={:warning} padding="extra_large">Extra large</.alert>
    """
  end

  defp component_config() do
    [
      name: "alert",
      args: [
        variant: ["default", "outline", "shadow", "bordered", "gradient", "base"],
        color: [
          "base",
          "white",
          "dark",
          "info",
          "danger",
          "success",
          "natural",
          "primary",
          "secondary",
          "misc",
          "warning",
          "silver",
          "dawn",
          "error"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
        type: ["flash", "flash_group", "alert"],
        only: ["flash", "flash_group", "alert"],
        helpers: [show_alert: 2, hide_alert: 2],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/alert"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "The Alert and Flash Message component in Phoenix LiveView displays static alerts and dynamic flash messages, including flash groups, for clear and effective user communication.",
      keywords:
        "phoenix alert component, alert component, liveview alert component, elixir, liveview, mishka chelekom alert component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Alert - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Alert - Chelekom Phoenix & LiveView component",
      og_title: "Alert - Chelekom Phoenix & LiveView component",
      og_description:
        "The Alert and Flash Message component in Phoenix LiveView displays static alerts and dynamic flash messages, including flash groups, for clear and effective user communication.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Alert - Chelekom Phoenix & LiveView component",
      twitter_description:
        "The Alert and Flash Message component in Phoenix LiveView displays static alerts and dynamic flash messages, including flash groups, for clear and effective user communication."
    }
  end
end
