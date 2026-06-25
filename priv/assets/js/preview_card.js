// PreviewCard — headless hover-card engine (Base UI parity).
//
// A `[data-part="trigger"]` (usually a link) reveals a `[data-part="popup"]` preview on
// hover or focus, anchored to it by side/align/offset (edge-flip + viewport clamp,
// repositioned on scroll/resize). Unlike the popover, it is NON-modal and never steals
// focus: pointer-leave (with a close delay) / blur / Escape dismiss it, and moving the
// pointer INTO the popup keeps it open. Motion + color are 100% CSS.

const PAD = 8;

const PreviewCard = {
  mounted() {
    this.trigger = this.el.querySelector('[data-part="trigger"]');
    this.popup = this.el.querySelector('[data-part="popup"]');

    this.side = this.el.getAttribute("data-side") || "bottom";
    this.align = this.el.getAttribute("data-align") || "center";
    this.sideOffset = parseFloat(this.el.getAttribute("data-side-offset")) || 0;
    this.alignOffset = parseFloat(this.el.getAttribute("data-align-offset")) || 0;
    this.delay = parseFloat(this.el.getAttribute("data-delay"));
    this.closeDelay = parseFloat(this.el.getAttribute("data-close-delay"));
    if (Number.isNaN(this.delay)) this.delay = 600;
    if (Number.isNaN(this.closeDelay)) this.closeDelay = 300;
    this.closeOnEscape = this.el.getAttribute("data-close-on-escape") !== "false";
    this.onOpenChange = this.el.getAttribute("data-on-open-change");
    this.onOpenChangeTarget = this.el.getAttribute("data-on-open-change-target");

    this.active = false;
    this.boundKeydown = (e) => this.handleKeydown(e);
    this.boundReposition = () => this.reposition();

    if (this.trigger && this.popup && this.popup.id) {
      this.trigger.setAttribute("aria-expanded", "false");
      this.trigger.addEventListener("pointerenter", () => this.scheduleOpen());
      this.trigger.addEventListener("pointerleave", () => this.scheduleClose());
      this.trigger.addEventListener("focusin", () => this.open());
      this.trigger.addEventListener("focusout", (e) => this.onFocusOut(e));
    }
    if (this.popup) {
      this.popup.addEventListener("pointerenter", () => this.cancelClose());
      this.popup.addEventListener("pointerleave", () => this.scheduleClose());
    }

    if (this.el.hasAttribute("data-open")) this.open(true);
  },

  updated() {
    const wantsOpen = this.el.hasAttribute("data-open");
    if (wantsOpen && !this.active) this.open(true);
    else if (!wantsOpen && this.active) this.close(true);
  },

  destroyed() {
    this.teardown();
    if (this.openTimer) clearTimeout(this.openTimer);
    if (this.closeTimer) clearTimeout(this.closeTimer);
  },

  // ---- scheduling --------------------------------------------------------
  scheduleOpen() {
    this.cancelClose();
    if (this.active) return;
    this.openTimer = setTimeout(() => this.open(), this.delay);
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
    // close only when focus leaves both the trigger and the popup
    const to = e.relatedTarget;
    if (to && (this.trigger.contains(to) || (this.popup && this.popup.contains(to)))) return;
    this.scheduleClose();
  },

  // ---- open / close ------------------------------------------------------
  open(serverDriven = false) {
    if (this.openTimer) clearTimeout(this.openTimer);
    this.cancelClose();
    if (this.active) return;
    this.active = true;
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
    }
    document.addEventListener("keydown", this.boundKeydown, true);
    window.addEventListener("scroll", this.boundReposition, true);
    window.addEventListener("resize", this.boundReposition);
    if (!serverDriven) this.emitOpenChange(true);
  },

  close(serverDriven = false) {
    if (this.closeTimer) clearTimeout(this.closeTimer);
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
    }
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
    if (this.active && e.key === "Escape" && this.closeOnEscape) {
      e.preventDefault();
      this.close();
    }
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
    // Pin the arrow to the popup edge, centered on the trigger (Base UI's Arrow does this inside the
    // component, so the demo's arrow class stays verbatim — no stylesheet needed).
    const arrow = popup.querySelector('[data-part="arrow"]');
    if (arrow) {
      const center = `${-arrow.offsetWidth / 2}px`;
      const vertical = side === "left" || side === "right";
      arrow.setAttribute("data-side", side);
      arrow.style.position = "absolute";
      arrow.style.left = vertical ? "" : "50%";
      arrow.style.marginLeft = vertical ? "" : center;
      arrow.style.top = vertical ? "50%" : "";
      arrow.style.marginTop = vertical ? center : "";
    }
    popup.style.visibility = "";
  },
};

export default PreviewCard;
