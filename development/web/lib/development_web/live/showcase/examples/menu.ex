defmodule DevelopmentWeb.Showcase.Examples.Menu do
  @moduledoc """
  Docs examples for the `menu` component, taken from the Mishka source docs
  (`mishka/.../docs/menu_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  `navigate={~p"/chelekom/..."}` links from the doc are replaced with `href="#"` so the module is
  self-contained (those routes don't exist in this dev app and would fail `~p` verification).
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "overview", title: "Sidebar menu"},
      %{id: "padding", title: "Padding"},
      %{id: "space", title: "Space"},
      %{id: "menu_items", title: "Menu items with sub menu"},
      %{id: "collapsible", title: "Collapsible menu"}
    ]
  end

  def example(%{section: "overview"} = assigns) do
    ~H"""
    <.menu space="small" class="w-full max-w-xs">
      <li>
        <.button
          display="flex"
          full_width
          size="py-1 px-2"
          icon="hero-home"
          icon_class="size-5"
          content_position="start"
        >
          Dashboard
        </.button>
      </li>

      <li>
        <.collapse id="ex-menu-collapse-1">
          <:trigger>
            <.button
              display="flex"
              full_width
              size="py-1 px-2"
              icon="hero-shopping-cart"
              icon_class="size-5"
              content_position="start"
              content_class="flex justify-between items-center gap-2 w-full"
            >
              E-commerce <.icon name="hero-chevron-down" class="size-4" />
            </.button>
          </:trigger>

          <ul class="pl-5 space-y-3 my-3 pe-4">
            <li>
              <.button_link border="none" full_width href="#">Products</.button_link>
            </li>
            <li>
              <.button_link border="none" full_width href="#">Billings</.button_link>
            </li>
            <li>
              <.button_link border="none" full_width href="#">Invoices</.button_link>
            </li>
          </ul>
        </.collapse>
      </li>

      <li>
        <.button
          display="flex"
          full_width
          size="py-1 px-2"
          icon="hero-envelope-open"
          icon_class="size-5"
          content_position="start"
          content_class="flex justify-between items-center gap-2 w-full"
        >
          <span>Inbox</span>
          <.badge size="w-7 text-[11px] h-5">10</.badge>
        </.button>
      </li>

      <li>
        <.button
          display="flex"
          full_width
          size="py-1 px-2"
          icon="hero-user-group"
          icon_class="size-5"
          content_position="start"
        >
          Users
        </.button>
      </li>

      <li>
        <.button
          display="flex"
          full_width
          icon="hero-cog-6-tooth"
          icon_class="size-5"
          content_position="start"
          size="py-1 px-2"
        >
          Settings
        </.button>
      </li>
    </.menu>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <.menu id="ex-menu-padding" padding="large" class="w-40 mx-auto">
      <li>
        <.button_link
          href="#"
          icon="hero-home"
          class="w-full"
          size="extra_small"
          variant="outline"
          color="warning"
        >
          Home
        </.button_link>
      </li>

      <li>
        <.button_link
          href="#"
          icon="hero-server"
          class="w-full"
          size="extra_small"
          variant="outline"
          color="warning"
        >
          Footer
        </.button_link>
      </li>

      <li>
        <.button_link
          href="#"
          icon="hero-bell"
          class="w-full"
          size="extra_small"
          variant="outline"
          color="warning"
        >
          Modal
        </.button_link>
      </li>
    </.menu>
    """
  end

  def example(%{section: "space"} = assigns) do
    ~H"""
    <.menu id="ex-menu-space" space="small" class="w-52">
      <li>
        <.button_link variant="transparent" color="warning" size="small" href="#" class="w-full">
          Dashboard
        </.button_link>
      </li>

      <li>
        <.button_link variant="transparent" color="warning" size="small" href="#" class="w-full">
          Footer
        </.button_link>
      </li>

      <li>
        <.accordion
          id="ex-menu-space-accordion"
          variant="transparent"
          color="warning"
          size="small"
          padding="small"
        >
          <:item title="Settings">
            <ul class="pl-5 space-y-3 mt-1">
              <li>
                <.button_link
                  variant="transparent"
                  color="warning"
                  size="small"
                  class="w-full"
                  href="#"
                >
                  Account
                </.button_link>
              </li>
            </ul>
          </:item>
        </.accordion>
      </li>

      <li>
        <.button_link variant="transparent" color="warning" size="small" href="#" class="w-full">
          Modal
        </.button_link>
      </li>

      <li>
        <.button_link variant="transparent" color="warning" size="small" href="#" class="w-full">
          List
        </.button_link>
      </li>
    </.menu>
    """
  end

  def example(%{section: "menu_items"} = assigns) do
    ~H"""
    <.menu id="ex-menu-items" space="small" class="w-52">
      <li>
        <.button_link variant="transparent" color="info" size="small" href="#" class="w-full">
          Dashboard
        </.button_link>
      </li>

      <li>
        <.button_link variant="transparent" color="info" size="small" href="#" class="w-full">
          Footer
        </.button_link>
      </li>

      <li>
        <.accordion
          id="ex-menu-items-accordion"
          variant="transparent"
          color="info"
          size="small"
          padding="small"
        >
          <:item title="Settings">
            <ul class="pl-5 space-y-3 mt-1">
              <li>
                <.button_link
                  variant="transparent"
                  color="info"
                  size="small"
                  class="w-full"
                  href="#"
                >
                  Account
                </.button_link>
              </li>
            </ul>
          </:item>
        </.accordion>
      </li>

      <li>
        <.button_link variant="transparent" color="info" size="small" href="#" class="w-full">
          Modal
        </.button_link>
      </li>

      <li>
        <.button_link variant="transparent" color="info" size="small" href="#" class="w-full">
          List
        </.button_link>
      </li>
    </.menu>
    """
  end

  def example(%{section: "collapsible"} = assigns) do
    ~H"""
    <.menu id="ex-menu-collapsible" space="small" class="w-52">
      <li>
        <.button_link variant="transparent" color="primary" size="small" href="#" class="w-full">
          Dashboard
        </.button_link>
      </li>

      <li>
        <.button_link variant="transparent" color="primary" size="small" href="#" class="w-full">
          Footer
        </.button_link>
      </li>

      <li>
        <.accordion
          id="ex-menu-collapsible-accordion"
          variant="transparent"
          color="primary"
          size="small"
          padding="small"
        >
          <:item title="Settings">
            <ul class="pl-5 space-y-3 mt-1">
              <li>
                <.button_link
                  variant="transparent"
                  color="primary"
                  size="small"
                  class="w-full"
                  href="#"
                >
                  Account
                </.button_link>
              </li>

              <li>
                <.button_link
                  variant="transparent"
                  color="primary"
                  size="small"
                  class="w-full"
                  href="#"
                >
                  Profile
                </.button_link>
              </li>
            </ul>
          </:item>
        </.accordion>
      </li>

      <li>
        <.button_link variant="transparent" color="primary" size="small" href="#" class="w-full">
          Modal
        </.button_link>
      </li>

      <li>
        <.button_link variant="transparent" color="primary" size="small" href="#" class="w-full">
          List
        </.button_link>
      </li>
    </.menu>
    """
  end

  def example(assigns), do: ~H""
end
