# calendar (headless)

An unstyled month date grid: server-rendered markup + ARIA wiring, with interaction (roving focus, selection, month navigation) delegated to the shared `DateGrid` JS engine. No formal WAI-ARIA APG pattern — it is a date-grid widget (`role="grid"`).

## Generate

```bash
mix mishka.ui.gen.headless calendar
```

Generates `lib/<app>_web/components/headless/calendar.ex`. Wire up the JS engine in `app.js`:

```js
import DateGrid from "./date_grid.js";
const Hooks = { DateGrid };
```

## Anatomy

The root is a `<div>` carrying `phx-hook="DateGrid"` and `class="chelekom-calendar"`. Parts are marked with `data-part` hooks the engine queries. The month (weekday headers, leading blanks, day buttons) is computed server-side from the `:month` and `:value` dates:

| Part | Element | `data-part` | Role | Class | Source |
|------|---------|-------------|------|-------|--------|
| root | `div` | — | — | `chelekom-calendar` | always rendered |
| input | `input[type=hidden]` | `input` | — | `chelekom-calendar__input` | rendered only when `:name` is set |
| header | `div` | `header` | — | `chelekom-calendar__header` | always rendered |
| prev | `button` | `prev` | — | `chelekom-calendar__prev` | always rendered (`aria-label="Previous month"`) |
| label | `div` | `label` | — | `chelekom-calendar__label` | always rendered (`aria-live="polite"`, shows `"%B %Y"`) |
| next | `button` | `next` | — | `chelekom-calendar__next` | always rendered (`aria-label="Next month"`) |
| grid | `div` | `grid` | `grid` | `chelekom-calendar__grid` | always rendered |
| weekdays | `div` | `weekdays` | `row` | `chelekom-calendar__weekdays` | always rendered |
| weekday | `div` | — | `columnheader` | `chelekom-calendar__weekday` | one per `Mon..Sun` |
| row | `div` | `row` | `row` | `chelekom-calendar__row` | always rendered |
| blank | `div` | `blank` | `gridcell` | `chelekom-calendar__blank` | leading offset cells (`aria-hidden="true"`) |
| day | `button` | `day` | `gridcell` | `chelekom-calendar__day` | one per day of month |

`DateGrid` queries `[data-part="input"]`, `[data-part="prev"]`, `[data-part="next"]`, and all `[data-part="day"]` cells (each carrying a `data-date` ISO value and a roving `tabindex`).

## ARIA & keyboard

Roles and aria attributes (wired by the template + engine):

- **grid** — `role="grid"`, `aria-labelledby={"#{@id}-label"}`.
- **weekdays row** — `role="row"`; each weekday is `role="columnheader"` with `aria-label`.
- **row** — `role="row"` holding the gridcells.
- **blank** — `role="gridcell"`, `aria-hidden="true"`.
- **day** — `role="gridcell"`, `aria-selected` (`"true"`/`"false"`), roving `tabindex` (`0` on the active cell, `-1` on the rest). On selection the engine sets `aria-selected="true"` on the chosen day and `"false"` on the others.
- **prev / next** — `aria-label="Previous month"` / `"Next month"`.
- **label** — `aria-live="polite"` so month changes are announced.

Roving focus: on mount/update the engine puts `tabindex="0"` on the selected day (`aria-selected="true"`), else today (`data-today`), else the first cell. Keyboard (handled by `DateGrid`, all default-prevented; disabled days are skipped):

- **ArrowLeft / ArrowRight** — ±1 day.
- **ArrowUp / ArrowDown** — ±1 week (±7 cells).
- **Home / End** — week start / week end.
- **PageUp / PageDown** — ±1 month (emits `chelekom:month`, no DOM move).
- **Enter / Space** — select the focused day.

The prev/next buttons and PageUp/PageDown emit a bubbling `chelekom:month` `CustomEvent` (`detail: { delta: -1 | 1 }`); the server listens and re-renders the new `:month`. Clicking a day also selects it.

## State

The engine works against `data-*` attributes; the day buttons are rendered server-side with their initial state and `DateGrid` toggles them on interaction:

- `data-date` — ISO 8601 date on each day (read by the engine, written into the hidden input on select).
- `data-selected` — present on the currently selected day; the engine adds/removes it across all days on `select()` (alongside `aria-selected`).
- `data-today` — present on today's cell (rendered server-side; used to seed initial focus).
- `data-disabled` — when present on a day, that cell is excluded from roving focus and selection (rendered server-side; the template does not emit it by default, but the engine and anatomy support it).

On select the engine also writes the chosen `data-date` into `[data-part="input"].value` for form submission. (Note: unlike the Base-UI-style components, the calendar has no paired `data-open`/`data-closed`.)

## Example

```heex
<.calendar id="due-date" name="due_date" month={@month} value={@value} />
```

Drive month navigation from the server by listening for the `chelekom:month` event and updating the `month` assign:

```heex
<.calendar
  id="due-date"
  name="due_date"
  month={@month}
  value={@value}
  phx-hook="DateGrid"
  class="rounded-md"
/>
```

Attrs (from the template): `id` (required, anchors aria relationships), `name` (renders the hidden form input when set), `month` (any `Date` within the month to render; day normalized to `1`; defaults to today), `value` (selected `Date` or `nil`), `class` (extra root classes), and `rest` (global). There are no slots — the grid is generated from `month`/`value`.

## Styling

This component ships **no** colors or spacing — only structural markup. Style it via the `chelekom-calendar*` classes (`chelekom-calendar`, `__input`, `__header`, `__prev`, `__label`, `__next`, `__grid`, `__weekdays`, `__weekday`, `__row`, `__blank`, `__day`) and the `data-*` state attributes, e.g.:

```css
.chelekom-calendar__day[data-today]    { /* highlight today */ }
.chelekom-calendar__day[data-selected] { /* selected styles */ }
.chelekom-calendar__day[data-disabled] { /* dimmed, not interactive */ }
.chelekom-calendar__day:focus-visible  { /* roving-focus ring */ }
```

Add your own classes to the root via the `class` attr.