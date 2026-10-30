// Tests for how the headless Drawer and FocusTrap (dialog) hooks lock the page's scroll.
// Run with: node --test  (from priv/assets/js/)
//
// A modal drawer or dialog hides <body>'s overflow and pads it by the scrollbar's width, so the
// page neither scrolls nor shifts behind it. Several can be open at once: two drawers, or a drawer
// over a dialog. The page must stay locked until the last of them closes, in whatever order they
// close, and then get back exactly the styles it had before the first one opened.

import { test, beforeEach, afterEach } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const VIEWPORT = 1280;
const SCROLLBAR = 15;

class FakeElement {
  constructor(tag, attrs = {}) {
    this.tagName = tag.toUpperCase();
    this.attrs = { ...attrs };
    this.children = [];
    // Like a CSSStyleDeclaration, an unset property reads as "".
    this.style = {
      overflow: "",
      paddingRight: "",
      setProperty(name, value) {
        this[name] = String(value);
      },
      removeProperty(name) {
        delete this[name];
      },
    };
    this.id = attrs.id || "";
  }

  getAttribute(name) {
    return name in this.attrs ? this.attrs[name] : null;
  }

  setAttribute(name, value) {
    this.attrs[name] = String(value);
  }

  removeAttribute(name) {
    delete this.attrs[name];
  }

  hasAttribute(name) {
    return name in this.attrs;
  }

  toggleAttribute(name, force) {
    if (force) this.attrs[name] = "";
    else delete this.attrs[name];
    return force;
  }

  appendChild(child) {
    this.children.push(child);
    return child;
  }

  contains(node) {
    return node === this || this.children.some((child) => child.contains(node));
  }

  querySelectorAll() {
    return [];
  }

  focus() {
    document.activeElement = this;
  }
}

// The page's own stylesheet pads <body> on the right; `cssPaddingRight` stands in for it, and an
// inline padding-right overrides it, as in a browser. The scrollbar takes its width out of the
// viewport until <body>'s overflow is hidden.
beforeEach(() => {
  const body = new FakeElement("body");
  body.cssPaddingRight = "0px";
  globalThis.document = {
    body,
    activeElement: body,
    documentElement: {
      get clientWidth() {
        return document.body.style.overflow === "hidden" ? VIEWPORT : VIEWPORT - SCROLLBAR;
      },
    },
    addEventListener() {},
    removeEventListener() {},
  };
  globalThis.window = { innerWidth: VIEWPORT };
  globalThis.getComputedStyle = (el) => ({ paddingRight: el.style.paddingRight || el.cssPaddingRight });
  globalThis.requestAnimationFrame = (callback) => callback();
});

const { default: Drawer } = await import("./drawer.js");
const { default: FocusTrap } = await import("./focus_trap.js");

// Every hook a test makes, closed after it so a failing test leaves no lock to the next one.
const hooks = [];

afterEach(() => {
  hooks.splice(0).forEach((hook) => hook.active && hook.close());
});

// Each hook as `mounted/0` leaves it for a modal one rendered closed, without a trigger, backdrop
// or swipe-area.
function drawer(id) {
  const el = new FakeElement("div", { id, "data-closed": "" });
  const popup = el.appendChild(new FakeElement("div", { "data-part": "popup", "data-closed": "" }));
  const hook = Object.create(Drawer);
  Object.assign(hook, { el, popup, modal: "true", trapFocus: true, active: false });
  hook.boundKeydown = () => {};
  hooks.push(hook);
  return hook;
}

function dialog(id) {
  const el = new FakeElement("div", { id, "data-closed": "" });
  const popup = el.appendChild(new FakeElement("div", { "data-part": "popup", "data-closed": "" }));
  const hook = Object.create(FocusTrap);
  Object.assign(hook, { el, popup, modal: "true", trapFocus: true, active: false });
  hook.boundKeydown = () => {};
  hook.boundOutside = () => {};
  hooks.push(hook);
  return hook;
}

const bodyStyle = () => ({
  overflow: document.body.style.overflow,
  paddingRight: document.body.style.paddingRight,
});

