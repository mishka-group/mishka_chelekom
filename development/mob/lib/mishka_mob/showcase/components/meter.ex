defmodule MishkaMob.Showcase.Components.Meter do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaMeter`.

  Examples lean on gauge-shaped data (storage, battery, signal) to make the
  distinction from Progress concrete: a meter reads a measurement, a progress bar
  tracks a task.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :meter,
      name: "Meter",
      category: "Feedback",
      order: 1,
      description: "A scalar gauge for a measurement inside a known range."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :mt_used, 72)

  @impl true
  def examples do
    [
      %Example{
        title: "A gauge",
        description: "A measurement with its own readout. Tap to fill it.",
        code: ~S"""
        <MishkaMeter value={@used} label="Storage" show_value={true} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaMeter value={@mt_used} label="Storage used" show_value={true} />
            <Spacer size={14} />
            <Row fill_width={true}>
              <Button
                text="Free up"
                background={:surface_raised}
                text_color={:on_surface}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :mt_down}}
              />
              <Spacer size={8} />
              <Button
                text="Fill up"
                background={:primary}
                text_color={:on_primary}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :mt_up}}
              />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Any range",
        description: "min/max map the scale; value_text replaces the percentage.",
        code: ~S"""
        <MishkaMeter
          value={3}
          max={5}
          label="Signal"
          value_text="3 of 5 bars"
          show_value={true}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaMeter value={3} max={5} label="Signal" value_text="3 of 5 bars" show_value={true} />
            <Spacer size={16} />
            <MishkaMeter
              value={37}
              min={20}
              max={40}
              label="Temperature"
              value_text="37 °C"
              show_value={true}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Clamped, never overshooting",
        description: "Values outside the range read as full or empty.",
        code: ~S"""
        <MishkaMeter value={250} />   # renders full
        <MishkaMeter value={-40} />   # renders empty
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaMeter value={250} label="Over the top" show_value={true} />
            <Spacer size={16} />
            <MishkaMeter value={-40} label="Below the floor" show_value={true} />
            <Spacer size={16} />
            <MishkaSeparator label="a meter with no value reads empty" />
            <Spacer size={16} />
            <MishkaMeter label="Unknown" show_value={true} />
          </Column>
          """
        end
      },
      %Example{
        title: "Colour and thickness",
        description:
          "color tints the fill and height sets how thick the gauge is. A meter " <>
            "reads a measurement, so colour is usually the warning — and a chunky " <>
            "bar is easier to read at a glance than a hairline.",
        code: ~S"""
        # height is the gauge's thickness; the default is the platform's ~4dp.
        <MishkaMeter value={91} color={0xFFDC2626} height={18} />

        # Colour from the value, so the gauge warns before the number is read.
        defp band(v) when v >= 85, do: 0xFFDC2626
        defp band(v) when v >= 60, do: 0xFFF59E0B
        defp band(_v), do: 0xFF16A34A
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaMeter value={22} label="Comfortable" color={:primary} show_value={true} />
            <Spacer size={16} />
            <MishkaMeter
              value={64}
              label="Amber, thicker"
              color={0xFFF59E0B}
              height={12}
              show_value={true}
            />
            <Spacer size={16} />
            <MishkaMeter
              value={91}
              label="Nearly full, thickest"
              color={0xFFDC2626}
              height={18}
              show_value={true}
            />
            <Spacer size={20} />
            <MishkaMeter
              value={@mt_used}
              label={"Disk — " <> band_name(@mt_used)}
              color={band(@mt_used)}
              height={14}
              show_value={true}
            />
            <Spacer size={8} />
            <Text
              text="Move it with the buttons in the first example."
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "value",
        type: "number",
        default: "min",
        description: "The measurement. Clamped into [min, max]; absent reads empty."
      },
      %{name: "min", type: "number", default: "0", description: "Lower bound."},
      %{name: "max", type: "number", default: "100", description: "Upper bound."},
      %{name: "label", type: "string", default: "nil", description: "Caption above the gauge."},
      %{
        name: "show_value",
        type: "boolean",
        default: "false",
        description: "Render a readout beside the label."
      },
      %{
        name: "value_text",
        type: "string",
        default: "nil",
        description: "Overrides the readout; the default is a rounded percentage."
      },
      %{
        name: "height",
        type: "number",
        default: "platform (~4)",
        description: "Gauge thickness. Forwarded to the native bar."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: "platform",
        description: "Fill colour."
      }
    ]
  end

  @impl true
  def handle(:mt_up, socket), do: nudge(socket, +12)
  def handle(:mt_down, socket), do: nudge(socket, -12)
  def handle(_tag, socket), do: socket

  # Clamped HERE too. ratio/1 clamps what is drawn, so an unbounded assign shows
  # a full gauge while the number behind it keeps climbing — and then takes as
  # many wasted taps to come back down. Same defect the Progress demo had.
  defp nudge(socket, delta) do
    next = socket.assigns.mt_used + delta

    Mob.Socket.assign(socket, :mt_used, next |> max(0) |> min(100))
  end

  # Colour as the warning: a gauge should read before its number does.
  defp band(value) when value >= 85, do: 0xFFDC2626
  defp band(value) when value >= 60, do: 0xFFF59E0B
  defp band(_value), do: 0xFF16A34A

  defp band_name(value) when value >= 85, do: "critical"
  defp band_name(value) when value >= 60, do: "filling up"
  defp band_name(_value), do: "healthy"

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={36} height={8} background={:muted} corner_radius={:radius_sm} />
        <Spacer weight={1} />
        <Box width={20} height={8} background={:surface_raised} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={10} />
      <Box fill_width={true} height={10} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={92} height={10} background={:primary} corner_radius={:radius_pill} />
      </Box>
      <Spacer size={12} />
      <Box fill_width={true} height={10} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={54} height={10} background={:muted} corner_radius={:radius_pill} />
      </Box>
    </Column>
    """
  end
end
