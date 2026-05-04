defmodule MishkaWeb.ChelekomLive.Docs.StepperLive do
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
      |> assign(page_title: "Stepper - Chelekom Phoenix & LiveView component")
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
    <.stepper variant="default" color="natural"></.stepper>
    <.stepper variant="default" color="primary"></.stepper>
    <.stepper variant="default" color="secondary"></.stepper>
    <.stepper variant="default" color="success"></.stepper>
    <.stepper variant="default" color="warning"></.stepper>
    <.stepper variant="default" color="danger"></.stepper>
    <.stepper variant="default" color="info"></.stepper>
    <.stepper variant="default" color="silver"></.stepper>
    <.stepper variant="default" color="misc"></.stepper>
    <.stepper variant="default" color="dawn"></.stepper>
    """
  end

  defp code_string(2) do
    """
    <.stepper size="extra_small"></.stepper>
    <.stepper size="small"></.stepper>
    <.stepper size="medium"></.stepper>
    <.stepper size="large"></.stepper>
    <.stepper size="extra_large"></.stepper>
    """
  end

  defp code_string(3) do
    """
    <.stepper border="extra_small"></.stepper>
    <.stepper border="small"></.stepper>
    <.stepper border="medium"></.stepper>
    <.stepper border="large"></.stepper>
    <.stepper border="extra_large"></.stepper>
    """
  end

  defp code_string(4) do
    """
    <.stepper vertical>
      <.stepper_section title="Step one" vertical />
      <.stepper_section title="Step two" vertical />
      <.stepper_section title="Step three" vertical />
    </.stepper>
    """
  end

  defp code_string(5) do
    """
    <.stepper margin="extra_small"></.stepper>
    <.stepper margin="small"></.stepper>
    <.stepper margin="medium"></.stepper>
    <.stepper margin="large"></.stepper>
    <.stepper margin="extra_large"></.stepper>
    """
  end

  defp code_string(6) do
    """
    <.stepper space="extra_small" vertical>
      <.stepper_section title="Step one" vertical />
    </.stepper>

    <.stepper spce="small" vertical>
      <.stepper_section title="Step one" vertical />
    </.stepper>

    <.stepper spce="medium" vertical>
      <.stepper_section title="Step one" vertical />
    </.stepper>

    <.stepper spce="large" vertical>
      <.stepper_section title="Step one" vertical />
    </.stepper>

    <.stepper spce="extra_large" vertical>
      <.stepper_section title="Step one" vertical />
    </.stepper>
    """
  end

  defp code_string(7) do
    """
    <.stepper font_weight="font-light" >
      <.stepper_section title="Step one" description="This is description" />
    </.stepper>
    """
  end

  defp code_string(8) do
    """
    <.stepper>
      <.stepper_section title="Section one" />
      <.stepper_section title="Section two" />
      <.stepper_section title="Section three" />
    </.stepper>

    <.stepper vertical>
      <.stepper_section title="Section one" vertical />
      <.stepper_section title="Section two" vertical />
      <.stepper_section title="Section three" vertical />
    </.stepper>
    """
  end

  defp code_string(9) do
    """
    <.stepper>
      <.stepper_section title="Section one" icon="hero-bell-alert" />
      <.stepper_section title="Section two" icon="hero-home" />
      <.stepper_section title="Section three" icon="hero-bell" />
    </.stepper>
    """
  end

  defp code_string(10) do
    """
    <.stepper>
      <.stepper_section title="Section one" />
      <.stepper_section title="Section two" />
      <.stepper_section title="Section three" />
    </.stepper>

    <.stepper vertical>
      <.stepper_section title="Section one" vertical />
      <.stepper_section title="Section two" vertical />
      <.stepper_section title="Section three" vertical />
    </.stepper>
    """
  end

  defp code_string(11) do
    """
    <.stepper>
      <.stepper_section
        title="Section one"
        description="This is the first step of the process."
      />
      <.stepper_section
        title="Section two"
        description="This is the second step of the process."
      />
      <.stepper_section
        title="Section three"
        description="This is the third step of the process."
      />
    </.stepper>

    <.stepper vertical>
      <.stepper_section
        title="Section one"
        description="This is the first step of the vertical process."
        vertical
      />
      <.stepper_section
        title="Section two"
        description="This is the second step of the vertical process."
        vertical
      />
      <.stepper_section
        title="Section three"
        description="This is the third step of the vertical process."
        vertical
      />
    </.stepper>
    """
  end

  defp code_string(12) do
    """
    <.stepper size="extra_small" color="info">
      <.stepper_section
        title="one"
        step="completed"
        />
        <.stepper_section
        title="two"
        step="canceled"
        />
        <.stepper_section
        title="three"
        step="current"
      />
      <.stepper_section
        title="four"
        step="none"
      />
    </.stepper>

    <.stepper size="extra_small" color="success">
      <.stepper_section
        step="compeleted"
        title="one"
      />
      <.stepper_section
        title="two"
        step="canceled"
        step="loading"
      />
      <.stepper_section
        title="three"
        step="current"
      />
      <.stepper_section
        title="four"
        step="none"
      />
    </.stepper>
    """
  end

  defp code_string(13) do
    """
     <.stepper size="extra_small" color="misc">
      <.stepper_section
        title="one"
        step_number={1}
      />
      <.stepper_section
        title="two"
        step_number={2}
      />
      <.stepper_section
        title="three"
        step_number={3}
      />
      <.stepper_section
        title="four"
        step_number={4}
      />
    </.stepper>
    """
  end

  defp code_string(14) do
    """
    <.stepper>
      <.stepper_section title="one" clickable={false} />
      <.stepper_section title="two" clickable={false} />
      <.stepper_section title="three" clickable={false} />
      <.stepper_section title="four" />
    </.stepper>
    """
  end

  defp code_string(15) do
    """
    <.stepper size="small">
      <.stepper_section title="one" reverse />
      <.stepper_section title="two" reverse />
      <.stepper_section title="three" reverse />
      <.stepper_section title="four" reverse />
    </.stepper>
    """
  end

  defp code_string(16) do
    """
    <.stepper variant="gradient" color="natural"></.stepper>
    <.stepper variant="gradient" color="primary"></.stepper>
    <.stepper variant="gradient" color="secondary"></.stepper>
    <.stepper variant="gradient" color="success"></.stepper>
    <.stepper variant="gradient" color="warning"></.stepper>
    <.stepper variant="gradient" color="danger"></.stepper>
    <.stepper variant="gradient" color="info"></.stepper>
    <.stepper variant="gradient" color="silver"></.stepper>
    <.stepper variant="gradient" color="misc"></.stepper>
    <.stepper variant="gradient" color="dawn"></.stepper>
    """
  end

  defp code_string(17) do
    """
    <.stepper col_step col_step_position="start"></.stepper>
    <.stepper col_step col_step_position="end"></.stepper>
    <.stepper col_step col_step_position="center"></.stepper>
    """
  end

  defp code_string(18) do
    """
    <.stepper></.stepper>
    """
  end

  defp component_config() do
    [
      name: "stepper",
      args: [
        variant: ["default", "gradient", "base"],
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
          "dawn"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        type: ["stepper", "stepper_section"],
        only: ["stepper", "stepper_section"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/stepper"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive stepper component for Phoenix LiveView, perfect for displaying multi-step workflows with customizable layouts and styles.",
      keywords:
        "phoenix stepper component, stepper component, liveview stepper component, elixir, liveview, mishka chelekom stepper component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Stepper - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Stepper - Chelekom Phoenix & LiveView component",
      og_title: "Stepper - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive stepper component for Phoenix LiveView, perfect for displaying multi-step workflows with customizable layouts and styles.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Stepper - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive stepper component for Phoenix LiveView, perfect for displaying multi-step workflows with customizable layouts and styles."
    }
  end
end
