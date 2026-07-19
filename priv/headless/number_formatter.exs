[
  number_formatter: [
    name: "number_formatter",
    category: "data display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/number_formatter",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["number_formatter"], only: ["number_formatter"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "span",
          note: "renders a formatted number (thousands/decimal separators, prefix/suffix)",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [pattern: "Number formatter (no formal APG pattern)", keyboard: []],
      state_attributes: [],
      hooks: []
    ]
  ]
]
