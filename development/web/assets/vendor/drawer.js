// Drawer — headless drawer engine (Base UI parity, single-level).
//
// A focus-trapped dialog that slides from an edge, PLUS:
//   • swipe-to-dismiss (pointer drag toward the dismiss edge; distance + velocity threshold)
//   • snap points (vertical bottom/top sheets — fractions / px / rem; velocity-skip or sequential)
//   • swipe-area (drag the drawer open from the screen edge while closed)
//   • page indent (iOS-style: background [data-drawer-content] scales while a drawer is open)
//   • modal: true | false | 'trap-focus'
//
// Motion is 100% CSS: the hook only toggles data-* state and writes CSS vars, so the
// consuming app owns every pixel of appearance. State contract mirrors FocusTrap
// (root+popup data-open/data-closed, trigger aria-expanded / data-popup-open).
//
// Deferred (documented limitations): nested-drawer stacks (--nested-drawers) and true
// touch scroll-lock arbitration. Touch is routed through the pointer handlers.

const FOCUSABLE =
  'a[href],button:not([disabled]),textarea:not([disabled]),input:not([disabled]),select:not([disabled]),[tabindex]:not([tabindex="-1"])';

const OPP = { up: "down", down: "up", left: "right", right: "left" };
const SIDE_DISMISS = { right: "right", left: "left", top: "up", bottom: "down" };
const EASE = "cubic-bezier(.32,.72,0,1)";

// Register the animatable custom properties once (perf: kills inheritance restyle).
(function registerProps() {
  if (typeof CSS === "undefined" || !CSS.registerProperty) return;
  const reg = (name, syntax, initialValue) => {
    try {
      CSS.registerProperty({ name, syntax, inherits: false, initialValue });
    } catch (_) {
      /* already registered (HMR/reconnect) — ignore */
    }
  };
  reg("--drawer-swipe-movement-x", "<length>", "0px");
  reg("--drawer-swipe-movement-y", "<length>", "0px");
  reg("--drawer-snap-point-offset", "<length>", "0px");
  reg("--drawer-swipe-progress", "<number>", "0");
  reg("--drawer-swipe-strength", "<number>", "1");
})();

// Module-level coordinator for the iOS page-indent effect. Tracks which drawers are
// open and toggles data-active / data-inactive on [data-drawer-content] /
// [data-drawer-background] within each drawer's [data-drawer-provider] scope.
const indent = {
  providers: new Map(), // id -> provider element
  open: new Set(), // ids of open drawers
  setOpen(id, on, providerEl) {
    if (providerEl) this.providers.set(id, providerEl);
    if (on) this.open.add(id);
    else this.open.delete(id);
    this.refresh();
  },
  remove(id) {
    this.open.delete(id);
    this.providers.delete(id);
    this.refresh();
  },
  refresh() {
    const scopes = new Set(this.providers.values());
    scopes.forEach((scope) => {
      const anyOpen = [...this.open].some((id) => this.providers.get(id) === scope);
      scope.querySelectorAll("[data-drawer-content],[data-drawer-background]").forEach((el) => {
        el.toggleAttribute("data-active", anyOpen);
        el.toggleAttribute("data-inactive", !anyOpen);
        if (!anyOpen) el.style.setProperty("--drawer-swipe-progress", "0");
      });
    });
  },
  progress(providerEl, p) {
    if (!providerEl) return;
    providerEl.querySelectorAll("[data-drawer-content]").forEach((el) => {
      el.style.setProperty("--drawer-swipe-progress", String(p));
    });
  },
};

const damp = (v) => (v < 0 ? -Math.sqrt(-v) : Math.sqrt(v));
const num = (px) => parseFloat(px) || 0;

