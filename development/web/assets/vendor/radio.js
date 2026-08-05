// Radio — headless single radio (Base UI parity).
//
// Wraps a native `<input type="radio">` and exposes Base UI's styling surface as live data-attributes
// on the root (the `<label>`) and the `[data-part="indicator"]`: `data-checked` / `data-unchecked`
// (mutually exclusive), kept in sync with the input's `checked` state — including when a SIBLING radio
// in the same `name` group steals the selection (the browser unchecks siblings without firing their
// `change`, so each radio also watches the document for same-name changes). `data-disabled` /
// `data-readonly` / `data-required` are rendered server-side. `readonly` is emulated by cancelling the
// click (native radios ignore the `readonly` attribute).
//
// No-JS fallback: the server already renders the correct initial `data-checked`/`data-unchecked`, so
// SSR and controlled (`<.form>`-driven) usage look right before/without the hook.

const Radio = {
  mounted() {
    this.input = this.el.querySelector('[data-part="input"]');
    this.indicator = this.el.querySelector('[data-part="indicator"]');
    if (!this.input) return;

    this.sync();

    this.onClick = (e) => {
      if (this.el.hasAttribute("data-readonly") || this.el.hasAttribute("data-disabled")) e.preventDefault();
    };
    this.onChange = () => this.sync();
    // A sibling becoming checked unchecks this one WITHOUT firing its `change`, so re-sync on any
    // same-name radio change anywhere in the document.
    this.onDocChange = (e) => {
      const t = e.target;
      if (t && t !== this.input && t.type === "radio" && this.input.name && t.name === this.input.name) {
        this.sync();
      }
    };

    this.input.addEventListener("click", this.onClick);
    this.input.addEventListener("change", this.onChange);
    this.input.ownerDocument.addEventListener("change", this.onDocChange, true);
  },

  destroyed() {
    if (this.onDocChange) this.input.ownerDocument.removeEventListener("change", this.onDocChange, true);
  },

  sync() {
    const on = this.input.checked;
    this.el.toggleAttribute("data-checked", on);
    this.el.toggleAttribute("data-unchecked", !on);
    if (this.indicator) {
      this.indicator.toggleAttribute("data-checked", on);
      this.indicator.toggleAttribute("data-unchecked", !on);
    }
  },
};

export default Radio;
