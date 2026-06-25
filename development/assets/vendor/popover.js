// Popover — headless popover engine (Base UI parity).
//
// A `[data-part="trigger"]` button toggles an anchored `[data-part="popup"]` (role=dialog)
// panel of arbitrary content, positioned by side/align/offset with edge-flip + viewport
// clamp (repositioned on scroll/resize). Optional hover-open. `modal`:
//   • false (default) — page stays interactive; outside click / Escape dismiss; focus moves
//     into the popup and returns to the trigger.
//   • "trap-focus"    — focus trapped; page scrollable; outside pointers live.
//   • true            — focus trapped, background scroll locked, a backdrop dims the page.
// initial_focus / final_focus override what's focused on open / close. Motion + color are
// 100% CSS — the hook only toggles data-* state and positions.

const FOCUSABLE =
  'a[href],button:not([disabled]),textarea:not([disabled]),input:not([disabled]),select:not([disabled]),[tabindex]:not([tabindex="-1"])';
const PAD = 8;

let scrollLocks = 0;
let savedOverflow = "";
let savedPadRight = "";
function lockScrollGlobal() {
  if (scrollLocks === 0) {
    const body = document.body;
    const sbw = window.innerWidth - document.documentElement.clientWidth;
    savedOverflow = body.style.overflow;
    savedPadRight = body.style.paddingRight;
    body.style.overflow = "hidden";
    if (sbw > 0) body.style.paddingRight = `${(parseFloat(getComputedStyle(body).paddingRight) || 0) + sbw}px`;
  }
  scrollLocks += 1;
}
function unlockScrollGlobal() {
  scrollLocks = Math.max(0, scrollLocks - 1);
  if (scrollLocks === 0) {
    document.body.style.overflow = savedOverflow;
    document.body.style.paddingRight = savedPadRight;
  }
}

