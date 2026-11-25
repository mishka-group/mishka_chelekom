defmodule MishkaMob.Components.MishkaNotificationPreview do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Notification Preview** — the
  way an app shows a push it would send, inside its own settings page.

  Settings screens draw these because a sentence describing a notification is
  not one: *"we will remind you before dinner"* is copy, while the card a person
  would actually receive is the specification. It is one shape everywhere — an
  app mark, an app-and-time line, a title, a body — and this draws it once.

  ## It previews; it never sends

  There is no delivery here and no permission read: the component takes four
  strings and an icon and draws them. An app that wants to arm the notification
  it is previewing does that itself, which is what makes this usable on a page
  that is only explaining what a setting would do.

  ## Headless

  No default background, corner or ink: a cream card, a glass sheet and a dark
  panel are all the same component with different props. The icon is a node as
  given — an app's own glyph, an image, a coloured square — so nothing here
  assumes an icon font.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `app` | string | `nil` | The app name on the first line. |
  | `time` | string | `nil` | The clock beside it; the line joins them with a middot. |
  | `title` | string | `nil` | The notification's title. |
  | `body` | string | `nil` | Its body, which may wrap. |
  | `layout` | `:inline` `:stacked` | `:inline` | The mark beside the text, or above it on its own line. |
  | `icon` | string, node, or list of nodes | `nil` | The app mark. |
  | `background` | color token / ARGB int | unset | The card's fill. |
  | `corner_radius` | number | `0` | The card's corners. |
  | `padding` | number | `12` | Inside the card. |
  | `app_size` | number | `10` | The app-and-time line's size. |
  | `app_color` | color token / ARGB int | `:muted` | Its ink. |
  | `app_font` | string | unset | Its face — a mono face suits it, and is the caller's call. |
  | `app_letter_spacing` | number | unset | Tracking on the app line. |
  | `title_size` | number | `13` | The title's size. |
  | `title_color` | color token / ARGB int | `:on_surface` | Its ink. |
  | `body_size` | number | `12` | The body's size. |
  | `body_line_height` | number | unset | The body's line-height multiplier. |
  | `body_color` | color token / ARGB int | `:muted` | Its ink. |
  | `line_gap` | number | `3` | Space between the three lines (`9` between the app row and the title under `:stacked`). |
  | `body_gap` | number | `5` | Under `:stacked` only: space between the title and the body. |
  | `icon_gap` | number | `10` | Space between the mark and the text. |
  | `body_max_lines` | integer | `3` | How many lines the body may take. |
  | `id` | string | unset | TestTag on the card. |

  Children are ignored; the card is data.

  ## Two layouts, because two designs exist

  `:inline` puts the mark beside the text — the phone's own notification
  shade. `:stacked` puts the mark and the app line on one row above the title,
  which is how a settings page draws the notification it is describing. Both
  are the same four strings; only the flow changes.

  **Documentation:** https://mishka.tools/chelekom/docs/mob/notification-preview
  """

  import Mob.Sigil

  @doc "Composite expander (`<MishkaNotificationPreview />`). Delegates to `notification/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: notification(props)

  @doc """
  The card.

      notification(app: "KATI", time: "19:15", title: "Dinner", body: "Prep the miso.")
  """
  @spec notification(map() | keyword()) :: map()
  def notification(props \\ %{}) do
    props = Map.new(props)
    line = app_line(Map.get(props, :app), Map.get(props, :time))

    body =
      case setting(props, :layout, :inline) do
        :stacked -> stacked(props, line)
        _inline -> inline(props, line)
      end

    ~MOB"""
    <Column
      fill_width={true}
      background={Map.get(props, :background)}
      corner_radius={setting(props, :corner_radius, 0)}
      padding={setting(props, :padding, 12)}
    >
      {body}
    </Column>
    """
    |> put_id(Map.get(props, :id))
  end

  defp inline(props, line) do
    ~MOB"""
    <Row fill_width={true} align="top">
      {icon_node(Map.get(props, :icon), props)}
      <Spacer size={setting(props, :icon_gap, 10)} />
      <Column weight={1.0}>
        {line_node(line, props)}
        <Spacer size={setting(props, :line_gap, 3)} />
        {text(Map.get(props, :title), setting(props, :title_size, 13),
            setting(props, :title_color, :on_surface), Map.get(props, :title_weight), 1)}
        <Spacer size={setting(props, :line_gap, 3)} />
        {text(Map.get(props, :body), setting(props, :body_size, 12),
            setting(props, :body_color, :muted), nil, setting(props, :body_max_lines, 3))}
      </Column>
    </Row>
    """
  end

  # The settings-page shape: mark and app line together, then the title and
  # body across the card's whole width.
  defp stacked(props, line) do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true} align="center">
        {icon_node(Map.get(props, :icon), props)}
        <Spacer size={setting(props, :icon_gap, 9)} />
        {line_node(line, props)}
      </Row>
      <Spacer size={setting(props, :line_gap, 9)} />
      {text(Map.get(props, :title), setting(props, :title_size, 13),
          setting(props, :title_color, :on_surface), Map.get(props, :title_weight), 1)}
      <Spacer size={setting(props, :body_gap, 5)} />
      {text(Map.get(props, :body), setting(props, :body_size, 12),
          setting(props, :body_color, :muted), nil, setting(props, :body_max_lines, 3))}
    </Column>
    """
  end

  @doc """
  The first line: the app name and the clock, joined with a middot.

      iex> MishkaMob.Components.MishkaNotificationPreview.app_line("KATI", "19:15")
      "KATI · 19:15"
      iex> MishkaMob.Components.MishkaNotificationPreview.app_line("KATI", nil)
      "KATI"
      iex> MishkaMob.Components.MishkaNotificationPreview.app_line(nil, nil)
      nil
  """
  @spec app_line(String.t() | nil, String.t() | nil) :: String.t() | nil
  def app_line(nil, nil), do: nil
  def app_line(app, nil), do: app
  def app_line(nil, time), do: time
  def app_line(app, time), do: app <> " · " <> time

  # The icon is a node as given; a string is drawn as text so a glyph reads
  # without an icon font, which is the same rule the Rating and Highlight ports
  # follow.
  defp icon_node(nil, _props), do: ~MOB"<Spacer size={0} />"

  defp icon_node(icon, props) when is_binary(icon) do
    assigns = %{
      icon: icon,
      size: setting(props, :icon_size, 18),
      color: Map.get(props, :icon_color)
    }

    ~MOB"""
    <Text text={@icon} text_size={@size} text_color={@color} />
    """
  end

  defp icon_node(nodes, _props), do: nodes

  defp line_node(nil, _props), do: ~MOB"<Spacer size={0} />"

  defp line_node(line, props) do
    assigns = %{
      line: line,
      size: setting(props, :app_size, 10),
      color: setting(props, :app_color, :muted),
      family: Map.get(props, :app_font),
      tracking: Map.get(props, :app_letter_spacing)
    }

    ~MOB"""
    <Text text={@line} text_size={@size} text_color={@color} font_family={@family} max_lines={1} />
    """
  end

  defp text(nil, _size, _color, _weight, _lines), do: ~MOB"<Spacer size={0} />"

  defp text(value, size, color, weight, lines, line_height \\ nil) do
    assigns = %{
      value: value,
      size: size,
      color: color,
      weight: weight,
      lines: lines,
      height: line_height
    }

    ~MOB"""
    <Text
      text={@value}
      text_size={@size}
      text_color={@color}
      font_weight={@weight}
      line_height={@height}
      max_lines={@lines}
    />
    """
  end

  defp setting(props, key, default), do: Map.get(props, key) || default

  defp put_id(node, nil), do: node
  defp put_id(node, id), do: %{node | props: Map.put(node.props, :id, id)}
end
