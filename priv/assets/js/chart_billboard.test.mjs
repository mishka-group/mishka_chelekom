// Tests for how the billboard.js Chart engine hands a config to billboard.
// Run with: node --test  (from priv/assets/js/)
//
// A bundler resolves "billboard.js" to its ESM build, which draws a chart type only after that
// type's module has been called and throws while mounting otherwise. These tests swap the package
// for a stand-in that checks the same thing, then generate charts through the hook the way a
// LiveView mount does: the config arrives as JSON with string types.

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

let billboard, Chart, moduleType;

if (!skip) {
  const hooks = registerHooks({
    resolve(specifier, context, next) {
      if (specifier === "billboard.js") return { url: STAND_IN_URL, shortCircuit: true };
      return next(specifier, context);
    },
  });

  billboard = await import(STAND_IN_URL);
  ({ default: Chart, moduleType } = await import("./chart_billboard.js"));
  hooks.deregister();
}

globalThis.getComputedStyle = () => ({ getPropertyValue: () => "" });

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
