// Tests for the Sidebar hook: what minimizing does to the sidebar's transitions, and that the hook
// takes its listener off when LiveView destroys it.
// Run with: node --test  (from priv/assets/js/)
//
// The sidebar slides in and out, and is hidden once it is off-screen, through the transition its
// classes give it. Minimizing animates its width, and must add to that transition, not replace it.

import { test, beforeEach } from "node:test";
import assert from "node:assert/strict";

// The transition the sidebar's classes give it, as getComputedStyle reports it in Tailwind v4.
const CLASS_TRANSITION = {
  transitionProperty: "transform, translate, scale, rotate, visibility",
  transitionDuration: "0.15s",
  transitionTimingFunction: "cubic-bezier(0.4, 0, 0.2, 1)",
  transitionDelay: "0s",
  transitionBehavior: "normal",
};

class FakeElement {
  constructor(attrs = {}) {
    this.attrs = { ...attrs };
    this.style = {};
    this.listeners = new Map();
    this.classList = { toggle() {}, add() {}, remove() {} };
  }

  getAttribute(name) {
    return name in this.attrs ? this.attrs[name] : null;
  }

  setAttribute(name, value) {
    this.attrs[name] = String(value);
  }

  addEventListener(type, listener) {
    this.listeners.set(type, listener);
  }

  removeEventListener(type, listener) {
    if (this.listeners.get(type) === listener) this.listeners.delete(type);
  }

  querySelector() {
    return null;
  }

  querySelectorAll() {
    return [];
  }
}

let sidebar;

beforeEach(() => {
  sidebar = new FakeElement({ id: "probe" });
  globalThis.document = {
    querySelector: (selector) => (selector === "#probe" ? sidebar : null),
  };
  // An inline longhand wins over the class's, as in the browser.
  globalThis.getComputedStyle = (el) => ({ ...CLASS_TRANSITION, ...el.style });
});

const { default: Sidebar } = await import("./sidebar.js");

// The hook as LiveView mounts it on the minimize button.
function mounted() {
  const hook = Object.create(Sidebar);
  hook.el = new FakeElement({ "data-sidebar-selector": "#probe" });
  hook.mounted();
  return hook;
}

const list = (value) => value.split(/,\s*(?![^(]*\))/);

test("minimizing keeps the slide and visibility transitions and adds width to them", () => {
  const hook = mounted();
  hook.el.listeners.get("click")();

  assert.equal(sidebar.style.transition, undefined, "an inline shorthand replaces the classes'");
  assert.deepEqual(list(sidebar.style.transitionProperty), [
    "transform",
    "translate",
    "scale",
    "rotate",
    "visibility",
    "width",
  ]);
  assert.deepEqual(list(sidebar.style.transitionDuration), [
    ...Array(5).fill("0.15s"),
    "0.3s",
  ]);
  assert.deepEqual(list(sidebar.style.transitionTimingFunction), [
    ...Array(5).fill("cubic-bezier(0.4, 0, 0.2, 1)"),
    "ease",
  ]);
});

test("minimizing and expanding again add width once", () => {
  const hook = mounted();
  hook.el.listeners.get("click")();
  hook.el.listeners.get("click")();

  const properties = list(sidebar.style.transitionProperty);
  assert.equal(properties.filter((property) => property === "width").length, 1);
  assert.equal(list(sidebar.style.transitionDuration).length, properties.length);
});

test("destroying the hook takes its click listener off the button", () => {
  const hook = mounted();
  assert.ok(hook.el.listeners.has("click"));

  assert.equal(typeof hook.destroyed, "function", "LiveView calls destroyed(), not destroy()");
  hook.destroyed();
  assert.equal(hook.el.listeners.has("click"), false);
});
