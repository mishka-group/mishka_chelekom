// OverflowList — show as many items as fit on one row and collapse the rest into a "+N" counter.
//
// A `ResizeObserver` re-runs the layout when the container's width changes. Items that don't fit
// get `data-hidden` + `inert` (hide them with CSS; inert already removes them from the tab order
// and the accessibility tree, so fading them out is safe); the counter element is revealed and its
// `[data-part="counter-value"]` is set to the number hidden. At least `data-min-visible` items are
// always kept. If `data-on-change` names an event, the hidden count is pushed when it changes.
//
// Measuring happens once per content change (mount, LiveView patch, font load), never on the
// resize path: natural widths are cached as fractions (getBoundingClientRect, not the rounded
// offsetWidth) and the counter is measured at its widest possible text ("+<total>"), so the layout
// decision can never feed back through its own output — no show/hide thrash while dragging, and no
// off-by-a-few-pixels overflow past the clip edge.
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

    this.measure();
    this.layout();

    this._ro = new ResizeObserver(() => {
      if (this.el.clientWidth !== this._lastWidth) this.layout();
    });
    this._ro.observe(this.el);

    if (document.fonts && document.fonts.status !== "loaded") {
      document.fonts.ready.then(() => {
        if (this._destroyed) return;
        this.measure();
        this.layout();
      });
    }
  },

  items() {
    return Array.from(this.el.querySelectorAll('[data-part="item"]'));
  },

  gap() {
    const s = getComputedStyle(this.el);
    return parseFloat(s.columnGap || s.gap || "0") || 0;
  },

  avail() {
    const s = getComputedStyle(this.el);
    return (
      this.el.clientWidth -
      (parseFloat(s.paddingLeft) || 0) -
      (parseFloat(s.paddingRight) || 0)
    );
  },

  // Reveal everything (synchronously — nothing paints mid-function), cache the natural widths,
  // and measure the counter at its widest text. layout() runs right after and re-applies state.
  measure() {
    const items = this.items();
    items.forEach((it) => {
      it.removeAttribute("data-hidden");
      it.removeAttribute("inert");
    });
    if (this.counter) {
      this.counter.removeAttribute("data-hidden");
      if (this.counterValue) this.counterValue.textContent = String(items.length);
    }
    this._widths = items.map((it) => it.getBoundingClientRect().width);
    this._counterW = this.counter ? this.counter.getBoundingClientRect().width : 0;
  },

  layout() {
    const items = this.items();
    if (!items.length) return;
    this._lastWidth = this.el.clientWidth;

    const gap = this.gap();
    const avail = this.avail();
    const widths = this._widths || [];
    const counterW = this._counterW || 0;

    let sumAll = 0;
    widths.forEach((w, i) => (sumAll += w + (i ? gap : 0)));

    let visible;
    if (sumAll <= avail) {
      visible = items.length;
    } else {
      let used = 0;
      visible = 0;
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
    }

    const hidden = items.length - visible;
    items.forEach((it, i) => {
      if (i < visible) {
        it.removeAttribute("data-hidden");
        it.removeAttribute("inert");
      } else {
        it.setAttribute("data-hidden", "");
        it.setAttribute("inert", "");
      }
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
    this.measure();
    this.layout();
  },

  destroyed() {
    this._destroyed = true;
    if (this._ro) this._ro.disconnect();
  },
};

export default OverflowList;
