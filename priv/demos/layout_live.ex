defmodule MishkaWeb.ChelekomLive.Docs.LayoutLive do
  use MishkaWeb, :live_view

  import MishkaWeb.Components.{
    CustomNav,
    CustomInfo,
    CustomTableContent,
    CustomTable,
    CustomTypography,
    CustomCodeWrapper,
    CustomCliProps,
    CustomInlineCode
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Layout - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.flex direction="col"></.flex>
    <.flex direction="col"></.flex>
    <.flex direction="col"></.flex>
    <.flex direction="col"></.flex>
    """
  end

  defp code_string(2) do
    """
    <.flex justify="start"></.flex>
    <.flex justify="center"></.flex>
    <.flex justify="end"></.flex>
    <.flex justify="between"></.flex>
    <.flex justify="around"></.flex>
    <.flex justify="evenly"></.flex>
    """
  end

  defp code_string(3) do
    """
    <.flex align="start"></.flex>
    <.flex align="center"></.flex>
    <.flex align="end"></.flex>
    <.flex align="stretch"></.flex>
    <.flex align="baseline"></.flex>
    """
  end

  defp code_string(4) do
    """
    <.flex gap="extra_small"></.flex>
    <.flex gap="small"></.flex>
    <.flex gap="medium"></.flex>
    <.flex gap="large"></.flex>
    <.grid gap="extra_large"></.grid>
    """
  end

  defp code_string(5) do
    """
    <.flex wrap="nowrap"></.flex>
    <.flex wrap="wrap"></.flex>
    <.flex wrap="wrap-reverse"></.flex>
    """
  end

  defp code_string(6) do
    """
    <.flex grow="grow"></.flex>
    <.flex grow="none"></.flex>
    """
  end

  defp code_string(7) do
    """
    <.flex shrink="shrink"></.flex>
    <.flex shrink="none"></.flex>
    """
  end

  defp code_string(8) do
    """
    <.flex basis="extra_small"></.flex>
    <.flex basis="small"></.flex>
    <.flex basis="medium"></.flex>
    <.flex basis="large"></.flex>
    <.flex basis="extra_large"></.flex>
    """
  end

  defp code_string(9) do
    """
    <.flex order="first"></.flex>
    <.grid order="last"></.grid>
    <.flex order="none"></.flex>
    """
  end

  defp code_string(10) do
    """
    <.flex align_self="auto"></.flex>
    <.flex align_self="start"></.flex>
    <.flex align_self="center"></.flex>
    <.flex align_self="end"></.flex>
    <.grid align_self="stretch"></.grid>
    """
  end

  defp code_string(11) do
    """
    <.grid></.grid>
    """
  end

  defp code_string(12) do
    """
    <.flex></.flex>
    """
  end

  defp code_string(13) do
    """
    <.grid cols="one"></.grid>
    <.grid cols="two"></.grid>
    <.grid cols="three"></.grid>
    <.grid cols="four"></.grid>
    <.grid cols="five"></.grid>
    <.grid cols="six"></.grid>
    <.grid cols="seven"></.grid>
    <.grid cols="eight"></.grid>
    <.grid cols="nine"></.grid>
    <.grid cols="ten"></.grid>
    <.grid cols="eleven"></.grid>
    <.grid cols="twelve"></.grid>
    <.grid cols="none"></.grid>
    """
  end

  defp code_string(14) do
    """
    <.grid rows="one"></.grid>
    <.grid rows="two"></.grid>
    <.grid rows="three"></.grid>
    <.grid rows="four"></.grid>
    <.grid rows="five"></.grid>
    <.grid rows="six"></.grid>
    <.grid rows="none"></.grid>
    """
  end

  defp code_string(15) do
    """
    <.grid auto_cols="auto"></.grid>
    <.grid auto_cols="min"></.grid>
    <.grid auto_cols="max"></.grid>
    <.grid auto_cols="fr"></.grid>
    """
  end

  defp code_string(16) do
    """
    <.grid auto_rows="auto"></.grid>
    <.grid auto_rows="min"></.grid>
    <.grid auto_rows="max"></.grid>
    <.grid auto_rows="fr"></.grid>
    """
  end

  defp code_string(17) do
    """
    <.grid auto_flow="row"></.grid>
    <.grid auto_flow="col"></.grid>
    <.grid auto_flow="row-dense"></.grid>
    <.grid auto_flow="col-dense"></.grid>
    """
  end

  defp code_string(18) do
    """
    <.grid justify_self="auto"></.grid>
    <.grid justify_self="start"></.grid>
    <.grid justify_self="end"></.grid>
    <.grid justify_self="center"></.grid>
    <.grid justify_self="stretch"></.grid>
    """
  end

  defp code_string(19) do
    """
    <.grid align_content="start"></.grid>
    <.grid align_content="center"></.grid>
    <.grid align_content="end"></.grid>
    <.grid align_content="between"></.grid>
    <.grid align_content="around"></.grid>
    <.grid align_content="evenly"></.grid>
    """
  end

  defp code_string(20) do
    """
    <.grid place_content="start"></.grid>
    <.grid place_content="center"></.grid>
    <.grid place_content="end"></.grid>
    <.grid place_content="between"></.grid>
    <.grid place_content="around"></.grid>
    <.grid place_content="evenly"></.grid>
    <.grid place_content="stretch"></.grid>
    """
  end

  defp code_string(21) do
    """
    <.grid place_items="start"></.grid>
    <.grid place_items="end"></.grid>
    <.grid place_items="center"></.grid>
    <.grid place_items="stretch"></.grid>
    """
  end

  defp code_string(22) do
    """
    <.grid place_self="auto"></.grid>
    <.grid place_self="start"></.grid>
    <.grid place_self="end"></.grid>
    <.grid place_self="center"></.grid>
    <.grid place_self="stretch"></.grid>
    """
  end

  defp component_config() do
    [
      name: "layout",
      args: [
        type: ["flex", "grid"],
        only: ["flex", "grid"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/layout"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Responsive Phoenix LiveView layout components featuring Flex and Grid systems.",
      keywords:
        "phoenix flex component, phoenix grid component, layout component, liveview layout component, elixir, liveview, mishka chelekom layout component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Layout flex and grid - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Layout flex and grid - Chelekom Phoenix & LiveView component",
      og_title: "Layout flex and grid - Chelekom Phoenix & LiveView component",
      og_description:
        "Responsive Phoenix LiveView layout components featuring Flex and Grid systems.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Layout flex and grid - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Responsive Phoenix LiveView layout components featuring Flex and Grid systems."
    }
  end
end