const LOCKED = { overflow: "hidden", paddingRight: `${SCROLLBAR}px` };
const UNLOCKED = { overflow: "", paddingRight: "" };

// Opens `first` then `second`, closes them in `closing` order, and checks the page after each step.
function stack(first, second, closing) {
  first.open();
  assert.deepEqual(bodyStyle(), LOCKED, "the first overlay locks the page");
  second.open();
  assert.deepEqual(bodyStyle(), LOCKED, "the second overlay keeps the lock and pads once");
  closing[0].close();
  assert.deepEqual(bodyStyle(), LOCKED, "the page stays locked while one overlay is still open");
  closing[1].close();
  assert.deepEqual(bodyStyle(), UNLOCKED, "the page is unlocked and unpadded once both close");
}

test("two drawers closed in the order they opened", () => {
  const a = drawer("a");
  const b = drawer("b");
  stack(a, b, [a, b]);
});

test("two drawers closed in the reverse order", () => {
  const a = drawer("a");
  const b = drawer("b");
  stack(a, b, [b, a]);
});

test("a drawer over a dialog, the dialog closing first", () => {
  const d = dialog("d");
  const r = drawer("r");
  stack(d, r, [d, r]);
});

test("a drawer over a dialog, the drawer closing first", () => {
  const d = dialog("d");
  const r = drawer("r");
  stack(d, r, [r, d]);
});

test("a dialog over a drawer, the drawer closing first", () => {
  const r = drawer("r");
  const d = dialog("d");
  stack(r, d, [r, d]);
});

test("a dialog over a drawer, the dialog closing first", () => {
  const r = drawer("r");
  const d = dialog("d");
  stack(r, d, [d, r]);
});

test("the page gets back the inline styles it had before the first lock", () => {
  document.body.style.overflow = "auto";
  document.body.style.paddingRight = "4px";
  const a = drawer("a");
  const d = dialog("d");

  a.open();
  d.open();
  assert.deepEqual(bodyStyle(), { overflow: "hidden", paddingRight: `${4 + SCROLLBAR}px` });
  a.close();
  d.close();
  assert.deepEqual(bodyStyle(), { overflow: "auto", paddingRight: "4px" });
});

test("the padding adds the scrollbar to the stylesheet's own, once", () => {
  document.body.cssPaddingRight = "8px";
  const a = drawer("a");
  const b = drawer("b");

  a.open();
  b.open();
  assert.equal(document.body.style.paddingRight, `${8 + SCROLLBAR}px`);
  a.close();
  assert.equal(document.body.style.paddingRight, `${8 + SCROLLBAR}px`);
  b.close();
  assert.equal(document.body.style.paddingRight, "");
});

test("a drawer removed while open gives its lock back, and only its own", () => {
  const a = drawer("a");
  const b = drawer("b");

  a.open();
  b.open();
  a.destroyed();
  a.destroyed();
  assert.deepEqual(bodyStyle(), LOCKED, "a second destroyed/0 does not take b's lock");
  b.close();
  assert.deepEqual(bodyStyle(), UNLOCKED);
});

test("a non-modal drawer or dialog leaves the page's scroll alone", () => {
  const a = drawer("a");
  const d = dialog("d");
  a.modal = "false";
  a.trapFocus = false;
  d.modal = "false";
  d.trapFocus = false;

  a.open();
  d.open();
  assert.deepEqual(bodyStyle(), UNLOCKED);
  a.close();
  d.close();
  assert.deepEqual(bodyStyle(), UNLOCKED);
});

// The two hooks share the count only while they read and write it the same way. They ship as
// separate files, to a CMS as separate hooks, so each carries the block rather than importing it.
test("the drawer and the dialog carry the same scroll-lock block", () => {
  const block = (file) => {
    const source = readFileSync(new URL(file, import.meta.url), "utf8");
    const found = source.match(/\/\/ Page scroll lock,[\s\S]*?\nfunction unlockBodyScroll\(body\) \{[\s\S]*?\n\}\n/);
    assert.ok(found, `${file} has the scroll-lock block`);
    return found[0];
  };

  assert.equal(block("./drawer.js"), block("./focus_trap.js"));
});
