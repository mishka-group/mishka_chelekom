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
  | `id` | string | `nil` | Test tag. The labelled variant also tags each line. |

  `decorative` from the web component is **not** ported: it only flips
  `role="separator"` to `role="none"` for screen readers in the DOM, and Mob
  exposes no such role on a divider.

  ## A rule has nothing to assert on without an `id`

  A separator draws a line: no text, no state, nothing in the semantics tree.
  So `id` is not decoration here, it is the only way a device test can say
  *which* rule it means — and the only way to check the one thing a rule can
  get wrong, which is its geometry. The labelled variant additionally tags its
  two flanking lines `<id>-line-start` and `<id>-line-end`, because "the label
  sits centred between two equal lines" is a claim about their widths.

  ## Platform note

  **Only the plain rule is portable.** Both other variants are broken on iOS,
  and the breakage is in the `mob` dependency rather than here — see
  `IOS_TODO.md` items 11-13:

    * the **vertical** rule renders 1pt wide and **0pt tall**, i.e. invisible.
      It is a Box with a `width` and `fill_height`, and iOS's `MobBox` consults
      `fillHeight` only in the branch it takes when there is *no* width;
    * the **labelled** variant's flanking lines come out as 1x1pt ticks.
      SwiftUI's `Divider()` draws along the axis of its container, so inside the
      `Row` that centres the label it is a *vertical* hairline, then clamped to
      `thickness` tall;
    * `weight` is read nowhere in the iOS renderer, so the two lines cannot
      share the leftover width there in any case.

  Android is correct for all three.
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
    id = Map.get(props, :id)

    cond do
      Map.get(props, :orientation, :horizontal) == :vertical ->
        tag(~MOB(<Box width={thickness} fill_height={true} background={color} />), id)

      is_binary(label) and label != "" ->
        labelled(label, color, thickness, Map.get(props, :space, 12), id)

      true ->
        tag(rule(color, thickness), id)
    end
  end

  @doc """
  The test tags on a labelled separator's two flanking lines.

      iex> MishkaMob.Components.MishkaSeparator.line_ids("or")
      {"or-line-start", "or-line-end"}
  """
  @spec line_ids(String.t()) :: {String.t(), String.t()}
  def line_ids(id) when is_binary(id), do: {id <> "-line-start", id <> "-line-end"}

  defp rule(color, thickness), do: ~MOB(<Divider color={color} thickness={thickness} />)

  # line — label — line. The lines carry `weight` so they share the leftover
  # width evenly around a label of any length. Each is tagged separately: their
  # widths are the only evidence that the label is actually centred, and a Row
  # merges its children away from a tag query that does not ask for the
  # unmerged tree.
  defp labelled(label, color, thickness, space, id) do
    {start_id, end_id} = if is_binary(id), do: line_ids(id), else: {nil, nil}

    ~MOB"""
    <Row fill_width={true}>
      {tag(rule_with_weight(color, thickness), start_id)}
      <Spacer size={space} />
      <Text text={label} text_size={:sm} text_color={:muted} />
      <Spacer size={space} />
      {tag(rule_with_weight(color, thickness), end_id)}
    </Row>
    """
    |> tag(id)
  end

  defp rule_with_weight(color, thickness),
    do: ~MOB(<Divider color={color} thickness={thickness} weight={1} />)

  defp tag(node, nil), do: node
  defp tag(node, id), do: %{node | props: Map.put(node.props, :id, id)}
end
