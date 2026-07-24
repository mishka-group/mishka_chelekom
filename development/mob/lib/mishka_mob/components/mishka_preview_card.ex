defmodule MishkaMob.Components.MishkaPreviewCard do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Preview Card** — the little
  card of detail about a thing: an avatar, a name, a line of context, sometimes
  an action.

  It is a `MishkaMob.Components.MishkaPopover` panel with a fixed inner layout,
  so it shares that component's surface and its limitation: Mob cannot anchor a
  floating card to a measured trigger, so the caller places it. `delay`,
  `close_delay` and the hover trigger are dropped — a phone has no hover.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `open` | boolean | `false` | Whether the card is shown. |
  | `title` | string | `nil` | The name. |
  | `subtitle` | string | `nil` | A line of context under it. |
  | `description` | string | `nil` | The body. |
  | `initials` | string | `nil` | Avatar initials. |
  | `image` | string | `nil` | Avatar image URL or path. |
  | `avatar_color` | color token / ARGB int | `:primary` | Avatar fill. |
  | plus everything `MishkaMob.Components.MishkaPopover` accepts | | | |

  Children become the card's footer, which is where actions belong.

  Not ported: `side`, `align`, offsets, `delay`, `close_delay`,
  `close_on_escape`, and `id` / `*_class`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{MishkaAvatar, MishkaPopover}

  @doc "Composite expander (`<MishkaPreviewCard>`). Children are the footer."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: preview_card(props, children)

  @doc """
  The preview-card node. Renders nothing when closed.

      {preview_card([open: @open?, title: "Shahryar", subtitle: "@shahryar",
                     initials: "SH"], [follow_button()])}
  """
  @spec preview_card(map() | keyword(), [map()]) :: map()
  def preview_card(props \\ %{}, footer \\ []) do
    props = Map.new(props)

    if truthy?(Map.get(props, :open, false)) do
      MishkaPopover.panel(props, [header(props), body(props), footer(footer)])
    else
      ~MOB(<Column />)
    end
  end

  defp header(props) do
    title = Map.get(props, :title)
    subtitle = Map.get(props, :subtitle)

    avatar =
      MishkaAvatar.avatar(
        initials: Map.get(props, :initials),
        src: Map.get(props, :image),
        size: 48,
        background: Map.get(props, :avatar_color, :primary),
        color: :on_primary
      )

    ~MOB"""
    <Row fill_width={true}>
      {avatar}
      <Spacer size={12} />
      <Column fill_width={true}>
        <Text text={title} text_size={:lg} text_color={:on_surface} :if={is_binary(title)} />
        <Spacer size={2} :if={is_binary(title) and is_binary(subtitle)} />
        <Text text={subtitle} text_size={:sm} text_color={:muted} :if={is_binary(subtitle)} />
      </Column>
    </Row>
    """
  end

  defp body(props) do
    description = Map.get(props, :description)

    ~MOB"""
    <Column fill_width={true} :if={is_binary(description)}>
      <Spacer size={12} />
      <Text text={description} text_size={:base} text_color={:on_surface} />
    </Column>
    """
  end

  defp footer([]), do: ~MOB(<Column />)

  defp footer(nodes) do
    ~MOB"""
    <Column fill_width={true}>
      <Spacer size={14} />
      <Row fill_width={true}>
        {nodes}
      </Row>
    </Column>
    """
  end

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
