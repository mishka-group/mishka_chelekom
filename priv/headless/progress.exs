[
  progress: [
    name: "progress",
    category: "feedback",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/progressbar/",
    args: [type: ["progress"], only: ["progress"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "progressbar",
          aria: ["aria-valuemin", "aria-valuemax", "aria-valuenow", "aria-label"],
          required: true
        ],
        parts: [indicator: [element: "div", data_attributes: ["data-part"]]]
      ],
      aria_pattern: [pattern: "Progressbar", keyboard: []],
      state_attributes: [],
      hooks: []
    ]
  ]
]
