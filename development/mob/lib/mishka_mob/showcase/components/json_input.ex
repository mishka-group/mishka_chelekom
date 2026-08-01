defmodule MishkaMob.Showcase.Components.JsonInput do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaJsonInput` and
  `MishkaMob.Components.MishkaNumberFormatter`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

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
        <MishkaJsonInput value={@json} lines={5} on_change={:json} id="config" />

        # The field never reformats as you type — that would move the cursor out
        # from under the user — so the screen just holds the raw text.
        def handle_info({:change, :json, text}, socket) do
          {:noreply, Mob.Socket.assign(socket, :json, text)}
        end

        MishkaJsonInput.validate(@json)
        #=> {:ok, %{"name" => "mishka", "stars" => 42}}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaJsonInput value={@json} lines={5} on_change={:json} id="json-valid" />
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
        <MishkaJsonInput value={@broken} lines={3} on_change={:broken} id="json-broken" />

        # The border reddens and the parser's own message appears underneath.
        # Both use the :error THEME token, so they follow light and dark.
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaJsonInput value={@broken} lines={3} on_change={:broken} id="json-broken" />
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Inert, not merely quiet — the field cannot be typed into at all.",
        code: ~S"""
        <MishkaJsonInput value={@json} disabled={true} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaJsonInput value={@json} lines={3} disabled={true} id="json-off" />
            <Spacer size={8} />
            <Text
              text="A disabled field used to withhold only its handler: it still took a
                    caret and accepted typing, and threw every keystroke away."
              text_size={:sm}
              text_color={:muted}
            />
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
            <MishkaNumberFormatter value={1_234_567.5} decimals={2} prefix="$" font_weight={:semibold} />
            <Spacer size={6} />
            <MishkaNumberFormatter
              value={1_234.5}
              decimals={2}
              thousand_separator="."
              decimal_separator=","
              suffix=" €"
            />
            <Spacer size={6} />
            <MishkaNumberFormatter value={-98_765} text_color={:error} />
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
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "{:change, tag, text} per keystroke. Without it the field reports nothing."
      },
      %{
        name: "placeholder",
        type: "string",
        default: "\"{ }\"",
        description: "Empty-state hint."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Inert: enabled={false}, not merely a withheld handler."
      },
      %{
        name: "error_color",
        type: "colour / ARGB",
        default: ":error",
        description: "The invalid border and the message. A theme token, so it follows the theme."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Test tag on the field."
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
      },
      %{
        name: "Formatter: text_size / text_color / font_weight",
        type: "tokens",
        default: ":base / :on_surface / :regular",
        description: "Text styling. The weight prop is `font_weight` — a bare `weight` is layout."
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
