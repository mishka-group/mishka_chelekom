defmodule MishkaWeb.ChelekomLive.Docs.FormsLive do
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
      |> assign(page_title: "Forms - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.text_field variant="outline" color="silver" />
    <.text_field variant="outline" color="white" />
    <.text_field variant="outline" color="primary" />
    <.text_field variant="outline" color="secondary" />
    <.text_field variant="outline" color="dark" />
    <.text_field variant="outline" color="success" />
    <.text_field variant="outline" color="warning" />
    <.text_field variant="outline" color="danger" />
    <.text_field variant="outline" color="info" />
    <.text_field variant="outline" color="light" />
    <.text_field variant="outline" color="misc" />
    <.text_field variant="outline" color="dawn" />
    """
  end

  defp code_string(2) do
    """
    <.text_field variant="default" color="white" />
    <.email_field variant="default" color="primary" />
    <.textarea_field variant="default" color="secondary" />
    <.text_field variant="default" color="dark" />
    <.text_field variant="default" color="success" />
    <.textarea_field variant="default" color="warning" />
    <.tel_field variant="default" color="danger" />
    <.text_field variant="default" color="info" />
    <.text_field variant="default" color="light" />
    <.email_field variant="default" color="misc" />
    <.tel_field variant="default" color="dawn" />
    """
  end

  defp code_string(3) do
    """
    <.text_field variant="shadow" color="white" />
    <.text_field variant="shadow" color="primary" />
    <.textarea_field variant="shadow" color="secondary" />
    <.text_field variant="shadow" color="dark" />
    <.text_field variant="shadow" color="success" />
    <.number_field variant="shadow" color="warning" />
    <.text_field variant="shadow" color="danger" />
    <.email_field variant="shadow" color="info" />
    <.tel_field variant="shadow" color="light" />
    <.text_field variant="shadow" color="misc" />
    <.text_field variant="shadow" color="dawn" />
    """
  end

  defp code_string(4) do
    """
    <.text_field variant="unbordered" color="white" />
    <.text_field variant="unbordered" color="primary" />
    <.textarea_field variant="unbordered" color="secondary" />
    <.tel_field variant="unbordered" color="dark" />
    <.text_field variant="unbordered" color="success" />
    <.email_field variant="unbordered" color="warning" />
    <.text_field variant="unbordered" color="danger" />
    <.text_field variant="unbordered" color="info" />
    <.text_field variant="unbordered" color="light" />
    <.number_field variant="unbordered" color="misc" />
    <.text_field variant="unbordered" color="dawn" />
    """
  end

  defp code_string(5) do
    """
    <.text_field variant="transparent" color="white" />
    <.text_field variant="transparent" color="primary" />
    <.email_field variant="transparent" color="secondary" />
    <.text_field variant="transparent" color="dark" />
    <.text_field variant="transparent" color="success" />
    <.text_field variant="transparent" color="warning" />
    <.number_field variant="transparent" color="danger" />
    <.text_field variant="transparent" color="info" />
    <.number_field variant="transparent" color="light" />
    <.tel_field variant="transparent" color="misc" />
    <.textarea_field variant="transparent" color="dawn" />
    """
  end

  defp code_string(6) do
    """
    <.text_field rounded="extra_small" />
    <.text_field rounded="small" />
    <.email_field rounded="medium" />
    <.text_field rounded="large" />
    <.url_field rounded="extra_large" />
    <.number_field rounded="full" />
    """
  end

  defp code_string(7) do
    """
    <.text_field border="extra_small" />
    <.email_field border="small" />
    <.text_field border="medium" />
    <.number_field border="large" />
    <.text_field border="extra_large" />
    """
  end

  defp code_string(8) do
    """
    <.url_feild size="extra_small" />
    <.text_field size="small" />
    <.email_field size="medium" />
    <.email_field size="large" />
    <.tel_field size="extra_large" />
    """
  end

  defp code_string(9) do
    """
    <.text_field space="extra_small" />
    <.text_field space="small" />
    <.text_field space="medium" />
    <.text_field space="large" />
    <.text_field space="extra_large" />
    """
  end

  defp code_string(10) do
    """
    <.text_field ring />
    """
  end

  defp code_string(11) do
    """
    <.text_field floating="none" />
    <.text_field floating="inner" />
    <.text_field floating="outer" />
    """
  end

  defp code_string(12) do
    """
    <!--you can use any hero-icons icon -->
    <.text_field error_icon="hero-shield-exclamation" />
    """
  end

  defp code_string(13) do
    """
    <.text_field labe="field_label" />
    """
  end

  defp code_string(14) do
    """
    <.text_field description="field_description" />
    <.number_field description="field_description" />
    <.url_field description="field_description" />
    <.email_field description="field_description" />
    <.textarea_field description="field_description" />
    """
  end

  defp code_string(15) do
    """
    <.text_field name="field_name" />
    <.email_field name="field_name" />
    <.number_field name="field_name" />
    """
  end

  defp code_string(16) do
    """
    <.text_field value="field_value" />

    <.text_field value="" />
    """
  end

  defp code_string(17) do
    """
    <.text_field errors={["Invalid email"]} />
    """
  end

  defp code_string(18) do
    """
    <.tel_field>
      <:start_section>
        +31
      </:start_section>
    </.tel_field>

    <.tel_field>
      <:start_section>
        <.icon name="hero-user" class="your_classes" />
      </:start_section>
    </.tel_field>


    <.email_field>
      <:start_section>
        <.icon name="hero-envelope" class="your_classes" />
      </:start_section>
    </.email_field>
    """
  end

  defp code_string(19) do
    """
    <.form_wrapper for={@form}>
      <div class="grid lg:grid-cols-2 gap-2">
        <.text_field
          name="name1"
          value=""
          space="small"
          color="light"
          label="Name"
          placeholder="Enter your name"
        />
        <.text_field
          name="name1"
          value=""
          space="small"
          color="light"
          label="Family"
          placeholder="Enter your family"
        />
        <.email_field
          name="name1"
          value=""
          space="small"
          color="light"
          label="Email"
          placeholder="Enter your rmail"
        />
      </div>
    </.form_wrapper>
    """
  end

  defp code_string(20) do
    """
    <.text_field />
    <.email_field />
    <.native_select />
    <.password_field />
    """
  end

  defp component_config() do
    [
      name: "form_wrapper",
      args: [
        variant: ["default", "outline", "transparent", "shadow", "unbordered", "base"],
        color: [
          "base",
          "white",
          "primary",
          "secondary",
          "dark",
          "success",
          "warning",
          "danger",
          "info",
          "light",
          "misc",
          "dawn",
          "silver"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
        padding: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["form_wrapper", "simple_form"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/forms"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Form components for Phoenix and Phoenix LiveView, featuring floating labels and various input styles.",
      keywords:
        "phoenix forms component, forms component, liveview forms component, elixir, liveview, mishka chelekom forms component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Forms - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Forms - Chelekom Phoenix & LiveView component",
      og_title: "Forms - Chelekom Phoenix & LiveView component",
      og_description:
        "Form components for Phoenix and Phoenix LiveView, featuring floating labels and various input styles.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Forms - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Form components for Phoenix and Phoenix LiveView, featuring floating labels and various input styles."
    }
  end
end
