// Chart — headless charting engine (Chart.js). One hook, `Chart`, drives every engine; this file is
// the Chart.js build. The generator installs exactly one engine file as `chart.js`.
//
// The hook lives on [data-part="surface"], NOT on the component root. The surface is
// `phx-update="ignore"` because Chart.js owns that subtree (a <canvas> the hook injects), and
// LiveView merges ONLY `data-*` on an ignored element. Every live knob is a `data-*` and the whole
// chart spec rides in on data-option. See chart_echarts.js for the full element/data-* contract; the
// two engines are interchangeable behind one <.chart> markup.
//
// The option here is the Chart.js *config* — `%{type:, data:, options:}` — passed through raw.
// Server -> client live updates: `push_event("chelekom:chart", %{id:, option:, merge:, resize:})`.

import { Chart as ChartJS, registerables } from "chart.js";
// Register every controller/element/scale/plugin, so every chart type works out of the box.
ChartJS.register(...registerables);
// Developer-owned, created once by the generator and never regenerated. See its header.
import userConfig from "./chart_extensions.js";

const FADE = "chelekom:fade";
const ARC_TYPES = ["pie", "doughnut", "polarArea"];

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

function resolveTokens(el) {
  return {
    axis: cssVar(el, "--chart-axis") || "rgba(148,163,184,0.6)",
    grid: cssVar(el, "--chart-grid") || "rgba(148,163,184,0.2)",
    text: cssVar(el, "--chart-text") || cssVar(el, "--color-base-text") || "#64748b",
  };
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

// Chart.js formatter callbacks take (value, index, ticks); a sentinel becomes a function of the
// value. "chelekom:fade" is left for applyTheme, which needs the series color and the canvas.
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

// A scriptable fill: a top-to-transparent gradient of the series color, built once the chart area
// exists. Used when a dataset asks for backgroundColor "chelekom:fade".
function fadeFill(base) {
  return (ctx) => {
    const area = ctx.chart.chartArea;
    if (!area) return withAlpha(base, 0.2);
    const g = ctx.chart.ctx.createLinearGradient(0, area.top, 0, area.bottom);
    g.addColorStop(0, withAlpha(base, 0.35));
    g.addColorStop(1, withAlpha(base, 0));
    return g;
  };
}

function isArc(type) {
  return ARC_TYPES.includes(type);
}

// Inject palette + text/axis/grid colors as DEFAULTS; anything the config already sets is kept.
function applyTheme(config, palette, tokens) {
  const type = config.type;
  config.data = config.data || {};
  (config.data.datasets || []).forEach((ds, i) => {
    const color = palette[i % palette.length];
    if (isArc(type)) {
      if (ds.backgroundColor == null) ds.backgroundColor = palette;
    } else {
      if (ds.borderColor == null) ds.borderColor = color;
      if (ds.backgroundColor == null) ds.backgroundColor = color;
      else if (ds.backgroundColor === FADE) ds.backgroundColor = fadeFill(color);
      if (type === "line" && ds.pointBackgroundColor == null) ds.pointBackgroundColor = color;
    }
  });

  const options = (config.options = config.options || {});
  options.responsive = options.responsive ?? true;
  // The surface is a fixed-height box, so let the canvas fill it rather than pick its own ratio.
  options.maintainAspectRatio = options.maintainAspectRatio ?? false;
  options.color = options.color ?? tokens.text;

  if (!isArc(type) && type !== "radar") {
    options.scales = options.scales || {};
    ["x", "y"].forEach((axis) => {
      const s = (options.scales[axis] = options.scales[axis] || {});
      s.grid = { color: tokens.grid, ...(s.grid || {}) };
      s.ticks = { color: tokens.text, ...(s.ticks || {}) };
      s.border = { color: tokens.axis, ...(s.border || {}) };
    });
  }

  options.plugins = options.plugins || {};
  const legend = (options.plugins.legend = options.plugins.legend || {});
  legend.labels = { color: tokens.text, ...(legend.labels || {}) };
  return config;
}

// ---- hook ---------------------------------------------------------------------------------------

const Chart = {
  mounted() {
    const el = this.el;
    this.rootId = el.getAttribute("data-root-id");
    this.onClick = el.getAttribute("data-on-click");
    this.domOption = el.getAttribute("data-option");
    this.raw = this.domOption;

    // Chart.js draws on a <canvas>; the component surface is a <div>, so inject one that fills it.
    this.canvas = document.createElement("canvas");
    el.appendChild(this.canvas);

    this.render(this.build(this.raw));

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
        this.render(this.build(this.raw), payload.merge === false);
      }
      if (payload.resize) this.chart && this.chart.resize();
    });
  },

  updated() {
    if (!this.chart) return;
    const next = this.el.getAttribute("data-option");
    if (next !== this.domOption) {
      this.domOption = next;
      this.raw = next;
      this.render(this.build(this.raw));
    }
  },

  destroyed() {
    if (this.themeObserver) this.themeObserver.disconnect();
    if (this.mql && this._onScheme) this.mql.removeEventListener("change", this._onScheme);
    if (this.ref) this.removeHandleEvent(this.ref);
    // Chart.js keeps a global registry of live instances plus its own ResizeObserver; without
    // destroy they outlive every LiveView navigation.
    if (this.chart) this.chart.destroy();
    this.chart = null;
  },

  // Parse (if a string), resolve sentinels, inject the current theme. Palette/tokens read fresh so a
  // theme toggle recolors correctly. Accepts a JSON string or an object.
  build(raw) {
    const palette = resolvePalette(this.el);
    const tokens = resolveTokens(this.el);
    const parsed = typeof raw === "string" ? safeParse(raw) : raw || {};
    const config = resolveSentinels(parsed);
    if (this.onClick) {
      const opts = (config.options = config.options || {});
      opts.onClick = (_evt, elements) => {
        if (!elements.length) return;
        const { datasetIndex, index } = elements[0];
        const ds = this.chart.data.datasets[datasetIndex] || {};
        this.pushEventTo(this.el, this.onClick, {
          datasetIndex,
          index,
          label: this.chart.data.labels?.[index],
          seriesName: ds.label,
          value: ds.data?.[index],
        });
      };
    }
    return applyTheme(config, palette, tokens);
  },

  // Chart.js cannot switch a live instance's type, so recreate when the type changes (or a replace
  // is requested); otherwise mutate data/options in place for an animated update.
  render(config, replace = false) {
    if (this.chart && !replace && this.chart.config.type === config.type) {
      this.chart.data = config.data;
      this.chart.options = config.options;
      this.chart.update();
    } else {
      if (this.chart) this.chart.destroy();
      this.chart = new ChartJS(this.canvas, config);
    }
  },

  retheme() {
    this.render(this.build(this.raw), true);
  },
};

export default Chart;
