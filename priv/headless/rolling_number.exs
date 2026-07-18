[
  rolling_number: [
    name: "rolling_number",
    category: "data display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/rolling_number",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["rolling_number"], only: ["rolling_number"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "RollingNumber", type: "file", file: "rolling_number.js", imports: "import RollingNumber from \"./rolling_number.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "span",
          data_attributes: ["data-value"],
          note: "carries the RollingNumber hook; animates on mount and on data-value change",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [pattern: "Rolling number (no formal APG pattern)", keyboard: []],
      state_attributes: [],
      hooks: ["RollingNumber"]
    ]
  ]
]
