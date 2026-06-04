// Slider — headless single-thumb slider engine.
//
// Pointer drag on the track + keyboard on the thumb (Arrow ±step, PageUp/Down ±10·step,
// Home/End → min/max). ARIA: thumb `role="slider"`, `aria-valuemin/max/now`. The resolved
// position is exposed as `--chelekom-slider` (0–1) on the root for CSS, and synced to a hidden
// `[data-part="input"]` for form submission.
//
// Config (data-* on the root): `data-min`, `data-max`, `data-step`, `data-value`.

const Slider = {
  mounted() {
    this.track = this.el.querySelector('[data-part="track"]') || this.el;
    this.thumb = this.el.querySelector('[data-part="thumb"]');
    this.input = this.el.querySelector('[data-part="input"]');

    this.min = parseFloat(this.el.getAttribute("data-min") ?? "0");
    this.max = parseFloat(this.el.getAttribute("data-max") ?? "100");
    this.step = parseFloat(this.el.getAttribute("data-step") ?? "1");
    this.value = parseFloat(this.el.getAttribute("data-value") ?? String(this.min));

    if (this.thumb) {
      this.thumb.setAttribute("role", "slider");
      this.thumb.setAttribute("aria-valuemin", String(this.min));
      this.thumb.setAttribute("aria-valuemax", String(this.max));
      this.thumb.setAttribute("tabindex", "0");
      this.thumb.addEventListener("keydown", (e) => this.onKey(e));
    }

    this.boundMove = (e) => this.onMove(e);
    this.boundUp = () => this.onUp();
    this.track.addEventListener("pointerdown", (e) => this.onDown(e));

    this.render();
  },

  onDown(e) {
    this.dragging = true;
    this.setFromPointer(e);
    document.addEventListener("pointermove", this.boundMove);
    document.addEventListener("pointerup", this.boundUp);
  },

  onMove(e) {
    if (this.dragging) this.setFromPointer(e);
  },

  onUp() {
    this.dragging = false;
    document.removeEventListener("pointermove", this.boundMove);
    document.removeEventListener("pointerup", this.boundUp);
  },

  setFromPointer(e) {
    const rect = this.track.getBoundingClientRect();
    const ratio = Math.min(1, Math.max(0, (e.clientX - rect.left) / rect.width));
    this.set(this.min + ratio * (this.max - this.min));
  },

  onKey(e) {
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
      this.set(this.value + map[e.key]);
    } else if (e.key === "Home") {
      e.preventDefault();
      this.set(this.min);
    } else if (e.key === "End") {
      e.preventDefault();
      this.set(this.max);
    }
  },

  set(raw) {
    const stepped = Math.round(raw / this.step) * this.step;
    this.value = Math.min(this.max, Math.max(this.min, stepped));
    this.render();
  },

  render() {
    const ratio = (this.value - this.min) / (this.max - this.min || 1);
    this.el.style.setProperty("--chelekom-slider", String(ratio));
    if (this.thumb) {
      this.thumb.setAttribute("aria-valuenow", String(this.value));
      this.thumb.style.left = `${ratio * 100}%`;
    }
    if (this.input) this.input.value = String(this.value);
  },
};

export default Slider;
