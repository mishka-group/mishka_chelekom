defmodule DevelopmentWeb.Components.Headless.SemiCircleProgress do
  @moduledoc """
  Headless **semi-circle progress** — a half-circle gauge (Mantine SemiCircleProgress parity).

  Renders a `role="progressbar"` with an SVG arc; the filled arc is computed at **render
  time** from `value` (via `stroke-dasharray`/`stroke-dashoffset`) — no JS. Set the arc colors and
  thickness with `stroke`/`stroke-width` on the `track`/`indicator` parts; size the `svg` part
  yourself (e.g. `w-full`); put a readout in the slot.

  `shape` picks the sweep: `"semi"` (default) is the half-circle gauge, `"full"` closes it into a
  ring — daisyUI's `radial-progress` shape — on a square viewBox.

  Ships **no** styling — style via `chelekom-semi-circle-progress*`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/semi_circle_progress
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"
  attr :value, :any, default: 0, doc: "Current value"
  attr :min, :integer, default: 0, doc: "Minimum value"
  attr :max, :integer, default: 100, doc: "Maximum value"
  attr :label, :string, default: nil, doc: "Accessible label (aria-label)"

  attr :shape, :string,
    default: "semi",
    values: ~w(semi full),
    doc: ~s|"semi" is the half-circle gauge; "full" closes the arc into a ring|

  attr :class, :any, default: nil, doc: "Extra classes for the root"

  attr :svg_class, :any,
    default: nil,
    doc: "Extra classes for the svg (size it here, e.g. w-full)"

  attr :track_class, :any, default: nil, doc: "Extra classes for the background arc"
  attr :indicator_class, :any, default: nil, doc: "Extra classes for the filled arc"
  attr :label_class, :any, default: nil, doc: "Extra classes for the readout"
  attr :rest, :global

  slot :inner_block, doc: "Optional centered readout"

  def semi_circle_progress(assigns) do
    value = to_num(assigns.value)
    span = max(assigns.max - assigns.min, 1)
    frac = min(max(value - assigns.min, 0), span) / span
    full? = assigns.shape == "full"
    circ = Float.round(:math.pi() * 90 * ((full? && 2) || 1), 3)

    assigns =
      assign(assigns,
        value: value,
        circ: circ,
        offset: Float.round(circ * (1 - frac), 3),
        view_box: (full? && "0 0 200 200") || "0 0 200 108",
        arc:
          (full? && "M 100 10 A 90 90 0 1 1 99.99 10") ||
            "M 10 100 A 90 90 0 0 1 190 100"
      )

    ~H"""
    <div
      id={@id}
      role="progressbar"
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@value}
      aria-label={@label}
      class={["chelekom-semi-circle-progress", @class]}
      {@rest}
    >
      <svg
        data-part="svg"
        viewBox={@view_box}
        fill="none"
        class={["chelekom-semi-circle-progress__svg", @svg_class]}
      >
        <path
          data-part="track"
          d={@arc}
          class={["chelekom-semi-circle-progress__track", @track_class]}
        />
        <path
          data-part="indicator"
          d={@arc}
          stroke-dasharray={@circ}
          stroke-dashoffset={@offset}
          stroke-linecap="round"
          class={["chelekom-semi-circle-progress__indicator", @indicator_class]}
        />
      </svg>
      <div
        :if={@inner_block != []}
        data-part="label"
        class={["chelekom-semi-circle-progress__label", @label_class]}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp to_num(v) when is_number(v), do: v

  defp to_num(v) when is_binary(v) do
    case Float.parse(v) do
      {f, _} -> f
      :error -> 0
    end
  end

  defp to_num(_), do: 0
end
