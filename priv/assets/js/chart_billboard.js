// Chart — headless charting engine (billboard.js, D3-based). One hook, `Chart`, drives every
// engine; this file is the billboard build. The generator installs exactly one engine file as
// `chart.js`.
//
// The hook lives on [data-part="surface"], NOT on the component root. The surface is
// `phx-update="ignore"` because billboard owns that subtree (an <svg> it draws into), and LiveView
// merges ONLY `data-*` on an ignored element. Every live knob is a `data-*` and the whole chart
// spec rides in on data-option. See chart_echarts.js for the full element/data-* contract; the
// engines are interchangeable behind one <.chart> markup.
//
// The option here is the billboard.js config WITHOUT `bindto` (the hook binds it), e.g.
// `%{data: %{columns: [["Sales", 120, 200, 150]], type: "bar"}}`, passed through raw.
// Server -> client live updates: `push_event("chelekom:chart", %{id:, option:, resize:})`.
//
// billboard.js's ESM build (the one a bundler picks) is modular: it draws a chart type only after
// that type's module has been called, and throws while mounting otherwise; zoom, subchart, data
// selection, regions and grid lines likewise stay off until their module has been called. A config
// crosses the LiveView wire as JSON, so its types are the strings the billboard docs write
// (`type: "bar"`, `types: %{"Sales" => "area"}`). Before every generate the hook replaces
// `data.type` and each value of `data.types` with its module's call (which returns the same string)
// and calls the module of every feature the config turns on. An unknown type warns once in the
// console and draws as a line. Everything else in the config is untouched.

import bb, {
  area,
  areaLineRange,
  areaSpline,
  areaSplineRange,
  areaStep,
  areaStepRange,
  bar,
  bubble,
  candlestick,
  donut,
  funnel,
  gauge,
  grid,
  line,
  pie,
  polar,
  radar,
  regions,
  scatter,
  selection,
  spline,
  step,
  subchart,
  treemap,
  zoom,
} from "billboard.js";
// Developer-owned, created once by the generator and never regenerated. See its header.
import userConfig from "./chart_extensions.js";

const STYLE_ID = "chelekom-billboard-styles";

// billboard.js ships its own stylesheet (dist/billboard.css); without it a line <path> defaults to a
// filled black blob and axes/tooltips are unstyled. Rather than force a build-pipeline change on the
// consumer, we inject the essential rules once. Colors read the --chart-* custom properties, so this
// themes with light/dark for free. Trimmed from billboard.js (MIT). Opt out with
// `billboard: { injectStyles: false }` in chart_extensions.js if you import the full CSS yourself.
const BILLBOARD_CSS = `
.bb svg { font-family: inherit; font-size: 11px; -webkit-tap-highlight-color: rgba(0,0,0,0); }
.bb text, .bb-legend-item text { fill: var(--chart-text, #64748b); user-select: none; }
.bb-line { fill: none; stroke-width: 1.5px; }
.bb-area { stroke-width: 0; opacity: 0.2; }
.bb-axis { shape-rendering: crispEdges; }
.bb-axis .domain, .bb-axis .tick line { fill: none; stroke: var(--chart-axis, rgba(148,163,184,0.6)); }
.bb-axis .tick text { fill: var(--chart-text, #64748b); }
.bb-grid line { stroke: var(--chart-grid, rgba(148,163,184,0.2)); }
.bb-grid text { fill: var(--chart-text, #64748b); }
.bb-chart-arc path { stroke: transparent; }
.bb-chart-arc text { fill: #fff; }
.bb-chart-arcs-title { fill: var(--chart-text, #64748b); font-size: 1.3em; }
.bb-tooltip { border-spacing: 0; background: rgba(15,23,42,0.95); color: #f8fafc; border-radius: 6px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.25); font-size: 11px; }
.bb-tooltip th { padding: 4px 9px; text-align: left; font-weight: 600; background: rgba(255,255,255,0.08); }
.bb-tooltip td { padding: 4px 9px; }
.bb-tooltip td.value { text-align: right; }
.bb-tooltip td .bb-tooltip-name span { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 5px; vertical-align: middle; }
.bb-defocused { opacity: 0.25 !important; }
`;

