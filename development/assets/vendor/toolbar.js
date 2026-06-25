// Toolbar — a roving-focus bar of heterogeneous controls (Base UI / WAI-ARIA APG parity).
//
// One hook on the root `role="toolbar"` rovs focus over its items — `[data-part="button"]`,
// `[data-part="link"]` and `[data-part="input"]`, in DOM order (including those inside a
// `[data-part="group"]`) — with arrow keys along `data-orientation`, Home/End, and looping when
// `data-loop`. With `data-focusable-when-disabled` (default), DISABLED items STAY in the roving order
// (focusable but inert) so they're discoverable; clicks on disabled items are blocked. A focused
// `[data-part="input"]` keeps its own arrow-key cursor movement and only hands navigation back to the
// toolbar at the text boundaries. `data-disabled` on the root disables the whole toolbar.

const Toolbar = {
  mounted() {
    const el = this.el;
    this.vertical = el.getAttribute("data-orientation") === "vertical";
    this.loop = el.hasAttribute("data-loop");
    this.disabled = el.hasAttribute("data-disabled");
    this.focusableWhenDisabled = el.hasAttribute("data-focusable-when-disabled");

    this.boundKey = (e) => this.onKey(e);
    el.addEventListener("keydown", this.boundKey);
    // block activation of disabled items (they stay focusable, but inert)
    this.boundClick = (e) => {
      const it = e.target.closest('[data-part="button"],[data-part="link"],[data-part="input"]');
      if (it && (this.disabled || it.hasAttribute("data-disabled"))) {
        e.preventDefault();
        e.stopPropagation();
      }
    };
    el.addEventListener("click", this.boundClick, true);
    // when an item is focused (e.g. by click), make it the tabbable one
    this.boundFocus = (e) => {
      const idx = this.items().indexOf(e.target);
      if (idx >= 0) this.roll(idx);
    };
    el.addEventListener("focusin", this.boundFocus);

    this.roll(this.firstIndex());
  },

  destroyed() {
    this.el.removeEventListener("keydown", this.boundKey);
    this.el.removeEventListener("click", this.boundClick, true);
    this.el.removeEventListener("focusin", this.boundFocus);
  },

  // focusable controls in DOM order; disabled stay in the order when focusableWhenDisabled
  items() {
    return Array.from(
      this.el.querySelectorAll('[data-part="button"],[data-part="link"],[data-part="input"]'),
    ).filter((i) => this.focusableWhenDisabled || !i.hasAttribute("data-disabled"));
  },

  firstIndex() {
    const items = this.items();
    const i = items.findIndex((it) => !it.hasAttribute("data-disabled"));
    return i >= 0 ? i : 0;
  },

  roll(idx) {
    this.items().forEach((it, i) => it.setAttribute("tabindex", i === idx ? "0" : "-1"));
  },

  focusItem(idx) {
    const it = this.items()[idx];
    if (!it) return;
    this.roll(idx);
    it.focus();
  },

  onKey(e) {
    if (this.disabled) return;
    const target = e.target.closest('[data-part="button"],[data-part="link"],[data-part="input"]');
    const items = this.items();
    const cur = items.indexOf(target);
    if (cur < 0) return;

    const next = this.vertical ? "ArrowDown" : "ArrowRight";
    const prev = this.vertical ? "ArrowUp" : "ArrowLeft";

    // a text input keeps its own cursor movement; only navigate at the boundaries
    if (target.matches('[data-part="input"]') && (e.key === next || e.key === prev)) {
      const atStart = target.selectionStart === 0 && target.selectionEnd === 0;
      const atEnd = target.selectionStart === target.value.length && target.selectionEnd === target.value.length;
      if (e.key === prev && !atStart) return;
      if (e.key === next && !atEnd) return;
    }

    let idx = null;
    if (e.key === next) idx = this.loop ? (cur + 1) % items.length : Math.min(items.length - 1, cur + 1);
    else if (e.key === prev) idx = this.loop ? (cur - 1 + items.length) % items.length : Math.max(0, cur - 1);
    else if (e.key === "Home") idx = 0;
    else if (e.key === "End") idx = items.length - 1;
    else return;

    e.preventDefault();
    this.focusItem(idx);
  },
};

export default Toolbar;
