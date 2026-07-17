[
  visually_hidden: [
    name: "visually_hidden",
    category: "misc",
    doc_url: "https://mishka.tools/chelekom/docs/headless/visually_hidden",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["visually_hidden"], only: ["visually_hidden"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "span",
          note: "visually hidden but readable by screen readers (inline CSS, works with no stylesheet)",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [pattern: "Visually hidden (utility)", keyboard: []],
      state_attributes: [],
      hooks: []
    ]
  ]
]
