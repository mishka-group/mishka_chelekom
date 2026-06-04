// Toggle — headless pressed/checked state engine (toggle, toggle_group item, switch).
//
// Clicking (or Enter/Space on a button) flips the control's state. Which ARIA attribute is
// toggled depends on the element's role: `role="switch"`/`checkbox` → `aria-checked`,
// otherwise `aria-pressed`. The matching `data-on`/`data-off` (and `data-checked`/
// `data-unchecked` for switches) attributes are toggled for CSS. A hidden input (if present,
// `[data-part="input"]`) is kept in sync for form submission.

const Toggle = {
  mounted() {
    this.input = this.el.querySelector('[data-part="input"]');
    this.role = this.el.getAttribute("role");
    this.attr =
      this.role === "switch" || this.role === "checkbox" ? "aria-checked" : "aria-pressed";

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
    if (this.el.hasAttribute("data-disabled")) return;
    const on = this.el.getAttribute(this.attr) !== "true";
    this.el.setAttribute(this.attr, String(on));

    if (this.attr === "aria-checked") {
      this.el.toggleAttribute("data-checked", on);
      this.el.toggleAttribute("data-unchecked", !on);
    } else {
      this.el.toggleAttribute("data-on", on);
      this.el.toggleAttribute("data-off", !on);
    }

    if (this.input) this.input.checked = on;
  },
};

export default Toggle;
