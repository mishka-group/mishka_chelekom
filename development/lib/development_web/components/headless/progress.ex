defmodule DevelopmentWeb.Components.Headless.Progress do
  @moduledoc """
  Headless **progress** — a determinate progress bar.

  A single `role="progressbar"` element exposes `aria-valuemin="0"`, `aria-valuemax`
  and `aria-valuenow`; the inner indicator carries a `--chelekom-progress` CSS custom
  property (a `0..1` ratio) you can scale/translate in your own styles. Ships **no**
  colors or spacing — style via the `chelekom-progress*` classes. No JS.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/progressbar/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional id"
  attr :value, :integer, required: true, doc: "Current value (between 0 and max)"
  attr :max, :integer, default: 100, doc: "Maximum value"
  attr :label, :string, default: nil, doc: "Accessible label for the progressbar"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  def progress(assigns) do
    ~H"""
    <div
      id={@id}
      role="progressbar"
      aria-valuemin="0"
      aria-valuemax={@max}
      aria-valuenow={@value}
      aria-label={@label}
      class={["chelekom-progress", @class]}
      {@rest}
    >
      <div
        data-part="indicator"
        style={"--chelekom-progress: #{@value / @max}"}
        class="chelekom-progress__indicator"
      >
      </div>
    </div>
    """
  end
end
