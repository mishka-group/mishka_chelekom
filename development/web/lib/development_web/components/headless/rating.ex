defmodule DevelopmentWeb.Components.Headless.Rating do
  @moduledoc """
  Headless **rating** — a star rating that is a radio group underneath.

  That is the whole design: a rating *is* a single choice from an ordered set, so it reuses the
  `RadioGroup` engine rather than inventing a widget. You get the APG radio behaviour for free —
  arrow keys move and select, Home/End jump to the ends, one tab stop for the whole control — plus
  a hidden input that carries the value into a surrounding form and fires `input`, so
  `<.form phx-change>` sees every change.

  `precision` is the interesting attribute. At `1.0` there is one control per star; at `0.5` there
  are two half-width controls per star, which is how a half-star rating is actually picked rather
  than approximated. The value is a float either way, and `data-value` carries it, so the server
  never has to reconstruct halves from an index.

  `readonly` shows a rating without letting it change — a review someone else left — and is not the
  same as `disabled`: focus still moves through a readonly rating, so it can be read with a screen
  reader. `clearable` adds a zero-width control before the first star, which is the only way to get
  back to no rating once one has been given.

  Parts: `item`. The items are siblings so a stylesheet can fill every star up to the chosen one
  with `:has(~ [aria-checked="true"])` and no JS at all.

  Ships **no** colors, sizing or spacing — style via `chelekom-rating*` and the
  `data-checked` / `data-half` hooks.

  WAI-ARIA: https://www.w3.org/WAI/ARIA/apg/patterns/radio/

  **Documentation:** https://mishka.tools/chelekom/docs/headless/rating
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the RadioGroup hook)"
  attr :name, :string, default: nil, doc: "Name for the hidden input that carries the value"
  attr :value, :any, default: 0, doc: "The current rating; a float when `precision` is 0.5"
  attr :count, :integer, default: 5, doc: "How many stars"

  attr :precision, :float,
    default: 1.0,
    values: [1.0, 0.5],
    doc: "1.0 for whole stars, 0.5 to pick halves"

  attr :label, :string, default: "Rating", doc: "Accessible name for the group"

  attr :clearable, :boolean,
    default: false,
    doc: "Add a zero-width control for going back to no rating"

  attr :readonly, :boolean,
    default: false,
    doc: "Show the rating without letting it change; focus still moves through it"

  attr :disabled, :boolean, default: false, doc: "Disable the whole control"

  attr :on_change, :any,
    default: nil,
    doc: "LiveView event name pushed as `%{value}` whenever the rating changes"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :item_class, :any, default: nil, doc: ~s|Extra classes for every `data-part="item"`|
  attr :rest, :global

  def rating(assigns) do
    assigns = assign(assigns, :values, values(assigns.count, assigns.precision))

    ~H"""
    <div
      id={@id}
      role="radiogroup"
      aria-label={@label}
      aria-readonly={@readonly && "true"}
      phx-hook="RadioGroup"
      data-part="root"
      data-orientation="horizontal"
      data-disabled={@disabled}
      data-precision={@precision}
      data-on-change={@on_change}
      class={["chelekom-rating", @class]}
      {@rest}
    >
      <input type="hidden" name={@name} value={to_string(@value)} />

      <button
        :if={@clearable}
        type="button"
        role="radio"
        data-part="item"
        data-value="0"
        data-clear
        data-checked={checked?(0, @value)}
        data-unchecked={!checked?(0, @value)}
        aria-checked={to_string(checked?(0, @value))}
        aria-label="No rating"
        tabindex={tabindex(0, @value, @clearable, @values)}
        disabled={@disabled}
        class={["chelekom-rating__item", @item_class]}
      />

      <button
        :for={{value, index} <- Enum.with_index(@values)}
        type="button"
        role="radio"
        data-part="item"
        data-value={value}
        data-half={@precision == 0.5 && if(rem(index, 2) == 0, do: "first", else: "second")}
        data-checked={checked?(value, @value)}
        data-unchecked={!checked?(value, @value)}
        aria-checked={to_string(checked?(value, @value))}
        aria-label={"#{value} of #{@count}"}
        tabindex={tabindex(value, @value, @clearable, @values)}
        disabled={@disabled}
        class={["chelekom-rating__item", @item_class]}
      />
    </div>
    """
  end

  # A radio group is one tab stop: the chosen control is the one you land on, and the first one
  # stands in when nothing has been chosen yet — without that fallback an unrated control cannot be
  # reached by keyboard at all.
  defp tabindex(value, current, clearable, values) do
    candidates = if clearable, do: [0 | values], else: values

    cond do
      checked?(value, current) -> "0"
      Enum.any?(candidates, &checked?(&1, current)) -> "-1"
      value == List.first(candidates) -> "0"
      true -> "-1"
    end
  end

  defp checked?(value, current), do: to_float(value) == to_float(current)

  defp to_float(value) when is_float(value), do: value
  defp to_float(value) when is_integer(value), do: value * 1.0

  defp to_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, _} -> float
      :error -> 0.0
    end
  end

  defp to_float(_), do: 0.0

  # Whole stars are 1..count; halves are every 0.5 step, which is what makes each star two
  # half-width controls rather than one control the caller has to interpret.
  defp values(count, 0.5), do: Enum.map(1..(count * 2), &(&1 / 2))
  defp values(count, _precision), do: Enum.map(1..count, &(&1 * 1.0))
end
