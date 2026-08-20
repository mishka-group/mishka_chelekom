defmodule MishkaMob.Components.MishkaToggle do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Toggle** — a button that stays
  pressed, as in a formatting toolbar's bold or italic.

  ## Three lookalikes, kept distinct

  Mob now has three controls that all mean "on or off", and the port keeps them
  apart on purpose:

    * `MishkaMob.Components.MishkaSwitch` — a *setting*. Wraps the platform's
      real switch widget; belongs beside a label in a settings list.
    * `MishkaMob.Components.MishkaChip` — a *filter*, one of a set you pick
      from. Pill-shaped by convention.
    * this — a *pressed button*, usually one of several in a toolbar, holding a
      binary state about the thing you are editing rather than about the app.

  They differ visually so a user can tell them apart: a switch slides, a chip is
  a pill, a toggle is a square-cornered button that looks pushed in.

  Beware the name: Mob's own `<Toggle>` tag is a **switch**, which is what
  `MishkaSwitch` wraps. This component deliberately does not use it.

  ## Which is why this one can be resized and `MishkaSwitch` cannot

  `MishkaSwitch` bottoms out in Mob's `<Toggle>`, which is Compose's Material
  `Switch`: its track (52×32), its handles (24 on, 16 off) and its 2dp outline
  are constants inside material3, and only the colours are parameterised. No
  prop at any layer reshapes it — that one needs a different native node, not a
  wider prop list.

  This component has no such floor. It is a `Box` around a `Text`, so every
  dimension it draws is one this module chooses, and every one of them is a prop
  below. If a design wants a 46×28 pressed button, it says so and gets it.

  ## Styling is the caller's, as on the web

  The headless component ships no colours and no spacing — you style it with a
  stylesheet. There is no stylesheet here, so every visual decision is a prop
  instead, with defaults chosen only so an unstyled toggle is legible. Pass your
  own to make it yours; the showcase does exactly that to build a segmented bar
  out of nothing but these props.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | Button text. Children override it. |
  | `pressed` | boolean | `false` | Whether it reads as pushed in. |
  | `disabled` | boolean | `false` | Wires no handler and mutes it. |
  | `on_change` | event tag (atom) | — | Sent as `{:tap, tag}`. |
  | `color` | color token / ARGB int | `:primary` | Fill **when pressed**. |
  | `text_color` | color token / ARGB int | `:on_primary` | Label **when pressed**. |
  | `background` | color token / ARGB int | `:surface_raised` | Fill when idle. |
  | `label_color` | color token / ARGB int | `:on_surface` | Label when idle. |
  | `padding` | spacing token / number | `:space_sm` | Inside the button. |
  | `padding_top` / `padding_right` / `padding_bottom` / `padding_left` | spacing token / number | unset | One edge, overriding `padding` on that side only. |
  | `corner_radius` | radius token / number | `:radius_md` | Corner rounding. |
  | `border_color` | color token / ARGB int | `:border` | Border. |
  | `border_width` | number | `1` | `0` removes the border. |
  | `text_size` | text token / number | `:base` | Label size. |
  | `font_weight` | `:regular`, `:medium`, `:semibold`, `:bold`, `:light`, `:thin` | unset (regular) | Label weight. |
  | `letter_spacing` | number (sp) | unset | Tracking on the label. |
  | `line_height` | number | unset | Multiplier of `text_size`; ignored without one. |
  | `max_lines` | number | unset (unlimited) | Caps the label and ellipsises the rest. |
  | `width` | number | unset | Exact width. Unset, the toggle hugs its label. |
  | `height` | number | unset | Exact height. Unset, the toggle hugs its label. |
  | `fill_width` | boolean | `false` | Span the parent instead of hugging. |
  | `align` | `:center`, `:leading`, `:trailing`, … | `:center` | Where the label sits inside the button. |
  | `shadow` | shadow spec string | unset | Passed straight through to the root Box — see "Shadows" below. |
  | `id` | string | `nil` | Test tag, suffixed `-pressed` / `-idle`. |

  `fill_width` defaults to **false** because a Box with neither a width nor the
  prop fills its parent — which rendered every toggle as one full-width slab and
  made a row of them impossible. Set it to `true` deliberately, for a toggle that
  really should span its container.

  Everything from `padding_top` down is a later addition, and every one of them
  defaults to exactly what the toggle drew before it existed. `align: :center`
  names the value that was previously hardcoded; the rest are marked *unset*,
  meaning the key is **left off the node entirely** rather than passed as `nil`
  — not the same thing once the tree is serialised, as the note beside the
  private `overrides` explains. So a toggle that names none of them builds the
  same props map, key for key, that it built before they existed.

  ## Sizing: padding is applied BEFORE width and height

  The bridge builds the node's modifier chain padding-first, so `width` and
  `height` measure the box *inside* the padding: `height: 28, padding: 8` is 44
  tall on screen, not 28. Pin the outer dimension by pairing the two, or drop the
  padding on the axis you are pinning. `width` / `height` want a plain number —
  they are not spacing props, so a token reaches the bridge unresolved and is
  ignored. Negative padding throws on the native side; never compute one.

  `text_size` also takes a raw number in sp for a design pinned to, say, 11.5.
  Only the token form is multiplied by the theme's `type_scale`, so a numeric
  size stays put when the user scales their type.

  ## Shadows

  `shadow` is not interpreted here — it rides on the root Box for the bridge to
  read, in CSS `box-shadow` order (`"dx dy blur spread #AARRGGBB"`, further
  layers after a pipe). There is one prop rather than a pressed/idle pair
  because the screen already knows which state it asked for: `pressed` is its
  own prop, so it can hand over the matching shadow itself. (The segmented
  control needs `selected_shadow` precisely because it picks the selected
  segment internally and the caller cannot reach it.) A bridge without shadow
  support ignores the prop, as it ignores any key it does not know.

  Not ported: `name`, `value`, `unchecked_value`, `form` (HTML form plumbing)
  and the `*_class` attrs.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  # Root-Box props that must be ABSENT when the caller says nothing, rather than
  # present-and-nil. See `overrides/2` for why the difference is visible.
  @box_overrides ~w(
    width height shadow
    padding_top padding_right padding_bottom padding_left
  )a

  # Label props, absent for the same reason. Most of these have no safe neutral
  # value at all: Compose resolves an unset `letter_spacing` / `line_height`
  # from the ambient text style, and Material's body style is not 0 / 1.0, so
  # writing those "neutral" numbers would visibly retrack and re-lead every
  # existing toggle; `max_lines` unset means unlimited, and any number starts
  # ellipsising. `font_weight` does have a neutral (`:regular`), and is still
  # left off, so a toggle nobody restyled builds the map it always built.
  @text_overrides ~w(font_weight letter_spacing line_height max_lines)a

  @doc "Composite expander (`<MishkaToggle>`). Children override the label."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: toggle(props, children)

  @doc """
  The toggle node.

      toggle(label: "B", pressed: @bold?, on_change: :bold)

  Sized to a design rather than to its text — the 46×28 the moduledoc promises,
  spelled with `padding: 0` because padding is applied before width and height:

      toggle(label: "W", width: 46, height: 28, padding: 0, border_width: 0,
             corner_radius: 8, text_size: 11.5, font_weight: :semibold)
  """
  @spec toggle(map() | keyword(), [map()]) :: map()
  def toggle(props \\ %{}, content \\ []) do
    props = Map.new(props)
    pressed? = truthy?(Map.get(props, :pressed, false))
    disabled? = truthy?(Map.get(props, :disabled, false))

    # fill_width: false is load-bearing. A Box given neither a width nor the
    # prop FILLS its parent, so every toggle rendered as a full-width slab and a
    # row of them was impossible — the same trap the chip fell into.
    node = ~MOB"""
    <Box
      fill_width={truthy?(Map.get(props, :fill_width, false))}
      background={background(props, pressed?, disabled?)}
      corner_radius={Map.get(props, :corner_radius) || :radius_md}
      padding={Map.get(props, :padding) || :space_sm}
      border_color={Map.get(props, :border_color) || :border}
      border_width={Map.get(props, :border_width) || 1}
      align={Map.get(props, :align) || :center}
    >
      {body(props, content, pressed?, disabled?)}
    </Box>
    """

    node
    |> merge_props(overrides(props, @box_overrides))
    |> tag_state(Map.get(props, :id), pressed?)
    |> wire(handler(props, disabled?))
  end

  defp wire(node, nil), do: node
  defp wire(node, tap), do: %{node | props: Map.put(node.props, :on_tap, tap)}

  # A pressed toggle differs from an idle one by its FILL COLOUR alone. Colour is
  # not in the accessibility tree, so nothing tells a device test which buttons
  # are pressed — the state goes into the test tag instead, the same way the
  # checkbox does it for its drawn mark.
  defp tag_state(node, nil, _pressed?), do: node

  defp tag_state(node, id, pressed?) do
    state = if pressed?, do: "pressed", else: "idle"
    %{node | props: Map.put(node.props, :id, "#{id}-#{state}")}
  end

  defp body(props, [], pressed?, disabled?) do
    ~MOB"""
    <Text
      text={Map.get(props, :label) || ""}
      text_size={Map.get(props, :text_size) || :base}
      text_color={text_color(props, pressed?, disabled?)}
    />
    """
    |> merge_props(overrides(props, @text_overrides))
  end

  defp body(_props, content, _pressed?, _disabled?), do: ~MOB(<Row>
  {content}
</Row>)

  # A disabled toggle that is PRESSED stays filled — greyed rather than accented,
  # but filled. Falling back to the idle background would render "locked on" and
  # "locked off" identically, so the user cannot see what they are locked into.
  # The same rule the chip settled on, and what the web's disabled group shows.
  defp background(_props, true, true), do: :muted
  defp background(props, true, _disabled?), do: Map.get(props, :color) || :primary

  defp background(props, _pressed?, _disabled?),
    do: Map.get(props, :background) || :surface_raised

  defp text_color(props, pressed?, disabled?) do
    cond do
      pressed? -> Map.get(props, :text_color) || :on_primary
      disabled? -> :muted
      true -> Map.get(props, :label_color) || :on_surface
    end
  end

  defp handler(_props, true), do: nil
  defp handler(props, _), do: Event.handler(Map.get(props, :on_change))

  # A prop the caller never set must be ABSENT from the node, not present as
  # `nil`. The tree is serialised with `:json.encode/1`, which renders the atom
  # `nil` as the STRING "nil" — so a defaulted `height: nil` would reach the
  # bridge as `"height":"nil"`, and a bridge that coerces with -doubleValue
  # reads that as 0.0 and collapses the button. Taking only the keys the caller
  # supplied is also what makes an untouched toggle's props map identical, key
  # for key, to the one it built before any of these props existed.
  defp overrides(props, keys) do
    props
    |> Map.take(keys)
    |> Map.reject(fn {_key, value} -> is_nil(value) end)
  end

  defp merge_props(node, extra) when map_size(extra) == 0, do: node
  defp merge_props(node, extra), do: %{node | props: Map.merge(node.props, extra)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
