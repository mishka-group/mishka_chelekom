defmodule MishkaMob.Components.MishkaSegmentedControl do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Segmented Control** — a joined
  strip of options where exactly one is always selected.

  ## Why it is not a Toggle Group with different padding

  It is drawn differently — one continuous track with the selection sitting
  inside it, rather than separate buttons — and it behaves differently in the way
  that matters: **the selection can never be empty**. Tapping the selected
  segment does nothing, where a toggle group would clear and a radio group would
  keep. That is why `select/2` exists and simply returns the tapped id: the rule
  is "always something", and stating it beats each screen rediscovering it.

  When an empty selection is meaningful, reach for
  `MishkaMob.Components.MishkaToggleGroup` instead.

  ## Segments are content-sized, and the track hugs them

  Equal-width segments would need `weight`, which Compose implements and Mob's
  iOS mapping does not, so the strip would look right on Android and collapse on
  iOS. Segments therefore size to their labels — the same compromise the Tabs
  port makes, for the same reason.

  That makes `fill_width` load-bearing on both the track and each segment. A Box
  given neither a width nor the prop **fills its parent**, so an unguarded
  segment took the whole strip and pushed the rest off the screen, and an
  unguarded track stretched to the screen edge around three short labels. Both
  now hug; pass `fill_width={true}` for a strip that should span its container,
  and accept that its segments still cluster at the leading edge.

  ## Styling is the caller's, as on the web

  The headless original ships no colours and no spacing. There is no stylesheet
  here, so every visual is a prop with a legible default.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | option id | first option | The selected segment. |
  | `label` | string | `nil` | Heading above the strip. |
  | `disabled` | boolean | `false` | Disables every segment. |
  | `on_change` | event tag (atom) | — | Sent as `{:tap, {tag, option_id}}`. |
  | `color` | color token / ARGB int | `:primary` | Selected segment fill. |
  | `text_color` | color token / ARGB int | `:on_primary` | Selected segment label. |
  | `label_color` | color token / ARGB int | `:on_surface` | An unselected label. |
  | `background` | color token / ARGB int | `:surface_raised` | The track. |
  | `padding` | spacing token / number | `:space_sm` | Inside each segment. |
  | `padding_top` / `padding_right` / `padding_bottom` / `padding_left` | spacing token / number | unset | One edge of a segment, overriding `padding` on that side only. |
  | `track_padding` | number | `3` | Inset between track and segments. |
  | `corner_radius` | radius token / number | `:radius_md` | The track's corners. |
  | `segment_radius` | radius token / number | `:radius_sm` | A segment's corners. |
  | `border_color` | color token / ARGB int | `nil` | Track border, when set. |
  | `border_width` | number | `0` | Track border width. |
  | `text_size` | text token / number | `:base` | Segment labels. |
  | `font_weight` | `:regular`, `:medium`, `:semibold`, `:bold`, `:light`, `:thin` | unset (regular) | Every segment label's weight. |
  | `selected_weight` | as `font_weight` | whatever `font_weight` is | The selected label only, for a strip that bolds its selection. |
  | `letter_spacing` | number (sp) | unset | Tracking on every segment label. |
  | `line_height` | number | unset | Multiplier of `text_size`; ignored without one. |
  | `max_lines` | number | unset (unlimited) | Caps a segment label and ellipsises the rest. |
  | `fill_width` | boolean | `false` | Track spans its parent. |
  | `width` | number | unset | The track's exact width. |
  | `height` | number | unset | The track's exact height — the trough. |
  | `align` | `:center`, `:leading`, … | unset (top-leading) | Where the segments sit when `height` leaves them room. |
  | `shadow` | shadow spec string | unset | On the track. See "Shadows" below. |
  | `segment_width` | number | unset | A segment's exact width. |
  | `segment_height` | number | unset | A segment's exact height. |
  | `segment_align` | `:center`, `:leading`, … | `:center` | Where a label sits inside its segment. |
  | `segment_weight` | number | unset | Row weight per segment — equal widths. Android only; see below. |
  | `selected_shadow` | shadow spec string | unset | On the selected segment only. |
  | `heading_size` | text token / number | `:sm` | The `label` heading above the strip. |
  | `heading_color` | color token / ARGB int | `:muted` | That heading's colour. |
  | `heading_weight` | as `font_weight` | unset (regular) | That heading's weight. |
  | `heading_gap` | number | `10` | Space between the heading and the track. |
  | `id` | string | `nil` | Prefix for each segment's test tag. |

  Everything from `padding_top` down is a later addition, and every one of them
  defaults to exactly what the control drew before it existed. The ones with a
  value name what was previously hardcoded — `segment_align: :center`,
  `heading_size: :sm`, `heading_color: :muted`, `heading_gap: 10` — and the ones
  marked *unset* have their key **left off the node entirely** rather than
  passed as `nil`, which is not the same thing once the tree is serialised, as
  the note beside the private `overrides` explains. So a control that names none
  of them builds the same props maps, key for key, that it built before they
  existed.

  ## Which prop belongs to the track and which to a segment

  The two are told apart by name, not by position, and the prefixes are not
  symmetrical because the existing ones were not: `padding` is a **segment's**
  and `track_padding` is the track's, while `corner_radius` is the **track's**
  and `segment_radius` is a segment's. The additions follow whichever side each
  neighbour already sits on — `height`, `width`, `align` and `shadow` join
  `corner_radius` on the track; `padding_top` and friends join `padding` on the
  segment; anything that had to be disambiguated took the `segment_` prefix.

  ## Sizing: padding is applied BEFORE width and height

  The bridge builds each node's modifier chain padding-first, so `height`
  measures the box *inside* the padding. A 36pt trough with a 3pt inset is
  `height: 30, track_padding: 3`, and a 28pt segment inside it is
  `segment_height: 28` with no vertical padding of its own. Pin the outer
  dimension by pairing the two, or drop the padding on the axis you pin.
  `width` / `height` want a plain number — they are not spacing props, so a
  token reaches the bridge unresolved and is ignored. Negative padding throws on
  the native side; never compute one.

  `text_size` also takes a raw number in sp for a design pinned to, say, 10.5.
  Only the token form is multiplied by the theme's `type_scale`, so a numeric
  size stays put when the user scales their type.

  ## Shadows

  `shadow` and `selected_shadow` are not interpreted here — they ride on the
  track and on the selected segment for the bridge to read, in CSS `box-shadow`
  order (`"dx dy blur spread #AARRGGBB"`, further layers after a pipe). The
  selected one is a prop of its own because the caller cannot reach that node:
  the control decides which segment is selected, so a screen has nowhere else to
  hang the lift under it. A bridge without shadow support ignores both props, as
  it ignores any key it does not know.

  ## Equal-width segments, and why they are still not the default

  `segment_weight` puts a `weight` on each segment Box, which is what Compose's
  Row reads to divide its width evenly — and the segments are direct children of
  that Row, so no wrapper is needed. Mob's iOS mapping implements no layout
  weight, so the prop is Android-only and the strip stays content-sized there.
  That asymmetry is exactly why it is opt-in and unset by default: a control that
  is right on one platform and collapsed on the other should be a decision, not
  a surprise. Pair it with `fill_width={true}` so the Row has a width to divide.

  ## Slots

  Segments are written out as children, the native analogue of Chelekom's
  `<:option>` slot, so the markup reads the way the Phoenix component does:

      <MishkaSegmentedControl value={@view} on_change={:pick} id="view">
        <MishkaSegmentedControlOption id={:day} label="Day" />
        <MishkaSegmentedControlOption id={:week} label="Week" />
        <MishkaSegmentedControlOption id={:month} label="Month" disabled={true} />
      </MishkaSegmentedControl>

  | Slot | Takes | Builds the same node as |
  |------|-------|-------------------------|
  | `<MishkaSegmentedControlOption>` | `id`, `label`, `disabled` | `option/3` |

  A slot tag is matched on `:type` among the parent's children and consumed by
  `expand/3`, so it never reaches the renderer. `option/3` produces exactly the
  node the tag does — `%{type: :mishka_segmented_control_option, props: %{id: …,
  label: …, disabled: …}}` — and the two forms are interchangeable. Use the tag
  when you are writing the segments out, the function when they come from data:

      <MishkaSegmentedControl value={@role} on_change={:pick}>
        {Enum.map(@roles, fn {id, label} -> option(id, label) end)}
      </MishkaSegmentedControl>

  The label is a prop rather than the slot's children because the control paints
  it: `text_size`, and the selected/idle `text_color`, are the control's props,
  so the `Text` node has to be the control's to build.

  `on_change` stays on the control rather than moving to the option. An `on_*`
  prop on a slot tag is not auto-wired the way a composite's is, so an option
  carrying its own handler would hand the renderer a bare atom; the control
  instead pairs its already-wired tag with each option's id.

  Given `id="view"`, the `:week` segment is tagged `"view-week-selected"` or
  `"view-week-idle"`. Selection is conveyed by fill colour alone, and colour is
  not in the accessibility tree, so those tags are the only thing a device test
  can read.

  Not ported: `name` (form plumbing) and the `*_class` attrs.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  # The slot tag and the builder share one atom on purpose: that is what makes
  # <MishkaSegmentedControlOption> and option/3 the same node, and so
  # interchangeable everywhere.
  @option_type :mishka_segmented_control_option

  # Track props that must be ABSENT when the caller says nothing, rather than
  # present-and-nil. See `overrides/2` for why the difference is visible.
  # `border_color` joined them: it has no default (the track draws no border
  # unless asked), but it was interpolated INTO the node, so an absent one
  # still landed in the props map as nil — and `:json` encodes an atom as a
  # string, so the bridge received "border_color":"nil" to resolve as a
  # colour token.
  @track_overrides ~w(width height align shadow border_color)a

  # A segment's own edge padding. Unprefixed, because `padding` is already the
  # segment's and `track_padding` already the track's.
  @segment_overrides ~w(padding_top padding_right padding_bottom padding_left)a

  # Segment props the caller spells with a prefix, mapped to the node key the
  # bridge reads: `segment_height` is a segment's `height`, and so on.
  @segment_aliases %{segment_width: :width, segment_height: :height, segment_weight: :weight}

  # The heading above the strip is a Text like any other, so its weight prop is
  # the same key under a name that cannot be mistaken for a segment's.
  @heading_aliases %{heading_weight: :font_weight}

  # Label props, absent rather than defaulted. Most have no safe neutral value:
  # Compose resolves an unset `letter_spacing` / `line_height` from the ambient
  # text style, and Material's body style is not 0 / 1.0, so writing those
  # "neutral" numbers would visibly retrack and re-lead every existing segment;
  # `max_lines` unset means unlimited, and any number starts ellipsising.
  # `font_weight` does have a neutral (`:regular`) and is still left off, so a
  # control nobody restyled builds the maps it always built, key for key.
  @text_overrides ~w(letter_spacing line_height max_lines)a

  @doc """
  Composite expander (`<MishkaSegmentedControl>`).

  Children are `<MishkaSegmentedControlOption>` slot tags — or the identical
  nodes from `option/3` — matched on `:type` and consumed here, so no marker
  ever reaches the renderer. Anything else among the children is dropped.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: segmented_control(props, children)

  @doc """
  Build one segment node — exactly what `<MishkaSegmentedControlOption>` builds.

  Reach for it when the segments come from data; write the tag when you are
  spelling them out.
  """
  @spec option(term(), String.t(), keyword()) :: map()
  def option(id, label, opts \\ []) do
    %{
      type: @option_type,
      props: %{id: id, label: label, disabled: Keyword.get(opts, :disabled, false)},
      children: []
    }
  end

  @doc """
  The next value after tapping `id` — always the tapped one.

  A segmented control cannot be cleared, so re-tapping the selection is a no-op
  rather than an empty state.

      iex> MishkaMob.Components.MishkaSegmentedControl.select(:a, :b)
      :b
      iex> MishkaMob.Components.MishkaSegmentedControl.select(:a, :a)
      :a
  """
  @spec select(term(), term()) :: term()
  def select(_current, tapped), do: tapped

  @doc """
  The control node. Children are `<MishkaSegmentedControlOption>` tags or
  `option/3` nodes — the same thing either way.
  """
  @spec segmented_control(map() | keyword(), [map()]) :: map()
  def segmented_control(props \\ %{}, children \\ []) do
    props = Map.new(props)
    label = Map.get(props, :label)

    # The slot tags are read for their props and then dropped: only the segments
    # built below go into the tree. A marker that survived would reach the
    # renderer, whose `when (node.type)` has no else branch, and draw nothing at
    # all — silently, because mix.exs has whitelisted the name.
    #
    # A tag written without `disabled` has no such key, where option/3 defaults
    # it, so everything downstream reads it with a default rather than a match.
    options =
      children
      |> Enum.filter(&match?(%{type: @option_type}, &1))
      |> Enum.map(& &1.props)

    selected = selected(props, options)
    segments = Enum.map(options, &segment(&1, props, Map.get(&1, :id) == selected))

    # The track and its Row must BOTH be told, or the strip stretches to the
    # screen edge around three short labels: a Box with no width fills, and a
    # Row that fills leaves a hugging track wrapping a full-width child.
    fill? = truthy?(Map.get(props, :fill_width, false))

    ~MOB"""
    <Column fill_width={true}>
      {heading(props, label)}
      {track(props, segments, fill?)}
    </Column>
    """
  end

  # Two nodes or none, which is what the `:if` on each of them used to say. It
  # moved out of the sigil so `heading_weight` can be MERGED onto the Text when
  # it is set, rather than written into it as a `nil` when it is not — the
  # distinction `overrides/2` exists for.
  defp heading(_props, label) when not is_binary(label), do: []

  defp heading(props, label) do
    text = ~MOB"""
    <Text
      text={label}
      text_size={Map.get(props, :heading_size) || :sm}
      text_color={Map.get(props, :heading_color) || :muted}
    />
    """

    gap = ~MOB"""
    <Spacer size={Map.get(props, :heading_gap) || 10} />
    """

    [merge_props(text, aliased(props, @heading_aliases)), gap]
  end

  defp track(props, segments, fill?) do
    # `border_color` arrives through @track_overrides, not the template.
    ~MOB"""
    <Box
      fill_width={fill?}
      background={Map.get(props, :background) || :surface_raised}
      corner_radius={Map.get(props, :corner_radius) || :radius_md}
      padding={Map.get(props, :track_padding) || 3}
      border_width={Map.get(props, :border_width) || 0}
    >
      <Row fill_width={fill?}>
        {segments}
      </Row>
    </Box>
    """
    |> merge_props(overrides(props, @track_overrides))
  end

  @doc """
  The selected id: the `value` prop when it names a real option, otherwise the
  first — a segmented control always has a selection.
  """
  @spec selected(map() | keyword(), [map()]) :: term() | nil
  def selected(props, options) do
    ids = Enum.map(options, &Map.get(&1, :id))
    wanted = props |> Map.new() |> Map.get(:value)

    if wanted in ids, do: wanted, else: List.first(ids)
  end

  defp segment(option, props, selected?) do
    disabled? =
      truthy?(Map.get(props, :disabled, false)) or truthy?(Map.get(option, :disabled, false))

    fill = segment_fill(props, selected?, disabled?)
    text_color = segment_ink(props, selected?, disabled?)

    # fill_width: false is what keeps a segment the size of its label. Without
    # it the first segment claims the whole strip and the others are pushed off
    # the screen — present in the tree, correct in every unit test, invisible on
    # the device. It is also what makes the "content-sized" claim above true.
    # `segment_weight` is the deliberate way out of it, and stays off by default
    # because Mob's iOS mapping has no layout weight to honour.
    node = ~MOB"""
    <Box
      fill_width={false}
      background={fill}
      corner_radius={Map.get(props, :segment_radius) || :radius_sm}
      padding={Map.get(props, :padding) || :space_sm}
      align={Map.get(props, :segment_align) || :center}
    >
      <Text
        text={Map.get(option, :label) || ""}
        text_size={Map.get(props, :text_size) || :base}
        text_color={text_color}
      />
    </Box>
    """

    node
    |> merge_props(overrides(props, @segment_overrides))
    |> merge_props(aliased(props, @segment_aliases))
    |> merge_props(selected_shadow(props, selected?))
    |> restyle_label(Map.merge(overrides(props, @text_overrides), weight(props, selected?)))
    |> tag_state(Map.get(props, :id), Map.get(option, :id), selected?)
    |> wire(tap(props, option, disabled?))
  end

  # A disabled selection is greyed rather than accented — the same rule the
  # toggle settled on, so a locked control reads as locked instead of live.
  defp segment_fill(_props, true, true), do: :muted
  defp segment_fill(props, true, _disabled?), do: Map.get(props, :color) || :primary
  defp segment_fill(_props, _selected?, _disabled?), do: :transparent

  defp segment_ink(props, true, _disabled?), do: Map.get(props, :text_color) || :on_primary
  defp segment_ink(_props, _selected?, true), do: :muted
  defp segment_ink(props, _selected?, _disabled?), do: Map.get(props, :label_color) || :on_surface

  # The selected label may carry its own weight — an iOS-style strip bolds its
  # selection — falling back to the strip-wide one, and then to nothing at all,
  # which is the weight every segment drew before either prop existed.
  defp weight(props, selected?) do
    selected_weight = if selected?, do: Map.get(props, :selected_weight)

    case selected_weight || Map.get(props, :font_weight) do
      nil -> %{}
      weight -> %{font_weight: weight}
    end
  end

  # A lift under the CHOSEN segment, which is the one the caller cannot address:
  # the control picks it, so there is no node for a screen to hang a shadow on.
  defp selected_shadow(props, true) do
    case Map.get(props, :selected_shadow) do
      nil -> %{}
      spec -> %{shadow: spec}
    end
  end

  defp selected_shadow(_props, _selected?), do: %{}

  # The label is the segment's only child, so it is reached by rebuilding that
  # one child rather than by walking the tree.
  defp restyle_label(node, extra) when map_size(extra) == 0, do: node

  defp restyle_label(node, extra),
    do: %{node | children: Enum.map(node.children, &merge_props(&1, extra))}

  defp wire(node, nil), do: node
  defp wire(node, handler), do: %{node | props: Map.put(node.props, :on_tap, handler)}

  # Selection is a fill colour, and colour is not in the accessibility tree, so
  # nothing tells a device test which segment is chosen. Fold it into the tag.
  defp tag_state(node, nil, _option_id, _selected?), do: node

  defp tag_state(node, id, option_id, selected?) do
    state = if selected?, do: "selected", else: "idle"
    %{node | props: Map.put(node.props, :id, "#{id}-#{option_id}-#{state}")}
  end

  defp tap(_props, _option, true), do: nil

  # Event.handler/2, not a hand-built {tag, id}: reached as a composite tag this
  # control's :on_change has ALREADY been widened to {screen_pid, tag}, and
  # pairing that with an id by hand gives {{pid, tag}, id} — which the renderer
  # registers and no handle_info clause matches.
  defp tap(props, option, _disabled),
    do: Event.handler(Map.get(props, :on_change), Map.get(option, :id))

  # A prop the caller never set must be ABSENT from the node, not present as
  # `nil`. The tree is serialised with `:json.encode/1`, which renders the atom
  # `nil` as the STRING "nil" — so a defaulted `height: nil` would reach the
  # bridge as `"height":"nil"`, and a bridge that coerces with -doubleValue
  # reads that as 0.0 and collapses the track. Taking only the keys the caller
  # supplied is also what makes an untouched control's props maps identical, key
  # for key, to the ones it built before any of these props existed.
  defp overrides(props, keys) do
    props
    |> Map.take(keys)
    |> Map.reject(fn {_key, value} -> is_nil(value) end)
  end

  # The same, for the props whose caller-facing name is prefixed — a caller's
  # `segment_height: 28` becomes plain `height: 28` on the segment's own node,
  # which is the key the bridge actually reads.
  defp aliased(props, aliases) do
    aliases
    |> Enum.flat_map(fn {from, to} ->
      case Map.get(props, from) do
        nil -> []
        value -> [{to, value}]
      end
    end)
    |> Map.new()
  end

  defp merge_props(node, extra) when map_size(extra) == 0, do: node
  defp merge_props(node, extra), do: %{node | props: Map.merge(node.props, extra)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