function injectStyles() {
  if (userConfig?.billboard?.injectStyles === false) return;
  if (document.getElementById(STYLE_ID)) return;
  const style = document.createElement("style");
  style.id = STYLE_ID;
  style.textContent = BILLBOARD_CSS;
  document.head.appendChild(style);
}

// ---- pure helpers -------------------------------------------------------------------------------

function cssVar(el, name) {
  return getComputedStyle(el).getPropertyValue(name).trim();
}

export function resolvePalette(el) {
  const fromVars = [];
  for (let i = 1; i <= 8; i++) {
    const v = cssVar(el, `--chart-${i}`);
    if (v) fromVars.push(v);
  }
  if (fromVars.length) return fromVars;
  if (Array.isArray(userConfig?.palette) && userConfig.palette.length) return userConfig.palette;
  return ["#3b82f6", "#22c55e", "#f59e0b", "#ef4444", "#8b5cf6", "#14b8a6", "#ec4899", "#64748b"];
}

export function safeParse(raw) {
  if (raw == null || raw === "") return {};
  try {
    return JSON.parse(raw);
  } catch (_e) {
    return {};
  }
}

export function intlFormatter(token) {
  const [ns, kind, arg] = token.split(":");
  if (ns !== "chelekom") return null;

  const custom = userConfig?.formatters?.[kind];
  if (typeof custom === "function") return (v) => custom(v, arg);

  switch (kind) {
    case "number":
      return (v) => new Intl.NumberFormat().format(v);
    case "compact":
      return (v) => new Intl.NumberFormat(undefined, { notation: "compact" }).format(v);
    case "percent":
      return (v) =>
        new Intl.NumberFormat(undefined, { style: "percent", maximumFractionDigits: 1 }).format(v);
    case "currency":
      return (v) =>
        new Intl.NumberFormat(undefined, { style: "currency", currency: arg || "USD" }).format(v);
    default:
      return null;
  }
}

// billboard formatters (axis.*.tick.format, tooltip.format.value, data.labels.format) take the
// value; a sentinel becomes a function of it.
function resolveSentinels(node) {
  if (Array.isArray(node)) return node.map(resolveSentinels);
  if (node && typeof node === "object") {
    const out = {};
    for (const [k, v] of Object.entries(node)) out[k] = resolveSentinels(v);
    return out;
  }
  if (typeof node === "string" && node.startsWith("chelekom:")) {
    const fn = intlFormatter(node);
    if (fn) return fn;
  }
  return node;
}

// ---- modules ------------------------------------------------------------------------------------

// Every billboard.js chart type, keyed by the string a config names it with. Each entry calls the
// imported binding rather than a copy of it: a billboard module replaces itself with a plain getter
// after its first call, so only the first chart of a type pays for the registration.
const TYPES = new Map([
  ["line", () => line()],
  ["spline", () => spline()],
  ["step", () => step()],
  ["area", () => area()],
  ["area-spline", () => areaSpline()],
  ["area-step", () => areaStep()],
  ["area-line-range", () => areaLineRange()],
  ["area-spline-range", () => areaSplineRange()],
  ["area-step-range", () => areaStepRange()],
  ["bar", () => bar()],
  ["scatter", () => scatter()],
  ["bubble", () => bubble()],
  ["candlestick", () => candlestick()],
  ["pie", () => pie()],
  ["donut", () => donut()],
  ["gauge", () => gauge()],
  ["polar", () => polar()],
  ["radar", () => radar()],
  ["funnel", () => funnel()],
  ["treemap", () => treemap()],
]);

const warnedTypes = new Set();

// A type string becomes its module's call. An unknown one warns once per name and draws as a line,
// so a mistyped series never stops the chart, or the page's LiveView, from mounting.
export function moduleType(type) {
  const register = TYPES.get(type);
  if (register) return register();
  const name = String(type);
  if (!warnedTypes.has(name)) {
    warnedTypes.add(name);
    console.warn(`[Chart] billboard.js has no "${name}" chart type; drawing it as a line.`);
  }
  return line();
}

