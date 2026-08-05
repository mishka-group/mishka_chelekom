defmodule MishkaMob.Showcase.Components.NumberField do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaNumberField`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaNumberField
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :number_field,
      name: "Number Field",
      category: "Forms",
      order: 11,
      description: "A numeric input with decrement and increment buttons."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:nf_qty, 3)
    |> Mob.Socket.assign(:nf_rate, 0.5)
    |> Mob.Socket.assign(:nf_price, 1999.99)
    |> Mob.Socket.assign(:nf_pct, 0.075)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Whole numbers",
        description: "A numeric keypad, and steppers that clamp into the range.",
        code: ~S"""
        <MishkaNumberField value={@qty} min={1} max={10} on_change={:qty} on_step={:qty_step} />

        def handle_info({:tap, {:qty_step, dir}}, socket) do
          {:noreply, assign(socket, :qty, MishkaNumberField.step(socket.assigns.qty, dir, min: 1, max: 10))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNumberField
              value={@nf_qty}
              min={1}
              max={10}
              on_change={:nf_qty}
              on_step={:nf_qty_step}
              id="nf-qty"
            />
            <Spacer size={10} />
            <Text
              text={"Quantity: " <> inspect(@nf_qty) <> " (1–10)"}
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Decimal steps",
        description: "step: 0.1 switches the keypad to decimal and keeps the precision clean.",
        code: ~S"""
        <MishkaNumberField value={@rate} step={0.1} min={0} max={1} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNumberField
              value={@nf_rate}
              step={0.1}
              min={0}
              max={1}
              on_change={:nf_rate}
              on_step={:nf_rate_step}
              id="nf-rate"
            />
            <Spacer size={10} />
            <Text
              text={"Rate: " <> inspect(@nf_rate) <> " — 0.3 + 0.1 is 0.4, not 0.4000000000000001"}
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Currency and percent",
        description: "format changes how the value READS, never what the assign holds.",
        code: ~S"""
        <MishkaNumberField value={@price} step={0.01} format={:currency} />
        <MishkaNumberField value={@pct} step={0.001} format={:percent} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNumberField
              value={@nf_price}
              step={0.01}
              min={0}
              format={:currency}
              on_step={:nf_price_step}
              id="nf-price"
            />
            <Spacer size={12} />
            <MishkaNumberField
              value={@nf_pct}
              step={0.001}
              min={0}
              max={1}
              format={:percent}
              on_step={:nf_pct_step}
              id="nf-pct"
            />
            <Spacer size={10} />
            <Text
              text={"Stored: " <> inspect(@nf_pct) <> " — a fraction. 0.075 reads as 7.5%."}
              text_size={:sm}
              text_color={:muted}
              id="nf-pct-note"
            />
          </Column>
          """
        end
      },
      %Example{
        title: "It hugs, or it spans",
        description: "The strip is the width of its parts unless you ask for fill_width.",
        code: ~S"""
        <MishkaNumberField value={@qty} fill_width={true} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNumberField value={@nf_qty} min={1} max={10} on_step={:nf_qty_step} id="nf-hug" />
            <Spacer size={12} />
            <MishkaNumberField
              value={@nf_qty}
              min={1}
              max={10}
              fill_width={true}
              on_step={:nf_qty_step}
              id="nf-wide"
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Empty and disabled",
        description: "Tapping + on an empty field lands ON min, not a step past it.",
        code: ~S"""
        <MishkaNumberField value={nil} min={5} placeholder="How many?" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNumberField value={nil} min={5} placeholder="How many?" />
            <Spacer size={12} />
            <MishkaNumberField value={3} disabled={true} />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "value", type: "number / nil", default: "nil", description: "Current value."},
      %{
        name: "min / max",
        type: "number / nil",
        default: "nil",
        description: "Bounds. Unbounded when absent."
      },
      %{
        name: "step",
        type: "number",
        default: "1",
        description: "Amount the buttons move; also picks the keypad."
      },
      %{
        name: "placeholder",
        type: "string",
        default: "nil",
        description: "Shown while empty."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Mutes and unwires everything."
      },
      %{
        name: "on_change / on_step",
        type: "event tags",
        default: "—",
        description:
          "{:change, tag, text} from the field; {:tap, {tag, :up | :down}} from a button."
      },
      %{
        name: "format",
        type: ":plain · :currency · :percent",
        default: ":plain",
        description: "How the value reads. :percent shows a FRACTION as a percentage."
      },
      %{
        name: "size",
        type: "number",
        default: "56",
        description: "Stepper edge, and the strip's height."
      },
      %{
        name: "fill_width",
        type: "boolean",
        default: "false",
        description: "Span the parent instead of hugging its parts."
      },
      %{
        name: "value_width",
        type: "number",
        default: "estimated",
        description: "The value slot's width. Estimated from the rendered text unless set."
      },
      %{
        name: "background · corner_radius",
        type: "colour / radius",
        default: ":surface / :radius_sm",
        description: "The strip's fill and rounding."
      },
      %{
        name: "border_color · border_width",
        type: "colour / number",
        default: ":border / 1",
        description: "The strip's outline. The inner field draws no box of its own."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Test tag on the value field, and <id>-down / <id>-up on the steppers."
      },
      %{
        name: "at_bound?/3 · format/3",
        type: "helpers",
        default: "—",
        description: "Whether a stepper is inert, and the display formatting."
      },
      %{
        name: "parse/2 · step/3 · to_text/2",
        type: "helpers",
        default: "—",
        description: "Partial input, clamping and step precision — the actual work."
      }
    ]
  end

  @impl true
  def handle({:nf_qty_step, dir}, socket) do
    Mob.Socket.assign(
      socket,
      :nf_qty,
      MishkaNumberField.step(socket.assigns.nf_qty, dir, step: 1, min: 1, max: 10)
    )
  end

  def handle({:nf_rate_step, dir}, socket) do
    Mob.Socket.assign(
      socket,
      :nf_rate,
      MishkaNumberField.step(socket.assigns.nf_rate, dir, step: 0.1, min: 0, max: 1)
    )
  end

  def handle({:nf_price_step, dir}, socket) do
    Mob.Socket.assign(
      socket,
      :nf_price,
      MishkaNumberField.step(socket.assigns.nf_price, dir, step: 0.01, min: 0)
    )
  end

  def handle({:nf_pct_step, dir}, socket) do
    Mob.Socket.assign(
      socket,
      :nf_pct,
      MishkaNumberField.step(socket.assigns.nf_pct, dir, step: 0.001, min: 0, max: 1)
    )
  end

  def handle(_tag, socket), do: socket

  @impl true
  def handle_change(:nf_qty, text, socket) do
    Mob.Socket.assign(socket, :nf_qty, MishkaNumberField.parse(text, min: 1, max: 10))
  end

  def handle_change(:nf_rate, text, socket) do
    Mob.Socket.assign(socket, :nf_rate, MishkaNumberField.parse(text, min: 0, max: 1))
  end

  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true}>
      <Box width={30} height={30} background={:surface_raised} corner_radius={:radius_sm} />
      <Spacer size={8} />
      <Box
        weight={1}
        height={30}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:border}
        border_width={1}
      />
      <Spacer size={8} />
      <Box width={30} height={30} background={:surface_raised} corner_radius={:radius_sm} />
    </Row>
    """
  end
end
