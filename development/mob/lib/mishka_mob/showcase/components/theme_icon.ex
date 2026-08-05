defmodule MishkaMob.Showcase.Components.ThemeIcon do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaThemeIcon` and
  `MishkaMob.Components.MishkaMarquee`.

  Every example owns its own assign and its own `id` prefix. Sharing either
  would make the page untestable: the whole gallery renders into one scrolling
  column, so two examples bound to the same assign are indistinguishable to a
  device test, and so are two icons with the same tag.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaThemeIcon
  alias MishkaMob.Showcase.Example

  @themes [{:light, "☀"}, {:dark, "🌙"}, {:system, "🖥"}]

  @impl true
  def entry do
    %{
      slug: :theme_icon,
      name: "Theme Icon",
      category: "Data display",
      order: 8,
      description: "A themed container around one icon, plus a marquee rail."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:ti_taps, 0)
    |> Mob.Socket.assign(:ti_held, nil)
    |> Mob.Socket.assign(:ti_theme, :dark)
  end

  @impl true
  def examples do
    [
      basic_example(),
      variants_example(),
      sizes_example(),
      radius_example(),
      colors_example(),
      gradient_example(),
      meaning_example(),
      own_icon_example(),
      switcher_example(),
      marquee_example()
    ]
  end

  defp basic_example do
    %Example{
      title: "One icon, wrapped",
      description:
        "The web component is a span around whatever icon you hand it. Here the container " <>
          "paints itself, because there is no stylesheet to do it.",
      code: ~S"""
      <MishkaThemeIcon id="ti-basic" icon="★" label="Favourite" on_tap={:star} />

      def handle_info({:tap, :star}, socket) do
        {:noreply, Mob.Socket.assign(socket, :stars, socket.assigns.stars + 1)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Row>
          <MishkaThemeIcon id="ti-basic" icon="★" label="Favourite" on_tap={:ti_tap} />
          <Spacer size={12} />
          <Text
            id={"ti-taps-#{@ti_taps}"}
            text={"Tapped #{@ti_taps}"}
            text_size={:sm}
            text_color={:muted}
            max_lines={1}
          />
        </Row>
        """
      end
    }
  end

  defp variants_example do
    %Example{
      title: "Variants",
      description:
        "Top row: filled, light, outline, subtle. Bottom row: white, default, gradient. " <>
          "Only the paint changes — the box, the icon and the geometry are the same.",
      code: ~S"""
      <MishkaThemeIcon icon="◆" variant={:filled} color={:primary} />
      <MishkaThemeIcon icon="◆" variant={:light} color={:primary} />
      <MishkaThemeIcon icon="◆" variant={:outline} color={:primary} />
      """,
      render: fn _assigns ->
        {first, second} = Enum.split(MishkaThemeIcon.variants(), 4)

        ~MOB"""
        <Column>
          {variant_row(first)}
          <Spacer size={10} />
          {variant_row(second)}
        </Column>
        """
      end
    }
  end

  defp sizes_example do
    %Example{
      title: "Sizes",
      description: "xs, sm, md, lg, xl — 20, 26, 32, 40 and 48dp. Or pass a number.",
      code: ~S"""
      <MishkaThemeIcon icon="●" size={:xs} />
      <MishkaThemeIcon icon="●" size={36} />
      """,
      render: fn _assigns ->
        row =
          for token <- [:xs, :sm, :md, :lg, :xl] do
            MishkaThemeIcon.theme_icon(%{
              id: "ti-size-#{token}",
              icon: "●",
              size: token,
              variant: :light
            })
          end

        ~MOB"""
        <Row>
          {space(row, 10)}
        </Row>
        """
      end
    }
  end

  defp radius_example do
    %Example{
      title: "Radius",
      description:
        "none, sm, md, lg, full — the four radius tokens the theme carries, plus square.",
      code: ~S"""
      <MishkaThemeIcon icon="◆" radius={:full} />
      <MishkaThemeIcon icon="◆" radius={2} />
      """,
      render: fn _assigns ->
        row =
          for token <- [:none, :sm, :md, :lg, :full] do
            MishkaThemeIcon.theme_icon(%{
              id: "ti-radius-#{token}",
              icon: "◆",
              radius: token,
              color: :secondary
            })
          end

        ~MOB"""
        <Row>
          {space(row, 10)}
        </Row>
        """
      end
    }
  end

  defp colors_example do
    %Example{
      title: "Colour",
      description:
        "primary, secondary, error, muted, then a raw ARGB. The glyph colour follows: a token " <>
          "gets its on_* partner, a raw colour gets black or white by luminance.",
      code: ~S"""
      <MishkaThemeIcon icon="✓" color={:error} />
      <MishkaThemeIcon icon="✓" color={0xFFFDE047} />
      """,
      render: fn _assigns ->
        tokens = [:primary, :secondary, :error, :muted]

        row =
          for color <- tokens ++ [0xFFFDE047] do
            MishkaThemeIcon.theme_icon(%{
              id: "ti-color-#{color_slug(color)}",
              icon: "✓",
              color: color
            })
          end

        ~MOB"""
        <Row>
          {space(row, 10)}
        </Row>
        """
      end
    }
  end

  defp gradient_example do
    %Example{
      title: "Gradient",
      description:
        "No renderer has a gradient background, so this one is drawn into a canvas that follows " <>
          "the corner radius itself — Compose clips a Box's children, SwiftUI does not.",
      code: ~S"""
      <MishkaThemeIcon
        icon="⚡"
        variant={:gradient}
        gradient={{0xFF6366F1, 0xFFEC4899}}
        size={:lg}
      />
      """,
      render: fn _assigns ->
        row = [
          MishkaThemeIcon.theme_icon(%{
            id: "ti-grad-brand",
            icon: "⚡",
            variant: :gradient,
            size: :lg
          }),
          MishkaThemeIcon.theme_icon(%{
            id: "ti-grad-sunset",
            icon: "⚡",
            variant: :gradient,
            size: :lg,
            gradient: {0xFFF97316, 0xFFEC4899}
          }),
          MishkaThemeIcon.theme_icon(%{
            id: "ti-grad-round",
            icon: "⚡",
            variant: :gradient,
            size: :lg,
            radius: :full,
            gradient: %{from: 0xFF6366F1, to: 0xFF22D3EE}
          })
        ]

        ~MOB"""
        <Row>
          {space(row, 10)}
        </Row>
        """
      end
    }
  end

  defp meaning_example do
    %Example{
      title: "What the icon means",
      description:
        "The web turns label into role=img + aria-label. Mob has nothing to announce into, so " <>
          "hold either of the first two: a long press is the touch equivalent of the hover that " <>
          "shows a title. The third has no label, so it has nothing to say.",
      code: ~S"""
      <MishkaThemeIcon id="ti-deploy" icon="🚀" label="Deploy" on_long_press={:explain} />

      # The label rides the payload, so one clause serves every icon on the page.
      def handle_info({:tap, {:explain, label}}, socket) do
        {:noreply, Mob.Socket.assign(socket, :held, label)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column>
          <Row>
            <MishkaThemeIcon
              id="ti-meaning"
              icon="🚀"
              label="Deploy"
              variant={:light}
              color={:error}
              on_long_press={:ti_hold}
            />
            <Spacer size={12} />
            <MishkaThemeIcon
              id="ti-meaning-alt"
              icon="⏮"
              label="Rollback"
              variant={:light}
              color={:secondary}
              on_long_press={:ti_hold}
            />
            <Spacer size={12} />
            <MishkaThemeIcon id="ti-plain" icon="✦" variant={:subtle} color={:muted} />
          </Row>
          <Spacer size={10} />
          <Text
            id={"ti-held-#{held_slug(@ti_held)}"}
            text={held_text(@ti_held)}
            text_size={:sm}
            text_color={:muted}
          />
        </Column>
        """
      end
    }
  end

  defp own_icon_example do
    %Example{
      title: "Your own icon",
      description:
        "Children are the icon — any node, including a drawing. The container will not tint it, " <>
          "the way CSS colour cannot tint an SVG that did not ask for currentColor.",
      code: ~S"""
      <MishkaThemeIcon id="ti-drawn" variant={:default} size={:xl}>
        {[Mob.UI.canvas(width: 20, height: 20, draw: rings())]}
      </MishkaThemeIcon>
      """,
      render: fn _assigns ->
        ~MOB"""
        <Row>
          <MishkaThemeIcon id="ti-drawn" variant={:default} size={:xl}>
            {[rings()]}
          </MishkaThemeIcon>
          <Spacer size={12} />
          <MishkaThemeIcon id="ti-drawn-alt" variant={:outline} size={:xl} color={:error}>
            {[rings()]}
          </MishkaThemeIcon>
        </Row>
        """
      end
    }
  end

  defp switcher_example do
    %Example{
      title: "A theme switcher, built from three",
      description:
        "This component used to BE a switcher. A switcher is three of them in a row with the " <>
          "active one filled — so the page still has one, and it is composition rather than a prop.",
      code: ~S"""
      <MishkaThemeIcon
        id={"sw-#{key}"}
        icon={glyph}
        label={to_string(key)}
        variant={if @theme == key, do: :filled, else: :subtle}
        on_tap={{:set_theme, key}}
      />

      def handle_info({:tap, {:set_theme, key}}, socket) do
        Mob.Theme.set(theme_module(key))
        {:noreply, Mob.Socket.assign(socket, :theme, key)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column>
          <Row>
            {switcher(@ti_theme)}
          </Row>
          <Spacer size={10} />
          <Text
            text={"Chosen: #{@ti_theme}. The bar at the top still owns the real theme."}
            text_size={:sm}
            text_color={:muted}
          />
        </Column>
        """
      end
    }
  end

  defp marquee_example do
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
  end

  @impl true
  def props do
    [
      %{
        name: "id",
        type: "string",
        default: "nil",
        description:
          "testTag for the container; markers add -<variant> and -labelled/-decorative."
      },
      %{
        name: "icon",
        type: "string",
        default: "nil",
        description: "Glyph shorthand, used when there are no children."
      },
      %{
        name: "label",
        type: "string",
        default: "nil",
        description: "What the icon means. Rides the long press; tags the marker."
      },
      %{
        name: "variant",
        type: "filled · light · outline · …",
        default: ":filled",
        description: "How the container is painted."
      },
      %{
        name: "color",
        type: "color token / ARGB",
        default: ":primary",
        description: "The tint the variant is built from."
      },
      %{
        name: "size",
        type: "xs sm md lg xl or dp",
        default: ":md",
        description: "Container edge; the glyph is 55% of it."
      },
      %{
        name: "radius",
        type: "none sm md lg full or dp",
        default: ":md",
        description: "Corner radius."
      },
      %{
        name: "gradient",
        type: "{from, to}",
        default: "{:primary, :secondary}",
        description: "Endpoints for variant: :gradient."
      },
      %{
        name: "icon_color",
        type: "color token / ARGB",
        default: "variant's",
        description: "Overrides the glyph colour."
      },
      %{
        name: "on_tap",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, tag}."
      },
      %{
        name: "on_long_press",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, label}} — the touch equivalent of hover."
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
  def handle(:ti_tap, socket),
    do: Mob.Socket.assign(socket, :ti_taps, socket.assigns.ti_taps + 1)

  def handle({:ti_hold, label}, socket), do: Mob.Socket.assign(socket, :ti_held, label)
  def handle({:ti_theme, key}, socket), do: Mob.Socket.assign(socket, :ti_theme, key)
  def handle(_tag, socket), do: socket

  defp variant_row(variants) do
    row =
      for variant <- variants do
        MishkaThemeIcon.theme_icon(%{id: "ti-var-#{variant}", icon: "◆", variant: variant})
      end

    ~MOB"""
    <Row>
      {space(row, 10)}
    </Row>
    """
  end

  defp switcher(active) do
    icons =
      for {key, glyph} <- @themes do
        MishkaThemeIcon.theme_icon(%{
          id: "ti-sw-#{key}",
          icon: glyph,
          label: to_string(key),
          size: :lg,
          variant: if(key == active, do: :filled, else: :subtle),
          on_tap: {:ti_theme, key}
        })
      end

    space(icons, 10)
  end

  # A caller-supplied icon: two circles drawn into a canvas, so the example
  # proves children may be any node rather than only a glyph.
  defp rings do
    Mob.UI.canvas(
      width: 22,
      height: 22,
      draw: [
        Mob.Canvas.circle(8, 11, 6, color: :primary, fill: true, opacity: 0.9),
        Mob.Canvas.circle(14, 11, 6, color: :error, fill: true, opacity: 0.7)
      ]
    )
  end

  defp space(nodes, size) do
    Enum.intersperse(nodes, %{type: :spacer, props: %{size: size}, children: []})
  end

  defp color_slug(color) when is_atom(color), do: to_string(color)
  defp color_slug(_argb), do: "raw"

  defp held_slug(nil), do: "none"
  defp held_slug(label), do: label |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-")

  defp held_text(nil), do: "Hold the rocket to read what it means"
  defp held_text(label), do: "It means: #{label}"

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
    <Row>
      {space(preview_icons(), 8)}
    </Row>
    """
  end

  # :md, not :lg — a gallery card is roughly 118dp of content wide once the grid,
  # the page padding and the card's own padding are taken out, and a Row does not
  # wrap.
  defp preview_icons do
    [
      MishkaThemeIcon.theme_icon(%{icon: "★"}),
      MishkaThemeIcon.theme_icon(%{icon: "◆", variant: :light, color: :error}),
      MishkaThemeIcon.theme_icon(%{icon: "⚡", variant: :gradient, radius: :full})
    ]
  end
end
