// Slider — headless single- or multi-thumb slider engine.
//
// One `[data-part="thumb"]` per value. Pointer drag on the track + keyboard on a thumb
// (Arrow ±step, PageUp/Down ±10·step, Home/End → min/max). Multiple thumbs are kept ordered
// (anti-cross). Each thumb is `role="slider"` with `aria-valuemin/max/now`. The `[data-part=
// "range"]` element spans the selected interval; `[data-part="value"]` shows the value(s); a
// hidden `[data-part="input"]` carries a comma-joined value for form submission. The latest
// ratio is exposed as `--chelekom-slider` on the root.
//
// Config (data-* on the root): `data-min`, `data-max`, `data-step`. Each thumb's start value
// comes from its `data-value`.

const Slider = {
  mounted() {
    this.track = this.el.querySelector('[data-part="track"]') || this.el;
    this.thumbs = Array.from(this.el.querySelectorAll('[data-part="thumb"]'));
    this.range = this.el.querySelector('[data-part="range"]');
    this.valueEl = this.el.querySelector('[data-part="value"]');
    this.input = this.el.querySelector('[data-part="input"]');

    this.min = parseFloat(this.el.getAttribute("data-min") ?? "0");
    this.max = parseFloat(this.el.getAttribute("data-max") ?? "100");
    this.step = parseFloat(this.el.getAttribute("data-step") ?? "1");
    this.values = this.thumbs.map((t) => parseFloat(t.getAttribute("data-value") ?? String(this.min)));

    this.thumbs.forEach((thumb, i) => {
      thumb.setAttribute("role", "slider");
      thumb.setAttribute("aria-valuemin", String(this.min));
      thumb.setAttribute("aria-valuemax", String(this.max));
      thumb.setAttribute("tabindex", "0");
      thumb.addEventListener("keydown", (e) => this.onKey(e, i));
      thumb.addEventListener("pointerdown", (e) => this.startDrag(e, i));
    });

    this.render();
  },

  startDrag(e, i) {
    e.preventDefault();
    this.thumbs[i].focus();
    const move = (ev) => this.setFromPointer(ev, i);
    const up = () => {
      document.removeEventListener("pointermove", move);
      document.removeEventListener("pointerup", up);
    };
    document.addEventListener("pointermove", move);
    document.addEventListener("pointerup", up);
    this.setFromPointer(e, i);
  },

  setFromPointer(e, i) {
    const rect = this.track.getBoundingClientRect();
    const ratio = Math.min(1, Math.max(0, (e.clientX - rect.left) / rect.width));
    this.set(i, this.min + ratio * (this.max - this.min));
  },

  onKey(e, i) {
    const big = this.step * 10;
    const map = {
      ArrowRight: this.step,
      ArrowUp: this.step,
      ArrowLeft: -this.step,
      ArrowDown: -this.step,
      PageUp: big,
      PageDown: -big,
    };
    if (e.key in map) {
      e.preventDefault();
      this.set(i, this.values[i] + map[e.key]);
    } else if (e.key === "Home") {
      e.preventDefault();
      this.set(i, this.min);
    } else if (e.key === "End") {
      e.preventDefault();
      this.set(i, this.max);
    }
  },

  set(i, raw) {
    let v = Math.min(this.max, Math.max(this.min, Math.round(raw / this.step) * this.step));
    // keep thumbs ordered (no crossing)
    const lo = i > 0 ? this.values[i - 1] : this.min;
    const hi = i < this.values.length - 1 ? this.values[i + 1] : this.max;
    this.values[i] = Math.min(hi, Math.max(lo, v));
    this.render();
  },

  ratio(v) {
    return (v - this.min) / (this.max - this.min || 1);
  },

  render() {
    this.thumbs.forEach((thumb, i) => {
      thumb.style.left = `${this.ratio(this.values[i]) * 100}%`;
      thumb.setAttribute("aria-valuenow", String(this.values[i]));
    });

    if (this.range && this.values.length) {
      const first = this.values.length > 1 ? this.ratio(this.values[0]) : 0;
      const last = this.ratio(this.values[this.values.length - 1]);
      this.range.style.left = `${first * 100}%`;
      this.range.style.width = `${(last - first) * 100}%`;
    }

    if (this.valueEl) this.valueEl.textContent = this.values.join(" – ");
    if (this.input) this.input.value = this.values.join(",");
    this.el.style.setProperty("--chelekom-slider", String(this.ratio(this.values[this.values.length - 1])));
  },
};

export default Slider;
