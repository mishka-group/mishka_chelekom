defmodule MishkaMob.Components.MishkaPreviewCard do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Preview Card** — a trigger you
  hold, and the card of detail it reveals about the thing it names.

  ## Both halves of the anatomy, not just the popup

  The web component is a `<:trigger>` *plus* a `popup`: hovering or focusing the
  trigger reveals the preview beside it. This port shipped with the popup alone,
  which left every caller to invent the half that decides *when* it opens — and
  made `id`, `side` and `align` look unportable when it was only the missing
  trigger that made them meaningless.

  A phone has no hover. It has the gesture that stands in for hover everywhere
  else on a touch screen: a **long press**. So the trigger is a real part again.
  Hold it and `on_hold` fires; a plain tap falls through to `on_tap`, because the
  web's trigger is usually a link and tapping a link should still follow it.

  Nothing here owns the open state — `open` is the screen's, exactly as with
  `MishkaMob.Components.MishkaPopover`, so holding the trigger a second time can
  close the card, or not, as the screen prefers.

  ## What `side` and `align` honestly mean here

  There is still no anchored positioning (see `MishkaMob.Components.MishkaPopover`
  for why a render function cannot measure its trigger). But once the trigger is
  *inside* the component, `side` no longer needs a measurement to mean something:
  it is the order and the axis of the two parts.

    * `:bottom` (default) / `:top` — a Column; the card sits under or over the
      trigger.
    * `:left` / `:right` — a Row; the card sits beside it. Both parts carry a
      weight so neither starves the other, which on a phone-width screen means
      roughly half the width each. Cramped, and offered because the web offers
      it, not because it is the shape to reach for.

  `align` positions the arrow along the card's facing edge, which is the only
  thing alignment can move while the card itself spans the width. `side_offset`
  is the real gap between the two parts; `align_offset` nudges the arrow.

  ## Everything carries a testTag

  `id` is the root of a small family of native tags, because a device test can
  read neither a colour nor a glyph nor a position:

  | Tag | What it proves |
  |---|---|
  | `<id>-open` / `<id>-closed` | the root's `data-open` / `data-closed` |
  | `<id>-trigger` | the thing to hold — deliberately stable, since a tag that changed with the state could not be found in order to change it |
  | `<id>-popup-<side>` | the popup, and which side it took |
  | `<id>-arrow-<align>` | the arrow, and where along the edge it sits |
  | `<id>-title` `<id>-subtitle` `<id>-description` `<id>-avatar` `<id>-footer` | the parts, addressable without a page-wide text query |

  `id` is also the value `on_hold` and `on_tap` report, so one screen clause
  serves a whole list of triggers.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `id` | string | `nil` | testTag root, and the value the trigger events carry. |
  | `open` | boolean | `false` | Whether the card is shown. |
  | `trigger` | node / [node] | `nil` | What you hold. Renders in both states. |
  | `on_hold` | event tag | `nil` | Long press on the trigger — `{:tap, {tag, id}}`. |
  | `on_tap` | event tag | `nil` | Plain tap on the trigger — `{:tap, {tag, id}}`. |
  | `side` | `:bottom` `:top` `:left` `:right` | `:bottom` | Where the card sits relative to the trigger. |
  | `align` | `:start` `:center` `:end` | `:center` | Where the arrow sits along the facing edge. |
  | `side_offset` | number | `8` | Gap between trigger and card, in dp. |
  | `align_offset` | number | `0` | Nudge along the alignment axis, in dp. |
  | `arrow` | boolean | `false` | Draw the pointer back at the trigger. |
  | `arrow_color` | color token / ARGB int | `:border` | Arrow colour. |
  | `title` | string | `nil` | The name. |
  | `subtitle` | string | `nil` | A line of context under it. |
  | `description` | string | `nil` | The body. |
  | `initials` / `image` | string | `nil` | Avatar content — omit both and there is no avatar. |
  | `avatar_color` | color token / ARGB int | `:primary` | Avatar fill. |
  | plus everything `MishkaMob.Components.MishkaPopover` accepts | | | |

  Children become the card's footer, which is where actions belong.

  Not ported: `delay` and `close_delay` (there is no hover to delay, and the long
  press has a hold time of its own), `close_on_escape` (a component cannot claim
  the system back gesture — the screen owns it), and the `*_class` attrs.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Event, MishkaAvatar, MishkaPopover}

  @sides [:top, :right, :bottom, :left]
  @aligns [:start, :center, :end]

  # Words are accepted too, since the web attrs are strings and a caller porting
  # a template should not have to translate them. Looked up rather than
  # converted, so a typo cannot mint an atom.
  @words %{
    "top" => :top,
    "right" => :right,
    "bottom" => :bottom,
    "left" => :left,
    "start" => :start,
    "center" => :center,
    "end" => :end
  }

  # The arrow points BACK at the trigger, so its glyph is the opposite of the
  # side the card took: a card below the trigger points up at it.
  @glyphs %{bottom: "▲", top: "▼", left: "▶", right: "◀"}

  @doc "Composite expander (`<MishkaPreviewCard>`). Children are the footer."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: preview_card(props, children)

  @doc """
  Wrap the thing whose preview this is, so holding it asks for the card.

  `preview_card/2` uses this for its own `trigger` prop. It is public because a
  trigger sometimes has to live somewhere the card cannot reach — inside a list
  row, say, with the card rendered at the foot of the screen.

      trigger("elixir", [link_text()], on_hold: :preview, test_id: "elixir-trigger")

  `on_hold` is the long press, the touch equivalent of the web's hover; `on_tap`
  is whatever the trigger already did. Both report `{:tap, {tag, id}}`, so one
  screen clause serves a list of them.
  """
  @spec trigger(term(), [map()], keyword()) :: map()
  def trigger(id, children, opts \\ []) do
    %{type: :box, props: %{}, children: children}
    |> put(:fill_width, if(Keyword.get(opts, :fill_width, true), do: true))
    |> put(:on_long_press, Event.handler(Keyword.get(opts, :on_hold), id))
    |> put(:on_tap, Event.handler(Keyword.get(opts, :on_tap), id))
    |> put(:id, Keyword.get(opts, :test_id))
  end

  @doc """
  The preview-card node — trigger, gap, arrow and popup.

  The trigger renders in both states; the rest appears only when `open`.

      <MishkaPreviewCard
        id="shahryar"
        open={@preview == "shahryar"}
        trigger={[handle("@shahryar")]}
        on_hold={:preview}
        arrow={true}
        title="Shahryar"
      >{[follow_button()]}</MishkaPreviewCard>
  """
  @spec preview_card(map() | keyword(), [map()]) :: map()
  def preview_card(props \\ %{}, footer \\ []) do
    props = Map.new(props)
    id = Map.get(props, :id)
    side = one_of(Map.get(props, :side), @sides, :bottom)
    align = one_of(Map.get(props, :align), @aligns, :center)
    trigger = trigger_part(props, side)

    if truthy?(Map.get(props, :open, false)) do
      root(side, align, id, "-open", parts(props, footer, id, side, align, trigger))
    else
      closed(side, align, id, trigger)
    end
  end

  # A closed card with no trigger is still nothing at all. The tag is the only
  # thing left of it, and it is what a device test reads instead of trying to
  # prove the absence of a colour.
  defp closed(_side, _align, id, []), do: put(~MOB(<Column />), :id, tag(id, "-closed"))
  defp closed(side, align, id, trigger), do: root(side, align, id, "-closed", trigger)

  defp root(side, _align, id, suffix, children) when side in [:top, :bottom] do
    %{type: :column, props: %{fill_width: true}, children: children}
    |> put(:id, tag(id, suffix))
  end

  # Beside the trigger the two parts share one line, so the row's own vertical
  # alignment is what `align` can act on — a Column has no horizontal alignment
  # prop to hang it off instead.
  defp root(_side, align, id, suffix, children) do
    %{type: :row, props: %{fill_width: true, align: row_align(align)}, children: children}
    |> put(:id, tag(id, suffix))
  end

  defp row_align(:start), do: "top"
  defp row_align(:end), do: "bottom"
  defp row_align(_align), do: "center"

  defp parts(props, footer, id, side, align, trigger) do
    popup = [popup(props, footer, id, side)]
    gap = gap(props, trigger)
    arrow = arrow(props, id, side, align)

    if side in [:bottom, :right] do
      trigger ++ gap ++ arrow ++ popup
    else
      popup ++ arrow ++ gap ++ trigger
    end
  end

  defp trigger_part(props, side) do
    case List.wrap(Map.get(props, :trigger)) do
      [] ->
        []

      nodes ->
        id = Map.get(props, :id)

        node =
          trigger(id, nodes,
            on_hold: Map.get(props, :on_hold),
            on_tap: Map.get(props, :on_tap),
            test_id: tag(id, "-trigger"),
            fill_width: side in [:top, :bottom]
          )

        [put(node, :weight, weight(side))]
    end
  end

  defp popup(props, footer, id, side) do
    props
    |> MishkaPopover.panel([header(props, id), body(props, id), footer_part(footer, id)])
    |> put(:id, tag(id, "-popup-#{side}"))
    |> put(:weight, weight(side))
  end

  # Beside the trigger both halves have to be weighted. A Box with neither a
  # width nor `fill_width` fills its parent, and Compose measures a Row's
  # unweighted children first — so whichever half went unweighted would take the
  # whole row and starve the other.
  defp weight(side) when side in [:left, :right], do: 1
  defp weight(_side), do: nil

  # The gap separates the trigger from the card. With no trigger there is no
  # pair to separate, and a leading spacer would only push the card down.
  defp gap(_props, []), do: []

  defp gap(props, _trigger) do
    case Map.get(props, :side_offset, 8) do
      size when is_number(size) and size > 0 ->
        [%{type: :spacer, props: %{size: size}, children: []}]

      _ ->
        []
    end
  end

  defp arrow(props, id, side, align) do
    if truthy?(Map.get(props, :arrow, false)), do: [arrow_node(props, id, side, align)], else: []
  end

  defp arrow_node(props, id, side, align) when side in [:top, :bottom] do
    glyph = glyph(props, id, side, align, :offset_x)
    edge = %{type: :spacer, props: %{size: 14}, children: []}
    flex = %{type: :spacer, props: %{weight: 1}, children: []}

    children =
      case align do
        :start -> [edge, glyph, flex]
        :end -> [flex, glyph, edge]
        _center -> [flex, glyph, flex]
      end

    %{type: :row, props: %{fill_width: true}, children: children}
  end

  defp arrow_node(props, id, side, align), do: glyph(props, id, side, align, :offset_y)

  defp glyph(props, id, side, align, offset_key) do
    %{
      type: :text,
      props: %{
        text: Map.fetch!(@glyphs, side),
        text_size: :sm,
        text_color: Map.get(props, :arrow_color, :border),
        max_lines: 1
      },
      children: []
    }
    |> put(:id, tag(id, "-arrow-#{align}"))
    |> put(offset_key, nudge(Map.get(props, :align_offset, 0)))
  end

  defp nudge(offset) when is_number(offset) and offset != 0, do: offset
  defp nudge(_offset), do: nil

  defp header(props, id) do
    avatar = avatar_part(props, id)
    title = line(Map.get(props, :title), tag(id, "-title"), :lg, :on_surface)
    subtitle = line(Map.get(props, :subtitle), tag(id, "-subtitle"), :sm, :muted)
    lines = title ++ between(title, subtitle, 2) ++ subtitle

    cond do
      avatar == [] and lines == [] ->
        ~MOB(<Column />)

      avatar == [] ->
        %{type: :column, props: %{fill_width: true}, children: lines}

      lines == [] ->
        %{type: :row, props: %{fill_width: true}, children: avatar}

      true ->
        # The names are the flexible half. Compose measures a Row's unweighted
        # children first, so a text column left to fill the width would be
        # measured before the avatar and leave it nothing.
        names = %{
          type: :box,
          props: %{weight: 1},
          children: [%{type: :column, props: %{fill_width: true}, children: lines}]
        }

        %{
          type: :row,
          props: %{fill_width: true},
          children: avatar ++ [%{type: :spacer, props: %{size: 12}, children: []}, names]
        }
    end
  end

  # An avatar with neither initials nor an image is an empty circle claiming
  # 48dp of the header. The web has no avatar part at all, so the honest default
  # when there is nothing to show is none.
  defp avatar_part(props, id) do
    initials = Map.get(props, :initials)
    image = Map.get(props, :image)

    if is_binary(initials) or is_binary(image) do
      [
        MishkaAvatar.avatar(
          id: tag(id, "-avatar"),
          initials: initials,
          src: image,
          size: 48,
          background: Map.get(props, :avatar_color, :primary),
          color: :on_primary
        )
      ]
    else
      []
    end
  end

  # A name squeezed narrower than itself wraps character by character, which
  # reads as a broken layout rather than as a long name — so one line, elided.
  defp line(text, id, size, color) when is_binary(text) do
    node = %{
      type: :text,
      props: %{text: text, text_size: size, text_color: color, max_lines: 1},
      children: []
    }

    [put(node, :id, id)]
  end

  defp line(_text, _id, _size, _color), do: []

  defp between([], _b, _size), do: []
  defp between(_a, [], _size), do: []
  defp between(_a, _b, size), do: [%{type: :spacer, props: %{size: size}, children: []}]

  defp body(props, id) do
    case Map.get(props, :description) do
      description when is_binary(description) ->
        # The body is the one part allowed to wrap, so it carries no max_lines.
        node = %{
          type: :text,
          props: %{text: description, text_size: :base, text_color: :on_surface},
          children: []
        }

        %{
          type: :column,
          props: %{fill_width: true},
          children: [
            %{type: :spacer, props: %{size: 12}, children: []},
            put(node, :id, tag(id, "-description"))
          ]
        }

      _ ->
        ~MOB(<Column />)
    end
  end

  defp footer_part([], _id), do: ~MOB(<Column />)

  defp footer_part(nodes, id) do
    row = put(%{type: :row, props: %{fill_width: true}, children: nodes}, :id, tag(id, "-footer"))

    %{
      type: :column,
      props: %{fill_width: true},
      children: [%{type: :spacer, props: %{size: 14}, children: []}, row]
    }
  end

  defp tag(nil, _suffix), do: nil
  defp tag(id, suffix) when is_binary(id), do: id <> suffix
  defp tag(id, suffix), do: to_string(id) <> suffix

  defp one_of(value, allowed, default) do
    case value do
      atom when is_atom(atom) -> if atom in allowed, do: atom, else: default
      word when is_binary(word) -> one_of(Map.get(@words, word), allowed, default)
      _other -> default
    end
  end

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
