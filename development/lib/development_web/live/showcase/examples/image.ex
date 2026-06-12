defmodule DevelopmentWeb.Showcase.Examples.Image do
  @moduledoc """
  Docs examples for the `image` component, taken from the Mishka source docs
  (`mishka/.../docs/image_live.html.heex`). Section headers, no descriptions.

  The doc uses `~p"/images/avatarN.png"` assets that do not exist in this development
  showcase (only `logo.svg` is present), so — following the same convention as the
  `carousel` examples — remote `picsum.photos` placeholder URLs are used as `src` so
  the images actually render.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "default", title: "Default image attributes"},
      %{id: "shadow", title: "Shadow"},
      %{id: "rounded", title: "Rounded"},
      %{id: "filters", title: "Filters"}
    ]
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.image src="https://picsum.photos/seed/chelekom-1/100/100" width={100} height={100} />
    </div>
    """
  end

  def example(%{section: "shadow"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.image
        :for={s <- ~w(extra_small small medium large extra_large)}
        src={"https://picsum.photos/seed/chelekom-shadow-#{s}/80/80"}
        width={80}
        height={80}
        shadow={s}
      />
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.image
        :for={r <- ~w(extra_small small medium large extra_large full)}
        src={"https://picsum.photos/seed/chelekom-rounded-#{r}/80/80"}
        width={80}
        height={80}
        rounded={r}
      />
    </div>
    """
  end

  def example(%{section: "filters"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-5">
      <.image
        :for={f <- ~w(blur brightness contrast hue saturation)}
        src={"https://picsum.photos/seed/chelekom-filter-#{f}/80/80"}
        width={80}
        height={80}
        filter={f}
        filter_size="extra_small"
      />
      <.image
        :for={f <- ~w(grayscale invert sepia)}
        src={"https://picsum.photos/seed/chelekom-filter-#{f}/80/80"}
        width={80}
        height={80}
        filter={f}
      />
    </div>
    """
  end

  def example(assigns), do: ~H""
end
