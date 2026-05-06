defmodule MishkaWeb.ChelekomLive.Docs.PaginationLive do
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
      |> assign(page_title: "Pagination - Chelekom Phoenix & LiveView component")
      |> assign(seo_tags: seo_tags())
      |> assign(:posts, %{total: 10, active: 1})
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

  def handle_event("pagination", %{"action" => "first"} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 10, active: 1})}
  end

  def handle_event("pagination", %{"action" => "next"} = _params, socket) do
    active = if socket.assigns.posts.active < 10, do: socket.assigns.posts.active + 1, else: 10

    socket =
      socket
      |> assign(:posts, %{total: 10, active: active})

    {:noreply, socket}
  end

  def handle_event("pagination", %{"action" => "select", "page" => page} = _params, socket) do
    socket =
      socket
      |> assign(:posts, %{
        total: 10,
        active: if(is_integer(page) and page > 0 and page <= 10, do: page, else: 1)
      })

    {:noreply, socket}
  end

  def handle_event("pagination", %{"action" => "previous"} = _params, socket) do
    active = if socket.assigns.posts.active <= 1, do: 1, else: socket.assigns.posts.active - 1

    socket =
      socket
      |> assign(:posts, %{total: 10, active: active})

    {:noreply, socket}
  end

  def handle_event("pagination", %{"action" => "last"} = _params, socket) do
    {:noreply, assign(socket, :posts, %{total: 10, active: socket.assigns.posts.total})}
  end

  defp code_string(1) do
    """
    <.pagination variant="default" color="natural" />
    <.pagination variant="default" color="primary" />
    <.pagination variant="default" color="secondary" />
    <.pagination variant="default" color="dark" />
    <.pagination variant="default" color="success" />
    <.pagination variant="default" color="warning" />
    <.pagination variant="default" color="danger" />
    <.pagination variant="default" color="info" />
    <.pagination variant="default" color="silver" />
    <.pagination variant="default" color="misc" />
    <.pagination variant="default" color="dawn" />
    """
  end

  defp code_string(2) do
    """
    <.pagination color="natural" variant="outline" />
    <.pagination color="primary" variant="outline" />
    <.pagination color="secondary" variant="outline" />
    <.pagination color="dark" variant="outline" />
    <.pagination color="success" variant="outline" />
    <.pagination color="warning" variant="outline" />
    <.pagination color="danger" variant="outline" />
    <.pagination color="info" variant="outline" />
    <.pagination color="silver" variant="outline" />
    <.pagination color="misc" variant="outline" />
    <.pagination color="dawn" variant="outline" />
    """
  end

  defp code_string(3) do
    """
    <.pagination color="natural" variant="transparent" />
    <.pagination color="primary" variant="transparent" />
    <.pagination color="secondary" variant="transparent" />
    <.pagination color="dark" variant="transparent" />
    <.pagination color="success" variant="transparent" />
    <.pagination color="warning" variant="transparent" />
    <.pagination color="danger" variant="transparent" />
    <.pagination color="info" variant="transparent" />
    <.pagination color="silver" variant="transparent" />
    <.pagination color="misc" variant="transparent" />
    <.pagination color="dawn" variant="transparent" />
    """
  end

  defp code_string(4) do
    """
    <.pagination color="natural" variant="subtle" />
    <.pagination color="primary" variant="subtle" />
    <.pagination color="secondary" variant="subtle" />
    <.pagination color="success" variant="subtle" />
    <.pagination color="warning" variant="subtle" />
    <.pagination color="danger" variant="subtle" />
    <.pagination color="info" variant="subtle" />
    <.pagination color="silver" variant="subtle" />
    <.pagination color="misc" variant="subtle" />
    <.pagination color="dawn" variant="subtle" />
    """
  end

  defp code_string(5) do
    """
    <.pagination color="natural" variant="shadow" />
    <.pagination color="primary" variant="shadow" />
    <.pagination color="secondary" variant="shadow" />
    <.pagination color="success" variant="shadow" />
    <.pagination color="warning" variant="shadow" />
    <.pagination color="danger" variant="shadow" />
    <.pagination color="info" variant="shadow" />
    <.pagination color="silver" variant="shadow" />
    <.pagination color="misc" variant="shadow" />
    <.pagination color="dawn" variant="shadow" />
    """
  end

  defp code_string(6) do
    """
    <.pagination color="natural" variant="inverted" />
    <.pagination color="primary" variant="inverted" />
    <.pagination color="secondary" variant="inverted" />
    <.pagination color="success" variant="inverted" />
    <.pagination color="warning" variant="inverted" />
    <.pagination color="danger" variant="inverted" />
    <.pagination color="info" variant="inverted" />
    <.pagination color="silver" variant="inverted" />
    <.pagination color="misc" variant="inverted" />
    <.pagination color="dawn" variant="inverted" />
    """
  end

  defp code_string(7) do
    """
    <.pagination rounded="full" />
    <.pagination rounded="extra_small" />
    <.pagination rounded="small" />
    <.pagination rounded="medium" />
    <.pagination rounded="large" />
    <.pagination rounded="extra_large" />
    <.pagination rounded="none" />
    """
  end

  defp code_string(8) do
    """
    <.pagination size="extra_small" />
    <.pagination size="small" />
    <.pagination size="medium" />
    <.pagination size="large" />
    <.pagination size="extra_large" />
    """
  end

  defp code_string(9) do
    """
    <.pagination space="extra_small" />
    <.pagination space="small" />
    <.pagination space="medium" />
    <.pagination space="large" />
    <.pagination space="extra_large" />
    """
  end

  defp code_string(10) do
    """
    <.pagination separator={%{type: :icon, value: "hero-hashtag"}} />
    <.pagination separator={%{type: :text, value: "..."}} />
    """
  end

  defp code_string(11) do
    """
    <.pagination
      next_label={%{type: :icon, value: "hero-chevron-double-right"}}
      previous_label={%{type: :icon, value: "hero-chevron-double-left"}}
    />
    <.pagination
      next_label={%{type: :text, value: "next"}}
      previous_label={%{type: :text, value: "prev"}}
    />
    """
  end

  defp code_string(12) do
    """
    <!--Set show_edges to control first and last pagination visibility-->
    <.pagination
      show_edges
      first_label={%{type: :icon, value: "hero-chevron-left"}}
      last_label={%{type: :icon, value: "hero-chevron-right"}}
    />
    <.pagination
      show_edges
      first_label={%{type: :text, value: "first"}}
      last_label={%{type: :text, value: "last"}}
    />
    """
  end

  defp code_string(13) do
    """
    <.pagination show_edges />
    """
  end

  defp code_string(14) do
    """
    <.pagination hide_controls />
    """
  end

  defp code_string(15) do
    """
    <.pagination total={10}/>
    <.pagination total={posts.total}/>
    """
  end

  defp code_string(16) do
    """
    <.pagination total={10} active={5} />

    <.pagination total={posts.total} active={@posts.active} />
    """
  end

  defp code_string(17) do
    """
    <.pagination total={10} active={5} siblings={2} />
    """
  end

  defp code_string(18) do
    """
    <.pagination total={10} active={5} boundaries={2} />

    <.pagination total={10} active={5} boundaries={10} />
    """
  end

  defp code_string(19) do
    """
    <.pagination color="natural" grouped />
    <.pagination color="primary" grouped />
    <.pagination color="secondary" variant="shadow" grouped />
    <.pagination color="success" variant="inverted" grouped />
    <.pagination color="warning" variant="inverted" grouped />
    <.pagination color="danger" variant="subtle" grouped />
    <.pagination color="info" variant="subtle" grouped />
    <.pagination color="silver" variant="transparent" grouped />
    <.pagination color="misc" variant="transparent" grouped />
    <.pagination color="dawn" variant="bordered" grouped />
    """
  end

  defp code_string(20) do
    """
    <.pagination total={@posts.total} active={@posts.active} siblings={1}>
      <:start_items>First</:start_items>
      <:end_items>Last</:end_items>
    </.pagination>

    <.pagination
      grouped
      total={@posts.total}
      active={@posts.active}
      siblings={3}
    >
      <:start_items>First</:start_items>
      <:end_items>Last</:end_items>
    </.pagination>

    """
  end

  defp code_string(21) do
    """
    <.pagination color="natural" variant="gradient" />
    <.pagination color="primary" variant="gradient" />
    <.pagination color="secondary" variant="gradient" />
    <.pagination color="dark" variant="gradient" />
    <.pagination color="success" variant="gradient" />
    <.pagination color="warning" variant="gradient" />
    <.pagination color="danger" variant="gradient" />
    <.pagination color="info" variant="gradient" />
    <.pagination color="silver" variant="gradient" />
    <.pagination color="misc" variant="gradient" />
    <.pagination color="dawn" variant="gradient" />
    """
  end

  defp code_string(22) do
    """
    <.pagination />
    """
  end

  defp component_config() do
    [
      name: "pagination",
      args: [
        variant: [
          "default",
          "outline",
          "transparent",
          "subtle",
          "shadow",
          "inverted",
          "gradient",
          "bordered",
          "base"
        ],
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
          "dawn",
          "dark",
          "white"
        ],
        size: ["extra_small", "small", "medium", "large", "extra_large"],
        rounded: ["extra_small", "small", "medium", "large", "extra_large", "full", "none"],
        space: ["extra_small", "small", "medium", "large", "extra_large"],
        only: ["pagination"],
        helpers: [],
        module: ""
      ],
      optional: [],
      necessary: []
    ]
  end

  defp seo_tags() do
    page_url = MishkaWeb.Endpoint.url() <> ~p"/chelekom/docs/pagination"

    page_image_url =
      MishkaWeb.Endpoint.url() <>
        "/images/docs/chelekom/#{String.replace(component_config()[:name], "_", "-")}.png"

    %{
      description:
        "Phoenix LiveView pagination with page numbers, ellipses, first, last, and next, previous buttons. Supports various styles and layouts for efficient navigation of large data sets.",
      keywords:
        "phoenix pagination component, pagination component, liveview pagination component, elixir, liveview, mishka chelekom pagination component",
      base: page_url,
      canonical: page_url,
      og_image: page_image_url,
      og_image_alt: "Pagination - Chelekom Phoenix & LiveView component",
      twitter_image_alt: "Pagination - Chelekom Phoenix & LiveView component",
      og_title: "Pagination - Chelekom Phoenix & LiveView component",
      og_description:
        "Phoenix LiveView pagination with page numbers, ellipses, first, last, and next, previous buttons. Supports various styles and layouts for efficient navigation of large data sets.",
      og_type: "article",
      og_url: page_url,
      twitter_image: page_image_url,
      twitter_url: page_url,
      twitter_title: "Pagination - Chelekom Phoenix & LiveView component",
      twitter_description:
        "Phoenix LiveView pagination with page numbers, ellipses, first, last, and next, previous buttons. Supports various styles and layouts for efficient navigation of large data sets."
    }
  end
end