const Drawer = {
  mounted() {
    this.trigger = this.el.querySelector('[data-part="trigger"]');
    this.popup = this.el.querySelector('[data-part="popup"]');
    this.backdrop = this.el.querySelector('[data-part="backdrop"]');
    this.swipeArea = this.el.querySelector('[data-part="swipe-area"]');
    this.provider = this.el.closest("[data-drawer-provider]");

    this.side = this.el.getAttribute("data-side") || "right";
    this.horizontal = this.side === "left" || this.side === "right";
    this.modal = this.el.getAttribute("data-modal") || "true"; // "true"|"false"|"trap-focus"
    this.trapFocus = this.modal === "true" || this.modal === "trap-focus";
    this.swipeEnabled = this.el.getAttribute("data-swipe") !== "false";
    this.closeOnEscape = this.el.getAttribute("data-close-on-escape") !== "false";
    this.closeOnOutside = this.el.getAttribute("data-close-on-outside") !== "false";
    this.onOpenChange = this.el.getAttribute("data-on-open-change");
    this.onOpenChangeTarget = this.el.getAttribute("data-on-open-change-target");
    this.onSnap = this.el.getAttribute("data-on-snap-point-change");
    this.onSnapTarget = this.el.getAttribute("data-on-snap-point-change-target");
    this.dismissDir = this.el.getAttribute("data-swipe-direction-config") || SIDE_DISMISS[this.side];

    this.snapRaw = this.parseSnap(this.el.getAttribute("data-snap-points"));
    this.sequential = this.el.getAttribute("data-snap-sequential") === "true";
    this.defaultSnap = this.el.getAttribute("data-default-snap-point");
    this.hasSnap = !this.horizontal && this.snapRaw.length > 0;
    this.activeOffset = 0;
    this.activeSnapValue = null;

    if (this.trigger) {
      this.trigger.setAttribute("aria-haspopup", "dialog");
      this.trigger.setAttribute("aria-expanded", "false");
      if (this.popup && this.popup.id) this.trigger.setAttribute("aria-controls", this.popup.id);
      this.trigger.addEventListener("click", () => {
        if (!this.trigger.hasAttribute("data-disabled")) this.open();
      });
    }

    this.boundKeydown = this.handleKeydown.bind(this);
    this.el.querySelectorAll("[data-close]").forEach((b) => b.addEventListener("click", () => this.close()));
    if (this.backdrop) {
      this.backdrop.addEventListener("click", () => {
        if (this.closeOnOutside && !this.suppressOutside) this.close();
      });
    }

    if (this.swipeEnabled && this.popup) this.bindSwipe();
    if (this.swipeArea) this.bindSwipeArea();

    this.active = false;
    if (this.el.hasAttribute("data-open")) this.activate();
    indent.setOpen(this.id(), this.el.hasAttribute("data-open"), this.provider);
    if (this.hasSnap && this.el.hasAttribute("data-open")) requestAnimationFrame(() => this.initSnap());
  },

  updated() {
    const wantsOpen = this.el.hasAttribute("data-open");
    if (wantsOpen && !this.active) this.activate();
    else if (!wantsOpen && this.active) this.deactivate();
    indent.setOpen(this.id(), wantsOpen, this.provider);
  },

  destroyed() {
    document.removeEventListener("keydown", this.boundKeydown, true);
    indent.remove(this.id());
    this.unlockScroll();
    if (this._captured != null && this.popup) {
      try { this.popup.releasePointerCapture(this._captured); } catch (_) {}
    }
  },

  id() {
    return this.el.id || (this.el.id = "drawer-" + Math.round(performance.now()));
  },

  // ---- open / close -------------------------------------------------------
  open() {
    this.setState(true);
    this.activate();
    indent.setOpen(this.id(), true, this.provider);
    if (this.hasSnap) requestAnimationFrame(() => this.initSnap());
    this.emitOpenChange(true);
  },

  close() {
    this.setState(false);
    this.deactivate();
    indent.setOpen(this.id(), false, this.provider);
    this.emitOpenChange(false);
  },

  setState(open) {
    this.el.toggleAttribute("data-open", open);
    this.el.toggleAttribute("data-closed", !open);
    if (this.popup) {
      this.popup.toggleAttribute("data-open", open);
      this.popup.toggleAttribute("data-closed", !open);
      if (open) {
        this.popup.setAttribute("data-starting-style", "");
        requestAnimationFrame(() =>
          requestAnimationFrame(() => this.popup && this.popup.removeAttribute("data-starting-style")),
        );
      }
    }
    if (this.swipeArea) {
      this.swipeArea.toggleAttribute("data-open", open);
      this.swipeArea.toggleAttribute("data-closed", !open);
    }
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", String(open));
      this.trigger.toggleAttribute("data-popup-open", open);
    }
  },

  emitOpenChange(open) {
    if (!this.onOpenChange) return;
    if (this.onOpenChangeTarget) this.pushEventTo(this.onOpenChangeTarget, this.onOpenChange, { open });
    else this.pushEventTo(this.el, this.onOpenChange, { open });
  },

  activate() {
    if (this.active) return;
    this.active = true;
    this.opener = document.activeElement;
    document.addEventListener("keydown", this.boundKeydown, true);
    if (this.modal === "true") this.lockScroll();
    if (this.trapFocus) {
      const first = this.focusables()[0] || this.popup;
      // preventScroll: the popup is still translated off-screen during the slide-in;
      // focusing it without this would scroll the page to it (a transient edge gap).
      if (first && first.focus) requestAnimationFrame(() => first.focus({ preventScroll: true }));
    }
  },

  deactivate() {
    if (!this.active) return;
    this.active = false;
    document.removeEventListener("keydown", this.boundKeydown, true);
    this.unlockScroll();
    if (this.trapFocus && this.opener && this.opener.focus) this.opener.focus();
  },

  // Lock background scroll for modal drawers. Removing the scrollbar would shift the
  // (fixed) drawer flush to the window edge AND reflow the page; pad the body by the
  // scrollbar width to compensate, so nothing jumps. Done synchronously → no transient.
  lockScroll() {
    if (this._locked) return;
    const sbw = window.innerWidth - document.documentElement.clientWidth;
    const body = document.body;
    this._prevOverflow = body.style.overflow;
    this._prevPadRight = body.style.paddingRight;
    body.style.overflow = "hidden";
    if (sbw > 0) {
      const cur = parseFloat(getComputedStyle(body).paddingRight) || 0;
      body.style.paddingRight = `${cur + sbw}px`;
    }
    this._locked = true;
  },

  unlockScroll() {
    if (!this._locked) return;
    document.body.style.overflow = this._prevOverflow || "";
    document.body.style.paddingRight = this._prevPadRight || "";
    this._locked = false;
  },

  focusables() {
    if (!this.popup) return [];
    return Array.from(this.popup.querySelectorAll(FOCUSABLE)).filter((el) => el.offsetParent !== null);
  },

  handleKeydown(e) {
    if (!this.active) return;
    if (e.key === "Escape" && this.closeOnEscape) {
      e.preventDefault();
      this.close();
      return;
    }
    if (e.key !== "Tab" || !this.trapFocus) return;
    const items = this.focusables();
    if (items.length === 0) {
      e.preventDefault();
      return;
    }
    const first = items[0];
    const last = items[items.length - 1];
    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  },

  // ---- snap points --------------------------------------------------------
  parseSnap(json) {
    if (!json) return [];
    let arr;
    try {
      arr = JSON.parse(json);
    } catch (_) {
      return [];
    }
    return Array.isArray(arr) ? arr : [];
  },

  // Resolve a raw snap value to a pixel HEIGHT of the popup.
  snapHeight(raw, viewportH, rootPx) {
    if (typeof raw === "number") {
      return raw <= 1 ? Math.max(0, Math.min(1, raw)) * viewportH : raw;
    }
    if (typeof raw === "string") {
      if (raw.endsWith("rem")) return parseFloat(raw) * rootPx;
      if (raw.endsWith("px")) return parseFloat(raw);
      const n = parseFloat(raw);
      return Number.isNaN(n) ? null : n <= 1 ? n * viewportH : n;
    }
    return null;
  },

  // Build resolved snap points {value, offset} sorted by offset (0 = full height).
  resolveSnaps() {
    const popupH = this.popup.offsetHeight;
    const viewportH = window.innerHeight;
    const rootPx = parseFloat(getComputedStyle(document.documentElement).fontSize) || 16;
    const maxH = Math.min(popupH, viewportH);
    const seen = [];
    this.snapRaw.forEach((raw) => {
      const h = this.snapHeight(raw, viewportH, rootPx);
      if (h == null) return;
      const height = Math.max(0, Math.min(h, maxH));
      const offset = Math.max(0, popupH - height);
      seen.push({ value: raw, offset, height });
    });
    seen.sort((a, b) => a.offset - b.offset);
    return seen;
  },

  initSnap() {
    if (!this.popup || !this.hasSnap) return;
    this.snaps = this.resolveSnaps();
    if (this.snaps.length === 0) return;
    let chosen = this.snaps[0];
    if (this.defaultSnap != null && this.defaultSnap !== "") {
      const match = this.snaps.find((s) => String(s.value) === String(this.defaultSnap));
      if (match) chosen = match;
    }
    this.applySnap(chosen, false);
  },

  applySnap(snap, emit) {
    this.activeOffset = snap.offset;
    this.activeSnapValue = snap.value;
    this.popup.style.setProperty("--drawer-snap-point-offset", `${snap.offset}px`);
    const expanded = snap.offset <= 1; // full-height snap
    this.popup.toggleAttribute("data-expanded", expanded);
    if (emit && this.onSnap) {
      if (this.onSnapTarget) this.pushEventTo(this.onSnapTarget, this.onSnap, { value: snap.value });
      else this.pushEventTo(this.el, this.onSnap, { value: snap.value });
    }
  },

  // ---- swipe-to-dismiss ---------------------------------------------------
  bindSwipe() {
    this.popup.addEventListener("pointerdown", (e) => this.startSwipe(e));
    this.popup.addEventListener("pointermove", (e) => this.moveSwipe(e));
    this.popup.addEventListener("pointerup", (e) => this.endSwipe(e));
    this.popup.addEventListener("pointercancel", (e) => this.endSwipe(e));
  },

  startSwipe(e) {
    if (e.button !== 0 || !this.active) return;
    if (e.target.closest("button,a,input,select,textarea,label,[role=button],[data-swipe-ignore]")) return;
    if (this.hasSnap) {
      // allow swipe even over scrollable content only at the top edge of scroll
      const sc = e.target.closest("[data-part=content]");
      if (sc && sc.scrollTop > 0) return;
    }
    this.swiping = true;
    this.firstMove = true;
    this.startX = e.clientX;
    this.startY = e.clientY;
    this.startTime = performance.now();
    this.lastSample = { x: e.clientX, y: e.clientY, t: this.startTime };
    this.sizeW = this.popup.offsetWidth;
    this.sizeH = this.popup.offsetHeight;
    try {
      this.popup.setPointerCapture(e.pointerId);
      this._captured = e.pointerId;
    } catch (_) {}
    this.popup.style.transition = "none";
    this.popup.setAttribute("data-swiping", "");
    if (this.backdrop) this.backdrop.setAttribute("data-swiping", "");
  },

  moveSwipe(e) {
    if (!this.swiping) return;
    e.preventDefault();
    if (this.firstMove) {
      this.startX = e.clientX;
      this.startY = e.clientY;
      this.firstMove = false;
    }
    const dx = e.clientX - this.startX;
    const dy = e.clientY - this.startY;
    const intended = this.dismissDir;
    // displacement along the (single) dismiss direction; perpendicular/opposite is damped
    let mx = 0;
    let my = 0;
    if (this.horizontal) {
      const along = intended === "right" ? Math.max(0, dx) : Math.min(0, dx);
      const off = intended === "right" ? Math.min(0, dx) : Math.max(0, dx);
      mx = along + damp(off);
      this.popup.style.setProperty("--drawer-swipe-movement-x", `${mx}px`);
    } else if (this.hasSnap) {
      // snap drawers: drag adjusts the offset (rubber-band past full-open)
      const next = this.activeOffset + dy;
      my = next >= 0 ? dy : -Math.sqrt(-next) - this.activeOffset;
      this.popup.style.setProperty("--drawer-swipe-movement-y", `${my}px`);
    } else {
      const along = intended === "down" ? Math.max(0, dy) : Math.min(0, dy);
      const off = intended === "down" ? Math.min(0, dy) : Math.max(0, dy);
      my = along + damp(off);
      this.popup.style.setProperty("--drawer-swipe-movement-y", `${my}px`);
    }
    if (!this.dirSet && (Math.abs(dx) > 2 || Math.abs(dy) > 2)) {
      this.popup.setAttribute("data-swipe-direction", intended);
      this.dirSet = true;
    }
    const size = this.horizontal ? this.sizeW : this.sizeH;
    const disp = this.projection(mx, my, intended);
    const progress = Math.max(0, Math.min(disp / (size || 1), 1));
    if (this.backdrop) this.backdrop.style.setProperty("--drawer-swipe-progress", String(progress));
    indent.progress(this.provider, progress);
    this.lastSample = { x: e.clientX, y: e.clientY, t: performance.now() };
  },

  projection(mx, my, dir) {
    if (dir === "right") return mx;
    if (dir === "left") return -mx;
    if (dir === "down") return my;
    return -my; // up
  },

  endSwipe(e) {
    if (!this.swiping) return;
    this.swiping = false;
    try {
      this.popup.releasePointerCapture(e.pointerId);
    } catch (_) {}
    this._captured = null;
    const now = performance.now();
    const dx = e.clientX - this.startX;
    const dy = e.clientY - this.startY;
    const dt = Math.max(now - this.startTime, 50);
    const intended = this.dismissDir;
    const size = this.horizontal ? this.sizeW : this.sizeH;

    this.popup.removeAttribute("data-swiping");
    this.popup.removeAttribute("data-swipe-direction");
    this.dirSet = false;
    if (this.backdrop) this.backdrop.removeAttribute("data-swiping");

    if (this.hasSnap) return this.endSnapDrag(dy, dt);

    const along = this.projection(this.horizontal ? dx : 0, this.horizontal ? 0 : dy, intended);
    const velocity = along / dt; // px per ms in the dismiss direction
    const dismiss = velocity >= 0.5 || along > size * 0.5;

    if (dismiss) {
      const strength = this.releaseStrength(size, along, velocity);
      this.popup.style.setProperty("--drawer-swipe-strength", String(strength));
      this.popup.setAttribute("data-swipe-dismiss", "");
      this.popup.setAttribute("data-ending-style", "");
      this.popup.style.transition = "";
      this.popup.style.removeProperty("--drawer-swipe-movement-x");
      this.popup.style.removeProperty("--drawer-swipe-movement-y");
      this.close();
      setTimeout(() => {
        if (this.popup) {
          this.popup.removeAttribute("data-swipe-dismiss");
          this.popup.removeAttribute("data-ending-style");
          this.popup.style.removeProperty("--drawer-swipe-strength");
        }
      }, 450);
    } else {
      this.snapBack();
    }
  },

  releaseStrength(size, along, velocity) {
    if (velocity <= 0.2) return 1;
    const remaining = Math.max(0, size - along);
    const t = Math.max(80, Math.min(remaining / Math.max(velocity, 0.2), 360));
    return Math.max(0.1, Math.min(0.1 + ((t - 80) / 280) * 0.9, 1));
  },

  snapBack() {
    this.popup.style.transition = "";
    this.popup.style.setProperty("--drawer-swipe-movement-x", "0px");
    this.popup.style.setProperty("--drawer-swipe-movement-y", "0px");
    if (this.backdrop) this.backdrop.style.setProperty("--drawer-swipe-progress", "1");
    indent.progress(this.provider, 1);
    requestAnimationFrame(() => {
      this.popup.style.removeProperty("--drawer-swipe-movement-x");
      this.popup.style.removeProperty("--drawer-swipe-movement-y");
    });
  },

  endSnapDrag(dy, dt) {
    this.popup.style.transition = "";
    this.popup.style.removeProperty("--drawer-swipe-movement-y");
    const popupH = this.popup.offsetHeight;
    const velocity = dy / dt; // +down
    const dragTarget = Math.max(0, Math.min(this.activeOffset + dy, popupH));
    let target = dragTarget;
    if (!this.sequential && Math.abs(velocity) >= 0.5) {
      target = Math.max(0, Math.min(dragTarget + Math.max(-4, Math.min(velocity, 4)) * 300, popupH));
    }
    // close if dragged/flicked down past the deepest snap
    const deepest = this.snaps[this.snaps.length - 1];
    if (velocity >= 0.5 && dy > 0 && Math.abs(target - popupH) < Math.abs(target - deepest.offset)) {
      return this.close();
    }
    let nearest = this.snaps[0];
    let best = Infinity;
    for (const s of this.snaps) {
      const d = Math.abs(s.offset - target);
      if (d < best) {
        best = d;
        nearest = s;
      }
    }
    if (Math.abs(target - popupH) < best) return this.close();
    this.applySnap(nearest, true);
  },

  // ---- swipe-area (open from edge) ----------------------------------------
  bindSwipeArea() {
    if (this.swipeArea.getAttribute("data-disabled") === "true") return;
    const openDir = this.swipeArea.getAttribute("data-swipe-direction") || OPP[this.dismissDir];
    this.swipeArea.style.touchAction = this.horizontal ? "pan-y" : "pan-x";
    this.swipeArea.addEventListener("pointerdown", (e) => {
      if (e.button !== 0 || this.el.hasAttribute("data-open")) return;
      this.areaSwiping = true;
      this.areaStartX = e.clientX;
      this.areaStartY = e.clientY;
      this.areaOpened = false;
      this.suppressOutside = true;
      try {
        this.swipeArea.setPointerCapture(e.pointerId);
      } catch (_) {}
      this.swipeArea.setAttribute("data-swiping", "");
      this.swipeArea.setAttribute("data-swipe-direction", openDir);
    });
    this.swipeArea.addEventListener("pointermove", (e) => {
      if (!this.areaSwiping) return;
      const dx = e.clientX - this.areaStartX;
      const dy = e.clientY - this.areaStartY;
      const disp = this.projection(dx, dy, openDir);
      if (disp < 1) return;
      if (!this.areaOpened) {
        this.open();
        this.areaOpened = true;
        this.popup.style.transition = "none";
        this.popup.setAttribute("data-swiping", "");
        if (this.backdrop) this.backdrop.setAttribute("data-swiping", "");
      }
      const closedOffset = this.horizontal ? this.popup.offsetWidth : this.popup.offsetHeight;
      const damped = disp <= closedOffset ? disp : closedOffset + Math.sqrt(disp - closedOffset);
      const sign = openDir === "left" || openDir === "up" ? -1 : 1;
      const movement = (closedOffset - damped) * sign;
      const prop = this.horizontal ? "--drawer-swipe-movement-x" : "--drawer-swipe-movement-y";
      this.popup.style.setProperty(prop, `${movement}px`);
      const openProgress = Math.max(0, Math.min(disp / (closedOffset || 1), 1));
      if (this.backdrop) this.backdrop.style.setProperty("--drawer-swipe-progress", String(openProgress));
    });
    const release = (e) => {
      if (!this.areaSwiping) return;
      this.areaSwiping = false;
      try {
        this.swipeArea.releasePointerCapture(e.pointerId);
      } catch (_) {}
      this.swipeArea.removeAttribute("data-swiping");
      this.popup.style.transition = "";
      this.popup.removeAttribute("data-swiping");
      if (this.backdrop) this.backdrop.removeAttribute("data-swiping");
      const dx = e.clientX - this.areaStartX;
      const dy = e.clientY - this.areaStartY;
      const disp = this.projection(dx, dy, openDir);
      const closedOffset = this.horizontal ? this.popup.offsetWidth : this.popup.offsetHeight;
      const prop = this.horizontal ? "--drawer-swipe-movement-x" : "--drawer-swipe-movement-y";
      this.popup.style.removeProperty(prop);
      if (this.areaOpened && disp < closedOffset * 0.5) this.close();
      setTimeout(() => (this.suppressOutside = false), 0);
    };
    this.swipeArea.addEventListener("pointerup", release);
    this.swipeArea.addEventListener("pointercancel", release);
  },
};

export default Drawer;
