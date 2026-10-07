defmodule DevelopmentWeb.Components.Headless.NumberFormatter do
  @moduledoc """
  Headless **number formatter** — display a number with thousands/decimal separators and
  an optional prefix/suffix (Mantine NumberFormatter parity).

  Pure render-time formatting — **no JS**. Renders a `<span>` with the formatted text.

  Ships **no** styling — style via `chelekom-number-formatter`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/number_formatter
  """
  use Phoenix.Component

  @doc type: :component
  attr :value, :any, required: true, doc: "The number (or numeric string) to format"

  attr :thousand_separator, :any,
    default: ",",
    doc: "Grouping separator (string, or false to disable)"

  attr :decimal_separator, :string, default: ".", doc: "Decimal separator"
  attr :decimal_scale, :integer, default: nil, doc: "Fixed number of decimal places"
  attr :prefix, :string, default: nil, doc: "Text before the number (e.g. \"$\")"
  attr :suffix, :string, default: nil, doc: "Text after the number (e.g. \"%\")"
  attr :class, :any, default: nil, doc: "Extra classes"
  attr :rest, :global

  def number_formatter(assigns) do
    assigns = assign(assigns, :formatted, format_number(assigns))

    ~H"""
    <span class={["chelekom-number-formatter", @class]} {@rest}>{@formatted}</span>
    """
  end

  defp format_number(a) do
    sep = thousand_separator(a.thousand_separator)

    {int_str, frac_str} =
      a.value
      |> to_number()
      |> number_text(a.decimal_scale)
      |> split_decimal()

    {sign, digits} = split_sign(int_str)
    frac = if frac_str && frac_str != "", do: a.decimal_separator <> frac_str, else: ""
    "#{a.prefix}#{sign}#{group(digits, sep)}#{frac}#{a.suffix}"
  end

  defp thousand_separator(false), do: ""
  defp thousand_separator(nil), do: ""
  defp thousand_separator(s) when is_binary(s), do: s
  defp thousand_separator(_), do: ","

  defp number_text(num, decimal_scale) do
    cond do
      decimal_scale -> :erlang.float_to_binary(num * 1.0, decimals: decimal_scale)
      is_integer(num) -> Integer.to_string(num)
      true -> Float.to_string(num)
    end
  end

  defp split_decimal(str) do
    case String.split(str, ".") do
      [i, f] -> {i, f}
      [i] -> {i, nil}
    end
  end

  defp split_sign("-" <> rest), do: {"-", rest}
  defp split_sign(int_str), do: {"", int_str}

  defp to_number(v) when is_number(v), do: v

  defp to_number(v) when is_binary(v) do
    case Float.parse(v) do
      {f, _} -> f
      :error -> 0
    end
  end

  defp to_number(_), do: 0

  defp group(digits, ""), do: digits

  defp group(digits, sep) do
    digits
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.map(&(&1 |> Enum.reverse() |> Enum.join()))
    |> Enum.reverse()
    |> Enum.join(sep)
  end
end
