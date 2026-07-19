[
  highlight: [
    name: "highlight",
    category: "typography",
    doc_url: "https://mishka.tools/chelekom/docs/headless/highlight",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["highlight"], only: ["highlight"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [element: "span", note: "wraps the text; matches become <mark> parts", required: true],
        parts: [
          mark: [element: "mark", note: "each highlighted match (case-insensitive)"]
        ]
      ],
      aria_pattern: [pattern: "Highlight (no formal APG pattern)", keyboard: []],
      state_attributes: [],
      hooks: []
    ]
  ]
]
