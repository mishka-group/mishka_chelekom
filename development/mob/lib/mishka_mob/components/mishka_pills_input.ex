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
  | `space` | number | `6` | Gap between pills. |

  Children are the pills.

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
    space = Map.get(props, :space, 6)

    spaced = Enum.intersperse(pills, ~MOB(<Spacer size={space} />))

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
          <Row fill_width={true}>
            {spaced}
          </Row>
          <Spacer size={8} />
        </Column>
        {draft(props, disabled?)}
      </Column>
    </Box>
    """
  end

  defp draft(props, disabled?) do
    node = ~MOB"""
    <TextField
      value={Map.get(props, :draft, "")}
      placeholder={Map.get(props, :placeholder, "")}
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

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp handler(_props, _key, true), do: nil
  defp handler(props, key, _), do: Event.handler(Map.get(props, key))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
