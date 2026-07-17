[
  pill: [
    name: "pill",
    category: "data display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/pill",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["pill"], only: ["pill"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "span",
          data_attributes: ["data-disabled"],
          note: "the tag container; presentational",
          required: true
        ],
        parts: [
          label: [element: "span", note: "the tag content"],
          remove: [
            element: "button",
            aria: ["aria-label"],
            note: "optional dismiss button (with_remove); fires on_remove"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Pill (no formal APG pattern)",
        keyboard: ["Enter / Space — activate the remove button"]
      ],
      state_attributes: ["data-disabled"],
      hooks: []
    ]
  ]
]
