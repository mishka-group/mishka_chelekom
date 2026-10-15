defmodule DevelopmentWeb.Components.Icon do
  @moduledoc """
  The `DevelopmentWeb.Components.Icon` module renders [Heroicons](https://heroicons.com) in a
  Phoenix LiveView application.

  An icon is a `<span>` that carries the icon's own class (`hero-x-mark`), drawn by the
  Heroicons Tailwind plugin. Only `hero-` names are supported: a name without the prefix
  matches no clause and raises a `FunctionClauseError`.

  ## Examples:

      <.icon name="hero-home" class="size-6" />
      <.icon name="hero-x-mark-solid" class="size-4 text-red-500" />
      <.icon name="hero-arrow-path" class="size-5 animate-spin" aria-hidden="true" />

  ## Attributes:
  - `name` - Required. The Heroicon name with the `hero-` prefix; add `-solid`, `-mini` or
    `-micro` for the other styles
  - `class` - Optional. Classes for size, colour, animation and anything else
  - `rest` - Global attributes passed to the `<span>`, such as `aria-hidden` or `aria-label`

  **Documentation:** https://mishka.tools/chelekom/docs/icon
  """
  use Phoenix.Component

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the Heroicons plugin your `assets/css/app.css` loads.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  @doc type: :component
  attr :name, :string, required: true
  attr :class, :any, default: nil

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} {@rest} />
    """
  end
end
