defmodule MishkaWeb.ChelekomLive.Docs.ToastLive do
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

  @all_toasts Enum.map(1..140, &"toast-example-#{&1}")

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Toast - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(toast_pos: "none")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("dismiss", _, socket) do
    {:noreply, socket}
  end

  def handle_event("toast_position", %{"pos" => pos}, socket) do
    socket =
      socket
      |> assign(toast_pos: if(Enum.member?(@all_toasts, pos), do: pos, else: "none"))

    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.toast variant="default" color="natural">Toast Default White</.toast>
    <.toast variant="default" color="white">Toast Default White</.toast>
    <.toast variant="default" color="dark">Toast Default Dark</.toast>
    <.toast variant="default" color="info">Toast Default Info</.toast>
    <.toast variant="default" color="success">Toast Default Success</.toast>
    <.toast variant="default" color="warning">Toast Default Warning</.toast>
    <.toast variant="default" color="danger">Toast Default Danger</.toast>
    <.toast variant="default" color="silver">Toast Default Silver</.toast>
    <.toast variant="default" color="misc">Toast Default Misc</.toast>
    <.toast variant="default" color="dawn">Toast Default Dawn</.toast>
    <.toast variant="default" color="primary">Toast Default Primary</.toast>
    <.toast variant="default" color="secondary">Toast Default Secondary</.toast>
    """
  end

  defp code_string(2) do
    """
    <.toast variant="outline" color="natural">Toast outline Info</.toast>
    <.toast variant="outline" color="info">Toast outline Info</.toast>
    <.toast variant="outline" color="success">Toast outline Success</.toast>
    <.toast variant="outline" color="warning">Toast outline Warning</.toast>
    <.toast variant="outline" color="danger">Toast outline Danger</.toast>
    <.toast variant="outline" color="silver">Toast outline Silver</.toast>
    <.toast variant="outline" color="misc">Toast outline Misc</.toast>
    <.toast variant="outline" color="dawn">Toast outline Dawn</.toast>
    <.toast variant="outline" color="primary">Toast outline Primary</.toast>
    <.toast variant="outline" color="secondary">Toast outline Secondary</.toast>
    """
  end

  defp code_string(3) do
    """
    <.toast variant="shadow" color="natural">Toast shadow White</.toast>
    <.toast variant="shadow" color="info">Toast shadow Info</.toast>
    <.toast variant="shadow" color="success">Toast shadow Success</.toast>
    <.toast variant="shadow" color="warning">Toast shadow Warning</.toast>
    <.toast variant="shadow" color="danger">Toast shadow Danger</.toast>
    <.toast variant="shadow" color="silver">Toast shadow Silver</.toast>
    <.toast variant="shadow" color="misc">Toast shadow Misc</.toast>
    <.toast variant="shadow" color="dawn">Toast shadow Dawn</.toast>
    <.toast variant="shadow" color="primary">Toast shadow Primary</.toast>
    <.toast variant="shadow" color="secondary">Toast shadow Secondary</.toast>
    """
  end

  defp code_string(4) do
    """
    <.toast variant="bordered" color="natural">Toast bordered White</.toast>
    <.toast variant="bordered" color="white">Toast bordered White</.toast>
    <.toast variant="bordered" color="dark">Toast bordered Dark</.toast>
    <.toast variant="bordered" color="info">Toast bordered Info</.toast>
    <.toast variant="bordered" color="success">Toast bordered Success</.toast>
    <.toast variant="bordered" color="warning">Toast bordered Warning</.toast>
    <.toast variant="bordered" color="danger">Toast bordered Danger</.toast>
    <.toast variant="bordered" color="silver">Toast bordered Silver</.toast>
    <.toast variant="bordered" color="misc">Toast bordered Misc</.toast>
    <.toast variant="bordered" color="dawn">Toast bordered Dawn</.toast>
    <.toast variant="bordered" color="primary">Toast bordered Primary</.toast>
    <.toast variant="bordered" color="secondary">Toast bordered Secondary</.toast>
    """
  end

  defp code_string(5) do
    """
    <.toast variant="gradient" color="natural">Toast gradient White</.toast>
    <.toast variant="gradient" color="dark">Toast gradient Dark</.toast>
    <.toast variant="gradient" color="info">Toast gradient Info</.toast>
    <.toast variant="gradient" color="success">Toast gradient Success</.toast>
    <.toast variant="gradient" color="warning">Toast gradient Warning</.toast>
    <.toast variant="gradient" color="danger">Toast gradient Danger</.toast>
    <.toast variant="gradient" color="silver">Toast gradient Silver</.toast>
    <.toast variant="gradient" color="misc">Toast gradient Misc</.toast>
    <.toast variant="gradient" color="dawn">Toast gradient Dawn</.toast>
    <.toast variant="gradient" color="primary">Toast gradient Primary</.toast>
    <.toast variant="gradient" color="secondary">Toast gradient Secondary</.toast>
    """
  end

  defp code_string(6) do
    """
    <.toast border="extra_small">Border extra small of Toast</.toast>
    <.toast border="small">Border small of Toast</.toast>
    <.toast border="medium">Border medium of Toast</.toast>
    <.toast border="large">Border large of Toast</.toast>
    <.toast border="extra_large">Border extra large of Toast</.toast>
    """
  end

  defp code_string(7) do
    """
    <.toast rounded="extra_small">Rounded extra small</.toast>
    <.toast rounded="small">Rounded small</.toast>
    <.toast rounded="medium">Rounded medium</.toast>
    <.toast rounded="large">Rounded large</.toast>
    <.toast rounded="extra_large">Rounded extra large</.toast>
    """
  end

  defp code_string(8) do
    """
    <.toast space="extra_small">Space extra small</.toast>
    <.toast space="small">Space small</.toast>
    <.toast space="medium">Space medium</.toast>
    <.toast space="large">Space large</.toast>
    <.toast space="extra_large">Space extra large</.toast>
    <.toast space="none">Space none</.toast>
    """
  end

  defp code_string(9) do
    """
    <.toast padding="extra_small">Padding extra small</.toast>
    <.toast padding="small">Padding small</.toast>
    <.toast padding="medium">Padding medium</.toast>
    <.toast padding="large">Padding large</.toast>
    <.toast padding="extra_large">Padding extra large</.toast>
    <.toast padding="none">Padding none</.toast>
    """
  end

  defp code_string(10) do
    """
    <.toast width="extra_small">Width extra small</.toast>
    <.toast width="small">Width small</.toast>
    <.toast width="medium">Width medium</.toast>
    <.toast width="large">Width large</.toast>
    <.toast width="extra_large">Width extra large</.toast>
    <.toast width="full">Width full</.toast>
    """
  end

  defp code_string(11) do
    """
    <.toast vertical="top">Toast at Top</.toast>
    <.toast vertical="bottom">Toast at Bottom</.toast>
    """
  end

  defp code_string(12) do
    """
    <.toast vertical="top" vertical_space="extra_small"></.toast>
    <.toast vertical="top" vertical_space="small"></.toast>
    <.toast vertical="top" vertical_space="medium"></.toast>
    <.toast vertical="top" vertical_space="large"></.toast>
    <.toast vertical="top" vertical_space="extra_large"></.toast>
    <.toast vertical="bottom" vertical_space="extra_small"></.toast>
    <.toast vertical="bottom" vertical_space="small"></.toast>
    <.toast vertical="bottom" vertical_space="medium"></.toast>
    <.toast vertical="bottom" vertical_space="large"></.toast>
    <.toast vertical="bottom" vertical_space="extra_large"></.toast>
    """
  end

  defp code_string(13) do
    """
    <.toast horizontal="left" vertical="top"></.toast>
    <.toast horizontal="center" vertical="top"></.toast>
    <.toast horizontal="right" vertical="top"></.toast>
    <.toast horizontal="left" vertical="bottom"></.toast>
    <.toast horizontal="center" vertical="bottom"></.toast>
    <.toast horizontal="right" vertical="bottom"></.toast>
    """
  end

  defp code_string(14) do
    """
    <.toast horizontal_space="extra_small" horizontal="left"></.toast>
    <.toast horizontal_space="small"></.toast>
    <.toast horizontal_space="medium" horizontal="center"></.toast>
    <.toast horizontal_space="large"></.toast>
    <.toast horizontal_space="extra_large" horizontal="left"></.toast>
    """
  end

  defp code_string(15) do
    """
    <.toast content_border="extra_small"></.toast>
    <.toast content_border="small"></.toast>
    <.toast content_border="medium"></.toast>
    <.toast content_border="large"></.toast>
    <.toast content_border="extra_large"></.toast>
    <.toast content_border="none"></.toast>
    """
  end

  defp code_string(16) do
    """
    <!--To position the content border, you should add a content border that fits your design.-->
    <.toast content_border="medium" border_position="start"></.toast>
    <.toast content_border="small" border_position="end"></.toast>
    """
  end

  defp code_string(17) do
    """
    <.toast row_direction="none"></.toast>
    <.toast row_direction="reverse"></.toast>
    """
  end

  defp code_string(18) do
    """
    <!--You can omit specifying the fixed prop because it is true by default-->
    <.toast fixed></.toast>
    <.toast fixed={true}></.toast>
    <.toast fixed={false}></.toast>
    """
  end

  defp code_string(19) do
    """
    <.toast font_weight="font-silver"></.toast>
    <.toast font_weight="font-thin"></.toast>
    <.toast font_weight="font-black"></.toast>
    """
  end

  defp code_string(20) do
    """
    <.toast_group>
      <.toast fixed={false}></.toast>
      <.toast fixed={false}></.toast>
      <.toast fixed={false}></.toast>
    </.toast_group>
    """
  end

  defp code_string(21) do
    """
    <.toast_group space="extra_small"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group space="small"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group space="medium"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group space="large"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group space="extra_large"><.toast fixed={false}></.toast></.toast_group>
    """
  end

  defp code_string(22) do
    """
    <.toast_group vertical="top"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group vertical="bottom"><.toast fixed={false}></.toast></.toast_group>
    """
  end

  defp code_string(23) do
    """
    <.toast_group vertical_space="extra_large"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group vertical_space="large"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group vertical_space="medium"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group vertical_space="small"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group vertical_space="extra_small"><.toast fixed={false}></.toast></.toast_group>
    """
  end

  defp code_string(24) do
    """
    <.toast_group horizontal="left"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group horizontal="center"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group horizontal="right"><.toast fixed={false}></.toast></.toast_group>
    """
  end

  defp code_string(25) do
    """
    <.toast_group horizontal_space="extra_small"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group horizontal_space="small"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group horizontal_space="medium"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group horizontal_space="large"><.toast fixed={false}></.toast></.toast_group>
    <.toast_group horizontal_space="extra_large"><.toast fixed={false}></.toast></.toast_group>
    """
  end

  defp code_string(26) do
    """
    <.toast>Toast base color and variant</.toast>
    """
  end

  defp component_config() do
    [
      name: "toast",
      args: [
        variant: ["default", "outline", "shadow", "bordered", "gradient", "base"],
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
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        space: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        type: ["toast", "toast_group"],
        only: ["toast", "toast_group"],
        helpers: [show_toast: 2, hide_toast: 2],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/toast"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Customizable toast notifications in Phoenix LiveView provide seamless, non-intrusive user feedback with flexible options for size, color, and positioning.",
      keywords:
        "phoenix toast component, toast component, liveview toast component, elixir, liveview, mishka chelekom toast component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Toast - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Toast - Chelekom Phoenix & LiveView component",
      og_title: "Toast - Chelekom Phoenix & LiveView component",
      og_description:
        "Customizable toast notifications in Phoenix LiveView provide seamless, non-intrusive user feedback with flexible options for size, color, and positioning.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Toast - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Customizable toast notifications in Phoenix LiveView provide seamless, non-intrusive user feedback with flexible options for size, color, and positioning."
    }
  end
end
