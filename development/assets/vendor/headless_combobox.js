// HeadlessCombobox — headless combobox / autocomplete engine.
//
// A text `[data-part="input"]` filters an `[data-part="popup"]` listbox of `[data-part="item"]`
// options as you type (non-matching options get `data-hidden`). ArrowDown opens + moves a roving
// highlight (`data-highlighted` + `aria-activedescendant`) over the NAVIGABLE options (skipping
// `data-hidden` and `data-disabled`); Enter/click selects (a selected item gets `data-selected` +
// `aria-selected`), Escape closes. ARIA: input `role="combobox"` + `aria-expanded` + `aria-controls`;
// list `role="listbox"`; options `role="option"`.
//
// Opt-in extras (each is gated by an attribute/part, so components that don't use them no-op):
//   root `data-multiple`       → multi-select: clicking toggles selection, renders chips, keeps open
//   root `data-creatable`      → show `[data-part="create"]` for the typed query (pushes data-on-create)
//   root `data-autohighlight`  → highlight the first match while typing
//   root `data-filter="contains|starts_with"` → match mode (default contains)
//   root `data-on-change="ev"` → push selected value(s) to LiveView on every change
//   `[data-part="trigger"]`    → button that opens/closes the popup
//   `[data-part="clear"]`      → clears the query/selection (hidden when empty)
//   `[data-part="empty"]`      → shown when nothing matches
//   `[data-part="status"]`     → aria-live result count
//   `[data-part="group"]`      → hidden when all its items are filtered out
//   `[data-part="chips"]` + `<template data-part="chip-template">` → multi-select chips (with `[data-chip-label]`
//                                and a `[data-part="chip-remove"]` button); each chip carries data-chip-value
//
// Distinct from the styled `Combobox` hook (combobox.js); this backs the headless `combobox`
// and `autocomplete` components.

