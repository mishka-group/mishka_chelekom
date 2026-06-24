// ContextMenu — headless context-menu engine (Base UI parity).
//
// Opens a `[data-part="popup"]` menu at the cursor on right-click (contextmenu) or touch
// long-press, positioned `fixed` and clamped to the viewport. Full menu semantics: roving
// highlight + typeahead, Enter/Space activation, checkbox/radio item state, nested submenus
// (hover + ArrowRight / ArrowLeft), Escape + outside-press dismissal, focus restore. Motion
// and color are 100% CSS — the hook only toggles data-* state and positions popups.
//
// Parts (data-part): trigger, popup, submenu, submenu-trigger, submenu-popup, item,
// checkbox-item, radio-group, radio-item, link-item, separator. Highlightable rows:
// item | checkbox-item | radio-item | link-item | submenu-trigger.

const HIGHLIGHTABLE =
  '[data-part="item"],[data-part="checkbox-item"],[data-part="radio-item"],[data-part="link-item"],[data-part="submenu-trigger"]';
const LONG_PRESS = 500;
const MENU = '[data-part="popup"],[data-part="submenu-popup"]';

const ContextMenu = {
  mounted() {
    this.trigger = this.el.querySelector('[data-part="trigger"]');
    this.popup = this.el.querySelector('[data-part="popup"]');
    this.disabled = this.el.getAttribute("data-disabled") === "true";
    this.onOpenChange = this.el.getAttribute("data-on-open-change");
    this.onOpenChangeTarget = this.el.getAttribute("data-on-open-change-target");

    this.stack = []; // open menu elements, root popup first
    this.typeahead = "";
    this.typeaheadAt = 0;
    this.submenuTimers = new Map();

    this.boundKeydown = (e) => this.handleKeydown(e);
    this.boundOutside = (e) => this.handleOutside(e);
    this.boundDocCtx = (e) => this.suppressNativeMenu(e);

    if (this.popup && this.popup.id && this.trigger) {
      this.trigger.setAttribute("aria-haspopup", "menu");
      this.trigger.setAttribute("aria-controls", this.popup.id);
      this.trigger.setAttribute("aria-expanded", "false");
    }
    if (this.trigger) {
      this.trigger.style.webkitTouchCallout = "none";
      this.trigger.addEventListener("contextmenu", (e) => this.onContextMenu(e));
      this.trigger.addEventListener("touchstart", (e) => this.onTouchStart(e), { passive: true });
      this.trigger.addEventListener("touchmove", (e) => this.onTouchMove(e), { passive: true });
      this.trigger.addEventListener("touchend", () => this.cancelLongPress());
      this.trigger.addEventListener("touchcancel", () => this.cancelLongPress());
    }

    // Wire interactive rows (event delegation on the whole root covers nested popups too).
    this.el.addEventListener("click", (e) => this.onRowClick(e));
    this.el.addEventListener("pointermove", (e) => this.onRowHover(e));

    document.addEventListener("contextmenu", this.boundDocCtx, true);
  },

  destroyed() {
    document.removeEventListener("contextmenu", this.boundDocCtx, true);
    this.teardownOpenListeners();
    this.cancelLongPress();
  },

  // ---- opening -----------------------------------------------------------
  onContextMenu(e) {
    if (this.disabled) return;
    e.preventDefault();
    e.stopPropagation();
    this.openAt(e.clientX, e.clientY);
  },

  suppressNativeMenu(e) {
    // Kill the browser's native menu on a second right-click over our trigger/menu.
    if (this.disabled) return;
    if (
      (this.trigger && this.trigger.contains(e.target)) ||
      this.stack.some((m) => m.contains(e.target))
    ) {
      e.preventDefault();
    }
  },

  onTouchStart(e) {
    if (this.disabled || e.touches.length !== 1) return;
    const t = e.touches[0];
    this.touchPoint = { x: t.clientX, y: t.clientY };
    this.longPressTimer = setTimeout(() => {
      this.openAt(this.touchPoint.x, this.touchPoint.y);
    }, LONG_PRESS);
  },

  onTouchMove(e) {
    if (!this.longPressTimer || !this.touchPoint) return;
    const t = e.touches[0];
    if (Math.abs(t.clientX - this.touchPoint.x) > 10 || Math.abs(t.clientY - this.touchPoint.y) > 10) {
      this.cancelLongPress();
    }
  },

  cancelLongPress() {
    if (this.longPressTimer) clearTimeout(this.longPressTimer);
    this.longPressTimer = null;
    this.touchPoint = null;
  },

  openAt(x, y) {
    const wasOpen = this.stack.length > 0;
    if (wasOpen) this.closeAll(false);
    this.opener = document.activeElement;
    this.placeMenu(this.popup, x, y, null);
    this.openMenu(this.popup);
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", "true");
      this.trigger.toggleAttribute("data-popup-open", true);
    }
    if (!wasOpen) {
      document.addEventListener("keydown", this.boundKeydown, true);
      // Grace period: ignore the opening gesture's trailing pointer events.
      this.allowOutside = false;
      setTimeout(() => {
        this.allowOutside = true;
        document.addEventListener("pointerdown", this.boundOutside, true);
      }, 60);
      this.emitOpenChange(true);
    }
    requestAnimationFrame(() => this.popup.focus({ preventScroll: true }));
  },

  // Position a fixed menu at (x,y), clamped to the viewport (flip near edges).
  placeMenu(menu, x, y, anchorRect) {
    menu.style.position = "fixed";
    menu.style.left = "0px";
    menu.style.top = "0px";
    menu.style.visibility = "hidden";
    menu.hidden = false;
    menu.removeAttribute("data-closed");
    const r = menu.getBoundingClientRect();
    const pad = 8;
    let left = x;
    let top = y;
    if (anchorRect) {
      left = anchorRect.right; // submenu opens to the right of its trigger
      top = anchorRect.top;
      if (left + r.width > window.innerWidth - pad) left = anchorRect.left - r.width;
    } else {
      if (left + r.width > window.innerWidth - pad) left = Math.max(pad, x - r.width);
      if (top + r.height > window.innerHeight - pad) top = Math.max(pad, y - r.height);
    }
    left = Math.min(Math.max(left, pad), window.innerWidth - r.width - pad);
    top = Math.min(Math.max(top, pad), window.innerHeight - r.height - pad);
    menu.style.left = `${left}px`;
    menu.style.top = `${top}px`;
    menu.style.visibility = "";
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
    // collapse the submenu-trigger that owns this submenu
    const sub = menu.closest('[data-part="submenu"]');
    if (sub) {
      const t = sub.querySelector('[data-part="submenu-trigger"]');
      if (t) {
        t.setAttribute("aria-expanded", "false");
        t.toggleAttribute("data-popup-open", false);
      }
    }
  },

  closeAll(restoreFocus = true) {
    [...this.stack].reverse().forEach((m) => this.closeMenu(m));
    this.stack = [];
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", "false");
      this.trigger.toggleAttribute("data-popup-open", false);
    }
    this.teardownOpenListeners();
    this.emitOpenChange(false);
    if (restoreFocus && this.opener && this.opener.focus) this.opener.focus({ preventScroll: true });
  },

  teardownOpenListeners() {
    document.removeEventListener("keydown", this.boundKeydown, true);
    document.removeEventListener("pointerdown", this.boundOutside, true);
    this.submenuTimers.forEach((t) => clearTimeout(t));
    this.submenuTimers.clear();
  },

  emitOpenChange(open) {
    if (!this.onOpenChange) return;
    if (this.onOpenChangeTarget) this.pushEventTo(this.onOpenChangeTarget, this.onOpenChange, { open });
    else this.pushEvent(this.onOpenChange, { open });
  },

  handleOutside(e) {
    if (!this.allowOutside) return;
    if (this.stack.some((m) => m.contains(e.target))) return;
    if (this.trigger && this.trigger.contains(e.target)) return;
    this.closeAll();
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
    // submenu open-on-hover (with a small delay); close sibling submenus
    if (row.getAttribute("data-part") === "submenu-trigger") {
      this.scheduleSubmenuOpen(row);
    } else {
      this.closeSiblingSubmenus(menu, null);
    }
  },

  scheduleSubmenuOpen(trigger) {
    const sub = trigger.closest('[data-part="submenu"]');
    const popup = sub && sub.querySelector('[data-part="submenu-popup"]');
    if (!popup || this.stack.indexOf(popup) !== -1) return;
    const parentMenu = trigger.closest(MENU);
    this.closeSiblingSubmenus(parentMenu, sub);
    const key = trigger;
    if (this.submenuTimers.has(key)) return;
    const t = setTimeout(() => {
      this.submenuTimers.delete(key);
      this.openSubmenu(trigger);
    }, 100);
    this.submenuTimers.set(key, t);
  },

  closeSiblingSubmenus(parentMenu, keepSub) {
    parentMenu.querySelectorAll('[data-part="submenu"]').forEach((s) => {
      if (s === keepSub) return;
      if (s.closest(MENU) !== parentMenu) return;
      const p = s.querySelector('[data-part="submenu-popup"]');
      if (p && this.stack.indexOf(p) !== -1) this.closeMenu(p);
    });
  },

  openSubmenu(trigger) {
    const sub = trigger.closest('[data-part="submenu"]');
    const popup = sub && sub.querySelector('[data-part="submenu-popup"]');
    if (!popup || this.stack.indexOf(popup) !== -1) return;
    this.placeMenu(popup, 0, 0, trigger.getBoundingClientRect());
    this.openMenu(popup);
    trigger.setAttribute("aria-expanded", "true");
    trigger.toggleAttribute("data-popup-open", true);
    return popup;
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
    if (part === "checkbox-item") {
      this.toggleCheckbox(row);
      return; // stays open
    }
    if (part === "radio-item") {
      this.selectRadio(row);
      return; // stays open
    }
    // item / link-item: let the consumer's phx-click / navigation run, then close.
    if (row.getAttribute("data-keep-open") !== "true") {
      setTimeout(() => this.closeAll(), 0);
    }
  },

  activateSubmenu(trigger, focusFirst) {
    const popup = this.openSubmenu(trigger);
    if (popup && focusFirst) {
      const first = this.itemsOf(popup)[0];
      if (first) this.setHighlight(popup, first);
      else popup.focus({ preventScroll: true });
    }
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
    const group = item.closest('[data-part="radio-group"]');
    if (!group) return;
    group.querySelectorAll('[data-part="radio-item"]').forEach((r) => {
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
    else this.pushEvent(ev, payload);
  },

  // ---- keyboard ----------------------------------------------------------
  handleKeydown(e) {
    if (this.stack.length === 0) return;
    const menu = this.activeMenu();
    const items = this.itemsOf(menu);
    const current = items.find((it) => it.hasAttribute("data-highlighted"));
    const idx = current ? items.indexOf(current) : -1;

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
        this.setHighlight(menu, items[(idx + 1) % items.length] || items[0]);
        return;
      case "ArrowUp":
        e.preventDefault();
        this.setHighlight(menu, items[(idx - 1 + items.length) % items.length] || items[items.length - 1]);
        return;
      case "Home":
        e.preventDefault();
        this.setHighlight(menu, items[0]);
        return;
      case "End":
        e.preventDefault();
        this.setHighlight(menu, items[items.length - 1]);
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
        e.preventDefault();
        this.closeAll();
        return;
      default:
        if (e.key.length === 1 && !e.metaKey && !e.ctrlKey && !e.altKey) {
          this.onType(menu, items, e.key);
        }
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

export default ContextMenu;
