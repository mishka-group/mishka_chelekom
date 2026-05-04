defmodule MishkaWeb.ChelekomLive.Docs.RatingLive do
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

  defmodule Review do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field(:fullname, :string)
      field(:rating, :float)
      field(:comment, :string)
    end

    @required_fields ~w(fullname)a

    def changeset(review, attrs) do
      review
      |> cast(attrs, @required_fields ++ [:rating, :comment])
      |> validate_required(@required_fields)
      |> validate_length(:fullname, min: 3, max: 70)
      |> validate_number(:rating, greater_than_or_equal_to: 0, less_than_or_equal_to: 5)
      |> validate_length(:comment, max: 500)
    end
  end

  def mount(_params, _session, socket) do
    init_form = Review.changeset(%Review{}, %{"rating" => "0"})

    socket =
      socket
      |> assign(page_title: "Rating - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(star: 3)
      |> assign(half_star: 2.5)
      |> assign(half_star_primary: 3.5)
      |> assign(half_star_danger: 1.5)
      |> assign(half_star_success: 4.5)
      |> assign(:form, to_form(init_form))
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

    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "rating",
        %{"action" => "select", "number" => number, "target" => "precision-" <> color},
        socket
      )
      when is_number(number) do
    key = String.to_existing_atom("half_star_#{color}")
    {:noreply, assign(socket, [{key, number}])}
  end

  def handle_event(
        "rating",
        %{"action" => "select", "number" => number, "target" => "precision"},
        socket
      )
      when is_number(number) do
    {:noreply, assign(socket, half_star: number)}
  end

  def handle_event("rating", %{"action" => "select", "number" => number} = _params, socket)
      when is_number(number) do
    {:noreply, assign(socket, star: number)}
  end

  def handle_event("rating", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("validate", %{"review" => review_params}, socket) do
    changeset = Review.changeset(%Review{}, review_params)

    new_socket =
      socket
      |> assign(:form, to_form(changeset, action: :validate))

    {:noreply, new_socket}
  end

  def handle_event("save", %{"review" => review_params}, socket) do
    changeset = Review.changeset(%Review{}, review_params)

    case Ecto.Changeset.apply_action(changeset, :update) do
      {:ok, _review} ->
        reset_changeset = Review.changeset(%Review{}, %{"rating" => "0"})

        new_socket =
          socket
          |> assign(form: to_form(reset_changeset))
          |> put_flash(:info, "Review submitted successfully!")

        {:noreply, new_socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp code_string(1) do
    """
    <.rating interactive />
    """
  end

  defp code_string(2) do
    """
    <.rating count={6} />
    <.rating count={8} />
    """
  end

  defp code_string(3) do
    """
    <.rating />
    <.rating select={3} />
    <.rating select={5} />
    """
  end

  defp code_string(4) do
    """
    <.rating color="base" />
    <.rating color="natural" />
    <.rating color="white" />
    <.rating color="primary" />
    <.rating color="secondary" />
    <.rating color="success" />
    <.rating color="warning" />
    <.rating color="danger" />
    <.rating color="info" />
    <.rating color="misc" />
    <.rating color="dawn" />
    <.rating color="silver" />
    <.rating color="dark" />
    """
  end

  defp code_string(5) do
    """
    <.rating gap="extra_small" />
    <.rating gap="small" />
    <.rating gap="medium" />
    <.rating gap="large" />
    <.rating gap="extra_large" />
    """
  end

  defp code_string(6) do
    """
    <.rating size="extra_small" />
    <.rating size="small" />
    <.rating size="medium" />
    <.rating size="large" />
    <.rating size="extra_large" />
    <.rating size="double_large" />
    <.rating size="triple_large" />
    <.rating size="quadruple_large" />
    """
  end

  defp code_string(7) do
    """
    <.rating field={@form[:rating]} size="large" color="warning" />
    """
  end

  defp code_string(8) do
    """
    <.form_wrapper for={@form} id="review-form" phx-change="validate" phx-submit="save" space="medium">
      <.text_field size="medium" field={@form[:fullname]} label="Full Name" />
      <.rating field={@form[:rating]} label="Your Rating" size="large" color="warning" precision={0.5} />
      <.textarea_field size="medium" field={@form[:comment]} label="Comment (optional)" />
      <:actions>
        <.button variant="outline" color="info" size="small" phx-disable-with="Submitting...">
          Submit Review
        </.button>
      </:actions>
    </.form_wrapper>
    """
  end

  defp code_string(9) do
    """
    <.rating select={3} size="large" disabled />
    <.rating select={2} size="large" interactive disabled />
    """
  end

  defp code_string(10) do
    """
    <.rating
      id="rating-precision"
      select={2.5}
      size="large"
      color="warning"
      precision={0.5}
      interactive
    />
    """
  end

  defp component_config() do
    [
      name: "rating",
      args: [
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
        size: [
          "extra_small",
          "small",
          "medium",
          "large",
          "extra_large",
          "double_large",
          "triple_large",
          "quadruple_large"
        ],
        only: ["rating"],
        helpers: [rating_select: 2],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/rating"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Interactive rating component for Phoenix LiveView with customizable stars, colors, sizes, hover effects, and native Phoenix form integration via the field prop.",
      keywords:
        "phoenix rating component, rating component, liveview rating component, elixir, liveview, mishka chelekom rating component, phoenix form rating",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Rating - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Rating - Chelekom Phoenix & LiveView component",
      og_title: "Rating - Chelekom Phoenix & LiveView component",
      og_description:
        "Interactive rating component for Phoenix LiveView with customizable stars, colors, sizes, hover effects, and native Phoenix form integration via the field prop.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Rating - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Interactive rating component for Phoenix LiveView with customizable stars, colors, sizes, hover effects, and native Phoenix form integration via the field prop."
    }
  end
end
