defmodule MishkaWeb.ChelekomLive.Docs.ModalLive do
  use MishkaWeb, :live_view
  alias MishkaWeb.Components.Modal

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
      |> assign(page_title: "Modal - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_6: code_string(6))
      |> assign(code_7: code_string(7))
      |> assign(code_8: code_string(8))
      |> assign(code_9: code_string(9))
      |> assign(code_10: code_string(10))
      |> assign(code_11: code_string(11))
      |> assign(code_12: code_string(12))
      |> assign(code_13: code_string(13))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.modal id="uniqu_id" variant="default" color="natual"></.modal>
    <.modal id="uniqu_id" variant="default" color="white"></.modal>
    <.modal id="uniqu_id" variant="default" color="primary"></.modal>
    <.modal id="uniqu_id" variant="default" color="secondary"></.modal>
    <.modal id="uniqu_id" variant="default" color="dark"></.modal>
    <.modal id="uniqu_id" variant="default" color="success"></.modal>
    <.modal id="uniqu_id" variant="default" color="warning"></.modal>
    <.modal id="uniqu_id" variant="default" color="danger"></.modal>
    <.modal id="uniqu_id" variant="default" color="info"></.modal>
    <.modal id="uniqu_id" variant="default" color="misc"></.modal>
    <.modal id="uniqu_id" variant="default" color="dawn"></.modal>
    <.modal id="uniqu_id" variant="default" color="silver"></.modal>
    """
  end

  defp code_string(3) do
    """
    <.modal id="uniqu_id" color="natural" variant="shadow"></.modal>
    <.modal id="uniqu_id" color="primary" variant="shadow"></.modal>
    <.modal id="uniqu_id" color="secondary" variant="shadow"></.modal>
    <.modal id="uniqu_id" color="success" variant="shadow"></.modal>
    <.modal id="uniqu_id" color="warning" variant="shadow"></.modal>
    <.modal id="uniqu_id" color="danger" variant="shadow"></.modal>
    <.modal id="uniqu_id" color="info" variant="shadow"></.modal>
    <.modal id="uniqu_id" color="misc" variant="shadow"></.modal>
    <.modal id="uniqu_id" color="dawn" variant="shadow"></.modal>
    <.modal id="uniqu_id" color="silver" variant="shadow"></.modal>
    """
  end

  defp code_string(4) do
    """
    <.modal id="uniqu_id" color="white" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="natural" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="primary" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="secondary" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="dark" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="success" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="warning" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="danger" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="info" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="misc" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="dawn" variant="bordered"></.modal>
    <.modal id="uniqu_id" color="silver" variant="bordered"></.modal>
    """
  end

  defp code_string(6) do
    """
    <.modal id="uniqu_id" padding="extra_small">Extra small padding</.modal>
    <.modal id="uniqu_id" padding="small">Small padding</.modal>
    <.modal id="uniqu_id" padding="medium">Medium padding</.modal>
    <.modal id="uniqu_id" padding="large">Large padding</.modal>
    <.modal id="uniqu_id" padding="extra_large">Extra large padding</.modal>
    <.modal id="uniqu_id" padding="none">No padding</.modal>
    """
  end

  defp code_string(7) do
    """
    <.modal id="uniqu_id" rounded="extra_small">Extra small rounded</.modal>
    <.modal id="uniqu_id" rounded="small">Small rounded</.modal>
    <.modal id="uniqu_id" rounded="medium">Medium rounded</.modal>
    <.modal id="uniqu_id" rounded="large">Large rounded</.modal>
    <.modal id="uniqu_id" rounded="extra_large">Extra large rounded</.modal>
    <.modal id="uniqu_id" rounded="none">No rounded</.modal>
    """
  end

  defp code_string(8) do
    """
    <.modal id="uniqu_id" size="extra_small">Extra small size</.modal>
    <.modal id="uniqu_id" size="small">Small size</.modal>
    <.modal id="uniqu_id" size="medium">Medium size</.modal>
    <.modal id="uniqu_id" size="large">Large size</.modal>
    <.modal id="uniqu_id" size="extra_large">Extra large size</.modal>
    <.modal id="uniqu_id" size="double_large">Double large size</.modal>
    <.modal id="uniqu_id" size="triple_large">Triple large size</.modal>
    <.modal id="uniqu_id" size="quadruple_large">Quadruple large size</.modal>
    <.modal id="uniqu_id" size="screen">Screen size</.modal>
    """
  end

  defp code_string(9) do
    """
    <.modal id="uniqu_id" title="Title of modal"></.modal>
    """
  end

  defp code_string(10) do
    """
    <.modal id="uniqu_id" title="Title of modal" show></.modal>
    <.modal id="uniqu_id" title="Title of modal" show={true}></.modal>
    <.modal id="uniqu_id" title="Title of modal" show={false}></.modal>
    """
  end

  defp code_string(11) do
    """
    <.modal id="uniqu_id" on_cancel={JS.push("close_modal")}>
      <div class="space-y-4">
        <p>
          Are you sure you want to delete this ite?
        </p>
       <div class="flex gap-4 justify-center">
         <.button class="w-full" color="success">
          Yes
        </.button>
         <.button class="w-full" color="danger" on_cancel>
          Cancel
        </.button>
       </div>
      </div>
    </.modal>
    """
  end

  defp code_string(12) do
    """
    <.modal id="uniqu_id" color="natural" variant="gradient"></.modal>
    <.modal id="uniqu_id" color="primary" variant="gradient"></.modal>
    <.modal id="uniqu_id" color="secondary" variant="gradient"></.modal>
    <.modal id="uniqu_id" color="success" variant="gradient"></.modal>
    <.modal id="uniqu_id" color="warning" variant="gradient"></.modal>
    <.modal id="uniqu_id" color="danger" variant="gradient"></.modal>
    <.modal id="uniqu_id" color="info" variant="gradient"></.modal>
    <.modal id="uniqu_id" color="misc" variant="gradient"></.modal>
    <.modal id="uniqu_id" color="dawn" variant="gradient"></.modal>
    <.modal id="uniqu_id" color="silver" variant="gradient"></.modal>
    """
  end

  defp code_string(13) do
    """
    <.modal id="uniqu_id"></.modal>
    """
  end

  defp component_config() do
    [
      name: "modal",
      args: [
        variant: ["default", "shadow", "bordered", "gradient", "base"],
        color: [
          "base",
          "white",
          "natural",
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
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        size: [
          "extra_small",
          "small",
          "medium",
          "large",
          "extra_large",
          "double_large",
          "triple_large",
          "quadruple_large",
          "screen"
        ],
        only: ["modal"],
        helpers: [show_modal: 2, hide_modal: 2],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/modal"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive modals for Phoenix and Phoenix LiveView, enabling dynamic content display with customizable styles and full-screen mode.",
      keywords:
        "phoenix modal component, modal component, liveview modal component, elixir, liveview, mishka chelekom modal component",
      base: MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/modal",
      canonical: MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/modal",
      og_image: page_image_url,
      og_image_alt: "Modal - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Modal - Chelekom Phoenix & LiveView component",
      og_title: "Modal - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive modals for Phoenix and Phoenix LiveView, enabling dynamic content display with customizable styles and full-screen mode.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Modal - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive modals for Phoenix and Phoenix LiveView, enabling dynamic content display with customizable styles and full-screen mode."
    }
  end
end
