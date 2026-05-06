defmodule MishkaWeb.ChelekomLive.Docs.GetStartedLive do
  use MishkaWeb, :live_view

  import MishkaWeb.Components.{
    CustomNav,
    CustomTableContent,
    CustomBlock,
    CustomMobileNavButton,
    CustomCodeWrapper,
    CustomTypography
  }

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Document - Chelekom Phoenix UIKit and components")
      |> assign(seo_tags: seo_tags())
      |> assign(code_1: code_string(1))
      |> assign(code_2: code_string(2))
      |> assign(code_3: code_string(3))
      |> assign(code_4: code_string(4))
      |> assign(code_5: code_string(5))
      |> assign(code_5: code_string(6))

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp code_string(1) do
    """
    def deps do
      [
        {:mishka_chelekom, "~> 0.0.8", only: :dev}
      ]
    end
    """
  end

  defp code_string(2) do
    """
    mix mishka.ui.gen.component alert
    mix mishka.ui.gen.component alert --color info --variant default
    # For Windows users please use `""` when you have more than
    # one value for an argument
    mix mishka.ui.gen.component alert --color "info,danger"
    """
  end

  defp code_string(3) do
    """
    mix mishka.ui.gen.components
    """
  end

  defp code_string(4) do
    """
    mix mishka.ui.gen.components --import --yes
    # Or you want to install helpers too
    mix mishka.ui.gen.components --import --helpers --yes
    """
  end

  defp code_string(5) do
    """
    # use YourProjectWeb.Components.MishkaComponents
    # lib/your_project_web.ex
    defp html_helpers do
      quote do
        ...

        # Replace Phoenix core components with MishkaComponents
        use YourProjectWeb.Components.MishkaComponents

        # Shortcut for generating JS commands
        alias Phoenix.LiveView.JS

        # Routes generation with the ~p sigil
        unquote(verified_routes())
      end
    end
    """
  end

  defp code_string(6) do
    """
    mix mishka.ui.gen.components --import --helpers --global --yes
    # Or if you have Igniter in your project
    # For more information: https://ash-hq.org/
    mix igniter.new my_app --with phx.new --install mishka_chelekom
    """
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs"

    page_image_url =
      MishkaWeb.Endpoint.url() <> "/images/docs/chelekom/get-started.png"

    %{
      description:
        "Documentation of getting started with Chelekom library to create components and UI kit in Phoenix and Phoenix LiveView",
      keywords:
        "Chelekom documentation, Phoenix components documentation, LiveView components documentation",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Document - Chelekom Phoenix UIKit and components",
      twitter_image_alt: "Document - Chelekom Phoenix UIKit and components",
      og_title: "Document - Chelekom Phoenix UIKit and components",
      og_description:
        "Documentation of getting started with Chelekom library to create components and UI kit in Phoenix and Phoenix LiveView",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Document - Chelekom Phoenix UIKit and components",
      twitter_description:
        "Documentation of getting started with Chelekom library to create components and UI kit in Phoenix and Phoenix LiveView"
    }
  end
end
