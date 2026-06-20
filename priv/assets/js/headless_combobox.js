// HeadlessCombobox — headless combobox / autocomplete engine.
//
// A text `[data-part="input"]` filters an `[data-part="popup"]` listbox of `[data-part="item"]`
// options as you type (non-matching options get `data-hidden`). ArrowDown opens + moves a roving
// highlight (`data-highlighted` + `aria-activedescendant`), Enter/click selects (fills the input and
// a hidden `[data-part="value"]`), Escape closes. ARIA: input `role="combobox"` + `aria-expanded` +
// `aria-controls`; list `role="listbox"`; options `role="option"`.
//
// Opt-in extras (the autocomplete component uses them; combobox sets none, so they no-op):
//   root `data-autohighlight`  → highlight the first match while typing
//   root `data-filter="contains|starts_with"` → match mode (default contains)
//   `[data-part="group"]`  → group wrapper hidden (`data-hidden`) when all its items are hidden
//   `[data-part="empty"]`  → shown when the query matches nothing
//   `[data-part="status"]` → aria-live text updated with the result count
//   `[data-part="clear"]`  → button that clears the input (hidden via `data-hidden` when empty)
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

    this.sync();
  },

  destroyed() {
    document.removeEventListener("click", this.boundOutside, true);
  },

  visible() {
    return this.items().filter((i) => !i.hasAttribute("data-hidden"));
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
    // hide a group whose every item is filtered out
    this.el.querySelectorAll('[data-part="group"]').forEach((g) => {
      const any = Array.from(g.querySelectorAll('[data-part="item"]')).some(
        (i) => !i.hasAttribute("data-hidden"),
      );
      g.toggleAttribute("data-hidden", !any);
    });

    const vis = this.visible();
    const hl = this.highlighted();
    if (this.autoHighlight && q !== "") this.highlight(vis[0] || null);
    else if (hl && !vis.includes(hl)) this.highlight(null);

    this.sync();
  },

  // Reflect the current result count into the empty / status / clear parts.
  sync() {
    const total = this.items().length;
    const n = this.visible().length;
    if (this.empty) this.empty.toggleAttribute("data-hidden", !(total > 0 && n === 0));
    if (this.status) {
      this.status.textContent = n === 0 ? "No results" : `${n} result${n === 1 ? "" : "s"} available`;
    }
    if (this.clearBtn) this.clearBtn.toggleAttribute("data-hidden", this.input.value === "");
  },

  clear() {
    this.input.value = "";
    if (this.hidden) this.hidden.value = "";
    this.items().forEach((i) => i.setAttribute("aria-selected", "false"));
    this.filter();
    this.input.focus();
    this.open();
  },

  open() {
    if (this.input.disabled || !this.popup || this.popup.hasAttribute("data-open")) return;
    this.popup.toggleAttribute("data-open", true);
    this.popup.toggleAttribute("data-closed", false);
    this.input.setAttribute("aria-expanded", "true");
    if (this.autoHighlight) this.highlight(this.visible()[0] || null);
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

  onKey(e) {
    const vis = this.visible();
    const cur = vis.findIndex((i) => i.hasAttribute("data-highlighted"));

    if (e.key === "ArrowDown") {
      e.preventDefault();
      this.open();
      this.highlight(vis[Math.min(vis.length - 1, cur + 1)] || vis[0]);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      this.highlight(vis[Math.max(0, cur - 1)] || vis[vis.length - 1]);
    } else if (e.key === "Enter" && cur >= 0) {
      e.preventDefault();
      this.select(vis[cur]);
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
    if (!item) return;
    const value = item.getAttribute("data-value") || item.textContent.trim();
    this.input.value = item.textContent.trim();
    if (this.hidden) this.hidden.value = value;
    this.items().forEach((i) => i.setAttribute("aria-selected", String(i === item)));
    this.close();
    this.sync();
  },
};

export default HeadlessCombobox;
