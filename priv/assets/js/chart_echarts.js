// Chart — headless charting engine (Apache ECharts). One hook, `Chart`, drives every engine; this
// file is the ECharts build. The generator installs exactly one engine file as `chart.js`.
//
// The hook lives on [data-part="surface"], NOT on the component root. The surface is
// `phx-update="ignore"` because ECharts owns that subtree (a <canvas> it draws into), and LiveView
// merges ONLY `data-*` on an ignored element — `class`/`style`/`aria-*` freeze at first render.
// Keeping the boundary inner lets the root stay a normal, server-styled element while `data-*` on
// the surface remains the one live channel from the server.
//
// Element contract:
//   [data-part="root"]     — component root, carries the consumer's class and box dimensions
//   [data-part="surface"]  — carries the hook + phx-update="ignore"; id is `<root id>-surface`;
//                            the engine draws here and all configuration is read from ITS data-*
//
//   data-* on the surface  | meaning
//   -----------------------|---------------------------------------------------------------------
//   data-root-id           | id of the root; the id `chelekom:chart` filters on for live updates
//   data-option            | the whole engine option, JSON-encoded
//   data-theme             | "light"/"dark" to force a palette; empty follows the page
//   data-group             | echarts.connect group — synced tooltip/zoom across charts
//   data-on-click          | LiveView event pushed with a small payload when a datum is clicked
//
// Server -> client: `push_event("chelekom:chart", %{id: <root id>, option: ...})`. A single global
// event name with an id filter in the payload, matching otp.js/editor.js — a per-instance name
// cannot be produced by a LiveComponent that does not know the DOM id. Add `merge: false` to replace
// instead of merge; `resize: true` to force a resize.

import * as echarts from "echarts";
// Developer-owned, created once by the generator and never regenerated. See its header.
import userConfig from "./chart_extensions.js";

const FADE = "chelekom:fade";

// Built-in fallback palette, used only when the CSS custom properties --chart-1..8 are absent and
// the developer set none in chart_extensions.js. Legible on both light and dark backgrounds.
const DEFAULT_PALETTE = [
  "#3b82f6",
  "#22c55e",
  "#f59e0b",
  "#ef4444",
  "#8b5cf6",
  "#14b8a6",
  "#ec4899",
  "#64748b",
];

// ---- pure helpers -------------------------------------------------------------------------------

function cssVar(el, name) {
  return getComputedStyle(el).getPropertyValue(name).trim();
}

// The series palette: --chart-1..8 when present, else the developer palette, else the built-in one.
export function resolvePalette(el) {
  const fromVars = [];
  for (let i = 1; i <= 8; i++) {
    const v = cssVar(el, `--chart-${i}`);
    if (v) fromVars.push(v);
  }
  if (fromVars.length) return fromVars;
  if (Array.isArray(userConfig?.palette) && userConfig.palette.length) return userConfig.palette;
  return DEFAULT_PALETTE;
}

// Axis / grid / label colors, CSS-var first with neutral fallbacks.
function resolveTokens(el) {
  return {
    axis: cssVar(el, "--chart-axis") || "rgba(148,163,184,0.6)",
    grid: cssVar(el, "--chart-grid") || "rgba(148,163,184,0.2)",
    text: cssVar(el, "--chart-text") || cssVar(el, "--color-base-text") || "#64748b",
  };
}

// A JSON option string may be malformed if the server built it wrong; treat that as an empty chart
// rather than throwing, so one bad chart cannot break the whole page.
export function safeParse(raw) {
  if (raw == null || raw === "") return {};
  try {
    return JSON.parse(raw);
  } catch (_e) {
    return {};
  }
}

// "chelekom:currency:USD" etc. -> a real function. A function cannot cross the LiveView wire, so the
// server sends a string and we swap the function in here. Extend via chart_extensions.js. Returns
// null for anything that is not a known formatter sentinel (e.g. "chelekom:fade", handled elsewhere).
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

// Walk the option and replace formatter sentinels with real functions. "chelekom:fade" is left as a
// string for applyFade, which needs the series color. Everything else is returned untouched.
function resolveSentinels(node) {
  if (Array.isArray(node)) return node.map(resolveSentinels);
  if (node && typeof node === "object") {
    const out = {};
    for (const [k, v] of Object.entries(node)) out[k] = resolveSentinels(v);
    return out;
  }
  if (typeof node === "string" && node.startsWith("chelekom:") && node !== FADE) {
    const fn = intlFormatter(node);
    if (fn) return fn;
  }
  return node;
}

