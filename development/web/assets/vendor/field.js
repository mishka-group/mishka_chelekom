// Field — headless interaction-state engine for the form-field wrapper.
//
// Tracks the wrapped control (the first input/textarea/select inside `[data-part="control"]`)
// and reflects its interaction state on the field ROOT as data-* attributes for CSS, mirroring
// Base UI Field:
//   data-focused → the control is focused
//   data-touched → the control has been blurred at least once (sticky)
//   data-dirty   → the control's value differs from its initial value
//   data-filled  → the control's value is non-empty
//
// Validity is server-driven: `data-invalid` / `data-disabled` are rendered by the component
// (from `errors` / `disabled`), never touched here. Listeners are delegated on the root
// (focusin/focusout/input bubble) so they survive LiveView re-renders of the control.

const Field = {
  mounted() {
    this.initial = this.value();
    this.sync(); // reflect data-filled for pre-filled values on mount

    this.onFocusIn = () => this.el.toggleAttribute("data-focused", true);
    this.onFocusOut = (e) => {
      // Ignore focus moving between elements inside the same field.
      if (e.relatedTarget && this.el.contains(e.relatedTarget)) return;
      this.el.removeAttribute("data-focused");
      this.el.toggleAttribute("data-touched", true);
    };
    this.onInput = () => this.sync();

    this.el.addEventListener("focusin", this.onFocusIn);
    this.el.addEventListener("focusout", this.onFocusOut);
    this.el.addEventListener("input", this.onInput);
    this.el.addEventListener("change", this.onInput);
  },

  destroyed() {
    this.el.removeEventListener("focusin", this.onFocusIn);
    this.el.removeEventListener("focusout", this.onFocusOut);
    this.el.removeEventListener("input", this.onInput);
    this.el.removeEventListener("change", this.onInput);
  },

  control() {
    return this.el.querySelector(
      '[data-part="control"] input, [data-part="control"] textarea, [data-part="control"] select'
    );
  },

  // Normalized current value of the control ("" when empty/absent).
  value() {
    const c = this.control();
    if (!c) return "";
    if (c.type === "checkbox" || c.type === "radio") return c.checked ? "on" : "";
    return c.value == null ? "" : c.value;
  },

  sync() {
    const v = this.value();
    this.el.toggleAttribute("data-dirty", v !== this.initial);
    this.el.toggleAttribute("data-filled", v !== "");
  },
};

export default Field;
