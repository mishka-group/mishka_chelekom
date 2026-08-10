defmodule DevelopmentWeb.Components.Headless.Countdown do
  @moduledoc """
  Headless **countdown** — the time left until a moment, ticking.

  daisyUI's countdown is a *display*: it animates a number you change yourself and ships no timer.
  This one counts. Give it a `target` and the server renders the correct remaining time on the
  first paint — so it is right before any JavaScript runs, and right again after a reconnect —
  while the `Countdown` hook ticks it down in between.

  Each unit is a `digit` part carrying `--value`, which is the custom property daisyUI's rolling
  digits animate, and its own text for anyone without the skin. `on_complete` fires once when the
  target passes, so the server can act on it rather than the page merely sitting at zero.

  A ticking timer is a screen-reader hazard: `aria-live="polite"` on every second is unusable
  noise. The root is `role="timer"` with live updates **off** by default; `announce` opts into
  polite announcements for the short countdowns where they are wanted.

  Parts: `unit`, `digit`, `label`, `separator`.

  Ships **no** colors, sizing or spacing — style via `chelekom-countdown*`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/countdown
  """
  use Phoenix.Component

  @sizes [{"days", 86_400}, {"hours", 3_600}, {"minutes", 60}, {"seconds", 1}]

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the Countdown hook)"

  attr :target, :any,
    default: nil,
    doc: "A DateTime, NaiveDateTime or ISO8601 string to count down to"

  attr :seconds, :integer,
    default: nil,
    doc: "How many seconds are left, when you have a duration rather than a moment"

  attr :units, :list,
    default: ~w(days hours minutes seconds),
    doc: "Which units to show, largest first; the largest one absorbs everything above it"

  attr :show_labels, :boolean, default: false, doc: "Render a label beside each unit"

  attr :labels, :map,
    default: %{},
    doc: ~s|Override a unit's label, e.g. %{"seconds" => "sec"}|

  attr :separator, :string, default: nil, doc: ~s|Text between units, e.g. ":" for a clock|

  attr :announce, :boolean,
    default: false,
    doc: "Announce each tick politely; off by default, because a per-second live region is noise"

  attr :on_complete, :string,
    default: nil,
    doc: "LiveView event pushed once when the countdown reaches zero"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :unit_class, :any, default: nil, doc: ~s|Extra classes for `data-part="unit"`|
  attr :digit_class, :any, default: nil, doc: ~s|Extra classes for `data-part="digit"`|
  attr :label_class, :any, default: nil, doc: ~s|Extra classes for `data-part="label"`|
  attr :rest, :global

  def countdown(assigns) do
    remaining = remaining(assigns.target, assigns.seconds)

    assigns =
      assigns
      |> assign(:remaining, remaining)
      |> assign(:parts, split(remaining, assigns.units))
      |> assign(:deadline, deadline(assigns.target, assigns.seconds))

    ~H"""
    <div
      id={@id}
      role="timer"
      aria-live={if @announce, do: "polite", else: "off"}
      phx-hook="Countdown"
      data-part="root"
      data-deadline={@deadline}
      data-units={Enum.join(@units, " ")}
      data-complete={@remaining <= 0}
      data-on-complete={@on_complete}
      class={["chelekom-countdown", @class]}
      {@rest}
    >
      <span
        :for={{{unit, value}, index} <- Enum.with_index(@parts)}
        data-part="unit"
        data-unit={unit}
        class={["chelekom-countdown__unit", @unit_class]}
      >
        <span
          :if={@separator && index > 0}
          data-part="separator"
          aria-hidden="true"
          class="chelekom-countdown__separator"
        >{@separator}</span>

        <span
          data-part="digit"
          data-unit={unit}
          style={"--value:#{value};"}
          aria-label={"#{value} #{label_for(unit, @labels)}"}
          class={["chelekom-countdown__digit", @digit_class]}
        >{value}</span>

        <span
          :if={@show_labels}
          data-part="label"
          aria-hidden="true"
          class={["chelekom-countdown__label", @label_class]}
        >{label_for(unit, @labels)}</span>
      </span>
    </div>
    """
  end

  defp label_for(unit, labels), do: Map.get(labels, unit, unit)

  @doc """
  Splits `remaining` seconds across `units`, largest first.

  The largest unit shown absorbs everything above it: a countdown of hours and minutes over two
  days reads 50 hours rather than 2, because dropping the days would lose them silently.

  Public because it is the component's arithmetic — a caller rendering the same countdown into a
  page title or an email should not have to re-derive it.
  """
  @spec split(integer(), [String.t()]) :: [{String.t(), non_neg_integer()}]
  def split(remaining, units) do
    shown = Enum.filter(@sizes, fn {name, _} -> name in units end)

    {parts, _left} =
      Enum.map_reduce(shown, max(remaining, 0), fn {name, size}, left ->
        {{name, div(left, size)}, rem(left, size)}
      end)

    parts
  end

  # Rendered server-side so the first paint is already correct, and correct again after a
  # reconnect — the hook only keeps it moving between renders.
  defp remaining(nil, seconds) when is_integer(seconds), do: max(seconds, 0)
  defp remaining(nil, _), do: 0

  defp remaining(target, _seconds) do
    case to_datetime(target) do
      nil -> 0
      datetime -> max(DateTime.diff(datetime, DateTime.utc_now()), 0)
    end
  end

  # The hook is handed an absolute instant, not a duration: a slow render or a backgrounded tab
  # would otherwise drift the clock.
  defp deadline(nil, seconds) when is_integer(seconds) do
    DateTime.utc_now() |> DateTime.add(max(seconds, 0)) |> DateTime.to_unix(:millisecond)
  end

  defp deadline(nil, _), do: nil

  defp deadline(target, _seconds) do
    case to_datetime(target) do
      nil -> nil
      datetime -> DateTime.to_unix(datetime, :millisecond)
    end
  end

  defp to_datetime(%DateTime{} = datetime), do: datetime
  defp to_datetime(%NaiveDateTime{} = naive), do: DateTime.from_naive!(naive, "Etc/UTC")

  defp to_datetime(target) when is_binary(target) do
    case DateTime.from_iso8601(target) do
      {:ok, datetime, _offset} -> datetime
      _ -> nil
    end
  end

  defp to_datetime(_), do: nil
end
