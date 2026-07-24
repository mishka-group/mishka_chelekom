// NavigationMenu — a site nav with a single SHARED morphing popup (Base UI parity).
//
// All trigger items share ONE positioner/popup/viewport/arrow. Activating an item moves its stored
// `[data-part="content"]` into the viewport and MORPHS the popup's size (`--popup-width/height`) from
// the old size to the new one, while the positioner moves under the active trigger. Switching between
// already-open items is instant (no open delay) and sets `data-activation-direction` (left/right/up/down,
// from the prev-vs-next trigger rects) so the consumer can slide the content. Hover opens after `delay`,
// closes after `close-delay`; a "patient click" right after a hover-open is ignored.
//
// State: positioner/popup `data-open`/`data-closed` + `data-side`/`data-align`; active trigger
// `data-popup-open` + `aria-expanded` + its `[data-part="icon"]` `data-open`; active content
// `data-activation-direction`. CSS vars: popup `--popup-width/height`, positioner
// `--positioner-width/height`. (Simplified vs Base UI: inline positioning — no Portal/Backdrop/nested/
// transition-status; close-grace = "pointer over the list or popup".)

const OPEN_DELAY = 50;
const CLOSE_DELAY = 50;
const PATIENT_CLICK = 500;
const SIDE_OFFSET = 8;

