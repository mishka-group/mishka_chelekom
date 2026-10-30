// Tests for what the Drawer hook does with the Tab order and focus when it opens and closes.
// Run with: node --test  (from priv/assets/js/)
//
// A closed drawer's popup is only translated off-screen, so it stays rendered: unless it is inert,
// Tab walks into the controls of a drawer nobody can see. And an inert popup cannot hold focus, so
// closing one that has focus inside must put focus somewhere, modal or not.

import { test, beforeEach } from "node:test";
import assert from "node:assert/strict";

class FakeElement {
  constructor(tag, attrs = {}) {
    this.tagName = tag.toUpperCase();
    this.attrs = { ...attrs };
    this.children = [];
    this.style = {};
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

beforeEach(() => {
  const body = new FakeElement("body");
  globalThis.document = {
    body,
    activeElement: body,
    documentElement: { clientWidth: 1280 },
    addEventListener() {},
    removeEventListener() {},
  };
  globalThis.window = { innerWidth: 1280 };
  globalThis.getComputedStyle = () => ({ paddingRight: "0px" });
  globalThis.requestAnimationFrame = (callback) => callback();
});

const { default: Drawer } = await import("./drawer.js");

// The hook as `mounted/0` leaves it, for a drawer rendered closed, without a trigger or swipe-area.
function drawer(modal) {
  const el = new FakeElement("div", { id: "dr", "data-closed": "" });
  const popup = new FakeElement("div", { "data-part": "popup", "data-closed": "", inert: "" });
  const field = popup.appendChild(new FakeElement("input"));
  el.appendChild(popup);

  const hook = Object.create(Drawer);
  Object.assign(hook, { el, popup, modal, trapFocus: modal !== "false", active: false });
  hook.boundKeydown = () => {};
  return { hook, popup, field };
}

test("an open popup is in the Tab order and a closed one is inert", () => {
  const { hook, popup } = drawer("true");

  hook.open();
  assert.equal(popup.hasAttribute("inert"), false);

  hook.close();
  assert.equal(popup.hasAttribute("inert"), true);
});

test("closing a non-modal drawer that has focus inside gives it back to the opener", () => {
  const { hook, field } = drawer("false");
  const opener = document.body.appendChild(new FakeElement("button"));

  opener.focus();
  hook.open();
  field.focus();
  hook.close();

  assert.equal(document.activeElement, opener);
});

test("closing a non-modal drawer leaves focus that is outside it where it is", () => {
  const { hook } = drawer("false");
  const opener = document.body.appendChild(new FakeElement("button"));
  const elsewhere = document.body.appendChild(new FakeElement("input"));

  opener.focus();
  hook.open();
  elsewhere.focus();
  hook.close();

  assert.equal(document.activeElement, elsewhere);
});
