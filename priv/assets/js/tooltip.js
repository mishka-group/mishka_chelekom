// Tooltip — headless tooltip engine (Base UI parity).
//
// A `[data-part="trigger"]` reveals a `role="tooltip"` `[data-part="popup"]` on hover or
// focus, anchored to it by side/align/offset (edge-flip + viewport clamp). Non-modal, never
// steals focus. Options: `hoverable` (can the mouse move into the popup), `disabled`,
// `track_cursor_axis` (popup follows the cursor on x / y / both), and a shared delay `group`
// so once one tooltip in the group is open, the others open instantly. Motion + color = CSS.

const PAD = 8;

// Shared delay groups (Base UI's TooltipProvider): a group stays "warm" while any tooltip
// in it is open and for `timeout` ms after the last closes — warm tooltips open instantly.
const groups = new Map();
function grp(id) {
  if (!groups.has(id)) groups.set(id, { open: 0, warm: false, timer: null });
  return groups.get(id);
}
function groupOnOpen(id) {
  if (!id) return;
  const g = grp(id);
  g.open += 1;
  g.warm = true;
  if (g.timer) {
    clearTimeout(g.timer);
    g.timer = null;
  }
}
function groupOnClose(id, timeout) {
  if (!id) return;
  const g = grp(id);
  g.open = Math.max(0, g.open - 1);
  if (g.open === 0 && !g.timer) {
    g.timer = setTimeout(() => {
      g.warm = false;
      g.timer = null;
    }, timeout);
  }
}
function groupWarm(id) {
  const g = id && groups.get(id);
  return !!(g && g.warm);
}

