defmodule MishkaWeb.ChelekomLive.Docs.CliLive do
  use MishkaWeb, :live_view

  import MishkaWeb.Components.{
    CustomNav,
    CustomTableContent,
    CustomTypography,
    CustomInlineCode,
    CustomCodeWrapper,
    CustomMobileNavButton
  }

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Cli - Chelekom")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    mix mishka.ui.gen.component alert
    mix mishka.ui.gen.component button --size large -c primary
    """
  end

  defp code_string(2) do
    """
    mix mishka.ui.gen.components
    mix mishka.ui.gen.components alert,divider,footer
    mix mishka.ui.gen.components --import --yes

    # Install all components with helper functions and
    # macros for importing, and globally replace them with
    # Phoenix core components (**Recommended**)
    mix mishka.ui.gen.components --import --helpers --global --yes

    # Or if you have Igniter in your project
    # For more information: https://ash-hq.org/
    mix igniter.new my_app --with phx.new --install mishka_chelekom
    """
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/cli"

    page_image_url =
      MishkaWeb.Endpoint.url() <> "/images/docs/chelekom/cli.png"

    %{
      description:
        "CLI generator tool to build Phoenix UI kit and Phoenix LiveView components with elixir mix task",
      keywords: "Phoenix CLI generator, components CLI generator, LiveView CLI, component CLI",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Cli - Mishka Chelekom",
      twitter_image_alt: "",
      og_title: "Cli - Mishka Chelekom",
      og_description:
        "CLI generator tool to build Phoenix UI kit and Phoenix LiveView components with elixir mix task",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Cli - Mishka Chelekom",
      twitter_description:
        "CLI generator tool to build Phoenix UI kit and Phoenix LiveView components with elixir mix task"
    }
  end
end
