defmodule MishkaMob.Showcase.Components.Progress do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaProgress`.

  The determinate examples are driven by a live value the buttons move, so the
  bar, the readout and the clamping are all visible on device rather than being
  three static screenshots.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :progress,
      name: "Progress",
      category: "Feedback",
      order: 0,
      description: "A determinate or indeterminate progress bar."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :pg_value, 40)

  @impl true
  def examples do
    [
      %Example{
        title: "Determinate",
        description: "A value inside [min, max]. Tap to move it.",
        code: ~S"""
        <MishkaProgress value={@value} />
        <MishkaProgress value={@value} label="Uploading" show_value={true} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaProgress value={@pg_value} />
            <Spacer size={16} />
            <MishkaProgress value={@pg_value} label="Uploading" show_value={true} />
            <Spacer size={14} />
            <Row fill_width={true}>
              <Button
                text="− 15"
                background={:surface_raised}
                text_color={:on_surface}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :pg_down}}
              />
              <Spacer size={8} />
              <Button
                text="+ 15"
                background={:primary}
                text_color={:on_primary}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :pg_up}}
              />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Indeterminate",
        description: "Omit value when the total is unknown — the bar animates itself.",
        code: ~S"""
        <MishkaProgress />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaProgress />
            <Spacer size={16} />
            <MishkaProgress label="Connecting…" />
          </Column>
          """
        end
      },
      %Example{
        title: "Custom range and readout",
        description: "min/max map any scale onto the bar; value_text overrides the percentage.",
        code: ~S"""
        <MishkaProgress value={3} max={5} label="Step" value_text="3 of 5" show_value={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaProgress value={3} max={5} label="Step" value_text="3 of 5" show_value={true} />
            <Spacer size={16} />
            <MishkaProgress value={7} min={5} max={10} label="Rating" show_value={true} />
          </Column>
          """
        end
      },
      %Example{
        title: "Colour",
        description:
          "color takes a theme token or an ARGB int. The last bar picks its own " <>
            "from the value — green, amber, then red — which is the reason the " <>
            "prop is worth having: the colour is the warning.",
        code: ~S"""
        # height is the bar's thickness — the default is the platform's ~4dp.
        <MishkaProgress value={65} color={0xFFF97316} height={16} />
        <MishkaProgress value={30} color={:primary} />

        # Colour as meaning, not decoration. The bar on this page uses the same
        # value the buttons move, so it changes band as you cross 60 and 85.
        defp band(value) when value >= 85, do: 0xFFDC2626
        defp band(value) when value >= 60, do: 0xFFF59E0B
        defp band(_value), do: 0xFF16A34A

        <MishkaProgress value={@value} color={band(@value)} show_value={true} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaProgress
              value={72}
              color={0xFFF97316}
              height={16}
              label="Orange, and thicker"
              show_value={true}
            />
            <Spacer size={16} />
            <MishkaProgress value={65} color={0xFF7C3AED} label="Violet" show_value={true} />
            <Spacer size={16} />
            <MishkaProgress value={30} color={:primary} label="The theme's primary" show_value={true} />
            <Spacer size={20} />
            <MishkaProgress
              value={@pg_value}
              color={band(@pg_value)}
              label={"Disk usage — " <> band_name(@pg_value)}
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
        type: "number / nil",
        default: "nil",
        description: "Current value in [min, max]. nil renders the indeterminate bar."
      },
      %{name: "min", type: "number", default: "0", description: "Lower bound."},
      %{name: "max", type: "number", default: "100", description: "Upper bound."},
      %{
        name: "label",
        type: "string",
        default: "nil",
        description: "Caption above the bar."
      },
      %{
        name: "show_value",
        type: "boolean",
        default: "false",
        description: "Render a readout beside the label. Ignored when indeterminate."
      },
      %{
        name: "value_text",
        type: "string",
        default: "nil",
        description: "Overrides the readout; the default is a rounded percentage."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: "platform",
        description: "Indicator colour."
      }
    ]
  end

  @impl true
  def handle(:pg_up, socket), do: nudge(socket, +15)
  def handle(:pg_down, socket), do: nudge(socket, -15)

  def handle(_tag, socket), do: socket

  # Colour as meaning: the bar warns before the number has to be read.
  defp band(value) when value >= 85, do: 0xFFDC2626
  defp band(value) when value >= 60, do: 0xFFF59E0B
  defp band(_value), do: 0xFF16A34A

  defp band_name(value) when value >= 85, do: "critical"
  defp band_name(value) when value >= 60, do: "getting full"
  defp band_name(_value), do: "healthy"

  # Deliberately allowed past 0/100 so the bar's clamping is visible on device.
  # Clamped HERE, not just in the component. fraction/1 clamps what it draws, so
  # an unbounded assign still shows a full bar — but it keeps climbing behind it,
  # and after ten taps up you had to press down thirteen times before anything
  # moved. The bar looked right and the buttons felt broken.
  defp nudge(socket, delta) do
    next = socket.assigns.pg_value + delta

    Mob.Socket.assign(socket, :pg_value, next |> max(0) |> min(100))
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box fill_width={false} width={40} height={8} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={10} />
      <Box fill_width={true} height={8} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={78} height={8} background={:primary} corner_radius={:radius_pill} />
      </Box>
      <Spacer size={12} />
      <Box fill_width={true} height={8} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={38} height={8} background={:muted} corner_radius={:radius_pill} />
      </Box>
    </Column>
    """
  end
end
