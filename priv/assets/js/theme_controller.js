// ThemeController — apply a theme, remember it, and follow the OS when asked.
//
// daisyUI's theme controller is a pure-CSS trick that forgets the choice the moment you navigate.
// This writes `data-theme` onto the target element and stores the choice, so it survives a reload.
//
// The controls are native `<input>`s, so keyboard navigation, form participation and screen-reader
// semantics come from the browser. This hook only listens for `change` and does the applying.

const SYSTEM = "system";

const ThemeController = {
  mounted() {
    this.target = this.el.getAttribute("data-target") || ":root";
    this.storageKey = this.el.getAttribute("data-storage-key") || "";
    this.onChange = this.el.getAttribute("data-on-change");

    this.media = window.matchMedia("(prefers-color-scheme: dark)");
    // Kept as a field so it can be detached again: a system theme keeps following the OS, so the
    // listener outlives the change that installed it.
    this.followSystem = () => {
      if (this.current === SYSTEM) this.paint(SYSTEM);
    };

    this.onInput = (event) => this.pick(event.target);
    this.el.addEventListener("change", this.onInput);

    this.restore();
  },

  destroyed() {
    this.el.removeEventListener("change", this.onInput);
    this.media.removeEventListener("change", this.followSystem);
  },

  // The stored choice beats the server's, because it is the more recent statement of intent — the
  // server only knows what it rendered, the browser knows what this person last picked.
  restore() {
    const stored = this.storageKey ? window.localStorage.getItem(this.storageKey) : null;
    const theme = stored || this.el.getAttribute("data-theme-value");
    if (!theme) return;

    this.apply(theme, { persist: false, push: false });
    this.check(theme);
  },

  pick(input) {
    if (!input || input.getAttribute("data-part") !== "input") return;

    // A switch is one checkbox standing for two themes; a radio carries its own.
    const off = input.getAttribute("data-unchecked-value");
    const theme = input.type === "checkbox" && !input.checked ? off : input.getAttribute("data-value");
    if (theme) this.apply(theme, { persist: true, push: true });
  },

  apply(theme, { persist, push }) {
    this.current = theme;
    this.paint(theme);

    if (persist && this.storageKey) window.localStorage.setItem(this.storageKey, theme);

    this.el.querySelectorAll('[data-part="option"]').forEach((option) => {
      option.toggleAttribute("data-checked", option.getAttribute("data-value") === theme);
    });

    if (theme === SYSTEM) {
      this.media.addEventListener("change", this.followSystem);
    } else {
      this.media.removeEventListener("change", this.followSystem);
    }

    if (push && this.onChange) this.pushEventTo(this.el, this.onChange, { theme });
  },

  paint(theme) {
    const node = this.target === ":root" ? document.documentElement : document.querySelector(this.target);
    if (!node) return;

    node.setAttribute("data-theme", theme === SYSTEM ? this.systemTheme() : theme);
  },

  systemTheme() {
    return this.media.matches ? "dark" : "light";
  },

  // Restoring has to move the control too, or the page paints one theme while the radio says
  // another.
  check(theme) {
    this.el.querySelectorAll('[data-part="input"]').forEach((input) => {
      input.checked = input.getAttribute("data-value") === theme;
    });
  },
};

export default ThemeController;