const Popover = {
  mounted() {
    this.trigger = this.el.querySelector('[data-part="trigger"]');
    this.popup = this.el.querySelector('[data-part="popup"]');
    this.backdrop = this.el.querySelector('[data-part="backdrop"]');

    this.side = this.el.getAttribute("data-side") || "bottom";
    this.align = this.el.getAttribute("data-align") || "center";
    this.sideOffset = parseFloat(this.el.getAttribute("data-side-offset")) || 0;
    this.alignOffset = parseFloat(this.el.getAttribute("data-align-offset")) || 0;
    this.modal = this.el.getAttribute("data-modal") || "false"; // false | true | trap-focus
    this.trapFocus = this.modal !== "false";
    this.openOnHover = this.el.getAttribute("data-open-on-hover") === "true";
    this.delay = parseFloat(this.el.getAttribute("data-delay"));
    this.closeDelay = parseFloat(this.el.getAttribute("data-close-delay"));
    if (Number.isNaN(this.delay)) this.delay = 300;
    if (Number.isNaN(this.closeDelay)) this.closeDelay = 0;
    this.closeOnEscape = this.el.getAttribute("data-close-on-escape") !== "false";
    this.closeOnOutside = this.el.getAttribute("data-close-on-outside") !== "false";
    this.disabled = this.el.getAttribute("data-disabled") === "true";
    this.initialFocusSel = this.el.getAttribute("data-initial-focus");
    this.finalFocusSel = this.el.getAttribute("data-final-focus");
    this.onOpenChange = this.el.getAttribute("data-on-open-change");
    this.onOpenChangeTarget = this.el.getAttribute("data-on-open-change-target");

    this.active = false;
    this.boundKeydown = (e) => this.handleKeydown(e);
    this.boundOutside = (e) => this.handleOutside(e);
    this.boundReposition = () => this.reposition();

    if (this.trigger && this.popup && this.popup.id) {
      this.trigger.setAttribute("aria-haspopup", "dialog");
      this.trigger.setAttribute("aria-controls", this.popup.id);
      this.trigger.setAttribute("aria-expanded", "false");
      this.trigger.addEventListener("click", () => {
        if (this.disabled || this.trigger.hasAttribute("data-disabled")) return;
        this.active ? this.close() : this.open();
      });
      if (this.openOnHover) {
        this.trigger.addEventListener("pointerenter", () => this.scheduleHoverOpen());
        this.trigger.addEventListener("pointerleave", () => this.scheduleHoverClose());
      }
    }

    if (this.openOnHover && this.popup) {
      this.popup.addEventListener("pointerenter", () => this.cancelHoverClose());
      this.popup.addEventListener("pointerleave", () => this.scheduleHoverClose());
    }
    if (this.backdrop) this.backdrop.addEventListener("click", () => this.closeOnOutside && this.close());
    this.el.querySelectorAll("[data-close]").forEach((b) => b.addEventListener("click", () => this.close()));

    if (this.el.hasAttribute("data-open")) this.open();
  },

  updated() {
    const wantsOpen = this.el.hasAttribute("data-open");
    if (wantsOpen && !this.active) this.open(true);
    else if (!wantsOpen && this.active) this.close(true);
  },

  destroyed() {
    this.teardown();
    if (this.hoverTimer) clearTimeout(this.hoverTimer);
  },

  // ---- open / close ------------------------------------------------------
  open(serverDriven = false) {
    if (this.active) return;
    this.active = true;
    this.opener = document.activeElement;
    this.positionPopup();
    this.popup.hidden = false;
    this.popup.toggleAttribute("data-open", true);
    this.popup.removeAttribute("data-closed");
    this.popup.setAttribute("data-starting-style", "");
    requestAnimationFrame(() =>
      requestAnimationFrame(() => this.popup && this.popup.removeAttribute("data-starting-style")),
    );
    this.el.toggleAttribute("data-open", true);
    this.el.toggleAttribute("data-closed", false);
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", "true");
      this.trigger.toggleAttribute("data-popup-open", true);
      this.trigger.toggleAttribute("data-pressed", true);
    }
    if (this.modal === "true") {
      lockScrollGlobal();
      this._locked = true;
    }
    document.addEventListener("keydown", this.boundKeydown, true);
    window.addEventListener("scroll", this.boundReposition, true);
    window.addEventListener("resize", this.boundReposition);
    this.allowOutside = false;
    setTimeout(() => {
      this.allowOutside = true;
      document.addEventListener("pointerdown", this.boundOutside, true);
    }, 60);
    const target = this.initialFocusEl() || this.focusables()[0] || this.popup;
    if (target && target.focus) requestAnimationFrame(() => target.focus({ preventScroll: true }));
    if (!serverDriven) this.emitOpenChange(true);
  },

  close(serverDriven = false) {
    if (!this.active) return;
    this.active = false;
    this.popup.toggleAttribute("data-open", false);
    this.popup.setAttribute("data-closed", "");
    this.popup.hidden = true;
    this.el.toggleAttribute("data-open", false);
    this.el.toggleAttribute("data-closed", true);
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", "false");
      this.trigger.toggleAttribute("data-popup-open", false);
      this.trigger.toggleAttribute("data-pressed", false);
    }
    this.teardown();
    const target = this.finalFocusEl() || this.trigger || this.opener;
    if (target && target.focus) target.focus({ preventScroll: true });
    if (!serverDriven) this.emitOpenChange(false);
  },

  teardown() {
    document.removeEventListener("keydown", this.boundKeydown, true);
    document.removeEventListener("pointerdown", this.boundOutside, true);
    window.removeEventListener("scroll", this.boundReposition, true);
    window.removeEventListener("resize", this.boundReposition);
    if (this._locked) {
      unlockScrollGlobal();
      this._locked = false;
    }
  },

  reposition() {
    if (this.active) this.positionPopup();
  },

  emitOpenChange(open) {
    if (!this.onOpenChange) return;
    if (this.onOpenChangeTarget) this.pushEventTo(this.onOpenChangeTarget, this.onOpenChange, { open });
    else this.pushEvent(this.onOpenChange, { open });
  },

  // ---- anchored positioning (fixed; flip on the main axis + clamp) --------
  positionPopup() {
    const popup = this.popup;
    popup.style.position = "fixed";
    popup.style.left = "0px";
    popup.style.top = "0px";
    popup.style.visibility = "hidden";
    popup.hidden = false;
    popup.removeAttribute("data-closed");
    const a = this.trigger.getBoundingClientRect();
    const p = popup.getBoundingClientRect();
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const off = this.sideOffset;
    let side = this.side;

    if (side === "bottom" && a.bottom + off + p.height > vh - PAD && a.top - off - p.height > PAD) side = "top";
    else if (side === "top" && a.top - off - p.height < PAD && a.bottom + off + p.height < vh - PAD) side = "bottom";
    else if (side === "right" && a.right + off + p.width > vw - PAD && a.left - off - p.width > PAD) side = "left";
    else if (side === "left" && a.left - off - p.width < PAD && a.right + off + p.width < vw - PAD) side = "right";

    let left;
    let top;
    if (side === "bottom" || side === "top") {
      top = side === "bottom" ? a.bottom + off : a.top - p.height - off;
      if (this.align === "start") left = a.left + this.alignOffset;
      else if (this.align === "end") left = a.right - p.width - this.alignOffset;
      else left = a.left + (a.width - p.width) / 2 + this.alignOffset;
    } else {
      left = side === "right" ? a.right + off : a.left - p.width - off;
      if (this.align === "start") top = a.top + this.alignOffset;
      else if (this.align === "end") top = a.bottom - p.height - this.alignOffset;
      else top = a.top + (a.height - p.height) / 2 + this.alignOffset;
    }

    left = Math.min(Math.max(left, PAD), Math.max(PAD, vw - p.width - PAD));
    top = Math.min(Math.max(top, PAD), Math.max(PAD, vh - p.height - PAD));
    popup.style.left = `${left}px`;
    popup.style.top = `${top}px`;
    popup.setAttribute("data-side", side);
    popup.setAttribute("data-align", this.align);
    popup.style.visibility = "";
  },

  // ---- hover open/close ---------------------------------------------------
  scheduleHoverOpen() {
    this.cancelHoverClose();
    if (this.active) return;
    this.hoverTimer = setTimeout(() => this.open(), this.delay);
  },
  scheduleHoverClose() {
    if (this.hoverTimer) clearTimeout(this.hoverTimer);
    this.hoverTimer = setTimeout(() => this.close(), this.closeDelay);
  },
  cancelHoverClose() {
    if (this.hoverTimer) clearTimeout(this.hoverTimer);
    this.hoverTimer = null;
  },

  // ---- focus + dismiss ---------------------------------------------------
  focusables() {
    if (!this.popup) return [];
    return Array.from(this.popup.querySelectorAll(FOCUSABLE)).filter((el) => el.offsetParent !== null);
  },
  initialFocusEl() {
    if (!this.initialFocusSel || this.initialFocusSel === "false") {
      return this.initialFocusSel === "false" ? this.popup : null;
    }
    try {
      return this.popup.querySelector(this.initialFocusSel) || document.querySelector(this.initialFocusSel);
    } catch (_) {
      return null;
    }
  },
  finalFocusEl() {
    if (!this.finalFocusSel) return null;
    try {
      return document.querySelector(this.finalFocusSel);
    } catch (_) {
      return null;
    }
  },

  handleOutside(e) {
    if (!this.allowOutside || !this.closeOnOutside) return;
    if (this.popup.contains(e.target)) return;
    if (this.trigger && this.trigger.contains(e.target)) return;
    this.close();
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
      last.focus({ preventScroll: true });
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus({ preventScroll: true });
    }
  },
};

export default Popover;
