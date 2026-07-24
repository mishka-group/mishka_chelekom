defmodule MishkaMob.Showcase.Components.Slider do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSlider`.

  The stepped example is the interesting one: it shows `snap/2` doing in the
  screen what the native widget cannot do in the track.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaSlider, only: [slider: 1]

  alias MishkaMob.Components.MishkaSlider
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :slider,
      name: "Slider",
      category: "Forms",
      order: 1,
      description: "A draggable value along a range, on Mob's native Slider."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:sl_volume, 40)
    |> Mob.Socket.assign(:sl_stepped, 50)
    |> Mob.Socket.assign(:sl_rating, 3)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Continuous",
        description: "Drag it; the screen owns the value.",
        code: ~S"""
        {slider(value: @volume, label: "Volume", show_value: true, on_change: :volume)}

        def handle_info({:change, :volume, v}, socket) do
          {:noreply, assign(socket, :volume, round(v))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {slider(value: @sl_volume, label: "Volume", show_value: true, on_change: :volume)}
          </Column>
          """
        end
      },
      %Example{
        title: "Stepped",
        description: "step is applied by snap/2 in the handler — the native track is continuous.",
        code: ~S"""
        {slider(value: @v, step: 10, on_change: :stepped)}

        def handle_info({:change, :stepped, raw}, socket) do
          {:noreply, assign(socket, :v, MishkaSlider.snap(raw, step: 10))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {slider(value: @sl_stepped, label: "Steps of 10", show_value: true, on_change: :stepped)}
            <Spacer size={6} />
            <Text
              text="Release the thumb — it lands on a multiple of 10."
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Custom range and readout",
        description: "min/max set the scale; value_text replaces the number.",
        code: ~S"""
        {slider(value: @r, min: 1, max: 5, value_text: "#{@r} of 5", show_value: true)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {slider(value: @sl_rating, min: 1, max: 5, label: "Rating",
                    value_text: stars(@sl_rating), show_value: true, on_change: :rating)}
          </Column>
          """
        end
      },
      %Example{
        title: "Colour",
        description: "Tints the thumb and the active track.",
        code: ~S"""
        {slider(value: 70, color: 0xFF7C3AED)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {slider(value: @sl_volume, color: 0xFF7C3AED, on_change: :volume)}
            <Spacer size={12} />
            {slider(value: @sl_volume, color: :primary, on_change: :volume)}
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
        description: "Current value. The widget is controlled — the screen owns it."
      },
      %{name: "min", type: "number", default: "0", description: "Lower bound."},
      %{
        name: "max",
        type: "number",
        default: "100",
        description: "Upper bound. Always sent — the bridge would otherwise default to 1.0."
      },
      %{name: "label", type: "string", default: "nil", description: "Caption above the track."},
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
        description: "Overrides the readout; the default is the rounded value."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: "platform",
        description: "Thumb and active track."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:change, tag, float} while dragging."
      },
      %{
        name: "snap/2",
        type: "helper",
        default: "—",
        description: "Snap a raw value to a step and clamp it, in your handler."
      }
    ]
  end

  @impl true
  def handle_change(:volume, v, socket), do: Mob.Socket.assign(socket, :sl_volume, round(v))

  def handle_change(:stepped, v, socket),
    do: Mob.Socket.assign(socket, :sl_stepped, MishkaSlider.snap(v, step: 10))

  def handle_change(:rating, v, socket),
    do: Mob.Socket.assign(socket, :sl_rating, MishkaSlider.snap(v, step: 1, min: 1, max: 5))

  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box fill_width={true} height={6} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={86} height={6} background={:primary} corner_radius={:radius_pill} />
      </Box>
      <Spacer size={6} />
      <Row fill_width={true}>
        <Spacer size={78} />
        <Box width={16} height={16} background={:primary} corner_radius={:radius_pill} />
      </Row>
    </Column>
    """
  end

  defp stars(n) when is_number(n), do: String.duplicate("★", round(n))
end
