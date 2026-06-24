// ToggleGroup — coordinated group of toggle buttons (Base UI parity).
//
// One hook on the root `role="group"` owns everything: roving tabindex (arrow keys along the
// orientation + Home/End, looping when `data-loop`), and the pressed state of every
// `[data-part="item"]`. `data-multiple` allows several pressed at once (toggle in/out); without it the
// group is single-select — pressing an item presses ONLY it, and pressing the already-pressed item
// deselects it (the group may be empty), matching Base UI. Each item reflects `aria-pressed` +
// `data-pressed`; the pressed values mirror into hidden inputs under `[data-part="value-inputs"]`
// (single → `name`, multiple → `name[]`) with a bubbling `input` (so `<.form>` reacts), and
// `data-on-change` pushes `{value: [...]}` to LiveView.

const ToggleGroup = {
  mounted() {
    const el = this.el;
    this.multiple = el.hasAttribute("data-multiple");
    this.disabled = el.hasAttribute("data-disabled");
    this.vertical = el.getAttribute("data-orientation") === "vertical";
    this.loop = el.hasAttribute("data-loop");
    this.name = el.getAttribute("data-name");
    this.onChange = el.getAttribute("data-on-change");
    this.inputs = el.querySelector('[data-part="value-inputs"]');

    this.pressed = new Set(
      this.items().filter((i) => i.hasAttribute("data-pressed")).map((i) => this.val(i))
    );

    this.bindItems();
    this.boundKey = (e) => this.onKey(e);
    el.addEventListener("keydown", this.boundKey);
    this.roll();
  },

  updated() {
    // A server re-render (e.g. form submit/reset) re-renders the items from @value; re-read the
    // pressed set from the server, re-bind any new items, and restore the roving tabindex.
    this.pressed = new Set(
      this.items().filter((i) => i.getAttribute("aria-pressed") === "true").map((i) => this.val(i))
    );
    this.bindItems();
    this.roll();
  },

  destroyed() {
    this.el.removeEventListener("keydown", this.boundKey);
  },

  items() {
    return Array.from(this.el.querySelectorAll('[data-part="item"]'));
  },

  enabledItems() {
    return this.items().filter((i) => !i.hasAttribute("data-disabled"));
  },

  val(item) {
    return item.getAttribute("data-value");
  },

  bindItems() {
    this.items().forEach((item) => {
      if (item._tgBound) return;
      item._tgBound = true;
      item.addEventListener("click", () => this.commit(item));
    });
  },

  // ---- press logic ----------------------------------------------------------

  commit(item) {
    if (this.disabled || item.hasAttribute("data-disabled")) return;
    const v = this.val(item);
    const nextPressed = !this.pressed.has(v);

    if (this.multiple) {
      if (nextPressed) this.pressed.add(v);
      else this.pressed.delete(v);
    } else {
      // single: press → only this; press the pressed one → empty (Base UI deselect).
      this.pressed = nextPressed ? new Set([v]) : new Set();
    }

    this.render();
    this.focusItem(item);
    if (this.onChange) this.pushEvent(this.onChange, { value: Array.from(this.pressed) });
  },

  render() {
    this.items().forEach((item) => {
      const on = this.pressed.has(this.val(item));
      item.setAttribute("aria-pressed", String(on));
      item.toggleAttribute("data-pressed", on);
    });
    this.roll();
    this.syncInputs();
  },

  // Mirror the pressed values into the hidden form input(s) and notify any enclosing <.form>.
  syncInputs() {
    if (!this.inputs || !this.name) return;
    const name = this.multiple ? `${this.name}[]` : this.name;
    const vals = Array.from(this.pressed);
    const html = (this.multiple ? vals : vals.slice(0, 1))
      .map((v) => `<input type="hidden" name="${name}" value="${this.escape(v)}">`)
      .join("");
    // single with no selection still submits an empty field (so the param is present)
    this.inputs.innerHTML =
      html || (this.multiple ? "" : `<input type="hidden" name="${name}" value="">`);
    this.inputs.dispatchEvent(new Event("input", { bubbles: true }));
  },

  // ---- roving tabindex / keyboard -------------------------------------------

  // The tabbable item is the first pressed-and-enabled one, else the first enabled one.
  roll() {
    const items = this.items();
    const tabbable =
      items.find((i) => i.hasAttribute("data-pressed") && !i.hasAttribute("data-disabled")) ||
      this.enabledItems()[0];
    items.forEach((i) => i.setAttribute("tabindex", i === tabbable ? "0" : "-1"));
  },

  focusItem(item) {
    this.items().forEach((i) => i.setAttribute("tabindex", i === item ? "0" : "-1"));
    item.focus();
  },

  onKey(e) {
    if (this.disabled) return;
    const items = this.enabledItems();
    const idx = items.indexOf(e.target.closest('[data-part="item"]'));
    if (idx < 0) return;
    const next = this.vertical ? "ArrowDown" : "ArrowRight";
    const prev = this.vertical ? "ArrowUp" : "ArrowLeft";
    let target = null;
    if (e.key === next) {
      target = items[this.loop ? (idx + 1) % items.length : Math.min(items.length - 1, idx + 1)];
    } else if (e.key === prev) {
      target = items[this.loop ? (idx - 1 + items.length) % items.length : Math.max(0, idx - 1)];
    } else if (e.key === "Home") {
      target = items[0];
    } else if (e.key === "End") {
      target = items[items.length - 1];
    } else if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      this.commit(items[idx]);
      return;
    } else {
      return;
    }
    e.preventDefault();
    if (target) this.focusItem(target);
  },

  escape(s) {
    return String(s).replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;");
  },
};

export default ToggleGroup;
