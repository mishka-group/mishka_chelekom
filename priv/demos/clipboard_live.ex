defmodule MishkaWeb.ChelekomLive.Docs.ClipboardLive do
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
    CustomInlineCode
  }

  import MishkaWeb.Components.CustomTab, only: [custom_tab: 1]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Clipboard - Chelekom Phoenix & LiveView component")
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    <.clipboard text="hello@mishka.tools">
      <:trigger>
        <button>Copy Email</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(2) do
    """
    <div id="copy-me">https://mishka.tools/chelekom/docs/clipboard</div>

    <.clipboard target_selector="#copy-me">
      <:trigger>
        <button>Copy Link</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(3) do
    """
    <.clipboard text="https://mishka.tools" timeout={4000}>
      <:trigger>
        <button>Copy URL</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(4) do
    """
    <.clipboard text="Invite Code: CHELEKOM123" success_class="bg-green-500 text-white">
      <:trigger>
        <button class="px-3 py-1 border rounded">Copy Code</button>
      </:trigger>
    </.clipboard>

    <!--Use it inside inline-->
    <p class="text-[14px] leading-8">
      Lorem Ipsum is simply dummy text of the printing and typesetting industry
      <.clipboard class=""
        text="Text you wanna copy"
        show_status_text={false}
        success_class="text-emerald-500 dark:text-emerald-800"
      >
        <:trigger>
          <button class="">
            <span class="mr-1">copy</span>
            <.icon name="hero-clipboard-document-list" class="size-4" />
          </button>
        </:trigger>
      </.clipboard> Lorem Ipsum has been the industry's standard dummy text ever since the 1500s
    </p>
    """
  end

  defp code_string(5) do
    """
    <.clipboard text="this-will-fail!" error_class="bg-red-500 text-white">
      <:trigger>
        <button class="px-3 py-1 border rounded">Copy Text</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(6) do
    """
    <.clipboard text="https://chelekom.tools" copy_success_text="Link copied successfully!">
      <:trigger>
        <button>Copy Link</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(7) do
    """
    <.clipboard text={@maybe_invalid_value} copy_error_text="Oops! Something went wrong.">
      <:trigger>
        <button>Try Copy</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(8) do
    """
    <.clipboard text="shahryar@mishka.tools" copy_button_label="Copy email address to clipboard">
      <:trigger>
        <button aria-hidden="true">📋</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(9) do
    """
    <.clipboard text="shahryar@mishka.tools" copy_button_aria_label="Copy email">
      <:trigger>
        <button aria-hidden="true">📧</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(10) do
    """
    <.clipboard text="shahryar@mishka.tools" copy_button_aria_label="Copy email">
      <:trigger>
        <button aria-hidden="true">📧</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(11) do
    """
    <.clipboard
      text="https://mishka.tools/chelekom/docs"
      text_description="This button copies the documentation link to your clipboard"
    >
      <:trigger>
        <button aria-hidden="true">🔗</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(12) do
    """
    <.clipboard>
      <:content>
        Invite code: <span class="font-mono">CHELEKOM2025</span>
      </:content>
      <:trigger>
        <button>Copy Code</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(13) do
    """
    <.clipboard text="https://mishka.tools/chelekom">
      <:trigger>
        <button class="bg-blue-500 text-white px-3 py-1 rounded">Copy Link</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(14) do
    """
    <.clipboard
      text="mishka.tools"
      copy_success_text="Copied successfully!"
      status_class="text-green-600 font-semibold text-sm mt-1"
    >
      <:trigger>
        <button class="px-3 py-1 border rounded">Copy</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(15) do
    """
    <.clipboard
      text="my-secret-token"
      show_status_text={false}
      success_class="bg-green-500 text-white"
      copy_success_text="Copied!"
    >
      <:trigger>
        <button class="btn btn-primary">Copy</button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(16) do
    """
    <.clipboard
      text="https://mishka.tools/chelekom/docs"
      show_status_text={false}
      success_class="bg-green-500 text-white rounde"
      copy_success_text="✅ Copied!"
      copy_error_text="❌ Failed"
      dynamic_label={true}
    >
      <:trigger>
        <button>
          📋 Copy
        </button>
      </:trigger>
    </.clipboard>
    """
  end

  defp code_string(17) do
    """
    <.clipboard
      content_class="block mt-2"
      >
      <:trigger>
        <button class="btn btn-primary">Copy</button>
      </:trigger>
      <:content>
        Invite code: <span class="font-mono">CHELEKOM2025</span>
      </:content>

    </.clipboard>
    """
  end

  defp component_config() do
    [
      name: "clipboard",
      args: [
        only: ["clipboard"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/clipboard"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Phoenix LiveView copy-to-clipboard component with customizable timeout, dynamic labels, accessibility features, status messages, and copy feedback.",
      keywords:
        "phoenix clipboard component, clipboard component, liveview clipboard component, elixir, liveview, mishka chelekom clipboard component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "clipboard - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "clipboard - Chelekom Phoenix & LiveView component",
      og_title: "clipboard - Chelekom Phoenix & LiveView component",
      og_description:
        "Phoenix LiveView copy-to-clipboard component with customizable timeout, dynamic labels, accessibility features, status messages, and copy feedback.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "clipboard - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Phoenix LiveView copy-to-clipboard component with customizable timeout, dynamic labels, accessibility features, status messages, and copy feedback."
    }
  end
end
