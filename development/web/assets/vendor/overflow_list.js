// OverflowList — show as many items as fit on one row and collapse the rest into a "+N" counter.
//
// A `ResizeObserver` re-runs the layout when the container's width changes. Items that don't fit
// get `data-hidden` + `inert` (hide them with CSS; inert already removes them from the tab order
// and the accessibility tree, so fading them out is safe); the counter element is revealed and its
// `[data-part="counter-value"]` is set to the number hidden. At least `data-min-visible` items are
// always kept. If `data-on-change` names an event, the hidden count is pushed (debounced, so a
// drag-resize doesn't flood the server) when it changes.
//
// Why the hook applies state through `this.js()` and not plain setAttribute: attributes written
// via the JS-command engine are sticky — LiveView re-applies them after every DOM patch — so a
// server round-trip can never strip the hidden state and re-reveal the row mid-drag.
//
// Measuring happens once per content change (mount, changed items after a patch, font load),
// never on the resize path: natural widths are cached as fractions (getBoundingClientRect, not
// the rounded offsetWidth) and the counter is measured at its widest possible text ("+<total>"),
// so the layout decision can never feed back through its own output.
//
// Element contract:
//   root                          — carries the hook; data-min-visible, data-on-change
//   [data-part="item"]            — each list item (order = priority)
//   [data-part="counter"]         — the "+N" element (gets data-hidden when nothing overflows)
//   [data-part="counter-value"]   — optional; receives the hidden count as text

// How many items fit on one row of `avail` width, always reserving room for the counter when
// anything overflows. Pure — exercised directly by overflow_list.test.mjs.
export function fit({ widths, counterW, gap, avail, min }) {
  const n = widths.length;

  let sumAll = 0;
  widths.forEach((w, i) => (sumAll += w + (i ? gap : 0)));
  if (sumAll <= avail) return n;

  const reserve = counterW > 0 ? gap + counterW : 0;
  let used = 0;
  let visible = 0;
  for (let i = 0; i < n; i++) {
    const next = used + (visible ? gap : 0) + widths[i];
    if (next + reserve > avail) break;
    used = next;
    visible++;
  }

  return Math.max(Math.min(min, n), visible);
}

const OverflowList = {
  mounted() {
    this.min = parseInt(this.el.getAttribute("data-min-visible") || "1", 10);
    this.on = this.el.getAttribute("data-on-change");
    this.counter = this.el.querySelector('[data-part="counter"]');
    this.counterValue = this.el.querySelector('[data-part="counter-value"]');

    this.refresh();

    this._ro = new ResizeObserver(() => {
      if (this.el.clientWidth !== this._lastWidth) this.layout();
    });
    this._ro.observe(this.el);

    if (document.fonts && document.fonts.status !== "loaded") {
      document.fonts.ready.then(() => {
        if (!this._destroyed) this.refresh();
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

  signature() {
    return this.items()
      .map((it) => it.textContent)
      .join("\u0001");
  },

  refresh() {
    this._sig = this.signature();
    this.measure();
    this.layout();
  },

  // Reveal everything (synchronously — nothing paints mid-function) and cache natural widths,
  // with the counter at its widest text. Must be followed by layout(), which applies real state.
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
    const counterW = this.counter ? this.counter.getBoundingClientRect().width : 0;
    this._counterW = counterW > 0 ? counterW : this._counterW || 0;
  },

  layout() {
    const items = this.items();
    if (!items.length) return;
    this._lastWidth = this.el.clientWidth;
    const js = this.js();

    const visible = fit({
      widths: this._widths || [],
      counterW: this._counterW || 0,
      gap: this.gap(),
      avail: this.avail(),
      min: this.min,
    });

    const hidden = items.length - visible;
    items.forEach((it, i) => {
      if (i < visible) {
        js.removeAttribute(it, "data-hidden");
        js.removeAttribute(it, "inert");
      } else {
        js.setAttribute(it, "data-hidden", "");
        js.setAttribute(it, "inert", "");
      }
    });

    if (this.counter) {
      if (hidden > 0) js.removeAttribute(this.counter, "data-hidden");
      else js.setAttribute(this.counter, "data-hidden", "");
    }
    if (this.counterValue) this.counterValue.textContent = String(hidden);
    this.report(hidden);
  },

  report(hidden) {
    if (this._last === hidden) return;
    this._last = hidden;
    if (!this.on) return;
    clearTimeout(this._reportTimer);
    this._reportTimer = setTimeout(() => {
      if (!this._destroyed) this.pushEventTo(this.el, this.on, { hidden: this._last });
    }, 120);
  },

  updated() {
    // Sticky attributes already survived the patch; only the counter text (server renders "0")
    // needs restoring — and a full re-measure only when the items themselves changed.
    if (this.counterValue) this.counterValue.textContent = String(this._last || 0);
    if (this.signature() !== this._sig) this.refresh();
  },

  destroyed() {
    this._destroyed = true;
    clearTimeout(this._reportTimer);
    if (this._ro) this._ro.disconnect();
  },
};

export default OverflowList;
