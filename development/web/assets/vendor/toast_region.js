// ToastRegion — headless toast manager with a collapsible stack (Base UI parity).
//
// The viewport ([data-part="viewport"]) is a polite `aria-live` region that STACKS toasts: newest in
// front, older ones peeking behind; hovering or focusing the viewport EXPANDS them into a full
// list (and pauses auto-dismiss). A [data-part="trigger"] button clones [data-part="template"]'s
// toast on click (filling any [data-toast-count] with a running number). Each toast auto-dismisses
// after its data-duration (default 5000ms; 0 = sticky); a [data-part="close"] button or the timer
// closes it with an exit animation. Static [data-part="toast"] children rendered up-front (or
// streamed by LiveView) are adopted too.
//
// The hook only writes per-toast LAYOUT VARS — the consuming CSS does the transforms:
//   on each toast: --toast-index (0=front) · --toast-offset-y (px of toasts in front) ·
//                  --toast-height (measured natural px) · --toast-swipe-movement-x/y
//   on the viewport: --toast-frontmost-height (the front toast's height)
// State attrs: viewport+toast [data-expanded]; toast [data-open]/[data-closed],
//   [data-starting-style]/[data-ending-style] (enter/exit), [data-limited] (beyond data-limit);
//   content [data-behind] (collapsed and not frontmost).

const EXIT_MS = 500;