function withAlpha(color, alpha) {
  const m6 = /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i.exec(color);
  const m3 = /^#([0-9a-f])([0-9a-f])([0-9a-f])$/i.exec(color);
  let r, g, b;
  if (m6) {
    [r, g, b] = [m6[1], m6[2], m6[3]].map((h) => parseInt(h, 16));
  } else if (m3) {
    [r, g, b] = [m3[1], m3[2], m3[3]].map((h) => parseInt(h + h, 16));
  } else {
    return color;
  }
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

// Replace `areaStyle.color === "chelekom:fade"` with a top-to-transparent gradient of the series'
// own color, so filled line/area charts fade the right hue with no color hard-coded server-side.
function applyFade(option, palette) {
  if (!option.series) return;
  const list = Array.isArray(option.series) ? option.series : [option.series];
  list.forEach((s, i) => {
    if (s && s.areaStyle && s.areaStyle.color === FADE) {
      const base =
        s.itemStyle?.color ||
        s.lineStyle?.color ||
        s.color ||
        palette[i % palette.length];
      s.areaStyle.color = new echarts.graphic.LinearGradient(0, 0, 0, 1, [
        { offset: 0, color: withAlpha(base, 0.35) },
        { offset: 1, color: withAlpha(base, 0) },
      ]);
    }
  });
}

// Decorate any axis (object or array) with themed defaults the user's own settings win over.
function decorateAxes(axis, tokens) {
  if (!axis) return axis;
  const base = (a) => ({
    axisLine: { lineStyle: { color: tokens.axis }, ...(a?.axisLine || {}) },
    axisTick: { lineStyle: { color: tokens.axis }, ...(a?.axisTick || {}) },
    axisLabel: { color: tokens.text, ...(a?.axisLabel || {}) },
    splitLine: {
      lineStyle: { color: tokens.grid },
      ...(a?.splitLine || {}),
      show: a?.splitLine?.show ?? false,
    },
    ...a,
  });
  return Array.isArray(axis) ? axis.map(base) : base(axis);
}

// Inject palette + text/axis/grid colors as DEFAULTS; anything the option already sets is kept.
function applyTheme(option, palette, tokens) {
  if (!option.color) option.color = palette;
  option.backgroundColor = option.backgroundColor || "transparent";
  option.textStyle = { color: tokens.text, ...(option.textStyle || {}) };
  if (option.xAxis) option.xAxis = decorateAxes(option.xAxis, tokens);
  if (option.yAxis) option.yAxis = decorateAxes(option.yAxis, tokens);
  if (option.legend) {
    const legends = Array.isArray(option.legend) ? option.legend : [option.legend];
    legends.forEach((l) => (l.textStyle = { color: tokens.text, ...(l.textStyle || {}) }));
  }
  // The surface clips overflow (so the chart never forces a page scrollbar), which would also clip a
  // tooltip near an edge — confine it to the box unless the option says otherwise.
  if (option.tooltip && option.tooltip.confine === undefined) option.tooltip.confine = true;
  return option;
}

function clickPayload(params) {
  return {
    name: params.name,
    value: params.value,
    seriesName: params.seriesName,
    seriesIndex: params.seriesIndex,
    dataIndex: params.dataIndex,
    componentType: params.componentType,
  };
}

// ---- hook ---------------------------------------------------------------------------------------

const Chart = {
  mounted() {
    const el = this.el;
    this.rootId = el.getAttribute("data-root-id");
    this.root = document.getElementById(this.rootId) || el.parentElement;
    this.onClick = el.getAttribute("data-on-click");
    this.group = el.getAttribute("data-group") || null;
    this.domOption = el.getAttribute("data-option");
    this.raw = this.domOption;

    this.chart = echarts.init(el, null, { renderer: "canvas" });
    this.chart.setOption(this.prepare(this.raw));

    if (this.group) {
      this.chart.group = this.group;
      echarts.connect(this.group);
    }

    if (this.onClick) {
      this.chart.on("click", (params) => {
        this.pushEventTo(this.el, this.onClick, clickPayload(params));
      });
    }

    // A chart inside a hidden tab mounts at 0×0; ResizeObserver repaints it the moment it is shown,
    // and also handles ordinary window/layout resizes without a window listener.
    this.ro = new ResizeObserver(() => this.chart && this.chart.resize());
    this.ro.observe(el);

    // Re-theme on a light/dark toggle when the palette is not forced: the CSS vars change, so we
    // re-read them and re-apply. Guarded to avoid a render->patch loop (setOption never pushes).
    if (!el.getAttribute("data-theme")) {
      this.themeObserver = new MutationObserver(() => this.retheme());
      this.themeObserver.observe(document.documentElement, {
        attributes: true,
        attributeFilter: ["data-theme", "class"],
      });
      this.mql = window.matchMedia("(prefers-color-scheme: dark)");
      this._onScheme = () => this.retheme();
      this.mql.addEventListener("change", this._onScheme);
    }

    this.ref = this.handleEvent("chelekom:chart", (payload) => {
      if (!payload || (payload.id && payload.id !== this.rootId)) return;
      if (payload.option != null) {
        this.raw = payload.option;
        this.chart.setOption(this.prepare(this.raw), { notMerge: payload.merge === false });
      }
      if (payload.resize) this.chart.resize();
    });
  },

  // Only data-* survive on an ignored element, so a server re-assign of `option` lands on
  // data-option. Re-apply only when it actually changed, so unrelated patches do not thrash.
  updated() {
    if (!this.chart) return;
    const next = this.el.getAttribute("data-option");
    if (next !== this.domOption) {
      this.domOption = next;
      this.raw = next;
      this.chart.setOption(this.prepare(this.raw));
    }
  },

  destroyed() {
    if (this.ro) this.ro.disconnect();
    if (this.themeObserver) this.themeObserver.disconnect();
    if (this.mql && this._onScheme) this.mql.removeEventListener("change", this._onScheme);
    if (this.ref) this.removeHandleEvent(this.ref);
    // The single biggest leak: without dispose the ECharts instance, its canvas and listeners
    // outlive every LiveView navigation.
    if (this.chart) this.chart.dispose();
    this.chart = null;
  },

  // Parse (if a string), resolve sentinels, then inject the current theme. Palette/tokens are read
  // fresh each time so a theme toggle recolors correctly. Accepts a JSON string or an object.
  prepare(raw) {
    const palette = resolvePalette(this.el);
    const tokens = resolveTokens(this.el);
    const parsed = typeof raw === "string" ? safeParse(raw) : raw || {};
    const option = resolveSentinels(parsed);
    applyTheme(option, palette, tokens);
    applyFade(option, palette);
    return option;
  },

  retheme() {
    if (this.chart) this.chart.setOption(this.prepare(this.raw), { notMerge: true });
  },
};

export default Chart;
