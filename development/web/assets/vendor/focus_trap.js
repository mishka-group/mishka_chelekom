// FocusTrap — headless dialog / alert-dialog behavior engine (Base UI parity).
//
// Client-driven by default: a `[data-part="trigger"]` opens the dialog, focus is trapped
// inside `[data-part="popup"]`, and Escape / backdrop / `[data-close]` close it, restoring
// focus to the opener. The server can also drive open/close by toggling `data-open` — see
// updated(). Supports Base UI's `modal` modes, scroll-lock, initial/final focus, nested
// dialogs, and an enter animation hook.
//
// Options (read from data-* on the root):
//   data-modal               "true" (default) | "false" | "trap-focus"
//   data-close-on-escape     "false" disables Escape
//   data-close-on-outside    "false" disables outside-press dismissal
//   data-on-open-change[-target]   LiveView event ({open}) + optional pushEventTo target
//   data-initial-focus       selector focused on open (default: first focusable)
//   data-final-focus         selector focused on close (default: the opener)
//
// State contract (paired-presence): root + popup (+ viewport) carry data-open|data-closed;
// the popup gains data-starting-style during the enter transition; the trigger gets
// aria-expanded / data-popup-open. Nested dialogs get data-nested / data-nested-dialog-open
// and --nested-dialogs (a count) on the popup.

const FOCUSABLE =
  'a[href],button:not([disabled]),textarea:not([disabled]),input:not([disabled]),select:not([disabled]),[tabindex]:not([tabindex="-1"])';

// Registry of currently-open dialogs — drives nested-dialog data attributes.
const openDialogs = [];

function refreshNested() {
  openDialogs.forEach((d) => {
    if (!d.popup) return;
    let nestedCount = 0;
    let isNested = false;
    openDialogs.forEach((o) => {
      if (o === d || !o.popup) return;
      if (d.popup.contains(o.popup)) nestedCount += 1;
      if (o.popup.contains(d.popup)) isNested = true;
    });
    [d.popup, d.viewport].forEach((el) => {
      if (!el) return;
      el.toggleAttribute("data-nested", isNested);
      el.toggleAttribute("data-nested-dialog-open", nestedCount > 0);
    });
    d.popup.style.setProperty("--nested-dialogs", String(nestedCount));
  });
}

// Shared scroll-lock (ref-counted so stacked modals don't unlock prematurely).
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
    if (sbw > 0) {
      const cur = parseFloat(getComputedStyle(body).paddingRight) || 0;
      body.style.paddingRight = `${cur + sbw}px`;
    }
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

