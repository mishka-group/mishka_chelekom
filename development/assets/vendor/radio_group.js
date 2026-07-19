// RadioGroup — headless single-select radio group (Base UI parity).
//
// Roving-tabindex composite of `[data-part="item"]` `<button role="radio">`s with selection that
// FOLLOWS FOCUS (APG radio pattern): Arrow Down/Right → next, Arrow Up/Left → previous (wrapping),
// Home/End → first/last; focusing or clicking an item selects it. On selection the hook updates every
// item's `aria-checked` + `data-checked`/`data-unchecked` (mutually exclusive) + roving `tabindex`,
// writes the chosen `data-value` into the group's hidden `<input>` and dispatches a bubbling `input`
// event (so an enclosing `<.form phx-change>` reacts), and pushes `data-on-change` (`{value}`) to
// LiveView when set. `data-disabled` (group) blocks everything; `aria-readonly` blocks changing the
// selection (focus still moves); disabled items (`data-disabled`) are skipped.

const RadioGroup = {
  mounted() {
    this.hidden = this.el.querySelector('input[type="hidden"]');
    this.onChange = this.el.getAttribute("data-on-change");
    this.vertical = this.el.getAttribute("data-orientation") !== "horizontal";
    this.boundKeydown = (e) => this.onKey(e);
    this.el.addEventListener("keydown", this.boundKeydown);
    this.bindItems();
  },

  updated() {
    this.bindItems();
  },

  destroyed() {
    this.el.removeEventListener("keydown", this.boundKeydown);
  },

  disabledGroup() {
    return this.el.hasAttribute("data-disabled");
  },

  readonly() {
    return this.el.getAttribute("aria-readonly") === "true";
  },

  // All radio items, and the navigable subset (enabled only).
  allItems() {
    return Array.from(this.el.querySelectorAll('[data-part="item"]'));
  },

  items() {
    return this.allItems().filter((i) => !i.hasAttribute("data-disabled"));
  },

  bindItems() {
    this.allItems().forEach((item) => {
      if (item._rgBound) return;
      item._rgBound = true;
      item.addEventListener("click", () => this.select(item));
      item.addEventListener("focus", () => {
        this.allItems().forEach((i) => i.toggleAttribute("data-highlighted", i === item));
        if (!this.readonly() && !this.disabledGroup() && !item.hasAttribute("data-disabled")) {
          this.select(item);
        }
      });
      item.addEventListener("blur", () => item.removeAttribute("data-highlighted"));
    });
  },

  onKey(e) {
    if (this.disabledGroup()) return;
    const items = this.items();
    if (!items.length) return;
    const idx = items.indexOf(document.activeElement);

    let target = null;
    if (e.key === "ArrowDown" || e.key === "ArrowRight") {
      target = items[(Math.max(idx, 0) + 1) % items.length];
    } else if (e.key === "ArrowUp" || e.key === "ArrowLeft") {
      target = items[(Math.max(idx, 0) - 1 + items.length) % items.length];
    } else if (e.key === "Home") {
      target = items[0];
    } else if (e.key === "End") {
      target = items[items.length - 1];
    } else if ((e.key === " " || e.key === "Enter") && idx >= 0) {
      e.preventDefault();
      this.select(items[idx]);
      return;
    } else {
      return;
    }

    e.preventDefault();
    if (target) {
      this.roll(target);
      target.focus(); // focus handler selects (unless readonly)
    }
  },

  roll(target) {
    this.allItems().forEach((i) => i.setAttribute("tabindex", i === target ? "0" : "-1"));
  },

  select(item) {
    if (this.disabledGroup() || this.readonly() || item.hasAttribute("data-disabled")) return;
    const value = item.getAttribute("data-value");

    this.allItems().forEach((i) => {
      const on = i === item;
      i.setAttribute("aria-checked", String(on));
      i.toggleAttribute("data-checked", on);
      i.toggleAttribute("data-unchecked", !on);
      i.setAttribute("tabindex", on ? "0" : "-1");
    });

    if (this.hidden && this.hidden.value !== value) {
      this.hidden.value = value;
      // Notify any enclosing <.form phx-change> — the hidden input is set programmatically.
      this.hidden.dispatchEvent(new Event("input", { bubbles: true }));
    }
    if (this.onChange) this.pushEventTo(this.el, this.onChange, { value });
  },
};

export default RadioGroup;
