// NumberField — headless number-field engine (Base UI parity).
//
// A text input flanked by stepper buttons, with an optional drag "scrub area". Reads its config
// from data-* attributes on the root and drives a visible (formatted) input plus a visually hidden
// `type="number"` input for form submission.
//
// Options (root data-*): data-min, data-max, data-step ("any" allowed), data-small-step (Alt),
// data-large-step (Shift), data-snap-on-step, data-allow-out-of-range, data-allow-wheel-scrub,
// data-locale, data-format (JSON Intl.NumberFormatOptions), data-value, data-disabled,
// data-readonly, data-on-change (LiveView event {value}), data-on-commit (LiveView event {value},
// fired on blur / pointer release / keyboard).
//
// Behavior: Arrow Up/Down (±step; Shift ⇒ largeStep, Alt ⇒ smallStep), PageUp/PageDown (±largeStep),
// Home/End (min/max), press-and-hold on the buttons (400ms ⇒ 60ms ticks), wheel scrub when focused
// (opt-in), and pointer scrubbing in the scrub area (data-direction / data-pixel-sensitivity /
// data-teleport-distance, with an optional [data-part="scrub-area-cursor"] virtual cursor that wraps).
// Locale-aware formatting + parsing (currency/percent/unit via Intl). Sets data-scrubbing on the root.

const START_AUTO_CHANGE_DELAY = 400;
const CHANGE_VALUE_TICK_DELAY = 60;

const ARABIC = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"];
const PERSIAN = ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹"];
const FULLWIDTH = ["０", "１", "２", "３", "４", "５", "６", "７", "８", "９"];
const HAN = { 零: "0", "〇": "0", 一: "1", 二: "2", 三: "3", 四: "4", 五: "5", 六: "6", 七: "7", 八: "8", 九: "9" };
const MINUS = ["-", "−", "－", "‒", "–", "—", "﹣"];
const PLUS = ["+", "＋", "﹢"];
const PERCENT = ["%", "٪", "％", "﹪"];
const PERMILLE = ["‰", "؉"];

const clamp = (v, lo, hi) => Math.min(hi, Math.max(lo, v));
const replaceAll = (s, find, rep) => (find ? s.split(find).join(rep) : s);

