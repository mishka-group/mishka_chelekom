defmodule MishkaMob.Components.MishkaSeparator do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Separator** — a thematic rule
  between groups of content, optionally carrying a centred label.

  Written with the `~MOB` sigil, so the markup reads like a Phoenix component.

  ## Two ways to call it

  As a **function component** — the form our own screens use, because it stays
  inside `--warnings-as-errors` (see "Why not a custom tag" below):

      ~MOB\"""
      <Column>
        <MishkaSeparator />
        <MishkaSeparator label="or continue with" />
      </Column>
      \"""

  Or as a registered composite tag, for apps that don't compile with
  `--warnings-as-errors`:

      Mob.Composite.register(:mishka_separator, {#{inspect(__MODULE__)}, :expand})
      # <MishkaSeparator label="or" />

  ### The tag, and the warning behind it

  `~MOB` validates tags against Mob's whitelist (`priv/tags/*.txt` in the `mob`
  dep, baked in at Mob's compile time). A composite registers at *runtime*, which
  that check cannot see, so an unlisted tag emits
  `"<MishkaSeparator> is not in the Mob tag whitelist"` — harmless in itself, and
  fatal under `--warnings-as-errors`.

  `mix mishka.ui.gen.mob` adds the tags it generates to that list, so the tag
  form is the one to write. The function form remains for anything a tag cannot
  express — two child slots, mostly.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `orientation` | `:horizontal` `:vertical` | `:horizontal` | Rule axis. A vertical rule needs a parent that gives it height (a `Row`). |
  | `label` | string | `nil` | Renders line — label — line. Horizontal only. |
  | `color` | color token / ARGB int | `:border` | Rule colour. |
  | `thickness` | number | `1` | Rule thickness in dp/pt. |
  | `space` | number | `12` | Gap between the label and the lines. |

  `decorative` from the web component is **not** ported: it only flips
  `role="separator"` to `role="none"` for screen readers in the DOM, and Mob
  exposes no such role on a divider.

  ## Platform note

  The label variant flexes its two lines with `weight`, which Android's Compose
  layout implements and iOS's SwiftUI mapping does not (only a bare `Spacer()`
  fills there) — so on iOS the flanking lines take their intrinsic width until
  Mob grows `weight` support. The plain and vertical rules are portable.
  """

  import Mob.Sigil

  @doc """
  Composite expander (`<MishkaSeparator />`). Delegates to `separator/1`; a
  separator has no children.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: separator(props)

  @doc """
  The separator node. Accepts a map or keyword list of props.

      separator()
      separator(label: "or")
      separator(orientation: :vertical)
  """
  @spec separator(map() | keyword()) :: map()
  def separator(props \\ %{}) do
    props = Map.new(props)
    color = Map.get(props, :color, :border)
    thickness = Map.get(props, :thickness, 1)
    label = Map.get(props, :label)

    cond do
      Map.get(props, :orientation, :horizontal) == :vertical ->
        ~MOB(<Box width={thickness} fill_height={true} background={color} />)

      is_binary(label) and label != "" ->
        labelled(label, color, thickness, Map.get(props, :space, 12))

      true ->
        rule(color, thickness)
    end
  end

  defp rule(color, thickness), do: ~MOB(<Divider color={color} thickness={thickness} />)

  # line — label — line. The lines carry `weight` so they share the leftover
  # width evenly around a label of any length.
  defp labelled(label, color, thickness, space) do
    ~MOB"""
    <Row fill_width={true}>
      <Divider color={color} thickness={thickness} weight={1} />
      <Spacer size={space} />
      <Text text={label} text_size={:sm} text_color={:muted} />
      <Spacer size={space} />
      <Divider color={color} thickness={thickness} weight={1} />
    </Row>
    """
  end
end
