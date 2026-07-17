[
  burger: [
    name: "burger",
    category: "buttons",
    doc_url: "https://mishka.tools/chelekom/docs/headless/burger",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/",
    args: [type: ["burger"], only: ["burger"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "button",
          role: "button",
          aria: ["aria-expanded", "aria-controls", "aria-label"],
          data_attributes: ["data-opened", "data-disabled"],
          note: "open/close navigation toggle; you own the open state",
          required: true
        ],
        parts: [
          line: [
            element: "span",
            note: "three bars; animate to an ✕ under data-opened via CSS (:nth-child)"
          ]
        ]
      ],
      aria_pattern: [pattern: "Disclosure", keyboard: ["Enter / Space — toggle"]],
      state_attributes: ["data-opened", "data-disabled"],
      hooks: []
    ]
  ]
]
