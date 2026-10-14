// Tests for when the Floating hook measures the page.
// Run with: node --test  (from priv/assets/js/)
//
// A page can mount a hundred floating hooks in one LiveView patch. Any layout read made while they
// mount (getComputedStyle, getBoundingClientRect, offsetWidth/Height) makes the browser restyle the
// whole page once per hook, so mounting must read none; showing the content is when it is placed.

import { test, beforeEach } from "node:test";
import assert from "node:assert/strict";

let reads = [];

class FakeElement {
  constructor(tag, attrs = {}) {
    this.tagName = tag.toUpperCase();
    this.attrs = { ...attrs };
    this.children = [];
    this.parentElement = null;
    this.style = {};
    this.listeners = {};
    this.id = attrs.id || "";
    const classes = new Set((attrs.class || "").split(" ").filter(Boolean));
    this.classList = {
      add: (...names) => names.forEach((name) => classes.add(name)),
      remove: (...names) => names.forEach((name) => classes.delete(name)),
      contains: (name) => classes.has(name),
    };
  }

  get hidden() {
    return this.hasAttribute("hidden");
  }

  get offsetWidth() {
    reads.push("offsetWidth");
    const stretched =
      this.staticWidth && (this.style.position !== "absolute" || !this.style.width);
    return stretched ? this.staticWidth : 120;
  }

  get offsetHeight() {
    reads.push("offsetHeight");
    return 40;
  }

  getBoundingClientRect() {
    reads.push("getBoundingClientRect");
    return { top: 100, bottom: 120, left: 50, right: 150, width: 100, height: 20 };
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

  appendChild(child) {
    if (child.parentElement) child.parentElement.removeChild(child);
    child.parentElement = this;
    this.children.push(child);
    return child;
  }

  insertBefore(child, before) {
    if (child.parentElement) child.parentElement.removeChild(child);
    child.parentElement = this;
    this.children.splice(this.children.indexOf(before), 0, child);
    return child;
  }

  removeChild(child) {
    this.children = this.children.filter((node) => node !== child);
    child.parentElement = null;
    return child;
  }

  contains(node) {
    return node === this || this.children.some((child) => child.contains(node));
  }

  querySelector(selector) {
    for (const child of this.children) {
      if (child.matches(selector)) return child;
      const found = child.querySelector(selector);
      if (found) return found;
    }
    return null;
  }

  querySelectorAll(selector) {
    const found = [];
    for (const child of this.children) {
      if (child.matches(selector)) found.push(child);
      found.push(...child.querySelectorAll(selector));
    }
    return found;
  }

  matches(selector) {
    if (selector.startsWith("[") && selector.endsWith("]")) {
      return this.hasAttribute(selector.slice(1, -1));
    }

    if (selector.startsWith(".")) {
      return selector
        .slice(1)
        .split(".")
        .every((name) => this.classList.contains(name));
    }

    if (selector.startsWith("#")) return this.id === selector.slice(1);
    return false;
  }

  addEventListener(name, listener) {
    (this.listeners[name] ||= []).push(listener);
  }

  removeEventListener(name, listener) {
    this.listeners[name] = (this.listeners[name] || []).filter((each) => each !== listener);
  }
}

beforeEach(() => {
  reads = [];
  const body = new FakeElement("body");
  const html = new FakeElement("html");
  globalThis.document = {
    body,
    documentElement: html,
    addEventListener() {},
    removeEventListener() {},
    querySelectorAll: (selector) => body.querySelectorAll(selector),
  };
  globalThis.window = {
    innerWidth: 1280,
    innerHeight: 800,
    scrollX: 0,
    scrollY: 0,
    addEventListener() {},
    removeEventListener() {},
  };
  globalThis.getComputedStyle = () => {
    reads.push("getComputedStyle");
    return { direction: "ltr" };
  };
});

const { default: Floating } = await import("./floating.js");

function mount(attrs = {}, staticWidth = null) {
  const el = new FakeElement("div", { "data-clickable": "true", ...attrs });
  const trigger = new FakeElement("button", { "data-floating-trigger": "" });
  const content = new FakeElement("div", { "data-floating-content": "", role: "menu" });
  el.appendChild(trigger);
  el.appendChild(content);
  document.body.appendChild(el);

  const hook = Object.create(Floating);
  hook.el = el;
  hook.mounted();
  content.staticWidth = staticWidth;
  return { hook, trigger, content };
}

test("mounting reads no layout, however many are mounted", () => {
  for (let i = 0; i < 100; i++) mount();
  assert.deepEqual(reads, []);
});

test("the content is hidden once mounted", () => {
  const { content } = mount();
  assert.equal(content.hidden, true);
  assert.equal(content.parentElement, document.body);
});

test("hidden content is not placed when the page scrolls or the hook updates", () => {
  const { hook } = mount();
  hook.updatePosition();
  hook.updated();
  assert.deepEqual(reads, []);
});

test("showing the content places it under its trigger", () => {
  const { hook, content } = mount();
  hook.show();

  assert.equal(content.hidden, false);
  assert.ok(reads.includes("getBoundingClientRect"));
  assert.equal(content.style.position, "absolute");
  assert.equal(content.style.top, `${120 + 5}px`);
  assert.equal(content.style.left, `${(50 + 150) / 2}px`);
});

test("a content placed beside its trigger reads the page's direction when it is shown", () => {
  globalThis.getComputedStyle = () => {
    reads.push("getComputedStyle");
    return { direction: "rtl" };
  };

  const { hook, content } = mount({ "data-position": "left" });
  assert.deepEqual(reads, []);

  hook.show();
  assert.ok(reads.includes("getComputedStyle"));
  assert.equal(content.style.left, `${150 + 5}px`);
});

test("the content is measured at its own size, not the width of a body it has not left yet", () => {
  const { hook, content } = mount({}, 1280);
  hook.show();

  assert.equal(content.style.left, `${(50 + 150) / 2}px`);
  assert.equal(content.style.transform, "translateX(-50%)");
});

test("smart positioning measures the content out of the flow too", () => {
  const { hook, content } = mount(
    { "data-smart-position": "true", "data-position": "right" },
    1280,
  );
  hook.show();

  assert.equal(content.style.left, `${150 + 5}px`);
});

test("content already placed keeps its place while it is measured again", () => {
  const { hook, content } = mount({}, 1280);
  hook.show();
  content.style.left = "777px";
  const seen = [];
  Object.defineProperty(content, "offsetHeight", {
    get() {
      seen.push(content.style.left);
      return 40;
    },
  });
  hook.updatePosition();

  assert.ok(seen.length > 0);
  assert.ok(seen.every((left) => left === "777px"));
});

test("the first show settles the width before it places a content a class stretches to the page", () => {
  const { hook, content } = mount({}, 1280);
  hook.show();

  assert.equal(content.style.width, "auto");
  assert.equal(content.style.left, `${(50 + 150) / 2}px`);
  assert.equal(content.style.transform, "translateX(-50%)");

  hook.hide();
  hook.show();
  assert.equal(content.style.left, `${(50 + 150) / 2}px`);
});
