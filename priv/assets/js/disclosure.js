// Disclosure — headless disclosure / accordion behavior engine.
//
// Each item is a `[data-part="trigger"]` (button) paired with a `[data-part="panel"]` via
// `aria-controls`. Clicking (or Enter/Space) toggles the panel. Add `data-single` to the
// root for accordion-style exclusive open (opening one closes the others); `data-single`
// without `data-collapsible="false"` still allows closing the open item.
//
// State: trigger `aria-expanded`; panel `data-open` | `data-closed`.

const Disclosure = {
  mounted() {
    this.single = this.el.hasAttribute("data-single");
    this.collapsible = this.el.getAttribute("data-collapsible") !== "false";

    this.pairs = Array.from(this.el.querySelectorAll('[data-part="trigger"]')).map(
      (trigger) => {
        const id = trigger.getAttribute("aria-controls");
        const panel = id ? this.el.querySelector(`#${CSS.escape(id)}`) : null;
        trigger.addEventListener("click", () => this.toggle(trigger, panel));
        if (panel) {
          const open = panel.hasAttribute("data-open");
          trigger.setAttribute("aria-expanded", String(open));
        }
        return { trigger, panel };
      }
    );
  },

  toggle(trigger, panel) {
    if (!panel) return;
    const willOpen = !panel.hasAttribute("data-open");

    if (!willOpen && !this.collapsible) return;

    if (willOpen && this.single) {
      this.pairs.forEach(({ trigger: t, panel: p }) => {
        if (p && p !== panel) this.set(t, p, false);
      });
    }

    this.set(trigger, panel, willOpen);
  },

  set(trigger, panel, open) {
    panel.toggleAttribute("data-open", open);
    panel.toggleAttribute("data-closed", !open);
    trigger.setAttribute("aria-expanded", String(open));
  },
};

export default Disclosure;
