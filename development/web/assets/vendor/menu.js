// Menu — headless menu-button engine (Base UI parity).
//
// A `[data-part="trigger"]` button opens a `[data-part="popup"]` menu anchored to it
// (side/align/offset, with edge-flip + clamp), optionally on hover. Full menu semantics:
// roving highlight + typeahead, Enter/Space activation, checkbox/radio item state, nested
// submenus (hover + ArrowRight / ArrowLeft), Escape + outside-press dismissal, focus
// management. Motion and color are 100% CSS — the hook toggles data-* state and positions.
//
// Parts (data-part): trigger, popup, submenu, submenu-trigger, submenu-popup, item,
// checkbox-item, radio-item, link-item, separator. Highlightable rows:
// item | checkbox-item | radio-item | link-item | submenu-trigger.

const HIGHLIGHTABLE =
  '[data-part="item"],[data-part="checkbox-item"],[data-part="radio-item"],[data-part="link-item"],[data-part="submenu-trigger"]';
const MENU = '[data-part="popup"],[data-part="submenu-popup"]';
const PAD = 8;

const Menu = {
  mounted() {
    this.trigger = this.el.querySelector('[data-part="trigger"]');
    this.popup = this.el.querySelector('[data-part="popup"]');
    this.disabled = this.el.getAttribute("data-disabled") === "true";
    this.side = this.el.getAttribute("data-side") || "bottom";
    this.align = this.el.getAttribute("data-align") || "start";
    this.sideOffset = parseFloat(this.el.getAttribute("data-side-offset")) || 0;
    this.alignOffset = parseFloat(this.el.getAttribute("data-align-offset")) || 0;
    this.openOnHover = this.el.getAttribute("data-open-on-hover") === "true";
    this.delay = parseFloat(this.el.getAttribute("data-delay"));
    this.closeDelay = parseFloat(this.el.getAttribute("data-close-delay"));
    if (Number.isNaN(this.delay)) this.delay = 100;
    if (Number.isNaN(this.closeDelay)) this.closeDelay = 0;
    this.loop = this.el.getAttribute("data-loop") !== "false";
    this.onOpenChange = this.el.getAttribute("data-on-open-change");
    this.onOpenChangeTarget = this.el.getAttribute("data-on-open-change-target");

    this.stack = [];
    this.typeahead = "";
    this.typeaheadAt = 0;
    this.submenuTimers = new Map();

    this.boundKeydown = (e) => this.handleKeydown(e);
    this.boundOutside = (e) => this.handleOutside(e);
    this.boundReposition = () => this.reposition();

    if (this.trigger && this.popup && this.popup.id) {
      this.trigger.setAttribute("aria-haspopup", "menu");
      this.trigger.setAttribute("aria-controls", this.popup.id);
      this.trigger.setAttribute("aria-expanded", "false");
      this.trigger.addEventListener("click", () => {
        if (this.disabled || this.trigger.hasAttribute("data-disabled")) return;
        this.isOpen() ? this.closeAll() : this.open();
      });
      this.trigger.addEventListener("keydown", (e) => this.onTriggerKeydown(e));
      if (this.openOnHover) {
        this.trigger.addEventListener("pointerenter", () => this.scheduleHoverOpen());
        this.trigger.addEventListener("pointerleave", () => this.scheduleHoverClose());
      }
    }

    this.el.addEventListener("click", (e) => this.onRowClick(e));
    this.el.addEventListener("pointermove", (e) => this.onRowHover(e));
    if (this.openOnHover && this.popup) {
      this.popup.addEventListener("pointerenter", () => this.cancelHoverClose());
      this.popup.addEventListener("pointerleave", () => this.scheduleHoverClose());
    }
  },

  destroyed() {
    this.teardownOpenListeners();
    if (this.hoverTimer) clearTimeout(this.hoverTimer);
  },

  isOpen() {
    return this.stack.length > 0;
  },

  // ---- open / close ------------------------------------------------------
  open() {
    if (this.isOpen()) return;
    this.opener = document.activeElement;
    this.positionPopup(this.popup, this.trigger.getBoundingClientRect(), this.side, this.align, this.sideOffset, this.alignOffset);
    this.openMenu(this.popup);
    this.trigger.setAttribute("aria-expanded", "true");
    this.trigger.toggleAttribute("data-popup-open", true);
    this.trigger.toggleAttribute("data-pressed", true);
    document.addEventListener("keydown", this.boundKeydown, true);
    window.addEventListener("scroll", this.boundReposition, true);
    window.addEventListener("resize", this.boundReposition);
    this.allowOutside = false;
    setTimeout(() => {
      this.allowOutside = true;
      document.addEventListener("pointerdown", this.boundOutside, true);
    }, 60);
    this.emitOpenChange(true);
    requestAnimationFrame(() => this.popup.focus({ preventScroll: true }));
  },

  closeAll(restoreFocus = true) {
    [...this.stack].reverse().forEach((m) => this.closeMenu(m));
    this.stack = [];
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", "false");
      this.trigger.toggleAttribute("data-popup-open", false);
      this.trigger.toggleAttribute("data-pressed", false);
    }
    this.teardownOpenListeners();
    this.emitOpenChange(false);
    if (restoreFocus && this.trigger) this.trigger.focus({ preventScroll: true });
  },

  teardownOpenListeners() {
    document.removeEventListener("keydown", this.boundKeydown, true);
    document.removeEventListener("pointerdown", this.boundOutside, true);
    window.removeEventListener("scroll", this.boundReposition, true);
    window.removeEventListener("resize", this.boundReposition);
    this.submenuTimers.forEach((t) => clearTimeout(t));
    this.submenuTimers.clear();
  },

  reposition() {
    if (!this.isOpen()) return;
    this.positionPopup(this.popup, this.trigger.getBoundingClientRect(), this.side, this.align, this.sideOffset, this.alignOffset);
    // reposition open submenus against their triggers
    this.stack.slice(1).forEach((p) => {
      const sub = p.closest('[data-part="submenu"]');
      const t = sub && sub.querySelector('[data-part="submenu-trigger"]');
      if (t) this.positionPopup(p, t.getBoundingClientRect(), "right", "start", 0, 0);
    });
  },

  openMenu(menu) {
    menu.hidden = false;
    menu.toggleAttribute("data-open", true);
    menu.removeAttribute("data-closed");
    menu.setAttribute("data-starting-style", "");
    requestAnimationFrame(() =>
      requestAnimationFrame(() => menu && menu.removeAttribute("data-starting-style")),
    );
    if (this.stack.indexOf(menu) === -1) this.stack.push(menu);
    this.setHighlight(menu, null);
  },

  closeMenu(menu) {
    menu.toggleAttribute("data-open", false);
    menu.setAttribute("data-closed", "");
    menu.hidden = true;
    const i = this.stack.indexOf(menu);
    if (i >= 0) this.stack.splice(i, 1);
    const sub = menu.closest('[data-part="submenu"]');
    if (sub) {
      const t = sub.querySelector('[data-part="submenu-trigger"]');
      if (t) {
        t.setAttribute("aria-expanded", "false");
        t.toggleAttribute("data-popup-open", false);
      }
    }
  },

  emitOpenChange(open) {
    if (!this.onOpenChange) return;
    if (this.onOpenChangeTarget) this.pushEventTo(this.onOpenChangeTarget, this.onOpenChange, { open });
    else this.pushEventTo(this.el, this.onOpenChange, { open });
  },

  // ---- anchored positioning (fixed; flip on the main axis + clamp) --------
  positionPopup(popup, anchor, side, align, sideOffset, alignOffset) {
    popup.style.position = "fixed";
    popup.style.left = "0px";
    popup.style.top = "0px";
    popup.style.visibility = "hidden";
    popup.hidden = false;
    popup.removeAttribute("data-closed");
    const p = popup.getBoundingClientRect();
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    let resolved = side;

    // flip on the main axis if it would overflow
    if (side === "bottom" && anchor.bottom + sideOffset + p.height > vh - PAD && anchor.top - sideOffset - p.height > PAD) resolved = "top";
    else if (side === "top" && anchor.top - sideOffset - p.height < PAD && anchor.bottom + sideOffset + p.height < vh - PAD) resolved = "bottom";
    else if (side === "right" && anchor.right + sideOffset + p.width > vw - PAD && anchor.left - sideOffset - p.width > PAD) resolved = "left";
    else if (side === "left" && anchor.left - sideOffset - p.width < PAD && anchor.right + sideOffset + p.width < vw - PAD) resolved = "right";

    let left;
    let top;
    if (resolved === "bottom" || resolved === "top") {
      top = resolved === "bottom" ? anchor.bottom + sideOffset : anchor.top - p.height - sideOffset;
      if (align === "start") left = anchor.left + alignOffset;
      else if (align === "end") left = anchor.right - p.width - alignOffset;
      else left = anchor.left + (anchor.width - p.width) / 2 + alignOffset;
    } else {
      left = resolved === "right" ? anchor.right + sideOffset : anchor.left - p.width - sideOffset;
      if (align === "start") top = anchor.top + alignOffset;
      else if (align === "end") top = anchor.bottom - p.height - alignOffset;
      else top = anchor.top + (anchor.height - p.height) / 2 + alignOffset;
    }

    left = Math.min(Math.max(left, PAD), Math.max(PAD, vw - p.width - PAD));
    top = Math.min(Math.max(top, PAD), Math.max(PAD, vh - p.height - PAD));
    popup.style.left = `${left}px`;
    popup.style.top = `${top}px`;
    popup.setAttribute("data-side", resolved);
    popup.setAttribute("data-align", align);
    popup.style.visibility = "";
  },

  // ---- hover open/close ---------------------------------------------------
  scheduleHoverOpen() {
    this.cancelHoverClose();
    if (this.isOpen()) return;
    this.hoverTimer = setTimeout(() => this.open(), this.delay);
  },

  scheduleHoverClose() {
    if (this.hoverTimer) clearTimeout(this.hoverTimer);
    this.hoverTimer = setTimeout(() => this.closeAll(false), this.closeDelay);
  },

  cancelHoverClose() {
    if (this.hoverTimer) clearTimeout(this.hoverTimer);
    this.hoverTimer = null;
  },

  handleOutside(e) {
    if (!this.allowOutside) return;
    if (this.stack.some((m) => m.contains(e.target))) return;
    if (this.trigger && this.trigger.contains(e.target)) return;
    this.closeAll(false);
  },

  // ---- rows: hover / click -----------------------------------------------
  itemsOf(menu) {
    return Array.from(menu.querySelectorAll(HIGHLIGHTABLE)).filter(
      (el) => el.closest(MENU) === menu && !el.hasAttribute("data-disabled"),
    );
  },

  activeMenu() {
    return this.stack[this.stack.length - 1] || null;
  },

  setHighlight(menu, el) {
    this.itemsOf(menu).forEach((it) => {
      const on = it === el;
      it.toggleAttribute("data-highlighted", on);
      it.tabIndex = on ? 0 : -1;
    });
    if (el && el.focus) el.focus({ preventScroll: true });
  },

  onRowHover(e) {
    const row = e.target.closest(HIGHLIGHTABLE);
    if (!row) return;
    const menu = row.closest(MENU);
    if (!menu || this.stack.indexOf(menu) === -1) return;
    if (row.hasAttribute("data-disabled")) return;
    if (this.activeMenu() === menu) this.setHighlight(menu, row);
    if (row.getAttribute("data-part") === "submenu-trigger") this.scheduleSubmenuOpen(row);
    else this.closeSiblingSubmenus(menu, null);
  },

  scheduleSubmenuOpen(trigger) {
    const sub = trigger.closest('[data-part="submenu"]');
    const popup = sub && sub.querySelector('[data-part="submenu-popup"]');
    if (!popup || this.stack.indexOf(popup) !== -1) return;
    const parentMenu = trigger.closest(MENU);
    this.closeSiblingSubmenus(parentMenu, sub);
    if (this.submenuTimers.has(trigger)) return;
    const t = setTimeout(() => {
      this.submenuTimers.delete(trigger);
      this.openSubmenu(trigger);
    }, 100);
    this.submenuTimers.set(trigger, t);
  },

  closeSiblingSubmenus(parentMenu, keepSub) {
    parentMenu.querySelectorAll('[data-part="submenu"]').forEach((s) => {
      if (s === keepSub || s.closest(MENU) !== parentMenu) return;
      const p = s.querySelector('[data-part="submenu-popup"]');
      if (p && this.stack.indexOf(p) !== -1) this.closeMenu(p);
    });
  },

  openSubmenu(trigger) {
    const sub = trigger.closest('[data-part="submenu"]');
    const popup = sub && sub.querySelector('[data-part="submenu-popup"]');
    if (!popup || this.stack.indexOf(popup) !== -1) return null;
    this.positionPopup(popup, trigger.getBoundingClientRect(), "right", "start", 0, 0);
    this.openMenu(popup);
    trigger.setAttribute("aria-expanded", "true");
    trigger.toggleAttribute("data-popup-open", true);
    return popup;
  },

  activateSubmenu(trigger, focusFirst) {
    const popup = this.openSubmenu(trigger);
    if (popup && focusFirst) {
      const first = this.itemsOf(popup)[0];
      if (first) this.setHighlight(popup, first);
      else popup.focus({ preventScroll: true });
    }
  },

  onRowClick(e) {
    const row = e.target.closest(HIGHLIGHTABLE);
    if (!row || row.hasAttribute("data-disabled")) return;
    const part = row.getAttribute("data-part");
    if (part === "submenu-trigger") {
      e.preventDefault();
      const sub = row.closest('[data-part="submenu"]');
      const p = sub && sub.querySelector('[data-part="submenu-popup"]');
      if (p && this.stack.indexOf(p) !== -1) this.closeMenu(p);
      else this.activateSubmenu(row, true);
      return;
    }
    if (part === "checkbox-item") return this.toggleCheckbox(row);
    if (part === "radio-item") return this.selectRadio(row);
    if (row.getAttribute("data-keep-open") !== "true") setTimeout(() => this.closeAll(), 0);
  },

  toggleCheckbox(item) {
    const checked = !item.hasAttribute("data-checked");
    item.toggleAttribute("data-checked", checked);
    item.toggleAttribute("data-unchecked", !checked);
    item.setAttribute("aria-checked", String(checked));
    const ind = item.querySelector('[data-part="checkbox-item-indicator"]');
    if (ind) {
      ind.toggleAttribute("data-checked", checked);
      ind.toggleAttribute("data-unchecked", !checked);
    }
    this.emitItemEvent(item, { checked });
  },

  selectRadio(item) {
    const name = item.getAttribute("data-radio-group");
    const menu = item.closest(MENU);
    let radios;
    if (name && menu) {
      radios = menu.querySelectorAll(`[data-part="radio-item"][data-radio-group="${name}"]`);
    } else {
      const group = item.closest('[data-part="radio-group"]');
      if (!group) return;
      radios = group.querySelectorAll('[data-part="radio-item"]');
    }
    radios.forEach((r) => {
      const on = r === item;
      r.toggleAttribute("data-checked", on);
      r.toggleAttribute("data-unchecked", !on);
      r.setAttribute("aria-checked", String(on));
      const ind = r.querySelector('[data-part="radio-item-indicator"]');
      if (ind) {
        ind.toggleAttribute("data-checked", on);
        ind.toggleAttribute("data-unchecked", !on);
      }
    });
    this.emitItemEvent(item, { value: item.getAttribute("data-value") });
  },

  emitItemEvent(item, payload) {
    const ev = item.getAttribute("data-on-change");
    if (!ev) return;
    const target = item.getAttribute("data-on-change-target");
    if (target) this.pushEventTo(target, ev, payload);
    else this.pushEventTo(this.el, ev, payload);
  },

  // ---- keyboard ----------------------------------------------------------
  onTriggerKeydown(e) {
    if (this.disabled) return;
    if (e.key === "ArrowDown" || e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      if (!this.isOpen()) this.open();
      requestAnimationFrame(() => {
        const items = this.itemsOf(this.popup);
        if (items[0]) this.setHighlight(this.popup, items[0]);
      });
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      if (!this.isOpen()) this.open();
      requestAnimationFrame(() => {
        const items = this.itemsOf(this.popup);
        if (items.length) this.setHighlight(this.popup, items[items.length - 1]);
      });
    }
  },

  handleKeydown(e) {
    if (!this.isOpen()) return;
    const menu = this.activeMenu();
    const items = this.itemsOf(menu);
    const current = items.find((it) => it.hasAttribute("data-highlighted"));
    const idx = current ? items.indexOf(current) : -1;
    const last = items.length - 1;
    const next = (i) => (this.loop ? (i + 1) % items.length : Math.min(i + 1, last));
    const prev = (i) => (this.loop ? (i - 1 + items.length) % items.length : Math.max(i - 1, 0));

    switch (e.key) {
      case "Escape":
        e.preventDefault();
        if (this.stack.length > 1) {
          this.closeMenu(menu);
          const owner = menu.closest('[data-part="submenu"]')?.querySelector('[data-part="submenu-trigger"]');
          if (owner) this.setHighlight(this.activeMenu(), owner);
        } else {
          this.closeAll();
        }
        return;
      case "ArrowDown":
        e.preventDefault();
        this.setHighlight(menu, items[idx === -1 ? 0 : next(idx)]);
        return;
      case "ArrowUp":
        e.preventDefault();
        this.setHighlight(menu, items[idx === -1 ? last : prev(idx)]);
        return;
      case "Home":
        e.preventDefault();
        this.setHighlight(menu, items[0]);
        return;
      case "End":
        e.preventDefault();
        this.setHighlight(menu, items[last]);
        return;
      case "ArrowRight":
        if (current && current.getAttribute("data-part") === "submenu-trigger") {
          e.preventDefault();
          this.activateSubmenu(current, true);
        }
        return;
      case "ArrowLeft":
        if (this.stack.length > 1) {
          e.preventDefault();
          this.closeMenu(menu);
          const owner = menu.closest('[data-part="submenu"]')?.querySelector('[data-part="submenu-trigger"]');
          if (owner) this.setHighlight(this.activeMenu(), owner);
        }
        return;
      case "Enter":
      case " ":
        if (current) {
          e.preventDefault();
          current.click();
        }
        return;
      case "Tab":
        this.closeAll(false);
        return;
      default:
        if (e.key.length === 1 && !e.metaKey && !e.ctrlKey && !e.altKey) this.onType(menu, items, e.key);
    }
  },

  onType(menu, items, ch) {
    this.typeahead = (performance.now() - this.typeaheadAt > 700 ? "" : this.typeahead) + ch.toLowerCase();
    this.typeaheadAt = performance.now();
    const match = items.find((it) =>
      (it.getAttribute("data-label") || it.textContent || "").trim().toLowerCase().startsWith(this.typeahead),
    );
    if (match) this.setHighlight(menu, match);
  },
};

export default Menu;
