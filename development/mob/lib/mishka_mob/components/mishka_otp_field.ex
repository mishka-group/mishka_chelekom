defmodule MishkaMob.Components.MishkaOtpField do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless OTP Field** — the segmented
  one-time-code input.

  ## The boxes are the input

  The web version renders one `<input>` per slot, the first with
  `maxlength={@length}` so a paste fills the lot, and moves focus between them.
  You type into the boxes; there is no other field.

  This does the same thing from the user's side. The slots are drawn, and an
  **invisible `TextField` is stacked over them** — transparent background, text,
  caret and indicator — so tapping the boxes opens the keyboard and typing fills
  them left to right. It carries `max_length`, which the bridge enforces
  synchronously, so a seventh digit in a six-slot code is refused outright rather
  than accepted and quietly dropped.

  An earlier version put a visible `TextField` *underneath* the boxes and made
  the boxes a read-only display of it. That is not what the web component does
  and it looked like a bug, because it was one.

  Mob has no focus control, so *which* slot is active cannot come from focus — it
  is derived from the value's length, which is the same answer.

  Whether to draw a caret in it does need focus, though, and that part is
  available: the field reports `on_focus` and `on_blur`, so a screen can hold a
  `focused?` flag and hand it back. Without it there is no cursor at all — the
  overlay's own is deliberately transparent, since it sits over the boxes rather
  than in them — and a tapped field looks identical to an untapped one.

  ## Validation belongs to the value

  `sanitize/2` drops anything the `validation_type` disallows and truncates to
  `length`, so a pasted `"12-34-56"` becomes `"123456"` rather than being
  rejected. `complete?/2` says when the code is full, which is what a screen
  needs for auto-submit.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | string | `""` | The code so far. |
  | `length` | integer | `6` | Number of slots. |
  | `validation_type` | `:numeric` `:alpha` `:alphanumeric` `:none` | `:numeric` | What is allowed. |
  | `mask` | boolean | `false` | Render `•` instead of the character. |
  | `disabled` | boolean | `false` | Mutes and unwires. |
  | `on_change` | event tag (atom) | — | `{:change, tag, text}`. |
  | `color` | color token / ARGB int | `:primary` | Border of filled and active slots. |
  | `slot_width` | number | `44` | Width of one slot. |
  | `group` | integer or list | `nil` | `3` splits evenly (`123-456`); `[3, 4]` splits unevenly (`Abs-5563`). |
  | `separator` | string | `nil` | What to draw between groups. Both props are required. |
  | `id` | string | `nil` | Sets a native testTag on the input, for end-to-end tests. |
  | `focused` | boolean | `false` | Draws a caret in the active slot. Track it with `on_focus`/`on_blur`. |
  | `on_focus` / `on_blur` | event tags | — | `{:focus, tag}` / `{:blur, tag}`. NOT taps. |

  Not ported: `name` (form plumbing), `auto_complete` / `input_mode` (browser
  hints), `transform`, `auto_submit` (the screen decides, using `complete?/2`),
  and the `*_class` attrs.

  `id` IS honoured, though not for the web's reason. The bridge turns an `:id`
  into a Compose `testTag`, which is how an instrumented test gets hold of the
  input — and the input here is invisible, so there is nothing else to match on.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaOtpField />`)."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: otp_field(props)

  @doc """
  Keep only the characters `validation_type` allows, then truncate to `length`.

  A pasted code with separators should still work, so the disallowed characters
  are dropped rather than the whole paste rejected.

      iex> MishkaMob.Components.MishkaOtpField.sanitize("12-34-56", length: 6)
      "123456"
      iex> MishkaMob.Components.MishkaOtpField.sanitize("1234567890", length: 4)
      "1234"
      iex> MishkaMob.Components.MishkaOtpField.sanitize("a1b2", validation_type: :alpha)
      "ab"
      iex> MishkaMob.Components.MishkaOtpField.sanitize("a1-b2", validation_type: :alphanumeric)
      "a1b2"
  """
  @spec sanitize(String.t() | nil, keyword()) :: String.t()
  def sanitize(nil, _opts), do: ""

  def sanitize(text, opts) do
    length = Keyword.get(opts, :length, 6)
    kind = Keyword.get(opts, :validation_type, :numeric)

    text
    |> String.graphemes()
    |> Enum.filter(&allowed?(&1, kind))
    |> Enum.take(length)
    |> Enum.join()
  end

  @doc """
  Whether the code fills every slot — what a screen checks before auto-submitting.

      iex> MishkaMob.Components.MishkaOtpField.complete?("123456", length: 6)
      true
      iex> MishkaMob.Components.MishkaOtpField.complete?("123", length: 6)
      false
  """
  @spec complete?(String.t() | nil, keyword()) :: boolean()
  def complete?(value, opts \\ []) do
    String.length(value || "") == Keyword.get(opts, :length, 6)
  end

  @doc "The OTP field node."
  @spec otp_field(map() | keyword()) :: map()
  def otp_field(props \\ %{}) do
    props = Map.new(props)
    length = Map.get(props, :length) || 6
    value = Map.get(props, :value) || ""
    disabled? = truthy?(Map.get(props, :disabled, false))
    chars = String.graphemes(value)
    # The slot the next character lands in. Focus would tell us on the web; here
    # the value's own length is the same answer and needs no focus API.
    active = min(String.length(value), length - 1)

    slots =
      0..(length - 1)
      |> Enum.flat_map(fn i ->
        [slot(Enum.at(chars, i), i == active, props, disabled?) | gap(i, length, props)]
      end)

    ~MOB"""
    <Box fill_width={true} align={:center}>
      <Row>
        {slots}
      </Row>
      {input(props, value, length, disabled?)}
    </Box>
    """
  end

  # What goes BETWEEN two slots: a separator on a group boundary, otherwise a
  # plain gap. Both `group` and `separator` are required, and the last slot gets
  # neither — the same rule the web component applies
  # (`@separator && @group && rem(i, @group) == 0 && i < @length`).
  defp gap(index, length, props) do
    separator = Map.get(props, :separator)
    boundaries = boundaries(Map.get(props, :group))

    cond do
      index + 1 >= length -> []
      is_binary(separator) and (index + 1) in boundaries -> [separator_node(separator, props)]
      true -> [~MOB(<Spacer size={8} />)]
    end
  end

  @doc """
  The slot offsets a separator follows.

  An integer groups evenly, the way the web component's `group` does:

      iex> MishkaMob.Components.MishkaOtpField.boundaries(3)
      [3, 6, 9, 12, 15, 18]

  A list groups unevenly, which the web cannot express — `Abs-5563` is three
  then four, and an even `group: 3` over seven slots would give `Abs-556-3`:

      iex> MishkaMob.Components.MishkaOtpField.boundaries([3, 4])
      [3]

      iex> MishkaMob.Components.MishkaOtpField.boundaries([2, 2, 2])
      [2, 4]

      iex> MishkaMob.Components.MishkaOtpField.boundaries(nil)
      []
  """
  @spec boundaries(pos_integer() | [pos_integer()] | nil) :: [pos_integer()]
  def boundaries(size) when is_integer(size) and size > 0 do
    # A generous ceiling — anything past the slot count is never matched.
    Enum.map(1..div(20, size)//1, &(&1 * size))
  end

  def boundaries(sizes) when is_list(sizes) do
    sizes
    |> Enum.filter(&(is_integer(&1) and &1 > 0))
    |> Enum.scan(&(&1 + &2))
    |> Enum.drop(-1)
  end

  def boundaries(_), do: []

  defp separator_node(separator, props) do
    ink = if truthy?(Map.get(props, :disabled, false)), do: :border, else: :muted

    ~MOB"""
    <Row align={:center}>
      <Spacer size={6} />
      <Text text={separator} text_size={:xl} text_color={ink} />
      <Spacer size={6} />
    </Row>
    """
  end

  # Stacked over the slots and invisible: the boxes are what the user sees and
  # taps, this is what the keyboard talks to. It is the last child of the Box, so
  # it sits on top and takes the touches.
  #
  # Deliberately NOT capped with `max_length`. A pasted "123-456" is seven
  # characters and would be refused whole, where `sanitize/2` turns it into the
  # code the user meant. Over-typing is corrected on the way back instead.
  defp input(props, value, _length, disabled?) do
    node = ~MOB"""
    <TextField
      value={value}
      placeholder=""
      enabled={not disabled?}
      caret="end"
      keyboard={keyboard(Map.get(props, :validation_type) || :numeric)}
      fill_width={true}
      background={:transparent}
      text_color={:transparent}
      border_color={:transparent}
      text_align={:center}
    />
    """

    node
    |> put(:id, Map.get(props, :id))
    |> put(:on_change, handler(props, disabled?))
    |> put(:on_focus, tag_handler(props, :on_focus, disabled?))
    |> put(:on_blur, tag_handler(props, :on_blur, disabled?))
  end

  defp tag_handler(_props, _key, true), do: nil
  defp tag_handler(props, key, _), do: Event.handler(Map.get(props, key))

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp slot(nil, active?, props, disabled?), do: slot_box("", false, active?, props, disabled?)

  defp slot(char, active?, props, disabled?) do
    shown = if truthy?(Map.get(props, :mask, false)), do: "•", else: char
    slot_box(shown, true, active?, props, disabled?)
  end

  defp slot_box(text, filled?, active?, props, disabled?) do
    accent = Map.get(props, :color) || :primary
    # A caret only in the slot the next character lands in, and only while the
    # field actually has focus — otherwise every OTP on a page would look live.
    caret? =
      active? and not filled? and not disabled? and
        truthy?(Map.get(props, :focused, false))

    # A fixed width, not `weight: 1`: weight is Compose-only and iOS ignores it,
    # which would leave the slots sized to their content there.
    width = Map.get(props, :slot_width) || 44

    border = slot_border(accent, filled? or active?, disabled?)

    ~MOB"""
    <Box
      width={width}
      height={48}
      align={:center}
      background={:surface}
      corner_radius={:radius_sm}
      border_color={border}
      border_width={if(filled? or active?, do: 2, else: 1)}
    >
      {slot_content(text, caret?, accent, disabled?)}
    </Box>
    """
  end

  # A slot only takes the accent while it is live: a disabled field keeps the
  # plain border however full it is.
  defp slot_border(_accent, _lit?, true), do: :border
  defp slot_border(accent, true, _disabled?), do: accent
  defp slot_border(_accent, _lit?, _disabled?), do: :border

  # Mob has no blink, so the caret is a steady bar. A blinking one would need a
  # per-frame re-render of the whole screen, which is a bad trade for a cursor.
  defp slot_content("", true, accent, _disabled?) do
    ~MOB(<Box width={2} height={24} background={accent} corner_radius={:radius_sm} />)
  end

  defp slot_content(text, _caret?, _accent, disabled?) do
    ink = if disabled?, do: :muted, else: :on_surface

    ~MOB(<Text text={text} text_size={:xl} text_color={ink} />)
  end

  defp keyboard(:numeric), do: "number"
  defp keyboard(_kind), do: "text"

  defp allowed?(_char, :none), do: true
  defp allowed?(char, :numeric), do: char =~ ~r/^[0-9]$/
  defp allowed?(char, :alpha), do: char =~ ~r/^[A-Za-z]$/
  defp allowed?(char, _alphanumeric), do: char =~ ~r/^[A-Za-z0-9]$/

  defp handler(_props, true), do: nil
  defp handler(props, _), do: Event.handler(Map.get(props, :on_change))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
