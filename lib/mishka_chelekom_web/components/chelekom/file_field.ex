defmodule MishkaChelekom.FileField do
  @moduledoc """
  The `MishkaChelekom.FileField` module provides a versatile and customizable component
  for handling file uploads in Phoenix LiveView applications.

  This module supports various configurations, allowing users to upload files or
  images through traditional file inputs or interactive dropzones.

  ### Key Features:
  - **Custom Styling Options:** Allows for customized styles, including colors, borders, and rounded corners.
  - **Flexible Input Types:** Supports both live uploads and standard file inputs.
  - **Dropzone Functionality:** Provides an interactive drag-and-drop area for file
  uploads with customizable icons and descriptions.
  - **Error Handling:** Displays error messages for issues like file size, file type,
  and maximum number of files.
  - **Upload Progress:** Shows real-time upload progress for each file.

  This component is designed to simplify file handling in forms and offers a visually
  appealing and user-friendly experience for uploading files in LiveView applications.
  """

  use Phoenix.Component

  @doc """
  Renders a `file_input` field with customizable styles, labels, and live upload capabilities.

  It can be used as a simple file input or as a dropzone with drag-and-drop support for files and images.

  ## Examples

  ```elixir
  <MishkaChelekom.FileField.file_field color="danger" />
  <MishkaChelekom.FileField.file_field target={:avatar} uploads={@uploads} dropzone/>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :label_class, :string, default: nil, doc: "Custom CSS class for the label styling"
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :variant, :string, default: "default", doc: "Determines the style"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :live, :boolean, default: false, doc: "Specifies whether this upload is live or input file"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :size, :string,
    default: "extra_small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :label, :string, default: nil, doc: "Specifies text for the label"
  attr :dashed, :boolean, default: true, doc: "Determines dashed border"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :uploads, :any, doc: "LiveView upload map"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :dropzone, :boolean, default: false, doc: ""
  attr :dropzone_type, :string, default: "file", doc: "file, image"
  attr :target, :atom, doc: "Name of upload input when is used as Live Upload"
  attr :dropzone_icon, :string, default: "hero-cloud-arrow-up", doc: ""
  attr :dropzone_title, :string, default: "Click to upload, or drag and drop a file", doc: ""
  attr :dropzone_description, :string, default: nil, doc: "Specifies description for dropzone"

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include:
      ~w(autocomplete disabled form checked multiple readonly min max step required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec file_field(map()) :: Phoenix.LiveView.Rendered.t()
  def file_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> file_field()
  end

  def file_field(%{dropzone: true, dropzone_type: "file"} = assigns) do
    targeted_upload = assigns.uploads[assigns.target]

    assigns =
      assigns
      |> assign_new(:entries, fn -> targeted_upload.entries end)
      |> assign_new(:upload_error, fn -> targeted_upload end)
      |> assign_new(:upload, fn -> targeted_upload end)

    ~H"""
    <div class={[
      dropzone_color(@variant, @color),
      border_class(@border),
      rounded_size(@rounded),
      size_class(@size),
      @dashed && "[&_.dropzone-wrapper]:border-dashed",
      @class
    ]}>
      <label
        class={[
          "dropzone-wrapper group flex flex-col items-center justify-center w-full cursor-pointer"
        ]}
        phx-drop-target={@upload.ref}
      >
        <div class="flex flex-col gap-3 items-center justify-center pt-5 pb-6">
          <.icon name={@dropzone_icon} class="size-14" />
          <div class="mb-2 font-semibold">
            <%= @dropzone_title %>
          </div>

          <div>
            <%= @dropzone_description %>
          </div>
        </div>
        <.live_file_input upload={@upload} class="hidden" />
      </label>

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>

      <div class="mt-5 space-y-4">
        <%= for entry <- @entries do %>
          <div class="upload-item border rounded relative p-3">
            <div class="flex justify-around gap-3">
              <.icon name="hero-document-arrow-up" class="size-8" />
              <div class="w-full space-y-3">
                <div class="text-ellipsis	overflow-hidden w-44 whitespace-nowrap">
                  <%= entry.client_name %>
                </div>

                <div>
                  <%= convert_to_mb(entry.client_size) %> <span>MB</span>
                </div>

                <MishkaChelekom.Progress.progress
                  value={entry.progress}
                  color={@color}
                  size="extra_small"
                />
              </div>
            </div>

            <button
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
              class="absolute top-2 right-2 text-custome-black-100/60 hover:text-custome-black-100"
            >
              <.icon name="hero-x-mark" class="size-4" />
            </button>

            <%= for err <- upload_errors(@upload_error, entry) do %>
              <p class="text-rose-600 font-medium text-xs mt-3">Error: <%= err %></p>
            <% end %>
          </div>
        <% end %>
      </div>

      <%= for err <- upload_errors(@upload_error) do %>
        <p class="text-rose-600 font-medium text-xs"><%= error_to_string(err) %></p>
      <% end %>
    </div>
    """
  end

  def file_field(%{dropzone: true, dropzone_type: "image"} = assigns) do
    targeted_upload = assigns.uploads[assigns.target]

    assigns =
      assigns
      |> assign_new(:entries, fn -> targeted_upload.entries end)
      |> assign_new(:upload_error, fn -> targeted_upload end)
      |> assign_new(:upload, fn -> targeted_upload end)

    ~H"""
    <div class={[
      dropzone_color(@variant, @color),
      border_class(@border),
      rounded_size(@rounded),
      size_class(@size),
      @dashed && "[&_.dropzone-wrapper]:border-dashed",
      @class
    ]}>
      <label
        class={[
          "dropzone-wrapper group flex flex-col items-center justify-center w-full cursor-pointer"
        ]}
        phx-drop-target={@upload.ref}
      >
        <div class="flex flex-col gap-3 items-center justify-center pt-5 pb-6">
          <.icon name={@dropzone_icon} class="size-14" />
          <div class="mb-2 font-semibold">
            <%= @dropzone_title %>
          </div>

          <div>
            <%= @dropzone_description %>
          </div>
        </div>
        <.live_file_input upload={@upload} class="hidden" />
      </label>

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>

      <div class="flex flex-wrap gap-3 my-3">
        <%= for entry <- @entries do %>
          <div class="relative">
            <div class="rounded w-24 h-24 overflow-hidden">
              <figure class="w-full h-full object-cover">
                <.live_img_preview entry={entry} class="w-full h-full object-cover rounded" />
              </figure>
            </div>

            <button class="bg-black/30 rounded p-px text-white flex justify-center items-center absolute top-2 right-2 z-10">
              <.icon name="hero-x-mark" class="size-4" />
            </button>
            <div
              role="status"
              class="absolute top-1 left-1 bottom-1 right-1 bg-black/25 flex justify-center items-center"
            >
              <MishkaChelekom.Spinner.spinner color="white" />
            </div>
          </div>
        <% end %>
      </div>

      <%= for err <- upload_errors(@upload_error) do %>
        <p class="text-rose-600 font-medium text-xs"><%= error_to_string(err) %></p>
      <% end %>
    </div>
    """
  end

  def file_field(assigns) do
    ~H"""
    <div class={[
      rounded_size(@rounded),
      color_class(@color),
      space_class(@space),
      @class
    ]}>
      <.label for={@id}><%= @label %></.label>

      <%= if @live do %>
        <.live_file_input
          upload={@upload}
          class={[
            "file-field block w-full cursor-pointer focus:outline-none file:border-0 file:cursor-pointer",
            "file:py-3 file:px-8 file:font-bold file:-ms-4 file:me-4"
          ]}
          {@rest}
        />
      <% else %>
        <input
          class={[
            "file-field block w-full cursor-pointer focus:outline-none file:border-0 file:cursor-pointer",
            "file:py-3 file:px-8 file:font-bold file:-ms-4 file:me-4"
          ]}
          type="file"
          {@rest}
        />
      <% end %>

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  @doc type: :component
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp label(assigns) do
    ~H"""
    <label for={@for} class={["block text-sm font-semibold leading-6", @class]}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc type: :component
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp error(assigns) do
    ~H"""
    <p class="mt-3 flex items-center gap-3 text-sm leading-6 text-rose-700">
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" /> <%= render_slot(@inner_block) %>
    </p>
    """
  end

  def convert_to_mb(size_in_bytes) when is_integer(size_in_bytes) do
    Float.round(size_in_bytes / (1024 * 1024), 2)
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

  defp border_class("none"), do: "[&_.dropzone-wrapper]:border-0"
  defp border_class("extra_small"), do: "[&_.dropzone-wrapper]:border"
  defp border_class("small"), do: "[&_.dropzone-wrapper]:border-2"
  defp border_class("medium"), do: "[&_.dropzone-wrapper]:border-[3px]"
  defp border_class("large"), do: "[&_.dropzone-wrapper]:border-4"
  defp border_class("extra_large"), do: "[&_.dropzone-wrapper]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp size_class("extra_small"), do: "[&_.dropzone-wrapper]:h-52"
  defp size_class("small"), do: "[&_.dropzone-wrapper]:h-56"
  defp size_class("medium"), do: "[&_.dropzone-wrapper]:h-60"
  defp size_class("large"), do: "[&_.dropzone-wrapper]:h-64"
  defp size_class("extra_large"), do: "[&_.dropzone-wrapper]:h-72"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_small")

  defp rounded_size("extra_small"),
    do: "[&_.file-field]:rounded-sm [&_.dropzone-wrapper]:rounded-sm"

  defp rounded_size("small"), do: "[&_.file-field]:rounded [&_.dropzone-wrapper]:rounded"
  defp rounded_size("medium"), do: "[&_.file-field]:rounded-md [&_.dropzone-wrapper]:rounded-md"
  defp rounded_size("large"), do: "[&_.file-field]:rounded-lg [&_.dropzone-wrapper]:rounded-lg"

  defp rounded_size("extra_large"),
    do: "[&_.file-field]:rounded-xl [&_.dropzone-wrapper]:rounded-xl"

  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: rounded_size("small")

  defp space_class("extra_small"), do: "space-y-1"
  defp space_class("small"), do: "space-y-1.5"
  defp space_class("medium"), do: "space-y-2"
  defp space_class("large"), do: "space-y-2.5"
  defp space_class("extra_large"), do: "space-y-3"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("medium")

  defp color_class("white") do
    [
      "[&_.file-field]:bg-white file:[&_.file-field]:text-[#DADADA] file:[&_.file-field]:bg-[#DADADA]"
    ]
  end

  defp color_class("primary") do
    [
      "[&_.file-field]:bg-[#4363EC] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#2441de]"
    ]
  end

  defp color_class("secondary") do
    [
      "[&_.file-field]:bg-[#877C7C] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#6B6E7C]"
    ]
  end

  defp color_class("success") do
    [
      "[&_.file-field]:bg-[#ECFEF3] file:[&_.file-field]:text-white [&_.file-field]:text-[#047857] file:[&_.file-field]:bg-[#047857]"
    ]
  end

  defp color_class("warning") do
    [
      "[&_.file-field]:bg-[#FFF8E6] file:[&_.file-field]:text-white [&_.file-field]:text-[#FF8B08] file:[&_.file-field]:bg-[#FF8B08]"
    ]
  end

  defp color_class("danger") do
    [
      "[&_.file-field]:bg-[#FFE6E6] [&_.file-field]:text-[#E73B3B] file:[&_.file-field]:text-white file:[&_.file-field]:bg-[#E73B3B]"
    ]
  end

  defp color_class("info") do
    [
      "[&_.file-field]:bg-[#E5F0FF] file:[&_.file-field]:text-white [&_.file-field]:text-[#004FC4] file:[&_.file-field]:bg-[#004FC4]"
    ]
  end

  defp color_class("misc") do
    [
      "[&_.file-field]:bg-[#FFE6FF] file:[&_.file-field]:text-white [&_.file-field]:text-[#52059C] file:[&_.file-field]:bg-[#52059C]"
    ]
  end

  defp color_class("dawn") do
    [
      "[&_.file-field]:bg-[#FFECDA] file:[&_.file-field]:text-white [&_.file-field]:text-[#4D4137] file:[&_.file-field]:bg-[#4D4137]"
    ]
  end

  defp color_class("light") do
    [
      "[&_.file-field]:bg-[#E3E7F1] file:[&_.file-field]:text-white [&_.file-field]:text-[#707483] file:[&_.file-field]:bg-[#707483]"
    ]
  end

  defp color_class("dark") do
    [
      "[&_.file-field]:bg-[#383838] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#1E1E1E]"
    ]
  end

  defp dropzone_color("outline", "white") do
    [
      "text-white [&_.dropzone-wrapper]:text-white [&_.dropzone-wrapper]:border-white",
      "hover:[&_.dropzone-wrapper]:text-white hover:[&_.dropzone-wrapper]:border-white",
      "[&_.upload-item]:border-white"
    ]
  end

  defp dropzone_color("outline", "silver") do
    [
      "text-[#afafaf] [&_.dropzone-wrapper]:text-[#afafaf]/80 [&_.dropzone-wrapper]:border-[#afafaf]/80",
      "hover:[&_.dropzone-wrapper]:text-[#afafaf] hover:[&_.dropzone-wrapper]:border-[#afafaf]",
      "[&_.upload-item]:border-[#afafaf]"
    ]
  end

  defp dropzone_color("outline", "primary") do
    [
      "text-[#2441de] [&_.dropzone-wrapper]:text-[#2441de] [&_.dropzone-wrapper]:border-[#2441de]/80",
      "hover:[&_.dropzone-wrapper]:text-[#2441de] hover:[&_.dropzone-wrapper]:border-[#2441de]",
      "[&_.upload-item]:border-[#2441de]"
    ]
  end

  defp dropzone_color("outline", "secondary") do
    [
      "text-[#877C7C] [&_.dropzone-wrapper]:border-[#877C7C]/80 [&_.dropzone-wrapper]:border-[#877C7C]/80",
      "hover:[&_.dropzone-wrapper]:text-[#877C7C] hover:[&_.dropzone-wrapper]:border-[#877C7C]",
      "[&_.upload-item]:border-[#877C7C]"
    ]
  end

  defp dropzone_color("outline", "success") do
    [
      "text-[#047857] [&_.dropzone-wrapper]:text-[#047857]/80 [&_.dropzone-wrapper]:border-[#047857]/80",
      "hover:[&_.dropzone-wrapper]:text-[#047857] hover:[&_.dropzone-wrapper]:border-[#047857]",
      "[&_.upload-item]:border-[#047857]"
    ]
  end

  defp dropzone_color("outline", "warning") do
    [
      "text-[#FF8B08] [&_.dropzone-wrapper]:text-[#FF8B08]/80 [&_.dropzone-wrapper]:border-[#FF8B08]/80",
      "hover:[&_.dropzone-wrapper]:text-[#FF8B08] hover:[&_.dropzone-wrapper]:border-[#FF8B08]",
      "[&_.upload-item]:border-[#FF8B08]"
    ]
  end

  defp dropzone_color("outline", "danger") do
    [
      "text-[#E73B3B] [&_.dropzone-wrapper]:text-[#E73B3B]/80 [&_.dropzone-wrapper]:border-[#E73B3B]/80",
      "hover:[&_.dropzone-wrapper]:text-[#004FC4] hover:[&_.dropzone-wrapper]:border-[#004FC4]",
      "[&_.upload-item]:border-[#E73B3B]"
    ]
  end

  defp dropzone_color("outline", "info") do
    [
      "text-[#004FC4] [&_.dropzone-wrapper]:text-[#004FC4]/80 [&_.dropzone-wrapper]:border-[#004FC4]/80",
      "hover:[&_.dropzone-wrapper]:text-[#004FC4] hover:[&_.dropzone-wrapper]:border-[#004FC4]",
      "[&_.upload-item]:border-[#004FC4]"
    ]
  end

  defp dropzone_color("outline", "misc") do
    [
      "text-[#52059C] [&_.dropzone-wrapper]:text-[#52059C]/80 [&_.dropzone-wrapper]:border-[#52059C]/80",
      "hover:[&_.dropzone-wrapper]:text-[#52059C] hover:[&_.dropzone-wrapper]:border-[#52059C]",
      "[&_.upload-item]:border-[#52059C]"
    ]
  end

  defp dropzone_color("outline", "dawn") do
    [
      "text-[#4D4137] [&_.dropzone-wrapper]:text-[#4D4137]/80 [&_.dropzone-wrapper]:border-[#4D4137]/80",
      "hover:[&_.dropzone-wrapper]:text-[#4D4137] hover:[&_.dropzone-wrapper]:border-[#4D4137]",
      "[&_.upload-item]:border-[#4D4137]"
    ]
  end

  defp dropzone_color("outline", "light") do
    [
      "text-[#707483] [&_.dropzone-wrapper]:text-[#707483]/80 [&_.dropzone-wrapper]:border-[#707483]/80",
      "hover:[&_.dropzone-wrapper]:text-[#707483] hover:[&_.dropzone-wrapper]:border-[#707483]",
      "[&_.upload-item]:border-[#707483]"
    ]
  end

  defp dropzone_color("outline", "dark") do
    [
      "text-[#1E1E1E] [&_.dropzone-wrapper]:text-[#1E1E1E]/80 [&_.dropzone-wrapper]:border-[#050404]/80",
      "hover:[&_.dropzone-wrapper]:text-[#1E1E1E] hover:[&_.dropzone-wrapper]:border-[#050404]",
      "[&_.upload-item]:border-[#050404]"
    ]
  end

  defp dropzone_color("default", "white") do
    [
      "[&_.dropzone-wrapper]:bg-white/80 text-[#3E3E3E] [&_.dropzone-wrapper]:border-[#DADADA]/80",
      "[&_.dropzone-wrapper]:text-[#3E3E3E]/80 [&_.upload-item]:border-[#DADADA]",
      "hover:[&_.dropzone-wrapper]:text-[#3E3E3E] hover:[&_.dropzone-wrapper]:border-[#DADADA]",
      "hover:[&_.dropzone-wrapper]:bg-white"
    ]
  end

  defp dropzone_color("default", "primary") do
    [
      "[&_.dropzone-wrapper]:bg-[#4363EC]/80 text-[#4363EC] [&_.dropzone-wrapper]:border-[#2441de]/80",
      "[&_.dropzone-wrapper]:text-white/80 hover:[&_.dropzone-wrapper]:text-white hover:[&_.dropzone-wrapper]:border-[#2441de]",
      "hover:[&_.dropzone-wrapper]:bg-[#4363EC] [&_.upload-item]:border-[#2441de]"
    ]
  end

  defp dropzone_color("default", "secondary") do
    [
      "[&_.dropzone-wrapper]:bg-[#6B6E7C]/80 text-[#6B6E7C] [&_.dropzone-wrapper]:border-[#877C7C]/80",
      "[&_.dropzone-wrapper]:text-white/80 hover:[&_.dropzone-wrapper]:text-white hover:[&_.dropzone-wrapper]:border-[#877C7C]",
      "hover:[&_.dropzone-wrapper]:bg-[#4363EC] [&_.upload-item]:border-[#ECFEF3]"
    ]
  end

  defp dropzone_color("default", "success") do
    [
      "[&_.dropzone-wrapper]:bg-[#ECFEF3]/80 text-[#047857] [&_.dropzone-wrapper]:border-[#6EE7B7]/80",
      "[&_.dropzone-wrapper]:text-[#047857]/80 hover:[&_.dropzone-wrapper]:text-[#047857] hover:[&_.dropzone-wrapper]:border-[#6EE7B7]",
      "hover:[&_.dropzone-wrapper]:bg-[#ECFEF3] [&_.upload-item]:border-[#6EE7B7]"
    ]
  end

  defp dropzone_color("default", "warning") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFF8E6]/80 text-[#FF8B08] [&_.dropzone-wrapper]:border-[#FF8B08]/80",
      "[&_.dropzone-wrapper]:text-[#FF8B08]/80 hover:[&_.dropzone-wrapper]:text-[#FF8B08] hover:[&_.dropzone-wrapper]:border-[#FF8B08]",
      "hover:[&_.dropzone-wrapper]:bg-[#FFF8E6] [&_.upload-item]:border-[#FF8B08]"
    ]
  end

  defp dropzone_color("default", "danger") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFE6E6]/80 text-[#E73B3B] [&_.dropzone-wrapper]:border-[#E73B3B]/80",
      "[&_.dropzone-wrapper]:text-[#E73B3B]/80 hover:[&_.dropzone-wrapper]:text-[#E73B3B] hover:[&_.dropzone-wrapper]:border-[#E73B3B]",
      "hover:[&_.dropzone-wrapper]:bg-[#FFE6E6] [&_.upload-item]:border-[#E73B3B]"
    ]
  end

  defp dropzone_color("default", "info") do
    [
      "[&_.dropzone-wrapper]:bg-[#E5F0FF]/80 text-[#004FC4] [&_.dropzone-wrapper]:border-[#004FC4]/80",
      "[&_.dropzone-wrapper]:text-[#004FC4]/80 hover:[&_.dropzone-wrapper]:text-[#004FC4] hover:[&_.dropzone-wrapper]:border-[#004FC4]",
      "hover:[&_.dropzone-wrapper]:bg-[#E5F0FF] [&_.upload-item]:border-[#004FC4]"
    ]
  end

  defp dropzone_color("default", "misc") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFE6FF]/80 text-[#52059C] [&_.dropzone-wrapper]:border-[#52059C]/80",
      "[&_.dropzone-wrapper]:text-[#52059C]/80 hover:[&_.dropzone-wrapper]:text-[#52059C] hover:[&_.dropzone-wrapper]:border-[#52059C]",
      "hover:[&_.dropzone-wrapper]:bg-[#FFE6FF] [&_.upload-item]:border-[#52059C]"
    ]
  end

  defp dropzone_color("default", "dawn") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFECDA]/80 text-[#4D4137] [&_.dropzone-wrapper]:border-[#4D4137]/80",
      "[&_.dropzone-wrapper]:text-[#4D4137]/80 hover:[&_.dropzone-wrapper]:text-[#4D4137] hover:[&_.dropzone-wrapper]:border-[#4D4137]",
      "hover:[&_.dropzone-wrapper]:bg-[#FFECDA] [&_.upload-item]:border-[#4D4137]"
    ]
  end

  defp dropzone_color("default", "light") do
    [
      "[&_.dropzone-wrapper]:bg-[#E3E7F1]/80 text-[#707483] [&_.dropzone-wrapper]:border-[#707483]/80",
      "[&_.dropzone-wrapper]:text-[#707483]/80 hover:[&_.dropzone-wrapper]:text-[#707483] hover:[&_.dropzone-wrapper]:border-[#707483]",
      "hover:[&_.dropzone-wrapper]:bg-[#E3E7F1] [&_.upload-item]:border-[#707483]"
    ]
  end

  defp dropzone_color("default", "dark") do
    [
      "[&_.dropzone-wrapper]:bg-[#1E1E1E]/80 text-[#1E1E1E] [&_.dropzone-wrapper]:border-[#050404]/80",
      "[&_.dropzone-wrapper]:text-white/80 hover:[&_.dropzone-wrapper]:text-white hover:[&_.dropzone-wrapper]:border-[#050404]",
      "hover:[&_.dropzone-wrapper]:bg-[#1E1E1E] [&_.upload-item]:border-[#050404]"
    ]
  end

  defp dropzone_color("unbordered", "white") do
    [
      "[&_.dropzone-wrapper]:bg-white/80 text-[#3E3E3E] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-[#3E3E3E]/80 [&_.upload-item]:border-[#DADADA]",
      "hover:[&_.dropzone-wrapper]:text-[#3E3E3E]",
      "hover:[&_.dropzone-wrapper]:bg-white"
    ]
  end

  defp dropzone_color("unbordered", "primary") do
    [
      "[&_.dropzone-wrapper]:bg-[#4363EC]/80 text-[#4363EC] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-white/80 hover:[&_.dropzone-wrapper]:text-white",
      "hover:[&_.dropzone-wrapper]:bg-[#4363EC] [&_.upload-item]:border-[#2441de]"
    ]
  end

  defp dropzone_color("unbordered", "secondary") do
    [
      "[&_.dropzone-wrapper]:bg-[#6B6E7C]/80 text-[#6B6E7C] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-white/80 hover:[&_.dropzone-wrapper]:text-white",
      "hover:[&_.dropzone-wrapper]:bg-[#4363EC] [&_.upload-item]:border-[#ECFEF3]"
    ]
  end

  defp dropzone_color("unbordered", "success") do
    [
      "[&_.dropzone-wrapper]:bg-[#ECFEF3]/80 text-[#047857] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-[#047857]/80 hover:[&_.dropzone-wrapper]:text-[#047857]",
      "hover:[&_.dropzone-wrapper]:bg-[#ECFEF3] [&_.upload-item]:border-[#6EE7B7]"
    ]
  end

  defp dropzone_color("unbordered", "warning") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFF8E6]/80 text-[#FF8B08] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-[#FF8B08]/80 hover:[&_.dropzone-wrapper]:text-[#FF8B08]",
      "hover:[&_.dropzone-wrapper]:bg-[#FFF8E6] [&_.upload-item]:border-[#FF8B08]"
    ]
  end

  defp dropzone_color("unbordered", "danger") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFE6E6]/80 text-[#E73B3B] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-[#E73B3B]/80 hover:[&_.dropzone-wrapper]:text-[#E73B3B]",
      "hover:[&_.dropzone-wrapper]:bg-[#FFE6E6] [&_.upload-item]:border-[#E73B3B]"
    ]
  end

  defp dropzone_color("unbordered", "info") do
    [
      "[&_.dropzone-wrapper]:bg-[#E5F0FF]/80 text-[#004FC4] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-[#004FC4]/80 hover:[&_.dropzone-wrapper]:text-[#004FC4]",
      "hover:[&_.dropzone-wrapper]:bg-[#E5F0FF] [&_.upload-item]:border-[#004FC4]"
    ]
  end

  defp dropzone_color("unbordered", "misc") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFE6FF]/80 text-[#52059C] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-[#52059C]/80 hover:[&_.dropzone-wrapper]:text-[#52059C]",
      "hover:[&_.dropzone-wrapper]:bg-[#FFE6FF] [&_.upload-item]:border-[#52059C]"
    ]
  end

  defp dropzone_color("unbordered", "dawn") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFECDA]/80 text-[#4D4137] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-[#4D4137]/80 hover:[&_.dropzone-wrapper]:text-[#4D4137]",
      "hover:[&_.dropzone-wrapper]:bg-[#FFECDA] [&_.upload-item]:border-[#4D4137]"
    ]
  end

  defp dropzone_color("unbordered", "light") do
    [
      "[&_.dropzone-wrapper]:bg-[#E3E7F1]/80 text-[#707483] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-[#707483]/80 hover:[&_.dropzone-wrapper]:text-[#707483]",
      "hover:[&_.dropzone-wrapper]:bg-[#E3E7F1] [&_.upload-item]:border-[#707483]"
    ]
  end

  defp dropzone_color("unbordered", "dark") do
    [
      "[&_.dropzone-wrapper]:bg-[#1E1E1E]/80 text-[#1E1E1E] [&_.dropzone-wrapper]:border-transparent",
      "[&_.dropzone-wrapper]:text-white/80 hover:[&_.dropzone-wrapper]:text-white",
      "hover:[&_.dropzone-wrapper]:bg-[#1E1E1E] [&_.upload-item]:border-[#050404]"
    ]
  end

  defp dropzone_color("shadow", "white") do
    [
      "[&_.dropzone-wrapper]:bg-white/80 text-[#3E3E3E] [&_.dropzone-wrapper]:border-[#DADADA]/80",
      "[&_.dropzone-wrapper]:text-[#3E3E3E]/80 [&_.upload-item]:border-[#DADADA]",
      "hover:[&_.dropzone-wrapper]:text-[#3E3E3E] hover:[&_.dropzone-wrapper]:border-[#DADADA]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-white"
    ]
  end

  defp dropzone_color("shadow", "primary") do
    [
      "[&_.dropzone-wrapper]:bg-[#4363EC]/80 text-[#4363EC] [&_.dropzone-wrapper]:border-[#2441de]/80",
      "[&_.dropzone-wrapper]:text-white/80 hover:[&_.dropzone-wrapper]:text-white hover:[&_.dropzone-wrapper]:border-[#2441de]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-[#4363EC] [&_.upload-item]:border-[#2441de]"
    ]
  end

  defp dropzone_color("shadow", "secondary") do
    [
      "[&_.dropzone-wrapper]:bg-[#6B6E7C]/80 text-[#6B6E7C] [&_.dropzone-wrapper]:border-[#877C7C]/80",
      "[&_.dropzone-wrapper]:text-white/80 hover:[&_.dropzone-wrapper]:text-white hover:[&_.dropzone-wrapper]:border-[#877C7C]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-[#4363EC] [&_.upload-item]:border-[#ECFEF3]"
    ]
  end

  defp dropzone_color("shadow", "success") do
    [
      "[&_.dropzone-wrapper]:bg-[#ECFEF3]/80 text-[#047857] [&_.dropzone-wrapper]:border-[#6EE7B7]/80",
      "[&_.dropzone-wrapper]:text-[#047857]/80 hover:[&_.dropzone-wrapper]:text-[#047857] hover:[&_.dropzone-wrapper]:border-[#6EE7B7]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-[#ECFEF3] [&_.upload-item]:border-[#6EE7B7]"
    ]
  end

  defp dropzone_color("shadow", "warning") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFF8E6]/80 text-[#FF8B08] [&_.dropzone-wrapper]:border-[#FF8B08]/80",
      "[&_.dropzone-wrapper]:text-[#FF8B08]/80 hover:[&_.dropzone-wrapper]:text-[#FF8B08] hover:[&_.dropzone-wrapper]:border-[#FF8B08]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-[#FFF8E6] [&_.upload-item]:border-[#FF8B08]"
    ]
  end

  defp dropzone_color("shadow", "danger") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFE6E6]/80 text-[#E73B3B] [&_.dropzone-wrapper]:border-[#E73B3B]/80",
      "[&_.dropzone-wrapper]:text-[#E73B3B]/80 hover:[&_.dropzone-wrapper]:text-[#E73B3B] hover:[&_.dropzone-wrapper]:border-[#E73B3B]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-[#FFE6E6] [&_.upload-item]:border-[#E73B3B]"
    ]
  end

  defp dropzone_color("shadow", "info") do
    [
      "[&_.dropzone-wrapper]:bg-[#E5F0FF]/80 text-[#004FC4] [&_.dropzone-wrapper]:border-[#004FC4]/80",
      "[&_.dropzone-wrapper]:text-[#004FC4]/80 hover:[&_.dropzone-wrapper]:text-[#004FC4] hover:[&_.dropzone-wrapper]:border-[#004FC4]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-[#E5F0FF] [&_.upload-item]:border-[#004FC4]"
    ]
  end

  defp dropzone_color("shadow", "misc") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFE6FF]/80 text-[#52059C] [&_.dropzone-wrapper]:border-[#52059C]/80",
      "[&_.dropzone-wrapper]:text-[#52059C]/80 hover:[&_.dropzone-wrapper]:text-[#52059C] hover:[&_.dropzone-wrapper]:border-[#52059C]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-[#FFE6FF] [&_.upload-item]:border-[#52059C]"
    ]
  end

  defp dropzone_color("shadow", "dawn") do
    [
      "[&_.dropzone-wrapper]:bg-[#FFECDA]/80 text-[#4D4137] [&_.dropzone-wrapper]:border-[#4D4137]/80",
      "[&_.dropzone-wrapper]:text-[#4D4137]/80 hover:[&_.dropzone-wrapper]:text-[#4D4137] hover:[&_.dropzone-wrapper]:border-[#4D4137]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-[#FFECDA] [&_.upload-item]:border-[#4D4137]"
    ]
  end

  defp dropzone_color("shadow", "light") do
    [
      "[&_.dropzone-wrapper]:bg-[#E3E7F1]/80 text-[#707483] [&_.dropzone-wrapper]:border-[#707483]/80",
      "[&_.dropzone-wrapper]:text-[#707483]/80 hover:[&_.dropzone-wrapper]:text-[#707483] hover:[&_.dropzone-wrapper]:border-[#707483]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-[#E3E7F1] [&_.upload-item]:border-[#707483]"
    ]
  end

  defp dropzone_color("shadow", "dark") do
    [
      "[&_.dropzone-wrapper]:bg-[#1E1E1E]/80 text-[#1E1E1E] [&_.dropzone-wrapper]:border-[#050404]/80",
      "[&_.dropzone-wrapper]:text-white/80 hover:[&_.dropzone-wrapper]:text-white hover:[&_.dropzone-wrapper]:border-[#050404]",
      "[&_.dropzone-wrapper]:shadow [&_.upload-item]:shadow hover:[&_.dropzone-wrapper]:bg-[#1E1E1E] [&_.upload-item]:border-[#050404]"
    ]
  end

  defp translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(MishkaChelekomWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(MishkaChelekomWeb.Gettext, "errors", msg, opts)
    end
  end

  attr :name, :string, required: true, doc: "Specifies the name of the element"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"

  defp icon(%{name: "hero-" <> _, class: class} = assigns) when is_list(class) do
    ~H"""
    <span class={[@name] ++ @class} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
