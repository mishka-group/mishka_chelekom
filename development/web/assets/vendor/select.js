// Select — headless listbox select engine (Base UI parity).
//
// One hook on the root drives the whole component: a `[data-part="trigger"]` (role=combobox) opens a
// `[data-part="popup"]` listbox of `[data-part="item"]` options. Single-select commits + closes;
// `data-multiple` toggles items and keeps the popup open. Keyboard: trigger Enter/Space/Arrow open;
// inside, Arrow Up/Down + Home/End move a roving highlight, Enter/Space commit, Escape/Tab close,
// and typeahead (typing letters) jumps to a matching option (when closed it selects directly).
//
// Reflects Base UI's data-attributes: trigger `data-popup-open`/`data-placeholder` (+ server-rendered
// `data-disabled`/`data-readonly`/`data-required`); `[data-part="value"]` `data-placeholder`;
// `[data-part="icon"]` `data-popup-open`; items `data-selected`/`data-highlighted`/`data-disabled`;
// popup `data-open`/`data-closed`/`data-side`. The selected value(s) are mirrored into hidden inputs
// under `[data-part="value-inputs"]` (single → `name`, multiple → `name[]`) and a bubbling `input`
// event is dispatched so an enclosing `<.form phx-change>` reacts. `data-on-change` (`{value}`) and
// `data-on-open-change` (`{open}`) are pushed to LiveView when set.

