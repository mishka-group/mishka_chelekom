defmodule DevelopmentWeb.Showcase.Examples.MegaMenu do
  @moduledoc """
  Docs examples for the `mega_menu` component, taken from the Mishka source docs
  (`mishka/.../docs/mega_menu_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "basic", title: "How to use"},
      %{id: "variants", title: "Variants and colors"},
      %{id: "clickable", title: "Clickable"},
      %{id: "sizes", title: "Sizes"},
      %{id: "padding", title: "Padding"},
      %{id: "rounded", title: "Rounded"},
      %{id: "border", title: "Border"},
      %{id: "trigger", title: "Trigger slot"}
    ]
  end

  def example(%{section: "basic"} = assigns) do
    ~H"""
    <div class="relative w-full flex justify-center gap-5 items-center">
      <.mega_menu
        space="small"
        rounded="large"
        padding="extra_small"
        top_gap="large"
        id="ex-mega_menu-basic-1"
      >
        <:trigger>
          <.button variant="outline" color="natural">MegaMenu</.button>
        </:trigger>

        <div class="grid md:grid-cols-2 lg:grid-cols-3">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Documentation</li>
          </ul>
          <div class="mt-4 md:mt-0">
            <h2 class="mb-2 font-semibold text-gray-900 dark:text-white">Mishka Chelekom</h2>
            <p class="mb-2 dark:text-gray-500">
              We provide a wide range of components tailored to meet various customer needs and preferences.
            </p>
          </div>
        </div>
      </.mega_menu>
    </div>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="relative w-full flex flex-wrap justify-center gap-5 items-center">
      <.mega_menu
        space="small"
        rounded="large"
        padding="extra_small"
        top_gap="small"
        id="ex-mega_menu-variants-base"
      >
        <:trigger>
          <.button variant="outline" color="misc" size="small">open base</.button>
        </:trigger>

        <div class="grid md:grid-cols-2 lg:grid-cols-3">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Documentation</li>
          </ul>
          <div class="mt-4 md:mt-0">
            <h2 class="mb-2 font-semibold">Mishka Chelekom</h2>
            <p class="mb-2">
              We provide a wide range of components tailored to meet various customer needs and preferences.
            </p>
          </div>
        </div>
      </.mega_menu>

      <.mega_menu
        space="small"
        rounded="large"
        padding="extra_small"
        top_gap="large"
        color="primary"
        id="ex-mega_menu-variants-primary"
        variant="default"
      >
        <:trigger>
          <.button variant="outline" color="primary" size="small">open primary</.button>
        </:trigger>

        <div class="grid md:grid-cols-2 lg:grid-cols-3">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Documentation</li>
          </ul>
          <div class="mt-4 md:mt-0">
            <h2 class="mb-2 font-semibold">Mishka Chelekom</h2>
            <p class="mb-2">
              We provide a wide range of components tailored to meet various customer needs and preferences.
            </p>
          </div>
        </div>
      </.mega_menu>

      <.mega_menu
        space="small"
        rounded="large"
        padding="extra_small"
        top_gap="large"
        color="warning"
        variant="shadow"
        id="ex-mega_menu-variants-warning"
      >
        <:trigger>
          <.button variant="outline" color="warning" size="small">open shadow</.button>
        </:trigger>

        <div class="grid md:grid-cols-2 lg:grid-cols-3">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Documentation</li>
          </ul>
          <div class="mt-4 md:mt-0">
            <h2 class="mb-2 font-semibold">Mishka Chelekom</h2>
            <p class="mb-2">
              We provide a wide range of components tailored to meet various customer needs and preferences.
            </p>
          </div>
        </div>
      </.mega_menu>

      <.mega_menu
        space="small"
        rounded="large"
        padding="extra_small"
        top_gap="large"
        color="dawn"
        variant="bordered"
        id="ex-mega_menu-variants-dawn"
      >
        <:trigger>
          <.button variant="outline" size="small" color="dawn">Dawn mega menu</.button>
        </:trigger>

        <div class="grid md:grid-cols-2 lg:grid-cols-3">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Documentation</li>
          </ul>
          <div class="mt-4 md:mt-0">
            <h2 class="mb-2 font-semibold">Mishka Chelekom</h2>
            <p class="mb-2">
              We provide a wide range of components tailored to meet various customer needs and preferences.
            </p>
          </div>
        </div>
      </.mega_menu>
    </div>
    """
  end

  def example(%{section: "clickable"} = assigns) do
    ~H"""
    <div class="relative w-full flex justify-center gap-5 items-center">
      <.mega_menu
        space="small"
        rounded="large"
        padding="extra_small"
        top_gap="large"
        color="danger"
        id="ex-mega_menu-clickable-1"
        clickable
        variant="default"
      >
        <:trigger>
          <.button variant="outline" color="danger" size="small">open clickable mega menu</.button>
        </:trigger>

        <div class="grid md:grid-cols-2 lg:grid-cols-3">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Documentation</li>
          </ul>
          <div class="mt-4 md:mt-0">
            <h2 class="mb-2 font-semibold">Mishka Chelekom</h2>
            <p class="mb-2">
              We provide a wide range of components tailored to meet various customer needs and preferences.
            </p>
          </div>
        </div>
      </.mega_menu>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="relative w-full flex flex-wrap justify-center gap-5 items-center">
      <.mega_menu
        space="extra_large"
        rounded="large"
        padding="extra_small"
        top_gap="large"
        color="misc"
        size="small"
        variant="default"
        id="ex-mega_menu-sizes-1"
      >
        <:trigger>
          <.button variant="outline" color="misc" size="small">open small</.button>
        </:trigger>

        <ul class="flex items-center gap-5 justify-between">
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Categories</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Support</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">About Us</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Contact</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">New Arrivals</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Best Sellers</li>
        </ul>

        <ul class="flex items-center gap-5 justify-between">
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Blog</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Privacy Policy</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Terms of Service</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Documentation</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">FAQs</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Case Studies</li>
        </ul>
      </.mega_menu>

      <.mega_menu
        space="extra_small"
        rounded="large"
        size="small"
        padding="extra_small"
        top_gap="large"
        variant="default"
        color="info"
        id="ex-mega_menu-sizes-2"
      >
        <:trigger>
          <.button variant="outline" color="info" size="small">open compact</.button>
        </:trigger>

        <ul class="flex items-center gap-2 justify-between">
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Categories</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Support</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">About Us</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Contact</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">New Arrivals</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Best Sellers</li>
        </ul>

        <ul class="flex items-center gap-2 justify-between">
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Blog</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Privacy Policy</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Terms of Service</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Documentation</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">FAQs</li>
          <li class="hover:underline hover:text-blue-400 cursor-pointer">Case Studies</li>
        </ul>
      </.mega_menu>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="relative w-full flex flex-wrap justify-center gap-5 items-center">
      <.mega_menu
        rounded="large"
        padding="extra_small"
        top_gap="large"
        color="secondary"
        variant="default"
        size="extra_small"
        id="ex-mega_menu-padding-1"
      >
        <:trigger>
          <.button variant="outline" color="secondary" size="small">open extra small</.button>
        </:trigger>

        <div class="grid md:grid-cols-2">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-200 dark:hover:text-blue-400 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-200 dark:hover:text-blue-400 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-200 dark:hover:text-blue-400 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-200 dark:hover:text-blue-400 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-200 dark:hover:text-blue-400 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-200 dark:hover:text-blue-400 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-200 dark:hover:text-blue-400 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-200 dark:hover:text-blue-400 cursor-pointer">Documentation</li>
          </ul>
        </div>
      </.mega_menu>

      <.mega_menu
        rounded="large"
        padding="extra_large"
        top_gap="large"
        color="success"
        size="extra_small"
        id="ex-mega_menu-padding-2"
        variant="default"
      >
        <:trigger>
          <.button variant="outline" color="success" size="small">open extra large</.button>
        </:trigger>

        <div class="grid md:grid-cols-2">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Documentation</li>
          </ul>
        </div>
      </.mega_menu>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="relative w-full flex flex-wrap justify-center gap-5 items-center">
      <.mega_menu
        rounded="extra_small"
        padding="small"
        top_gap="large"
        color="info"
        size="extra_small"
        variant="default"
        id="ex-mega_menu-rounded-1"
      >
        <:trigger>
          <.button variant="outline" color="info" size="small">open extra small</.button>
        </:trigger>

        <div class="grid md:grid-cols-2">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Documentation</li>
          </ul>
        </div>
      </.mega_menu>

      <.mega_menu
        rounded="extra_large"
        padding="small"
        top_gap="large"
        color="dawn"
        size="extra_small"
        id="ex-mega_menu-rounded-2"
        variant="default"
      >
        <:trigger>
          <.button variant="outline" color="dawn" size="small">open extra large</.button>
        </:trigger>

        <div class="grid md:grid-cols-2">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Documentation</li>
          </ul>
        </div>
      </.mega_menu>
    </div>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="relative w-full flex flex-wrap justify-center gap-5 items-center">
      <.mega_menu
        border="extra_small"
        padding="small"
        top_gap="large"
        variant="bordered"
        size="extra_small"
        id="ex-mega_menu-border-1"
      >
        <:trigger>
          <.button variant="outline" color="natural" size="small">open extra small</.button>
        </:trigger>

        <div class="grid md:grid-cols-2">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Documentation</li>
          </ul>
        </div>
      </.mega_menu>

      <.mega_menu
        border="extra_large"
        padding="small"
        top_gap="large"
        color="danger"
        variant="bordered"
        size="extra_small"
        id="ex-mega_menu-border-2"
      >
        <:trigger>
          <.button color="danger" variant="outline" size="small">open extra large</.button>
        </:trigger>

        <div class="grid md:grid-cols-2">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-600 cursor-pointer">Documentation</li>
          </ul>
        </div>
      </.mega_menu>
    </div>
    """
  end

  def example(%{section: "trigger"} = assigns) do
    ~H"""
    <div class="relative w-full flex justify-center gap-5 items-center">
      <.mega_menu
        padding="small"
        top_gap="large"
        size="extra_small"
        font_weight="font-thin"
        id="ex-mega_menu-trigger-1"
      >
        <:trigger>
          <button class="py-2 px-10 text-lg text-gray-200 bg-slate-600 rounded-full">
            open mega menu
          </button>
        </:trigger>
        <div class="grid md:grid-cols-2">
          <ul class="space-y-4 sm:mb-4 md:mb-0">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Product Categories</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Customer Support</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">About Us</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Contact</li>
          </ul>
          <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Blog</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Privacy Policy</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Terms of Service</li>
            <li class="hover:underline hover:text-blue-400 cursor-pointer">Documentation</li>
          </ul>
        </div>
      </.mega_menu>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
