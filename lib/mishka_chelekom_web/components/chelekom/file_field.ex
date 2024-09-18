defmodule MishkaChelekom.FileField do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :label_class, :string, default: nil, doc: ""
  attr :color, :string, default: "primary", doc: ""
  attr :rounded, :string, default: "small", doc: ""
  attr :live, :boolean, default: false, doc: ""
  attr :space, :string, default: "medium", doc: ""
  attr :size, :string, default: "extra_small", doc: ""
  attr :error_icon, :string, default: nil, doc: ""
  attr :dropzone, :boolean, default: false, doc: ""
  attr :label, :string, default: nil
  attr :errors, :list, default: []
  attr :name, :any
  attr :value, :any

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form for example: @form[:email]"

  attr :rest, :global,
    include:
      ~w(autocomplete disabled form checked multiple readonly min max step required title autofocus)

  @spec file_field(map()) :: Phoenix.LiveView.Rendered.t()
  def file_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> file_field()
  end

  def file_field(%{dropzone: true} = assigns) do
    ~H"""
    <.label :if={@label} for={@id}><%= @label %></.label>

    <div>
          <div class="flex items-center justify-center w-full">
            <label
              for="dropzone"
              class="group flex flex-col items-center justify-center w-full h-64 border border-custome-100 hover:border-custome-black-100 border-dashed rounded cursor-pointer bg-gray-50 hover:bg-custome-gray-200"
            >
              <div
                class="flex flex-col gap-3 items-center justify-center pt-5 pb-6 text-custome-black-100/60 group-hover:text-custome-black-100"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-16 h-16"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M12 16.5V9.75m0 0 3 3m-3-3-3 3M6.75 19.5a4.5 4.5 0 0 1-1.41-8.775 5.25 5.25 0 0 1 10.233-2.33 3 3 0 0 1 3.758 3.848A3.752 3.752 0 0 1 18 19.5H6.75Z"
                  />
                </svg>
                <p class="mb-2 font-semibold">
                  <span class="underline">Click to uplaod</span> or drap and
                  drop a file
                </p>
                <p>Maximum file size of 50MB.</p>
              </div>
              <input id="dropzone" type="file" class="hidden" />
            </label>
          </div>
          <div class="mt-5 space-y-4">
            <div
              class="shadow-custom-main-shadow relative border border-custome-gray-100 hover:border-custome-black-100 rounded p-3 flex justify-around gap-3"
            >
              <div>
                <!-- preview -->
                <img
                  src="../../image/placeholder.svg"
                  class="w-10 h-10 rounded"
                  alt=""
                />
              </div>
              <div class="w-full space-y-2">
                <div>Test.mp4</div>
                <div>20 <span>MB</span></div>
                <div class="flex justify-between gap-3 items-center">
                  <!-- progressbar -->
                  <div
                    role="progressbar"
                    class="bg-custome-gray-100 rounded-full w-full overflow-hidden relative h-2 flex items-center justify-start"
                  >
                    <div class="bg-custome-black-100/75 h-full w-1/2"></div>
                  </div>
                  <div><span>50</span>%</div>
                </div>
              </div>
              <button
                class="absolute top-2 right-2 text-custome-black-100/60 hover:text-custome-black-100"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M6 18 18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
            <div
              class="shadow-custom-main-shadow relative border border-custome-gray-100 hover:border-custome-black-100 rounded p-3 flex items-start justify-around gap-3"
            >
              <div
                class="p-2 rounded bg-custome-gray-100 text-custome-gray-300"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-6 h-6"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="m15.75 10.5 4.72-4.72a.75.75 0 0 1 1.28.53v11.38a.75.75 0 0 1-1.28.53l-4.72-4.72M4.5 18.75h9a2.25 2.25 0 0 0 2.25-2.25v-9a2.25 2.25 0 0 0-2.25-2.25h-9A2.25 2.25 0 0 0 2.25 7.5v9a2.25 2.25 0 0 0 2.25 2.25Z"
                  />
                </svg>
              </div>
              <div class="w-full space-y-2">
                <div>Test.mp4</div>
                <div>20 <span>MB</span></div>
                <div class="flex justify-between gap-3 items-center">
                  <!-- progressbar -->
                  <div
                    role="progressbar"
                    class="bg-custome-gray-100 rounded-full w-full overflow-hidden relative h-2 flex items-center justify-start"
                  >
                    <div class="bg-custome-black-100/45 h-full w-1/3"></div>
                  </div>
                  <div><span>30</span>%</div>
                </div>
              </div>
              <button
                class="absolute top-2 right-2 text-custome-black-100/60 hover:text-custome-black-100"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M6 18 18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
          </div>
        </div>
    """
  end

  def file_field(assigns) do
    ~H"""
    <div class={[
      color_class(@color),
      rounded_size(@rounded),
      space_class(@space),
      @class
    ]}>
      <.label for={@id}><%= @label %></.label>

      <%= if @live do %>
        <.live_file_input
          class={[
            "file-input block w-full cursor-pointer focus:outline-none file:border-0 file:cursor-pointer",
            "file:py-3 file:px-8 file:font-bold file:-ms-4 file:me-4"
          ]}
          {@rest}
        />
      <% else %>
        <input
          class={[
            "file-input block w-full cursor-pointer focus:outline-none file:border-0 file:cursor-pointer",
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

  attr :for, :string, default: nil
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class={["block text-sm font-semibold leading-6", @class]}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  attr :icon, :string, default: nil
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex items-center gap-3 text-sm leading-6 text-rose-700">
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" /> <%= render_slot(@inner_block) %>
    </p>
    """
  end

  defp rounded_size("extra_small"), do: "[&_.file-input]:rounded-sm"
  defp rounded_size("small"), do: "[&_.file-input]:rounded"
  defp rounded_size("medium"), do: "[&_.file-input]:rounded-md"
  defp rounded_size("large"), do: "[&_.file-input]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.file-input]:rounded-xl"
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
      "[&_.file-input]:bg-white file:[&_.file-input]:text-[#DADADA] file:[&_.file-input]:bg-[#DADADA]"
    ]
  end

  defp color_class("primary") do
    [
      "[&_.file-input]:bg-[#4363EC] file:[&_.file-input]:text-white [&_.file-input]:text-white file:[&_.file-input]:bg-[#2441de]"
    ]
  end

  defp color_class("secondary") do
    [
      "[&_.file-input]:bg-[#877C7C] file:[&_.file-input]:text-white [&_.file-input]:text-white file:[&_.file-input]:bg-[#6B6E7C]"
    ]
  end

  defp color_class("success") do
    [
      "[&_.file-input]:bg-[#ECFEF3] file:[&_.file-input]:text-white [&_.file-input]:text-[#047857] file:[&_.file-input]:bg-[#047857]"
    ]
  end

  defp color_class("warning") do
    [
      "[&_.file-input]:bg-[#FFF8E6] file:[&_.file-input]:text-white [&_.file-input]:text-[#FF8B08] file:[&_.file-input]:bg-[#FF8B08]"
    ]
  end

  defp color_class("danger") do
    [
      "[&_.file-input]:bg-[#FFE6E6] [&_.file-input]:text-[#E73B3B] file:[&_.file-input]:text-white file:[&_.file-input]:bg-[#E73B3B]"
    ]
  end

  defp color_class("info") do
    [
      "[&_.file-input]:bg-[#E5F0FF] file:[&_.file-input]:text-white [&_.file-input]:text-[#004FC4] file:[&_.file-input]:bg-[#004FC4]"
    ]
  end

  defp color_class("misc") do
    [
      "[&_.file-input]:bg-[#FFE6FF] file:[&_.file-input]:text-white [&_.file-input]:text-[#52059C] file:[&_.file-input]:bg-[#52059C]"
    ]
  end

  defp color_class("dawn") do
    [
      "[&_.file-input]:bg-[#FFECDA] file:[&_.file-input]:text-white [&_.file-input]:text-[#4D4137] file:[&_.file-input]:bg-[#4D4137]"
    ]
  end

  defp color_class("light") do
    [
      "[&_.file-input]:bg-[#E3E7F1] file:[&_.file-input]:text-white [&_.file-input]:text-[#707483] file:[&_.file-input]:bg-[#707483]"
    ]
  end

  defp color_class("dark") do
    [
      "[&_.file-input]:bg-[#383838] file:[&_.file-input]:text-white [&_.file-input]:text-white file:[&_.file-input]:bg-[#1E1E1E]"
    ]
  end
end