const Select = {
  mounted() {
    const el = this.el;
    this.trigger = el.querySelector('[data-part="trigger"]');
    this.popup = el.querySelector('[data-part="popup"]');
    this.valueEl = el.querySelector('[data-part="value"]');
    this.icon = el.querySelector('[data-part="icon"]');
    this.inputs = el.querySelector('[data-part="value-inputs"]');

    this.multiple = el.hasAttribute("data-multiple");
    this.disabled = el.hasAttribute("data-disabled");
    this.readonly = el.hasAttribute("data-readonly");
    this.name = el.getAttribute("data-name");
    this.placeholder = el.getAttribute("data-placeholder") || "";
    this.onChange = el.getAttribute("data-on-change");
    this.onOpenChange = el.getAttribute("data-on-open-change");
    this.side = el.getAttribute("data-side") || "bottom";
    this.hover = !el.hasAttribute("data-no-hover");
    this.typeBuf = "";

    if (!this.popup) return;

    this.selected = new Set(
      this.all().filter((i) => i.hasAttribute("data-selected")).map((i) => this.val(i))
    );

    this.boundOutside = (e) => {
      if (!el.contains(e.target)) this.close();
    };

    if (this.trigger) {
      this.trigger.addEventListener("click", (e) => {
        e.stopPropagation();
        if (!this.disabled) this.toggle();
      });
      this.trigger.addEventListener("keydown", (e) => this.onTriggerKey(e));
    }
    this.popup.addEventListener("keydown", (e) => this.onPopupKey(e));
    this.bindItems();

    this.syncValue();
  },

  destroyed() {
    document.removeEventListener("click", this.boundOutside, true);
  },

  // ---- item helpers ---------------------------------------------------------

  all() {
    return Array.from(this.popup.querySelectorAll('[data-part="item"]'));
  },

  items() {
    return this.all().filter((i) => !i.hasAttribute("data-disabled"));
  },

  val(item) {
    return item.getAttribute("data-value");
  },

  label(item) {
    const t = item.querySelector('[data-part="item-text"]');
    return (t ? t.textContent : item.textContent).trim();
  },

  bindItems() {
    this.all().forEach((item) => {
      if (item._selBound) return;
      item._selBound = true;
      item.addEventListener("click", () => this.commit(item));
      item.addEventListener("pointermove", () => {
        if (this.hover && !item.hasAttribute("data-disabled")) this.highlight(item);
      });
    });
  },

  // ---- open / close ---------------------------------------------------------

  isOpen() {
    return this.popup.hasAttribute("data-open");
  },

  toggle() {
    this.isOpen() ? this.close() : this.open();
  },

  open() {
    if (this.disabled || this.isOpen()) return;
    this.popup.toggleAttribute("data-open", true);
    this.popup.toggleAttribute("data-closed", false);
    this.popup.setAttribute("data-side", this.side);
    this.position();
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", "true");
      this.trigger.toggleAttribute("data-popup-open", true);
    }
    if (this.icon) this.icon.toggleAttribute("data-popup-open", true);
    document.addEventListener("click", this.boundOutside, true);

    const start = this.all().find((i) => i.hasAttribute("data-selected")) || this.items()[0];
    if (start) {
      requestAnimationFrame(() => {
        this.highlight(start);
        start.focus();
        start.scrollIntoView({ block: "nearest" });
      });
    }
    if (this.onOpenChange) this.pushEventTo(this.el, this.onOpenChange, { open: true });
  },

  close(focusTrigger = false) {
    if (!this.isOpen()) return;
    this.popup.toggleAttribute("data-open", false);
    this.popup.toggleAttribute("data-closed", true);
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", "false");
      this.trigger.removeAttribute("data-popup-open");
    }
    if (this.icon) this.icon.removeAttribute("data-popup-open");
    document.removeEventListener("click", this.boundOutside, true);
    if (focusTrigger && this.trigger) this.trigger.focus();
    if (this.onOpenChange) this.pushEventTo(this.el, this.onOpenChange, { open: false });
  },

  position() {
    const sides = {
      bottom: { top: "100%", bottom: "auto" },
      top: { bottom: "100%", top: "auto" },
      right: { left: "100%", right: "auto", top: "0" },
      left: { right: "100%", left: "auto", top: "0" },
    };
    Object.assign(this.popup.style, sides[this.side] || sides.bottom);
    // Expose the trigger width (Base UI's `--anchor-width`) so consumers can size the popup to it.
    if (this.trigger)
      this.popup.style.setProperty("--anchor-width", `${this.trigger.offsetWidth}px`);
  },

  // ---- highlight / keyboard -------------------------------------------------

  highlight(item) {
    this.all().forEach((i) => {
      const on = i === item;
      i.toggleAttribute("data-highlighted", on);
      i.setAttribute("tabindex", on ? "0" : "-1");
    });
    this.active = item;
  },

  onTriggerKey(e) {
    if (this.disabled) return;
    if (["ArrowDown", "ArrowUp", "Enter", " "].includes(e.key)) {
      e.preventDefault();
      this.open();
    } else if (e.key.length === 1 && !e.metaKey && !e.ctrlKey) {
      // typeahead while closed selects directly (native <select> behavior)
      this.typeahead(e.key, true);
    }
  },

  onPopupKey(e) {
    if (e.key === "Escape") {
      e.preventDefault();
      this.close(true);
      return;
    }
    if (e.key === "Tab") {
      this.close();
      return;
    }
    const items = this.items();
    const idx = items.indexOf(this.active);
    let target = null;
    if (e.key === "ArrowDown") target = items[Math.min(items.length - 1, idx + 1)];
    else if (e.key === "ArrowUp") target = items[Math.max(0, idx - 1)];
    else if (e.key === "Home") target = items[0];
    else if (e.key === "End") target = items[items.length - 1];
    else if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      if (this.active) this.commit(this.active);
      return;
    } else if (e.key.length === 1 && !e.metaKey && !e.ctrlKey) {
      this.typeahead(e.key, false);
      return;
    } else {
      return;
    }
    e.preventDefault();
    if (target) {
      this.highlight(target);
      target.focus();
      target.scrollIntoView({ block: "nearest" });
    }
  },

  typeahead(ch, commitWhenClosed) {
    clearTimeout(this._typeTimer);
    this.typeBuf += ch.toLowerCase();
    this._typeTimer = setTimeout(() => (this.typeBuf = ""), 500);
    const match = this.items().find((i) => this.label(i).toLowerCase().startsWith(this.typeBuf));
    if (!match) return;
    if (commitWhenClosed && !this.multiple) {
      this.commit(match);
    } else {
      this.highlight(match);
      match.focus();
      match.scrollIntoView({ block: "nearest" });
    }
  },

  // ---- selection ------------------------------------------------------------

  commit(item) {
    if (this.disabled || this.readonly || item.hasAttribute("data-disabled")) return;
    const value = this.val(item);

    if (this.multiple) {
      const on = !item.hasAttribute("data-selected");
      item.toggleAttribute("data-selected", on);
      item.setAttribute("aria-selected", String(on));
      if (on) this.selected.add(value);
      else this.selected.delete(value);
    } else {
      this.all().forEach((i) => {
        const on = i === item;
        i.toggleAttribute("data-selected", on);
        i.setAttribute("aria-selected", String(on));
      });
      this.selected = new Set([value]);
      this.close(true);
    }

    this.syncValue();
    if (this.onChange) {
      this.pushEventTo(this.el, this.onChange, { value: this.multiple ? Array.from(this.selected) : value });
    }
  },

  // Reflect the current selection into the trigger value text, data-placeholder, and the hidden
  // form input(s) — then notify any enclosing <.form phx-change>.
  syncValue() {
    const labels = this.all()
      .filter((i) => this.selected.has(this.val(i)))
      .map((i) => this.label(i));
    const empty = labels.length === 0;

    if (this.valueEl) {
      this.valueEl.textContent = empty ? this.placeholder : labels.join(", ");
      this.valueEl.toggleAttribute("data-placeholder", empty);
    }
    if (this.trigger) this.trigger.toggleAttribute("data-placeholder", empty);

    if (this.inputs && this.name) {
      const values = Array.from(this.selected);
      const name = this.multiple ? `${this.name}[]` : this.name;
      const html = (this.multiple ? values : values.slice(0, 1))
        .map((v) => `<input type="hidden" name="${name}" value="${this.escape(v)}">`)
        .join("");
      // single with no value still submits an empty field
      this.inputs.innerHTML =
        html || (this.multiple ? "" : `<input type="hidden" name="${name}" value="">`);
      this.inputs.dispatchEvent(new Event("input", { bubbles: true }));
    }
  },

  escape(s) {
    return String(s).replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;");
  },
};

export default Select;
