// Slider — headless single- or multi-thumb slider engine (Base UI parity).
//
// Anatomy: a `[data-part="control"]` holds a `[data-part="track"]` containing a
// `[data-part="indicator"]` (the filled interval) and one `[data-part="thumb"]` (role=slider) per
// value. Pointer drag on the control + keyboard on a thumb: Arrow ±step (Up/Right increase),
// Shift+Arrow / PageUp/Down ±largeStep, Home/End → min/max. Range thumbs keep `minStepsBetweenValues`
// apart and obey `data-collision` (push | swap | none). Vertical via `data-orientation="vertical"`.
//
// Reflects Base UI data-attributes: `data-orientation` (all parts), `data-dragging` (root/control/
// thumb while dragging), `data-disabled`, thumb `data-index`. Each thumb is role=slider with
// `aria-valuemin/max/now`, `aria-valuetext` (Intl-formatted via `data-format`/`data-locale`) and
// `aria-orientation`. The value(s) mirror into hidden inputs (single → `name`, range → `name[]`) with
// a bubbling `input` (so `<.form phx-change>` fires); `data-on-change` (`{value}`) and `data-on-commit`
// (`{value}`) push to LiveView. The latest ratio is exposed as `--chelekom-slider` on the root.

const Slider = {
  mounted() {
    const el = this.el;
    this.control = el.querySelector('[data-part="control"]') || el.querySelector('[data-part="track"]') || el;
    this.track = el.querySelector('[data-part="track"]') || this.control;
    this.indicator = el.querySelector('[data-part="indicator"]');
    this.thumbs = Array.from(el.querySelectorAll('[data-part="thumb"]'));
    this.valueEl = el.querySelector('[data-part="value"]');

    const num = (a, d) => (el.getAttribute(a) != null ? parseFloat(el.getAttribute(a)) : d);
    this.min = num("data-min", 0);
    this.max = num("data-max", 100);
    this.step = num("data-step", 1) || 1;
    this.largeStep = num("data-large-step", 10) || 10;
    this.minSteps = num("data-min-steps", 0);
    this.vertical = el.getAttribute("data-orientation") === "vertical";
    this.disabled = el.hasAttribute("data-disabled");
    this.collision = el.getAttribute("data-collision") || "push";
    this.name = el.getAttribute("data-name");
    this.onChange = el.getAttribute("data-on-change");
    this.onCommit = el.getAttribute("data-on-commit");
    this.locale = el.getAttribute("data-locale") || undefined;
    try {
      this.format = el.getAttribute("data-format") ? JSON.parse(el.getAttribute("data-format")) : undefined;
    } catch {
      this.format = undefined;
    }

    this.values = this.thumbs.map((t) => parseFloat(t.getAttribute("data-value") ?? String(this.min)));

    this.thumbs.forEach((thumb, i) => {
      thumb.setAttribute("role", "slider");
      thumb.setAttribute("aria-valuemin", String(this.min));
      thumb.setAttribute("aria-valuemax", String(this.max));
      thumb.setAttribute("aria-orientation", this.vertical ? "vertical" : "horizontal");
      thumb.setAttribute("data-index", String(i));
      thumb.setAttribute("tabindex", this.disabled ? "-1" : "0");
      if (!this.disabled) {
        thumb.addEventListener("keydown", (e) => this.onKey(e, i));
        thumb.addEventListener("keyup", () => this.commit());
        thumb.addEventListener("pointerdown", (e) => {
          e.stopPropagation();
          this.startDrag(e, i);
        });
      }
    });

    // Pressing the track jumps the nearest thumb to the pointer, then drags it.
    if (!this.disabled) this.control.addEventListener("pointerdown", (e) => this.onTrackPress(e));

    this.render();
  },

  fmt(v) {
    try {
      return new Intl.NumberFormat(this.locale, this.format).format(v);
    } catch {
      return String(v);
    }
  },

  // ---- pointer --------------------------------------------------------------

  ratioFromPointer(e) {
    const r = this.control.getBoundingClientRect();
    const ratio = this.vertical
      ? (r.bottom - e.clientY) / r.height // bottom = min, top = max
      : (e.clientX - r.left) / r.width;
    return Math.min(1, Math.max(0, ratio));
  },

  nearestThumb(value) {
    let best = 0;
    let bestD = Infinity;
    this.values.forEach((v, i) => {
      const d = Math.abs(v - value);
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    });
    return best;
  },

  onTrackPress(e) {
    if (this.disabled) return;
    const value = this.min + this.ratioFromPointer(e) * (this.max - this.min);
    const i = this.nearestThumb(value);
    this.thumbs[i].focus();
    this.set(i, value, "track-press");
    this.startDrag(e, i);
  },

  startDrag(e, i) {
    e.preventDefault();
    const thumb = this.thumbs[i];
    thumb.focus();
    this.setDragging(thumb, true);
    // Capture the pointer so the drag keeps tracking outside the element, and lock the cursor to
    // "grabbing" for the whole gesture — otherwise it flickers (grab ↔ default) as the moving thumb
    // slides out from under the physical pointer.
    try {
      thumb.setPointerCapture(e.pointerId);
    } catch {}
    const prevCursor = document.body.style.cursor;
    const prevSelect = document.body.style.userSelect;
    document.body.style.cursor = "grabbing";
    document.body.style.userSelect = "none";
    const move = (ev) => {
      const value = this.min + this.ratioFromPointer(ev) * (this.max - this.min);
      this.set(i, value, "drag");
    };
    const up = () => {
      document.removeEventListener("pointermove", move);
      document.removeEventListener("pointerup", up);
      this.setDragging(thumb, false);
      document.body.style.cursor = prevCursor;
      document.body.style.userSelect = prevSelect;
      try {
        thumb.releasePointerCapture(e.pointerId);
      } catch {}
      this.commit();
    };
    document.addEventListener("pointermove", move);
    document.addEventListener("pointerup", up);
  },

  setDragging(thumb, on) {
    [this.el, this.control, thumb].forEach((n) => n && n.toggleAttribute("data-dragging", on));
  },

  // ---- keyboard -------------------------------------------------------------

  onKey(e, i) {
    if (this.disabled) return;
    const inc = e.shiftKey ? this.largeStep : this.step;
    // Up/Right increase, Down/Left decrease (works for both orientations).
    const map = {
      ArrowRight: inc,
      ArrowUp: inc,
      ArrowLeft: -inc,
      ArrowDown: -inc,
      PageUp: this.largeStep,
      PageDown: -this.largeStep,
    };
    if (e.key in map) {
      e.preventDefault();
      this.set(i, this.values[i] + map[e.key], "keyboard");
    } else if (e.key === "Home") {
      e.preventDefault();
      this.set(i, this.min, "keyboard");
    } else if (e.key === "End") {
      e.preventDefault();
      this.set(i, this.max, "keyboard");
    }
  },

  // ---- value mutation (step / clamp / collision) ----------------------------

  snap(raw) {
    const v = this.min + Math.round((raw - this.min) / this.step) * this.step;
    return Math.min(this.max, Math.max(this.min, parseFloat(v.toFixed(6))));
  },

  set(i, raw, reason) {
    const gap = this.minSteps * this.step;
    let v = this.snap(raw);
    const n = this.values.length;

    if (n === 1) {
      this.values[0] = v;
    } else if (this.collision === "none") {
      const lo = i > 0 ? this.values[i - 1] + gap : this.min;
      const hi = i < n - 1 ? this.values[i + 1] - gap : this.max;
      this.values[i] = Math.min(hi, Math.max(lo, v));
    } else if (this.collision === "swap") {
      this.values[i] = v;
      // re-sort and follow the dragged value's new index
      const order = this.values.map((val, idx) => ({ val, idx })).sort((a, b) => a.val - b.val);
      this.values = order.map((o) => o.val);
      this._activeIndex = order.findIndex((o) => o.idx === i);
    } else {
      // push (default): move neighbors out of the way, cascading, clamped to min/max.
      this.values[i] = v;
      for (let j = i + 1; j < n; j++) {
        if (this.values[j] < this.values[j - 1] + gap) this.values[j] = Math.min(this.max, this.values[j - 1] + gap);
      }
      for (let j = i - 1; j >= 0; j--) {
        if (this.values[j] > this.values[j + 1] - gap) this.values[j] = Math.max(this.min, this.values[j + 1] - gap);
      }
      // if pushing hit a wall, clamp the dragged thumb back
      const lo = i > 0 ? this.values[i - 1] + gap : this.min;
      const hi = i < n - 1 ? this.values[i + 1] - gap : this.max;
      this.values[i] = Math.min(hi, Math.max(lo, this.values[i]));
    }

    this.render();
    if (this.onChange) this.pushEvent(this.onChange, { value: n === 1 ? this.values[0] : this.values.slice() });
  },

  commit() {
    // Notify any enclosing <.form phx-change> at interaction-end (not per drag-pixel): the hidden
    // inputs are set programmatically every render, but we only dispatch the event on commit.
    const anyInput = this.el.querySelector('[data-part="input"]');
    if (anyInput) anyInput.dispatchEvent(new Event("input", { bubbles: true }));
    if (this.onCommit) this.pushEvent(this.onCommit, { value: this.values.length === 1 ? this.values[0] : this.values.slice() });
  },

  // ---- render ---------------------------------------------------------------

  ratio(v) {
    return (v - this.min) / (this.max - this.min || 1);
  },

  render() {
    // The engine owns LAYOUT (mirrors Base UI's SliderThumb/SliderIndicator); the consumer's CSS owns
    // only APPEARANCE. Thumb: anchor the value edge (bottom for vertical, left for horizontal), center
    // the cross axis at 50%, and translate by half so the thumb's centre sits on the track.
    this.thumbs.forEach((thumb, i) => {
      const pct = this.ratio(this.values[i]) * 100;
      thumb.style.position = "absolute";
      if (this.vertical) {
        thumb.style.bottom = `${pct}%`;
        thumb.style.left = "50%";
        thumb.style.top = "";
        thumb.style.translate = "-50% 50%";
      } else {
        thumb.style.left = `${pct}%`;
        thumb.style.top = "50%";
        thumb.style.bottom = "";
        thumb.style.translate = "-50% -50%";
      }
      thumb.setAttribute("aria-valuenow", String(this.values[i]));
      thumb.setAttribute("aria-valuetext", this.fmt(this.values[i]));
      const input = thumb.querySelector('[data-part="input"]');
      if (input && input.value !== String(this.values[i])) input.value = String(this.values[i]);
    });

    if (this.indicator && this.values.length) {
      // The filled bar spans `first`%→`last`%; the cross axis inherits the track size (so it's exactly
      // as wide/tall as the track and needs no centering). Vertical is absolute from the bottom;
      // horizontal is relative (Base UI's SliderIndicator).
      const first = (this.values.length > 1 ? this.ratio(this.values[0]) : 0) * 100;
      const last = this.ratio(this.values[this.values.length - 1]) * 100;
      const size = last - first;
      if (this.vertical) {
        this.indicator.style.position = "absolute";
        this.indicator.style.width = "inherit";
        this.indicator.style.height = `${size}%`;
        this.indicator.style.bottom = `${first}%`;
        this.indicator.style.left = "";
        this.indicator.style.top = "";
      } else {
        this.indicator.style.position = "relative";
        this.indicator.style.height = "inherit";
        this.indicator.style.width = `${size}%`;
        this.indicator.style.left = `${first}%`;
        this.indicator.style.bottom = "";
        this.indicator.style.top = "";
      }
    }

    if (this.valueEl) this.valueEl.textContent = this.values.map((v) => this.fmt(v)).join(" – ");

    this.el.style.setProperty("--chelekom-slider", String(this.ratio(this.values[this.values.length - 1])));
  },
};

export default Slider;
