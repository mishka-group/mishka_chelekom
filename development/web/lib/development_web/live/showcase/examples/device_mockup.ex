defmodule DevelopmentWeb.Showcase.Examples.DeviceMockup do
  @moduledoc """
  Docs examples for the `device_mockup` component, taken from the Mishka source docs
  (`mishka/.../docs/device_mockup_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  The original doc renders screen content via a doc-only `<.custom_component_list>` helper; here we
  inline simple placeholder content so the examples are self-contained.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "iphone", title: "iPhone"},
      %{id: "android", title: "Android"},
      %{id: "watch", title: "Watch"},
      %{id: "ipad", title: "iPad"},
      %{id: "laptop", title: "Laptop"},
      %{id: "imac", title: "iMac"},
      %{id: "colors", title: "Colors"},
      %{id: "content", title: "Embed Any UI"}
    ]
  end

  def example(%{section: "iphone"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.device_mockup>
        <div class="pt-10 px-4 space-y-2">
          <div class="h-3 w-24 bg-gray-300 rounded"></div>
          <div class="h-24 w-full bg-gray-200 rounded-lg"></div>
          <div class="h-3 w-32 bg-gray-300 rounded"></div>
        </div>
      </.device_mockup>
    </div>
    """
  end

  def example(%{section: "android"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.device_mockup type="android">
        <div class="pt-10 px-4 space-y-2">
          <div class="h-3 w-24 bg-gray-300 rounded"></div>
          <div class="h-24 w-full bg-gray-200 rounded-lg"></div>
          <div class="h-3 w-32 bg-gray-300 rounded"></div>
        </div>
      </.device_mockup>
    </div>
    """
  end

  def example(%{section: "watch"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.device_mockup type="watch">
        <div class="h-full flex items-center justify-center text-neutral-700 dark:text-[#f1f1f1]">
          <.icon name="hero-clock" class="size-10" />
        </div>
      </.device_mockup>
    </div>
    """
  end

  def example(%{section: "ipad"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.device_mockup type="ipad">
        <div class="pt-10 px-6 grid grid-cols-2 gap-3">
          <div class="h-20 bg-gray-200 rounded-lg"></div>
          <div class="h-20 bg-gray-200 rounded-lg"></div>
          <div class="h-20 bg-gray-200 rounded-lg"></div>
          <div class="h-20 bg-gray-200 rounded-lg"></div>
        </div>
      </.device_mockup>
    </div>
    """
  end

  def example(%{section: "laptop"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.device_mockup type="laptop">
        <div class="p-4 grid grid-cols-2 gap-3">
          <div class="h-16 bg-gray-200 rounded-lg"></div>
          <div class="h-16 bg-gray-200 rounded-lg"></div>
        </div>
      </.device_mockup>
    </div>
    """
  end

  def example(%{section: "imac"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.device_mockup type="imac">
        <div class="p-4 grid grid-cols-2 gap-3">
          <div class="h-16 bg-gray-200 rounded-lg"></div>
          <div class="h-16 bg-gray-200 rounded-lg"></div>
        </div>
      </.device_mockup>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.device_mockup :for={c <- ~w(silver primary success info danger)} type="android" color={c}>
        <div class="pt-10 px-4 space-y-2">
          <div class="h-3 w-24 bg-gray-300 rounded"></div>
          <div class="h-20 w-full bg-gray-200 rounded-lg"></div>
        </div>
      </.device_mockup>
    </div>
    """
  end

  def example(%{section: "content"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.device_mockup>
        <div class="h-full pt-8 pb-2 px-4 space-y-3 text-neutral-700 dark:text-[#f1f1f1]">
          <div class="space-y-1">
            <div class="text-sm font-medium">Name</div>
            <div class="w-full h-10 select-none rounded-lg border bg-gray-200 px-2 flex items-center leading-0 text-gray-400">
              Enter your name
            </div>
          </div>
          <div class="space-y-1">
            <div class="text-sm font-medium">Family</div>
            <div class="w-full h-10 select-none rounded-lg border bg-gray-200 px-2 flex items-center leading-0 text-gray-400">
              Enter your family
            </div>
          </div>
          <div class="space-y-1">
            <div class="text-sm font-medium">Job title</div>
            <div class="w-full h-10 select-none rounded-lg border bg-gray-200 px-2 flex items-center leading-0 text-gray-400">
              Enter your job title
            </div>
          </div>
          <div class="space-y-5">
            <div class="text-neutral-500 dark:text-neutral-200 text-xs">
              By signing up you accepted terms of services
            </div>
            <div class="py-1.5 w-full px-1 text-center bg-teal-500 text-white rounded-lg">
              Sign up
            </div>
          </div>
        </div>
      </.device_mockup>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
