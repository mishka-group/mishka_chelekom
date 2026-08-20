defmodule MishkaMob.Components.MishkaThemeIcon do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Theme Icon** — a themed
  container around exactly one icon.

  The web component is a `<span>` that wraps whatever icon you hand it. It ships
  no styling at all and says so: "Size, color and shape are yours." On the web
  that means a stylesheet. There is no stylesheet here, so those three become
  props — `variant`, `color`, `size`, `radius`, `gradient` — and the container
  paints itself.

  It previously shipped as a light/dark *switcher*: three tinted chips wired to
  `Mob.Theme.set/1`. That was a different component wearing this one's name. A
  switcher is three theme icons in a row, and the showcase still builds one that
  way, out of this.

  ## The icon is yours

  Pass it as children — any node, including a `Mob.UI.canvas/1` drawing:

      theme_icon(%{color: :primary}, [my_logo()])

  or, when the icon is a character (an emoji, a glyph from a font), use the
  `icon` shorthand and the container sizes and tints it for you:

      <MishkaThemeIcon icon="★" variant={:light} color={:error} size={:lg} />

  The shorthand exists because `text_color` does not inherit in Mob the way CSS
  `color` does — a `Text` you build yourself carries its own colour, so a
  caller-supplied icon keeps whatever colour the caller gave it. That is the
  same split the web has (CSS can only tint an SVG that opts into
  `fill="currentColor"`), stated out loud.

  ## Variants

  | `variant` | Container | Glyph |
  |------|------|------|
  | `:filled` (default) | solid `color` | the matching `on_*` token |
  | `:light` | `color` at 19% alpha | `color` |
  | `:outline` | nothing, 1dp border in `color` | `color` |
  | `:subtle` | nothing | `color` |
  | `:white` | `:surface` | `color` |
  | `:default` | `:surface_raised`, 1dp `:border` | `:on_surface` |
  | `:gradient` | a `gradient` from → to | `:on_primary` |

  `:white` is the theme's `:surface`, not the colour white — in a dark theme the
  "white" variant is the dark surface, which is what white means once an app has
  a theme.

  `:light` needs a colour *mixed with transparency*, and mixing needs numbers, so
  the token is resolved through `Mob.Theme.resolved_palette/0` at build time
  rather than on the native side. The tree is rebuilt on every render, so it
  still follows a theme change; it just resolves one step earlier than the rest.

  ## The gradient is drawn, not styled

  Neither `Box` nor either renderer has a gradient background, so
  `variant: :gradient` paints one into a `Mob.UI.canvas/1` sized exactly to the
  icon. It is drawn as vertical bands whose top and bottom edges follow the
  rounded-rectangle silhouette, because a canvas cannot be clipped to its
  parent's corner radius — Compose's `Box` clips its children, SwiftUI's `ZStack`
  does not, and a shape that only rounds on Android is worse than one that
  rounds itself. Endpoints may be tokens or ARGB ints; they are interpolated on
  the BEAM, so they resolve at build time for the same reason `:light` does.

  ## `label`, and what a long press is for

  On the web, `label` flips the span from `aria-hidden` to `role="img"` with that
  label. Mob's `Box` has no accessibility-label prop on either renderer — only
  `Image` carries a `description` — so there is nothing to announce into.

  Two things carry the label instead. It rides in the `on_long_press` payload,
  because a long press is the touch equivalent of the hover that reveals a
  `title` on the web, and it is the one gesture a phone has spare. And it lands
  in the testTag: `<id>-labelled` or `<id>-decorative`, so the distinction the
  web makes in the accessibility tree is at least *addressable* here.

  ## ids and testTags

  `id` tags the container, and two nested markers spell out the state a device
  test cannot otherwise see — a colour is not something `onNodeWithTag` can read:

    * `<id>` — the container itself; the node that carries `on_tap`.
    * `<id>-<variant>` — `ti-save-filled`, `ti-save-gradient`, …
    * `<id>-labelled` / `<id>-decorative`.

  A tappable `Box` merges its children's semantics, so those markers need
  `useUnmergedTree = true`.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `id` | string | `nil` | testTag base for the container and its markers. |
  | `icon` | string | `nil` | Glyph shorthand, used when there are no children. |
  | `label` | string | `nil` | What the icon means. Rides the long press; tags the marker. |
  | `variant` | see table | `:filled` | How the container is painted. |
  | `color` | color token / ARGB int | `:primary` | The tint the variant is built from. |
  | `size` | `:xs :sm :md :lg :xl` or dp | `:md` | Container edge; the glyph is 55% of it. |
  | `radius` | `:none :sm :md :lg :full` or dp | `:md` | Corner radius. |
  | `gradient` | `{from, to}` / `%{from:, to:}` | `{:primary, :secondary}` | Used by `variant: :gradient`. |
  | `icon_color` | color token / ARGB int | variant's | Overrides the glyph colour. |
  | `border_color` | color token / ARGB int | variant's | Overrides the variant's border, or draws one where it has none. |
  | `border_width` | number (dp) | `1` | Read only when a border colour is in play. |
  | `shadow` | string | `nil` | Drop shadow on the container. See below. |
  | `on_tap` | event tag | — | `{:tap, tag}`. |
  | `on_long_press` | event tag | — | `{:tap, {tag, label}}`. |

  Not ported: `class` (there is no CSS), `rest` (no DOM attributes), and
  `role` / `aria-*` — see the `label` section for what happens to them instead.

  ## The shadow is yours too

  The variants say how the container is *painted*; none of them says how far it
  floats. A tinted disc with no shadow reads as a patch of colour, and the
  design that wants it to sit above the page is the one that knows how high —
  so `shadow` is a string handed to the container untouched, in CSS
  `box-shadow` order and units of dp:

      shadow: "0 1 2 0 #0D1A1917"

  `dx dy blur spread #AARRGGBB`. Stack layers by separating them with a
  vertical bar, ambient first, key light second, exactly as CSS does:

      shadow: "0 1 2 0 #0D1A1917 | 0 8 16 -12 #801A1917"

  It rides the container — the node that carries the `corner_radius`, the fill
  and the `on_tap` — so the shadow follows the rounded silhouette and every
  variant can take one. Omit it and the container carries no `shadow` key at
  all, not a null one.

  ## Overriding the variant's border

  `:outline` and `:default` draw a 1dp border and the other five draw none.
  That is a default, not a rule: `border_color` replaces the variant's choice
  (and gives a `:filled` or `:light` container a hairline it otherwise cannot
  have), and `border_width` thickens whichever colour is in play. Setting
  `border_width` alone still draws nothing, because the renderer honours a
  border on a box only when the colour is set and the width is non-zero.
  """

  import Bitwise

  alias MishkaMob.Components.Event

  # Mantine's ThemeIcon scale, nudged up: these are dp on a phone rather than
  # CSS px on a desktop, and 16dp of icon is a smudge.
  @sizes %{xs: 20, sm: 26, md: 32, lg: 40, xl: 48}

  # Mob's theme carries four radius tokens, so the web's six-step scale lands on
  # those four plus square. Anything in between is a number.
  @radii %{none: 0, sm: :radius_sm, md: :radius_md, lg: :radius_lg, full: :radius_pill}

  # What reads on top of a filled container, per semantic token. Any other token
  # falls back to :on_primary; a raw ARGB picks black or white by luminance.
  @on_token %{
    primary: :on_primary,
    secondary: :on_secondary,
    error: :on_error,
    surface: :on_surface,
    surface_raised: :on_surface,
    background: :on_background
  }

  @variants [:filled, :light, :outline, :subtle, :white, :default, :gradient]

  @doc "Composite expander (`<MishkaThemeIcon />`). Children are the icon."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: theme_icon(props, children)

  @doc "The variants this component paints, in the order the showcase shows them."
  @spec variants() :: [atom()]
  def variants, do: @variants

  @doc "The named size scale, in dp."
  @spec sizes() :: %{atom() => number()}
  def sizes, do: @sizes

  @doc """
  The themed container node.

      theme_icon(%{icon: "★", variant: :light, color: :error, id: "ti-star"})

      theme_icon(%{
        icon: "★",
        radius: :full,
        shadow: "0 1 2 0 #0D1A1917 | 0 8 16 -12 #801A1917"
      })

      <MishkaThemeIcon id="ti-logo" label="Home" on_tap={:go_home}>
        {[logo()]}
      </MishkaThemeIcon>

      def handle_info({:tap, :go_home}, socket), do: {:noreply, home(socket)}
  """
  @spec theme_icon(map() | keyword(), [map()]) :: map()
  def theme_icon(props \\ %{}, children \\ []) do
    props = Map.new(props)
    variant = variant(props)
    size = size(props)
    radius = radius(props)
    color = Map.get(props, :color, :primary)
    skin = skin(variant, color)
    id = Map.get(props, :id)

    # The variant proposes a border; the caller disposes. Width is only ever
    # written alongside a colour, because the renderer draws a border on a box
    # only when it has both — a lone width would serialise and paint nothing.
    border_color = Map.get(props, :border_color, skin.border)

    container =
      %{width: size, height: size, align: :center, corner_radius: radius}
      |> put_some(:id, id)
      |> put_some(:background, skin.background)
      |> put_some(:border_color, border_color)
      |> put_some(:border_width, border_color && Map.get(props, :border_width, 1))
      |> put_some(:shadow, Map.get(props, :shadow))
      |> put_some(:on_tap, Event.handler(Map.get(props, :on_tap)))
      |> put_some(
        :on_long_press,
        Event.handler(Map.get(props, :on_long_press), Map.get(props, :label))
      )

    icon =
      case children do
        [] -> glyph(props, skin, size)
        nodes -> nodes
      end

    %{
      type: :box,
      props: container,
      children: gradient_layer(variant, props, size, radius) ++ markers(id, variant, props, icon)
    }
  end

  # The glyph shorthand. `max_lines: 1` because a Text squeezed narrower than its
  # content wraps character by character, and a two-character icon in a 20dp box
  # is exactly that case.
  defp glyph(props, skin, size) do
    case Map.get(props, :icon) do
      nil ->
        []

      glyph ->
        [
          %{
            type: :text,
            props: %{
              text: to_string(glyph),
              text_size: round(size * 0.55),
              text_color: Map.get(props, :icon_color, skin.icon),
              max_lines: 1
            },
            children: []
          }
        ]
    end
  end

  # Without an id there is nothing to tag, so the icon sits straight in the
  # container. With one, two markers carry the state that is otherwise only a
  # colour. Both hug their content and re-centre it: `fill_width: false` is
  # honoured on Android and ignored on iOS, where a Box always offers its
  # parent's width, so the alignment is what actually keeps the glyph centred.
  defp markers(nil, _variant, _props, icon), do: icon

  defp markers(id, variant, props, icon) do
    [marker("#{id}-#{variant}", [marker("#{id}-#{labelling(props)}", icon)])]
  end

  defp marker(id, children) do
    %{type: :box, props: %{id: id, fill_width: false, align: :center}, children: children}
  end

  defp labelling(props) do
    case Map.get(props, :label) do
      nil -> "decorative"
      "" -> "decorative"
      _ -> "labelled"
    end
  end

  # ── The painted container ─────────────────────────────────────────────────

  defp skin(:filled, color), do: %{background: color, icon: on_color(color), border: nil}
  defp skin(:light, color), do: %{background: tint(color), icon: color, border: nil}
  defp skin(:outline, color), do: %{background: nil, icon: color, border: color}
  defp skin(:subtle, color), do: %{background: nil, icon: color, border: nil}
  defp skin(:white, color), do: %{background: :surface, icon: color, border: nil}
  defp skin(:gradient, _color), do: %{background: nil, icon: :on_primary, border: nil}

  defp skin(:default, _color),
    do: %{background: :surface_raised, icon: :on_surface, border: :border}

  # 19% of the tint over whatever is behind it — Mantine's `light` in one line,
  # and one of the two places a colour has to become a number rather than staying
  # a token the native side resolves.
  defp tint(color), do: (argb(color) &&& 0x00FFFFFF) ||| 0x30000000

  defp on_color(color) when is_atom(color), do: Map.get(@on_token, color, :on_primary)

  # A caller-supplied colour has no `on_` partner, so pick the one that can be
  # read against it. The weights are the usual perceived-luminance ones.
  defp on_color(color) do
    argb = argb(color)
    r = argb >>> 16 &&& 0xFF
    g = argb >>> 8 &&& 0xFF
    b = argb &&& 0xFF

    if (0.299 * r + 0.587 * g + 0.114 * b) / 255 > 0.6, do: :black, else: :white
  end

  # ── The gradient ──────────────────────────────────────────────────────────

  defp gradient_layer(:gradient, props, size, radius) do
    {from, to} = gradient(props)
    r = min(radius_px(radius), size / 2)
    [Mob.UI.canvas(width: size, height: size, draw: gradient_ops(size, r, argb(from), argb(to)))]
  end

  defp gradient_layer(_variant, _props, _size, _radius), do: []

  defp gradient(props) do
    case Map.get(props, :gradient) do
      {from, to} -> {from, to}
      %{from: from, to: to} -> {from, to}
      [_ | _] = kw -> {Keyword.get(kw, :from, :primary), Keyword.get(kw, :to, :secondary)}
      _ -> {:primary, :secondary}
    end
  end

  # One filled quad per band. Neighbouring bands share an edge with identical
  # corners, so they tile without a seam, and the top and bottom edges follow the
  # rounded silhouette — which is what makes this a rounded gradient square
  # rather than a square one that only Android's clip happens to round.
  defp gradient_ops(size, r, from, to) do
    steps = max(12, round(size))
    step = size / steps

    Enum.map(0..(steps - 1), fn i ->
      x0 = i * step
      x1 = x0 + step
      inset0 = corner_inset(x0, size, r)
      inset1 = corner_inset(x1, size, r)

      Mob.Canvas.path(
        [
          {x0, inset0},
          {x1, inset1},
          {x1, size - inset1},
          {x0, size - inset0}
        ],
        color: mix(from, to, (x0 + x1) / 2 / size),
        fill: true,
        closed: true
      )
    end)
  end

  # How far a rounded rectangle's edge has moved inward at x: zero along the
  # straight middle, and the corner circle's arc inside the two end columns.
  defp corner_inset(_x, _size, r) when r <= 0, do: 0.0

  defp corner_inset(x, size, r) do
    cond do
      x < r -> r - :math.sqrt(max(r * r - (r - x) * (r - x), 0))
      x > size - r -> corner_inset(size - x, size, r)
      true -> 0.0
    end
  end

  defp mix(from, to, t) do
    Enum.reduce([24, 16, 8, 0], 0, fn shift, acc ->
      a = from >>> shift &&& 0xFF
      b = to >>> shift &&& 0xFF
      acc ||| round(a + (b - a) * t) <<< shift
    end)
  end

  # ── Scales ────────────────────────────────────────────────────────────────

  defp variant(props) do
    variant = Map.get(props, :variant, :filled)
    if variant in @variants, do: variant, else: :filled
  end

  defp size(props) do
    case Map.get(props, :size, :md) do
      n when is_number(n) -> n
      token -> Map.get(@sizes, token, @sizes.md)
    end
  end

  defp radius(props) do
    case Map.get(props, :radius, :md) do
      n when is_number(n) -> n
      token -> Map.get(@radii, token, :radius_md)
    end
  end

  defp radius_px(radius) when is_number(radius), do: radius

  defp radius_px(token) do
    Mob.Theme.current() |> Mob.Theme.radius_map() |> Map.get(token, 0)
  end

  # A colour as a number. Semantic tokens walk the active theme, base palette
  # names (:blue_500, :white) walk the renderer's table, and "#rrggbb" is read
  # straight. Anything unknown becomes opaque black rather than a bare string,
  # which would serialise silently and paint nothing.
  defp argb(value) when is_integer(value), do: value

  defp argb("#" <> hex) when byte_size(hex) == 6 do
    case Integer.parse(hex, 16) do
      {int, ""} -> 0xFF000000 ||| int
      _ -> 0xFF000000
    end
  end

  defp argb(value) when is_atom(value) do
    case Map.get(Mob.Theme.resolved_palette(), value) do
      nil -> Map.get(Mob.Renderer.colors(), value, 0xFF000000)
      int when is_integer(int) -> int
      token -> Map.get(Mob.Renderer.colors(), token, 0xFF000000)
    end
  end

  defp argb(_value), do: 0xFF000000

  defp put_some(map, _key, nil), do: map
  defp put_some(map, _key, false), do: map
  defp put_some(map, key, value), do: Map.put(map, key, value)
end
