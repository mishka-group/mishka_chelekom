// Disclosure — headless accordion / disclosure engine (WAI-ARIA APG).
// Static ARIA/ids/tabindex are rendered by the component; this only drives the dynamic behavior.
// Root data-attrs: data-multiple, data-collapsible, data-orientation, data-disabled, data-loop,
// data-hidden-until-found, data-on-value-change. Per item: data-value, data-disabled, data-on-open-change.

const Disclosure = {
  mounted() {
    this.onClick = (e) => this.handleClick(e);
    this.onKeydown = (e) => this.handleKeydown(e);
    this.onBeforematch = (e) => this.handleBeforematch(e);
    this.el.addEventListener("click", this.onClick);
    this.el.addEventListener("keydown", this.onKeydown);
    this.el.addEventListener("beforematch", this.onBeforematch);
    this.setup();
  },

  updated() {
    this.setup();
  },

  destroyed() {
    this.el.removeEventListener("click", this.onClick);
    this.el.removeEventListener("keydown", this.onKeydown);
    this.el.removeEventListener("beforematch", this.onBeforematch);
  },

  setup() {
    this.multiple = this.el.getAttribute("data-multiple") === "true";
    this.collapsible = this.el.getAttribute("data-collapsible") !== "false";
    this.rootDisabled = this.el.hasAttribute("data-disabled");
    this.horizontal = this.el.getAttribute("data-orientation") === "horizontal";
    this.loop = this.el.getAttribute("data-loop") !== "false";
    this.untilFound = this.el.hasAttribute("data-hidden-until-found");
    this.onValueChange = this.el.getAttribute("data-on-value-change");
    this.rtl = getComputedStyle(this.el).direction === "rtl";
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    this.pairs = Array.from(this.el.querySelectorAll('[data-part="trigger"]')).map((trigger) => {
      const id = trigger.getAttribute("aria-controls");
      const panel = id ? this.el.querySelector(`#${CSS.escape(id)}`) : null;
      const item = trigger.closest('[data-part="item"]');
      if (panel) {
        const open = panel.hasAttribute("data-open");
        trigger.setAttribute("aria-expanded", String(open));
        trigger.toggleAttribute("data-panel-open", open);
        if (open) {
          panel.removeAttribute("hidden");
          this.measure(panel);
        }
      }
      return { trigger, panel, item, value: item && item.getAttribute("data-value") };
    });

    this.rove();
  },

  disabled(trigger) {
    return this.rootDisabled || trigger.hasAttribute("data-disabled");
  },

  triggers(enabledOnly) {
    const all = this.pairs.map((p) => p.trigger);
    return enabledOnly ? all.filter((t) => !this.disabled(t)) : all;
  },

  // Roving tabindex: the focused (or first enabled) trigger is the only tab stop.
  rove(focused) {
    const enabled = this.triggers(true);
    const stop =
      (focused && !this.disabled(focused) && focused) || enabled[0] || this.pairs[0]?.trigger;
    this.pairs.forEach(({ trigger }) => (trigger.tabIndex = trigger === stop ? 0 : -1));
  },

  handleClick(e) {
    const t = e.target.closest('[data-part="trigger"]');
    if (t && this.el.contains(t)) this.toggle(t);
  },

  handleBeforematch(e) {
    const panel = e.target.closest('[data-part="panel"]');
    const pair = panel && this.pairs.find((p) => p.panel === panel);
    if (pair) this.toggle(pair.trigger, true);
  },

  // Enter/Space stay on the native button; we own arrow + Home/End focus movement.
  handleKeydown(e) {
    const t = e.target.closest('[data-part="trigger"]');
    if (!t || !this.el.contains(t)) return;

    const nextKey = this.horizontal ? (this.rtl ? "ArrowLeft" : "ArrowRight") : "ArrowDown";
    const prevKey = this.horizontal ? (this.rtl ? "ArrowRight" : "ArrowLeft") : "ArrowUp";
    const all = this.triggers();
    const enabled = this.triggers(true);
    const pos = all.indexOf(t);
    if (pos < 0 || !enabled.length) return;

    let target;
    if (e.key === nextKey) target = this.step(all, pos, 1);
    else if (e.key === prevKey) target = this.step(all, pos, -1);
    else if (e.key === "Home") target = enabled[0];
    else if (e.key === "End") target = enabled[enabled.length - 1];
    else return;

    e.preventDefault();
    e.stopPropagation();
    if (target) {
      this.rove(target);
      target.focus();
    }
  },

  // Next/previous enabled trigger from pos (skips disabled, including a disabled focused one).
  step(all, pos, dir) {
    const n = all.length;
    for (let s = 1; s <= n; s++) {
      let i = pos + dir * s;
      if (this.loop) i = ((i % n) + n) % n;
      else if (i < 0 || i >= n) return null;
      if (!this.disabled(all[i])) return all[i];
    }
    return null;
  },

  toggle(trigger, force) {
    const pair = this.pairs.find((p) => p.trigger === trigger);
    if (!pair || !pair.panel || this.disabled(trigger)) return;

    const isOpen = pair.panel.hasAttribute("data-open");
    const open = force === true ? true : !isOpen;
    if (open === isOpen || (!open && !this.collapsible)) return;

    if (open && !this.multiple) {
      this.pairs.forEach((p) => {
        if (p.panel && p !== pair && p.panel.hasAttribute("data-open")) this.setOpen(p, false);
      });
    }
    this.setOpen(pair, open);
    this.emit(pair, open);
  },

  setOpen(pair, open) {
    const { trigger, panel, item } = pair;
    trigger.setAttribute("aria-expanded", String(open));
    trigger.toggleAttribute("data-panel-open", open);
    if (item) item.toggleAttribute("data-open", open);
    panel.toggleAttribute("data-open", open);
    panel.toggleAttribute("data-closed", !open);
    open ? this.expand(panel) : this.collapse(panel);
  },

  // Measured natural size, exposed for the consumer's height/width transition.
  measure(panel) {
    panel.style.setProperty("--accordion-panel-height", `${panel.scrollHeight}px`);
    panel.style.setProperty("--accordion-panel-width", `${panel.scrollWidth}px`);
  },

  // Reveal, pin the collapsed starting style and commit it as the baseline (so the transition always
  // runs from 0 — scrollHeight still reports the content size while collapsed), then release it.
  expand(panel) {
    panel.removeAttribute("hidden");
    if (this.reducedMotion) return this.measure(panel);
    panel.setAttribute("data-starting-style", "");
    void panel.offsetHeight;
    this.measure(panel);
    requestAnimationFrame(() => panel.removeAttribute("data-starting-style"));
  },

  // Pin the open size as the transition's start, apply the closed style, then hide once the
  // animation finishes. Chrome registers the exit transition a frame late, so wait a frame
  // before watching it (https://github.com/mui/base-ui/issues/3099).
  collapse(panel) {
    const hide = () => {
      if (panel.hasAttribute("data-open")) return; // reopened mid-transition
      panel.removeAttribute("data-ending-style");
      panel.setAttribute("hidden", this.untilFound ? "until-found" : "");
    };
    if (this.reducedMotion || !panel.getAnimations) return hide();
    this.measure(panel); // pin the open size as the transition's "from"
    void panel.offsetHeight; // commit it
    requestAnimationFrame(() => {
      // apply the closing style in a FRESH frame so the height transitions from the committed size
      panel.setAttribute("data-ending-style", "");
      requestAnimationFrame(() =>
        Promise.allSettled(panel.getAnimations().map((a) => a.finished)).then(hide)
      );
    });
  },

  emit(pair, open) {
    const itemEvent = pair.item && pair.item.getAttribute("data-on-open-change");
    if (itemEvent) this.pushEvent(itemEvent, { value: pair.value, open });
    if (this.onValueChange) {
      const value = this.pairs
        .filter((p) => p.panel && p.panel.hasAttribute("data-open"))
        .map((p) => p.value)
        .filter((v) => v != null);
      this.pushEvent(this.onValueChange, { value });
    }
  },
};

export default Disclosure;
