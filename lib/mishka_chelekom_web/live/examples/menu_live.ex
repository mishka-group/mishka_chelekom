defmodule MishkaChelekomWeb.Examples.MenuLive do
  use Phoenix.LiveView
  use Phoenix.Component

  def mount(_params, _session, socket) do
    list_menues = [
      %{
        id: "Dashaboard",
        navigate: "/",
        title: "Dashaboard",
        size: "extra_small",
        color: "misc",
        variant: "unbordered",
        rounded: "large",
        class: "w-full",
        display: "flex",
        icon_class: "size-5",
        icon: "hero-home",
        active: true
      },
      %{
        id: "Footer",
        navigate: "/examples/footer",
        title: "Footer",
        size: "extra_small",
        color: "misc",
        variant: "unbordered",
        rounded: "large",
        class: "w-full",
        display: "flex",
        icon_class: "size-5",
        icon: "hero-server"
      },
      %{
        id: "Menu-item",
        title: "Menu item",
        padding: "pl-5 space-y-3 mt-3",
        size: "extra_small",
        rounded: "large",
        color: "misc",
        variant: "menu",
        icon: "hero-bookmark",
        icon_class: "size-5",
        sub_items: [
          %{
            navigate: "/examples/indicator",
            title: "Indicator",
            size: "extra_small",
            color: "misc",
            variant: "unbordered",
            rounded: "large",
            class: "w-full",
            display: "flex",
            icon_class: "size-5",
            icon: "hero-scissors"
          },
          %{
            navigate: "/examples/image",
            title: "Image",
            size: "extra_small",
            color: "misc",
            variant: "unbordered",
            rounded: "large",
            class: "w-full",
            display: "flex",
            icon_class: "size-5",
            icon: "hero-scale"
          },
          %{
            navigate: "/examples/rating",
            title: "Rating",
            size: "extra_small",
            color: "misc",
            variant: "unbordered",
            rounded: "large",
            class: "w-full",
            display: "flex",
            icon_class: "size-5",
            icon: "hero-building-storefront"
          },
          %{
            id: "Invoice",
            title: "Invoice",
            variant: "menu",
            padding: "pl-5 space-y-3 mt-3",
            size: "extra_small",
            rounded: "large",
            color: "misc",
            icon: "hero-bookmark",
            icon_class: "size-5",
            sub_items: [
              %{
                navigate: "/examples/popover",
                title: "Popover",
                size: "extra_small",
                color: "misc",
                variant: "unbordered",
                rounded: "large",
                class: "w-full",
                display: "flex",
                icon_class: "size-5",
                icon: "hero-bolt"
              },
              %{
                navigate: "/examples/overlay",
                title: "Overlay",
                size: "extra_small",
                color: "misc",
                variant: "unbordered",
                rounded: "large",
                class: "w-full",
                display: "flex",
                icon_class: "size-5",
                icon: "hero-shopping-bag"
              }
            ]
          }
        ]
      },
      %{
        navigate: "/examples/modal",
        title: "Modal",
        size: "extra_small",
        color: "misc",
        variant: "unbordered",
        rounded: "large",
        class: "w-full",
        display: "flex",
        icon_class: "size-5",
        icon: "hero-bell"
      }
    ]

    {:ok, assign(socket, :list_menues, list_menues)}
  end
end