const FocusTrap = {
  mounted() {
    this.trigger = this.el.querySelector('[data-part="trigger"]');
    this.popup = this.el.querySelector('[data-part="popup"]');
    this.backdrop = this.el.querySelector('[data-part="backdrop"]');
    this.viewport = this.el.querySelector('[data-part="viewport"]');

    this.modal = this.el.getAttribute("data-modal") || "true"; // true | false | trap-focus
    this.trapFocus = this.modal !== "false";
    this.closeOnEscape = this.el.getAttribute("data-close-on-escape") !== "false";
    this.closeOnOutside = this.el.getAttribute("data-close-on-outside") !== "false";
    this.onOpenChange = this.el.getAttribute("data-on-open-change");
    this.onOpenChangeTarget = this.el.getAttribute("data-on-open-change-target");
    this.initialFocusSel = this.el.getAttribute("data-initial-focus");
    this.finalFocusSel = this.el.getAttribute("data-final-focus");

    this.boundKeydown = this.handleKeydown.bind(this);
    this.boundClose = () => this.close();
    this.boundOutside = (e) => this.handleOutside(e);

    if (this.trigger) {
      this.trigger.setAttribute("aria-haspopup", "dialog");
      this.trigger.setAttribute("aria-expanded", "false");
      if (this.popup && this.popup.id) {
        this.trigger.setAttribute("aria-controls", this.popup.id);
      }
      this.trigger.addEventListener("click", () => {
        if (!this.trigger.hasAttribute("data-disabled")) this.open();
      });
    }

    if (this.backdrop && this.closeOnOutside) {
      this.backdrop.addEventListener("click", this.boundClose);
    }

    this.el.querySelectorAll("[data-close]").forEach((b) =>
      b.addEventListener("click", this.boundClose),
    );

    this.active = false;
    if (this.el.hasAttribute("data-open")) this.activate();
  },

  updated() {
    const wantsOpen = this.el.hasAttribute("data-open");
    if (wantsOpen && !this.active) this.activate();
    else if (!wantsOpen && this.active) this.deactivate();
  },

  destroyed() {
    document.removeEventListener("keydown", this.boundKeydown, true);
    document.removeEventListener("pointerdown", this.boundOutside, true);
    this.unlockScroll();
    this.unregister();
  },

  open() {
    this.setState(true);
    this.activate();
    this.emitOpenChange(true);
  },

  close() {
    this.setState(false);
    this.deactivate();
    this.emitOpenChange(false);
  },

  emitOpenChange(open) {
    if (!this.onOpenChange) return;
    if (this.onOpenChangeTarget) this.pushEventTo(this.onOpenChangeTarget, this.onOpenChange, { open });
    else this.pushEventTo(this.el, this.onOpenChange, { open });
  },

  setState(open) {
    this.el.toggleAttribute("data-open", open);
    this.el.toggleAttribute("data-closed", !open);
    [this.popup, this.viewport].forEach((el) => {
      if (!el) return;
      el.toggleAttribute("data-open", open);
      el.toggleAttribute("data-closed", !open);
      if (open) {
        el.setAttribute("data-starting-style", "");
        requestAnimationFrame(() =>
          requestAnimationFrame(() => el && el.removeAttribute("data-starting-style")),
        );
      }
    });
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", String(open));
      this.trigger.toggleAttribute("data-popup-open", open);
    }
  },

  activate() {
    if (this.active) return;
    this.active = true;
    this.opener = document.activeElement;
    document.addEventListener("keydown", this.boundKeydown, true);
    if (this.modal === "true") this.lockScroll();
    // Non-modal dialogs have no backdrop to click — dismiss via a document listener.
    if (this.modal !== "true" && this.closeOnOutside) {
      document.addEventListener("pointerdown", this.boundOutside, true);
    }
    this.register();
    if (this.trapFocus) {
      const first = this.initialFocusEl() || this.focusables()[0] || this.popup;
      if (first && first.focus) requestAnimationFrame(() => first.focus({ preventScroll: true }));
    }
  },

  deactivate() {
    if (!this.active) return;
    this.active = false;
    document.removeEventListener("keydown", this.boundKeydown, true);
    document.removeEventListener("pointerdown", this.boundOutside, true);
    this.unlockScroll();
    this.unregister();
    const final = this.finalFocusEl() || this.opener;
    if (final && final.focus) final.focus({ preventScroll: true });
  },

  register() {
    if (openDialogs.indexOf(this) === -1) openDialogs.push(this);
    refreshNested();
  },

  unregister() {
    const i = openDialogs.indexOf(this);
    if (i >= 0) openDialogs.splice(i, 1);
    refreshNested();
  },

  lockScroll() {
    if (this._locked) return;
    lockScrollGlobal();
    this._locked = true;
  },

  unlockScroll() {
    if (!this._locked) return;
    unlockScrollGlobal();
    this._locked = false;
  },

  initialFocusEl() {
    if (!this.initialFocusSel || this.initialFocusSel === "false") {
      return this.initialFocusSel === "false" ? this.popup : null;
    }
    try {
      return (this.popup && this.popup.querySelector(this.initialFocusSel)) ||
        document.querySelector(this.initialFocusSel);
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
    if (!this.active || !this.popup) return;
    if (this.popup.contains(e.target)) return;
    if (this.trigger && this.trigger.contains(e.target)) return;
    this.close();
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
      last.focus({ preventScroll: true });
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus({ preventScroll: true });
    }
  },
};

export default FocusTrap;
