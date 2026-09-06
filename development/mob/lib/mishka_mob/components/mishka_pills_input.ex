defmodule MishkaMob.Components.MishkaPillsInput do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Pills Input** — a bordered
  control holding arbitrary pills beside a text field.

  ## Pills Input or Tags Input?

  `MishkaMob.Components.MishkaTagsInput` owns its tokens: you hand it strings
  and it renders them as pills with ✕ buttons. A pills input owns **nothing** —
  the caller supplies the pill nodes, which may be
  `MishkaMob.Components.MishkaPill`s, avatars, colour swatches or anything else.

  That is the whole difference, and it is why both exist: use Tags Input for a
  list of strings, and this when the tokens are richer than that (a recipient
  picker showing avatars, say). The web component draws the same distinction with
  its `:pills` slot.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `draft` | string | `""` | The text field's value. |
  | `placeholder` | string | `nil` | Draft placeholder. |
  | `disabled` | boolean | `false` | Mutes and unwires. |
  | `on_draft` | event tag (atom) | — | `{:change, tag, text}` as the draft is typed. |
  | `on_add` | event tag (atom) | — | Fired on return. Carries NO text — commit your own draft. |
  | `on_press` | event tag (atom) | — | `{:tap, tag}` on EVERY tap of the draft. |
  | `on_focus` / `on_blur` | event tags | — | The draft gained or lost focus. |
  | `space` | number | `6` | Gap between pills. |
  | `wrap_chars` | number | `34` | Characters per pill row. |
  | `per_row` | number | `nil` | A fixed count instead, when the pills are uniform. |
  | `id` | string | `nil` | Test tag on the draft field. |

  Children are the pills.

  ## Pair it with a suggestion list

  A pills input owns no list, but a picker usually wants one: `on_focus` tells
  the screen to open it, `on_draft` filters it, and each row's tap adds a pill —
  or removes it, if that one is already picked. The Autocomplete page shows the
  whole pattern, and the toggle-on-second-tap is what keeps a picker from
  collecting the same recipient twice.

  ## How the rows are packed

  Mob has no flow layout, and a `Row` runs off the edge rather than onto a second
  line — silently, since nothing clips or complains. Nor is any geometry reported
  back to `render/1`, so the packing is an estimate.

  It used to be a fixed count of three, which is wrong the moment the pills are
  not all short: "Ada Lovelace", "Grace Hopper" and "Katherine Johnson" were
  packed onto one row and the last was squeezed to a sliver. Pills are now packed
  against `wrap_chars`, the same measured budget the tags input uses, costing
  each pill by the **text inside it** — all this component can know, since the
  pills are the caller's own nodes.

  A pill with no text at all (an avatar, a colour swatch) is costed at a flat
  allowance: something has to be assumed, and assuming "free" packs an unbounded
  number onto one row. When the pills ARE uniform, `per_row` still takes over and
  chunks by count, which is exactly right for that case.

  Not ported: `id` / `input_name` (form plumbing) and the `*_class` attrs.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaPillsInput>`). Children are the pills."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: pills_input(props, children)

  @doc """
  The pills-input node.

      <MishkaPillsInput
        draft={@draft}
        on_draft={:typed}
        on_add={:commit}
      >{recipient_pills()}</MishkaPillsInput>
  """
  @spec pills_input(map() | keyword(), [map()]) :: map()
  def pills_input(props \\ %{}, pills \\ []) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))

    ~MOB"""
    <Box
      fill_width={true}
      background={:surface}
      corner_radius={:radius_md}
      padding={:space_sm}
      border_color={:border}
      border_width={1}
    >
      <Column fill_width={true}>
        <Column fill_width={true} :if={pills != []}>
          {rows(pills, props)}
          <Spacer size={8} />
        </Column>
        {draft(props, disabled?)}
      </Column>
    </Box>
    """
  end

  # One Row per chunk, stacked. A single Row would run off the edge as soon as
  # the pills outgrew the width — silently, since nothing clips or complains.
  #
  # Chunking by a fixed COUNT was the bug: three short pills fit a row and three
  # long ones do not, so "Ada Lovelace / Grace Hopper / Katherine Johnson" packed
  # all three and squeezed the last into a sliver. The budget is the same
  # measured one the tags input uses, and each pill's cost is estimated from the
  # text inside it — which is all this component can know, since the pills are
  # the caller's nodes and may be avatars or swatches with no text at all.
  defp rows(pills, props) do
    space = Map.get(props, :space) || 6
    gap = ~MOB(<Spacer size={space} />)

    lines =
      pills
      |> chunk(props)
      |> Enum.map(fn chunk ->
        spaced = Enum.intersperse(chunk, gap)

        ~MOB"""
        <Column fill_width={true}>
          <Row>
            {spaced}
          </Row>
          <Spacer size={space} />
        </Column>
        """
      end)

    ~MOB(<Column fill_width={true}>
  {lines}
</Column>)
  end

  # `per_row` still wins when a caller sets it — a fixed count is right when the
  # pills are uniform, an avatar row say. Left unset, the width estimate decides.
  defp chunk(pills, props) do
    case Map.get(props, :per_row) do
      nil -> pack(pills, Map.get(props, :wrap_chars) || 34)
      n -> Enum.chunk_every(pills, max(n, 1))
    end
  end

  @doc """
  Pack pills into rows against a character `budget`, costing each by the text it
  contains.

  A pill with no text at all — an avatar, a colour swatch — is costed as
  `@textless_cost`, because something has to be assumed and assuming "free"
  packs an unbounded number onto one row.

      iex> alias MishkaMob.Components.MishkaPillsInput, as: P
      ...> pill = fn label -> %{type: :text, props: %{text: label}, children: []} end
      ...> P.pack([pill.("Ada Lovelace"), pill.("Grace Hopper")], 34) |> length()
      1

      iex> alias MishkaMob.Components.MishkaPillsInput, as: P
      ...> pill = fn label -> %{type: :text, props: %{text: label}, children: []} end
      ...> P.pack([pill.("Ada Lovelace"), pill.("Grace Hopper"), pill.("Katherine Johnson")], 34)
      ...> |> length()
      2
  """
  @spec pack([map()], pos_integer()) :: [[map()]]
  def pack(pills, budget) do
    pills
    |> Enum.reduce([], fn pill, rows ->
      cost = cost(pill)

      case rows do
        [{row, used} | rest] when used + cost <= budget -> [{[pill | row], used + cost} | rest]
        rows -> [{[pill], cost} | rows]
      end
    end)
    |> Enum.reverse()
    |> Enum.map(fn {row, _used} -> Enum.reverse(row) end)
  end

  # Same allowance per pill as the tags input: its text plus 5 for padding, the
  # ✕ and the gap to the next one.
  @textless_cost 10

  defp cost(pill) do
    case text_of(pill) do
      "" -> @textless_cost
      text -> String.length(text) + 5
    end
  end

  defp text_of(%{props: props, children: children}) do
    own = Map.get(props, :text)
    rest = children |> List.wrap() |> Enum.map_join(&text_of/1)

    if is_binary(own), do: own <> rest, else: rest
  end

  defp text_of(_node), do: ""

  # The draft draws NO box of its own: the control around it is the box, and a
  # Material text field with no border draws its indicator line instead — a
  # stray rule across the middle of the control. `enabled` is what actually
  # disables it, too; withholding the handler stops the BEAM hearing about edits
  # but leaves the field focusable and editable, so it looks live and silently
  # goes nowhere.
  defp draft(props, disabled?) do
    node = ~MOB"""
    <TextField
      value={Map.get(props, :draft) || ""}
      placeholder={Map.get(props, :placeholder) || ""}
      return_key="done"
      fill_width={true}
      background={:transparent}
      enabled={not disabled?}
      underline={false}
    />
    """

    node
    |> tag(Map.get(props, :id))
    |> put(:on_change, handler(props, :on_draft, disabled?))
    |> put(:on_submit, handler(props, :on_add, disabled?))
    |> put(:on_tap, handler(props, :on_press, disabled?))
    |> put(:on_focus, handler(props, :on_focus, disabled?))
    |> put(:on_blur, handler(props, :on_blur, disabled?))
  end

  defp tag(node, nil), do: node
  defp tag(node, id), do: %{node | props: Map.put(node.props, :id, "#{id}-draft")}

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp handler(_props, _key, true), do: nil
  defp handler(props, key, _), do: Event.handler(Map.get(props, key))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
