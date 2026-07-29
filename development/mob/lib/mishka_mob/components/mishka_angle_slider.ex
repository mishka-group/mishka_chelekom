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
  | `text_color` | color token / ARGB int | `:on_surface` | Colour of the centre reading. |
  | `color` | ARGB int | `:primary`-ish blue | Arc and handle colour. |
  | `on_change` | event tag (atom) | — | `{:drag, tag, %{x:, y:, phase:}}` — a touch POSITION. Convert with `angle_at/3`, which returns `:dead` near the centre. |

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

    dial =
      canvas_node(size, dial(size, angle, props), Event.handler(Map.get(props, :on_change)))

    head = header(Map.get(props, :label))

    ~MOB"""
    <Column fill_width={true} align={:center}>
      {head}
      {dial}
    </Column>
    """
  end

  @doc """
  The angle a touch at `{x, y}` selects on a dial of `size`, 0° up and increasing
  clockwise — the inverse of `point_on_dial/4`.

  Returns `:dead` inside the centre disc, where the angle is numerically wild and
  no user meant anything by it. A fingertip resting near the middle would
  otherwise spin the value through a full turn over a few pixels.

      iex> MishkaMob.Components.MishkaAngleSlider.angle_at(80, 10, 160)
      0.0

      iex> MishkaMob.Components.MishkaAngleSlider.angle_at(150, 80, 160)
      90.0

      iex> MishkaMob.Components.MishkaAngleSlider.angle_at(80, 80, 160)
      :dead
  """
  @spec angle_at(number(), number(), number()) :: float() | :dead
  def angle_at(x, y, size \\ @size) do
    center = size / 2
    dx = x - center
    dy = y - center

    if :math.sqrt(dx * dx + dy * dy) < @ring do
      :dead
    else
      # atan2 is 0 at three o'clock and the dial's 0 is twelve o'clock, so the
      # quarter turn here is the exact inverse of point_on_dial/4's.
      deg = :math.atan2(dy, dx) * 180 / :math.pi() + 90
      Float.round(if(deg < 0, do: deg + 360.0, else: deg * 1.0), 6)
    end
  end

  @doc """
  The angle a drag should settle on, given where it currently is.

  `angle_at/3` is circular, so dragging clockwise past twelve o'clock takes 359°
  straight to 0° and the ring empties in one frame. That is true of an angle and
  wrong as a gesture: the finger moved a few pixels, so the value should not
  travel most of a turn.

  A jump of more than half a turn is therefore read as crossing the seam, and the
  value pins to the end it was heading for. A full ring stays full until you drag
  back the other way.

      iex> alias MishkaMob.Components.MishkaAngleSlider, as: A
      iex> A.follow(350.0, 10.0)
      360.0

      iex> alias MishkaMob.Components.MishkaAngleSlider, as: A
      iex> A.follow(10.0, 350.0)
      0.0

      iex> alias MishkaMob.Components.MishkaAngleSlider, as: A
      iex> A.follow(90.0, 120.0)
      120.0

  Pass `:dead` straight through — there was no angle to follow.

      iex> MishkaMob.Components.MishkaAngleSlider.follow(90.0, :dead)
      90.0
  """
  @spec follow(number(), number() | :dead) :: float()
  def follow(current, :dead), do: current * 1.0

  def follow(current, new) do
    cond do
      abs(new - current) <= 180 -> new * 1.0
      new < current -> 360.0
      true -> 0.0
    end
  end

  # Mob.UI.canvas/1 is Map.take(props, [:width, :height, :draw]) — it drops any
  # handler, which is the "renders perfectly and does nothing" failure. Built
  # literally so on_drag reaches the renderer.
  defp canvas_node(size, ops, handler) do
    props = %{width: size, height: size, draw: ops}
    props = if handler, do: Map.put(props, :on_drag, handler), else: props

    %{type: :canvas, props: props, children: []}
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

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
