defmodule MishkaMob.Components.MishkaAngleSlider do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Angle Slider** — a circular
  dial for choosing an angle, 0–360°, with 0° pointing up and the value
  increasing clockwise.

  ## A real dial, and a slider to turn it

  The dial is drawn on `Mob.UI.canvas/1`: a track ring, a filled arc from 12
  o'clock to the current angle, a handle on the circle, and the reading in the
  middle. That is the actual control the web component draws.

  What Mob cannot give it is a *rotational gesture* — there are no pointer
  coordinates delivered to `render/1`, so nothing can hit-test a finger against
  the ring. So the dial is the display and a native `Slider` beneath it is the
  control. Both read the same number; the dial cannot drift from the slider.
  When Mob grows a pan gesture with coordinates, this component gains dragging
  without changing its API.

  ## Angles

  Screen space measures 0° at three o'clock and canvas arcs sweep clockwise, so
  an angle of `a` sits at `a - 90` on the canvas. `point_on_dial/4` does that
  conversion once, and is public so a test can check the compass points rather
  than trusting the trigonometry by eye.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | number | `0` | Angle in degrees. Wraps. |
  | `size` | number | `160` | Dial diameter in logical units. |
  | `show_value` | boolean | `true` | Draw the `45°` reading in the centre. |
  | `label` | string | `nil` | Caption above the dial. |
  | `color` | ARGB int | `:primary`-ish blue | Arc and handle colour. |
  | `on_change` | event tag (atom) | — | `{:change, tag, float}` while dragging. |

  Not ported: `step` (keyboard nudging — snap in the screen with
  `MishkaMob.Components.MishkaSlider.snap/2`), `disabled`, and `name`/`form`/`id`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Color, Event}

  @size 160
  @ring 10
  @knob_stroke 3
  # Barely proud of the @ring-wide track (63.5..76.5 against 65..75) — enough to
  # read as a grabbable knob, not so much that it floats off the progress.
  @knob 5
  @accent 0xFF_3B_82_F6
  @track 0xFF_D1_D5_DB

  @doc "Composite expander (`<MishkaAngleSlider />`). Delegates to `angle_slider/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: angle_slider(props)

  @doc """
  The angle slider.

      angle_slider(value: @angle, on_change: :angle)
  """
  @spec angle_slider(map() | keyword()) :: map()
  def angle_slider(props \\ %{}) do
    props = Map.new(props)
    angle = normalize_angle(Map.get(props, :value, 0))
    size = Map.get(props, :size, @size)

    dial = Mob.UI.canvas(width: size, height: size, draw: dial(size, angle, props))

    control =
      ~MOB(<Slider min={0} max={360} value={angle} />)
      |> put(:on_change, Event.handler(Map.get(props, :on_change)))

    head = header(Map.get(props, :label))

    ~MOB"""
    <Column fill_width={true} align={:center}>
      {head}
      {dial}
      <Spacer size={4} />
      {control}
    </Column>
    """
  end

  @doc """
  Draw ops for the dial at `angle`.

      iex> ops = MishkaMob.Components.MishkaAngleSlider.dial(100, 90, %{})
      iex> Enum.any?(ops, &(&1.op == :arc))
      true
  """
  @spec dial(number(), number(), map()) :: [map()]
  def dial(size, angle, props) do
    center = size / 2
    radius = center - @ring
    accent = Map.get(props, :color, @accent)

    ring =
      [Mob.Canvas.circle(center, center, radius, color: @track, width: @ring)] ++
        arc(center, radius, angle, accent)

    ring ++ handle(center, radius, angle, accent) ++ reading(center, angle, props)
  end

  # A zero-degree sweep still paints a cap-sized blob, so skip the arc entirely.
  # 360° and 0° are the same angle but NOT the same position. wrap_hue/1 is fmod,
  # and fmod(360.0, 360.0) is 0.0 — which sent a full sweep back to zero and, via
  # the guard below, erased the dial entirely. Wrap only genuinely out-of-range
  # input; Color.hsv_to_rgb/3 wraps for the colour maths anyway.
  defp normalize_angle(v) when is_number(v) and v >= 0 and v <= 360, do: v * 1.0
  defp normalize_angle(v), do: Color.wrap_hue(v)

  defp arc(_center, _radius, angle, _accent) when angle == 0, do: []

  defp arc(center, radius, angle, accent) do
    [
      Mob.Canvas.arc(center, center, radius, -90, angle - 90,
        color: accent,
        width: @ring,
        cap: :round
      )
    ]
  end

  # Sized to sit INSIDE the track, not to straddle it. The ring is @ring wide, so
  # it occupies radius ± @ring/2; a knob of r + stroke/2 beyond that overhangs on
  # both sides and reads as a circle floating off the progress rather than riding
  # it. @knob is chosen so the outer edge lands exactly on the ring's outer edge.
  defp handle(center, radius, angle, accent) do
    {x, y} = point_on_dial(center, center, radius, angle)

    [
      Mob.Canvas.circle(x, y, @knob, color: 0xFF_FF_FF_FF, fill: true),
      Mob.Canvas.circle(x, y, @knob, color: accent, width: @knob_stroke)
    ]
  end

  defp reading(center, angle, props) do
    if truthy?(Map.get(props, :show_value, true)) do
      [
        Mob.Canvas.text(center, center - 11, "#{round(angle)}°",
          size: 22,
          color: Map.get(props, :text_color, :on_surface),
          weight: :semibold,
          anchor: :center
        )
      ]
    else
      []
    end
  end

  @doc """
  The point at `angle` on a circle of `radius` about `(cx, cy)`, with 0°
  pointing **up** and increasing **clockwise**.

      iex> MishkaMob.Components.MishkaAngleSlider.point_on_dial(50, 50, 40, 0)
      {50.0, 10.0}

      iex> MishkaMob.Components.MishkaAngleSlider.point_on_dial(50, 50, 40, 90)
      {90.0, 50.0}

      iex> MishkaMob.Components.MishkaAngleSlider.point_on_dial(50, 50, 40, 180)
      {50.0, 90.0}
  """
  @spec point_on_dial(number(), number(), number(), number()) :: {float(), float()}
  def point_on_dial(cx, cy, radius, angle) do
    radians = (angle - 90) * :math.pi() / 180

    {round_to(cx + radius * :math.cos(radians)), round_to(cy + radius * :math.sin(radians))}
  end

  # Trig leaves 6.1e-15 where a 0 belongs; that is noise in a coordinate, and it
  # makes doctests and assertions unreadable.
  defp round_to(value), do: Float.round(value * 1.0, 6)

  defp header(nil), do: nil

  defp header(label) do
    ~MOB"""
    <Column>
      <Text text={label} text_size={:sm} text_color={:on_surface} />
      <Spacer size={6} />
    </Column>
    """
  end

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
