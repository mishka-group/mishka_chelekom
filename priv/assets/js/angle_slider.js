// AngleSlider — a circular control for picking an angle 0–360° (Mantine AngleSlider parity).
//
// 0° points up and increases clockwise. Pointer drag (and arrow keys) set the angle; the thumb layer
// is rotated to place the handle on the circle and a `--angle` custom property is exposed for an
// optional conic-gradient fill. The value is mirrored into `[data-part="input"]` for form submission
// and, if `data-on-change` names an event, pushed to the server on release / key change.
//
// Element contract:
//   root                     — carries the hook; data-value, data-step, data-disabled, data-on-change
//   [data-part="thumb-layer"]— absolutely fills the root; rotated by the angle
//   [data-part="input"]      — optional hidden input to submit the value
//   [data-part="value"]      — optional element whose text becomes "<deg>°"

const norm = (deg) => ((deg % 360) + 360) % 360;

const AngleSlider = {
  mounted() {
    this.step = parseFloat(this.el.getAttribute("data-step")) || 1;
    this.on = this.el.getAttribute("data-on-change");
    this.layer = this.el.querySelector('[data-part="thumb-layer"]');
    this.input = this.el.querySelector('[data-part="input"]');
    this.valueEl = this.el.querySelector('[data-part="value"]');

    this._value = this.readValue();
    this.render();

    this._onDown = (e) => {
      if (this.isDisabled()) return;
      e.preventDefault();
      this.el.focus();
      this.dragging = true;
      this.el.setAttribute("data-dragging", "");
      this.moveTo(e);
      window.addEventListener("pointermove", this._onMove);
      window.addEventListener("pointerup", this._onUp);
    };
    this._onMove = (e) => {
      if (this.dragging) this.moveTo(e);
    };
    this._onUp = () => {
      this.dragging = false;
      this.el.removeAttribute("data-dragging");
      window.removeEventListener("pointermove", this._onMove);
      window.removeEventListener("pointerup", this._onUp);
      this.commit();
    };
    this._onKey = (e) => this.onKey(e);

    this.el.addEventListener("pointerdown", this._onDown);
    this.el.addEventListener("keydown", this._onKey);
  },

  isDisabled() {
    return this.el.hasAttribute("data-disabled");
  },

  readValue() {
    const v = parseFloat(this.el.getAttribute("data-value"));
    return isNaN(v) ? 0 : norm(v);
  },

  snap(deg) {
    const s = Math.round(norm(deg) / this.step) * this.step;
    return norm(s);
  },

  moveTo(e) {
    const rect = this.el.getBoundingClientRect();
    const dx = e.clientX - (rect.left + rect.width / 2);
    const dy = e.clientY - (rect.top + rect.height / 2);
    // atan2(dx, -dy): 0° at top, positive clockwise.
    this._value = this.snap(Math.atan2(dx, -dy) * (180 / Math.PI));
    this.render();
  },

  onKey(e) {
    if (this.isDisabled()) return;
    let d = 0;
    switch (e.key) {
      case "ArrowRight":
      case "ArrowUp":
        d = this.step;
        break;
      case "ArrowLeft":
      case "ArrowDown":
        d = -this.step;
        break;
      case "Home":
        e.preventDefault();
        this._value = 0;
        this.render();
        this.commit();
        return;
      case "End":
        e.preventDefault();
        this._value = norm(360 - this.step);
        this.render();
        this.commit();
        return;
      default:
        return;
    }
    e.preventDefault();
    this._value = norm(this._value + d);
    this.render();
    this.commit();
  },

  render() {
    const deg = this._value;
    if (this.layer) this.layer.style.transform = `rotate(${deg}deg)`;
    this.el.style.setProperty("--angle", `${deg}deg`);
    this.el.setAttribute("data-value", String(deg));
    this.el.setAttribute("aria-valuenow", String(Math.round(deg)));
    if (this.input) this.input.value = String(deg);
    if (this.valueEl) this.valueEl.textContent = `${Math.round(deg)}°`;
  },

  commit() {
    if (this.on) this.pushEventTo(this.el, this.on, { value: Math.round(this._value) });
  },

  updated() {
    if (this.dragging) return;
    this._value = this.readValue();
    this.render();
  },

  destroyed() {
    this.el.removeEventListener("pointerdown", this._onDown);
    this.el.removeEventListener("keydown", this._onKey);
    window.removeEventListener("pointermove", this._onMove);
    window.removeEventListener("pointerup", this._onUp);
  },
};

export default AngleSlider;
