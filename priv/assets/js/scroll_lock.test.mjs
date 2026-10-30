// Tests for how the headless Drawer, FocusTrap (dialog) and Popover hooks lock the page's scroll.
// Run with: node --test  (from priv/assets/js/)
//
// A modal drawer, dialog or popover hides <body>'s overflow and pads it by the scrollbar's width,
// so the page neither scrolls nor shifts behind it. Several can be open at once: two drawers, a
// drawer over a dialog, a popover over either. The page must stay locked until the last of them
// closes, in whatever order they close, and then get back exactly the styles it had before the
// first one opened.

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

  querySelector() {
    return null;
  }

  querySelectorAll() {
    return [];
  }

  getBoundingClientRect() {
    return { top: 100, bottom: 120, left: 50, right: 150, width: 100, height: 20 };
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
  globalThis.window = {
    innerWidth: VIEWPORT,
    innerHeight: 900,
    addEventListener() {},
    removeEventListener() {},
  };
  globalThis.getComputedStyle = (el) => ({ paddingRight: el.style.paddingRight || el.cssPaddingRight });
  globalThis.requestAnimationFrame = (callback) => callback();
});

const { default: Drawer } = await import("./drawer.js");
const { default: FocusTrap } = await import("./focus_trap.js");
const { default: Popover } = await import("./popover.js");

// Every hook a test makes, closed after it so a failing test leaves no lock to the next one.
const hooks = [];

afterEach(() => {
  hooks.splice(0).forEach((hook) => hook.active && hook.close());
});

// Each hook as `mounted/0` leaves it for a modal one rendered closed, without a backdrop or
// swipe-area, and without a trigger except the popover's, which it is placed against.
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

function popover(id) {
  const el = new FakeElement("div", { id, "data-closed": "" });
  const trigger = el.appendChild(new FakeElement("button", { "data-part": "trigger" }));
  const popup = el.appendChild(new FakeElement("div", { "data-part": "popup", "data-closed": "" }));
  const hook = Object.create(Popover);
  Object.assign(hook, { el, trigger, popup, modal: "true", trapFocus: true, active: false });
  Object.assign(hook, { side: "bottom", align: "center", sideOffset: 0, alignOffset: 0 });
  hook.boundKeydown = () => {};
  hook.boundOutside = () => {};
  hook.boundReposition = () => {};
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

// A popover with a drawer or a dialog: either one opened first, either one closed first.
for (const [name, other] of [["drawer", drawer], ["dialog", dialog]]) {
  test(`a popover over a ${name}, the ${name} closing first`, () => {
    const o = other("o");
    const p = popover("p");
    stack(o, p, [o, p]);
  });

  test(`a popover over a ${name}, the popover closing first`, () => {
    const o = other("o");
    const p = popover("p");
    stack(o, p, [p, o]);
  });

  test(`a ${name} over a popover, the popover closing first`, () => {
    const p = popover("p");
    const o = other("o");
    stack(p, o, [p, o]);
  });

  test(`a ${name} over a popover, the ${name} closing first`, () => {
    const p = popover("p");
    const o = other("o");
    stack(p, o, [o, p]);
  });
}

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

test("a non-modal drawer, dialog or popover leaves the page's scroll alone", () => {
  const overlays = [drawer("a"), dialog("d"), popover("p")];
  overlays.forEach((hook) => Object.assign(hook, { modal: "false", trapFocus: false }));

  overlays.forEach((hook) => hook.open());
  assert.deepEqual(bodyStyle(), UNLOCKED);
  overlays.forEach((hook) => hook.close());
  assert.deepEqual(bodyStyle(), UNLOCKED);
});

// The hooks share the count only while they read and write it the same way. They ship as separate
// files, to a CMS as separate hooks, so each carries the block rather than importing it.
test("the drawer, the dialog and the popover carry the same scroll-lock block", () => {
  const block = (file) => {
    const source = readFileSync(new URL(file, import.meta.url), "utf8");
    const found = source.match(/\/\/ Page scroll lock,[\s\S]*?\nfunction unlockBodyScroll\(body\) \{[\s\S]*?\n\}\n/);
    assert.ok(found, `${file} has the scroll-lock block`);
    return found[0];
  };

  assert.equal(block("./focus_trap.js"), block("./drawer.js"));
  assert.equal(block("./popover.js"), block("./drawer.js"));
});
