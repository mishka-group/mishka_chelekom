// Otp — headless one-time-code (OTP) field engine (Base UI parity).
//
// A row of single-character `[data-part="input"]` boxes backed by one logical value string.
// Reads config from the root's data-*: data-length, data-validation-type
// (numeric|alpha|alphanumeric|none), data-transform (none|uppercase|lowercase), data-mask,
// data-auto-submit, data-disabled, data-readonly, data-value (initial), data-on-change /
// data-on-complete / data-on-invalid (LiveView events, {value}).
//
// Behavior: typing replaces + auto-advances; paste distributes & normalizes; Backspace clears
// (Ctrl/Meta+Backspace clears all); Delete removes-and-shifts; Arrows + Home/End/ArrowUp/Down
// navigate (roving tabindex — only the active slot is tabbable). Rejected characters fire
// on-invalid. The combined value mirrors into the hidden `[data-part="value"]` input; when every
// slot is filled the root gets `data-complete`, on-complete fires, and the owning form is submitted
// if data-auto-submit is set. Each box reflects `data-filled`; the root reflects
// `data-filled`/`data-complete`/`data-focused`.

const DISALLOWED = {
  numeric: /[^\d]/g,
  alpha: /[^a-zA-Z]/g,
  alphanumeric: /[^a-zA-Z0-9]/g,
};

