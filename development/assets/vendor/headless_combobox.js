// HeadlessCombobox — headless combobox / autocomplete engine.
//
// A text `[data-part="input"]` filters an `[data-part="popup"]` listbox of
// `[data-part="item"]` options as you type (options whose text doesn't match get
// `data-hidden`). ArrowDown opens + moves through visible options (roving via
// `data-highlighted` + `aria-activedescendant`), Enter/click selects (fills the input and a
// hidden `[data-part="value"]`, closes), Escape closes. ARIA: input `role="combobox"` +
// `aria-expanded` + `aria-controls`; list `role="listbox"`; options `role="option"`.
//
// Distinct from the styled `Combobox` hook (combobox.js); this backs the headless `combobox`
// and `autocomplete` components.

const HeadlessCombobox = {
  mounted() {
    this.input = this.el.querySelector('[data-part="input"]');
    this.popup = this.el.querySelector('[data-part="popup"]');
    this.hidden = this.el.querySelector('[data-part="value"]');
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
  },

  destroyed() {
    document.removeEventListener("click", this.boundOutside, true);
  },

  visible() {
    return this.items().filter((i) => !i.hasAttribute("data-hidden"));
  },

  filter() {
    const q = this.input.value.trim().toLowerCase();
    this.items().forEach((it) => {
      const match = it.textContent.toLowerCase().includes(q);
      it.toggleAttribute("data-hidden", q !== "" && !match);
    });
  },

  open() {
    if (!this.popup || this.popup.hasAttribute("data-open")) return;
    this.popup.toggleAttribute("data-open", true);
    this.popup.toggleAttribute("data-closed", false);
    this.input.setAttribute("aria-expanded", "true");
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
  },
};

export default HeadlessCombobox;
