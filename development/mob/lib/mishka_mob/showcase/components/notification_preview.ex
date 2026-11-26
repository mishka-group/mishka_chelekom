defmodule MishkaMob.Showcase.Components.NotificationPreview do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaNotificationPreview`.

  What a push would look like, drawn on the page that configures it. The
  preview sends nothing: it takes four strings and an icon.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :notification_preview,
      name: "Notification Preview",
      category: "Data display",
      order: 901,
      description: "An app mark, an app-and-time line, a title and a body — the push as a card."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A reminder",
        description: "The shape every push takes; the mark is a node or a glyph.",
        code: ~S"""
        <MishkaNotificationPreview
          app="KATI" time="19:15" icon="●"
          title="Dinner in 15 minutes"
          body="Miso salmon, rice, greens. Prep the miso."
          background={0xFFFBF1DE} corner_radius={18}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNotificationPreview
              app="KATI"
              time="19:15"
              icon="●"
              title="Dinner in 15 minutes"
              body="Miso salmon, rice, greens. Prep the miso."
              background={0xFFFBF1DE}
              corner_radius={18}
              app_font={:mono}
              app_color={0xFF8A8177}
              title_color={0xFF1A1917}
              body_color={0xFF5C574F}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "A release, on the app's own surface",
        description: "No background is a valid card: the page's surface shows through.",
        code: ~S"""
        <MishkaNotificationPreview
          app="KATI" time="08:00"
          title="New episode — The Long Hollow"
          body="Season 2, episode 6 is out. 48 minutes."
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaNotificationPreview
              app="KATI"
              time="08:00"
              title="New episode — The Long Hollow"
              body="Season 2, episode 6 is out. 48 minutes."
              corner_radius={14}
              padding={14}
              app_font={:mono}
            />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true} padding_top={4} padding_bottom={4}>
      <Row fill_width={true} align="center">
        <Box width={14} height={14} background={:primary} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={46} height={6} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={8} />
      <Box width={128} height={8} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={6} />
      <Box fill_width={true} height={6} background={:surface_raised} corner_radius={:radius_sm} />
      <Spacer size={4} />
      <Box width={92} height={6} background={:surface_raised} corner_radius={:radius_sm} />
    </Column>
    """
  end

  @impl true
  def props do
    [
      %{
        name: "app",
        type: "string",
        default: "nil",
        description: "The app name on the first line."
      },
      %{name: "time", type: "string", default: "nil", description: "The clock beside it."},
      %{name: "title", type: "string", default: "nil", description: "The notification's title."},
      %{name: "body", type: "string", default: "nil", description: "Its body, which may wrap."},
      %{
        name: "icon",
        type: "string / node / nodes",
        default: "nil",
        description: "The app mark."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: "unset",
        description: "The card's fill."
      },
      %{name: "corner_radius", type: "number", default: "0", description: "The card's corners."},
      %{name: "padding", type: "number", default: "12", description: "Inside the card."},
      %{
        name: "app_font",
        type: "string",
        default: "unset",
        description: "The first line's face."
      },
      %{name: "body_max_lines", type: "integer", default: "3", description: "Body line cap."},
      %{name: "id", type: "string", default: "nil", description: "TestTag on the card."}
    ]
  end
end
