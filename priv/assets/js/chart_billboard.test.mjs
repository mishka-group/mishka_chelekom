// Tests for how the billboard.js Chart engine hands a config to billboard, and how it styles it.
// Run with: node --test  (from priv/assets/js/)
//
// A bundler resolves "billboard.js" to its ESM build, which draws a chart type only after that
// type's module has been called and throws while mounting otherwise. These tests swap the package
// for a stand-in that checks the same thing, then generate charts through the hook the way a
// LiveView mount does: the config arrives as JSON with string types.
//
// A page whose Content Security Policy allows no inline style refuses a <style> element and a
// `style` attribute, so the engine adopts one constructable stylesheet per page and draws the
// tooltip swatch with an SVG `fill`. The mount tests run the hook against a stand-in document that
// records every element created and every sheet adopted.

import { test as nodeTest, beforeEach } from "node:test";
import assert from "node:assert/strict";
import nodeModule from "node:module";

// module.registerHooks swaps the package in; a Node without it (before 22.15) skips these tests.
const { registerHooks } = nodeModule;
const skip = typeof registerHooks !== "function" && "needs module.registerHooks (Node 22.15+)";
const test = (name, fn) => nodeTest(name, { skip }, fn);

const TYPES = {
  line: "line",
  spline: "spline",
  step: "step",
  area: "area",
  "area-spline": "areaSpline",
  "area-step": "areaStep",
  "area-line-range": "areaLineRange",
  "area-spline-range": "areaSplineRange",
  "area-step-range": "areaStepRange",
  bar: "bar",
  scatter: "scatter",
  bubble: "bubble",
  candlestick: "candlestick",
  pie: "pie",
  donut: "donut",
  gauge: "gauge",
  polar: "polar",
  radar: "radar",
  funnel: "funnel",
  treemap: "treemap",
};

const FEATURES = ["grid", "zoom", "subchart", "selection", "regions"];

// A module returns its type string (a feature module returns true) and records that it was called.
const moduleExport = (name, value) =>
  `export const ${name} = () => (called.add(${JSON.stringify(name)}), ${JSON.stringify(value)});`;

// billboard's own rule (checkModuleImport): every type a chart names, and line when it names none,
// must have had its module called before generate.
const STAND_IN = `
export const called = new Set();
export const generated = [];
${Object.entries(TYPES)
  .map(([type, name]) => moduleExport(name, type))
  .join("\n")}
${FEATURES.map((name) => moduleExport(name, true)).join("\n")}
export default {
  generate(config) {
    const { type, types = {} } = config.data;
    for (const needed of [type ?? "line", ...Object.values(types)]) {
      if (!called.has(${JSON.stringify(TYPES)}[needed])) {
        throw new Error("[billboard.js] '" + needed + "' module has not been imported");
      }
    }
    generated.push(config);
    return { destroy() {}, flush() {} };
  },
};
`;

const STAND_IN_URL = `data:text/javascript,${encodeURIComponent(STAND_IN)}`;

// chart_extensions.js for a second copy of the engine, imported as "./chart_billboard.js?opt-out".
const OPT_OUT_URL = `data:text/javascript,${encodeURIComponent(
  "export default { billboard: { injectStyles: false } };",
)}`;

let billboard, Chart, OptOutChart, moduleType;

if (!skip) {
  const hooks = registerHooks({
    resolve(specifier, context, next) {
      if (specifier === "billboard.js") return { url: STAND_IN_URL, shortCircuit: true };
      if (specifier === "./chart_extensions.js" && context.parentURL?.endsWith("?opt-out")) {
        return { url: OPT_OUT_URL, shortCircuit: true };
      }
      return next(specifier, context);
    },
  });

  billboard = await import(STAND_IN_URL);
  ({ default: Chart, moduleType } = await import("./chart_billboard.js"));
  ({ default: OptOutChart } = await import("./chart_billboard.js?opt-out"));
  hooks.deregister();
}

globalThis.getComputedStyle = () => ({ getPropertyValue: () => "" });
globalThis.ResizeObserver = class {
  observe() {}
  disconnect() {}
};
globalThis.MutationObserver = class {
  observe() {}
  disconnect() {}
};
globalThis.window = { matchMedia: () => ({ addEventListener() {}, removeEventListener() {} }) };

// A constructable stylesheet as far as the engine uses one.
class FakeSheet {
  replaceSync(css) {
    this.css = css;
  }
}

