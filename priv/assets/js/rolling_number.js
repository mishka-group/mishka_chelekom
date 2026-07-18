// RollingNumber — animate a number to a new value (Mantine RollingNumber parity).
//
// On mount it rolls from 0 up to `data-value`; whenever LiveView re-renders with a new `data-value`
// it animates from the current value to the new one (requestAnimationFrame, ease-out). `data-duration`
// (ms, default 800) sets the speed and `data-locale` the thousands grouping. Respects
// `prefers-reduced-motion` by jumping straight to the value.

const RollingNumber = {
  mounted() {
    this.current = 0;
    this.animateTo(this.target());
  },

  updated() {
    this.animateTo(this.target());
  },

  target() {
    return Number(this.el.getAttribute("data-value")) || 0;
  },

  format(n) {
    const locale = this.el.getAttribute("data-locale") || undefined;
    return Math.round(n).toLocaleString(locale);
  },

  animateTo(target) {
    const from = this.current;
    if (from === target) {
      this.el.textContent = this.format(target);
      return;
    }

    const reduce =
      window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const dur = reduce ? 0 : Number(this.el.getAttribute("data-duration")) || 800;

    if (dur <= 0) {
      this.current = target;
      this.el.textContent = this.format(target);
      return;
    }

    const start = performance.now();
    cancelAnimationFrame(this._raf);

    const tick = (now) => {
      const t = Math.min(1, (now - start) / dur);
      const eased = 1 - Math.pow(1 - t, 3);
      const val = from + (target - from) * eased;
      this.el.textContent = this.format(val);
      if (t < 1) {
        this._raf = requestAnimationFrame(tick);
      } else {
        this.current = target;
        this.el.textContent = this.format(target);
      }
    };

    this._raf = requestAnimationFrame(tick);
  },

  destroyed() {
    cancelAnimationFrame(this._raf);
  },
};

export default RollingNumber;
