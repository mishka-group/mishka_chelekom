// ColorPicker — saturation/value area + hue slider (Mantine ColorPicker parity).
//
// Anatomy: a 2D `[data-part="area"]` (drag to set saturation on X and value/brightness on Y, the
// `[data-part="area-thumb"]` follows), a native range `[data-part="hue"]` (0–360), a
// `[data-part="preview"]` swatch and a hidden `[data-part="input"]` that carries the hex value for
// forms. Emits `data-on-change` with `{value: "#rrggbb"}` and mirrors the value into the input's
// `input` event so `<.form phx-change>` fires.

function hsvToRgb(h, s, v) {
  s /= 100;
  v /= 100;
  const c = v * s;
  const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
  const m = v - c;
  let r = 0,
    g = 0,
    b = 0;
  if (h < 60) [r, g, b] = [c, x, 0];
  else if (h < 120) [r, g, b] = [x, c, 0];
  else if (h < 180) [r, g, b] = [0, c, x];
  else if (h < 240) [r, g, b] = [0, x, c];
  else if (h < 300) [r, g, b] = [x, 0, c];
  else [r, g, b] = [c, 0, x];
  return [Math.round((r + m) * 255), Math.round((g + m) * 255), Math.round((b + m) * 255)];
}

function toHex(r, g, b) {
  return "#" + [r, g, b].map((n) => n.toString(16).padStart(2, "0")).join("");
}

function hexToHsv(hex) {
  hex = (hex || "").replace("#", "");
  if (hex.length === 3)
    hex = hex
      .split("")
      .map((c) => c + c)
      .join("");
  if (hex.length !== 6) return { h: 217, s: 76, v: 96 };
  const r = parseInt(hex.slice(0, 2), 16) / 255;
  const g = parseInt(hex.slice(2, 4), 16) / 255;
  const b = parseInt(hex.slice(4, 6), 16) / 255;
  const max = Math.max(r, g, b),
    min = Math.min(r, g, b),
    d = max - min;
  let h = 0;
  if (d) {
    if (max === r) h = ((g - b) / d) % 6;
    else if (max === g) h = (b - r) / d + 2;
    else h = (r - g) / d + 4;
    h *= 60;
    if (h < 0) h += 360;
  }
  return { h, s: max ? (d / max) * 100 : 0, v: max * 100 };
}

const ColorPicker = {
  mounted() {
    const root = this.el;
    this.area = root.querySelector('[data-part="area"]');
    this.areaThumb = root.querySelector('[data-part="area-thumb"]');
    this.hueInput = root.querySelector('[data-part="hue"]');
    this.preview = root.querySelector('[data-part="preview"]');
    this.input = root.querySelector('[data-part="input"]');
    if (!this.area || !this.hueInput) return;

    const init = hexToHsv(root.getAttribute("data-value") || "#3b82f6");
    this.h = init.h;
    this.s = init.s;
    this.v = init.v;
    this.hueInput.value = String(Math.round(this.h));

    const clamp = (n) => Math.min(100, Math.max(0, n));

    this.fromArea = (e) => {
      const r = this.area.getBoundingClientRect();
      this.s = clamp(((e.clientX - r.left) / r.width) * 100);
      this.v = clamp(100 - ((e.clientY - r.top) / r.height) * 100);
      this.render();
    };

    const onMove = (e) => {
      this.fromArea(e);
      e.preventDefault();
    };
    const onUp = () => {
      root.removeAttribute("data-dragging");
      window.removeEventListener("pointermove", onMove);
      window.removeEventListener("pointerup", onUp);
    };
    this._areaDown = (e) => {
      root.setAttribute("data-dragging", "");
      this.fromArea(e);
      window.addEventListener("pointermove", onMove);
      window.addEventListener("pointerup", onUp);
      e.preventDefault();
    };
    this._hueInput = () => {
      this.h = Number(this.hueInput.value);
      this.render();
    };

    this.area.addEventListener("pointerdown", this._areaDown);
    this.hueInput.addEventListener("input", this._hueInput);
    this.render();
  },

  render() {
    this.area.style.background = `linear-gradient(to top, #000, rgba(0,0,0,0)), linear-gradient(to right, #fff, hsl(${this.h}, 100%, 50%))`;
    if (this.areaThumb) {
      this.areaThumb.style.position = "absolute";
      this.areaThumb.style.left = this.s + "%";
      this.areaThumb.style.top = 100 - this.v + "%";
      this.areaThumb.style.translate = "-50% -50%";
    }
    const [r, g, b] = hsvToRgb(this.h, this.s, this.v);
    const hex = toHex(r, g, b);
    if (this.preview) this.preview.style.background = hex;
    if (this.input && this.input.value !== hex) {
      this.input.value = hex;
      this.input.dispatchEvent(new Event("input", { bubbles: true }));
    }
    this.el.setAttribute("data-value", hex);
    const on = this.el.getAttribute("data-on-change");
    if (on) this.pushEventTo(this.el, on, { value: hex });
  },

  destroyed() {
    if (this.area) this.area.removeEventListener("pointerdown", this._areaDown);
    if (this.hueInput) this.hueInput.removeEventListener("input", this._hueInput);
  },
};

export default ColorPicker;
