// Chart configuration — THIS FILE IS YOURS.
//
// Chelekom creates it once and never overwrites it, so anything you put here survives
// `mix mishka.ui.gen.headless chart` being run again. (The engine next to it, chart_*.js, IS
// regenerated — never edit that one.)
//
// Every engine (ECharts, Chart.js, billboard.js) reads this same shape, so switching engines does
// not mean re-learning this file.
//
//   palette     Fallback series colors, used only when the CSS custom properties --chart-1..8 are
//               NOT defined on the page. Prefer the CSS vars (they theme with light/dark for free);
//               this is the "before you theme anything" default.
//
//   formatters  Extra formatter sentinels. A key `foo` here is reachable from the server as the
//               string "chelekom:foo" anywhere the engine takes a formatter (axis labels, tooltips,
//               data labels). The function receives (value, arg) where `arg` is the third segment of
//               the sentinel, e.g. "chelekom:unit:kg" calls unit(value, "kg").
//
//   billboard   Engine-specific knobs. `injectStyles: false` opts out of the compact stylesheet the
//               billboard engine injects (set it if you import billboard.js/dist/billboard.css
//               yourself).

export default {
  palette: [],
  formatters: {
    // Example — uncomment and use as "chelekom:unit:kg" in an axisLabel/ticks formatter:
    // unit: (value, arg) => `${new Intl.NumberFormat().format(value)} ${arg ?? ""}`.trim(),
  },
  billboard: {
    injectStyles: true,
  },
};
