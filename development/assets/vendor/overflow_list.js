// OverflowList — show as many items as fit on one row and collapse the rest into a "+N" counter.
//
// A `ResizeObserver` re-runs the layout whenever the container resizes. Items that don't fit get
// `data-hidden` (hide them with CSS); the counter element is revealed and its `[data-part=
// "counter-value"]` is set to the number hidden. At least `data-min-visible` items are always kept.
// If `data-on-change` names an event, the hidden count is pushed to the server when it changes.
//
// Element contract:
//   root                          — carries the hook; data-min-visible, data-on-change
//   [data-part="item"]            — each list item (order = priority)
//   [data-part="counter"]         — the "+N" element (gets data-hidden when nothing overflows)
//   [data-part="counter-value"]   — optional; receives the hidden count as text

const OverflowList = {
  mounted() {
    this.min = parseInt(this.el.getAttribute("data-min-visible") || "1", 10);
    this.on = this.el.getAttribute("data-on-change");
    this.counter = this.el.querySelector('[data-part="counter"]');
    this.counterValue = this.el.querySelector('[data-part="counter-value"]');
    this._ro = new ResizeObserver(() => this.layout());
    this._ro.observe(this.el);
    this.layout();
  },

  items() {
    return Array.from(this.el.querySelectorAll('[data-part="item"]'));
  },

  gap() {
    const s = getComputedStyle(this.el);
    return parseFloat(s.columnGap || s.gap || "0") || 0;
  },

  layout() {
    const items = this.items();
    if (!items.length) return;

    const gap = this.gap();

    // Reveal everything so we can measure natural widths.
    items.forEach((it) => it.removeAttribute("data-hidden"));
    if (this.counter) this.counter.removeAttribute("data-hidden");

    const avail = this.el.clientWidth;
    const widths = items.map((it) => it.offsetWidth);
    const counterW = this.counter ? this.counter.offsetWidth : 0;

    // Does everything fit without a counter?
    let sumAll = 0;
    widths.forEach((w, i) => (sumAll += w + (i ? gap : 0)));
    if (sumAll <= avail) {
      if (this.counter) this.counter.setAttribute("data-hidden", "");
      this.report(0);
      return;
    }

    // Otherwise reserve room for the counter and fit what we can.
    let used = 0;
    let visible = 0;
    for (let i = 0; i < items.length; i++) {
      const next = used + (visible ? gap : 0) + widths[i];
      if (next + gap + counterW <= avail || visible < this.min) {
        used = next;
        visible++;
      } else {
        break;
      }
    }
    visible = Math.max(Math.min(this.min, items.length), visible);

    const hidden = items.length - visible;
    items.forEach((it, i) => {
      if (i < visible) it.removeAttribute("data-hidden");
      else it.setAttribute("data-hidden", "");
    });

    if (this.counter) {
      if (hidden > 0) this.counter.removeAttribute("data-hidden");
      else this.counter.setAttribute("data-hidden", "");
    }
    if (this.counterValue) this.counterValue.textContent = String(hidden);
    this.report(hidden);
  },

  report(hidden) {
    if (this._last === hidden) return;
    this._last = hidden;
    if (this.on) this.pushEventTo(this.el, this.on, { hidden });
  },

  updated() {
    this.layout();
  },

  destroyed() {
    if (this._ro) this._ro.disconnect();
  },
};

export default OverflowList;
