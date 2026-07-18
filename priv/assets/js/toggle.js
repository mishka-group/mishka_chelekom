// Toggle — headless pressed/checked state engine (toggle, toggle_group item, switch, checkbox).
//
// Clicking (or Enter/Space on a button) flips the control's state. Which ARIA attribute is
// toggled depends on the element's role: `role="switch"`/`checkbox` → `aria-checked` (with
// `data-checked`/`data-unchecked`), otherwise `aria-pressed` (with `data-pressed`, present only
// when on — Base UI Toggle parity). A hidden input (if present, `[data-part="input"]`) is kept in
// sync for form submission.
//
// Checkbox opt-in extras (switch/toggle set none of these, so they no-op):
//   `data-readonly`     → toggling is blocked, but the control stays focusable
//   `aria-checked="mixed"` (indeterminate) → the next toggle resolves to checked, clearing mixed
//   `data-on-change="event"` → pushes the LiveView event `{checked}` on every toggle
//   a `[data-part="indicator"]` child mirrors `data-checked`/`data-unchecked`/`data-indeterminate`.

const Toggle = {
  mounted() {
    this.input = this.el.querySelector('[data-part="input"]');
    // Children that mirror the checked state for CSS: a checkbox `indicator` and/or a switch
    // `track`/`thumb` — so each part can be styled off its own `data-checked`/`data-unchecked`.
    this.mirrors = [
      this.el.querySelector('[data-part="indicator"]'),
      this.el.querySelector('[data-part="track"]'),
      this.el.querySelector('[data-part="thumb"]'),
    ].filter(Boolean);
    this.role = this.el.getAttribute("role");
    this.attr =
      this.role === "switch" || this.role === "checkbox" ? "aria-checked" : "aria-pressed";

    // Reflect an initial indeterminate state onto the native input (HTML has no such attribute).
    if (this.input && this.el.hasAttribute("data-indeterminate")) this.input.indeterminate = true;

    this.boundClick = this.toggle.bind(this);
    this.boundKey = (e) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        this.toggle();
      }
    };

    this.el.addEventListener("click", this.boundClick);
    this.el.addEventListener("keydown", this.boundKey);
  },

  destroyed() {
    this.el.removeEventListener("click", this.boundClick);
    this.el.removeEventListener("keydown", this.boundKey);
  },

  toggle() {
    if (this.el.hasAttribute("data-disabled") || this.el.hasAttribute("data-readonly")) return;

    // From an indeterminate (mixed) state the next toggle resolves to checked.
    const prev = this.el.getAttribute(this.attr) === "true";
    const on = this.el.getAttribute(this.attr) === "mixed" ? true : !prev;
    this.set(on);

    // Notify any enclosing <.form phx-change> — setting `.checked` programmatically doesn't fire it.
    if (this.input) this.input.dispatchEvent(new Event("change", { bubbles: true }));

    // Fire the server event only on a real change; read data-on-change live (survives re-renders).
    // Payload is semantic: {checked} for switch/checkbox, {pressed} for toggle buttons.
    const onChange = this.el.getAttribute("data-on-change");
    if (onChange && on !== prev) {
      this.pushEventTo(this.el, onChange, this.attr === "aria-checked" ? { checked: on } : { pressed: on });
    }

    // Notify any group coordinator (CheckboxGroup) — covers BOTH click and keyboard toggles.
    this.el.dispatchEvent(new CustomEvent("chelekom:toggle", { bubbles: true }));
  },

  // Set the resolved (non-mixed) state on the control, indicator and hidden input.
  set(on) {
    this.el.setAttribute(this.attr, String(on));
    this.el.removeAttribute("data-indeterminate");

    if (this.attr === "aria-checked") {
      this.el.toggleAttribute("data-checked", on);
      this.el.toggleAttribute("data-unchecked", !on);
    } else {
      // Pressed buttons (toggle / toggle_group item): Base UI exposes only `data-pressed` (present
      // when on, absent when off).
      this.el.toggleAttribute("data-pressed", on);
    }

    this.mirrors.forEach((m) => {
      m.toggleAttribute("data-checked", on);
      m.toggleAttribute("data-unchecked", !on);
      m.removeAttribute("data-indeterminate");
    });

    if (this.input) {
      this.input.checked = on;
      this.input.indeterminate = false;
    }
  },
};

export default Toggle;
