// Menubar — a coordinated bar of menus (Base UI / WAI-ARIA APG menubar parity).
//
// One hook on the root `role="menubar"` owns: roving tabindex over the top-level `[data-part="trigger"]`
// buttons (arrow keys along `data-orientation`, Home/End, looping when `data-loop`), opening/closing the
// per-menu `[data-part="popup"]`, and — the defining menubar behaviour — switching the open menu when
// the pointer enters (or the arrow keys reach) a different trigger while a menu is already open.
//
// Inside an open menu: Arrow Up/Down move between `[role="menuitem"]`/`[data-part="item"]`, Home/End jump,
// Escape closes back to the trigger, and the cross-axis arrow opens the menu / left-right hops to the
// adjacent menu. Activating an item closes the menu. Reflects Base UI state: root `data-has-submenu-open`
// + `data-modal` + `data-orientation`; the active trigger gets `data-popup-open` + `data-pressed`; the
// popup `data-open`/`data-closed` (positioning + hide are the consumer's CSS, like the styled menubar).

const Menubar = {
  mounted() {
    const el = this.el;
    this.vertical = el.getAttribute("data-orientation") === "vertical";
    this.loop = el.hasAttribute("data-loop");
    this.disabled = el.hasAttribute("data-disabled");

    this.menus = Array.from(el.querySelectorAll('[data-part="menu"]')).map((menu) => ({
      menu,
      trigger: menu.querySelector('[data-part="trigger"]'),
      popup: menu.querySelector('[data-part="popup"]'),
    }));
    this.openIndex = -1;

    this.boundOutside = (e) => {
      if (!el.contains(e.target)) this.closeAll();
    };

    this.menus.forEach((m, i) => {
      if (!m.trigger) return;
      m.trigger.addEventListener("click", (e) => {
        e.stopPropagation();
        this.onTriggerClick(i);
      });
      m.trigger.addEventListener("pointerenter", () => this.onTriggerEnter(i));
      m.trigger.addEventListener("keydown", (e) => this.onTriggerKey(e, i));
      if (m.popup) {
        m.popup.addEventListener("keydown", (e) => this.onPopupKey(e, i));
        // pointer over an item highlights it (shares the keyboard highlight state)
        m.popup.addEventListener("pointermove", (e) => {
          const it = e.target.closest('[role="menuitem"],[data-part="item"]');
          if (it && !it.hasAttribute("data-disabled") && !it.hasAttribute("disabled")) this.setHighlighted(i, it);
        });
        // activating any item closes the menu (the item's own phx-click still fires)
        m.popup.addEventListener("click", (e) => {
          if (e.target.closest('[role="menuitem"],[data-part="item"]')) this.close(i, false);
        });
      }
    });

    this.roll(this.firstEnabled());
  },

  destroyed() {
    document.removeEventListener("click", this.boundOutside, true);
  },

  // ---- helpers --------------------------------------------------------------

  enabled(i) {
    return this.menus[i].trigger && !this.menus[i].trigger.hasAttribute("data-disabled");
  },

  enabledTriggers() {
    return this.menus.map((_, i) => i).filter((i) => this.enabled(i));
  },

  firstEnabled() {
    return this.enabledTriggers()[0] ?? 0;
  },

  roll(focusIndex) {
    this.menus.forEach((m, i) => {
      if (m.trigger) m.trigger.setAttribute("tabindex", i === focusIndex ? "0" : "-1");
    });
  },

  items(i) {
    return Array.from(this.menus[i].popup.querySelectorAll('[role="menuitem"],[data-part="item"]')).filter(
      (it) => !it.hasAttribute("data-disabled") && !it.hasAttribute("disabled"),
    );
  },

  focusFirstItem(i) {
    const it = this.items(i)[0];
    if (it) requestAnimationFrame(() => this.focusInItem(i, it));
  },

  // focus an item + mark it the highlighted one (data-highlighted), clearing its siblings
  focusInItem(i, item) {
    if (!item) return;
    item.focus();
    this.setHighlighted(i, item);
  },

  setHighlighted(i, target) {
    this.menus[i].popup
      .querySelectorAll('[role="menuitem"],[data-part="item"]')
      .forEach((it) => it.toggleAttribute("data-highlighted", it === target));
  },

  // ---- open / close ---------------------------------------------------------

  onTriggerClick(i) {
    if (this.disabled || !this.enabled(i)) return;
    if (this.openIndex === i) this.close(i, true);
    else this.open(i);
  },

  onTriggerEnter(i) {
    // menubar mode: with a menu already open, hovering another trigger switches to it
    if (this.openIndex !== -1 && this.openIndex !== i && this.enabled(i)) this.open(i);
  },

  open(i) {
    if (this.disabled || !this.enabled(i)) return;
    if (this.openIndex !== -1 && this.openIndex !== i) this.close(this.openIndex, false);

    const m = this.menus[i];
    m.popup.toggleAttribute("data-open", true);
    m.popup.toggleAttribute("data-closed", false);
    m.trigger.setAttribute("aria-expanded", "true");
    m.trigger.toggleAttribute("data-popup-open", true);
    m.trigger.toggleAttribute("data-pressed", true);

    this.openIndex = i;
    this.el.toggleAttribute("data-has-submenu-open", true);
    this.roll(i);
    m.trigger.focus();
    document.addEventListener("click", this.boundOutside, true);
  },

  close(i, focusTrigger) {
    const m = this.menus[i];
    if (!m) return;
    m.popup.toggleAttribute("data-open", false);
    m.popup.toggleAttribute("data-closed", true);
    m.popup
      .querySelectorAll("[data-highlighted]")
      .forEach((it) => it.removeAttribute("data-highlighted"));
    m.trigger.setAttribute("aria-expanded", "false");
    m.trigger.removeAttribute("data-popup-open");
    m.trigger.removeAttribute("data-pressed");

    if (this.openIndex === i) {
      this.openIndex = -1;
      this.el.removeAttribute("data-has-submenu-open");
      document.removeEventListener("click", this.boundOutside, true);
    }
    if (focusTrigger) m.trigger.focus();
  },

  closeAll() {
    if (this.openIndex !== -1) this.close(this.openIndex, false);
  },

  // ---- keyboard -------------------------------------------------------------

  onTriggerKey(e, i) {
    const next = this.vertical ? "ArrowDown" : "ArrowRight";
    const prev = this.vertical ? "ArrowUp" : "ArrowLeft";
    const openKey = this.vertical ? "ArrowRight" : "ArrowDown";

    if (e.key === next) {
      e.preventDefault();
      this.step(i, +1);
    } else if (e.key === prev) {
      e.preventDefault();
      this.step(i, -1);
    } else if (e.key === "Home") {
      e.preventDefault();
      this.focusTrigger(this.enabledTriggers()[0]);
    } else if (e.key === "End") {
      e.preventDefault();
      const t = this.enabledTriggers();
      this.focusTrigger(t[t.length - 1]);
    } else if (e.key === openKey || e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      this.open(i);
      this.focusFirstItem(i);
    } else if (e.key === "Escape") {
      this.closeAll();
    }
  },

  // move focus to the adjacent trigger; if a menu is open, switch the open menu too
  step(from, dir) {
    const triggers = this.enabledTriggers();
    const pos = triggers.indexOf(from);
    let np = pos + dir;
    np = this.loop
      ? (np + triggers.length) % triggers.length
      : Math.max(0, Math.min(triggers.length - 1, np));
    const ni = triggers[np];
    if (ni === from) return;
    if (this.openIndex !== -1) {
      this.open(ni);
      this.focusFirstItem(ni);
    } else {
      this.focusTrigger(ni);
    }
  },

  focusTrigger(i) {
    this.roll(i);
    this.menus[i].trigger.focus();
  },

  onPopupKey(e, i) {
    const items = this.items(i);
    const cur = items.indexOf(document.activeElement);

    if (e.key === "ArrowDown") {
      e.preventDefault();
      this.moveItem(i, items, cur, +1);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      this.moveItem(i, items, cur, -1);
    } else if (e.key === "Home") {
      e.preventDefault();
      this.focusInItem(i, items[0]);
    } else if (e.key === "End") {
      e.preventDefault();
      this.focusInItem(i, items[items.length - 1]);
    } else if (e.key === "Escape") {
      e.preventDefault();
      this.close(i, true);
    } else if (e.key === "Tab") {
      this.closeAll();
    } else if (!this.vertical && (e.key === "ArrowRight" || e.key === "ArrowLeft")) {
      // hop to the adjacent top-level menu from inside a popup
      e.preventDefault();
      this.step(i, e.key === "ArrowRight" ? +1 : -1);
    }
  },

  moveItem(i, items, cur, dir) {
    if (!items.length) return;
    let n = cur + dir;
    if (n < 0) n = items.length - 1;
    if (n >= items.length) n = 0;
    this.focusInItem(i, items[n]);
  },
};

export default Menubar;
