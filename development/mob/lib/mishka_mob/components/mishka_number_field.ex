defmodule MishkaMob.Components.MishkaNumberField do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Number Field** — a numeric
  input with decrement/increment buttons.

  The text side is Mob's native `TextField` with a numeric keyboard, so the
  platform brings the right keypad; the steppers are tappable boxes either side.

  ## Parsing is the component, not the markup

  A numeric input's real work is turning whatever the user typed into a number:
  partial input while typing (`"-"`, `"1."`, `""`), values outside the range, and
  the step arithmetic that must not drift into floating-point noise. Those live
  in `parse/2` and `step/3` as pure functions, so a screen gets the same
  behaviour as the buttons without re-deriving it — and so the awkward cases are
  tested rather than discovered.

  `step/3` clamps into `[min, max]` and rounds to the step's own precision, so
  stepping `0.1` from `0.3` gives `0.4` rather than `0.4000000000000001`.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | number or `nil` | `nil` | Current value. |
  | `min` / `max` | number or `nil` | `nil` | Bounds. Unbounded when absent. |
  | `step` | number | `1` | Amount the buttons move. |
  | `placeholder` | string | `nil` | Shown while empty. |
  | `disabled` | boolean | `false` | Mutes and unwires everything. |
  | `on_change` | event tag (atom) | — | `{:change, tag, text}` from the field. |
  | `on_step` | event tag (atom) | — | `{:tap, {tag, :up \\| :down}}` from the buttons. |
  | `decimals` | integer | derived from `step` | Display precision. |
  | `format` | `:plain` `:currency` `:percent` | `:plain` | How the value reads. |
  | `size` | number | `56` | Stepper edge, and the strip's height. |
  | `value_width` | number | estimated from the text | The value slot, when not spanning. |
  | `fill_width` | boolean | `false` | Span the parent instead of hugging. |
  | `background` / `border_color` / `border_width` / `corner_radius` | | | The strip. |

  ## One control, not three

  It renders a single bordered strip — stepper, hairline, centred value,
  hairline, stepper — because that is what a number field *is*. It used to be a
  button, a gap, a bordered field that filled the row, and another button, so
  the two steppers drifted to opposite edges of the screen with a wide box
  marooned between them. The inner field therefore draws no box of its own:
  `underline: false` suppresses the platform's indicator line, and the strip
  around it is the only border.

  A stepper goes inert at its bound as well as when disabled — a `+` that cannot
  go up should not look pressable, which is what the web's own `disabled`
  attribute does there.

  Not ported: `name` (form plumbing), `small_step` / `large_step` (they are
  modifier-key gestures — there is no shift or alt on a phone), `snap_on_step`,
  `allow_out_of_range` (the port always clamps), press-and-hold to repeat
  (Android's bridge has no long-press event at all; iOS has `onLongPress`, so
  this is blocked on the Android side rather than the design), scrub-to-change
  (a pointer drag on the label), and the `*_class` attrs.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaNumberField />`)."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: number_field(props)

  @doc """
  Parse user input into a number, or `nil` when it is not (yet) one.

  Partial input while typing must not blow up or snap to zero: a lone `"-"` or a
  trailing `"."` is "not a number yet", not an error.

      iex> MishkaMob.Components.MishkaNumberField.parse("42")
      42
      iex> MishkaMob.Components.MishkaNumberField.parse("4.5")
      4.5
      iex> MishkaMob.Components.MishkaNumberField.parse("-")
      nil
      iex> MishkaMob.Components.MishkaNumberField.parse("")
      nil
      iex> MishkaMob.Components.MishkaNumberField.parse("abc")
      nil
  """
  @spec parse(String.t() | number() | nil, keyword()) :: number() | nil
  def parse(input, opts \\ [])
  def parse(value, opts) when is_number(value), do: clamp(value, opts)
  def parse(nil, _opts), do: nil

  def parse(text, opts) when is_binary(text) do
    trimmed = String.trim(text)

    cond do
      trimmed in ["", "-", "+", ".", "-.", "+."] ->
        nil

      true ->
        case Float.parse(trimmed) do
          {float, ""} -> clamp(maybe_integer(float, trimmed), opts)
          _ -> nil
        end
    end
  end

  @doc """
  Move `value` by one `step` in `direction`, clamped into the range.

  Rounds to the step's own precision so repeated stepping does not accumulate
  floating-point noise.

      iex> MishkaMob.Components.MishkaNumberField.step(1, :up, step: 1)
      2
      iex> MishkaMob.Components.MishkaNumberField.step(0.3, :up, step: 0.1)
      0.4
      iex> MishkaMob.Components.MishkaNumberField.step(nil, :up, step: 1, min: 5)
      5
      iex> MishkaMob.Components.MishkaNumberField.step(10, :up, step: 1, max: 10)
      10
  """
  @spec step(number() | nil, :up | :down, keyword()) :: number()
  def step(value, direction, opts \\ [])

  def step(nil, _direction, opts) do
    # No current value: the first press establishes the starting point rather
    # than jumping a step past it. Stepping up from empty with min: 5 lands on
    # 5, not 6.
    (Keyword.get(opts, :min) || 0) |> clamp(opts)
  end

  def step(value, direction, opts) do
    amount = Keyword.get(opts, :step, 1)
    moved = if direction == :down, do: value - amount, else: value + amount

    moved
    |> round_to(amount)
    |> clamp(opts)
  end

  @doc """
  Render a value for display, at the precision implied by the step.

      iex> MishkaMob.Components.MishkaNumberField.to_text(4, 0)
      "4"
      iex> MishkaMob.Components.MishkaNumberField.to_text(4.5, 1)
      "4.5"
      iex> MishkaMob.Components.MishkaNumberField.to_text(nil, 0)
      ""
  """
  @spec to_text(number() | nil, non_neg_integer()) :: String.t()
  def to_text(nil, _decimals), do: ""
  def to_text(value, 0) when is_integer(value), do: Integer.to_string(value)
  def to_text(value, 0), do: value |> round() |> Integer.to_string()
  def to_text(value, decimals), do: :erlang.float_to_binary(value * 1.0, decimals: decimals)

  @doc """
  The number of decimals a step implies.

      iex> MishkaMob.Components.MishkaNumberField.decimals_for(1)
      0
      iex> MishkaMob.Components.MishkaNumberField.decimals_for(0.25)
      2
  """
  @spec decimals_for(number()) :: non_neg_integer()
  def decimals_for(step) when is_integer(step), do: 0

  def decimals_for(step) do
    case step |> Float.to_string() |> String.split(".") do
      [_, frac] -> frac |> String.trim_trailing("0") |> String.length()
      _ -> 0
    end
  end

  @doc "The number-field node."
  @spec number_field(map() | keyword()) :: map()
  def number_field(props \\ %{}) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))
    amount = Map.get(props, :step) || 1
    decimals = Map.get(props, :decimals) || decimals_for(amount)
    value = Map.get(props, :value)
    text = display(value, props, decimals)

    # ONE joined control, not three pieces in a row. It used to be a stepper, a
    # gap, a bordered field that filled the row, and another stepper — so the
    # buttons drifted to the far edges with a wide box marooned between them.
    # The web draws a single bordered strip with the value centred and the
    # steppers flanking it, and that is what a number field is: one control.
    ~MOB"""
    <Box
      fill_width={truthy?(Map.get(props, :fill_width, false))}
      background={Map.get(props, :background) || :surface}
      corner_radius={Map.get(props, :corner_radius) || :radius_sm}
      border_color={Map.get(props, :border_color) || :border}
      border_width={Map.get(props, :border_width) || 1}
    >
      <Row>
        {stepper("−", :down, props, disabled? or at_bound?(value, :down, props))}
        {rule(props)}
        {value_slot(props, text, disabled?)}
        {rule(props)}
        {stepper("+", :up, props, disabled? or at_bound?(value, :up, props))}
      </Row>
    </Box>
    """
  end

  @doc """
  Whether stepping `direction` would do nothing, because the value is already at
  that end of the range.

      iex> MishkaMob.Components.MishkaNumberField.at_bound?(10, :up, max: 10)
      true
      iex> MishkaMob.Components.MishkaNumberField.at_bound?(9, :up, max: 10)
      false
      iex> MishkaMob.Components.MishkaNumberField.at_bound?(nil, :up, max: 10)
      false
  """
  @spec at_bound?(number() | nil, :up | :down, keyword() | map()) :: boolean()
  def at_bound?(nil, _direction, _opts), do: false

  def at_bound?(value, direction, opts) do
    opts = Map.new(opts)
    bound = if direction == :up, do: Map.get(opts, :max), else: Map.get(opts, :min)

    cond do
      is_nil(bound) -> false
      direction == :up -> value >= bound
      true -> value <= bound
    end
  end

  @doc """
  Render a value the way the web's `format` does.

  `:plain` is the number itself. `:currency` and `:percent` are the two the web
  ships, and percent is the one worth stating: it renders a **fraction** as a
  percentage, so `0.075` shows as `7.5%` — the value in the assign is never the
  number on the screen.

      iex> MishkaMob.Components.MishkaNumberField.format(1999.99, :currency, 2)
      "$1,999.99"
      iex> MishkaMob.Components.MishkaNumberField.format(0.075, :percent, 3)
      "7.5%"
      iex> MishkaMob.Components.MishkaNumberField.format(42, :plain, 0)
      "42"
      iex> MishkaMob.Components.MishkaNumberField.format(nil, :currency, 2)
      ""
  """
  @spec format(number() | nil, atom(), non_neg_integer()) :: String.t()
  def format(nil, _kind, _decimals), do: ""

  def format(value, :currency, decimals) do
    "$" <> group(to_text(value, decimals))
  end

  def format(value, :percent, decimals) do
    # The stored value is a fraction, so the displayed precision is two decimals
    # coarser than the step that produced it.
    to_text(value * 100, max(decimals - 2, 0)) <> "%"
  end

  def format(value, _plain, decimals), do: to_text(value, decimals)

  # Thousands separators, applied to the integer part only.
  defp group(text) do
    {int, frac} =
      case String.split(text, ".") do
        [i, f] -> {i, "." <> f}
        [i] -> {i, ""}
      end

    {sign, digits} =
      if String.starts_with?(int, "-"), do: {"-", String.trim_leading(int, "-")}, else: {"", int}

    grouped =
      digits
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.chunk_every(3)
      |> Enum.map_join(",", &Enum.join/1)
      |> String.reverse()

    sign <> grouped <> frac
  end

  defp display(value, props, decimals),
    do: format(value, Map.get(props, :format) || :plain, decimals)

  # The value slot is a FIXED width unless the strip is asked to span. `weight`
  # makes a child take everything left over, so a weighted slot forced the whole
  # strip to the width of its parent — it hugged in the tree and filled the
  # screen on the device, which is the bug this component started with.
  defp value_slot(props, text, disabled?) do
    if truthy?(Map.get(props, :fill_width, false)) do
      ~MOB"""
      <Box weight={1}>
        {input(props, text, disabled?)}
      </Box>
      """
    else
      ~MOB"""
      <Box width={value_width(props, text)}>
        {input(props, text, disabled?)}
      </Box>
      """
    end
  end

  # There is no text measurement on this side of the bridge, so the slot's
  # default width is an estimate from the rendered string: roughly 16dp a
  # character, never below 96. A fixed 96 clipped "$1,999.99" to "99.99" — a
  # money string is simply longer than a quantity, and the component knows which
  # it is rendering. Pass `value_width` to take the decision back.
  defp value_width(props, text) do
    Map.get(props, :value_width) || max(96, 40 + 16 * String.length(text))
  end

  # A hairline between the stepper and the value, so the strip reads as one
  # control with three parts rather than three controls that happen to touch.
  defp rule(props) do
    ~MOB"""
    <Box
      width={1}
      height={Map.get(props, :size) || 56}
      background={Map.get(props, :border_color) || :border}
    />
    """
  end

  defp input(props, text, disabled?) do
    node = ~MOB"""
    <TextField
      value={text}
      placeholder={Map.get(props, :placeholder) || ""}
      keyboard={keyboard_for(Map.get(props, :step) || 1)}
      fill_width={true}
      text_align="center"
      background={:transparent}
      enabled={not disabled?}
      underline={false}
    />
    """

    node = tag(node, Map.get(props, :id))

    case handler(props, :on_change, disabled?) do
      nil -> node
      tap -> %{node | props: Map.put(node.props, :on_change, tap)}
    end
  end

  # Inert at a bound as well as when disabled: a + that cannot go up should not
  # look pressable, which is what the web does with its own disabled attribute.
  defp stepper(glyph, direction, props, inert?) do
    color = if inert?, do: :muted, else: :on_surface
    size = Map.get(props, :size) || 56

    node = ~MOB"""
    <Box width={size} height={size} align={:center} background={:transparent}>
      <Text text={glyph} text_size={:lg} text_color={color} />
    </Box>
    """

    # Every stepper on a page reads "−" or "+", so an exact-text lookup cannot
    # tell two number fields apart. The tag carries the direction as well.
    node = tag(node, suffix(Map.get(props, :id), direction))

    case handler(props, :on_step, inert?) do
      nil -> node
      {pid, tag} -> %{node | props: Map.put(node.props, :on_tap, {pid, {tag, direction}})}
    end
  end

  # A whole-number step wants the plain number pad; a fractional one needs the
  # decimal point. A non-numeric step fails the guard and gets the decimal pad
  # rather than raising inside a node build.
  defp keyboard_for(step) when is_number(step) and step == trunc(step), do: "number"
  defp keyboard_for(_step), do: "decimal"

  defp tag(node, nil), do: node
  defp tag(node, id), do: %{node | props: Map.put(node.props, :id, id)}

  defp suffix(nil, _direction), do: nil
  defp suffix(id, direction), do: "#{id}-#{direction}"

  defp handler(_props, _key, true), do: nil
  defp handler(props, key, _), do: Event.handler(Map.get(props, key))

  defp clamp(value, opts) do
    value
    |> then(fn v -> if (min = Keyword.get(opts, :min)) && v < min, do: min, else: v end)
    |> then(fn v -> if (max = Keyword.get(opts, :max)) && v > max, do: max, else: v end)
  end

  # Keep integers integral: "42" should not become 42.0.
  defp maybe_integer(float, text) do
    if String.contains?(text, "."), do: float, else: trunc(float)
  end

  defp round_to(value, amount) when is_integer(amount), do: round(value)

  # Round to the step's own precision so repeated stepping does not accumulate
  # floating-point noise (0.3 + 0.1 must be 0.4, not 0.4000000000000001).
  defp round_to(value, amount), do: Float.round(value * 1.0, decimals_for(amount))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
