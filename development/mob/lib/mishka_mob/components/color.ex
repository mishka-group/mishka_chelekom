defmodule MishkaMob.Components.Color do
  @moduledoc """
  The colour engine behind Mishka's colour controls — hex parsing, HSV↔RGB
  conversion and ARGB packing.

  On the web these live in one `ColorPicker` JS hook shared by the picker, the
  colour input and the hue/alpha sliders. Here they are pure functions with
  doctests, which is the better trade: colour conversion is exactly the kind of
  arithmetic that is easy to get subtly wrong and cheap to pin down with
  examples.

  ## Units

    * **hue** — degrees, `0..360`, wrapping (`380` is `20`, `-10` is `350`)
    * **saturation** / **value** — `0..100`, clamped
    * **alpha** — `0..100` at this layer (Chelekom's alpha slider is a
      percentage); packed into ARGB as `0..255`
    * **rgb** — `{r, g, b}`, each `0..255`

  Mob takes colours as ARGB integers, so `argb/2` is the last step before a
  colour reaches a prop or a canvas op.
  """

  import Bitwise, only: [<<<: 2]

  @doc """
  Parse a hex colour into `{:ok, {r, g, b}}`, or `:error`.

  Accepts `#rgb` and `#rrggbb`, with or without the leading `#`, in any case.
  Shorthand expands the way CSS does — each digit is doubled, so `#f00` is
  `#ff0000` and not `#f00000`.

      iex> MishkaMob.Components.Color.parse("#3b82f6")
      {:ok, {59, 130, 246}}

      iex> MishkaMob.Components.Color.parse("F00")
      {:ok, {255, 0, 0}}

      iex> MishkaMob.Components.Color.parse("#12345")
      :error

      iex> MishkaMob.Components.Color.parse(nil)
      :error
  """
  @spec parse(String.t() | nil) :: {:ok, {integer(), integer(), integer()}} | :error
  def parse(hex) when is_binary(hex) do
    digits = hex |> String.trim() |> String.trim_leading("#") |> String.downcase()

    cond do
      not String.match?(digits, ~r/\A[0-9a-f]+\z/) -> :error
      String.length(digits) == 3 -> digits |> expand_shorthand() |> pairs()
      String.length(digits) == 6 -> pairs(digits)
      true -> :error
    end
  end

  def parse(_), do: :error

  @doc """
  Whether a string is a usable hex colour — the question a text field asks on
  every keystroke.

      iex> MishkaMob.Components.Color.valid?("#fff")
      true

      iex> MishkaMob.Components.Color.valid?("#ff")
      false
  """
  @spec valid?(String.t() | nil) :: boolean()
  def valid?(hex), do: match?({:ok, _}, parse(hex))

  defp expand_shorthand(digits) do
    digits |> String.graphemes() |> Enum.map_join(&(&1 <> &1))
  end

  defp pairs(<<r::binary-2, g::binary-2, b::binary-2>>) do
    {:ok, {byte(r), byte(g), byte(b)}}
  end

  defp byte(pair), do: String.to_integer(pair, 16)

  @doc """
  Format `{r, g, b}` as a lowercase `#rrggbb` string.

      iex> MishkaMob.Components.Color.hex({59, 130, 246})
      "#3b82f6"

      iex> MishkaMob.Components.Color.hex({0, 0, 0})
      "#000000"
  """
  @spec hex({integer(), integer(), integer()}) :: String.t()
  def hex({r, g, b}) do
    "#" <> pad(r) <> pad(g) <> pad(b)
  end

  defp pad(component) do
    component
    |> clamp_byte()
    |> Integer.to_string(16)
    |> String.downcase()
    |> String.pad_leading(2, "0")
  end

  @doc """
  Pack `{r, g, b}` into the ARGB integer Mob props and canvas ops expect.

  `alpha` is a percentage, `0..100`, to match the alpha slider.

      iex> MishkaMob.Components.Color.argb({255, 0, 0})
      0xFFFF0000

      iex> MishkaMob.Components.Color.argb({255, 0, 0}, 50)
      0x80FF0000
  """
  @spec argb({integer(), integer(), integer()}, number()) :: integer()
  def argb(rgb, alpha \\ 100)

  def argb({r, g, b}, alpha) do
    a = alpha |> clamp(0, 100) |> Kernel.*(255) |> Kernel./(100) |> round()

    (a <<< 24) + (clamp_byte(r) <<< 16) + (clamp_byte(g) <<< 8) + clamp_byte(b)
  end

  @doc """
  Convert HSV to `{r, g, b}`. Hue wraps; saturation and value clamp to `0..100`.

      iex> MishkaMob.Components.Color.hsv_to_rgb(0, 100, 100)
      {255, 0, 0}

      iex> MishkaMob.Components.Color.hsv_to_rgb(120, 100, 100)
      {0, 255, 0}

      iex> MishkaMob.Components.Color.hsv_to_rgb(240, 100, 100)
      {0, 0, 255}

      iex> MishkaMob.Components.Color.hsv_to_rgb(0, 0, 100)
      {255, 255, 255}

      iex> MishkaMob.Components.Color.hsv_to_rgb(0, 0, 0)
      {0, 0, 0}

  A hue of 380° is a hue of 20°:

      iex> MishkaMob.Components.Color.hsv_to_rgb(380, 100, 100) ==
      ...>   MishkaMob.Components.Color.hsv_to_rgb(20, 100, 100)
      true
  """
  @spec hsv_to_rgb(number(), number(), number()) :: {integer(), integer(), integer()}
  def hsv_to_rgb(h, s, v) do
    h = wrap_hue(h)
    s = clamp(s, 0, 100) / 100
    v = clamp(v, 0, 100) / 100

    c = v * s
    x = c * (1 - abs(:math.fmod(h / 60, 2) - 1))
    m = v - c

    {r, g, b} = sector(h, c, x)

    {round((r + m) * 255), round((g + m) * 255), round((b + m) * 255)}
  end

  defp sector(h, c, x) when h < 60, do: {c, x, 0}
  defp sector(h, c, x) when h < 120, do: {x, c, 0}
  defp sector(h, c, x) when h < 180, do: {0, c, x}
  defp sector(h, c, x) when h < 240, do: {0, x, c}
  defp sector(h, c, x) when h < 300, do: {x, 0, c}
  defp sector(_h, c, x), do: {c, 0, x}

  @doc """
  Convert `{r, g, b}` to `{hue, saturation, value}` — hue in degrees, the other
  two as percentages, all rounded.

      iex> MishkaMob.Components.Color.rgb_to_hsv({255, 0, 0})
      {0, 100, 100}

      iex> MishkaMob.Components.Color.rgb_to_hsv({0, 128, 0})
      {120, 100, 50}

      iex> MishkaMob.Components.Color.rgb_to_hsv({255, 255, 255})
      {0, 0, 100}

  Grey has no hue to speak of, so it reports 0 rather than an arbitrary angle:

      iex> MishkaMob.Components.Color.rgb_to_hsv({128, 128, 128})
      {0, 0, 50}
  """
  @spec rgb_to_hsv({integer(), integer(), integer()}) :: {integer(), integer(), integer()}
  def rgb_to_hsv({r, g, b}) do
    r = clamp_byte(r) / 255
    g = clamp_byte(g) / 255
    b = clamp_byte(b) / 255

    max = Enum.max([r, g, b])
    min = Enum.min([r, g, b])
    delta = max - min

    {round(hue(delta, max, r, g, b)), round(saturation(delta, max) * 100), round(max * 100)}
  end

  defp saturation(_delta, +0.0), do: 0.0
  defp saturation(delta, max), do: delta / max

  defp hue(delta, _max, _r, _g, _b) when delta == 0, do: 0.0

  defp hue(delta, max, r, g, b) do
    raw =
      cond do
        max == r -> 60 * :math.fmod((g - b) / delta, 6)
        max == g -> 60 * ((b - r) / delta + 2)
        true -> 60 * ((r - g) / delta + 4)
      end

    wrap_hue(raw)
  end

  @doc """
  The fully saturated, fully bright colour at `hue` — what a hue slider's track
  paints, and the base a saturation/value area is built from.

      iex> MishkaMob.Components.Color.hue_rgb(0)
      {255, 0, 0}

      iex> MishkaMob.Components.Color.hue_rgb(240)
      {0, 0, 255}
  """
  @spec hue_rgb(number()) :: {integer(), integer(), integer()}
  def hue_rgb(hue), do: hsv_to_rgb(hue, 100, 100)

  @doc """
  Hex straight from HSV — the round trip a picker performs on every drag.

      iex> MishkaMob.Components.Color.hsv_to_hex(217, 76, 96)
      "#3b82f5"

  Note the last digit: hex → HSV → hex is accurate to about ±1 per channel,
  because HSV is held as whole degrees and percentages. That is the same
  precision the web picker keeps, and it is invisible on screen — but it does
  mean a hex the user typed should be stored as typed, not round-tripped
  through HSV on every keystroke.
  """
  @spec hsv_to_hex(number(), number(), number()) :: String.t()
  def hsv_to_hex(h, s, v), do: h |> hsv_to_rgb(s, v) |> hex()

  @doc """
  HSV from a hex string, falling back to `default` when it will not parse — so a
  half-typed field never crashes a render.

      iex> MishkaMob.Components.Color.hex_to_hsv("#ff0000")
      {0, 100, 100}

      iex> MishkaMob.Components.Color.hex_to_hsv("nope")
      {0, 0, 100}
  """
  @spec hex_to_hsv(String.t() | nil, {integer(), integer(), integer()}) ::
          {integer(), integer(), integer()}
  def hex_to_hsv(hex, default \\ {0, 0, 100}) do
    case parse(hex) do
      {:ok, rgb} -> rgb_to_hsv(rgb)
      :error -> default
    end
  end

  @doc """
  Whether text on this background should be dark.

  Uses the ITU-R BT.601 luma weights — the same rule the web picker uses to keep
  its readout legible as the swatch moves from black to white.

      iex> MishkaMob.Components.Color.light?({255, 255, 255})
      true

      iex> MishkaMob.Components.Color.light?({0, 0, 128})
      false
  """
  @spec light?({integer(), integer(), integer()}) :: boolean()
  def light?({r, g, b}) do
    0.299 * clamp_byte(r) + 0.587 * clamp_byte(g) + 0.114 * clamp_byte(b) > 140
  end

  @doc """
  Ink that stays readable on `rgb` — near-black on light colours, white on dark.

      iex> MishkaMob.Components.Color.ink_on({255, 255, 255})
      0xFF111827

      iex> MishkaMob.Components.Color.ink_on({0, 0, 0})
      0xFFFFFFFF
  """
  @spec ink_on({integer(), integer(), integer()}) :: integer()
  def ink_on(rgb), do: if(light?(rgb), do: 0xFF_11_18_27, else: 0xFF_FF_FF_FF)

  @doc """
  Wrap a hue into `0..360`.

      iex> MishkaMob.Components.Color.wrap_hue(380)
      20.0

      iex> MishkaMob.Components.Color.wrap_hue(-10)
      350.0
  """
  @spec wrap_hue(number()) :: float()
  def wrap_hue(hue) do
    case :math.fmod(hue * 1.0, 360.0) do
      wrapped when wrapped < 0 -> wrapped + 360.0
      wrapped -> wrapped
    end
  end

  @doc """
  Clamp a number into `[min, max]`.

      iex> MishkaMob.Components.Color.clamp(120, 0, 100)
      100
  """
  @spec clamp(number(), number(), number()) :: number()
  def clamp(value, min, _max) when value < min, do: min
  def clamp(value, _min, max) when value > max, do: max
  def clamp(value, _min, _max), do: value

  defp clamp_byte(component), do: component |> round() |> clamp(0, 255)
end