// A document as far as the hook touches it; `adoptedStyleSheets` is left off to stand for a browser
// without constructable stylesheets.
const fakeDocument = ({ constructable = true } = {}) => {
  const doc = {
    created: [],
    appended: [],
    documentElement: {},
    head: { appendChild: (node) => doc.appended.push(node) },
    body: { appendChild: (node) => doc.appended.push(node) },
    getElementById: () => null,
    createElement(tag) {
      doc.created.push(String(tag).toLowerCase());
      return { tagName: String(tag).toUpperCase(), setAttribute() {}, style: {} };
    },
  };
  if (constructable) doc.adoptedStyleSheets = [];
  return doc;
};

const withDocument = ({ constructable = true } = {}) => {
  globalThis.document = fakeDocument({ constructable });
  if (constructable) globalThis.CSSStyleSheet = FakeSheet;
  else delete globalThis.CSSStyleSheet;
  return globalThis.document;
};

// Mounts the hook the way LiveView does: an object whose prototype is the hook, on its surface.
const mount = (engine = Chart, option = { data: { columns: [["Sales", 1, 2]] } }) => {
  const attrs = { "data-option": JSON.stringify(option), "data-root-id": "sales" };
  const hook = Object.create(engine);
  hook.el = { getAttribute: (name) => attrs[name] ?? null };
  hook.handleEvent = () => "ref";
  hook.removeHandleEvent = () => {};
  hook.mounted();
  return hook;
};

const billboardSheets = (doc) =>
  doc.adoptedStyleSheets.filter(
    (sheet) => sheet instanceof FakeSheet && sheet.css.includes(".bb-line"),
  );

let warnings = [];
console.warn = (message) => warnings.push(message);

beforeEach(() => {
  if (skip) return;
  billboard.called.clear();
  billboard.generated.length = 0;
  warnings = [];
});

const generate = (option) => {
  const hook = { el: {}, onClick: null, chart: null };
  Chart.generate.call(hook, JSON.stringify(option));
  return billboard.generated.at(-1);
};

test("every billboard chart type named in data.type draws", () => {
  for (const [type, name] of Object.entries(TYPES)) {
    billboard.called.clear();
    const config = generate({ data: { columns: [["Sales", 1, 2, 3]], type } });
    assert.equal(config.data.type, type);
    assert.ok(billboard.called.has(name), `${name}() was not called for "${type}"`);
  }
});

test("every value of data.types draws with its own module", () => {
  const config = generate({
    data: {
      columns: [
        ["Revenue", 1, 2],
        ["Target", 2, 3],
        ["Spend", 3, 4],
      ],
      type: "bar",
      types: { Target: "area-spline", Spend: "step" },
    },
  });

  assert.deepEqual(config.data.types, { Target: "area-spline", Spend: "step" });
  for (const name of ["bar", "areaSpline", "step"]) assert.ok(billboard.called.has(name));
});

test("a config with no type draws billboard's default line", () => {
  const config = generate({ data: { columns: [["Sales", 1, 2, 3]] } });

  assert.equal(config.data.type, undefined);
  assert.ok(billboard.called.has("line"));
});

test("a config with no data block draws an empty chart", () => {
  const config = generate({ xAxis: { type: "category" }, series: [] });

  assert.deepEqual(config.data, { columns: [] });
  assert.ok(billboard.called.has("line"));
});

test("an unknown type draws as a line and warns once per name", () => {
  const option = { data: { columns: [["Sales", 1]], type: "sparkle", types: { Sales: "zigzag" } } };

  const config = generate(option);
  generate(option);

  assert.equal(config.data.type, "line");
  assert.equal(config.data.types.Sales, "line");
  assert.equal(warnings.length, 2);
  assert.match(warnings[0], /"sparkle"/);
  assert.match(warnings[1], /"zigzag"/);
});

test("a name from Object.prototype is an unknown type, not a module", () => {
  assert.equal(moduleType("constructor"), "line");
  assert.equal(moduleType("__proto__"), "line");
});

