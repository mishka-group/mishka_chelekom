// RovingTabindex — headless composite navigation engine (tabs / menu / listbox / toolbar).
//
// Keeps exactly one `[data-part="item"]` with tabindex=0; arrow keys (+ Home/End) move
// focus among items and roll the tabindex. Set `data-orientation="vertical"` for Up/Down
// (default is horizontal: Left/Right). With `data-activate-on-focus` (tabs), focusing an
// item selects it: toggles `aria-selected` and shows the matching panel (by aria-controls).
//
// State: item `tabindex`, `data-highlighted`, and (when selecting) `aria-selected`;
// panel `data-open` | `data-closed`. Disabled items (`data-disabled`) are skipped.

const RovingTabindex = {
  mounted() {
    this.vertical = this.el.getAttribute("data-orientation") === "vertical";
    this.activateOnFocus = this.el.hasAttribute("data-activate-on-focus");
    this.boundKeydown = this.handleKeydown.bind(this);

    this.refresh();
    this.el.addEventListener("keydown", this.boundKeydown);
  },

  updated() {
    this.refresh();
  },

  destroyed() {
    this.el.removeEventListener("keydown", this.boundKeydown);
  },

  refresh() {
    this.items = Array.from(this.el.querySelectorAll('[data-part="item"]')).filter(
      (i) => !i.hasAttribute("data-disabled")
    );

    let active = this.items.findIndex(
      (i) => i.getAttribute("aria-selected") === "true" || i.hasAttribute("data-active")
    );
    if (active < 0) active = 0;

    this.items.forEach((item, i) => {
      item.setAttribute("tabindex", i === active ? "0" : "-1");
      if (!item._rtBound) {
        item.addEventListener("click", () => this.activate(item));
        item.addEventListener("focus", () => {
          if (this.activateOnFocus) this.activate(item);
        });
        item._rtBound = true;
      }
    });
  },

  handleKeydown(e) {
    const next = this.vertical ? "ArrowDown" : "ArrowRight";
    const prev = this.vertical ? "ArrowUp" : "ArrowLeft";
    const idx = this.items.indexOf(document.activeElement);
    if (idx < 0 && !["Home", "End"].includes(e.key)) return;

    let target = null;
    if (e.key === next) target = this.items[(idx + 1) % this.items.length];
    else if (e.key === prev)
      target = this.items[(idx - 1 + this.items.length) % this.items.length];
    else if (e.key === "Home") target = this.items[0];
    else if (e.key === "End") target = this.items[this.items.length - 1];
    else if ((e.key === "Enter" || e.key === " ") && idx >= 0)
      return this.activate(this.items[idx]);
    else return;

    e.preventDefault();
    if (target) {
      this.roll(target);
      target.focus();
    }
  },

  roll(target) {
    this.items.forEach((item) =>
      item.setAttribute("tabindex", item === target ? "0" : "-1")
    );
  },

  activate(item) {
    this.roll(item);
    this.items.forEach((i) => {
      const selected = i === item;
      if (i.hasAttribute("aria-selected")) i.setAttribute("aria-selected", String(selected));
      if (i.hasAttribute("aria-checked")) i.setAttribute("aria-checked", String(selected));
      i.toggleAttribute("data-highlighted", selected);

      const panelId = i.getAttribute("aria-controls");
      const panel = panelId ? document.getElementById(panelId) : null;
      if (panel) {
        panel.toggleAttribute("data-open", selected);
        panel.toggleAttribute("data-closed", !selected);
      }
    });
  },
};

export default RovingTabindex;
