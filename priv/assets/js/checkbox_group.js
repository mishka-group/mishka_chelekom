// CheckboxGroup — coordinates a tristate "select all" parent checkbox with its children.
//
// Put `phx-hook="CheckboxGroup"` on a wrapper that contains one parent checkbox (`[data-parent]`)
// and any number of child checkboxes (`[role="checkbox"]`). Each checkbox drives its own state via
// the `Toggle` hook; this hook only coordinates the group:
//   • clicking the parent checks/unchecks every (enabled) child
//   • clicking any child re-derives the parent → checked (all) / unchecked (none) / mixed (some)
//
// It listens for the bubbling `chelekom:toggle` event each checkbox's `Toggle` fires after it flips
// (so it works for BOTH click and keyboard) — adding no duplicate toggle logic. To sync children it
// dispatches a real click on the ones that must change.

const CheckboxGroup = {
  mounted() {
    this.parent = this.el.querySelector("[data-parent]");
    this.onToggle = (e) => this.handle(e);
    this.el.addEventListener("chelekom:toggle", this.onToggle);
    this.derive();
  },

  updated() {
    this.derive();
  },

  destroyed() {
    this.el.removeEventListener("chelekom:toggle", this.onToggle);
  },

  children() {
    return Array.from(this.el.querySelectorAll('[role="checkbox"]')).filter((c) => c !== this.parent);
  },

  isChecked(el) {
    return el.getAttribute("aria-checked") === "true";
  },

  enabled(el) {
    return !el.hasAttribute("data-disabled") && !el.hasAttribute("data-readonly");
  },

  handle(e) {
    if (this.syncing) return;
    const target = e.target.closest('[role="checkbox"]');
    if (!target || !this.el.contains(target)) return;

    if (target === this.parent) {
      // the parent's own Toggle has already flipped it — mirror its new state onto every child
      const want = this.isChecked(this.parent);
      this.syncing = true;
      this.children().forEach((c) => {
        if (this.enabled(c) && this.isChecked(c) !== want) c.click();
      });
      this.syncing = false;
    }
    this.derive();
  },

  // Parent state from the TOGGLABLE children (disabled/readonly are frozen, so they don't count, and
  // can't trap the parent in "mixed"): all checked → checked · none → unchecked · some → mixed.
  derive() {
    if (!this.parent) return;
    const kids = this.children().filter((c) => this.enabled(c));
    const checked = kids.filter((c) => this.isChecked(c)).length;
    const state =
      kids.length === 0 || checked === 0
        ? "unchecked"
        : checked === kids.length
          ? "checked"
          : "mixed";

    this.parent.setAttribute("aria-checked", state === "mixed" ? "mixed" : String(state === "checked"));
    this.parent.toggleAttribute("data-checked", state === "checked");
    this.parent.toggleAttribute("data-unchecked", state === "unchecked");
    this.parent.toggleAttribute("data-indeterminate", state === "mixed");

    const ind = this.parent.querySelector('[data-part="indicator"]');
    if (ind) {
      ind.toggleAttribute("data-checked", state === "checked");
      ind.toggleAttribute("data-unchecked", state === "unchecked");
      ind.toggleAttribute("data-indeterminate", state === "mixed");
    }
    const input = this.parent.querySelector('[data-part="input"]');
    if (input) {
      input.checked = state === "checked";
      input.indeterminate = state === "mixed";
    }
  },
};

export default CheckboxGroup;
