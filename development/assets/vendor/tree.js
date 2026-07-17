// Tree — client engine for the headless `<.tree>` component.
//
// The server renders the complete nested `<ul role="tree">` / `<li role="treeitem">`
// structure; this hook owns every interaction Mantine's Tree exposes:
// expand/collapse, single & multiple selection, shift-range selection, cascading
// checkboxes (with indeterminate) or strict per-node checks, full WAI-ARIA keyboard
// navigation, drag & drop with before/after/inside drop zones, and async child
// loading driven by the server.
//
// The server renders expanded/selected/checked as INITIAL state only and publishes each as a
// `data-*-values` attribute; from mount on, the hook owns them and re-asserts them after every
// patch. Without that, morphdom strips the attributes the hook wrote (the server never rendered
// them) and the tree silently collapses and loses its selection on any unrelated re-render.

const SELECT = {
  root: "[data-tree-root]",
  item: "[role=treeitem]",
  label: "[data-part=label]",
  subtree: "[data-part=subtree]",
  checkbox: "[data-part=checkbox]",
  handle: "[data-part=drag-handle]",
  expandIcon: "[data-part=expand-icon]",
};

const bool = (el, name) => el.getAttribute(name) === "true";

export default {
  mounted() {
    this.anchor = null;
    this.loaded = new Set();
    this.loading = new Set();
    // Expanded / selected / checked are all hook-owned after mount: the
    // server renders them only as an INITIAL value, so a later patch would re-render each node
    // without them and morphdom would strip whatever the user had done. Each is published by the
    // server as one `data-*-values` attribute the hook diffs, so the server can still take
    // control back deliberately (a "collapse all" button) without clobbering the user by accident.
    this.expanded = new Set();
    this.selected = new Set();
    this.checked = new Set();
    this.published = {};
    this.readPublished();

    this.opts = {
      expandOnClick: bool(this.el, "data-expand-on-click"),
      expandOnSpace: bool(this.el, "data-expand-on-space"),
      checkOnSpace: bool(this.el, "data-check-on-space"),
      selectOnClick: bool(this.el, "data-select-on-click"),
      allowRangeSelection: bool(this.el, "data-allow-range-selection"),
      clearOnOutsideClick: bool(this.el, "data-clear-selection-on-outside-click"),
      checkStrictly: bool(this.el, "data-check-strictly"),
      withCheckboxes: bool(this.el, "data-with-checkboxes"),
      multiple: bool(this.el, "data-multiple"),
      draggable: bool(this.el, "data-draggable"),
      withDragHandle: bool(this.el, "data-with-drag-handle"),
    };

    this.onClick = this.handleClick.bind(this);
    this.onKeyDown = this.handleKeyDown.bind(this);
    this.onFocusOut = this.handleFocusOut.bind(this);
    this.onOutside = this.handleOutside.bind(this);

    this.el.addEventListener("click", this.onClick);
    this.el.addEventListener("keydown", this.onKeyDown);
    this.el.addEventListener("focusout", this.onFocusOut);

    if (this.opts.clearOnOutsideClick) {
      document.addEventListener("click", this.onOutside);
    }

    if (this.opts.draggable) this.bindDragAndDrop();

    this.handleEvent(`tree:${this.el.id}:children`, ({ value }) => {
      this.loading.delete(value);
      this.loaded.add(value);
      const item = this.node(value);
      item && item.removeAttribute("data-loading");
      this.syncAll();
    });

    this.syncAll();
    this.setRovingTabindex();
  },

  updated() {
    this.readPublished();
    this.syncAll();
    this.setRovingTabindex();
  },

  // Adopt a set only when the SERVER's published value changed — per-node `data-*` attributes
  // cannot tell us that, because when the server re-renders an unchanged value LiveView sends no
  // diff and the DOM still holds whatever the hook last wrote.
  readPublished() {
    [
      ["data-expanded-values", "expanded"],
      ["data-selected-values", "selected"],
      ["data-checked-values", "checked"],
    ].forEach(([attr, key]) => {
      const raw = this.el.getAttribute(attr);
      if (raw === this.published[attr]) return;

      this.published[attr] = raw;

      try {
        this[key] = new Set(JSON.parse(raw || "[]"));
      } catch (_e) {
        this[key] = new Set();
      }
    });
  },

  destroyed() {
    this.el.removeEventListener("click", this.onClick);
    this.el.removeEventListener("keydown", this.onKeyDown);
    this.el.removeEventListener("focusout", this.onFocusOut);
    document.removeEventListener("click", this.onOutside);
  },

  // ── queries ───────────────────────────────────────────────────────────────

  items() {
    return Array.from(this.el.querySelectorAll(SELECT.item));
  },

  // Only nodes whose every ancestor subtree is open — this is the sequence
  // ArrowUp/ArrowDown walks, and it must ignore anything inside a collapsed
  // subtree even when `keepMounted` leaves it in the DOM.
  visibleItems() {
    return this.items().filter((item) => {
      for (let el = item.parentElement; el && el !== this.el; el = el.parentElement) {
        if (el.matches(SELECT.subtree) && el.hidden) return false;
      }
      return true;
    });
  },

  node(value) {
    return this.el.querySelector(`${SELECT.item}[data-value="${CSS.escape(value)}"]`);
  },

  valueOf(item) {
    return item.getAttribute("data-value");
  },

  subtreeOf(item) {
    const sub = item.querySelector(SELECT.subtree);
    return sub && sub.closest(SELECT.item) === item ? sub : null;
  },

  childItems(item) {
    const sub = this.subtreeOf(item);
    if (!sub) return [];
    return Array.from(sub.children).filter((el) => el.matches(SELECT.item));
  },

  // Every leaf under `item` (or itself when it is a leaf). Cascading checks operate
  // on leaves only — a parent is "checked" iff all of its leaves are.
  leaves(item) {
    const kids = this.childItems(item);
    if (kids.length === 0) return [item];
    return kids.flatMap((kid) => this.leaves(kid));
  },

  isExpanded(item) {
    return item.getAttribute("data-expanded") === "true";
  },

  hasChildren(item) {
    return this.childItems(item).length > 0 || item.getAttribute("data-has-children") === "true";
  },

  // ── expand / collapse ─────────────────────────────────────────────────────

  setExpanded(item, expanded) {
    if (!this.hasChildren(item)) return;
    const value = this.valueOf(item);
    expanded ? this.expanded.add(value) : this.expanded.delete(value);
    this.applyExpanded(item, expanded);
    this.pushOpt(expanded ? "expand" : "collapse", { value });

    // Async children: ask the server once, on first expand.
    if (
      expanded &&
      item.getAttribute("data-has-children") === "true" &&
      this.childItems(item).length === 0 &&
      !this.loaded.has(value) &&
      !this.loading.has(value)
    ) {
      this.loading.add(value);
      item.setAttribute("data-loading", "true");
      this.pushOpt("load_children", { value });
    }
  },

  applyExpanded(item, expanded) {
    item.setAttribute("data-expanded", String(expanded));
    item.setAttribute("aria-expanded", String(expanded));
    const sub = this.subtreeOf(item);
    if (sub) sub.hidden = !expanded;
  },

  toggleExpanded(item) {
    this.setExpanded(item, !this.isExpanded(item));
  },

  // ── selection ─────────────────────────────────────────────────────────────

  selectedValues() {
    return Array.from(this.selected);
  },

  applySelection(values) {
    this.selected = new Set(values);
    this.paintSelection();
    this.pushOpt("select", { values: Array.from(this.selected) });
  },

  // Painting is separate from pushing so `syncAll` can restore the selection after a patch
  // without firing a spurious `select` event back at the server.
  paintSelection() {
    const set = this.selected;
    this.items().forEach((item) => {
      const on = set.has(this.valueOf(item));
      item.setAttribute("aria-selected", String(on));
      if (on) {
        item.setAttribute("data-selected", "true");
      } else {
        item.removeAttribute("data-selected");
      }
      const label = this.labelOf(item);
      if (label) {
        on
          ? label.setAttribute("data-selected", "true")
          : label.removeAttribute("data-selected");
      }
    });
  },

  labelOf(item) {
    const label = item.querySelector(SELECT.label);
    return label && label.closest(SELECT.item) === item ? label : null;
  },

  select(item) {
    const value = this.valueOf(item);
    this.anchor = value;
    this.applySelection(
      this.opts.multiple ? [...new Set([...this.selectedValues(), value])] : [value]
    );
  },

  // Shift-click / shift-arrow selects the inclusive slice between the anchor and the
  // target, in the tree's flattened visible order — matching Mantine's getValuesRange.
  selectRange(target) {
    const order = this.visibleItems().map((i) => this.valueOf(i));
    const a = order.indexOf(this.anchor);
    const b = order.indexOf(this.valueOf(target));
    if (a === -1 || b === -1) return this.select(target);
    this.applySelection(order.slice(Math.min(a, b), Math.max(a, b) + 1));
  },

  // ── checkboxes ────────────────────────────────────────────────────────────

  checkedValues() {
    return this.items()
      .filter((i) => i.getAttribute("data-checked") === "true")
      .map((i) => this.valueOf(i));
  },

  // Re-apply the hook's checked set after a patch, then let refreshAncestors derive the parents.
  paintChecked() {
    if (!this.opts.withCheckboxes) return;
    this.items().forEach((item) => this.markChecked(item, this.checked.has(this.valueOf(item))));
  },

  setChecked(item, checked) {
    if (this.opts.checkStrictly) {
      if (!this.disabled(item)) this.markChecked(item, checked);
    } else {
      // A disabled leaf must not ride along on a parent's cascade: the browser omits disabled
      // inputs from a form POST, so `on_check` would otherwise report a value the form never
      // sends — two sources of truth disagreeing about a node the UI paints as forbidden.
      this.leaves(item)
        .filter((leaf) => !this.disabled(leaf))
        .forEach((leaf) => this.markChecked(leaf, checked));

      this.refreshAncestors();
    }
    this.checked = new Set(this.checkedValues());
    this.pushOpt("check", { values: Array.from(this.checked) });
  },

  disabled(item) {
    return item.getAttribute("data-disabled") === "true";
  },

  markChecked(item, checked) {
    item.setAttribute("data-checked", String(checked));
    item.removeAttribute("data-indeterminate");
    const box = this.checkboxOf(item);
    if (box) {
      box.checked = checked;
      box.indeterminate = false;
      box.setAttribute("aria-checked", String(checked));
    }
  },

  checkboxOf(item) {
    const box = item.querySelector(SELECT.checkbox);
    return box && box.closest(SELECT.item) === item ? box : null;
  },

  // A parent is checked when every leaf under it is checked, indeterminate when only some are.
  // Skipped entirely without checkboxes: it is the expensive half of `syncAll` (a descendant
  // query per node, per patch) and it would otherwise write `data-checked` onto nodes the
  // server never rendered it on — which morphdom then strips on the next patch, leaving the
  // hook and the DOM fighting each other forever.
  refreshAncestors() {
    if (this.opts.checkStrictly || !this.opts.withCheckboxes) return;

    this.items().forEach((item) => {
      const kids = this.childItems(item);
      if (kids.length === 0) return;

      const leaves = this.leaves(item);
      const checked = leaves.filter((l) => l.getAttribute("data-checked") === "true").length;
      const all = checked === leaves.length;
      const some = checked > 0 && !all;

      item.setAttribute("data-checked", String(all));
      some
        ? item.setAttribute("data-indeterminate", "true")
        : item.removeAttribute("data-indeterminate");

      const box = this.checkboxOf(item);
      if (box) {
        box.checked = all;
        box.indeterminate = some;
        box.setAttribute("aria-checked", some ? "mixed" : String(all));
      }
    });
  },

  // ── events ────────────────────────────────────────────────────────────────

  handleClick(event) {
    const box = event.target.closest(SELECT.checkbox);
    if (box) {
      const item = box.closest(SELECT.item);
      // The native input has already flipped itself; drive state from its new value.
      this.setChecked(item, box.checked);
      // The box is tabindex=-1, so the tree item owns the tab stop — keep it in sync.
      this.focus(item);
      return;
    }

    const label = event.target.closest(SELECT.label);
    if (!label) return;

    const item = label.closest(SELECT.item);
    if (!item || item.getAttribute("data-disabled") === "true") return;

    // The expand icon toggles the branch and nothing else. Mantine runs expand AND select from
    // one click on the row, which makes `select_on_click` + `multiple` unusable on a tree with
    // folders: every navigation click silently joins the selection, and there is no way to
    // collapse a branch without selecting it. Giving the chevron its own target is what every
    // real file tree does, and it leaves the row click meaning exactly one thing.
    const icon = event.target.closest(SELECT.expandIcon);

    if (icon && icon.closest(SELECT.item) === item && this.hasChildren(item)) {
      event.stopPropagation();
      this.toggleExpanded(item);
      this.focus(item);
      return;
    }

    if (this.opts.allowRangeSelection && event.shiftKey && this.anchor) {
      event.preventDefault();
      this.selectRange(item);
      this.focus(item);
      return;
    }

    if (this.opts.expandOnClick) this.toggleExpanded(item);
    if (this.opts.selectOnClick) this.select(item);
    this.focus(item);
  },

  handleKeyDown(event) {
    const item = event.target.closest(SELECT.item);
    if (!item || !this.el.contains(item)) return;

    // Navigation is always allowed — a disabled node must still be reachable and announced.
    // Only the ACTIONS below are gated, and the guard has to live here: `pointer-events-none`
    // blocks the mouse but does nothing for a keypress.
    const disabled = item.getAttribute("data-disabled") === "true";

    switch (event.key) {
      case "ArrowRight": {
        event.preventDefault();
        event.stopPropagation();
        if (this.hasChildren(item) && !this.isExpanded(item)) {
          this.setExpanded(item, true);
        } else {
          const first = this.childItems(item)[0];
          first && this.focus(first);
        }
        break;
      }

      case "ArrowLeft": {
        event.preventDefault();
        event.stopPropagation();
        if (this.hasChildren(item) && this.isExpanded(item)) {
          this.setExpanded(item, false);
        } else {
          const parent = item.parentElement.closest(SELECT.item);
          parent && this.focus(parent);
        }
        break;
      }

      case "ArrowDown":
      case "ArrowUp": {
        event.preventDefault();
        event.stopPropagation();
        const order = this.visibleItems();
        const next = order[order.indexOf(item) + (event.key === "ArrowDown" ? 1 : -1)];
        if (!next) break;
        this.focus(next);
        if (event.shiftKey && this.opts.allowRangeSelection && this.anchor) {
          this.selectRange(next);
        }
        break;
      }

      case "Home": {
        event.preventDefault();
        const first = this.visibleItems()[0];
        first && this.focus(first);
        break;
      }

      case "End": {
        event.preventDefault();
        const all = this.visibleItems();
        all.length && this.focus(all[all.length - 1]);
        break;
      }

      case " ":
      case "Space": {
        if (this.opts.expandOnSpace) {
          event.preventDefault();
          event.stopPropagation();
          this.toggleExpanded(item);
        }
        if (this.opts.checkOnSpace && !disabled) {
          event.preventDefault();
          event.stopPropagation();
          this.setChecked(item, item.getAttribute("data-checked") !== "true");
        }
        break;
      }

      case "Enter": {
        event.preventDefault();
        if (!disabled) this.select(item);
        break;
      }

      default:
        return;
    }
  },

  handleFocusOut(event) {
    const item = event.target.closest && event.target.closest(SELECT.item);
    if (item && !item.contains(event.relatedTarget)) {
      item.removeAttribute("data-focus-ring");
    }
  },

  // Guarded: without the length check this fires an O(n) sweep and a websocket event on every
  // click anywhere on the page, forever.
  handleOutside(event) {
    if (this.el.contains(event.target)) return;
    if (this.selectedValues().length === 0) return;
    this.applySelection([]);
  },

  // The focus ring only appears for keyboard-driven focus, mirroring Mantine's
  // data-focus-ring: clicking a node focuses it silently.
  focus(item) {
    this.focusedValue = this.valueOf(item);
    this.items().forEach((i) => i.setAttribute("tabindex", i === item ? "0" : "-1"));
    item.setAttribute("data-focus-ring", "true");
    item.focus();
  },

  // Restore from our OWN record, not from the DOM: `tabindex` is a dynamic in the server's
  // render, so a patch resets it and reading it back would silently send the tab stop to the
  // first root mid-interaction.
  setRovingTabindex() {
    const items = this.items();
    if (!items.length) return;

    const current =
      (this.focusedValue && items.find((i) => this.valueOf(i) === this.focusedValue)) || items[0];

    items.forEach((i) => i.setAttribute("tabindex", i === current ? "0" : "-1"));
  },

  // ── drag & drop ───────────────────────────────────────────────────────────

  bindDragAndDrop() {
    this.dragged = null;

    this.el.addEventListener("dragstart", (event) => {
      const origin = this.opts.withDragHandle
        ? event.target.closest(SELECT.handle)
        : event.target.closest(SELECT.label);
      if (!origin) {
        event.preventDefault();
        return;
      }
      const item = origin.closest(SELECT.item);
      this.dragged = item;
      this.labelOf(item)?.setAttribute("data-dragging", "true");
      event.dataTransfer.effectAllowed = "move";
      event.dataTransfer.setData("text/plain", this.valueOf(item));
    });

    this.el.addEventListener("dragover", (event) => {
      const label = event.target.closest(SELECT.label);
      if (!label || !this.dragged) return;
      const item = label.closest(SELECT.item);
      if (item === this.dragged || this.dragged.contains(item)) return;

      const position = this.dropPosition(event, label, item);
      if (!position) return;

      event.preventDefault();
      this.clearDropMarkers();
      label.setAttribute("data-drag-over", position);
    });

    // `dragleave` also fires when the pointer crosses into a CHILD of the label, so clearing
    // unconditionally would drop the marker mid-hover and swallow the drop that follows.
    this.el.addEventListener("dragleave", (event) => {
      const label = event.target.closest(SELECT.label);
      if (label && !label.contains(event.relatedTarget)) {
        label.removeAttribute("data-drag-over");
      }
    });

    this.el.addEventListener("drop", (event) => {
      const label = event.target.closest(SELECT.label);
      if (!label || !this.dragged) return;
      event.preventDefault();

      const position = label.getAttribute("data-drag-over");
      const item = label.closest(SELECT.item);
      this.clearDropMarkers();

      if (position) {
        this.pushOpt("drag_drop", {
          dragged: this.valueOf(this.dragged),
          target: this.valueOf(item),
          position,
        });
      }
    });

    this.el.addEventListener("dragend", () => {
      this.labelOf(this.dragged)?.removeAttribute("data-dragging");
      this.clearDropMarkers();
      this.dragged = null;
    });
  },

  // Mirrors Mantine's zone geometry: a collapsed folder gets three zones
  // (before / inside / after at 25%-75%), an EXPANDED folder only two — an 'after'
  // drop on its label would render the indicator between the folder and its first
  // child, which reads as "first child" rather than "next sibling".
  dropPosition(event, label, item) {
    const rect = label.getBoundingClientRect();
    const y = event.clientY - rect.top;
    const h = rect.height;
    const folder = this.hasChildren(item);

    let position;
    if (folder && this.isExpanded(item)) {
      position = y < h * 0.5 ? "before" : "inside";
    } else if (folder) {
      position = y < h * 0.25 ? "before" : y > h * 0.75 ? "after" : "inside";
    } else {
      position = y < h * 0.5 ? "before" : "after";
    }

    const allow = this.el.getAttribute("data-allow-drop");
    if (allow === "inside-only" && position !== "inside") return null;
    if (allow === "reorder-only" && position === "inside") return null;
    return position;
  },

  clearDropMarkers() {
    this.el
      .querySelectorAll("[data-drag-over]")
      .forEach((el) => el.removeAttribute("data-drag-over"));
  },

  // ── sync ──────────────────────────────────────────────────────────────────

  syncAll() {
    this.items().forEach((item) => {
      if (this.hasChildren(item)) {
        this.applyExpanded(item, this.expanded.has(this.valueOf(item)));
      }

      const level = Number(item.getAttribute("data-level") || 1);
      item.style.setProperty("--label-offset", `calc(var(--level-offset) * ${level - 1})`);
    });

    this.paintSelection();
    this.paintChecked();
    this.refreshAncestors();
  },

  pushOpt(name, payload) {
    const event = this.el.getAttribute(`data-on-${name.replace(/_/g, "-")}`);
    if (!event) return;
    const target = this.el.getAttribute("data-on-target");
    target ? this.pushEventTo(target, event, payload) : this.pushEvent(event, payload);
  },
};