const HeadlessCombobox = {
  mounted() {
    this.input = this.el.querySelector('[data-part="input"]');
    this.popup = this.el.querySelector('[data-part="popup"]');
    this.hidden = this.el.querySelector('[data-part="value"]');
    this.empty = this.el.querySelector('[data-part="empty"]');
    this.status = this.el.querySelector('[data-part="status"]');
    this.clearBtn = this.el.querySelector('[data-part="clear"]');
    this.trigger = this.el.querySelector('[data-part="trigger"]');
    this.chips = this.el.querySelector('[data-part="chips"]');
    this.chipTpl = this.el.querySelector('template[data-part="chip-template"]');
    this.createBtn = this.el.querySelector('[data-part="create"]');
    this.multiple = this.el.hasAttribute("data-multiple");
    this.creatable = this.el.hasAttribute("data-creatable");
    this.name = this.el.getAttribute("data-name");
    this.autoHighlight = this.el.hasAttribute("data-autohighlight");
    this.filterMode = this.el.getAttribute("data-filter") || "contains";
    this.items = () => Array.from(this.el.querySelectorAll('[data-part="item"]'));

    if (this.popup && this.popup.id) {
      this.input.setAttribute("role", "combobox");
      this.input.setAttribute("aria-controls", this.popup.id);
      this.input.setAttribute("aria-expanded", "false");
      this.input.setAttribute("aria-autocomplete", "list");
    }

    this.input.addEventListener("input", () => {
      this.filter();
      this.open();
    });
    this.input.addEventListener("focus", () => this.open());
    this.input.addEventListener("keydown", (e) => this.onKey(e));
    this.boundOutside = (e) => {
      if (!this.el.contains(e.target)) this.close();
    };

    this.items().forEach((it) => it.addEventListener("click", () => this.select(it)));
    if (this.clearBtn) this.clearBtn.addEventListener("click", () => this.clear());
    if (this.trigger) this.trigger.addEventListener("click", () => this.toggle());
    if (this.createBtn) this.createBtn.addEventListener("click", () => this.create());
    if (this.chips) {
      this.chips.addEventListener("click", (e) => {
        const rm = e.target.closest('[data-part="chip-remove"]');
        const chip = rm && rm.closest('[data-part="chip"]');
        if (chip) this.deselectValue(chip.getAttribute("data-chip-value"));
      });
    }

    this.sync();
  },

  destroyed() {
    document.removeEventListener("click", this.boundOutside, true);
  },

  valueOf(item) {
    return item.getAttribute("data-value") || item.textContent.trim();
  },

  // Filterable (not hidden) vs navigable (not hidden AND not disabled).
  visible() {
    return this.items().filter((i) => !i.hasAttribute("data-hidden"));
  },

  navigable() {
    return this.items().filter(
      (i) => !i.hasAttribute("data-hidden") && !i.hasAttribute("data-disabled"),
    );
  },

  highlighted() {
    return this.items().find((i) => i.hasAttribute("data-highlighted")) || null;
  },

  match(text, q) {
    return this.filterMode === "starts_with" ? text.startsWith(q) : text.includes(q);
  },

  filter() {
    const q = this.input.value.trim().toLowerCase();
    this.items().forEach((it) => {
      const hit = this.match(it.textContent.toLowerCase(), q);
      it.toggleAttribute("data-hidden", q !== "" && !hit);
    });
    this.el.querySelectorAll('[data-part="group"]').forEach((g) => {
      const any = Array.from(g.querySelectorAll('[data-part="item"]')).some(
        (i) => !i.hasAttribute("data-hidden"),
      );
      g.toggleAttribute("data-hidden", !any);
    });

    const nav = this.navigable();
    const hl = this.highlighted();
    if (this.autoHighlight && q !== "") this.highlight(nav[0] || null);
    else if (hl && !nav.includes(hl)) this.highlight(null);

    this.sync();
  },

  // Reflect result count into the empty / status / clear / create parts.
  sync() {
    const total = this.items().length;
    const n = this.visible().length;
    const q = this.input.value.trim();
    if (this.empty) this.empty.toggleAttribute("data-hidden", !(total > 0 && n === 0));
    if (this.status) {
      this.status.textContent =
        n === 0 ? "No results" : `${n} result${n === 1 ? "" : "s"} available`;
    }
    if (this.clearBtn) {
      const hasSelection = this.items().some((i) => i.getAttribute("aria-selected") === "true");
      this.clearBtn.toggleAttribute("data-hidden", q === "" && !hasSelection);
    }
    if (this.createBtn) {
      const exact = this.items().some((i) => i.textContent.trim().toLowerCase() === q.toLowerCase());
      this.createBtn.toggleAttribute("data-hidden", !(this.creatable && q !== "" && !exact));
      this.createBtn.querySelectorAll("[data-create-label]").forEach((el) => (el.textContent = q));
    }
  },

  clear() {
    this.input.value = "";
    if (this.hidden) this.hidden.value = "";
    this.items().forEach((i) => {
      i.setAttribute("aria-selected", "false");
      i.removeAttribute("data-selected");
    });
    if (this.chips) this.chips.querySelectorAll('[data-part="chip"]').forEach((c) => c.remove());
    this.filter();
    this.emit();
    this.input.focus();
    this.open();
  },

  open() {
    if (this.input.disabled || !this.popup || this.popup.hasAttribute("data-open")) return;
    this.popup.toggleAttribute("data-open", true);
    this.popup.toggleAttribute("data-closed", false);
    this.input.setAttribute("aria-expanded", "true");
    if (this.autoHighlight) this.highlight(this.navigable()[0] || null);
    document.addEventListener("click", this.boundOutside, true);
  },

  close() {
    if (!this.popup) return;
    this.popup.toggleAttribute("data-open", false);
    this.popup.toggleAttribute("data-closed", true);
    this.input.setAttribute("aria-expanded", "false");
    this.highlight(null);
    document.removeEventListener("click", this.boundOutside, true);
  },

  toggle() {
    if (this.popup && this.popup.hasAttribute("data-open")) this.close();
    else {
      this.open();
      this.input.focus();
    }
  },

  onKey(e) {
    const nav = this.navigable();
    const cur = nav.findIndex((i) => i.hasAttribute("data-highlighted"));

    if (e.key === "ArrowDown") {
      e.preventDefault();
      this.open();
      this.highlight(nav[Math.min(nav.length - 1, cur + 1)] || nav[0]);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      this.open();
      this.highlight(nav[Math.max(0, cur - 1)] || nav[nav.length - 1]);
    } else if (e.key === "Enter") {
      if (cur >= 0) {
        e.preventDefault();
        this.select(nav[cur]);
      } else if (this.creatable && this.createBtn && !this.createBtn.hasAttribute("data-hidden")) {
        e.preventDefault();
        this.create();
      }
    } else if (e.key === "Escape") {
      this.close();
    }
  },

  highlight(item) {
    this.items().forEach((i) => i.toggleAttribute("data-highlighted", i === item));
    if (item && item.id) this.input.setAttribute("aria-activedescendant", item.id);
    else this.input.removeAttribute("aria-activedescendant");
  },

  select(item) {
    if (!item || item.hasAttribute("data-disabled")) return;
    const value = this.valueOf(item);
    const label = item.textContent.trim();

    if (this.multiple) {
      const selected = item.getAttribute("aria-selected") === "true";
      item.setAttribute("aria-selected", String(!selected));
      item.toggleAttribute("data-selected", !selected);
      if (selected) this.removeChip(value);
      else this.addChip(value, label);
      this.input.value = "";
      this.filter();
      this.input.focus();
    } else {
      this.input.value = label;
      if (this.hidden) this.hidden.value = value;
      this.items().forEach((i) => {
        const on = i === item;
        i.setAttribute("aria-selected", String(on));
        i.toggleAttribute("data-selected", on);
      });
      this.close();
    }
    this.emit();
    this.sync();
  },

  addChip(value, label) {
    if (!this.chips || !this.chipTpl) return;
    if (this.chips.querySelector(`[data-chip-value="${CSS.escape(value)}"]`)) return;
    const frag = this.chipTpl.content.cloneNode(true);
    const chip = frag.querySelector('[data-part="chip"]');
    if (!chip) return;
    chip.setAttribute("data-chip-value", value);
    chip.querySelectorAll("[data-chip-label]").forEach((el) => (el.textContent = label));
    // Wire the chip's hidden input so an interactively-added selection actually submits (name[]).
    const input = chip.querySelector("[data-chip-input]");
    if (input && this.name) {
      input.setAttribute("name", `${this.name}[]`);
      input.value = value;
    }
    this.chips.appendChild(frag);
  },

  removeChip(value) {
    const chip = this.chips && this.chips.querySelector(`[data-chip-value="${CSS.escape(value)}"]`);
    if (chip) chip.remove();
  },

  deselectValue(value) {
    const item = this.items().find((i) => this.valueOf(i) === value);
    if (item) {
      item.setAttribute("aria-selected", "false");
      item.removeAttribute("data-selected");
    }
    this.removeChip(value);
    this.emit();
    this.sync();
    this.input.focus();
  },

  create() {
    const q = this.input.value.trim();
    if (!q) return;
    const ev = this.el.getAttribute("data-on-create");
    if (ev) this.pushEvent(ev, { value: q });
    this.input.value = "";
    this.filter();
  },

  // Push selected value(s) to LiveView: an array in multiple mode, a single value (or null) otherwise.
  emit() {
    const ev = this.el.getAttribute("data-on-change");
    if (!ev) return;
    if (this.multiple) {
      const value = this.items()
        .filter((i) => i.getAttribute("aria-selected") === "true")
        .map((i) => this.valueOf(i));
      this.pushEvent(ev, { value });
    } else {
      const sel = this.items().find((i) => i.getAttribute("aria-selected") === "true");
      this.pushEvent(ev, { value: sel ? this.valueOf(sel) : null });
    }
  },
};

export default HeadlessCombobox;
