[
  floating_indicator: [
    name: "floating_indicator",
    category: "navigation",
    doc_url: "https://mishka.tools/chelekom/docs/headless/floating_indicator",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["floating_indicator"], only: ["floating_indicator"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "FloatingIndicator", type: "file", file: "floating_indicator.js", imports: "import FloatingIndicator from \"./floating_indicator.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-active", "data-on-change"],
          note: "carries the FloatingIndicator hook; must be positioned (relative)",
          required: true
        ],
        parts: [
          indicator: [element: "span", note: "the moving highlight; engine sets transform + size"],
          target: [element: "button", note: "an option; needs data-value; gets data-active when selected"]
        ]
      ],
      aria_pattern: [pattern: "Floating indicator (no formal APG pattern)", keyboard: []],
      state_attributes: ["data-active"],
      hooks: ["FloatingIndicator"]
    ]
  ]
]