// Resolves `data.type` and every value of `data.types` in place. billboard draws a series with no
// type as a line, so the line module is called whenever `data.type` is unset.
function resolveTypes(data) {
  if (data.type == null) line();
  else data.type = moduleType(data.type);
  if (data.types && typeof data.types === "object") {
    for (const id of Object.keys(data.types)) data.types[id] = moduleType(data.types[id]);
  }
}

// Calls the module of each feature the config turns on, leaving the config's own values as written.
// Grid is always called: besides `grid.x` / `grid.y` lines it draws the hover focus line, which
// billboard shows by default (`grid.focus.show`).
function resolveFeatures(config) {
  grid();
  if (config.zoom?.enabled) zoom();
  if (config.subchart?.show) subchart();
  if (config.data.selection?.enabled) selection();
  if (Array.isArray(config.regions) && config.regions.length) regions();
}

// ---- hook ---------------------------------------------------------------------------------------

const Chart = {
  mounted() {
    injectStyles();
    const el = this.el;
    this.rootId = el.getAttribute("data-root-id");
    this.onClick = el.getAttribute("data-on-click");
    this.domOption = el.getAttribute("data-option");
    this.raw = this.domOption;

    this.generate(this.raw);

    // billboard auto-resizes on window resize, but not on a container-only resize (e.g. a tab being
    // shown); flush() re-fits it to the current box.
    this.ro = new ResizeObserver(() => this.chart && this.chart.flush());
    this.ro.observe(el);

    // The palette is baked into the config at generate time, so a light/dark toggle has to
    // regenerate to pick up the new --chart-* values.
    if (!el.getAttribute("data-theme")) {
      this.themeObserver = new MutationObserver(() => this.generate(this.raw));
      this.themeObserver.observe(document.documentElement, {
        attributes: true,
        attributeFilter: ["data-theme", "class"],
      });
      this.mql = window.matchMedia("(prefers-color-scheme: dark)");
      this._onScheme = () => this.generate(this.raw);
      this.mql.addEventListener("change", this._onScheme);
    }

    this.ref = this.handleEvent("chelekom:chart", (payload) => {
      if (!payload || (payload.id && payload.id !== this.rootId)) return;
      if (payload.option != null) {
        this.raw = payload.option;
        this.generate(this.raw);
      }
      if (payload.resize) this.chart && this.chart.flush();
    });
  },

  updated() {
    const next = this.el.getAttribute("data-option");
    if (next !== this.domOption) {
      this.domOption = next;
      this.raw = next;
      this.generate(this.raw);
    }
  },

  destroyed() {
    if (this.ro) this.ro.disconnect();
    if (this.themeObserver) this.themeObserver.disconnect();
    if (this.mql && this._onScheme) this.mql.removeEventListener("change", this._onScheme);
    if (this.ref) this.removeHandleEvent(this.ref);
    // Without destroy the billboard instance, its <svg> and its window resize listener outlive every
    // LiveView navigation.
    if (this.chart) this.chart.destroy();
    this.chart = null;
  },

  // billboard cannot swap a live instance's type/axes, so regenerate on every change. Palette read
  // fresh so a theme toggle recolors correctly. Accepts a JSON string or an object.
  generate(raw) {
    const palette = resolvePalette(this.el);
    const parsed = typeof raw === "string" ? safeParse(raw) : raw || {};
    const config = resolveSentinels(parsed);
    config.bindto = this.el;
    // billboard requires a data block; an empty one renders an empty chart instead of throwing.
    config.data = config.data || { columns: [] };
    resolveTypes(config.data);
    resolveFeatures(config);
    if (!config.color) config.color = { pattern: palette };
    if (this.onClick) {
      config.data.onclick = (d) =>
        this.pushEventTo(this.el, this.onClick, {
          id: d.id,
          index: d.index,
          value: d.value,
          x: d.x,
        });
    }
    if (this.chart) this.chart.destroy();
    this.chart = bb.generate(config);
  },
};

export default Chart;