const NavigationMenu = {
  mounted() {
    const el = this.el;
    this.list = el.querySelector('[data-part="list"]');
    this.positioner = el.querySelector('[data-part="positioner"]');
    this.popup = el.querySelector('[data-part="popup"]');
    this.viewport = el.querySelector('[data-part="viewport"]');
    this.arrow = el.querySelector('[data-part="arrow"]');

    this.orientation = el.getAttribute("data-orientation") || "horizontal";
    this.vertical = this.orientation === "vertical";
    this.side = el.getAttribute("data-side") || "bottom";
    this.align = el.getAttribute("data-align") || "center";
    this.delay = Number(el.getAttribute("data-delay")) || OPEN_DELAY;
    this.closeDelay = Number(el.getAttribute("data-close-delay")) || CLOSE_DELAY;

    this.items = Array.from(el.querySelectorAll('[data-part="item"]')).map((li) => ({
      value: li.getAttribute("data-value"),
      li,
      trigger: li.querySelector('[data-part="trigger"]'),
      content: li.querySelector('[data-part="content"]'),
    }));
    this.triggers = this.items.filter((it) => it.trigger);

    this.value = null;
    this.prevTrigger = null;
    this.activeContent = null;
    this.stick = false;
    this.overList = false;
    this.overPopup = false;

    // prevSize fallback (popup reads 0 mid-transition)
    this.prevSize = { w: 0, h: 0 };
    this.ro = new ResizeObserver(() => {
      if (this.popup.offsetWidth > 0) this.prevSize = { w: this.popup.offsetWidth, h: this.popup.offsetHeight };
    });
    this.ro.observe(this.popup);

    this.boundOutside = (e) => {
      if (el.contains(e.target)) return;
      if (e.target.closest("[data-base-ui-navigation-menu-trigger]")) return;
      this.close("outside-press");
    };

    this.triggers.forEach(({ trigger, value }) => {
      trigger.addEventListener("pointerenter", (e) => this.onTriggerEnter(value, e));
      trigger.addEventListener("pointerleave", () => this.scheduleClose());
      trigger.addEventListener("click", () => this.onTriggerClick(value));
      trigger.addEventListener("keydown", (e) => this.onTriggerKey(e, value));
      trigger.addEventListener("blur", () => this.onBlur());
    });
    this.list.addEventListener("pointerenter", () => { this.overList = true; this.cancelClose(); });
    this.list.addEventListener("pointerleave", () => { this.overList = false; this.scheduleClose(); });
    this.popup.addEventListener("pointerenter", () => { this.overPopup = true; this.cancelClose(); });
    this.popup.addEventListener("pointerleave", () => { this.overPopup = false; this.scheduleClose(); });
    this.popup.addEventListener("keydown", (e) => this.onPopupKey(e));

    this.boundResize = () => { if (this.value != null) this.syncSize(); };
    window.addEventListener("resize", this.boundResize);

    // controlled / open-by-default
    const initial = el.getAttribute("data-value");
    if (initial) requestAnimationFrame(() => this.activate(initial, { reason: "none", instant: true }));
  },

  destroyed() {
    document.removeEventListener("click", this.boundOutside, true);
    window.removeEventListener("resize", this.boundResize);
    this.ro?.disconnect();
    this.mo?.disconnect();
    clearTimeout(this._open);
    clearTimeout(this._close);
    clearTimeout(this._stick);
  },

  find(value) {
    return this.triggers.find((it) => it.value === value);
  },

  // ---- core: activate / morph -----------------------------------------------

  activate(value, opts = {}) {
    const reason = opts.reason || "none";
    const it = this.find(value);
    if (!it || !it.content) return;
    if (value === this.value) return;

    const firstOpen = this.value == null;
    const instant = opts.instant || firstOpen;

    // 1. activation direction from prev-vs-next trigger rects (only when already open)
    let dir = null;
    if (!firstOpen && this.prevTrigger) {
      const p = this.prevTrigger.getBoundingClientRect();
      const n = it.trigger.getBoundingClientRect();
      if (this.vertical) dir = n.top === p.top ? null : n.top > p.top ? "down" : "up";
      else dir = n.left === p.left ? null : n.left > p.left ? "right" : "left";
    }

    // 2. OLD size = what the popup currently shows (the last committed positioner size)
    const curW = parseFloat(this.positioner.style.getPropertyValue("--positioner-width")) || this.popup.offsetWidth || this.prevSize.w;
    const curH = parseFloat(this.positioner.style.getPropertyValue("--positioner-height")) || this.popup.offsetHeight || this.prevSize.h;

    // 3. swap content: previous back to its <li>, next into the viewport
    if (this.activeContent) {
      this.activeContent.setAttribute("hidden", "");
      this.prevLi.appendChild(this.activeContent);
    }
    it.content.removeAttribute("hidden");
    this.viewport.appendChild(it.content);
    this.activeContent = it.content;
    this.prevLi = it.li;
    this.mo?.disconnect();
    this.mo = new MutationObserver(() => { if (this.value != null) this.syncSize(); });
    this.mo.observe(it.content, { childList: true, subtree: true, characterData: true });

    // 4. mark OPEN first — the positioner is `display:none` while `data-closed`, so it must be visible
    // before we can measure (otherwise the first open reads 0).
    this.positioner.toggleAttribute("data-open", true);
    this.positioner.toggleAttribute("data-closed", false);
    this.popup.toggleAttribute("data-open", true);
    this.popup.toggleAttribute("data-closed", false);
    [this.positioner, this.popup, this.arrow].forEach((n) => {
      if (!n) return;
      n.setAttribute("data-side", this.side);
      n.setAttribute("data-align", this.align);
    });
    document.addEventListener("click", this.boundOutside, true);

    // 5. clear fixed sizes, then measure the NEW content's natural size. The viewport is normally
    // width/height:100% of the (auto) popup — circular — so un-constrain it to `max-content` just for
    // the measurement, read the content box, and restore.
    this.clearVars();
    this.viewport.style.width = "max-content";
    this.viewport.style.height = "max-content";
    const measuredW = it.content.offsetWidth || this.prevSize.w;
    const measuredH = it.content.offsetHeight || this.prevSize.h;
    this.viewport.style.width = "";
    this.viewport.style.height = "";

    // 6. position under the trigger (needs the measured width for align=center/end)
    this.position(it.trigger, measuredW);

    // 6/8. write sizes — morph from OLD→NEW unless first open / instant
    this.positioner.style.setProperty("--positioner-width", `${measuredW}px`);
    this.positioner.style.setProperty("--positioner-height", `${measuredH}px`);
    if (instant) {
      this.popup.style.setProperty("--popup-width", `${measuredW}px`);
      this.popup.style.setProperty("--popup-height", `${measuredH}px`);
      this.positioner.toggleAttribute("data-instant", true);
      requestAnimationFrame(() => this.positioner.removeAttribute("data-instant"));
    } else {
      this.popup.style.setProperty("--popup-width", `${curW}px`);
      this.popup.style.setProperty("--popup-height", `${curH}px`);
      requestAnimationFrame(() => {
        if (this.value !== value) return;
        this.popup.style.setProperty("--popup-width", `${measuredW}px`);
        this.popup.style.setProperty("--popup-height", `${measuredH}px`);
      });
    }

    // 10. activation direction on the active content
    if (dir) it.content.setAttribute("data-activation-direction", dir);
    else it.content.removeAttribute("data-activation-direction");

    // 11. arrow + 12. per-trigger state + roving
    this.positionArrow(it.trigger);
    this.triggers.forEach(({ trigger, value: v }) => {
      const on = v === value;
      trigger.setAttribute("aria-expanded", String(on));
      trigger.toggleAttribute("data-popup-open", on);
      trigger.setAttribute("tabindex", on ? "0" : "-1");
      const icon = trigger.querySelector('[data-part="icon"]');
      if (icon) icon.toggleAttribute("data-open", on);
    });

    // 13. after the morph settles, release the popup size back to auto (positioner keeps px)
    this.scheduleAutoSize(value);

    // 14. bookkeeping + optional focus
    this.value = value;
    this.prevTrigger = it.trigger;
    if (reason === "trigger-press" || reason === "list-navigation") {
      requestAnimationFrame(() => {
        const f = this.viewport.querySelector('a,button,[tabindex]:not([tabindex="-1"]),input,select,textarea');
        if (f) f.focus();
      });
    }
  },

  scheduleAutoSize(value) {
    clearTimeout(this._auto);
    const done = () => {
      if (this.value !== value) return;
      this.popup.style.setProperty("--popup-width", "auto");
      this.popup.style.setProperty("--popup-height", "auto");
    };
    // settle after the transition; fall back to a timer if no transition runs
    const anims = this.popup.getAnimations ? this.popup.getAnimations() : [];
    if (anims.length) Promise.allSettled(anims.map((a) => a.finished)).then(done);
    this._auto = setTimeout(done, 300);
  },

  syncSize() {
    this.clearVars();
    const w = this.popup.offsetWidth || this.prevSize.w;
    const h = this.popup.offsetHeight || this.prevSize.h;
    this.positioner.style.setProperty("--positioner-width", `${w}px`);
    this.positioner.style.setProperty("--positioner-height", `${h}px`);
    if (this.prevTrigger) this.position(this.prevTrigger, w);
  },

  clearVars() {
    ["--popup-width", "--popup-height"].forEach((v) => this.popup.style.removeProperty(v));
    ["--positioner-width", "--positioner-height"].forEach((v) => this.positioner.style.removeProperty(v));
  },

  close(reason) {
    if (this.value == null) return;
    const trigger = this.prevTrigger;

    // seed exit size from the positioner's current px (not a fresh measure)
    const w = this.positioner.style.getPropertyValue("--positioner-width");
    const h = this.positioner.style.getPropertyValue("--positioner-height");
    if (w) {
      this.popup.style.setProperty("--popup-width", w);
      this.popup.style.setProperty("--popup-height", h);
    }

    this.positioner.toggleAttribute("data-open", false);
    this.positioner.toggleAttribute("data-closed", true);
    this.popup.toggleAttribute("data-open", false);
    this.popup.toggleAttribute("data-closed", true);

    if (this.activeContent) {
      this.activeContent.removeAttribute("data-activation-direction");
      this.activeContent.setAttribute("hidden", "");
      this.prevLi.appendChild(this.activeContent);
      this.activeContent = null;
    }
    this.mo?.disconnect();

    this.triggers.forEach(({ trigger: t }) => {
      t.setAttribute("aria-expanded", "false");
      t.removeAttribute("data-popup-open");
      const icon = t.querySelector('[data-part="icon"]');
      if (icon) icon.removeAttribute("data-open");
    });

    this.value = null;
    document.removeEventListener("click", this.boundOutside, true);
    requestAnimationFrame(() => this.clearVars());

    if (trigger && !["trigger-hover", "outside-press", "focus-out"].includes(reason)) {
      const ae = document.activeElement;
      if (ae === document.body || this.popup.contains(ae)) trigger.focus({ preventScroll: true });
    }
  },

  // ---- positioning ----------------------------------------------------------

  position(trigger, width) {
    const r = this.el.getBoundingClientRect();
    const t = trigger.getBoundingClientRect();
    const s = this.positioner.style;
    s.position = "absolute";
    s.top = s.left = s.right = s.bottom = "";
    if (this.side === "bottom") s.top = `${t.bottom - r.top + SIDE_OFFSET}px`;
    else if (this.side === "top") s.bottom = `${r.bottom - t.top + SIDE_OFFSET}px`;
    else s.top = `${t.top - r.top}px`;

    if (this.side === "left" || this.side === "right") {
      if (this.side === "right") s.left = `${t.right - r.left + SIDE_OFFSET}px`;
      else s.right = `${r.right - t.left + SIDE_OFFSET}px`;
    } else {
      // horizontal align of the panel under the trigger
      let left = t.left - r.left;
      if (this.align === "center") left = t.left - r.left + t.width / 2 - width / 2;
      else if (this.align === "end") left = t.right - r.left - width;
      s.left = `${Math.max(0, left)}px`;
    }
  },

  positionArrow(trigger) {
    if (!this.arrow) return;
    const pr = this.positioner.getBoundingClientRect();
    const t = trigger.getBoundingClientRect();
    if (this.side === "bottom" || this.side === "top") {
      const center = t.left + t.width / 2 - pr.left;
      this.arrow.style.left = `${center}px`;
      this.arrow.style.removeProperty("top");
    }
  },

  // ---- hover / click timing -------------------------------------------------

  onTriggerEnter(value, e) {
    if (e.pointerType === "touch") return;
    this.cancelClose();
    if (this.value != null) {
      // already open → instant switch
      clearTimeout(this._open);
      this.activate(value, { reason: "trigger-hover" });
    } else {
      clearTimeout(this._open);
      this._open = setTimeout(() => {
        this.activate(value, { reason: "trigger-hover" });
        this.stick = true;
        clearTimeout(this._stick);
        this._stick = setTimeout(() => (this.stick = false), PATIENT_CLICK);
      }, this.delay);
    }
  },

  scheduleClose() {
    clearTimeout(this._close);
    this._close = setTimeout(() => {
      if (!this.overList && !this.overPopup) this.close("trigger-hover");
    }, this.closeDelay);
  },

  cancelClose() {
    clearTimeout(this._close);
  },

  onTriggerClick(value) {
    clearTimeout(this._open);
    this.cancelClose();
    if (this.stick) return; // patient click: ignore the click that follows a hover-open
    if (this.value === value) this.close("trigger-press");
    else this.activate(value, { reason: "trigger-press" });
  },

  onBlur() {
    // close if focus left the whole component
    requestAnimationFrame(() => {
      if (!this.el.contains(document.activeElement)) this.close("focus-out");
    });
  },

  // ---- keyboard -------------------------------------------------------------

  onTriggerKey(e, value) {
    const openKey = this.vertical ? "ArrowRight" : "ArrowDown";
    const triggers = this.triggers;
    const idx = triggers.findIndex((t) => t.value === value);

    if (e.key === openKey || e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      this.activate(value, { reason: "list-navigation" });
    } else if (e.key === (this.vertical ? "ArrowDown" : "ArrowRight")) {
      e.preventDefault();
      this.focusTrigger(triggers[(idx + 1) % triggers.length]);
    } else if (e.key === (this.vertical ? "ArrowUp" : "ArrowLeft")) {
      e.preventDefault();
      this.focusTrigger(triggers[(idx - 1 + triggers.length) % triggers.length]);
    } else if (e.key === "Home") {
      e.preventDefault();
      this.focusTrigger(triggers[0]);
    } else if (e.key === "End") {
      e.preventDefault();
      this.focusTrigger(triggers[triggers.length - 1]);
    } else if (e.key === "Escape") {
      this.close("escape-key");
    }
  },

  focusTrigger(it) {
    if (!it) return;
    this.triggers.forEach((t) => t.trigger.setAttribute("tabindex", t === it ? "0" : "-1"));
    it.trigger.focus();
    if (this.value != null) this.activate(it.value, { reason: "list-navigation" });
  },

  onPopupKey(e) {
    if (e.key === "Escape") {
      e.preventDefault();
      this.close("escape-key");
    } else if (e.key === "Tab" && !e.shiftKey) {
      // leaving the popup forward closes the menu (focus proceeds naturally)
      const f = this.viewport.querySelectorAll('a,button,[tabindex]:not([tabindex="-1"]),input,select,textarea');
      if (f.length && document.activeElement === f[f.length - 1]) this.close("focus-out");
    }
  },
};

export default NavigationMenu;
