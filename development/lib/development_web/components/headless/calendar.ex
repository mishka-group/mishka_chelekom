defmodule DevelopmentWeb.Components.Headless.Calendar do
  @moduledoc """
  Headless **calendar** — an unstyled month date grid.

  Behavior is delegated to the shared `DateGrid` JS engine: roving focus over the day
  cells (`[data-part="day"]`) with Arrow keys (±1 day / ±1 week), Home/End (week
  start/end), PageUp/PageDown and the prev/next buttons (±1 month, emitted as a
  `chelekom:month` event for the server to re-render), and Enter/Space to select. The
  selected ISO date is mirrored into a hidden `[data-part="input"]` for form submission.

  The month itself is computed server-side from the `:month` and `:value` dates using
  Elixir's `Date` helpers. Style via the `chelekom-calendar*` classes and the
  `data-open`/`data-closed`/`data-selected`/`data-today` state attributes — this
  component ships **no** colors or spacing.

  WAI-ARIA: no formal APG pattern (date-grid widget).
  """
  use Phoenix.Component

  @weekdays ~w(Mon Tue Wed Thu Fri Sat Sun)

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors aria relationships)"
  attr :name, :string, default: nil, doc: "Name for the hidden form input"

  attr :month, Date,
    default: nil,
    doc: "Any Date within the month to render (day is normalized to 1)"

  attr :value, Date, default: nil, doc: "Currently selected Date, or nil"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  def calendar(assigns) do
    today = Date.utc_today()
    month = (assigns[:month] || today) |> Map.put(:day, 1)

    assigns =
      assigns
      |> assign(:today, today)
      |> assign(:month, month)
      |> assign(:weekdays, @weekdays)
      |> assign(:leading, Date.day_of_week(month) - 1)
      |> assign(:days, Enum.map(1..Date.days_in_month(month), &Map.put(month, :day, &1)))

    ~H"""
    <div id={@id} phx-hook="DateGrid" class={["chelekom-calendar", @class]} {@rest}>
      <input
        :if={@name}
        type="hidden"
        data-part="input"
        name={@name}
        value={@value && Date.to_iso8601(@value)}
        class="chelekom-calendar__input"
      />

      <div data-part="header" class="chelekom-calendar__header">
        <button
          type="button"
          data-part="prev"
          aria-label="Previous month"
          class="chelekom-calendar__prev"
        >
          {"‹"}
        </button>
        <div data-part="label" aria-live="polite" class="chelekom-calendar__label">
          {Calendar.strftime(@month, "%B %Y")}
        </div>
        <button
          type="button"
          data-part="next"
          aria-label="Next month"
          class="chelekom-calendar__next"
        >
          {"›"}
        </button>
      </div>

      <div
        role="grid"
        data-part="grid"
        aria-labelledby={"#{@id}-label"}
        class="chelekom-calendar__grid"
      >
        <div role="row" data-part="weekdays" class="chelekom-calendar__weekdays">
          <div
            :for={wd <- @weekdays}
            role="columnheader"
            aria-label={wd}
            class="chelekom-calendar__weekday"
          >
            {wd}
          </div>
        </div>

        <div role="row" data-part="row" class="chelekom-calendar__row">
          <div
            :for={_ <- 1..@leading//1}
            role="gridcell"
            data-part="blank"
            aria-hidden="true"
            class="chelekom-calendar__blank"
          >
          </div>
          <button
            :for={d <- @days}
            type="button"
            role="gridcell"
            data-part="day"
            data-date={Date.to_iso8601(d)}
            data-today={d == @today}
            data-selected={d == @value}
            aria-selected={to_string(d == @value)}
            tabindex="-1"
            class="chelekom-calendar__day"
          >
            {d.day}
          </button>
        </div>
      </div>
    </div>
    """
  end
end
