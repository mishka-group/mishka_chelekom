// FloatingIndicator — a single highlight box that measures the active target and slides over it
// (Mantine FloatingIndicator parity).
//
// The active target is the one whose `data-value` matches the root's `data-active`. Clicking a target
// moves the indicator (and pushes `data-on-change` if set); the server can also drive it by changing
// `data-active`. A `ResizeObserver` keeps the indicator aligned when the container resizes.
//
// Element contract:
//   root                      — carries the hook; data-active, data-on-change; position: relative
//   [data-part="indicator"]   — the moving box (engine sets transform + width/height)
//   [data-part="target"]      — each option; must have data-value; gets data-active when selected

const FloatingIndicator = {
  mounted() {
    this.on = this.el.getAttribute("data-on-change");
    this.indicator = this.el.querySelector('[data-part="indicator"]');
    this.active = this.el.getAttribute("data-active");

    this._onClick = (e) => {
      const t = e.target.closest('[data-part="target"]');
      if (t && this.el.contains(t)) this.setActive(t.getAttribute("data-value"), true);
    };
    this.el.addEventListener("click", this._onClick);

    this._ro = new ResizeObserver(() => this.move());
    this._ro.observe(this.el);
    this.targets().forEach((t) => this._ro.observe(t));

    requestAnimationFrame(() => this.sync());
  },

  targets() {
    return Array.from(this.el.querySelectorAll('[data-part="target"]'));
  },

  activeTarget() {
    const ts = this.targets();
    return ts.find((t) => t.getAttribute("data-value") === this.active) || ts[0];
  },

  setActive(value, push) {
    if (value == null || value === this.active) return;
    this.active = value;
    this.sync();
    if (push && this.on) this.pushEventTo(this.el, this.on, { value });
  },

  sync() {
    const at = this.activeTarget();
    this.targets().forEach((t) => {
      const on = t === at;
      t.toggleAttribute("data-active", on);
      t.setAttribute("aria-pressed", on ? "true" : "false");
    });
    if (at) this.el.setAttribute("data-active", at.getAttribute("data-value"));
    this.move();
  },

  move() {
    const at = this.activeTarget();
    if (!at || !this.indicator) return;
    const p = this.el.getBoundingClientRect();
    const r = at.getBoundingClientRect();
    const x = r.left - p.left + this.el.scrollLeft;
    const y = r.top - p.top + this.el.scrollTop;
    this.indicator.style.transform = `translate(${x}px, ${y}px)`;
    this.indicator.style.width = `${r.width}px`;
    this.indicator.style.height = `${r.height}px`;
  },

  updated() {
    const a = this.el.getAttribute("data-active");
    if (a != null) this.active = a;
    this.sync();
  },

  destroyed() {
    this.el.removeEventListener("click", this._onClick);
    if (this._ro) this._ro.disconnect();
  },
};

export default FloatingIndicator;
