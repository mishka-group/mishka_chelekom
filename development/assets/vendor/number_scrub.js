// NumberScrub — headless number-field (spinbutton) engine.
//
// Increment/decrement buttons (`[data-part="increment"]`/`[data-part="decrement"]`), Arrow
// Up/Down on the input, PageUp/Down for ±10·step, and click-drag on the input to scrub the
// value. Respects `min`/`max`/`step` from the input element. ARIA: input gets
// `role="spinbutton"` + `aria-valuemin/max/now`.

const NumberScrub = {
  mounted() {
    this.input = this.el.querySelector('[data-part="input"]') || this.el.querySelector("input");
    this.inc = this.el.querySelector('[data-part="increment"]');
    this.dec = this.el.querySelector('[data-part="decrement"]');

    if (!this.input) return;

    this.step = parseFloat(this.input.step) || 1;
    this.min = this.input.min !== "" ? parseFloat(this.input.min) : -Infinity;
    this.max = this.input.max !== "" ? parseFloat(this.input.max) : Infinity;

    this.input.setAttribute("role", "spinbutton");
    this.syncAria();

    this.inc && this.inc.addEventListener("click", () => this.bump(this.step));
    this.dec && this.dec.addEventListener("click", () => this.bump(-this.step));
    this.input.addEventListener("keydown", (e) => this.onKey(e));
    this.input.addEventListener("input", () => this.syncAria());
    this.input.addEventListener("pointerdown", (e) => this.startScrub(e));
  },

  current() {
    const v = parseFloat(this.input.value);
    return Number.isNaN(v) ? 0 : v;
  },

  bump(delta) {
    const v = Math.min(this.max, Math.max(this.min, this.current() + delta));
    this.input.value = String(Number(v.toFixed(6)));
    this.syncAria();
    this.input.dispatchEvent(new Event("input", { bubbles: true }));
  },

  onKey(e) {
    if (e.key === "ArrowUp") (e.preventDefault(), this.bump(this.step));
    else if (e.key === "ArrowDown") (e.preventDefault(), this.bump(-this.step));
    else if (e.key === "PageUp") (e.preventDefault(), this.bump(this.step * 10));
    else if (e.key === "PageDown") (e.preventDefault(), this.bump(this.step * -10));
  },

  startScrub(e) {
    const startX = e.clientX;
    const startVal = this.current();
    const move = (ev) => {
      const delta = Math.round((ev.clientX - startX) / 4) * this.step;
      const v = Math.min(this.max, Math.max(this.min, startVal + delta));
      this.input.value = String(Number(v.toFixed(6)));
      this.syncAria();
    };
    const up = () => {
      document.removeEventListener("pointermove", move);
      document.removeEventListener("pointerup", up);
    };
    document.addEventListener("pointermove", move);
    document.addEventListener("pointerup", up);
  },

  syncAria() {
    if (this.min !== -Infinity) this.input.setAttribute("aria-valuemin", String(this.min));
    if (this.max !== Infinity) this.input.setAttribute("aria-valuemax", String(this.max));
    this.input.setAttribute("aria-valuenow", String(this.current()));
  },
};

export default NumberScrub;