test("grid is always called; the other features only when the config turns them on", () => {
  generate({ data: { columns: [["Sales", 1]] } });
  assert.ok(billboard.called.has("grid"));
  for (const name of ["zoom", "subchart", "selection", "regions"]) {
    assert.ok(!billboard.called.has(name), `${name} was called for a config that does not use it`);
  }

  const config = generate({
    data: { columns: [["Sales", 1]], selection: { enabled: true } },
    zoom: { enabled: { type: "drag" } },
    subchart: { show: true },
    regions: [{ axis: "x", start: 0, end: 1 }],
  });
  for (const name of FEATURES) assert.ok(billboard.called.has(name), `${name} was not called`);
  assert.deepEqual(config.zoom, { enabled: { type: "drag" } });
});

// The engine keeps one sheet for the page, so this runs before any test that builds it.
test("a browser without constructable stylesheets warns once and creates no <style>", () => {
  const doc = withDocument({ constructable: false });

  mount();
  mount();

  assert.deepEqual(doc.created, []);
  assert.deepEqual(doc.appended, []);
  assert.equal(warnings.filter((w) => /constructable stylesheet/.test(w)).length, 1);
});

test("two charts adopt one stylesheet and create no <style>", () => {
  const doc = withDocument();

  mount();
  mount(Chart, { data: { columns: [["Visits", 3, 1]], type: "bar" } });

  assert.equal(billboardSheets(doc).length, 1);
  assert.equal(doc.adoptedStyleSheets.length, 1);
  assert.ok(!doc.created.includes("style"), "the engine created a <style> element");
  assert.deepEqual(doc.appended, []);
});

test("a remount after a LiveView navigation adopts the same sheet, never a second copy", () => {
  const doc = withDocument();

  const hooks = [mount(), mount()];
  const [sheet] = billboardSheets(doc);
  hooks.forEach((hook) => hook.destroyed());
  mount();
  mount();

  assert.deepEqual(billboardSheets(doc), [sheet]);
});

test("a sheet the page adopted is kept, and the engine's is put back if dropped", () => {
  const doc = withDocument();
  const pageSheet = new FakeSheet();
  pageSheet.replaceSync(".app {}");

  mount();
  const [sheet] = billboardSheets(doc);
  doc.adoptedStyleSheets = [pageSheet];
  mount();
  mount();

  assert.deepEqual(doc.adoptedStyleSheets, [pageSheet, sheet]);
});

test("the adopted sheet styles lines, axes and the tooltip", () => {
  const doc = withDocument();
  mount();
  const [{ css }] = billboardSheets(doc);

  for (const rule of [
    ".bb-line { fill: none;",
    ".bb-axis .domain",
    ".bb-tooltip {",
    ".bb-tooltip td > svg",
  ]) {
    assert.ok(css.includes(rule), `the sheet lacks ${rule}`);
  }
});

test("injectStyles: false adopts nothing and leaves billboard's tooltip as it is", () => {
  const doc = withDocument();

  mount(OptOutChart);
  mount(OptOutChart);

  assert.deepEqual(doc.adoptedStyleSheets, []);
  assert.deepEqual(doc.created, []);
  assert.equal(billboard.generated.at(-1).tooltip, undefined);
});

test("a tooltip with no template of its own draws its swatch without a style attribute", () => {
  const config = generate({
    data: { columns: [["Sales", 1, 2]] },
    tooltip: { grouped: false, contents: { text: { note: ["a"] } } },
  });
  const { template } = config.tooltip.contents;

  assert.equal(config.tooltip.grouped, false);
  assert.deepEqual(config.tooltip.contents.text, { note: ["a"] });
  assert.doesNotMatch(template, /style\s*=/);
  assert.match(template, /<circle [^>]*fill="\{=COLOR\}"/);
  for (const key of ["CLASS_TOOLTIP", "TITLE", "CLASS_TOOLTIP_NAME", "NAME", "VALUE"]) {
    assert.ok(template.includes(`{=${key}}`), `the template drops {=${key}}`);
  }
  assert.match(template, /\{\{.*\}\}/, "the template has no per-series row");
});

test("a tooltip template or contents of the developer's own is left as written", () => {
  const own = "<ul>{{<li>{=NAME}: {=VALUE}</li>}}</ul>";

  const config = generate({
    data: { columns: [["Sales", 1]] },
    tooltip: { contents: { template: own } },
  });
  assert.equal(config.tooltip.contents.template, own);

  const hook = { el: {}, onClick: null, chart: null };
  const contents = () => "<b>mine</b>";
  Chart.generate.call(hook, { data: { columns: [["Sales", 1]] }, tooltip: { contents } });
  assert.equal(billboard.generated.at(-1).tooltip.contents, contents);
});
