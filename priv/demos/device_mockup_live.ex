defmodule MishkaWeb.ChelekomLive.Docs.DeviceMockupLive do
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
    CustomBlock,
    CustomComponentList
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Device Mockups - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <!--The default type is iPhone, so you can skip specifying it.-->
    <.device_mockup image="/path" />
    """
  end

  defp code_string(2) do
    """
    <.device_mockup image="/path" type="android" />
    """
  end

  defp code_string(3) do
    """
    <.device_mockup image="/path" type="watch" />
    """
  end

  defp code_string(4) do
    """
    <.device_mockup image="/path" type="ipad" />
    """
  end

  defp code_string(5) do
    """
    <.device_mockup image="/path" type="laptop" />
    """
  end

  defp code_string(6) do
    """
    <.device_mockup image="/path" type="imac" />
    """
  end

  defp code_string(7) do
    """
    <.device_mockup image="/path" image_class="your_classes" />
    """
  end

  defp code_string(8) do
    """
    <.device_mockup>
      <div class="bg-white h-full pt-8 pb-2 px-1 space-y-3">
        <div class="space-y-1">
          <label class="text-sm font-medium">Name</label>
          <input class="rounded-lg border bg-gray-200"  placeholder="Enter your name"/>
        </div>
        <div class="space-y-1">
          <label class="text-sm font-medium">Family</label>
          <input class="rounded-lg border bg-gray-200" placeholder="Enter your family">
        </div>
        <div class="space-y-1">
          <label class="text-sm font-medium">Job title</label>
          <input class="rounded-lg border bg-gray-200" placeholder="Enter your job title" />
        </div>
        <div class="space-y-1">
          <label class="text-sm font-medium">Graduation Date</label>
          <input class="rounded-lg border bg-gray-200" placeholder="Select a date" />
          </div>
        <div class="space-y-5">
          <div class="text-xs">By signing up you accepted terms of services</div>
          <button class="p-1 bg-teal-500 text-white rounded-lg">Sign up</button>
        </div>
      </div>
    </.device_mockup>
    """
  end

  defp code_string(9) do
    """
    <.device_mockup type="imac" color="base" />
    <.device_mockup type="imac" color="silver" />
    <.device_mockup type="watch" color="primary" />
    <.device_mockup color="secondary" />
    <.device_mockup type="ipad" color="success" />
    <.device_mockup type="android" color="warning" />
    <.device_mockup color="danger" />
    <.device_mockup type="iphone" color="info" />
    <.device_mockup type="imac" color="natural" />
    <.device_mockup type="android" color="misc" />
    <.device_mockup type="watch" color="dawn" />
    <.device_mockup type="ipad" color="silver" />
    """
  end

  defp component_config() do
    [
      name: "device_mockup",
      args: [
        color: [
          "base",
          "natural",
          "primary",
          "secondary",
          "success",
          "warning",
          "danger",
          "info",
          "misc",
          "dawn",
          "silver"
        ],
        type: ["watch", "android", "laptop", "ipad", "imac"],
        only: ["device_mockup"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: ["image"]
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/device-mockup"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "DeviceMockup component provides customizable mockups for devices like iPhone, Android, iPad, and more, with support for various color themes.",
      keywords:
        "phoenix device mockup component, device mockup component, liveview device mockup component, elixir, liveview, mishka chelekom device mockup component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Device Mockups - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Device Mockups - Chelekom Phoenix & LiveView component",
      og_title: "Device Mockups - Chelekom Phoenix & LiveView component",
      og_description:
        "DeviceMockup component provides customizable mockups for devices like iPhone, Android, iPad, and more, with support for various color themes.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Device Mockups - Chelekom Phoenix & LiveView component",
      twitter_description:
        "DeviceMockup component provides customizable mockups for devices like iPhone, Android, iPad, and more, with support for various color themes."
    }
  end
end
