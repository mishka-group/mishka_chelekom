defmodule MishkaWeb.ChelekomLive.Docs.ChatLive do
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
      |> assign(page_title: "Chat - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.chat>
      <.chat_section>
        <div>Shahryar Tavakkoli</div>
        <p>Mishka Chelekom is easy to install.</p>
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(2) do
    """
    <.chat>
      <.chat_section>
        <div>Shahryar Tavakkoli</div>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(3) do
    """
    <.chat>
      <.chat_section>
        <div>Shahryar Tavakkoli</div>
        <p>Mishka Chelekom is easy to install.</p>
        <:meta>
          <div class="flex justify-between items-center">
            <div>20:40</div>
            <.icon name="hero-check" />
          </div>
        </:meta>
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(4) do
    """
    <.chat>
      <.chat_section font_weight="font-bold">
        <div>Shahryar Tavakkoli</div>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat>
      <.chat_section font_weight="font-silver">
        <div>Shahryar Tavakkoli</div>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(5) do
    """
    <.chat variant="default" color="natural">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="primary">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="white">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="dark">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="secondary">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="success">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="warning">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="danger">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="info">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="silver">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="misc">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="default" color="dawn">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(6) do
    """
    <.chat color="natural" variant="outline">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="primary" variant="outline">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="secondary" variant="outline">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="success" variant="outline">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="warning" variant="outline">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="danger" variant="outline">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="info" variant="outline">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="silver" variant="outline">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="misc" variant="outline">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="dawn" variant="outline">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(7) do
    """
    <.chat color="natural" variant="shadow">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="primary" variant="shadow">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="secondary" variant="shadow">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="success" variant="shadow">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="warning" variant="shadow">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="danger" variant="shadow">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="info" variant="shadow">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="silver" variant="shadow">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="misc" variant="shadow">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="dawn" variant="shadow">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(8) do
    """
    <.chat color="natural" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="white" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="primary" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="secondary" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="dark" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="success" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="warning" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="danger" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="info" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="silver" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="misc" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="dawn" variant="bordered">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(9) do
    """
    <.chat color="natural" variant="gradient">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="primary" variant="gradient">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="secondary" variant="gradient">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="success" variant="gradient">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="warning" variant="gradient">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="danger" variant="gradient">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="info" variant="gradient">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="silver" variant="gradient">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="misc" variant="gradient">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="dawn" variant="gradient">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(10) do
    """
    <.chat color="natural" variant="transparent">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="primary" variant="transparent">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="secondary" variant="transparent">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="success" variant="transparent">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="warning" variant="transparent">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="danger" variant="transparent">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="info" variant="transparent">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat variant="transparent" color="silver">
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="misc" variant="transparent">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat color="dawn" variant="transparent">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(11) do
    """
    <.chat border="extra_small">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat border="small">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat border="medium">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat border="large">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat border="extra_large">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(12) do
    """
    <.chat rounded="extra_small">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat rounded="small">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat rounded="medium">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat rounded="large">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat rounded="extra_large">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(13) do
    """
    <.chat padding="extra_small">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat padding="small">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat padding="medium">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat padding="large">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat padding="extra_large">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(14) do
    """
    <.chat size="extra_small">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat size="small">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat size="medium">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat size="large">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat size="extra_large">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(15) do
    """
    <.chat space="extra_small">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat space="small">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat space="medium">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat space="large">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat space="extra_large">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(16) do
    """
    <!-- Default is postion="normal", no need to specify it-->
    <.chat postion="normal">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>

    <.chat position="flipped">
      <.chat_section>
        <p>Mishka Chelekom is easy to install.</p>
        <:status time="22:10" deliver="Delivered" />
      </.chat_section>
    </.chat>
    """
  end

  defp code_string(17) do
    """
    <div class="space-y-14 p-5">
      <.chat variant="gradient" color="misc">
        <.avatar
          src={~p"/images/avatar1.jpg"}
          size="medium"
          rounded="full"
          border="small"
          color="silver"
        />
        <.chat_section>
          <div>
            Hey, have you checked out the new Mishka Chelekom UI Kit?
          </div>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>

      <.chat position="flipped" variant="gradient" color="misc">
        <.avatar size="medium" rounded="full" border="small" color="silver">ST</.avatar>
        <.chat_section>
          <div>
            Yeah, I did! The components are
            so easy to integrate with Phoenix LiveView.
          </div>
          <:status time="22:11" deliver="Delivered" />
        </.chat_section>
      </.chat>

      <.chat variant="gradient" color="misc">
        <.avatar
          src={~p"/images/avatar1.jpg"}
          size="medium"
          rounded="full"
          border="small"
          color="silver"
        />
        <.chat_section>
          <div>
            I agree. I used the button component in my project,
            and it works perfectly with the design!
          </div>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>

      <.chat position="flipped" variant="gradient" color="misc">
        <.avatar size="medium" rounded="full" border="small" color="silver">ST</.avatar>
        <.chat_section>
          <div>
            Exactly. The fact that you can adjust the size
            and even add icons made my layout so much cleaner!
          </div>
          <:status time="22:11" deliver="Delivered" />
        </.chat_section>
      </.chat>
    </div>
    """
  end

  defp code_string(18) do
    """
    <!--It's not necessayr to specifiy color and variant as base is the default-->
    <.chat>
      <.chat_section>
        <div>Mona Aghili</div>
        <p>This is base variant of chat component.</p>
      </.chat_section>
    </.chat>
    """
  end

  defp component_config() do
    [
      name: "chat",
      args: [
        variant: ["default", "outline", "transparent", "shadow", "gradient", "bordered", "base"],
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
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        padding: ["extra_small", "small", "medium", "large", "extra_large"],
        type: ["chat", "chat_section"],
        only: ["chat", "chat_section"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/chat"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description: "",
      keywords:
        "phoenix chat component, chat component, liveview chat component, elixir, liveview, mishka chelekom chat component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Chat - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Chat - Chelekom Phoenix & LiveView component",
      og_title: "Chat - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive chat bubbles and chat containers for Phoenix LiveView applications, with customizable styles, colors.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Chat - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive chat bubbles and chat containers for Phoenix LiveView applications, with customizable styles, colors."
    }
  end
end