const Tooltip = {
  mounted() {
    this.trigger = this.el.querySelector('[data-part="trigger"]');
    this.popup = this.el.querySelector('[data-part="popup"]');

    this.side = this.el.getAttribute("data-side") || "top";
    this.align = this.el.getAttribute("data-align") || "center";
    this.sideOffset = parseFloat(this.el.getAttribute("data-side-offset")) || 0;
    this.alignOffset = parseFloat(this.el.getAttribute("data-align-offset")) || 0;
    this.delay = parseFloat(this.el.getAttribute("data-delay"));
    this.closeDelay = parseFloat(this.el.getAttribute("data-close-delay"));
    if (Number.isNaN(this.delay)) this.delay = 600;
    if (Number.isNaN(this.closeDelay)) this.closeDelay = 0;
    this.groupTimeout = parseFloat(this.el.getAttribute("data-group-timeout")) || 400;
    this.hoverable = this.el.getAttribute("data-hoverable") !== "false";
    this.disabled = this.el.getAttribute("data-disabled") === "true";
    this.trackAxis = this.el.getAttribute("data-track-cursor-axis") || "none";
    this.closeOnEscape = this.el.getAttribute("data-close-on-escape") !== "false";
    this.group = this.el.getAttribute("data-group");
    this.onOpenChange = this.el.getAttribute("data-on-open-change");
    this.onOpenChangeTarget = this.el.getAttribute("data-on-open-change-target");

    this.active = false;
    this.boundKeydown = (e) => this.handleKeydown(e);
    this.boundReposition = () => this.reposition();

    if (this.trigger) {
      this.trigger.addEventListener("pointerenter", () => this.scheduleOpen());
      this.trigger.addEventListener("pointerleave", () => this.scheduleClose());
      this.trigger.addEventListener("focusin", () => this.open());
      this.trigger.addEventListener("focusout", (e) => this.onFocusOut(e));
      if (this.trackAxis !== "none") {
        this.trigger.addEventListener("pointermove", (e) => this.onPointerMove(e));
      }
    }
    if (this.popup && this.hoverable) {
      this.popup.addEventListener("pointerenter", () => this.cancelClose());
      this.popup.addEventListener("pointerleave", () => this.scheduleClose());
    }

    if (this.el.hasAttribute("data-open")) this.open(true);
  },

  updated() {
    this.disabled = this.el.getAttribute("data-disabled") === "true";
    const wantsOpen = this.el.hasAttribute("data-open");
    if (wantsOpen && !this.active) this.open(true);
    else if (!wantsOpen && this.active) this.close(true);
  },

  destroyed() {
    this.teardown();
    if (this.openTimer) clearTimeout(this.openTimer);
    if (this.closeTimer) clearTimeout(this.closeTimer);
    if (this.active) groupOnClose(this.group, this.groupTimeout);
  },

  // ---- scheduling --------------------------------------------------------
  scheduleOpen() {
    if (this.disabled) return;
    this.cancelClose();
    if (this.active) return;
    const wait = groupWarm(this.group) ? 0 : this.delay;
    this.openTimer = setTimeout(() => this.open(), wait);
  },
  scheduleClose() {
    if (this.openTimer) clearTimeout(this.openTimer);
    this.closeTimer = setTimeout(() => this.close(), this.closeDelay);
  },
  cancelClose() {
    if (this.closeTimer) clearTimeout(this.closeTimer);
    this.closeTimer = null;
  },
  onFocusOut(e) {
    const to = e.relatedTarget;
    if (to && (this.trigger.contains(to) || (this.popup && this.popup.contains(to)))) return;
    this.close();
  },
  onPointerMove(e) {
    this.cursor = { x: e.clientX, y: e.clientY };
    if (this.active && this.trackAxis !== "none") this.positionPopup();
  },

  // ---- open / close ------------------------------------------------------
  open(serverDriven = false) {
    if (this.openTimer) clearTimeout(this.openTimer);
    this.cancelClose();
    if (this.active || this.disabled) return;
    this.active = true;
    groupOnOpen(this.group);
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
    if (this.trigger) this.trigger.toggleAttribute("data-popup-open", true);
    document.addEventListener("keydown", this.boundKeydown, true);
    window.addEventListener("scroll", this.boundReposition, true);
    window.addEventListener("resize", this.boundReposition);
    if (!serverDriven) this.emitOpenChange(true);
  },

  close(serverDriven = false) {
    if (this.closeTimer) clearTimeout(this.closeTimer);
    if (!this.active) return;
    this.active = false;
    groupOnClose(this.group, this.groupTimeout);
    this.popup.toggleAttribute("data-open", false);
    this.popup.setAttribute("data-closed", "");
    this.popup.hidden = true;
    this.el.toggleAttribute("data-open", false);
    this.el.toggleAttribute("data-closed", true);
    if (this.trigger) this.trigger.toggleAttribute("data-popup-open", false);
    this.teardown();
    if (!serverDriven) this.emitOpenChange(false);
  },

  teardown() {
    document.removeEventListener("keydown", this.boundKeydown, true);
    window.removeEventListener("scroll", this.boundReposition, true);
    window.removeEventListener("resize", this.boundReposition);
  },

  reposition() {
    if (this.active) this.positionPopup();
  },

  emitOpenChange(open) {
    if (!this.onOpenChange) return;
    if (this.onOpenChangeTarget) this.pushEventTo(this.onOpenChangeTarget, this.onOpenChange, { open });
    else this.pushEvent(this.onOpenChange, { open });
  },

  handleKeydown(e) {
    if (this.active && e.key === "Escape" && this.closeOnEscape) this.close();
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

    const t = this.trigger.getBoundingClientRect();
    const a = { left: t.left, right: t.right, top: t.top, bottom: t.bottom, width: t.width, height: t.height };
    if (this.trackAxis !== "none" && this.cursor) {
      if (this.trackAxis === "x" || this.trackAxis === "both") {
        a.left = a.right = this.cursor.x;
        a.width = 0;
      }
      if (this.trackAxis === "y" || this.trackAxis === "both") {
        a.top = a.bottom = this.cursor.y;
        a.height = 0;
      }
    }

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
};

export default Tooltip;
