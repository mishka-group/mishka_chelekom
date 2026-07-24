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

  Not ported: `name` / `input_name` (form plumbing) and `id` / `*_class`.
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
      background={:surface}
      corner_radius={:radius_md}
      padding={:space_sm}
      border_color={:border}
      border_width={1}
    >
      <Column fill_width={true}>
        {tokens(tags, props, disabled?)}
        {draft(props, disabled?)}
      </Column>
    </Box>
    """
  end

  defp tokens([], _props, _disabled?), do: ~MOB(<Column />)

  defp tokens(tags, props, disabled?) do
    pills =
      tags
      |> Enum.map(fn tag ->
        MishkaPill.pill(
          label: tag,
          with_remove: true,
          disabled: disabled?,
          on_remove: remove_tag(props, tag)
        )
      end)
      |> Enum.intersperse(~MOB(<Spacer size={6} />))

    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        {pills}
      </Row>
      <Spacer size={8} />
    </Column>
    """
  end

  defp draft(props, disabled?) do
    node = ~MOB"""
    <TextField
      value={Map.get(props, :draft, "")}
      placeholder={Map.get(props, :placeholder, "Add a tag…")}
      return_key="done"
      fill_width={true}
      background={:surface}
      padding={:space_sm}
    />
    """

    node
    |> put(:on_change, handler(props, :on_draft, disabled?))
    |> put(:on_submit, handler(props, :on_add, disabled?))
  end

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
