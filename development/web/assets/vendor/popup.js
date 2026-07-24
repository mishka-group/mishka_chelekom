// Popup — headless floating + dismissal engine (popover / menu / tooltip / select).
//
// A `[data-part="trigger"]` opens a `[data-part="popup"]`; outside-click and Escape close
// it. `data-trigger="hover"` (tooltip) opens on hover/focus instead of click and never traps
// focus. Positioning is lightweight: the popup is placed on the side given by
// `data-side` (top|right|bottom|left, default bottom) with `data-align` (start|center|end).
//
// State: trigger `aria-expanded`, `aria-controls`; popup `data-open` | `data-closed`,
// `data-side`. The engine also exposes the resolved side via the `--chelekom-side` CSS var.

const Popup = {
  mounted() {
    // A submenu trigger is a roving menu item (`data-part="item"`) AND a popup trigger, so
    // fall back to an `aria-haspopup` element when there's no explicit `[data-part="trigger"]`.
    this.trigger =
      this.el.querySelector('[data-part="trigger"]') || this.el.querySelector("[aria-haspopup]");
    this.popup = this.el.querySelector('[data-part="popup"]');
    const mode = this.el.getAttribute("data-trigger");
    this.hover = mode === "hover";
    this.contextmenu = mode === "contextmenu";
    this.side = this.el.getAttribute("data-side") || "bottom";
    this.align = this.el.getAttribute("data-align") || "center";

    this.boundOutside = this.handleOutside.bind(this);
    this.boundKeydown = this.handleKeydown.bind(this);

    if (this.trigger && this.popup) {
      if (this.popup.id) this.trigger.setAttribute("aria-controls", this.popup.id);
      this.trigger.setAttribute("aria-expanded", "false");

      if (this.hover) {
        ["mouseenter", "focusin"].forEach((ev) =>
          this.el.addEventListener(ev, () => this.show())
        );
        ["mouseleave", "focusout"].forEach((ev) =>
          this.el.addEventListener(ev, () => this.hide())
        );
      } else if (this.contextmenu) {
        this.trigger.addEventListener("contextmenu", (e) => {
          e.preventDefault();
          this.point = { x: e.clientX, y: e.clientY };
          this.isOpen() ? this.hide() : this.show();
        });
      } else {
        this.trigger.addEventListener("click", (e) => {
          e.stopPropagation();
          this.isOpen() ? this.hide() : this.show();
        });
      }
    }
  },

  destroyed() {
    document.removeEventListener("click", this.boundOutside, true);
    document.removeEventListener("keydown", this.boundKeydown, true);
  },

  isOpen() {
    return this.popup && this.popup.hasAttribute("data-open");
  },

  show() {
    if (!this.popup || this.isOpen()) return;
    this.popup.toggleAttribute("data-open", true);
    this.popup.toggleAttribute("data-closed", false);
    this.popup.setAttribute("data-side", this.side);
    this.popup.style.setProperty("--chelekom-side", this.side);
    if (this.trigger) this.trigger.setAttribute("aria-expanded", "true");
    this.position();

    document.addEventListener("click", this.boundOutside, true);
    document.addEventListener("keydown", this.boundKeydown, true);

    if (!this.hover) {
      const first = this.popup.querySelector(
        '[data-part="item"],[role="menuitem"],[role="option"],a,button'
      );
      if (first) requestAnimationFrame(() => first.focus());
    }
  },

  hide() {
    if (!this.popup || !this.isOpen()) return;
    this.popup.toggleAttribute("data-open", false);
    this.popup.toggleAttribute("data-closed", true);
    if (this.trigger) this.trigger.setAttribute("aria-expanded", "false");
    document.removeEventListener("click", this.boundOutside, true);
    document.removeEventListener("keydown", this.boundKeydown, true);
  },

  position() {
    // Context menus open at the pointer.
    if (this.contextmenu && this.point) {
      Object.assign(this.popup.style, {
        position: "fixed",
        left: `${this.point.x}px`,
        top: `${this.point.y}px`,
      });
      return;
    }

    // Minimal anchored placement; consumers can override via CSS.
    const sideStyles = {
      bottom: { top: "100%", bottom: "auto" },
      top: { bottom: "100%", top: "auto" },
      right: { left: "100%", right: "auto", top: "0" },
      left: { right: "100%", left: "auto", top: "0" },
    };
    Object.assign(this.popup.style, sideStyles[this.side] || sideStyles.bottom);
  },

  handleOutside(e) {
    if (!this.el.contains(e.target)) this.hide();
  },

  handleKeydown(e) {
    if (e.key === "Escape") {
      this.hide();
      if (this.trigger) this.trigger.focus();
    }
  },
};

export default Popup;