const NumberField = {
  mounted() {
    const el = this.el;
    this.input = el.querySelector('[data-part="input"]');
    this.hidden = el.querySelector('[data-part="hidden-input"]');
    this.inc = el.querySelector('[data-part="increment"]');
    this.dec = el.querySelector('[data-part="decrement"]');
    this.scrubArea = el.querySelector('[data-part="scrub-area"]');
    this.scrubCursor = el.querySelector('[data-part="scrub-area-cursor"]');
    if (!this.input) return;

    const num = (a) => (el.getAttribute(a) != null && el.getAttribute(a) !== "" ? parseFloat(el.getAttribute(a)) : undefined);
    this.stepRaw = el.getAttribute("data-step") || "1";
    this.step = this.stepRaw === "any" ? 1 : parseFloat(this.stepRaw) || 1;
    this.smallStep = num("data-small-step") ?? 0.1;
    this.largeStep = num("data-large-step") ?? 10;
    this.min = num("data-min");
    this.max = num("data-max");
    this.minD = this.min ?? -Number.MAX_SAFE_INTEGER;
    this.maxD = this.max ?? Number.MAX_SAFE_INTEGER;
    this.minZero = this.min ?? 0;
    this.snapOnStep = el.hasAttribute("data-snap-on-step");
    this.allowOutOfRange = el.hasAttribute("data-allow-out-of-range");
    this.allowWheelScrub = el.hasAttribute("data-allow-wheel-scrub");
    this.disabled = el.hasAttribute("data-disabled");
    this.readonly = el.hasAttribute("data-readonly");
    this.locale = el.getAttribute("data-locale") || undefined;
    try {
      this.format = el.getAttribute("data-format") ? JSON.parse(el.getAttribute("data-format")) : undefined;
    } catch {
      this.format = undefined;
    }
    this.onChange = el.getAttribute("data-on-change");
    this.onCommit = el.getAttribute("data-on-commit");

    const initial = el.getAttribute("data-value");
    this.value = initial != null && initial !== "" ? parseFloat(initial) : null;
    if (Number.isNaN(this.value)) this.value = null;
    this.allowInputSync = true;

    this.setDisplay(this.fmt(this.value));
    this.syncHidden();

    // input
    this.input.addEventListener("keydown", (e) => this.onKeyDown(e));
    this.input.addEventListener("input", (e) => this.onInput(e));
    this.input.addEventListener("blur", (e) => this.onBlur(e));
    this.input.addEventListener("focus", (e) => this.onFocus(e));
    this.input.addEventListener("paste", (e) => this.onPaste(e));
    this.onWheel = (e) => this.handleWheel(e);
    this.input.addEventListener("wheel", this.onWheel, { passive: false });

    // buttons (pointer-only; tabindex=-1)
    if (this.inc) this.bindButton(this.inc, 1);
    if (this.dec) this.bindButton(this.dec, -1);

    // scrub area
    if (this.scrubArea) this.bindScrub();
  },

  destroyed() {
    this.clearHold();
    this.endScrub();
  },

  // ---- formatting / parsing -------------------------------------------------

  formatter(opts) {
    return new Intl.NumberFormat(this.locale, opts || this.format || { maximumFractionDigits: 20 });
  },

  localeDetails() {
    const det = {};
    this.formatter().formatToParts(11111.1).forEach((p) => (det[p.type] = p.value));
    new Intl.NumberFormat(this.locale).formatToParts(0.1).forEach((p) => {
      if (p.type === "decimal") det.decimal = p.value;
    });
    return det;
  },

  fmt(v) {
    if (v == null || !Number.isFinite(v)) return "";
    return this.formatter().format(v);
  },

  parse(str) {
    if (str == null) return null;
    let input = String(str).replace(/\p{Cf}/gu, "").trim();
    if (input === "") return null;

    MINUS.forEach((s) => (input = replaceAll(input, s, "-")));
    PLUS.forEach((s) => (input = replaceAll(input, s, "+")));
    let neg = false;
    let m = input.match(/([+-])\s*$/);
    if (m) {
      if (m[1] === "-") neg = true;
      input = input.replace(/([+-])\s*$/, "");
    }
    m = input.match(/^\s*([+-])/);
    if (m) {
      if (m[1] === "-") neg = true;
      input = input.replace(/^\s*[+-]/, "");
    }

    const det = this.localeDetails();
    if (det.group) input = /\p{Zs}/u.test(det.group) ? input.replace(/\p{Zs}/gu, "") : replaceAll(input, det.group, "");
    if (det.currency) input = replaceAll(input, det.currency, "");
    if (det.decimal && det.decimal !== ".") input = replaceAll(input, det.decimal, ".");
    input = replaceAll(replaceAll(input, "．", "."), "，", "");
    input = replaceAll(replaceAll(input, "٫", "."), "٬", "");

    ARABIC.forEach((ch, i) => (input = replaceAll(input, ch, String(i))));
    PERSIAN.forEach((ch, i) => (input = replaceAll(input, ch, String(i))));
    FULLWIDTH.forEach((ch, i) => (input = replaceAll(input, ch, String(i))));
    Object.keys(HAN).forEach((ch) => (input = replaceAll(input, ch, HAN[ch])));

    const isUnitPercent = this.format && this.format.style === "unit" && this.format.unit === "percent";
    const hasPercent = PERCENT.some((s) => String(str).includes(s)) || (this.format && this.format.style === "percent");
    const hasPermille = PERMILLE.some((s) => String(str).includes(s));
    PERCENT.concat(PERMILLE).forEach((s) => (input = replaceAll(input, s, "")));

    input = input.replace(/[^0-9.]/g, "");
    const lastDot = input.lastIndexOf(".");
    if (lastDot !== -1) {
      input = input.slice(0, lastDot).replace(/\./g, "") + "." + input.slice(lastDot + 1).replace(/\./g, "");
    }

    let n = parseFloat((neg ? "-" : "") + input);
    if (!Number.isFinite(n)) return null;
    if (hasPermille) n /= 1000;
    else if (!isUnitPercent && hasPercent) n /= 100;
    return Number.isFinite(n) ? n : null;
  },

  // ---- validation (snap / clamp / float cleanup) ----------------------------

  snapToStep(value, base, step, nearest) {
    const stepSize = Math.abs(step);
    const dir = Math.sign(step) || 1;
    const raw = value - base + stepSize * 1e-10 * dir;
    if (nearest) return base + Math.round(raw / step) * step;
    const snapped = dir > 0 ? Math.floor(raw / stepSize) : Math.ceil(raw / stepSize);
    return base + snapped * stepSize;
  },

  cleanFP(v) {
    return Number.isFinite(v) ? parseFloat(v.toPrecision(12)) : v;
  },

  validate(value, { step, small, doClamp }) {
    if (value == null) return value;
    let n = value;
    if (step != null && this.snapOnStep && step !== 0) {
      const base = small || this.minD === -Number.MAX_SAFE_INTEGER ? this.minZero : this.minD;
      n = this.snapToStep(n, base, step, small);
    }
    if (doClamp) n = clamp(n, this.minD, this.maxD);
    n = this.cleanFP(n);
    return doClamp ? clamp(n, this.minD, this.maxD) : n;
  },

  // ---- value mutation -------------------------------------------------------

  stepAmount(e) {
    if (e && e.altKey) return this.smallStep;
    if (e && e.shiftKey) return this.largeStep;
    return this.step;
  },

  isStepReason(reason) {
    return !["input-change", "input-blur", "input-paste", "input-clear", "none"].includes(reason);
  },

  setValue(raw, { reason = "none", dir = 0, e } = {}) {
    const doClamp = !this.allowOutOfRange || this.isStepReason(reason);
    const small = !!(e && e.altKey);
    const stepForSnap = dir ? this.stepAmount(e) * dir : null;
    const validated = this.validate(raw, { step: stepForSnap, small, doClamp });

    const changed = validated !== this.value;
    this.value = validated;
    this.syncHidden();
    if (this.allowInputSync) this.setDisplay(this.fmt(validated));

    if (changed && this.onChange) this.pushEvent(this.onChange, { value: validated });
    return validated;
  },

  increment(dir, e, reason) {
    const amount = this.stepAmount(e);
    const next = typeof this.value === "number" ? this.value + amount * dir : Math.max(0, this.min ?? 0);
    return this.setValue(next, { reason: reason || "keyboard", dir, e });
  },

  // Fired when an interaction finalizes a value (blur / keyboard / pointer release).
  commit() {
    if (this.onCommit) this.pushEvent(this.onCommit, { value: this.value });
  },

  setDisplay(text) {
    this.input.value = text;
  },

  syncHidden() {
    if (this.hidden) this.hidden.value = this.value == null ? "" : String(this.value);
  },

  // ---- input events ---------------------------------------------------------

  onFocus() {
    if (this.disabled || this.readonly) return;
    if (this._touched) return;
    this._touched = true;
    const len = this.input.value.length;
    this.input.setSelectionRange(len, len);
  },

  onInput(e) {
    if (this.disabled || this.readonly) return;
    this.allowInputSync = false;
    const text = this.input.value;
    if (text.trim() === "") {
      this.setValue(null, { reason: "input-clear", e });
      return;
    }
    const parsed = this.parse(text);
    if (parsed !== null) {
      // update value but DON'T reformat the text the user is typing
      this.allowInputSync = false;
      this.setValue(parsed, { reason: "input-change", e });
    }
  },

  onBlur(e) {
    if (this.disabled || this.readonly) return;
    this.allowInputSync = true;
    const text = this.input.value;
    if (text.trim() === "") {
      this.setValue(null, { reason: "input-clear", e });
      this.setDisplay("");
      this.commit();
      return;
    }
    const parsed = this.parse(text);
    if (parsed === null) {
      // revert to last good value
      this.setDisplay(this.fmt(this.value));
      return;
    }
    const v = this.setValue(parsed, { reason: "input-blur", e });
    this.setDisplay(this.fmt(v));
    this.commit();
  },

  onPaste(e) {
    if (this.disabled || this.readonly) return;
    let data = "";
    try {
      data = (e.clipboardData || window.clipboardData).getData("text") || "";
    } catch {
      return;
    }
    const parsed = this.parse(data);
    if (parsed !== null) {
      e.preventDefault();
      this.allowInputSync = false;
      this.setValue(parsed, { reason: "input-paste", e });
      this.input.value = data;
    }
  },

  onKeyDown(e) {
    if (this.disabled || this.readonly) return;
    this.allowInputSync = true;
    const k = e.key;
    let handled = true;
    if (k === "ArrowUp") {
      e.preventDefault();
      this.increment(1, e);
    } else if (k === "ArrowDown") {
      e.preventDefault();
      this.increment(-1, e);
    } else if (k === "PageUp") {
      e.preventDefault();
      this.setValue((this.value ?? 0) + this.largeStep, { reason: "keyboard", dir: 1, e });
    } else if (k === "PageDown") {
      e.preventDefault();
      this.setValue((this.value ?? 0) - this.largeStep, { reason: "keyboard", dir: -1, e });
    } else if (k === "Home" && this.min != null) {
      e.preventDefault();
      this.setValue(this.min, { reason: "keyboard", e });
      this.setDisplay(this.fmt(this.value));
    } else if (k === "End" && this.max != null) {
      e.preventDefault();
      this.setValue(this.max, { reason: "keyboard", e });
      this.setDisplay(this.fmt(this.value));
    } else {
      handled = false;
    }
    if (handled) this.commit();
  },

  handleWheel(e) {
    if (!this.allowWheelScrub || this.disabled || this.readonly) return;
    if (e.ctrlKey || document.activeElement !== this.input) return;
    e.preventDefault();
    this.allowInputSync = true;
    this.increment(e.deltaY > 0 ? -1 : 1, e, "wheel");
    this.commit();
  },

  // ---- stepper buttons (press-and-hold) -------------------------------------

  bindButton(btn, dir) {
    btn.addEventListener("pointerdown", (e) => {
      if (this.disabled || this.readonly || (e.button && e.button !== 0)) return;
      e.preventDefault();
      if (e.pointerType !== "touch" && e.pointerType !== "pen") this.input.focus();
      this._held = false;
      this.allowInputSync = true;
      const reason = dir > 0 ? "increment-press" : "decrement-press";
      const startTick = () => {
        this._held = true;
        this.increment(dir, e, reason);
        this.holdInterval = setInterval(() => this.increment(dir, e, reason), CHANGE_VALUE_TICK_DELAY);
      };
      this.holdTimer = setTimeout(startTick, START_AUTO_CHANGE_DELAY);
      const up = () => {
        this.clearHold();
        if (!this._held) this.increment(dir, e, reason);
        this.commit();
        window.removeEventListener("pointerup", up);
        window.removeEventListener("pointercancel", up);
      };
      window.addEventListener("pointerup", up);
      window.addEventListener("pointercancel", up);
    });
  },

  clearHold() {
    clearTimeout(this.holdTimer);
    clearInterval(this.holdInterval);
    this.holdTimer = this.holdInterval = null;
  },

  // ---- scrub area -----------------------------------------------------------

  bindScrub() {
    const area = this.scrubArea;
    this.scrubDir = area.getAttribute("data-direction") || "horizontal";
    this.pixelSensitivity = parseFloat(area.getAttribute("data-pixel-sensitivity")) || 2;
    this.teleport = parseFloat(area.getAttribute("data-teleport-distance")) || undefined;
    area.style.touchAction = "none";
    area.addEventListener("pointerdown", (e) => this.startScrub(e));
  },

  startScrub(e) {
    if (this.disabled || this.readonly || (e.button && e.button !== 0)) return;
    e.preventDefault();
    this.input.focus();
    this.allowInputSync = true;
    this._scrubAccum = 0;
    this.el.toggleAttribute("data-scrubbing", true);

    if (this.scrubCursor) {
      this.scrubCursor.toggleAttribute("data-scrubbing", true);
      const cw = this.scrubCursor.offsetWidth;
      const ch = this.scrubCursor.offsetHeight;
      this._vx = e.clientX - cw / 2;
      this._vy = e.clientY - ch / 2;
      this.scrubCursor.style.position = "fixed";
      this.scrubCursor.style.left = "0px";
      this.scrubCursor.style.top = "0px";
      this.scrubCursor.style.pointerEvents = "none";
      this.scrubCursor.style.transform = `translate3d(${this._vx}px,${this._vy}px,0)`;
      if (this.scrubArea.requestPointerLock) {
        try {
          this.scrubArea.requestPointerLock();
        } catch {
          /* ignore */
        }
      }
    }

    this.onScrubMove = (ev) => this.scrubMove(ev);
    this.onScrubUp = () => this.endScrub();
    window.addEventListener("pointermove", this.onScrubMove);
    window.addEventListener("pointerup", this.onScrubUp);
    window.addEventListener("pointercancel", this.onScrubUp);
  },

  scrubMove(e) {
    // value change
    const move = this.scrubDir === "vertical" ? -e.movementY : e.movementX;
    this._scrubAccum += move;
    const sens = this.pixelSensitivity || 2;
    while (Math.abs(this._scrubAccum) >= sens) {
      const dir = this._scrubAccum > 0 ? 1 : -1;
      this._scrubAccum -= dir * sens;
      this.increment(dir, e, "scrub");
    }

    // virtual cursor (wraps within the teleport box, else the viewport)
    if (this.scrubCursor && this._vx != null) {
      const cw = this.scrubCursor.offsetWidth;
      const ch = this.scrubCursor.offsetHeight;
      let x = this._vx + e.movementX;
      let y = this._vy + e.movementY;
      let minX = 0;
      let minY = 0;
      let maxX = window.innerWidth;
      let maxY = window.innerHeight;
      if (this.teleport) {
        const r = this.scrubArea.getBoundingClientRect();
        const cx = r.left + r.width / 2;
        const cy = r.top + r.height / 2;
        minX = cx - this.teleport;
        maxX = cx + this.teleport;
        minY = cy - this.teleport;
        maxY = cy + this.teleport;
      }
      if (x + cw / 2 < minX) x = maxX - cw / 2;
      else if (x + cw / 2 > maxX) x = minX - cw / 2;
      if (y + ch / 2 < minY) y = maxY - ch / 2;
      else if (y + ch / 2 > maxY) y = minY - ch / 2;
      this._vx = x;
      this._vy = y;
      this.scrubCursor.style.transform = `translate3d(${x}px,${y}px,0)`;
    }
  },

  endScrub() {
    if (!this.onScrubMove) return;
    window.removeEventListener("pointermove", this.onScrubMove);
    window.removeEventListener("pointerup", this.onScrubUp);
    window.removeEventListener("pointercancel", this.onScrubUp);
    this.onScrubMove = this.onScrubUp = null;
    this.el.removeAttribute("data-scrubbing");
    if (this.scrubCursor) {
      this.scrubCursor.removeAttribute("data-scrubbing");
      this.scrubCursor.style.transform = "";
      this._vx = this._vy = null;
    }
    if (document.exitPointerLock && document.pointerLockElement) {
      try {
        document.exitPointerLock();
      } catch {
        /* ignore */
      }
    }
    this.commit();
  },
};

export default NumberField;
