// ToastRegion — headless toast/notification live-region engine.
//
// The root is an `aria-live` region. Each toast (`[data-part="toast"]`) auto-dismisses after
// `data-duration` ms (default 5000; `0` disables), and any `[data-part="dismiss"]` inside it
// closes it immediately. Dismissing sets `data-closed` then removes the node after a short
// exit window so CSS can animate. Works with toasts rendered up-front or streamed in by
// LiveView (re-scanned in `updated()`).

const ToastRegion = {
  mounted() {
    this.timers = new WeakMap();
    this.scan();
  },

  updated() {
    this.scan();
  },

  destroyed() {
    this.el.querySelectorAll('[data-part="toast"]').forEach((t) => this.clear(t));
  },

  scan() {
    this.el.querySelectorAll('[data-part="toast"]').forEach((toast) => {
      if (toast._toastBound) return;
      toast._toastBound = true;

      toast.setAttribute("role", toast.getAttribute("role") || "status");

      toast
        .querySelectorAll('[data-part="dismiss"]')
        .forEach((b) => b.addEventListener("click", () => this.dismiss(toast)));

      const duration = parseInt(toast.getAttribute("data-duration") ?? "5000", 10);
      if (duration > 0) {
        this.timers.set(toast, setTimeout(() => this.dismiss(toast), duration));
      }
    });
  },

  dismiss(toast) {
    this.clear(toast);
    toast.toggleAttribute("data-open", false);
    toast.toggleAttribute("data-closed", true);
    setTimeout(() => toast.remove(), 200);
  },

  clear(toast) {
    const t = this.timers.get(toast);
    if (t) clearTimeout(t);
  },
};

export default ToastRegion;
