defmodule MishkaMob.Showcase.Components.ThemeIcon do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaThemeIcon` and
  `MishkaMob.Components.MishkaMarquee`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :theme_icon,
      name: "Theme Icon",
      category: "Navigation",
      order: 4,
      description: "A light/dark switcher, plus a marquee rail."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :ti_theme, :dark)

  @impl true
  def examples do
    [
      %Example{
        title: "Theme switcher",
        description: "One option per theme; the active one is tinted.",
        code: ~S"""
        <MishkaThemeIcon active={@theme} on_select={:set_theme} />

        def handle_info({:tap, {:set_theme, key}}, socket) do
          Mob.Theme.set(module_for(key))
          {:noreply, assign(socket, :theme, key)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaThemeIcon active={@ti_theme} on_select={:ti_set} />
            <Spacer size={10} />
            <Text text={"Selected: " <> to_string(@ti_theme)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Glyphs only",
        description: "show_labels: false for a compact strip.",
        code: ~S"""
        <MishkaThemeIcon active={@theme} show_labels={false} on_select={:set_theme} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaThemeIcon active={@ti_theme} show_labels={false} on_select={:ti_set} />
          </Column>
          """
        end
      },
      %Example{
        title: "Marquee",
        description: "The continuous animation is not ported — this is the honest static form.",
        code: ~S"""
        <MishkaMarquee repeat={3}>{[ticker()]}</MishkaMarquee>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaMarquee repeat={3} height={32}>
              {[ticker()]}
            </MishkaMarquee>
            <Spacer size={8} />
            <Text
              text="Flick it — Mob exposes no animation primitive, so it moves under your finger."
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
        name: "active",
        type: "theme key",
        default: "nil",
        description: "Which option reads as current."
      },
      %{
        name: "options",
        type: "list of {key, glyph, label}",
        default: "themes/0",
        description: "The themes offered."
      },
      %{
        name: "on_select",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, key}}."
      },
      %{
        name: "show_labels",
        type: "boolean",
        default: "true",
        description: "Show the text under each glyph."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Active option's tint."
      },
      %{
        name: "Marquee: repeat / space / height / id",
        type: "see MishkaMarquee",
        default: "—",
        description: "A repeated horizontal rail; the animation is not ported."
      }
    ]
  end

  @impl true
  def handle({:ti_set, key}, socket), do: Mob.Socket.assign(socket, :ti_theme, key)
  def handle(_tag, socket), do: socket

  defp ticker do
    %{
      type: :row,
      props: %{},
      children:
        Enum.flat_map(["BEAM", "•", "OTP", "•", "Elixir", "•", "Mob", "•", "Chelekom"], fn word ->
          [
            %{
              type: :text,
              props: %{text: word, text_size: :base, text_color: :on_surface},
              children: []
            },
            %{type: :spacer, props: %{size: 10}, children: []}
          ]
        end)
    }
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true}>
      <Box weight={1} height={40} background={:primary} corner_radius={:radius_md} />
      <Spacer size={8} />
      <Box weight={1} height={40} background={:surface_raised} corner_radius={:radius_md} />
      <Spacer size={8} />
      <Box weight={1} height={40} background={:surface_raised} corner_radius={:radius_md} />
    </Row>
    """
  end
end
