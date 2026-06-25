// Tabs — a value-driven tablist with an animated indicator (Base UI parity) + LiveView push.
//
// One hook on the root owns: roving tabindex over `[data-part="tab"]` (arrow keys along
// `data-orientation` + Home/End), activating a tab (by its `data-value`) on click — and on focus when
// `data-activate-on-focus`. Activating shows the matching `[data-part="panel"]` (others get `hidden` +
// `data-hidden`), sets `aria-selected`/`data-active`, computes `data-activation-direction`
// (left/right/up/down vs the previous tab), and measures the active tab to publish the indicator CSS
// vars `--active-tab-left/right/top/bottom/width/height` (on the indicator + list) so a
// `[data-part="indicator"]` can slide/resize under it.
//
// Server push: when `data-on-change` is set, the resolved value is pushed to LiveView (`{value}`) on a
// user change. The root's `data-value` is the controlled value — on a server re-render `updated()`
// re-syncs the active tab + indicator WITHOUT pushing (no loop).

const Tabs = {
  mounted() {
    const el = this.el;
    this.tablist = el.querySelector('[data-part="tablist"]');
    this.indicator = el.querySelector('[data-part="indicator"]');
    this.orientation = el.getAttribute("data-orientation") || "horizontal";
    this.vertical = this.orientation === "vertical";
    this.activateOnFocus = el.hasAttribute("data-activate-on-focus");
    this.onChange = el.getAttribute("data-on-change");
    this.onChangeTarget = el.getAttribute("data-on-change-target"); // optional: target a LiveComponent

    this.tabs = Array.from(el.querySelectorAll('[data-part="tab"]'));
    this.panels = Array.from(el.querySelectorAll('[data-part="panel"]'));

    this.tabs.forEach((tab) => {
      if (tab._tabsBound) return;
      tab._tabsBound = true;
      tab.addEventListener("click", () => this.select(tab.getAttribute("data-value"), { user: true }));
      tab.addEventListener("keydown", (e) => this.onKey(e, tab));
      tab.addEventListener("focus", () => {
        if (this.activateOnFocus && !tab.hasAttribute("data-disabled")) {
          this.select(tab.getAttribute("data-value"), { user: true });
        }
      });
    });

    // resync the indicator when the list resizes (font load, wrap, etc.)
    this.ro = new ResizeObserver(() => this.moveIndicator());
    if (this.tablist) this.ro.observe(this.tablist);
    this.boundResize = () => this.moveIndicator();
    window.addEventListener("resize", this.boundResize);

    this.value = el.getAttribute("data-value") || this.firstEnabledValue();
    this.select(this.value, { user: false, instant: true });
  },

  updated() {
    // controlled: the server may have changed data-value — re-sync without pushing
    const v = this.el.getAttribute("data-value");
    if (v != null && v !== this.value) this.select(v, { user: false });
    else this.moveIndicator();
  },

  destroyed() {
    this.ro?.disconnect();
    window.removeEventListener("resize", this.boundResize);
  },

  enabledTabs() {
    return this.tabs.filter((t) => !t.hasAttribute("data-disabled"));
  },

  firstEnabledValue() {
    const t = this.enabledTabs()[0] || this.tabs[0];
    return t && t.getAttribute("data-value");
  },

  panelFor(value) {
    return this.panels.find((p) => p.getAttribute("data-value") === value);
  },

  // ---- selection ------------------------------------------------------------

  select(value, { user = false, instant = false } = {}) {
    const tab = this.tabs.find((t) => t.getAttribute("data-value") === value);
    if (!tab || tab.hasAttribute("data-disabled")) return;

    // activation direction vs the previous active tab
    let dir = null;
    if (this.value != null && this.value !== value) {
      const prev = this.tabs.find((t) => t.getAttribute("data-value") === this.value);
      if (prev) {
        const p = prev.getBoundingClientRect();
        const n = tab.getBoundingClientRect();
        if (this.vertical) dir = n.top === p.top ? null : n.top > p.top ? "down" : "up";
        else dir = n.left === p.left ? null : n.left > p.left ? "right" : "left";
      }
    }

    this.value = value;

    this.tabs.forEach((t) => {
      const on = t === tab;
      t.setAttribute("aria-selected", String(on));
      t.toggleAttribute("data-active", on);
      t.setAttribute("tabindex", on ? "0" : "-1");
    });
    this.panels.forEach((p) => {
      const on = p.getAttribute("data-value") === value;
      p.toggleAttribute("hidden", !on);
      p.toggleAttribute("data-hidden", !on);
    });

    // activation direction on root/list/tabs/panels/indicator (for slide animations)
    [this.el, this.tablist, this.indicator, tab, this.panelFor(value)].forEach((n) => {
      if (!n) return;
      if (dir) n.setAttribute("data-activation-direction", dir);
      else n.removeAttribute("data-activation-direction");
    });

    this.moveIndicator(instant);

    if (user && this.onChange) {
      if (this.onChangeTarget) this.pushEventTo(this.onChangeTarget, this.onChange, { value });
      else this.pushEvent(this.onChange, { value });
    }
  },

  // measure the active tab and publish the indicator CSS vars on the indicator + list
  moveIndicator(instant) {
    if (!this.tablist) return;
    const tab = this.tabs.find((t) => t.getAttribute("data-value") === this.value);
    if (!tab) return;
    const lr = this.tablist.getBoundingClientRect();
    const tr = tab.getBoundingClientRect();
    const vars = {
      "--active-tab-left": `${tr.left - lr.left}px`,
      "--active-tab-right": `${lr.right - tr.right}px`,
      "--active-tab-top": `${tr.top - lr.top}px`,
      "--active-tab-bottom": `${lr.bottom - tr.bottom}px`,
      "--active-tab-width": `${tr.width}px`,
      "--active-tab-height": `${tr.height}px`,
    };
    [this.tablist, this.indicator].forEach((n) => {
      if (!n) return;
      for (const k in vars) n.style.setProperty(k, vars[k]);
    });
    if (instant && this.indicator) {
      // suppress the slide on the very first placement
      const t = this.indicator.style.transition;
      this.indicator.style.transition = "none";
      void this.indicator.offsetWidth;
      requestAnimationFrame(() => (this.indicator.style.transition = t));
    }
  },

  // ---- keyboard (roving) ----------------------------------------------------

  onKey(e, tab) {
    const next = this.vertical ? "ArrowDown" : "ArrowRight";
    const prev = this.vertical ? "ArrowUp" : "ArrowLeft";
    const tabs = this.enabledTabs();
    const idx = tabs.indexOf(tab);
    let target = null;
    if (e.key === next) target = tabs[(idx + 1) % tabs.length];
    else if (e.key === prev) target = tabs[(idx - 1 + tabs.length) % tabs.length];
    else if (e.key === "Home") target = tabs[0];
    else if (e.key === "End") target = tabs[tabs.length - 1];
    else if ((e.key === "Enter" || e.key === " ") && !this.activateOnFocus) {
      e.preventDefault();
      this.select(tab.getAttribute("data-value"), { user: true });
      return;
    } else return;
    e.preventDefault();
    if (target) {
      target.focus(); // focus → activates when activate_on_focus
      if (!this.activateOnFocus) this.roll(target);
    }
  },

  roll(tab) {
    this.tabs.forEach((t) => t.setAttribute("tabindex", t === tab ? "0" : "-1"));
  },
};

export default Tabs;
