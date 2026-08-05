defmodule DevelopmentWeb.Showcase.Examples.Dropdown do
  @moduledoc """
  Docs examples for the `dropdown` component, taken from the Mishka source docs
  (`mishka/.../docs/dropdown_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "color-variants", title: "Color variants"},
      %{id: "smart-position", title: "Smart position"},
      %{id: "position", title: "Position"},
      %{id: "width", title: "Width"},
      %{id: "rounded", title: "Rounded"},
      %{id: "space", title: "Space"},
      %{id: "padding", title: "Padding"},
      %{id: "size", title: "Size"}
    ]
  end

  def example(%{section: "color-variants"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center items-center gap-10">
      <.dropdown
        id="ex-dropdown-bordered"
        space="small"
        rounded="large"
        padding="extra_small"
        variant="bordered"
        color="danger"
      >
        <:trigger>
          <.button variant="outline" color="danger" size="extra_small">
            Bordered danger
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Earning</li>
            <li class="py-1.5 px-2 cursor-pointer">Sign out</li>
          </ul>
        </:content>
      </.dropdown>

      <.dropdown
        id="ex-dropdown-gradient"
        space="small"
        rounded="large"
        padding="extra_small"
        variant="gradient"
        color="misc"
      >
        <:trigger>
          <.button color="misc" variant="outline" size="extra_small">
            Gradient misc
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Earning</li>
            <li class="py-1.5 px-2 cursor-pointer">Sign out</li>
          </ul>
        </:content>
      </.dropdown>

      <.dropdown
        id="ex-dropdown-shadow"
        space="small"
        rounded="large"
        padding="extra_small"
        variant="shadow"
        color="dawn"
      >
        <:trigger>
          <.button variant="outline" color="dawn" size="extra_small">
            Shadow dawn
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Earning</li>
            <li class="py-1.5 px-2 cursor-pointer">Sign out</li>
          </ul>
        </:content>
      </.dropdown>
    </div>
    """
  end

  def example(%{section: "smart-position"} = assigns) do
    ~H"""
    <div class="flex justify-center items-center">
      <.dropdown
        id="ex-dropdown-smart"
        space="small"
        rounded="large"
        width="extra_large"
        smart_position={true}
        padding="extra_small"
      >
        <:trigger>
          <.button size="extra_small">
            Top dropdown
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 transition-all duration-100 hover:text-slate-500 dark:hover:text-slate-300 cursor-pointer">
              Dashboard
            </li>
            <li class="py-1.5 px-2 transition-all duration-100 hover:text-slate-500 dark:hover:text-slate-300 cursor-pointer">
              Settings
            </li>
            <li class="py-1.5 px-2 transition-all duration-100 hover:text-slate-500 dark:hover:text-slate-300 cursor-pointer">
              Earning
            </li>
            <li class="py-1.5 px-2 transition-all duration-100 hover:text-slate-500 dark:hover:text-slate-300 cursor-pointer">
              Sign out
            </li>
            <li class="py-1.5 px-2 transition-all duration-100 hover:text-slate-500 dark:hover:text-slate-300 cursor-pointer">
              Profile
            </li>
            <li class="py-1.5 px-2 transition-all duration-100 hover:text-slate-500 dark:hover:text-slate-300 cursor-pointer">
              Messages
            </li>
          </ul>
        </:content>
      </.dropdown>
    </div>
    """
  end

  def example(%{section: "position"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center items-center gap-10">
      <.dropdown
        id="ex-dropdown-top"
        position="top"
        space="small"
        rounded="large"
        padding="extra_small"
        variant="bordered"
        color="danger"
      >
        <:trigger>
          <.button variant="outline" color="secondary" size="extra_small">
            Top dropdown
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Earning</li>
            <li class="py-1.5 px-2 cursor-pointer">Sign out</li>
          </ul>
        </:content>
      </.dropdown>

      <.dropdown
        id="ex-dropdown-bottom"
        space="small"
        rounded="large"
        padding="extra_small"
        variant="shadow"
        color="dawn"
      >
        <:trigger>
          <.button variant="outline" color="dawn" size="extra_small">
            Bottom dropdown
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Earning</li>
            <li class="py-1.5 px-2 cursor-pointer">Sign out</li>
          </ul>
        </:content>
      </.dropdown>
    </div>
    """
  end

  def example(%{section: "width"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center items-center gap-5">
      <.dropdown
        id="ex-dropdown-width-default"
        rounded="small"
        padding="extra_small"
        variant="default"
        color="misc"
      >
        <:trigger>
          <.button variant="outline" color="info" size="extra_small">
            open dropdown
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          </ul>
        </:content>
      </.dropdown>

      <.dropdown
        id="ex-dropdown-width-small"
        rounded="small"
        padding="extra_small"
        width="extra_small"
      >
        <:trigger>
          <.button variant="outline" color="warning" size="extra_small">
            open dropdown
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          </ul>
        </:content>
      </.dropdown>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex justify-center items-center">
      <.dropdown
        id="ex-dropdown-rounded"
        space="small"
        rounded="extra_large"
        width="large"
        padding="extra_small"
        variant="default"
        color="danger"
      >
        <:trigger>
          <.button variant="outline" color="misc" size="extra_small">
            open dropdown
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Earning</li>
            <li class="py-1.5 px-2 cursor-pointer">Sign out</li>
          </ul>
        </:content>
      </.dropdown>
    </div>
    """
  end

  def example(%{section: "space"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center items-center gap-5">
      <.dropdown
        id="ex-dropdown-space-large"
        rounded="small"
        padding="extra_small"
        color="primary"
        variant="default"
        space="extra_large"
      >
        <:trigger>
          <.button variant="outline" color="primary" size="extra_small">
            open dropdown
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          </ul>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          </ul>
        </:content>
      </.dropdown>

      <.dropdown
        id="ex-dropdown-space-small"
        rounded="small"
        padding="extra_small"
        space="extra_small"
      >
        <:trigger>
          <.button variant="outline" color="dawn" size="extra_small">
            open dropdown
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          </ul>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          </ul>
        </:content>
      </.dropdown>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center items-center gap-5">
      <.dropdown
        id="ex-dropdown-padding-large"
        rounded="small"
        padding="extra_large"
        variant="default"
        color="natural"
      >
        <:trigger>
          <.button variant="outline" color="info" size="extra_small">
            open dropdown
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          </ul>
        </:content>
      </.dropdown>

      <.dropdown id="ex-dropdown-padding-small" rounded="small" padding="extra_small">
        <:trigger>
          <.button variant="outline" color="silver" size="extra_small">
            open dropdown
          </.button>
        </:trigger>

        <:content>
          <ul class="text-xs">
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          </ul>
        </:content>
      </.dropdown>
    </div>
    """
  end

  def example(%{section: "size"} = assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center items-center gap-5">
      <.dropdown
        id="ex-dropdown-size-large"
        rounded="small"
        padding="extra_small"
        size="large"
        variant="default"
        color="natural"
      >
        <:trigger>
          <.button variant="outline" color="primary" size="extra_small">
            open dropdown
          </.button>
        </:trigger>

        <:content>
          <ul>
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          </ul>
        </:content>
      </.dropdown>

      <.dropdown
        id="ex-dropdown-size-small"
        rounded="small"
        padding="extra_small"
        size="extra_small"
        variant="default"
        color="silver"
      >
        <:trigger>
          <.button variant="outline" color="silver" size="extra_small">
            open dropdown
          </.button>
        </:trigger>

        <:content>
          <ul>
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
            <li class="py-1.5 px-2 cursor-pointer">Dashboard</li>
            <li class="py-1.5 px-2 cursor-pointer">Settings</li>
          </ul>
        </:content>
      </.dropdown>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
