defmodule MishkaMob.Showcase.Components.Slider do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSlider`.

  The stepped example is the interesting one: it shows `snap/2` doing in the
  screen what the native widget cannot do in the track.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

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
    |> Mob.Socket.assign(:sl_range, [20, 60])
    |> Mob.Socket.assign(:sl_vertical, 40)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Continuous",
        description: "Drag it; the screen owns the value.",
        code: ~S"""
        <MishkaSlider value={@volume} label="Volume" show_value={true} on_change={:volume} />

        def handle_info({:change, :volume, v}, socket) do
          {:noreply, assign(socket, :volume, round(v))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSlider value={@sl_volume} label="Volume" show_value={true} on_change={:volume} />
          </Column>
          """
        end
      },
      %Example{
        title: "Stepped",
        description: "step is applied by snap/2 in the handler — the native track is continuous.",
        code: ~S"""
        <MishkaSlider value={@v} step={10} on_change={:stepped} />

        def handle_info({:change, :stepped, raw}, socket) do
          {:noreply, assign(socket, :v, MishkaSlider.snap(raw, step: 10))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSlider value={@sl_stepped} label="Steps of 10" show_value={true} on_change={:stepped} />
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
        <MishkaSlider value={@r} min={1} max={5} value_text={"#{@r} of 5"} show_value={true} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSlider
              value={@sl_rating}
              min={1}
              max={5}
              label="Rating"
              value_text={stars(@sl_rating)}
              show_value={true}
              on_change={:rating}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Colour",
        description: "Tints the thumb and the active track.",
        code: ~S"""
        <MishkaSlider value={70} color={0xFF7C3AED} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSlider value={@sl_volume} color={0xFF7C3AED} on_change={:volume} />
            <Spacer size={12} />
            <MishkaSlider value={@sl_volume} color={:primary} on_change={:volume} />
          </Column>
          """
        end
      },
      %Example{
        title: "Range · two thumbs · min gap · push collision",
        description:
          "Pass values instead of value and you get two thumbs. min_gap keeps " <>
            "them apart; collision says what happens when they meet — push " <>
            "carries the other thumb along, stop holds the dragged one there.",
        code: ~S"""
        <MishkaSlider values={@range} min={0} max={100} step={5}
                      min_gap={5} on_change={:range} />

        # min_gap and collision are enforced by the WIDGET, so a push happens
        # under the finger with no round trip. resolve/3 is the same rule as a
        # pure function, for a screen that wants to re-apply it authoritatively.

        # The pair comes back as "lo,hi" — one change channel, two numbers.
        def handle_change(:range, reported, socket) do
          case MishkaSlider.parse_range(reported) do
            {lo, hi} ->
              moved = if lo != hd(socket.assigns.range), do: :lo, else: :hi
              {lo, hi} = MishkaSlider.resolve({lo, hi}, moved,
                           min_gap: 5, collision: :push, min: 0, max: 100)
              Mob.Socket.assign(socket, :range, [lo, hi])

            :error ->
              socket
          end
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSlider values={@sl_range} min={0} max={100} step={5} label="Price" on_change={:range} />
            <Spacer size={6} />
            <Text text={range_label(@sl_range)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Vertical",
        description:
          "orientation={:vertical} turns the control a quarter turn. length sets " <>
            "how long the track is, since a rotated slider cannot inherit a width.",
        code: ~S"""
        <MishkaSlider
          value={@level}
          orientation={:vertical}
          length={180}
          on_change={:level}
        />
        """,
        render: fn assigns ->
          ~MOB"""
          <Row fill_width={true} align={:center}>
            <MishkaSlider
              value={@sl_vertical}
              min={0}
              max={100}
              orientation={:vertical}
              length={160}
              on_change={:vertical}
            />
            <Spacer size={16} />
            <Text text={"Level #{round(@sl_vertical)}"} text_size={:base} text_color={:on_surface} />
          </Row>
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

  def handle_change(:range, reported, socket) do
    case MishkaSlider.parse_range(reported) do
      {lo, hi} ->
        [was_lo, _] = socket.assigns.sl_range
        moved = if lo != was_lo, do: :lo, else: :hi

        {lo, hi} =
          MishkaSlider.resolve({lo, hi}, moved,
            min_gap: 5,
            collision: :push,
            min: 0,
            max: 100
          )

        Mob.Socket.assign(socket, :sl_range, [round(lo), round(hi)])

      :error ->
        socket
    end
  end

  def handle_change(:vertical, v, socket),
    do: Mob.Socket.assign(socket, :sl_vertical, MishkaSlider.snap(v, step: 1, min: 0, max: 100))

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
  defp range_label([lo, hi]), do: "#{round(lo)} — #{round(hi)}  (min gap 5, push)"
end
