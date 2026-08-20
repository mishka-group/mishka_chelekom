defmodule MishkaMob.Components.MishkaRadio do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Radio** — one option in a
  mutually exclusive set.

  Same row shape as `MishkaMob.Components.MishkaCheckbox`, with the one visual
  difference that carries the meaning: a **circle with a centre dot** rather than
  a square with a tick. That distinction is the whole convention for "pick one"
  versus "pick any", so it is drawn rather than left to colour.

  ## Exclusivity lives in the screen

  On the web a shared `name` makes the browser enforce that only one radio in a
  group is selected. There is no form and no browser here, so exclusivity is one
  line in the handler — assign the tapped id — and a radio is simply told whether
  it is `checked`. That is why `name` is not a prop: it would describe a
  behaviour this component does not perform.

  A group of these is `MishkaMob.Components.MishkaRadioGroup`'s job; a single
  radio stays a single radio.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | Text beside the dot. |
  | `checked` | boolean | `false` | Whether this option is selected. |
  | `disabled` | boolean | `false` | Wires no handler and mutes the row. |
  | `on_select` | event tag (atom) | — | Sent as `{:tap, tag}`. |
  | `color` | color token / ARGB int | `:primary` | Ring and dot when selected. |
  | `text_color` | color token / ARGB int | `:on_surface` | The label. |
  | `size` | number | `22` | Outer circle diameter. |
  | `fill_width` | boolean | `true` | Row spans its parent, so the label is tappable. |
  | `id` | string | `nil` | Test tag on the ring, suffixed with its state. |

  ## Why `id` carries the state

  A selected radio differs from an unselected one by a **dot**, and a dot is not
  text — so nothing in the accessibility tree says which option is chosen, and a
  device test cannot see the selection at all. The ring's tag therefore ends in
  `-selected` or `-empty`, the same trick `MishkaMob.Components.MishkaCheckbox`
  uses for its drawn mark. Tests look for the tag, not for a glyph.

  Not ported: `name`, `value`, `required` (form plumbing) and the `*_class`
  attrs. `readonly` collapses into `disabled` — both omit the handler.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaRadio />`). Delegates to `radio/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: radio(props)

  @doc """
  The radio node.

      radio(label: "Small", checked: @size == :s, on_select: {:size, :s})
  """
  @spec radio(map() | keyword()) :: map()
  def radio(props \\ %{}) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))
    checked? = truthy?(Map.get(props, :checked, false))
    label = Map.get(props, :label)
    label_color = if disabled?, do: :muted, else: Map.get(props, :text_color) || :on_surface

    # fill_width makes the whole row the tap target, which is the point of a
    # stacked radio. Side by side it is the opposite: the first option would
    # take the entire width and push the rest off-screen, so a horizontal group
    # passes false and each option hugs its label. Row honours the prop on BOTH
    # renderers — unlike Box, which reads it on Android only.
    # `nil` means "not given", not `false`: `Map.get/3` hands back its default
    # only when the key is ABSENT, so a keyword-built props map carrying an
    # unset key as an explicit nil used to read as a deliberate `false`.
    # Only a real `false` turns this off.
    fill? = Map.get(props, :fill_width) != false

    node = ~MOB"""
    <Row fill_width={fill?}>
      {indicator(props, checked?, disabled?)}
      <Spacer size={10} :if={is_binary(label)} />
      <Text text={label} text_size={:base} text_color={label_color} :if={is_binary(label)} />
    </Row>
    """

    case handler(props, disabled?) do
      nil -> node
      tap -> %{node | props: Map.put(node.props, :on_tap, tap)}
    end
  end

  # An exact size/2 radius keeps it a circle at any size — the same rule the
  # Avatar uses, and the reason a radius token is not good enough here.
  #
  # The dot is a FRACTION of the ring (size / 2.4), never a fixed pixel count:
  # a fixed dot is a blob in a small ring and a speck in a large one. The floor
  # of 6 is the smallest dot that still reads as a dot on a real screen.
  defp indicator(props, checked?, disabled?) do
    size = Map.get(props, :size) || 22
    accent = if disabled?, do: :muted, else: Map.get(props, :color) || :primary
    dot = max(round(size / 2.4), 6)

    ring = ~MOB"""
    <Box
      width={size}
      height={size}
      corner_radius={size / 2}
      background={:surface_raised}
      border_color={if(checked?, do: accent, else: :border)}
      border_width={if(checked?, do: 2, else: 1)}
      align={:center}
    >
      <Box width={dot} height={dot} corner_radius={dot / 2} background={accent} :if={checked?} />
    </Box>
    """

    tag_state(ring, Map.get(props, :id), checked?)
  end

  # A dot is not text, so the selection is invisible to the accessibility tree
  # and to a device test. Fold the state into the test tag instead.
  defp tag_state(node, nil, _checked?), do: node

  defp tag_state(node, id, checked?) do
    state = if checked?, do: "selected", else: "empty"
    %{node | props: Map.put(node.props, :id, "#{id}-#{state}")}
  end

  defp handler(_props, true), do: nil
  defp handler(props, _), do: Event.handler(Map.get(props, :on_select))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
