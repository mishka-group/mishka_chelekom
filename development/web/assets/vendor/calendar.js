// Calendar — move focus around a month grid.
//
// Everything else about this component is server-side: the weeks are `Date` arithmetic in Elixir,
// the selection lives in the LiveView, and the month pages with ordinary buttons. What a server
// cannot do is move focus, and a day grid is genuinely two-dimensional — so this is the whole hook.
//
// It never changes the selection and never re-lays the grid. Stepping off the edge of the month
// asks the server for the neighbouring one and remembers the date to land on, so focus continues
// where the keys were taking it rather than jumping to the first of the month.

const DAY = 86400000;

const Calendar = {
  mounted() {
    this.onKeydown = (event) => this.handleKey(event);
    this.el.addEventListener("keydown", this.onKeydown);
    this.restoreFocus();
  },

  updated() {
    // A month change re-renders the grid, so the day that was being navigated to only exists now.
    this.restoreFocus();
  },

  destroyed() {
    this.el.removeEventListener("keydown", this.onKeydown);
  },

  days() {
    return Array.from(this.el.querySelectorAll('[data-part="day"]'));
  },

  dayFor(iso) {
    return this.el.querySelector(`[data-part="day"][data-date="${iso}"]`);
  },

  iso(date) {
    return new Date(date).toISOString().slice(0, 10);
  },

  handleKey(event) {
    const day = event.target.closest('[data-part="day"]');
    if (!day) return;

    const from = Date.parse(day.getAttribute("data-date"));
    if (Number.isNaN(from)) return;

    const step = {
      ArrowLeft: -DAY,
      ArrowRight: DAY,
      ArrowUp: -7 * DAY,
      ArrowDown: 7 * DAY,
    }[event.key];

    let target = null;

    if (step) {
      target = from + step;
    } else if (event.key === "Home") {
      target = this.weekEdge(day, "first");
    } else if (event.key === "End") {
      target = this.weekEdge(day, "last");
    } else if (event.key === "PageUp" || event.key === "PageDown") {
      target = this.shiftMonth(from, event.key === "PageUp" ? -1 : 1);
    } else {
      return;
    }

    event.preventDefault();
    if (target !== null) this.focusDate(this.iso(target));
  },

  // Home/End are the ends of the *row*, which the grid already knows — no date maths needed.
  weekEdge(day, which) {
    const row = day.closest('[data-part="week"]');
    if (!row) return null;

    const cells = Array.from(row.querySelectorAll('[data-part="day"]'));
    const edge = which === "first" ? cells[0] : cells[cells.length - 1];
    return edge ? Date.parse(edge.getAttribute("data-date")) : null;
  },

  // Clamped, so 31 January page-down lands on 28/29 February rather than sliding into March.
  shiftMonth(from, offset) {
    const date = new Date(from);
    const day = date.getUTCDate();
    const target = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth() + offset, 1));
    const lastDay = new Date(
      Date.UTC(target.getUTCFullYear(), target.getUTCMonth() + 1, 0)
    ).getUTCDate();

    target.setUTCDate(Math.min(day, lastDay));
    return target.getTime();
  },

  focusDate(iso) {
    const day = this.dayFor(iso);

    if (day) {
      this.roll(day);
      day.focus();
      return;
    }

    // The day is in a month that is not rendered. Ask for it, and remember where to land once it
    // arrives — otherwise the arrow key would silently do nothing at the edge of the grid.
    const event = this.el.getAttribute("data-on-month-change");
    if (!event) return;

    this.pending = iso;
    this.pushEventTo(this.el, event, { month: iso });
  },

  restoreFocus() {
    if (!this.pending) return;

    const day = this.dayFor(this.pending);
    this.pending = null;
    if (!day) return;

    this.roll(day);
    day.focus();
  },

  // One tab stop for the whole grid, so Tab leaves the calendar instead of walking 35 days.
  roll(target) {
    this.days().forEach((day) => day.setAttribute("tabindex", day === target ? "0" : "-1"));
  },
};

export default Calendar;
