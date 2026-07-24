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

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | Button text. Children override it. |
  | `pressed` | boolean | `false` | Whether it reads as pushed in. |
  | `disabled` | boolean | `false` | Wires no handler and mutes it. |
  | `on_change` | event tag (atom) | — | Sent as `{:tap, tag}`. |
  | `color` | color token / ARGB int | `:primary` | Fill when pressed. |
  | `text_color` | color token / ARGB int | `:on_primary` | Label colour when pressed. |

  Not ported: `name`, `value`, `unchecked_value`, `form` (HTML form plumbing)
  and `id` / `*_class`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaToggle>`). Children override the label."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: toggle(props, children)

  @doc """
  The toggle node.

      toggle(label: "B", pressed: @bold?, on_change: :bold)
  """
  @spec toggle(map() | keyword(), [map()]) :: map()
  def toggle(props \\ %{}, content \\ []) do
    props = Map.new(props)
    pressed? = truthy?(Map.get(props, :pressed, false))
    disabled? = truthy?(Map.get(props, :disabled, false))

    node = ~MOB"""
    <Box
      background={background(props, pressed?, disabled?)}
      corner_radius={:radius_md}
      padding={:space_sm}
      border_color={:border}
      border_width={1}
    >
      {body(props, content, pressed?, disabled?)}
    </Box>
    """

    case handler(props, disabled?) do
      nil -> node
      tap -> %{node | props: Map.put(node.props, :on_tap, tap)}
    end
  end

  defp body(props, [], pressed?, disabled?) do
    ~MOB"""
    <Text
      text={Map.get(props, :label)}
      text_size={:base}
      text_color={text_color(props, pressed?, disabled?)}
    />
    """
  end

  defp body(_props, content, _pressed?, _disabled?), do: ~MOB(<Row>
  {content}
</Row>)

  defp background(props, pressed?, disabled?) do
    if pressed? and not disabled?, do: Map.get(props, :color, :primary), else: :surface_raised
  end

  defp text_color(props, pressed?, disabled?) do
    cond do
      disabled? -> :muted
      pressed? -> Map.get(props, :text_color, :on_primary)
      true -> :on_surface
    end
  end

  defp handler(_props, true), do: nil
  defp handler(props, _), do: Event.handler(Map.get(props, :on_change))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
