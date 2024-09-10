defmodule MishkaChelekom.Carousel do
  use Phoenix.Component
  import MishkaChelekomComponents
  alias Phoenix.LiveView.JS

  @doc type: :component
  attr :id, :string, required: true, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :overlay, :string, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :padding, :string, default: "medium", doc: ""
  attr :text_position, :string, default: "center", doc: ""
  attr :rest, :global, doc: ""
  attr :indicator, :boolean, default: true
  attr :control, :boolean, default: true

  slot :inner_block, required: false, doc: ""

  slot :slide, required: true do
    attr :image, :string
    attr :image_class, :string
    attr :link, :string
    attr :title, :string
    attr :description, :string
    attr :title_class, :string
    attr :description_class, :string
    attr :wrapper_class, :string
    attr :content_position, :string
    attr :class, :string
    attr :active, :boolean, doc: ""
  end

  def carousel(assigns) do
    assigns =
      assign_new(assigns, :mounted_active_carousel, fn ->
        Enum.find(assigns.slide, &Map.get(&1, :active))
      end)

    ~H"""
    <div>
      <div
        id={@id}
        phx-mounted={
          is_nil(@mounted_active_carousel) &&
            unselect_carousel(@id, length(@slide)) |> select_carousel(@id, 1)
        }
        class={[
          "relative w-full",
          "[&_.slide]:absolute [&_.slide]:inset-0 [&_.slide]:opacity-0 [&_.slide.active-slide]:opacity-100",
          "[&_.slide]:transition-all [&_.slide]:delay-75 [&_.slide]:duration-1000 [&_.slide]:ease-in-out",
          text_position(@text_position),
          padding_size(@padding),
          color_class(@overlay),
          size_class(@size)
        ]}
      >
        <div
          :for={{slide, index} <- Enum.with_index(@slide, 1)}
          id={"#{@id}-carousel-slide-#{index}"}
          class={["slide h-full", slide[:class]]}
          phx-mounted={
            slide[:active] && unselect_carousel(@id, length(@slide)) |> select_carousel(@id, index)
          }
        >
          <div class="relative w-full">
            <div
              :if={@control}
              class={[
                "carousel-button-wrapper drop-shadow-2xl w-fit absolute top-0 bottom-0 left-0 p-5 flex justify-center items-center",
                "z-20 text-white transition-all ease-in-out duration-300 hover:bg-black/5"
              ]}
            >
              <button
                id={"#{@id}-carousel-pervious-btn-#{index}"}
                phx-click={
                  index - 1 != 0 &&
                    unselect_carousel(@id, length(@slide)) |> select_carousel(@id, index - 1)
                }
              >
                <.icon name="hero-chevron-left" class="size-5 md:size-7 lg:size-9" />
              </button>
            </div>

            <.link :if={!is_nil(slide[:link])} navigate={slide[:link]}>
              <MishkaChelekom.Image.image
                class="max-w-full"
                src={slide[:image]}
                id={"#{@id}-carousel-slide-image-#{index}"}
              />
            </.link>

            <MishkaChelekom.Image.image
              :if={is_nil(slide[:link])}
              class="max-w-full"
              src={slide[:image]}
              id={"#{@id}-carousel-slide-image-#{index}"}
            />

            <div
              :if={!is_nil(slide[:title]) || !is_nil(slide[:description])}
              class="carousel-overlay absolute inset-0"
              id={"#{@id}-carousel-slide-content-#{index}"}
            >
              <div
                class={[
                  "description-wrapper h-full mx-auto flex flex-col gap-5",
                  content_position(slide[:content_position]),
                  slide[:wrapper_class]
                ]}
                id={"#{@id}-carousel-slide-content-position-#{index}"}
              >
                <div
                  :if={!is_nil(slide[:title])}
                  id={"#{@id}-carousel-slide-content-title-#{index}"}
                  class={["carousel-title", slide[:title_class] || "text-white"]}
                >
                  <%= slide[:title] %>
                </div>
                <p
                  :if={!is_nil(slide[:description])}
                  id={"#{@id}-carousel-slide-content-description-#{index}"}
                  class={["carousel-description", slide[:description_class]]}
                >
                  <%= slide[:description] %>
                </p>
              </div>
            </div>

            <div
              :if={@control}
              class={[
                "carousel-button-wrapper drop-shadow-2xl w-fit absolute top-0 bottom-0 right-0 p-5 flex justify-center items-center",
                "z-20 text-white transition-all ease-in-out duration-300"
              ]}
            >
              <button
                id={"#{@id}-carousel-next-btn-#{index}"}
                phx-click={
                  index + 1 <= length(@slide) &&
                    unselect_carousel(@id, length(@slide)) |> select_carousel(@id, index + 1)
                }
              >
                <.icon name="hero-chevron-right" class="size-5 md:size-7 lg:size-9" />
              </button>
            </div>

            <div
              :if={@indicator}
              id={"#{@id}-carousel-slide-indicator-#{index}"}
              class="absolute inset-x-0 bottom-0 z-50 flex justify-center gap-3 py-2.5"
            >
              <button
                :for={indicator_item <- 1..length(@slide)}
                data-indicator-index={"#{indicator_item}"}
                phx-click={
                  unselect_carousel(@id, length(@slide))
                  |> select_carousel(@id, indicator_item)
                  |> JS.add_class("active-indicator")
                }
                class={[
                  "carousel-indicator",
                  "h-1 w-6",
                  "border-solid border-transparent bg-white bg-clip-padding p-0",
                  "opacity-70 transition-opacity duration-[600ms] ease-[cubic-bezier(0.25,0.1,0.25,1.0)]",
                  "motion-reduce:transition-none",
                  "[&.active-indicator]opacity-100"
                ]}
                aria-label={
                  Map.get(Enum.at(@slide, indicator_item - 1), :title, "Slide #{indicator_item}")
                }
                aria-current={indicator_item == index && "true"}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp size_class("extra_small"),
    do:
      "text-xs [&_.description-wrapper]:max-w-80 [&_.carousel-title]:md:text-xl [&_.carousel-title]:md:text-3xl"

  defp size_class("small"),
    do:
      "text-sm [&_.description-wrapper]:max-w-96 [&_.carousel-title]:md:text-xl [&_.carousel-title]:md:text-4xl"

  defp size_class("medium"),
    do:
      "text-base [&_.description-wrapper]:max-w-xl [&_.carousel-title]:md:text-2xl [&_.carousel-title]:md:text-5xl"

  defp size_class("large"),
    do:
      "text-lg [&_.description-wrapper]:max-w-2xl [&_.carousel-title]:md:text-3xl [&_.carousel-title]:md:text-6xl"

  defp size_class("extra_large"),
    do:
      "text-xl [&_.description-wrapper]:max-w-3xl [&_.carousel-title]:md:text-3xl [&_.carousel-title]:md:text-7xl"

  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp padding_size("extra_small"),
    do: "[&_.description-wrapper]:p-2.5 md:[&_.description-wrapper]:p-6"

  defp padding_size("small"), do: "[&_.description-wrapper]:p-3 md:[&_.description-wrapper]:p-7"

  defp padding_size("medium"),
    do: "[&_.description-wrapper]:p-3.5 md:[&_.description-wrapper]:p-8"

  defp padding_size("large"), do: "[&_.description-wrapper]:p-4 md:[&_.description-wrapper]:p-9"

  defp padding_size("extra_large"),
    do: "[&_.description-wrapper]:p-5 md:[&_.description-wrapper]:p-10"

  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("medium")

  defp content_position("start") do
    "justify-start"
  end

  defp content_position("end") do
    "justify-end"
  end

  defp content_position("center") do
    "justify-center"
  end

  defp content_position("between") do
    "justify-between"
  end

  defp content_position("around") do
    "justify-around"
  end

  defp content_position(_), do: content_position("center")

  defp text_position("start") do
    "[&_.description-wrapper]:text-start"
  end

  defp text_position("end") do
    "[&_.description-wrapper]:text-end"
  end

  defp text_position("center") do
    "[&_.description-wrapper]:text-center"
  end

  defp text_position(_), do: text_position("center")

  defp color_class("white") do
    "[&_.carousel-overlay]:bg-white/30 text-[#3E3E3E] hover:[&_.carousel-button-wrapper]:bg-white/5"
  end

  defp color_class("primary") do
    "[&_.carousel-overlay]:bg-[#4363EC]/30 text-white hover:[&_.carousel-button-wrapper]:bg-[#4363EC]/5"
  end

  defp color_class("secondary") do
    "[&_.carousel-overlay]:bg-[#6B6E7C]/30 text-white hover:[&_.carousel-button-wrapper]:bg-[#6B6E7C]/5"
  end

  defp color_class("success") do
    "[&_.carousel-overlay]:bg-[#ECFEF3]/30 text-[#047857] hover:[&_.carousel-button-wrapper]:bg-[#ECFEF3]/5"
  end

  defp color_class("warning") do
    "[&_.carousel-overlay]:bg-[#FFF8E6]/30 text-[#FF8B08] hover:[&_.carousel-button-wrapper]:bg-[#FFF8E6]/5"
  end

  defp color_class("danger") do
    "[&_.carousel-overlay]:bg-[#FFE6E6]/30 text-[#E73B3B] hover:[&_.carousel-button-wrapper]:bg-[#FFE6E6]/5"
  end

  defp color_class("info") do
    "[&_.carousel-overlay]:bg-[#E5F0FF]/30 text-[#004FC4] hover:[&_.carousel-button-wrapper]:bg-[#E5F0FF]/5"
  end

  defp color_class("misc") do
    "[&_.carousel-overlay]:bg-[#FFE6FF]/30 text-[#52059C] hover:[&_.carousel-button-wrapper]:bg-[#FFE6FF]/5"
  end

  defp color_class("dawn") do
    "[&_.carousel-overlay]:bg-[#FFECDA]/30 text-[#4D4137] hover:[&_.carousel-button-wrapper]:bg-[#FFECDA]/5"
  end

  defp color_class("light") do
    "[&_.carousel-overlay]:bg-[#E3E7F1]/30 text-[#707483] hover:[&_.carousel-button-wrapper]:bg-[#E3E7F1]/5"
  end

  defp color_class("dark") do
    "[&_.carousel-overlay]:bg-[#1E1E1E]/30 text-white hover:[&_.carousel-button-wrapper]:bg-[#1E1E1E]/5"
  end

  def select_carousel(js \\ %JS{}, id, count) when is_binary(id) do
    JS.add_class(js, "active-slide",
      to: "##{id}-carousel-slide-#{count}",
      transition: "duration-0"
    )
    |> JS.remove_attribute("disabled", to: "##{id}-carousel-pervious-btn-#{count}")
    |> JS.remove_attribute("disabled", to: "##{id}-carousel-next-btn-#{count}")
  end

  def unselect_carousel(js \\ %JS{}, id, count) do
    Enum.reduce(1..count, js, fn item, acc ->
      acc
      |> JS.set_attribute({"disabled", "true"}, to: "##{id}-carousel-pervious-btn-#{item}")
      |> JS.set_attribute({"disabled", "true"}, to: "##{id}-carousel-next-btn-#{item}")
      |> JS.remove_class("active-slide",
        to: "##{id}-carousel-slide-#{item}",
        transition: "duration-0"
      )
      |> JS.remove_class("active-indicator", to: ".carousel-indicator")
    end)
  end
end