const ToastRegion = {
  mounted() {
    this.viewport = this.el.querySelector('[data-part="viewport"]') || this.el;
    this.template = this.el.querySelector('[data-part="template"]');
    this.limit = parseInt(this.el.getAttribute("data-limit") ?? "3", 10);
    this.count = 0;
    this.hovered = false;
    this.focused = false;
    this.expanded = false;
    this.timers = new WeakMap();
    this.exitTimers = new Set();
    this.rafs = new Set();
    this.cleanup = [];

    this.el.querySelectorAll('[data-part="trigger"]').forEach((b) => this.on(b, "click", () => this.add()));
    this.on(this.viewport, "pointerenter", () => this.setHover(true));
    this.on(this.viewport, "pointerleave", () => this.setHover(false));
    this.on(this.viewport, "focusin", () => this.setFocus(true));
    this.on(this.viewport, "focusout", (e) => {
      if (!this.viewport.contains(e.relatedTarget)) this.setFocus(false);
    });

    this.toasts().forEach((t) => this.wire(t));
    this.restack();
  },

  updated() {
    this.toasts().forEach((t) => this.wire(t));
    this.restack();
  },

  destroyed() {
    this.toasts().forEach((t) => this.clearTimer(t));
    this.exitTimers.forEach((id) => clearTimeout(id));
    this.rafs.forEach((id) => cancelAnimationFrame(id));
    this.cleanup.forEach((off) => off());
  },

  on(target, type, fn) {
    target.addEventListener(type, fn);
    this.cleanup.push(() => target.removeEventListener(type, fn));
  },

  toasts() {
    return Array.from(this.viewport.querySelectorAll('[data-part="toast"]'));
  },

  // Clone the template's toast to the front of the stack (newest first), animate it in. If the
  // template carries a data-toast-key, dedup: an existing toast with that key is refreshed (brought
  // to front + timer reset) instead of stacking a duplicate.
  add() {
    const tpl = this.template && (this.template.content || this.template);
    const src = tpl && tpl.querySelector('[data-part="toast"]');
    if (!src) return;
    const key = src.getAttribute("data-toast-key");
    if (key) {
      const existing = this.toasts().find(
        (t) => t.getAttribute("data-toast-key") === key && !t.hasAttribute("data-ending-style"),
      );
      if (existing) {
        this.viewport.prepend(existing);
        this.startTimer(existing);
        this.restack();
        return;
      }
    }
    this.count += 1;
    const toast = src.cloneNode(true);
    toast.querySelectorAll("[data-toast-count]").forEach((el) => (el.textContent = this.count));
    toast.setAttribute("data-open", "");
    toast.setAttribute("data-starting-style", "");
    if (this.expanded) toast.setAttribute("data-expanded", "");
    this.viewport.prepend(toast);
    this.wire(toast);
    this.restack();
    const raf = requestAnimationFrame(() => {
      this.rafs.delete(raf);
      void toast.offsetHeight;
      toast.removeAttribute("data-starting-style");
      this.restack();
    });
    this.rafs.add(raf);
  },

  wire(toast) {
    if (toast._wired) return;
    toast._wired = true;
    toast
      .querySelectorAll('[data-part="close"]')
      .forEach((b) => this.on(b, "click", () => this.dismiss(toast)));
    toast._duration = parseInt(toast.getAttribute("data-duration") ?? "5000", 10);
    this.startTimer(toast);
  },

  startTimer(toast) {
    this.clearTimer(toast);
    if (toast._duration > 0 && !this.expanded && !toast.hasAttribute("data-ending-style")) {
      this.timers.set(
        toast,
        setTimeout(() => this.dismiss(toast), toast._duration),
      );
    }
  },

  clearTimer(toast) {
    const id = this.timers.get(toast);
    if (id) {
      clearTimeout(id);
      this.timers.delete(toast);
    }
  },

  setHover(on) {
    this.hovered = on;
    this.syncExpanded();
  },

  setFocus(on) {
    this.focused = on;
    this.syncExpanded();
  },

  // Expanded = hovered OR focused — so leaving with the mouse never collapses while a toast button
  // is still keyboard-focused (and vice-versa). Pauses/resumes every timer accordingly.
  syncExpanded() {
    const want = this.hovered || this.focused;
    if (want === this.expanded) return;
    this.expanded = want;
    this.viewport.toggleAttribute("data-expanded", want);
    this.toasts().forEach((t) => {
      t.toggleAttribute("data-expanded", want);
      want ? this.clearTimer(t) : this.startTimer(t);
    });
    this.restack();
  },

  // Measure natural heights and publish the stacking vars.
  restack() {
    if (!this.viewport.isConnected) return;
    const active = this.toasts().filter((t) => !t.hasAttribute("data-ending-style"));
    let offset = 0;
    let front = 0;
    active.forEach((toast, i) => {
      const h = this.naturalHeight(toast);
      toast.style.setProperty("--toast-index", i);
      toast.style.setProperty("--toast-offset-y", `${offset}px`);
      toast.style.setProperty("--toast-height", `${h}px`);
      toast.style.setProperty("--toast-swipe-movement-x", "0px");
      toast.style.setProperty("--toast-swipe-movement-y", "0px");
      toast.toggleAttribute("data-limited", i >= this.limit);
      const content = toast.querySelector('[data-part="content"]');
      if (content) content.toggleAttribute("data-behind", i > 0 && !this.expanded);
      if (i === 0) front = h;
      offset += h;
    });
    this.viewport.style.setProperty("--toast-frontmost-height", `${front}px`);
  },

  // The toast's natural height. The CSS otherwise pins it to the front/var height, so we briefly
  // override to `auto` and read offsetHeight (the layout height, unaffected by the scale() transform
  // — unlike getBoundingClientRect), then hand it back to the stylesheet.
  naturalHeight(toast) {
    toast.style.setProperty("height", "auto", "important");
    const h = toast.offsetHeight;
    toast.style.removeProperty("height");
    return h;
  },

  dismiss(toast) {
    if (toast.hasAttribute("data-ending-style")) return;
    this.clearTimer(toast);
    toast.removeAttribute("data-open");
    toast.setAttribute("data-closed", "");
    toast.setAttribute("data-ending-style", "");
    this.restack();
    const id = setTimeout(() => {
      this.exitTimers.delete(id);
      toast.remove();
      this.restack();
    }, EXIT_MS);
    this.exitTimers.add(id);
  },
};

export default ToastRegion;
