// FocusTrap — headless dialog / alert-dialog behavior engine.
//
// Self-contained (client-driven by default): a `[data-part="trigger"]` opens the dialog,
// focus is trapped inside `[data-part="popup"]`, and Escape / backdrop / `[data-close]`
// close it, restoring focus to the opener. Consumers can also drive open/close from the
// server by toggling the `data-open` attribute on the root — `updated()` re-syncs.
//
// State contract (paired-presence, Base-UI style):
//   root + popup: `data-open` | `data-closed`
//   trigger:      `aria-expanded`, `aria-haspopup="dialog"`
//
// Markup parts (via `data-part`): trigger, backdrop, popup, plus `[data-close]` elements.

const FOCUSABLE =
  'a[href],button:not([disabled]),textarea:not([disabled]),input:not([disabled]),select:not([disabled]),[tabindex]:not([tabindex="-1"])';

const FocusTrap = {
  mounted() {
    this.trigger = this.el.querySelector('[data-part="trigger"]');
    this.popup = this.el.querySelector('[data-part="popup"]');
    this.backdrop = this.el.querySelector('[data-part="backdrop"]');

    this.closeOnEscape = this.el.getAttribute("data-close-on-escape") !== "false";
    this.closeOnOutside = this.el.getAttribute("data-close-on-outside") !== "false";

    this.boundKeydown = this.handleKeydown.bind(this);
    this.boundOpen = () => this.open();
    this.boundClose = () => this.close();

    if (this.trigger) {
      this.trigger.setAttribute("aria-haspopup", "dialog");
      this.trigger.setAttribute("aria-expanded", "false");
      if (this.popup && this.popup.id) {
        this.trigger.setAttribute("aria-controls", this.popup.id);
      }
      this.trigger.addEventListener("click", this.boundOpen);
    }

    if (this.backdrop && this.closeOnOutside) {
      this.backdrop.addEventListener("click", this.boundClose);
    }

    this.el.querySelectorAll("[data-close]").forEach((b) =>
      b.addEventListener("click", this.boundClose)
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
  },

  open() {
    this.setState(true);
    this.activate();
  },

  close() {
    this.setState(false);
    this.deactivate();
  },

  setState(open) {
    this.el.toggleAttribute("data-open", open);
    this.el.toggleAttribute("data-closed", !open);
    if (this.popup) {
      this.popup.toggleAttribute("data-open", open);
      this.popup.toggleAttribute("data-closed", !open);
    }
    if (this.trigger) this.trigger.setAttribute("aria-expanded", String(open));
  },

  activate() {
    if (this.active) return;
    this.active = true;
    this.opener = document.activeElement;
    document.addEventListener("keydown", this.boundKeydown, true);
    const first = this.focusables()[0] || this.popup;
    if (first && first.focus) requestAnimationFrame(() => first.focus());
  },

  deactivate() {
    if (!this.active) return;
    this.active = false;
    document.removeEventListener("keydown", this.boundKeydown, true);
    if (this.opener && this.opener.focus) this.opener.focus();
  },

  focusables() {
    if (!this.popup) return [];
    return Array.from(this.popup.querySelectorAll(FOCUSABLE)).filter(
      (el) => el.offsetParent !== null
    );
  },

  handleKeydown(e) {
    if (!this.active) return;

    if (e.key === "Escape" && this.closeOnEscape) {
      e.preventDefault();
      this.close();
      return;
    }

    if (e.key !== "Tab") return;

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
};

export default FocusTrap;
