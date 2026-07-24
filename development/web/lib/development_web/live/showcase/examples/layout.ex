defmodule DevelopmentWeb.Showcase.Examples.Layout do
  @moduledoc """
  Docs examples for the `layout` component (Flex + Grid systems), taken from the
  Mishka source docs (`mishka/.../docs/layout_live.html.heex`). Section headers,
  no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "overview", title: "Overview"},
      %{id: "flex", title: "Flex Component"},
      %{id: "direction", title: "Direction"},
      %{id: "justify", title: "Justify"},
      %{id: "align", title: "Align"},
      %{id: "wrap", title: "Wrap"},
      %{id: "grid", title: "Grid Component"},
      %{id: "grid-place", title: "Grid placement"}
    ]
  end

  def example(%{section: "overview"} = assigns) do
    ~H"""
    <div>
      <.flex wrap="wrap" gap="medium" class="mb-6">
        <.card rounded="large" class="order-last w-full sm:w-1/2 bg-white dark:bg-zinc-800 shadow-xs">
          <.card_content padding="medium">
            <div class="font-semibold text-black dark:text-white">Flex – I'm shown last</div>
          </.card_content>
        </.card>

        <.card rounded="large" class="w-full sm:w-1/2 bg-white dark:bg-zinc-700 shadow-xs">
          <.card_content padding="medium">
            <div class="font-semibold text-black dark:text-white">Flex – I'm in the middle</div>
          </.card_content>
        </.card>

        <.card rounded="large" class="order-first w-full sm:w-1/2 bg-white dark:bg-zinc-600 shadow-xs">
          <.card_content padding="medium">
            <div class="font-semibold text-black dark:text-white">Flex – I'm shown first</div>
          </.card_content>
        </.card>
      </.flex>

      <.grid cols="two" gap="medium">
        <.card rounded="large" class="col-span-2 sm:col-span-1 bg-white dark:bg-blue-800 shadow-xs">
          <.card_content padding="medium">
            <div class="font-semibold text-black dark:text-white">Grid – Column 1</div>
          </.card_content>
        </.card>

        <.card rounded="large" class="col-span-2 sm:col-span-1 bg-white dark:bg-blue-900 !shadow-xs">
          <.card_content padding="medium">
            <div class="font-semibold text-black dark:text-white">Grid – Column 2</div>
          </.card_content>
        </.card>

        <.card rounded="large" class="col-span-2 bg-white dark:bg-blue-950 !shadow-xs">
          <.card_content padding="medium">
            <div class="font-semibold text-black dark:text-white">Grid – Full Width Card</div>
          </.card_content>
        </.card>
      </.grid>
    </div>
    """
  end

  def example(%{section: "flex"} = assigns) do
    ~H"""
    <.flex gap="small">
      <div class="bg-blue-100 dark:bg-blue-900 p-2 rounded text-gray-900 dark:text-gray-100">
        Item A
      </div>
      <div class="bg-blue-200 dark:bg-blue-800 p-2 rounded text-gray-900 dark:text-gray-100">
        Item B
      </div>
      <div class="bg-blue-200 dark:bg-blue-800 p-2 rounded text-gray-900 dark:text-gray-100">
        Item C
      </div>
    </.flex>
    """
  end

  def example(%{section: "direction"} = assigns) do
    ~H"""
    <.flex direction="col" gap="medium">
      <div class="bg-blue-100 dark:bg-blue-900 p-2 rounded text-gray-900 dark:text-gray-100">
        Item A
      </div>
      <div class="bg-blue-200 dark:bg-blue-800 p-2 rounded text-gray-900 dark:text-gray-100">
        Item B
      </div>
    </.flex>
    """
  end

  def example(%{section: "justify"} = assigns) do
    ~H"""
    <.flex justify="center" class="h-32 p-3 bg-gray-100 dark:bg-gray-800">
      <div class="bg-pink-300 dark:bg-pink-800 p-2 rounded text-gray-900 dark:text-gray-100">
        Centered
      </div>
    </.flex>
    """
  end

  def example(%{section: "align"} = assigns) do
    ~H"""
    <.flex align="center" class="h-32 bg-green-50 dark:bg-green-900">
      <div class="bg-green-300 dark:bg-green-700 p-2 rounded text-gray-900 dark:text-gray-100">
        Vertically centered
      </div>
    </.flex>
    """
  end

  def example(%{section: "wrap"} = assigns) do
    ~H"""
    <.flex wrap="wrap" gap="small">
      <div class="bg-purple-100 dark:bg-purple-800 p-2 rounded w-1/2 text-gray-900 dark:text-gray-100">
        1
      </div>
      <div class="bg-purple-200 dark:bg-purple-700 p-2 rounded w-1/2 text-gray-900 dark:text-gray-100">
        2
      </div>
      <div class="bg-purple-300 dark:bg-purple-600 p-2 rounded w-1/2 text-gray-900 dark:text-gray-100">
        3
      </div>
    </.flex>
    """
  end

  def example(%{section: "grid"} = assigns) do
    ~H"""
    <.grid cols="three" gap="medium">
      <div class="p-2 rounded bg-blue-100 dark:bg-blue-800 text-black dark:text-white">
        Col 1
      </div>
      <div class="p-2 rounded bg-blue-200 dark:bg-blue-900 text-black dark:text-white">
        Col 2
      </div>
      <div class="p-2 rounded bg-blue-300 dark:bg-blue-950 text-black dark:text-white">
        Col 3
      </div>
    </.grid>
    """
  end

  def example(%{section: "grid-place"} = assigns) do
    ~H"""
    <.grid cols="two" place_items="center" class="h-64" gap="medium">
      <div class="p-2 rounded bg-orange-100 dark:bg-orange-700 text-black dark:text-white">
        1
      </div>
      <div class="p-2 rounded bg-orange-200 dark:bg-orange-800 text-black dark:text-white">
        2
      </div>
    </.grid>
    """
  end

  def example(assigns), do: ~H""
end
