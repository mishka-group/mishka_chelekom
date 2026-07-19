// FloatingWindow — a draggable panel positioned inside its nearest positioned ancestor (Mantine
// FloatingWindow parity).
//
// Drag the `handle` to move the window — or focus it and use the arrow keys (10px, 1px with
// Shift), the WCAG 2.5.7 alternative to dragging. The window is clamped to stay inside its offset
// parent. Position is mirrored into `data-x` / `data-y` and, if `data-on-move` names an event,
// pushed to the server on release / key move. Clicks on interactive controls inside the handle
// (buttons, links, inputs) do not start a drag, so a close button in the title bar keeps working.
//
// Element contract:
//   root [data-part="window"] — carries the hook; must be positioned (absolute/fixed); data-x/data-y
//   [data-part="handle"]      — the drag handle (defaults to the whole window if omitted)

const INTERACTIVE = "button, a, input, textarea, select, [data-no-drag]";

const FloatingWindow = {
  mounted() {
    this.x = parseFloat(this.el.getAttribute("data-x")) || 0;
    this.y = parseFloat(this.el.getAttribute("data-y")) || 0;
    this.on = this.el.getAttribute("data-on-move");
    this.handle = this.el.querySelector('[data-part="handle"]') || this.el;
    this.handle.style.touchAction = "none";
    this.apply();

    this._onDown = (e) => {
      if (e.button !== 0) return;
      if (e.target.closest(INTERACTIVE)) return;
      e.preventDefault();
      this.startX = e.clientX;
      this.startY = e.clientY;
      this.origX = this.x;
      this.origY = this.y;
      this.dragging = true;
      this.el.setAttribute("data-dragging", "");
      try {
        this.handle.setPointerCapture(e.pointerId);
      } catch (_e) {}
      window.addEventListener("pointermove", this._onMove);
      window.addEventListener("pointerup", this._onUp);
    };
    this._onMove = (e) => {
      if (!this.dragging) return;
      this.x = this.origX + (e.clientX - this.startX);
      this.y = this.origY + (e.clientY - this.startY);
      this.clamp();
      this.apply();
    };
    this._onUp = () => {
      if (!this.dragging) return;
      this.dragging = false;
      this.el.removeAttribute("data-dragging");
      window.removeEventListener("pointermove", this._onMove);
      window.removeEventListener("pointerup", this._onUp);
      if (this.on) this.pushEventTo(this.el, this.on, { x: Math.round(this.x), y: Math.round(this.y) });
    };

    this._onKey = (e) => {
      const step = e.shiftKey ? 1 : 10;
      let dx = 0;
      let dy = 0;
      if (e.key === "ArrowLeft") dx = -step;
      else if (e.key === "ArrowRight") dx = step;
      else if (e.key === "ArrowUp") dy = -step;
      else if (e.key === "ArrowDown") dy = step;
      else return;
      e.preventDefault();
      this.x += dx;
      this.y += dy;
      this.clamp();
      this.apply();
      if (this.on) this.pushEventTo(this.el, this.on, { x: Math.round(this.x), y: Math.round(this.y) });
    };

    this.handle.addEventListener("pointerdown", this._onDown);
    this.handle.addEventListener("keydown", this._onKey);
  },

  parent() {
    return this.el.offsetParent || this.el.parentElement;
  },

  clamp() {
    const p = this.parent();
    if (!p) return;
    const maxX = Math.max(0, p.clientWidth - this.el.offsetWidth);
    const maxY = Math.max(0, p.clientHeight - this.el.offsetHeight);
    this.x = Math.min(Math.max(0, this.x), maxX);
    this.y = Math.min(Math.max(0, this.y), maxY);
  },

  apply() {
    this.el.style.left = `${this.x}px`;
    this.el.style.top = `${this.y}px`;
    this.el.setAttribute("data-x", String(Math.round(this.x)));
    this.el.setAttribute("data-y", String(Math.round(this.y)));
  },

  updated() {
    if (this.dragging) return;
    this.x = parseFloat(this.el.getAttribute("data-x")) || 0;
    this.y = parseFloat(this.el.getAttribute("data-y")) || 0;
    this.apply();
  },

  destroyed() {
    this.handle.removeEventListener("pointerdown", this._onDown);
    this.handle.removeEventListener("keydown", this._onKey);
    window.removeEventListener("pointermove", this._onMove);
    window.removeEventListener("pointerup", this._onUp);
  },
};

export default FloatingWindow;
