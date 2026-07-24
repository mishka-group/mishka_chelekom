defmodule MishkaMob.Showcase.Components.JsonInput do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaJsonInput` and
  `MishkaMob.Components.MishkaNumberFormatter`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaJsonInput, only: [json_input: 1]
  import MishkaMob.Components.MishkaNumberFormatter, only: [number_formatter: 1]

  alias MishkaMob.Components.MishkaJsonInput
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :json_input,
      name: "JSON Input",
      category: "Forms",
      order: 17,
      description: "A validated JSON textarea, plus a number formatter."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:json, ~s({"name": "mishka", "stars": 42}))
    |> Mob.Socket.assign(:broken, ~s({"name": mishka}))
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Valid, and validated on the server",
        description:
          "Parsing is Jason's job — the same division of labour the web version keeps.",
        code: ~S"""
        {json_input(value: @json, on_change: :json)}

        MishkaJsonInput.validate(@json)  #=> {:ok, %{"name" => "mishka"}}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {json_input(value: @json, lines: 5, on_change: :json)}
            <Spacer size={8} />
            <Text
              text={"Parses: " <> inspect(match?({:ok, _}, MishkaJsonInput.validate(@json)))}
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Invalid shows the parser's own message",
        description: "Blank is not an error — an untouched field is not a mistake.",
        code: ~S"""
        {json_input(value: ~s({"name": mishka}))}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {json_input(value: @broken, lines: 3, on_change: :broken)}
          </Column>
          """
        end
      },
      %Example{
        title: "Number formatter",
        description: "Grouping, decimals, prefix and suffix — all one pure function.",
        code: ~S"""
        MishkaNumberFormatter.format(1234567.5, decimals: 2, prefix: "$")
        #=> "$1,234,567.50"
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {number_formatter(value: 1_234_567.5, decimals: 2, prefix: "$", weight: :semibold)}
            <Spacer size={6} />
            {number_formatter(value: 1_234.5, decimals: 2, thousand_separator: ".", decimal_separator: ",", suffix: " €")}
            <Spacer size={6} />
            {number_formatter(value: -98_765, text_color: :danger)}
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
        type: "string",
        default: "\"\"",
        description: "The raw text — never reformatted as you type."
      },
      %{
        name: "lines",
        type: "integer",
        default: "6",
        description: "Field height in rows. The bridge grew a `lines` prop for this."
      },
      %{
        name: "invalid",
        type: "boolean",
        default: "derived",
        description: "Force the error state; otherwise validate/1 decides."
      },
      %{
        name: "error_text / show_error",
        type: "string · boolean",
        default: "parser message · true",
        description: "The message under the field."
      },
      %{
        name: "validate/1",
        type: "helper",
        default: "—",
        description: "{:ok, term} · {:error, msg} · :empty."
      },
      %{
        name: "format/1",
        type: "helper",
        default: "—",
        description: "Pretty-print — a deliberate action, never a keystroke."
      },
      %{
        name: "Formatter: decimals",
        type: "integer",
        default: "nil",
        description: "Fixed decimal places."
      },
      %{
        name: "Formatter: thousand_separator",
        type: "string · boolean",
        default: "\",\"",
        description: "false disables grouping."
      },
      %{
        name: "Formatter: decimal_separator",
        type: "string",
        default: "\".\"",
        description: "Swap both for European style."
      },
      %{
        name: "Formatter: prefix / suffix",
        type: "string",
        default: "nil",
        description: "Wrapped around the digits."
      }
    ]
  end

  @impl true
  def handle_change(:json, text, socket), do: Mob.Socket.assign(socket, :json, text)
  def handle_change(:broken, text, socket), do: Mob.Socket.assign(socket, :broken, text)
  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box
        fill_width={true}
        height={46}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:border}
        border_width={1}
        padding={6}
      >
        <Column fill_width={true}>
          <Box width={40} height={6} background={:muted} corner_radius={:radius_sm} />
          <Spacer size={6} />
          <Box width={56} height={6} background={:muted} corner_radius={:radius_sm} />
          <Spacer size={6} />
          <Box width={28} height={6} background={:muted} corner_radius={:radius_sm} />
        </Column>
      </Box>
    </Column>
    """
  end
end
