defmodule MishkaChelekom.Modal do
  @moduledoc """
  The `MishkaChelekom.Modal` module provides a versatile and customizable modal component for
  Phoenix LiveView applications. It supports various configurations for size, style, color,
  padding, and border radius to match different design requirements. The module is designed
  to facilitate user interactions with dynamic content, such as forms,
  confirmation dialogs, or notifications.

  The modal component includes JavaScript hooks for showing and hiding the modal,
  which are triggered based on user actions or programmatic events.

  The component is equipped to handle accessibility features like focus management
  and keyboard navigation to ensure a seamless user experience.

  This module can be integrated with other components and tailored for various use cases
  in web applications, making it a powerful tool for enhancing user interfaces and interaction workflows.
  """

  use Phoenix.Component
  import MishkaChelekomWeb.Gettext
  alias Phoenix.LiveView.JS

  @sizes [
    "extra_small",
    "small",
    "medium",
    "large",
    "extra_large",
    "double_large",
    "triple_large",
    "quadruple_large"
  ]
  @colors [
    "white",
    "primary",
    "secondary",
    "dark",
    "success",
    "warning",
    "danger",
    "info",
    "light",
    "misc",
    "dawn"
  ]

  @variants [
    "default",
    "outline",
    "transparent",
    "shadow",
    "unbordered"
  ]

  @doc """
  Renders a customizable `modal` component that displays overlay content with optional title and inner content.
  It can be controlled with the `show` attribute and includes actions for closing the modal.

  ## Examples

  ```elixir
  <.modal id="modal-1" title="default">
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit.
      Commodi ea atque soluta praesentium quidem dicta sapiente accusamus nihil.
    </div>
  </.modal>

  <.modal id="modal-2" title="Info Modal" show>
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit.
      Commodi ea atque soluta praesentium quidem dicta sapiente accusamus nihil.
    </div>
  </.modal>

  <.modal id="modal-3" color="primary" rounded="large" title="Custom Modal">
    <p>Customize the modal appearance by changing attributes like `color` and `rounded`.</p>
  </.modal>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :title, :string, doc: "Specifies the title of the element"
  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :rounded, :string, values: @sizes, default: "small", doc: "Determines the border radius"

  attr :padding, :string,
    values: @sizes ++ ["none"],
    default: "medium",
    doc: "Determines padding for items"

  attr :size, :string,
    values: @sizes ++ ["screen"],
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :show, :boolean, default: false, doc: "Show element"
  attr :on_cancel, JS, default: %JS{}, doc: "Custom JS module for on_cancel action"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-zinc-50/90 fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class={[
                "relative hidden transition",
                color_variant(@variant, @color),
                rounded_size(@rounded),
                padding_size(@padding),
                size_class(@size)
              ]}
            >
              <div class="flex items-center justify-between mb-4">
                <div :if={@title} class="font-semibold text-base md:text-lg xl:text-2xl">
                  <%= @title %>
                </div>
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="p-2 hover:opacity-60"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="size-5" />
                </button>
              </div>

              <div id={"#{@id}-content"}>
                <%= render_slot(@inner_block) %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  ## JS Commands
  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      time: 300,
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> transition_show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> transition_hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  defp transition_show(js, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  defp transition_hide(js, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size(_), do: nil

  defp padding_size("extra_small"), do: "p-2"
  defp padding_size("small"), do: "p-3"
  defp padding_size("medium"), do: "p-4"
  defp padding_size("large"), do: "p-5"
  defp padding_size("extra_large"), do: "p-6"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp size_class("extra_small"), do: "mx-auto max-w-xs"
  defp size_class("small"), do: "mx-auto max-w-sm"
  defp size_class("medium"), do: "mx-auto max-w-md"
  defp size_class("large"), do: "mx-auto max-w-lg"
  defp size_class("extra_large"), do: "mx-auto max-w-xl"
  defp size_class("double_large"), do: "mx-auto max-w-2xl"
  defp size_class("triple_large"), do: "mx-auto max-w-3xl"
  defp size_class("quadruple_large"), do: "mx-auto max-w-4xl"
  defp size_class("screen"), do: "w-full h-screen overflow-y-scroll"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_large")

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border border-[#4363EC] "
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border border-[#1E1E1E]"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E]"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857]"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08]"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B]"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4]"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C]"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137]"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483]"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC]"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C]"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52]"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08]"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B]"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD]"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C]"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137]"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483]"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E]"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border border-[#DADADA] shadow"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border border-[#4363EC] shadow"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border border-[#6B6E7C] shadow"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border border-[#AFEAD0] shadow"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border border-[#FFF8E6] shadow"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border border-[#FFE6E6] shadow"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border border-[#E5F0FF] shadow"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border border-[#FFE6FF] shadow"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border border-[#FFECDA] shadow"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border border-[#E3E7F1] shadow"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border border-[#1E1E1E] shadow"
  end

  defp color_variant(_, _), do: color_variant("default", "white")

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
