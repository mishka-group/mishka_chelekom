[
  meter: [
    name: "meter",
    category: "feedback",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/meter/",
    args: [type: ["meter"], only: ["meter"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "meter",
          aria: ["aria-valuemin", "aria-valuemax", "aria-valuenow", "aria-labelledby"],
          required: true
        ],
        parts: [label: [element: "span"], track: [element: "div"], indicator: [element: "div"]]
      ],
      aria_pattern: [pattern: "Meter", keyboard: []],
      state_attributes: [],
      hooks: []
    ]
  ]
]
