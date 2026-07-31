defmodule MishkaMob.Components.MishkaTagsInput do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Tags Input** — a bordered
  control holding removable tokens with a draft field beneath them.

  Composes `MishkaMob.Components.MishkaPill` for the tokens (each with its own
  ✕) and Mob's native `TextField` for the draft.

  ## Return commits the draft — and carries no text

  There is no keydown to hook on a phone, but `TextField` reports `on_submit`
  when the return key is pressed, and `return_key: "done"` labels it.

  Verified against the bridge: `nativeSendSubmit(handle)` takes **only the
  handle**, unlike `nativeSendChangeStr(handle, value)`. A submit event is
  therefore a bare notification with no payload, so the screen commits the draft
  it is already holding from `on_change` rather than reading text off the event.
  The reducers are `add/3` and `remove/2`.

  ## `add/3` is stricter than it looks

  Blank input is ignored, surrounding whitespace is trimmed, and a duplicate is
  rejected rather than appended — a tags input that lets you add "elixir" twice
  is a bug the caller then has to fix everywhere. `allow_duplicates: true` opts
  back in.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `tags` | list of strings | `[]` | The current tokens. |
  | `draft` | string | `""` | The text field's value. |
  | `placeholder` | string | `nil` | Draft placeholder. |
  | `disabled` | boolean | `false` | Mutes and unwires everything. |
  | `on_draft` | event tag (atom) | — | `{:change, tag, text}` as the draft is typed. |
  | `on_add` | event tag (atom) | — | Fired on return. Carries NO text — commit your own draft. |
  | `on_remove` | event tag (atom) | — | `{:tap, {tag, tag_string}}` from a token's ✕. |
  | `background` / `border_color` / `border_width` / `corner_radius` / `padding` | | | The control. |
  | `space` | number | `6` | Gap between tokens. |
  | `wrap_chars` | number | `40` | Roughly how much text fits on one token row. |
  | `id` | string | `nil` | Tags the draft field and each token's ✕. |

  ## It ships no look of its own worth keeping

  The headless original ships no colours and no spacing. There is no stylesheet
  here, so the container's decoration is a set of props with legible defaults —
  pass your own, or `border_width: 0` for no box at all.

  The draft field inside draws **no** box: `underline: false`, because a
  Material text field otherwise draws its indicator line *inside* the control,
  which reads as a stray border across the middle of the box.

  ## Tokens wrap by estimate, because nothing here can measure text

  Neither renderer has a flow layout, and there is no text measurement on this
  side of the bridge, so a single `Row` of tokens simply runs off the edge once
  you have a few. Tags are packed greedily into rows using `wrap_chars` as a
  character budget — an estimate, calibrated against a real phone: a card's
  usable width is about 349dp, a character at `:base` is about 8.5dp, and a
  token's padding plus its ✕ costs about 36dp. That is roughly 40 characters a
  row, counting each token as its length plus 4. It was 28, which broke "United
  Kingdom" onto a line of its own with half the row empty beside it. Raise it
  for a wider control, lower it for a narrow one.

  Not ported: `name` / `input_name` (form plumbing) and the `*_class` attrs.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Event, MishkaPill}

  @doc "Composite expander (`<MishkaTagsInput />`)."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: tags_input(props)

  @doc """
  Add `draft` to `tags`.

  Trims, ignores blanks, and refuses duplicates unless `allow_duplicates: true`.

      iex> MishkaMob.Components.MishkaTagsInput.add(["a"], "b")
      ["a", "b"]
      iex> MishkaMob.Components.MishkaTagsInput.add(["a"], "  a  ")
      ["a"]
      iex> MishkaMob.Components.MishkaTagsInput.add(["a"], "   ")
      ["a"]
      iex> MishkaMob.Components.MishkaTagsInput.add(["a"], "a", allow_duplicates: true)
      ["a", "a"]
  """
  @spec add([String.t()], String.t() | nil, keyword()) :: [String.t()]
  def add(tags, draft, opts \\ []) do
    value = String.trim(draft || "")

    cond do
      value == "" -> tags
      value in tags and not Keyword.get(opts, :allow_duplicates, false) -> tags
      true -> tags ++ [value]
    end
  end

  @doc """
  Remove a tag.

      iex> MishkaMob.Components.MishkaTagsInput.remove(["a", "b"], "a")
      ["b"]
  """
  @spec remove([String.t()], String.t()) :: [String.t()]
  def remove(tags, tag), do: List.delete(tags, tag)

  @doc "The tags-input node."
  @spec tags_input(map() | keyword()) :: map()
  def tags_input(props \\ %{}) do
    props = Map.new(props)
    tags = props |> Map.get(:tags, []) |> List.wrap()
    disabled? = truthy?(Map.get(props, :disabled, false))

    ~MOB"""
    <Box
      fill_width={true}
      background={Map.get(props, :background, :surface)}
      corner_radius={Map.get(props, :corner_radius, :radius_md)}
      padding={Map.get(props, :padding, :space_sm)}
      border_color={Map.get(props, :border_color, :border)}
      border_width={Map.get(props, :border_width, 1)}
    >
      <Column fill_width={true}>
        {tokens(tags, props, disabled?)}
        {draft(props, disabled?)}
      </Column>
    </Box>
    """
  end

  @doc """
  Pack tags into rows that will roughly fit, using `budget` characters a row.

  Neither renderer has a flow layout and nothing here can measure text, so this
  is an estimate rather than a measurement: each tag costs its own length plus a
  fixed allowance for its padding and ✕. A tag longer than the whole budget gets
  a row to itself rather than being dropped.

      iex> MishkaMob.Components.MishkaTagsInput.wrap(["a", "b"], 28)
      [["a", "b"]]
      iex> MishkaMob.Components.MishkaTagsInput.wrap(["aaaaaaaa", "bbbbbbbb", "cccccccc"], 20)
      [["aaaaaaaa"], ["bbbbbbbb"], ["cccccccc"]]
      iex> MishkaMob.Components.MishkaTagsInput.wrap([], 28)
      []
  """
  @spec wrap([String.t()], pos_integer()) :: [[String.t()]]
  def wrap(tags, budget) do
    tags
    |> Enum.reduce([], fn tag, rows ->
      cost = String.length(tag) + 4

      case rows do
        [{row, used} | rest] when used + cost <= budget -> [{[tag | row], used + cost} | rest]
        rows -> [{[tag], cost} | rows]
      end
    end)
    |> Enum.reverse()
    |> Enum.map(fn {row, _used} -> Enum.reverse(row) end)
  end

  defp tokens([], _props, _disabled?), do: ~MOB(<Column />)

  defp tokens(tags, props, disabled?) do
    space = Map.get(props, :space, 6)
    budget = Map.get(props, :wrap_chars, 40)

    rows =
      tags
      |> wrap(budget)
      |> Enum.map(fn row ->
        pills =
          row
          |> Enum.map(&token(&1, props, disabled?))
          |> Enum.intersperse(~MOB(<Spacer size={space} />))

        ~MOB"""
        <Row fill_width={true}>
          {pills}
        </Row>
        """
      end)
      |> Enum.intersperse(~MOB(<Spacer size={space} />))

    ~MOB"""
    <Column fill_width={true}>
      {rows}
      <Spacer size={8} />
    </Column>
    """
  end

  defp token(tag, props, disabled?) do
    node =
      MishkaPill.pill(
        label: tag,
        with_remove: true,
        disabled: disabled?,
        on_remove: remove_tag(props, tag)
      )

    # Every token's ✕ reads the same glyph, so an exact-text lookup cannot say
    # WHICH tag it would remove. The tag itself makes the id unique.
    tag_node(node, Map.get(props, :id), tag)
  end

  defp tag_node(node, nil, _tag), do: node

  defp tag_node(node, id, tag),
    do: %{node | props: Map.put(node.props, :id, "#{id}-tag-#{tag}")}

  defp draft(props, disabled?) do
    node = ~MOB"""
    <TextField
      value={Map.get(props, :draft, "")}
      placeholder={Map.get(props, :placeholder, "Add a tag…")}
      return_key="done"
      fill_width={true}
      background={:transparent}
      enabled={not disabled?}
      underline={false}
    />
    """

    node
    |> draft_tag(Map.get(props, :id))
    |> put(:on_change, handler(props, :on_draft, disabled?))
    |> put(:on_submit, handler(props, :on_add, disabled?))
  end

  defp draft_tag(node, nil), do: node
  defp draft_tag(node, id), do: %{node | props: Map.put(node.props, :id, "#{id}-draft")}

  defp remove_tag(props, tag) do
    case Event.handler(Map.get(props, :on_remove)) do
      nil -> nil
      {pid, name} -> {pid, {name, tag}}
    end
  end

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp handler(_props, _key, true), do: nil
  defp handler(props, key, _), do: Event.handler(Map.get(props, key))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