const Otp = {
  mounted() {
    const el = this.el;
    this.boxes = Array.from(el.querySelectorAll('[data-part="input"]'));
    this.hidden = el.querySelector('[data-part="value"]');
    if (!this.boxes.length) return;

    this.length = parseInt(el.getAttribute("data-length"), 10) || this.boxes.length;
    this.validationType = el.getAttribute("data-validation-type") || "numeric";
    this.disallowed = DISALLOWED[this.validationType] || null;
    this.transform = el.getAttribute("data-transform") || "none";
    this.autoSubmit = el.hasAttribute("data-auto-submit");
    this.disabled = el.hasAttribute("data-disabled");
    this.readonly = el.hasAttribute("data-readonly");
    this.onChange = el.getAttribute("data-on-change");
    this.onComplete = el.getAttribute("data-on-complete");
    this.onInvalid = el.getAttribute("data-on-invalid");

    this.value = this.normalize(el.getAttribute("data-value") || (this.hidden && this.hidden.value) || "")[0];
    this.activeIndex = Math.min(this.value.length, this.length - 1);
    this.render();

    this.boxes.forEach((box, i) => {
      box.addEventListener("input", (e) => this.onInput(e, i));
      box.addEventListener("keydown", (e) => this.onKeyDown(e, i));
      box.addEventListener("paste", (e) => this.onPaste(e, i));
      box.addEventListener("focus", () => this.onBoxFocus(i));
      box.addEventListener("mousedown", (e) => {
        if (this.disabled) return;
        e.preventDefault();
        this.focusBox(i);
      });
    });

    // Browser OTP autofill may target the hidden input — distribute it too.
    if (this.hidden) this.hidden.addEventListener("input", (e) => this.onHiddenInput(e));

    this.onFocusIn = () => this.setFocused(true);
    this.onFocusOut = (e) => {
      if (e.relatedTarget && el.contains(e.relatedTarget)) return;
      this.setFocused(false);
    };
    el.addEventListener("focusin", this.onFocusIn);
    el.addEventListener("focusout", this.onFocusOut);

    // Server can set/clear the value: push_event("chelekom:otp", %{id: dom_id, value: "..."}).
    // Needed because the root is phx-update="ignore" (the slots are client-owned), so a server
    // re-render can't reset them — this is the channel for programmatic set/clear.
    this.setRef = this.handleEvent("chelekom:otp", (p) => {
      if (!p || (p.id && p.id !== el.id)) return;
      this.value = this.normalize(p.value ?? "")[0];
      this.activeIndex = Math.min(Array.from(this.value).length, this.length - 1);
      this.render();
      if (p.focus !== false) this.focusBox(this.activeIndex);
    });
  },

  destroyed() {
    this.el.removeEventListener("focusin", this.onFocusIn);
    this.el.removeEventListener("focusout", this.onFocusOut);
    if (this.setRef) this.removeHandleEvent(this.setRef);
  },

  // ---- normalization --------------------------------------------------------

  normalize(str) {
    let s = (str ?? "").replace(/\s/g, "");
    const before = Array.from(s).length;
    if (this.disallowed) s = s.replace(this.disallowed, "");
    if (this.transform === "uppercase") s = s.toUpperCase();
    else if (this.transform === "lowercase") s = s.toLowerCase();
    if (this.disallowed) s = s.replace(this.disallowed, "");
    const chars = Array.from(s);
    const rejected = before > chars.length || chars.length > this.length;
    return [chars.slice(0, this.length).join(""), rejected];
  },

  replaceAt(current, index, chunk) {
    const norm = this.normalize(chunk)[0];
    const prefix = current.slice(0, index);
    const suffix = current.slice(index + Array.from(norm).length);
    return this.normalize(prefix + norm + suffix)[0];
  },

  removeAt(current, index) {
    const chars = Array.from(current);
    if (index < 0 || index >= chars.length) return current;
    chars.splice(index, 1);
    return chars.join("");
  },

  isComplete() {
    return Array.from(this.value).length === this.length;
  },

  // ---- rendering / state ----------------------------------------------------

  render() {
    const chars = Array.from(this.value);
    const complete = this.isComplete();
    this.boxes.forEach((b, i) => {
      const c = chars[i] || "";
      if (b.value !== c) b.value = c;
      b.toggleAttribute("data-filled", c !== "");
      b.toggleAttribute("data-complete", complete);
      b.tabIndex = i === this.activeIndex ? 0 : -1;
    });
    this.el.toggleAttribute("data-complete", complete);
    this.el.toggleAttribute("data-filled", chars.length > 0);
    if (this.hidden && this.hidden.value !== this.value) this.hidden.value = this.value;
  },

  setFocused(on) {
    this.el.toggleAttribute("data-focused", on);
    this.boxes.forEach((b) => b.toggleAttribute("data-focused", on));
  },

  fire(event, value) {
    if (event) this.pushEvent(event, { value });
  },

  setValue(next, reason) {
    const [norm] = this.normalize(next);
    const wasComplete = this.isComplete();
    const changed = norm !== this.value;
    this.value = norm;
    this.render();
    if (changed) this.fire(this.onChange, norm);
    if (this.isComplete() && (changed || !wasComplete)) {
      this.fire(this.onComplete, norm);
      if (this.autoSubmit) this.submitForm();
    }
    return norm;
  },

  focusBox(i) {
    const idx = Math.max(0, Math.min(this.length - 1, i));
    this.activeIndex = idx;
    this.boxes.forEach((b, j) => (b.tabIndex = j === idx ? 0 : -1));
    const box = this.boxes[idx];
    if (box) {
      box.focus();
      box.select();
    }
  },

  onBoxFocus(i) {
    this.activeIndex = i;
    this.boxes.forEach((b, j) => (b.tabIndex = j === i ? 0 : -1));
    this.boxes[i].select();
  },

  submitForm() {
    const form = (this.hidden && this.hidden.form) || this.el.closest("form");
    if (form && typeof form.requestSubmit === "function") form.requestSubmit();
  },

  // ---- events ---------------------------------------------------------------

  onInput(e, i) {
    if (this.disabled || this.readonly) return;
    const raw = e.target.value;
    const [norm, rejected] = this.normalize(raw);
    if (rejected) this.fire(this.onInvalid, raw);

    if (norm === "") {
      if (raw === "") {
        this.setValue(this.removeAt(this.value, i), "input-clear");
      } else {
        // reject — restore the slot's character
        e.target.value = Array.from(this.value)[i] || "";
        e.target.select();
      }
      return;
    }

    this.setValue(this.replaceAt(this.value, i, norm), "input-change");
    this.focusBox(Math.min(i + Array.from(norm).length, this.length - 1));
  },

  onHiddenInput(e) {
    if (this.disabled || this.readonly) return;
    const [norm, rejected] = this.normalize(e.target.value);
    if (rejected) this.fire(this.onInvalid, e.target.value);
    if (norm === "") return;
    this.setValue(norm, "input-change");
    this.focusBox(Math.min(Array.from(norm).length, this.length - 1));
  },

  onKeyDown(e, i) {
    if (this.disabled) return;
    const last = this.length - 1;
    const endTarget = Math.min(Array.from(this.value).length, last);
    const boundary = (e.ctrlKey || e.metaKey) && !e.altKey;
    const k = e.key;

    if (k === "ArrowLeft") {
      e.preventDefault();
      this.focusBox(boundary ? 0 : i - 1);
      return;
    }
    if (k === "ArrowRight") {
      e.preventDefault();
      this.focusBox(boundary ? endTarget : i + 1);
      return;
    }
    if (k === "Home" || k === "ArrowUp") {
      e.preventDefault();
      this.focusBox(0);
      return;
    }
    if (k === "End" || k === "ArrowDown") {
      e.preventDefault();
      this.focusBox(endTarget);
      return;
    }

    if (this.readonly) return;

    if (k === "Backspace" && boundary) {
      e.preventDefault();
      this.setValue("", "keyboard");
      this.focusBox(0);
      return;
    }
    if (k === "Delete") {
      e.preventDefault();
      this.setValue(this.removeAt(this.value, i), "keyboard");
      this.focusBox(i);
      return;
    }

    const inputEl = e.currentTarget;
    const fullSelection = inputEl.selectionStart === 0 && inputEl.selectionEnd === inputEl.value.length;
    const slot = Array.from(this.value)[i] || "";
    if (k.length === 1 && fullSelection && slot === k) {
      e.preventDefault();
      if (i < last) this.focusBox(i + 1);
      return;
    }

    if (k === "Backspace") {
      e.preventDefault();
      const target = Math.max(0, i - 1);
      const deleteIndex = slot === "" ? target : i;
      this.setValue(this.removeAt(this.value, deleteIndex), "keyboard");
      this.focusBox(target);
    }
  },

  onPaste(e, i) {
    if (this.disabled || this.readonly) return;
    e.preventDefault();
    let raw = "";
    try {
      raw = (e.clipboardData || window.clipboardData).getData("text") || "";
    } catch {
      return;
    }
    const [norm, rejected] = this.normalize(raw);
    if (rejected) this.fire(this.onInvalid, raw);
    if (norm === "") return;
    this.setValue(this.replaceAt(this.value, i, norm), "input-paste");
    this.focusBox(Math.min(i + Array.from(norm).length, this.length - 1));
  },
};

export default Otp;
