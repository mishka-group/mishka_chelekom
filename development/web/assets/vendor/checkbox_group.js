// CheckboxGroup — coordinates a checkbox group/tree: tristate "select all" parents + group on_change.
//
// Put `phx-hook="CheckboxGroup"` on a wrapper containing child checkboxes (`[role="checkbox"]`) and,
// optionally, parent checkboxes (`[data-parent]`). A parent owns the checkboxes in the
// `[data-part="children"]` container that immediately follows it; that container may itself hold more
// parents, so groups NEST to any depth (e.g. a permissions tree). Each checkbox drives its own state
// via the `Toggle` hook; this hook only coordinates the group:
//   • toggling a parent checks/unchecks every (enabled) leaf in its subtree
//   • toggling any checkbox re-derives every parent bottom-up → checked (all direct children checked)
//     / unchecked (none) / mixed (some, or any child mixed)
//   • if the wrapper has `data-on-change`, pushes that event with the selected leaf values ({value:[...]})
//
// A parent with NO `[data-part="children"]` container is treated flat (its children are the wrapper's
// other checkboxes) — so a simple one-level "select all" works without any nesting markup.
//
// It listens for the bubbling `chelekom:toggle` event each checkbox's `Toggle` fires after it flips
// (so it works for BOTH click and keyboard). To sync a subtree it dispatches a real click on the
// leaves that must change.

const CheckboxGroup = {
  mounted() {
    this.onToggle = (e) => this.handle(e);
    this.el.addEventListener("chelekom:toggle", this.onToggle);
    this.deriveAll();
  },

  updated() {
    this.deriveAll();
  },

  destroyed() {
    this.el.removeEventListener("chelekom:toggle", this.onToggle);
  },

  isChecked(el) {
    return el.getAttribute("aria-checked") === "true";
  },

  isMixed(el) {
    return el.hasAttribute("data-indeterminate");
  },

  enabled(el) {
    return !el.hasAttribute("data-disabled") && !el.hasAttribute("data-readonly");
  },

  // The children container a parent owns (its next sibling [data-part="children"]), or null (flat).
  container(parent) {
    const n = parent.nextElementSibling;
    return n && n.matches('[data-part="children"]') ? n : null;
  },

  // A parent's DIRECT child checkboxes (not grandchildren nested in a deeper container).
  directChildren(parent) {
    const c = this.container(parent);
    const scope = c || this.el;
    return Array.from(scope.querySelectorAll('[role="checkbox"]')).filter(
      (cb) => cb !== parent && cb.closest('[data-part="children"]') === c,
    );
  },

  // Every leaf (non-parent) checkbox under a parent — the ones a "select all" actually toggles.
  leaves(parent) {
    const c = this.container(parent);
    const scope = c || this.el;
    return Array.from(scope.querySelectorAll('[role="checkbox"]')).filter(
      (cb) => cb !== parent && !cb.hasAttribute("data-parent"),
    );
  },

  // All parents, deepest first, so a parent re-derives only after its sub-parents have settled.
  parents() {
    return Array.from(this.el.querySelectorAll('[role="checkbox"][data-parent]')).sort(
      (a, b) => this.depth(b) - this.depth(a),
    );
  },

  depth(el) {
    let d = 0;
    let n = el.parentElement;
    while (n && n !== this.el) {
      if (n.matches('[data-part="children"]')) d += 1;
      n = n.parentElement;
    }
    return d;
  },

  handle(e) {
    if (this.syncing) return;
    const target = e.target.closest('[role="checkbox"]');
    if (!target || !this.el.contains(target)) return;

    if (target.hasAttribute("data-parent")) {
      // the parent's own Toggle has flipped it — mirror its new state onto every leaf in its subtree
      const want = this.isChecked(target);
      this.syncing = true;
      this.leaves(target).forEach((leaf) => {
        if (this.enabled(leaf) && this.isChecked(leaf) !== want) leaf.click();
      });
      this.syncing = false;
    }
    this.deriveAll();
    this.emit();
  },

  deriveAll() {
    this.parents().forEach((p) => this.derive(p));
  },

  // A parent reflects its TOGGLABLE direct children: all checked → checked · none → unchecked ·
  // otherwise (some checked, or any child itself mixed) → mixed.
  derive(parent) {
    const kids = this.directChildren(parent).filter((c) => this.enabled(c));
    let state;
    if (kids.length === 0 || kids.every((c) => !this.isChecked(c) && !this.isMixed(c)))
      state = "unchecked";
    else if (kids.every((c) => this.isChecked(c) && !this.isMixed(c))) state = "checked";
    else state = "mixed";
    this.setState(parent, state);
  },

  setState(el, state) {
    el.setAttribute("aria-checked", state === "mixed" ? "mixed" : String(state === "checked"));
    el.toggleAttribute("data-checked", state === "checked");
    el.toggleAttribute("data-unchecked", state === "unchecked");
    el.toggleAttribute("data-indeterminate", state === "mixed");

    const ind = el.querySelector('[data-part="indicator"]');
    if (ind) {
      ind.toggleAttribute("data-checked", state === "checked");
      ind.toggleAttribute("data-unchecked", state === "unchecked");
      ind.toggleAttribute("data-indeterminate", state === "mixed");
    }
    const input = el.querySelector('[data-part="input"]');
    if (input) {
      input.checked = state === "checked";
      input.indeterminate = state === "mixed";
    }
  },

  // Push the selected LEAF values to LiveView (parents carry no submittable value). The value comes
  // from the checkbox's `data-value` (always present, so on_change works even without a form name),
  // falling back to the hidden input's value.
  emit() {
    const onChange = this.el.getAttribute("data-on-change");
    if (!onChange) return;
    const value = Array.from(this.el.querySelectorAll('[role="checkbox"]'))
      .filter((c) => !c.hasAttribute("data-parent") && this.isChecked(c))
      .map((c) => {
        const v = c.getAttribute("data-value");
        if (v != null) return v;
        const input = c.querySelector('[data-part="input"]');
        return input ? input.value : null;
      })
      .filter((v) => v != null);
    this.pushEventTo(this.el, onChange, { value });
  },
};

export default CheckboxGroup;
