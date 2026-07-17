[
  anchor: [
    name: "anchor",
    category: "navigation",
    doc_url: "https://mishka.tools/chelekom/docs/headless/anchor",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["anchor"], only: ["anchor"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "a",
          note: "a plain link; pass href/navigate/patch and any global attrs",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [pattern: "Link (no formal APG pattern)", keyboard: ["Enter — follow"]],
      state_attributes: [],
      hooks: []
    ]
  ]
]
