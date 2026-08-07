[
  chart: [
    name: "chart",
    category: "data display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/chart",
    spec_url: "https://echarts.apache.org/en/option.html",
    args: [type: ["chart"], only: ["chart"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,

    # Top-level = the default engine (echarts). The catalog-integrity tests read THIS key for the
    # exact-version and permissive-license checks; each :libs entry re-pins its own package. EXACT
    # pins, never carets — the version shape is asserted (x.y.z), and a range would let a peer-pinned
    # transitive (e.g. billboard's d3-*) drift into a combination that fails at runtime, not install.
    npm: [%{name: "echarts", version: "6.1.0"}],

    license: [
      spdx: "Apache-2.0",
      note:
        "The default engine, Apache ECharts, is Apache-2.0 — the same license as this project. The " <>
          "other engines are permissive too: Chart.js is MIT, billboard.js is MIT (it pulls the " <>
          "d3-* modules, which are ISC/BSD). ApexCharts is deliberately NOT offered: every release " <>
          "after 5.0.0 relicensed to a proprietary dual-license (free only under a revenue cap), " <>
          "which is incompatible with an Apache-2.0 project and is rejected by the catalog tests."
    ],

    # Multi-engine shape, exactly like the editor. There is ONE <.chart> markup, ONE hook name
    # (Chart) and ONE installed file (chart.js); the only thing --engine changes is which engine
    # file is copied and which npm package is installed. Every entry MUST register the same hook
    # module (asserted by the catalog-integrity test) so the template never branches. Adding a
    # fourth engine is this data plus one file — no change to the component's markup or public API.
    libs: [
      echarts: [
        default: true,
        npm: [%{name: "echarts", version: "6.1.0"}],
        scripts: [
          %{
            module: "Chart",
            type: "file",
            file: "chart_echarts.js",
            # Every engine installs under ONE name, so switching engines overwrites the file instead
            # of leaving a stale one that still imports the packages we removed.
            as: "chart.js",
            imports: "import Chart from \"./chart.js\";"
          }
        ]
      ],
      chartjs: [
        npm: [%{name: "chart.js", version: "4.5.1"}],
        scripts: [
          %{
            module: "Chart",
            type: "file",
            file: "chart_chartjs.js",
            as: "chart.js",
            imports: "import Chart from \"./chart.js\";"
          }
        ]
      ],
      billboard: [
        npm: [%{name: "billboard.js", version: "4.0.3"}],
        scripts: [
          %{
            module: "Chart",
            type: "file",
            file: "chart_billboard.js",
            as: "chart.js",
            imports: "import Chart from \"./chart.js\";"
          }
        ]
      ]
    ],

    # Written once into assets/vendor/ and never overwritten, so a developer's palette and custom
    # formatters survive regeneration. The engine beside it IS regenerated, which is why this config
    # cannot live in it.
    user_files: [%{file: "chart_extensions.js"}],
    scripts: [
      %{
        module: "Chart",
        type: "file",
        file: "chart_echarts.js",
        as: "chart.js",
        imports: "import Chart from \"./chart.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-empty"],
          note:
            "the styled wrapper — carries the live `class` and the box dimensions. NOT the hook: " <>
              "unlike the ignored surface it keeps a live class the server can re-render",
          required: true
        ],
        parts: [
          surface: [
            element: "div",
            role: "img",
            aria: ["aria-label"],
            data_attributes: [
              "data-root-id",
              "data-option",
              "data-theme",
              "data-group",
              "data-on-click"
            ],
            note:
              "carries phx-hook + phx-update=\"ignore\"; id is <root id>-surface. The engine draws " <>
                "its canvas/svg here, so data-* is the only channel the server can reach it through; " <>
                "data-option carries the whole (JSON-encoded) engine option"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Chart (role=img with an accessible name)",
        keyboard: [
          "Charts are non-interactive by default (role=img)",
          "Give every chart an aria_label; the engine's own data is invisible to a screen reader",
          "For ECharts you can additionally set its `aria` option for a generated description"
        ]
      ],
      state_attributes: ["data-empty"],
      hooks: ["Chart"]
    ]
  ]
]
