defmodule DevelopmentWeb.Components.Headless.Chart do
  @moduledoc """
  Headless **chart** — a declarative wrapper over a JavaScript charting engine (Apache **ECharts**
  by default; **Chart.js** or **billboard.js** via `--engine`).

  You write the engine's option object as a plain Elixir map and pass it to `option`. The map is
  JSON-encoded and handed to the engine on the client, so the entire chart spec lives server-side
  and travels the LiveView wire as data. There is **no per-chart JavaScript**: the one `Chart`
  hook — installed by the generator — calls the engine's `init` / `setOption` for you.

  Like the editor, the hook is **not** on the root. The chart `surface` is `phx-update="ignore"`
  because the engine owns that subtree (a `<canvas>` or `<svg>` it draws into), and LiveView merges
  only `data-*` on an ignored element — `class`/`style` there would freeze at first render. So the
  root keeps your live `class`, and every live knob (`option`, `theme`, …) is a `data-*` on the
  surface.

  ## The option shape is the engine's own

  `option` is passed through **raw**, so its shape is whichever engine you generated:

    * **echarts** — the [ECharts option](https://echarts.apache.org/en/option.html):
      `%{xAxis: %{type: "category", data: ~w(Mon Tue Wed)}, yAxis: %{type: "value"},
      series: [%{type: "bar", data: [120, 200, 150]}]}`
    * **chartjs** — the [Chart.js config](https://www.chartjs.org/docs/latest/):
      `%{type: "line", data: %{labels: ~w(Mon Tue Wed), datasets: [%{label: "Sales",
      data: [120, 200, 150]}]}}`
    * **billboard** — the [billboard.js config](https://naver.github.io/billboard.js/) without
      `bindto` (the hook binds it): `%{data: %{columns: [["Sales", 120, 200, 150]], type: "bar"}}`

  ## Theming (the bridge)

  Series colors come from the CSS custom properties `--chart-1` … `--chart-8` (read off the chart
  element at mount); axis, grid and label colors from `--chart-axis`, `--chart-grid`, `--chart-text`.
  Define them in `app.css` for light and dark, and every chart re-colors with your theme — you never
  hard-code a palette into the option. A sensible default palette ships in `chart_extensions.js`
  (developer-owned, generated once) so charts look right before you theme anything.

  ## Formatters (the string trick)

  Engine formatters are JS callbacks, and a function cannot cross the LiveView wire — so pass a
  **sentinel string** and the hook swaps in a real `Intl` function on the client:

    * `"chelekom:number"`, `"chelekom:compact"`, `"chelekom:percent"`
    * `"chelekom:currency:USD"` (any ISO 4217 code)
    * `"chelekom:fade"` as a color (e.g. ECharts `areaStyle: %{color: "chelekom:fade"}`) becomes a
      top-to-transparent gradient of the series color

  Add your own in `chart_extensions.js`.

  ## Live updates

  Because the surface is `phx-update="ignore"`, change a chart by pushing a fresh option rather than
  re-rendering:

      push_event(socket, "chelekom:chart", %{id: "sales", option: new_option})

  Add `merge: false` to the payload to replace rather than merge. Re-assigning `option` on the
  server also works (it rides in on `data-option`), but a push avoids growing the DOM payload for
  large datasets.

  ## Accessibility

  A canvas/SVG chart is opaque to a screen reader, so give every chart an `aria_label`; the surface
  is `role="img"`. For ECharts you can additionally set the engine's own `aria` option in `option`
  for a generated description of the data.

  Needs one npm package, installed for you by the generator: `echarts` (Apache-2.0) — or `chart.js`
  / `billboard.js` (both MIT) when you pass `--engine`.

  Ships **no** colors, spacing or typography of its own — size it with `height` / `width`, style the
  box via `chelekom-chart*`, and drive the palette from the `--chart-*` custom properties.

  The surface clips its overflow, so a chart always shrinks to fit its container (even inside a CSS
  grid or flex column) instead of forcing a horizontal scrollbar. A side effect is that a tooltip
  near an edge is clipped to the box; for ECharts the hook defaults `tooltip.confine` to `true` so
  tooltips stay inside — override it in `option` if you want them to escape.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/chart
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "Unique id; also the id `push_event` targets for live updates"

  attr :option, :any,
    default: %{},
    doc:
      "The engine-native chart spec as an Elixir map (atom or string keys), JSON-encoded and passed " <>
        "through raw. A pre-encoded JSON string is accepted too. May be empty and filled later via " <>
        "`push_event`"

  attr :theme, :string,
    default: nil,
    doc:
      ~s|Force a palette: `"light"` or `"dark"`. `nil` follows the page (a `data-theme` on `<html>`, else `prefers-color-scheme`)|

  attr :height, :string,
    default: "20rem",
    doc:
      "CSS height of the chart box. A chart needs an explicit height, or it collapses to 0 and draws nothing"

  attr :width, :string, default: "100%", doc: "CSS width of the chart box"

  attr :group, :string,
    default: nil,
    doc:
      "Sync tooltip and zoom across charts that share this group name (ECharts `connect`; ignored " <>
        "by the other engines)"

  attr :aria_label, :string,
    default: nil,
    doc: "Accessible name for the chart (strongly recommended)"

  attr :on_click, :string,
    default: nil,
    doc: "LiveView event pushed when a data point is clicked, with a small serializable payload"

  attr :hook, :string,
    default: "Chart",
    doc:
      "Advanced: the JS hook to mount. Every engine registers `Chart`, so this only matters if you " <>
        "have hand-vendored a second engine under another name"

  attr :class, :any, default: nil, doc: "Extra classes for the root (stays live)"

  attr :surface_class, :any,
    default: nil,
    doc: "Extra classes for the chart surface. Frozen after first render (it is ignored)"

  attr :rest, :global

  def chart(assigns) do
    ~H"""
    <div
      id={@id}
      data-part="root"
      class={["chelekom-chart", @class]}
      style={"width: #{@width}; height: #{@height}"}
      {@rest}
    >
      <div
        id={"#{@id}-surface"}
        phx-hook={@hook}
        phx-update="ignore"
        data-part="surface"
        data-root-id={@id}
        data-option={encode_option(@option)}
        data-theme={@theme}
        data-group={@group}
        data-on-click={@on_click}
        role="img"
        aria-label={@aria_label}
        class={["chelekom-chart__surface", @surface_class]}
        style="width: 100%; height: 100%; overflow: hidden"
      >
      </div>
    </div>
    """
  end

  # The option map is what the engine consumes. Encode with the app's configured JSON library so a
  # sentinel string (e.g. "chelekom:currency:USD") rides through untouched and is resolved to a real
  # function on the client. A pre-encoded string is passed straight through.
  defp encode_option(nil), do: "{}"
  defp encode_option(json) when is_binary(json), do: json

  defp encode_option(option) when is_map(option) or is_list(option),
    do: Phoenix.json_library().encode!(option)
end
