defmodule DevelopmentWeb.Showcase.Examples.ScrollArea do
  @moduledoc """
  Docs examples for the `scroll_area` component, taken from the Mishka source docs
  (`mishka/.../docs/scroll_area_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "horizontal", title: "Horizontal"},
      %{id: "vertical", title: "Vertical"},
      %{id: "type", title: "Type"},
      %{id: "width", title: "Width"},
      %{id: "padding", title: "Padding"},
      %{id: "height", title: "Height"},
      %{id: "content-class", title: "Content class"}
    ]
  end

  def example(%{section: "horizontal"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.scroll_area
        id="ex-scroll_area-horizontal"
        horizontal
        vertical={false}
        width="w-full"
        height="h-fit md:h-[390px]"
        class="mx-auto"
        content_class="py-7 px-1"
      >
        <div class="flex gap-4 [&>*]:rounded-lg [&>*]:shadow-sm">
          <div class="min-w-[300px] h-[300px] bg-gray-100 dark:bg-gray-800 p-4">Card 1</div>
          <div class="min-w-[300px] h-[300px] bg-gray-100 dark:bg-gray-800 p-4">Card 2</div>
          <div class="min-w-[300px] h-[300px] bg-gray-100 dark:bg-gray-800 p-4">Card 3</div>
          <div class="min-w-[300px] h-[300px] bg-gray-100 dark:bg-gray-800 p-4">Card 4</div>
        </div>
      </.scroll_area>
    </div>
    """
  end

  def example(%{section: "vertical"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.scroll_area
        id="ex-scroll_area-vertical"
        vertical={false}
        height="h-[300px]"
        content_class="py-7 px-1"
      >
        <div class="grid lg:grid-cols-2 gap-4 [&>*]:rounded-lg [&>*]:shadow-sm">
          <div class="min-w-[200px] bg-gray-100 dark:bg-gray-800 p-4">
            <h3 class="font-bold mb-2">Better Organization</h3>
            <p>
              Scroll areas help organize content efficiently, especially when dealing with long lists or large amounts of content in a confined space.
            </p>
          </div>
          <div class="min-w-[200px] bg-gray-100 dark:bg-gray-800 p-4">
            <h3 class="font-bold mb-2">Enhanced UX</h3>
            <p>
              Provides smooth scrolling experience with custom scrollbars, improving user interaction and navigation within your application.
            </p>
          </div>
          <div class="min-w-[200px] bg-gray-100 dark:bg-gray-800 p-4">
            <h3 class="font-bold mb-2">Space Efficiency</h3>
            <p>
              Maximizes screen real estate by containing content in fixed dimensions while maintaining access to all information through scrolling.
            </p>
          </div>
          <div class="min-w-[200px] bg-gray-100 dark:bg-gray-800 p-4">
            <h3 class="font-bold mb-2">Responsive Design</h3>
            <p>
              Adapts seamlessly to different screen sizes and orientations, ensuring consistent content presentation across all devices.
            </p>
          </div>
        </div>
      </.scroll_area>
    </div>
    """
  end

  def example(%{section: "type"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.scroll_area
        id="ex-scroll_area-type"
        type="hover"
        width="w-full md:w-[380px]"
        height="h-80"
        class="mx-auto"
        content_class="py-7 px-1"
      >
        <h2 class="text-xl font-bold mb-4">Versatile Integration</h2>
        <p class="mb-4">
          The scroll area component seamlessly integrates with various UI elements such as sidebars, drawers, and comboboxes. In sidebars, it enables smooth navigation through lengthy menu items, while in drawers it manages overflow content elegantly. For comboboxes, it handles long option lists efficiently, ensuring a clean and organized dropdown experience.
        </p>

        <h2 class="text-xl font-bold mb-4">Enhanced Content Management</h2>
        <p class="mb-4">
          When combined with table of contents, modals, or data tables, the scroll area component maintains content accessibility while preserving layout integrity. It's particularly useful in documentation sections, chat interfaces, and content-heavy panels where vertical or horizontal space management is crucial, all while providing consistent scrolling behavior across different devices and screen sizes.
        </p>
      </.scroll_area>
    </div>
    """
  end

  def example(%{section: "width"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.scroll_area
        id="ex-scroll_area-width"
        width="w-full md:w-2/3"
        height="h-80"
        class="mx-auto"
        content_class="py-7 px-1"
      >
        <h2 class="text-xl font-bold mb-4">Advanced Scroll Area Features</h2>
        <p class="mb-4">
          The scroll area component offers sophisticated features like customizable scrollbar visibility, smooth scrolling behavior, and responsive dimensions. With support for both vertical and horizontal scrolling, it adapts seamlessly to various content types and layout requirements, making it ideal for handling overflow content in a clean, accessible manner.
        </p>

        <h2 class="text-xl font-bold mb-4">Flexible Integration</h2>
        <p class="mb-4">
          Whether you're building complex navigation systems, data tables, or content-rich interfaces, the scroll area component provides consistent scrolling behavior across different devices and browsers. Its configurable width, height, and padding options ensure optimal presentation while maintaining performance and user experience standards.
        </p>
      </.scroll_area>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.scroll_area id="ex-scroll_area-padding" height="h-64" padding="small">
        <h2 class="text-xl font-bold mb-4">Integration with Other Components</h2>
        <p class="mb-4">
          Scroll areas enhance various UI components by providing controlled overflow:
        </p>
        <ul class="list-disc pl-5 mb-4">
          <li>In modals for long-form content</li>
          <li>Within sidebars for extensive navigation menus</li>
          <li>Inside dropdowns for lengthy option lists</li>
          <li>For table bodies with many rows</li>
          <li>In chat interfaces for message history</li>
        </ul>

        <h2 class="text-xl font-bold mb-4">Benefits</h2>
        <p class="mb-4">
          By integrating scroll areas with other components, you can:
        </p>
        <ul class="list-disc pl-5 mb-4">
          <li>Maintain a compact UI footprint</li>
          <li>Improve content accessibility</li>
          <li>Create responsive layouts</li>
          <li>Handle dynamic content gracefully</li>
          <li>Ensure consistent scrolling behavior</li>
        </ul>
      </.scroll_area>
    </div>
    """
  end

  def example(%{section: "height"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.scroll_area id="ex-scroll_area-height" content_class="py-5 px-7" height="h-[120px]">
        <h2 class="text-xl font-bold mb-4">Introduction to Phoenix LiveView Scroll Area</h2>
        <p class="mb-4">
          Scroll Area in Phoenix LiveView provides an elegant solution for managing scrollable content.
          It offers customizable scrollbars, responsive behavior, and smooth scrolling experiences.
          With support for both vertical and horizontal scrolling, it adapts seamlessly to various content types
          and screen sizes while maintaining performance and accessibility.
        </p>
      </.scroll_area>
    </div>
    """
  end

  def example(%{section: "content-class"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.scroll_area id="ex-scroll_area-content-class" content_class="py-3 px-5" height="h-[120px]">
        <div class="space-y-4">
          <h2 class="text-xl font-bold">
            Customizable Dimensions for Enhanced Integration
          </h2>
          <p>
            The scroll area component's flexible height and width customization makes it exceptionally versatile when integrated into other UI components. Whether embedding it within modals, sidebars, or complex dashboards, you can precisely control its dimensions using Tailwind CSS classes. This adaptability ensures optimal space utilization in nested layouts, responsive designs, and dynamic content scenarios. The component maintains smooth scrolling behavior and consistent user experience regardless of its configured size, making it perfect for everything from compact dropdown menus to full-page content sections.
          </p>
        </div>
      </.scroll_area>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
