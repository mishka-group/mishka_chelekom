defmodule MishkaMob.Components.MishkaToolbar do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Toolbar** — a strip of related
  controls, in groups, with separators between them.

  ## What a toolbar is, once the keyboard is gone

  On the web a toolbar is partly a *keyboard* construct: it makes a row of
  controls one tab stop and moves focus between them with the arrow keys
  (`loop`, `focusable_when_disabled`). There is no roving tabindex on a phone and
  no arrow keys, so that part does not travel. Everything else does, and it turns
  out to be most of the component: the four item kinds (`<MishkaToolbarButton>`,
  `<MishkaToolbarLink>`, `<MishkaToolbarInput>`, `<MishkaToolbarSeparator>`), the
  chunking of consecutive items that share a `:group`, per-item and whole-bar
  `disabled`, and the orientation the separators follow.

  Arbitrary nodes still pass through untouched, so a toolbar can hold a
  `MishkaMob.Components.MishkaToggle` or a
  `MishkaMob.Components.MishkaToggleGroup` beside its own items — it invents no
  button type it can avoid inventing.

  ## `label` is the hint, and a long press is the hover

  On the web an item's `label` is its `aria-label`: an icon-only button says
  "Undo" to a screen reader, and a desktop browser shows the same string as a
  tooltip on hover. Mob exposes no accessible name, and a touch screen has no
  hover — but it does have a long press, which is what a phone uses for exactly
  this. So an item with an `:icon` draws the glyph, holding it fires `on_hold`,
  and passing the reported id back as `hint` prints that item's `label` under the
  strip. The web's invisible name becomes a visible one, on demand.

  That is also how `focusable_when_disabled` ports. On the web a disabled item
  stays in the roving order so it remains *discoverable*. Here a disabled item
  still answers a long press with its label — it cannot be activated, but you can
  still find out what it is. Set `focusable_when_disabled: false` to take that
  away too.

  Buttons and links carry the hold; an input does not, because a text field
  consumes its own long press to place a selection.

  ## Nothing wraps, so overflow is a decision

  A `Row` runs off the edge rather than flowing onto a second line, and nothing
  measures itself, so a toolbar with more controls than fit is simply clipped by
  the strip's Box. `overflow` names what to do instead:

    * `:none` (default) — the web's behaviour, and a plain Row.
    * `:scroll` — the strip scrolls along its own axis. The phone idiom, and the
      only mode that keeps every control reachable without a second surface.
    * `:collapse` — keep `visible` controls and put a `⋯` at the end, which
      reports `on_overflow` so a screen can show the rest in a
      `MishkaMob.Components.MishkaDrawer`. `split/2` is the whole policy, pure
      and testable.

  ## Slots

  The items are written as tags, so a toolbar reads the way the Phoenix component
  does — the web's `<:item>` types, one tag each:

      <MishkaToolbar id="fmt" on_select={:act} on_hold={:hint} hint={@hint}>
        <MishkaToolbarButton id={:bold} label="Bold" icon="B" />
        <MishkaToolbarButton id={:italic} label="Italic" icon="I" />
        <MishkaToolbarSeparator />
        <MishkaToolbarLink id={:docs} label="Docs" href="https://mishka.tools" />
        <MishkaToolbarInput id={:find} placeholder="Find…" value={@query} />
      </MishkaToolbar>

  | Slot | Builder | Takes |
  |------|---------|-------|
  | `<MishkaToolbarButton>` | `button/3` | `id`, `label`, `icon`, `disabled`, `group` |
  | `<MishkaToolbarLink>` | `link/3` | the same, plus `href` |
  | `<MishkaToolbarInput>` | `input/2` | `id`, `placeholder`, `value`, `width`, `label`, `disabled`, `group` |
  | `<MishkaToolbarSeparator>` | `separator/1` | `group` |

  A tag and its builder produce the **identical** node — `expand/3` routes every
  slot tag back through the builder — so pick by where the items come from. Write
  the tags when you are writing the bar out; call the builders when the items come
  from data:

      <MishkaToolbar id="tb" overflow={:scroll} on_select={:act}>
        {Enum.map(@tools, fn {id, label, icon} ->
          MishkaToolbar.button(id, label, icon: icon)
        end)}
      </MishkaToolbar>

  No item tag carries its own `on_*`: one `on_select` on the bar serves every
  button and link, because each reports its own `id`.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `id` | string | `nil` | Test tag. Items get `<id>-<item_id>`. |
  | `orientation` | `:horizontal` `:vertical` | `:horizontal` | Layout axis. Separators follow it. |
  | `disabled` | boolean | `false` | Disables every item in the bar. |
  | `focusable_when_disabled` | boolean | `true` | A disabled item still answers a long press. |
  | `on_select` | event tag (atom) | — | `{:tap, {tag, item_id}}` from a button or link. |
  | `on_hold` | event tag (atom) | — | `{:tap, {tag, item_id}}` from a long press. |
  | `on_input` | event tag (atom) | — | `{:change, {tag, item_id}, value}` from an input. |
  | `on_overflow` | event tag (atom) | — | `{:tap, tag}` from the `⋯`. |
  | `hint` | item id | `nil` | Prints that item's `label` under the strip. |
  | `overflow` | `:none` `:scroll` `:collapse` | `:none` | What too many controls do. |
  | `visible` | integer | `3` | Controls kept when `overflow: :collapse`. |
  | `space` | number | `8` | Gap between items. |
  | `height` | number | `nil` | Bounds the strip — a vertical `:scroll` needs it. |
  | `background` | color token / ARGB int | `:surface_raised` | Strip fill. |
  | `corner_radius` | radius token / number | `:radius_md` | Strip corners. |
  | `padding` | spacing token / number | `:space_sm` | Padding inside the strip. |
  | `group_background` | color token / ARGB int | `:surface` | Fill behind a labelled group. |
  | `item_color` | color token / ARGB int | `:on_surface` | Button ink. |
  | `link_color` | color token / ARGB int | `:primary` | Link ink. |

  Not ported: `loop` (roving focus), `class` / `group_class` (there is no
  stylesheet — every visual decision is a prop instead), and `label` as an
  *announced* name, which is the gap the hint works around.

  ## The input is the flexible one, and only when it can be

  Compose measures a Row's unweighted children first, in order, each against what
  is left — so an unweighted `TextField` with `fill_width` eats the row and the
  buttons after it get the scraps. An input item therefore sits in a `weight: 1`
  box, which inverts that: the buttons take their natural width and the field
  takes the remainder.

  Except under `overflow: :scroll`, where the Row is measured against an
  unbounded width and a weight has nothing to divide. There the input falls back
  to a fixed `:width` (160 by default) — which is what a scrolling strip wants
  anyway, since nothing inside one should be flexible.

  ## What iOS does not do yet

  Three of this component's layout guarantees are Android-only, all for reasons
  that live in `IOS_TODO.md` rather than here. `weight` is read nowhere in
  `MobRootView.swift` (item 13), so the measurement order above is not enforced.
  `MobBox` never reads `fill_width` (item 6), so a group cluster fills the strip
  instead of hugging its items — the same bug that makes a chip full-width there.
  And `Text` has no `max_lines` (item 9), so an over-packed strip stacks letters
  vertically rather than ellipsising. `height` is likewise dropped unless a width
  is also set (item 1), which is what a vertical `overflow: :scroll` needs.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @button :mishka_toolbar_button
  @link :mishka_toolbar_link
  @input :mishka_toolbar_input
  @sep :mishka_toolbar_separator

  @slot_types [@button, @link, @input, @sep]

  # Wide enough for "Find…" plus a few characters, and used only where a weight
  # cannot be: inside a scrolling strip, and in a vertical bar.
  @default_input_width 160

  # A separator in a horizontal bar is as tall as a padded item.
  @hairline 22

  @doc """
  Composite expander (`<MishkaToolbar>`). Children are the items.

  Each of the four slot tags is matched on `:type` and consumed here — a slot tag
  has no module and no expander of its own, so a tag the parent does not take is
  serialised straight to the renderer, which has never heard of it and draws
  nothing. Anything that is not one of ours passes through as an ordinary control.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx) do
    toolbar(props, children |> List.wrap() |> Enum.map(&from_tag/1))
  end

  # A slot tag arrives with its attributes as raw props — whatever the caller did
  # not write is simply absent — while a builder fills every key in. Routing the
  # tag back through its own builder is what makes the two forms the SAME node
  # rather than two nodes that happen to render alike, so `<MishkaToolbarButton>`
  # and `button/3` stay interchangeable even if a default here later changes. A
  # nil attribute counts as an absent one, as it does everywhere else in Mob.
  defp from_tag(%{type: @button, props: props}) do
    button(Map.get(props, :id), Map.get(props, :label), opts(props, [:icon, :disabled, :group]))
  end

  defp from_tag(%{type: @link, props: props}) do
    link(
      Map.get(props, :id),
      Map.get(props, :label),
      opts(props, [:href, :icon, :disabled, :group])
    )
  end

  defp from_tag(%{type: @input, props: props}) do
    input(
      Map.get(props, :id),
      opts(props, [:label, :placeholder, :value, :width, :disabled, :group])
    )
  end

  defp from_tag(%{type: @sep, props: props}), do: separator(opts(props, [:group]))

  defp from_tag(node), do: node

  defp opts(props, keys) do
    keys
    |> Enum.map(&{&1, Map.get(props, &1)})
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
  end

  @doc """
  A command — the builder behind `<MishkaToolbarButton>`. `id` is what
  `on_select` and `on_hold` report.

  Options: `:icon`, `:disabled`, `:group`.

  With an `:icon` the glyph is what gets drawn and `label` becomes the hint a
  long press reveals — the web's icon-plus-`aria-label` idiom, which is also what
  a desktop browser shows on hover.

      button(:undo, "Undo", icon: "↺")
      # is <MishkaToolbarButton id={:undo} label="Undo" icon="↺" />
  """
  @spec button(term(), String.t(), keyword()) :: map()
  def button(id, label, opts \\ []) do
    %{
      type: @button,
      props: %{
        id: id,
        label: label,
        icon: Keyword.get(opts, :icon),
        disabled: Keyword.get(opts, :disabled, false),
        group: Keyword.get(opts, :group)
      },
      children: []
    }
  end

  @doc """
  A destination — the builder behind `<MishkaToolbarLink>`. Drawn in `link_color`
  with a rule under it, so it does not read as a button — the colour alone would
  not say so.

  Options: `:href`, `:icon`, `:disabled`, `:group`.

  The tap reports the item's id like every other item, so one handler serves the
  whole bar; `href/2` turns that id back into the destination.

      link(:docs, "Docs", href: "https://mishka.tools/chelekom")
      # is <MishkaToolbarLink id={:docs} label="Docs" href="https://mishka.tools/chelekom" />
  """
  @spec link(term(), String.t(), keyword()) :: map()
  def link(id, label, opts \\ []) do
    %{
      type: @link,
      props: %{
        id: id,
        label: label,
        href: Keyword.get(opts, :href),
        icon: Keyword.get(opts, :icon),
        disabled: Keyword.get(opts, :disabled, false),
        group: Keyword.get(opts, :group)
      },
      children: []
    }
  end

  @doc """
  A text field in the bar — a find box, a font size, a URL. The builder behind
  `<MishkaToolbarInput>`.

  Options: `:placeholder`, `:value`, `:width`, `:label`, `:disabled`, `:group`.

  Edits arrive as `{:change, {on_input_tag, item_id}, value}`. The value stays
  the caller's, as everywhere else in this library: echo it back, or the field
  goes on showing what the BEAM already discarded.

      input(:find, placeholder: "Find…", value: query)
      # is <MishkaToolbarInput id={:find} placeholder="Find…" value={@query} />

  An input is the one item with no hint: a text field consumes its own long
  press to place a selection, so `on_hold` would never fire on it. Its
  `:placeholder` is already the visible label the hint exists to supply.
  """
  @spec input(term(), keyword()) :: map()
  def input(id, opts \\ []) do
    %{
      type: @input,
      props: %{
        id: id,
        label: Keyword.get(opts, :label),
        placeholder: Keyword.get(opts, :placeholder),
        value: Keyword.get(opts, :value, ""),
        width: Keyword.get(opts, :width),
        disabled: Keyword.get(opts, :disabled, false),
        group: Keyword.get(opts, :group)
      },
      children: []
    }
  end

  @doc """
  A divider between groups — the builder behind `<MishkaToolbarSeparator>`.
  Orients itself to the toolbar.

  Takes `:group` like any other item, so a separator can sit *inside* a group
  rather than only between two of them — which is what the web's chunking does
  when a separator carries the same `group` as its neighbours.
  """
  @spec separator(keyword()) :: map()
  def separator(opts \\ []) do
    %{type: @sep, props: %{group: Keyword.get(opts, :group)}, children: []}
  end

  @doc """
  Every node type a toolbar consumes as an item. Exported so a test can prove
  none of them leaked to the renderer.
  """
  @spec slot_types() :: [atom()]
  def slot_types, do: @slot_types

  @doc """
  The `href` of the link item with this id, or `nil`.

  A link reports its **id** like every other item, so one `on_select` clause
  serves the whole bar; this is how that id becomes a destination again. Opening
  it is the screen's business — `Mob.Device.open_url/1`, or
  `Mob.Socket.push_screen/3` for an internal one — because a node tree is a
  description, not an effect.

      iex> alias MishkaMob.Components.MishkaToolbar
      iex> items = [MishkaToolbar.link(:docs, "Docs", href: "https://mishka.tools")]
      iex> MishkaToolbar.href(items, :docs)
      "https://mishka.tools"

      iex> alias MishkaMob.Components.MishkaToolbar
      iex> MishkaToolbar.href([MishkaToolbar.button(:bold, "B")], :bold)
      nil
  """
  @spec href([map()], term()) :: String.t() | nil
  def href(items, id) do
    Enum.find_value(List.wrap(items), fn
      %{type: @link, props: %{id: ^id} = props} -> Map.get(props, :href)
      _other -> nil
    end)
  end

  @doc """
  The test tag on an item, given the toolbar's `id`.

  A disabled item differs from a live one by its ink and by carrying no handler,
  and a device test can read neither — so `disabled` goes into the tag. Returns
  `nil` when the toolbar has no `id`, which is how an untagged toolbar stays
  untagged.

      iex> MishkaMob.Components.MishkaToolbar.item_tag("fmt", :bold, false)
      "fmt-bold"

      iex> MishkaMob.Components.MishkaToolbar.item_tag("fmt", :bold, true)
      "fmt-bold-disabled"

      iex> MishkaMob.Components.MishkaToolbar.item_tag(nil, :bold, false)
      nil
  """
  @spec item_tag(String.t() | nil, term(), boolean()) :: String.t() | nil
  def item_tag(nil, _item_id, _disabled?), do: nil
  def item_tag(id, item_id, true), do: "#{id}-#{item_id}-disabled"
  def item_tag(id, item_id, _live), do: "#{id}-#{item_id}"

  @doc """
  The test tag on a labelled group.

  A group's label is its `aria-label` on the web — invisible to sighted users,
  and unavailable here since Mob exposes no accessible name. The tag is the one
  place it survives.

      iex> MishkaMob.Components.MishkaToolbar.group_tag("fmt", "Text align")
      "fmt-group-text-align"

      iex> MishkaMob.Components.MishkaToolbar.group_tag("fmt", nil)
      nil
  """
  @spec group_tag(String.t() | nil, String.t() | nil) :: String.t() | nil
  def group_tag(nil, _label), do: nil
  def group_tag(_id, nil), do: nil
  def group_tag(id, label), do: "#{id}-group-#{slug(label)}"

  @doc """
  The test tag on the `⋯`.

      iex> MishkaMob.Components.MishkaToolbar.overflow_tag("fmt")
      "fmt-overflow"
  """
  @spec overflow_tag(String.t() | nil) :: String.t() | nil
  def overflow_tag(id), do: suffix(id, "overflow")

  @doc """
  The test tag on the hint caption.

      iex> MishkaMob.Components.MishkaToolbar.hint_tag("fmt")
      "fmt-hint"
  """
  @spec hint_tag(String.t() | nil) :: String.t() | nil
  def hint_tag(id), do: suffix(id, "hint")

  @doc """
  The scroller's tag under `overflow: :scroll`. It also registers the native
  scroll view under that name, so `Mob.Test.scroll_to/3` can move the strip
  without a finger.

      iex> MishkaMob.Components.MishkaToolbar.scroll_tag("fmt")
      "fmt-scroll"
  """
  @spec scroll_tag(String.t() | nil) :: String.t() | nil
  def scroll_tag(id), do: suffix(id, "scroll")

  @doc """
  Split items into `{shown, hidden}` for `overflow: :collapse`.

  `visible` counts **controls**, not children: a separator rides along with the
  items it divides rather than spending a slot, and a chunk that would end on a
  separator drops it, because a strip should not end in a divider. At least one
  control always survives — a bar of nothing but a `⋯` says less than a bar with
  one button and a bigger overflow.

      iex> alias MishkaMob.Components.MishkaToolbar
      iex> items = [MishkaToolbar.button(:a, "A"), MishkaToolbar.button(:b, "B")]
      iex> {shown, hidden} = MishkaToolbar.split(items, 1)
      iex> {length(shown), length(hidden)}
      {1, 1}

      iex> alias MishkaMob.Components.MishkaToolbar
      iex> items = [MishkaToolbar.button(:a, "A"), MishkaToolbar.separator()]
      iex> {shown, hidden} = MishkaToolbar.split(items, 3)
      iex> {length(shown), hidden}
      {1, []}
  """
  @spec split([map()], integer()) :: {[map()], [map()]}
  def split(items, visible) do
    keep = max(visible, 1)

    {shown, hidden, _count} =
      items
      |> List.wrap()
      |> Enum.reduce({[], [], 0}, fn item, {shown, hidden, count} ->
        cond do
          hidden != [] -> {shown, [item | hidden], count}
          separator?(item) -> {[item | shown], hidden, count}
          count < keep -> {[item | shown], hidden, count + 1}
          true -> {shown, [item], count}
        end
      end)

    {shown |> Enum.reverse() |> trim_trailing_separators(), Enum.reverse(hidden)}
  end

  @doc """
  The toolbar node. `children` are the items, already built — `expand/3` is what
  turns the slot tags into these.

      <MishkaToolbar id="fmt" on_select={:act} on_hold={:hint} hint={@hint}>
        <MishkaToolbarButton id={:bold} label="Bold" icon="B" />
        <MishkaToolbarButton id={:italic} label="Italic" icon="I" />
        <MishkaToolbarSeparator />
        <MishkaToolbarInput id={:find} placeholder="Find…" value={@query} />
      </MishkaToolbar>

      def handle_info({:tap, {:act, id}}, socket), do: {:noreply, act(socket, id)}
      def handle_info({:tap, {:hint, id}}, socket), do: {:noreply, assign(socket, :hint, id)}
  """
  @spec toolbar(map() | keyword(), [map()]) :: map()
  def toolbar(props \\ %{}, children \\ []) do
    props = Map.new(props)
    items = List.wrap(children)
    overflow = Map.get(props, :overflow, :none)

    {shown, hidden} =
      if overflow == :collapse do
        split(items, Map.get(props, :visible, 3))
      else
        {items, []}
      end

    ctx = context(props, overflow)

    nodes =
      shown
      |> chunk_groups()
      |> Enum.flat_map(&group_nodes(&1, ctx))
      |> Kernel.++(overflow_nodes(hidden, ctx))
      |> Enum.intersperse(gap(Map.get(props, :space, 8)))

    strip = if ctx.vertical?, do: column(nodes), else: row(nodes)

    body =
      case hint(shown, ctx) do
        nil -> scroller(strip, ctx)
        caption -> column([scroller(strip, ctx), gap(6), caption])
      end

    ~MOB"""
    <Box
      background={Map.get(props, :background, :surface_raised)}
      corner_radius={Map.get(props, :corner_radius, :radius_md)}
      padding={Map.get(props, :padding, :space_sm)}
      fill_width={ctx.vertical? == false}
    >
      {body}
    </Box>
    """
    |> put(:height, Map.get(props, :height))
    |> put(:id, Map.get(props, :id))
  end

  # Everything an item needs, resolved once. The alternative was threading six
  # arguments through four render clauses.
  defp context(props, overflow) do
    vertical? = Map.get(props, :orientation, :horizontal) == :vertical

    %{
      props: props,
      id: Map.get(props, :id),
      vertical?: vertical?,
      overflow: overflow,
      disabled?: truthy?(Map.get(props, :disabled, false)),
      focusable?: truthy?(Map.get(props, :focusable_when_disabled, true)),
      # A weight divides a bounded main axis. Under :scroll there is no bound to
      # divide, and in a Column the main axis is height, which an input must not
      # be allowed to eat.
      weighted?: vertical? == false and overflow != :scroll
    }
  end

  # Chunk consecutive items sharing a `:group`, exactly as the web does — an
  # ungrouped run comes back with a nil label and renders bare.
  defp chunk_groups(items) do
    items
    |> Enum.chunk_by(&group_of/1)
    |> Enum.map(fn [first | _rest] = chunk -> %{label: group_of(first), items: chunk} end)
  end

  defp group_of(%{props: props}) when is_map(props), do: Map.get(props, :group)
  defp group_of(_node), do: nil

  defp group_nodes(%{label: nil, items: items}, ctx), do: Enum.map(items, &item(&1, ctx))

  defp group_nodes(%{label: label, items: items}, ctx) do
    inner =
      items
      |> Enum.map(&item(&1, ctx))
      |> Enum.intersperse(gap(Map.get(ctx.props, :space, 8)))

    lane = if ctx.vertical?, do: column(inner), else: row(inner)

    # fill_width={false} is load-bearing: a Box given neither a width nor the
    # prop FILLS its parent, so the first group swallowed the strip and every
    # item after it went off the edge.
    node = ~MOB"""
    <Box
      fill_width={false}
      background={Map.get(ctx.props, :group_background, :surface)}
      corner_radius={:radius_sm}
      padding={2}
    >
      {lane}
    </Box>
    """

    [put(node, :id, group_tag(ctx.id, label))]
  end

  defp item(%{type: @sep}, ctx), do: divider(ctx.vertical?)

  defp item(%{type: @button, props: item}, ctx) do
    disabled? = disabled?(item, ctx)
    ink = if disabled?, do: :muted, else: Map.get(ctx.props, :item_color, :on_surface)

    face(item, ink, ctx, disabled?, false)
  end

  defp item(%{type: @link, props: item}, ctx) do
    disabled? = disabled?(item, ctx)
    ink = if disabled?, do: :muted, else: Map.get(ctx.props, :link_color, :primary)

    face(item, ink, ctx, disabled?, true)
  end

  defp item(%{type: @input, props: item}, ctx) do
    disabled? = disabled?(item, ctx)
    width = Map.get(item, :width)

    # The tag goes on the FIELD, not on the box around it — a device test drives
    # an input by typing into it, and only the text_field node accepts text.
    field =
      ~MOB"""
      <TextField
        value={Map.get(item, :value, "")}
        placeholder={Map.get(item, :placeholder)}
        fill_width={true}
        background={:transparent}
        underline={false}
        enabled={not disabled?}
        return_key="done"
      />
      """
      |> put(:id, item_tag(ctx.id, Map.get(item, :id), disabled?))
      |> put(:on_change, change(ctx, Map.get(item, :id), disabled?))

    node = ~MOB"""
    <Box background={:surface} corner_radius={:radius_sm} padding={4}>
      {field}
    </Box>
    """

    # Exactly one of weight / width, never neither — a Box with neither fills its
    # parent, which is how a find box once became the whole toolbar.
    if ctx.weighted? and is_nil(width) do
      put(node, :weight, 1)
    else
      put(node, :width, width || @default_input_width)
    end
  end

  # Anything that is not one of our items is a control the caller built — a
  # Toggle, an ActionIcon — and passes through untouched.
  defp item(node, _ctx), do: node

  # Button and link differ only in their ink and in the rule under the text, so
  # they share a face. `max_lines: 1` because a Text squeezed narrower than its
  # content wraps CHARACTER BY CHARACTER rather than clipping.
  defp face(item, ink, ctx, disabled?, rule?) do
    text = Map.get(item, :icon) || Map.get(item, :label)

    caption = ~MOB"""
    <Text text={text} text_size={:base} text_color={ink} max_lines={1} />
    """

    # The rule is a Box with `fill_width` inside a hugging Column, so it is
    # exactly as wide as the text above it — the trick MishkaAnchor uses, and
    # the only way to underline anything in Mob.
    label =
      if rule? do
        ~MOB"""
        <Column>
          {caption}
          <Box fill_width={true} height={1} background={ink} />
        </Column>
        """
      else
        caption
      end

    ~MOB"""
    <Box fill_width={false} corner_radius={:radius_sm} padding={:space_sm} align={:center}>
      {label}
    </Box>
    """
    |> put(:id, item_tag(ctx.id, Map.get(item, :id), disabled?))
    |> put(:on_tap, select(ctx, Map.get(item, :id), disabled?))
    |> put(:on_long_press, hold(ctx, Map.get(item, :id), disabled?))
  end

  # A separator in a horizontal toolbar is a vertical hairline, and vice versa —
  # the axis is the toolbar's, not the caller's to remember.
  defp divider(true) do
    ~MOB"""
    <Box fill_width={true} height={1} background={:border} />
    """
  end

  defp divider(_horizontal) do
    height = @hairline

    ~MOB"""
    <Box width={1} height={height} background={:border} />
    """
  end

  defp overflow_nodes([], _ctx), do: []

  defp overflow_nodes(_hidden, ctx) do
    node = ~MOB"""
    <Box fill_width={false} corner_radius={:radius_sm} padding={:space_sm} align={:center}>
      <Text text="⋯" text_size={:base} text_color={:on_surface} max_lines={1} />
    </Box>
    """

    [
      node
      |> put(:id, overflow_tag(ctx.id))
      |> put(:on_tap, Event.handler(Map.get(ctx.props, :on_overflow)))
    ]
  end

  # The hint sits OUTSIDE the scroller, so the label of the item being held does
  # not slide away with the strip. The tag goes on the Text itself rather than on
  # a Row around it, so a device test can read this caption from its own node
  # instead of asking the whole page whether a string is somewhere on it.
  defp hint(items, ctx) do
    with id when not is_nil(id) <- Map.get(ctx.props, :hint),
         %{props: props} <- find_item(items, id),
         label when is_binary(label) <- Map.get(props, :label) do
      node = ~MOB"""
      <Text text={label} text_size={:xs} text_color={:muted} max_lines={1} />
      """

      put(node, :id, hint_tag(ctx.id))
    else
      _no_label -> nil
    end
  end

  defp find_item(items, id) do
    Enum.find(items, fn
      %{type: type, props: props} when type in @slot_types -> Map.get(props, :id) == id
      _other -> false
    end)
  end

  # The Scroll must FILL its axis, or there is nothing to scroll.
  #
  # Without it the scroller measures to its CONTENT — so the viewport and the
  # content are the same size, the strip cannot move, and the overflow is simply
  # clipped by the Box outside it. The controls past the edge stayed composed
  # and tagged, so a test could find them; they were merely unreachable, by
  # finger or by scroll_to. This is the mirror of the tab strip's rule, where
  # the inner Row must NOT fill for the same reason.
  defp scroller(strip, %{overflow: :scroll} = ctx) do
    axis = if ctx.vertical?, do: nil, else: "horizontal"

    ~MOB"""
    <Scroll>
      {strip}
    </Scroll>
    """
    |> put(:axis, axis)
    |> put(:id, scroll_tag(ctx.id))
    |> put(if(ctx.vertical?, do: :fill_height, else: :fill_width), true)
  end

  defp scroller(strip, _ctx), do: strip

  defp suffix(nil, _part), do: nil
  defp suffix(id, part), do: id <> "-" <> part

  defp disabled?(item, ctx), do: ctx.disabled? or truthy?(Map.get(item, :disabled, false))

  defp select(_ctx, _item_id, true), do: nil
  defp select(ctx, item_id, _live), do: Event.handler(Map.get(ctx.props, :on_select), item_id)

  # A disabled item still answers a long press. That is `focusable_when_disabled`:
  # on the web it keeps a disabled item in the roving order so it stays
  # discoverable, and here "discoverable" means you can still hold it and read
  # what it is, even though tapping does nothing.
  defp hold(ctx, item_id, disabled?) do
    if disabled? and not ctx.focusable? do
      nil
    else
      Event.handler(Map.get(ctx.props, :on_hold), item_id)
    end
  end

  defp change(_ctx, _item_id, true), do: nil
  defp change(ctx, item_id, _live), do: Event.handler(Map.get(ctx.props, :on_input), item_id)

  defp separator?(%{type: @sep}), do: true
  defp separator?(_node), do: false

  defp trim_trailing_separators(items) do
    items |> Enum.reverse() |> Enum.drop_while(&separator?/1) |> Enum.reverse()
  end

  defp slug(label) do
    label
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  defp gap(size), do: ~MOB(<Spacer size={size} />)

  defp row(items), do: ~MOB(<Row align={:center}>
  {items}
</Row>)

  defp column(items), do: ~MOB(<Column>
  {items}
</Column>)

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_value), do: true
end
