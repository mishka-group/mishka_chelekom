// DateGrid — headless calendar grid engine.
//
// Roving focus over day cells (`[data-part="day"]`, each with a `data-date` ISO value and a
// roving `tabindex`): Left/Right ±1 day, Up/Down ±1 week, Home/End → week start/end,
// PageUp/Down → ±1 month (delegated to the host via a `chelekom:month` event so the server can
// re-render). Enter/Space selects: toggles `aria-selected` + `data-selected` and writes the
// ISO date to a hidden `[data-part="input"]`. Disabled days (`data-disabled`) are skipped.
//
// The month grid itself is rendered server-side; this engine only handles interaction.

const DateGrid = {
  mounted() {
    this.input = this.el.querySelector('[data-part="input"]');
    this.boundKey = (e) => this.onKey(e);
    this.refresh();
    this.el.addEventListener("keydown", this.boundKey);

    const prev = this.el.querySelector('[data-part="prev"]');
    const next = this.el.querySelector('[data-part="next"]');
    prev && prev.addEventListener("click", () => this.emitMonth(-1));
    next && next.addEventListener("click", () => this.emitMonth(1));
  },

  updated() {
    this.refresh();
  },

  destroyed() {
    this.el.removeEventListener("keydown", this.boundKey);
  },

  refresh() {
    this.days = Array.from(this.el.querySelectorAll('[data-part="day"]')).filter(
      (d) => !d.hasAttribute("data-disabled")
    );
    let active = this.days.findIndex(
      (d) => d.getAttribute("aria-selected") === "true" || d.hasAttribute("data-today")
    );
    if (active < 0) active = 0;
    this.days.forEach((d, i) => {
      d.setAttribute("tabindex", i === active ? "0" : "-1");
      if (!d._dgBound) {
        d.addEventListener("click", () => this.select(d));
        d._dgBound = true;
      }
    });
  },

  onKey(e) {
    const idx = this.days.indexOf(document.activeElement);
    if (idx < 0) return;
    const moves = { ArrowRight: 1, ArrowLeft: -1, ArrowDown: 7, ArrowUp: -7 };
    let target = null;

    if (e.key in moves) target = this.days[idx + moves[e.key]];
    else if (e.key === "Home") target = this.days[idx - (idx % 7)];
    else if (e.key === "End") target = this.days[Math.min(this.days.length - 1, idx - (idx % 7) + 6)];
    else if (e.key === "PageUp") return (e.preventDefault(), this.emitMonth(-1));
    else if (e.key === "PageDown") return (e.preventDefault(), this.emitMonth(1));
    else if (e.key === "Enter" || e.key === " ") return (e.preventDefault(), this.select(this.days[idx]));
    else return;

    e.preventDefault();
    if (target) {
      this.days.forEach((d) => d.setAttribute("tabindex", "-1"));
      target.setAttribute("tabindex", "0");
      target.focus();
    }
  },

  select(day) {
    if (!day) return;
    this.days.forEach((d) => {
      const sel = d === day;
      d.setAttribute("aria-selected", String(sel));
      d.toggleAttribute("data-selected", sel);
    });
    if (this.input) this.input.value = day.getAttribute("data-date") || "";
  },

  emitMonth(delta) {
    this.el.dispatchEvent(
      new CustomEvent("chelekom:month", { bubbles: true, detail: { delta } })
    );
  },
};

export default DateGrid;
