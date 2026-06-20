[
  separator: [
    name: "separator",
    category: "feedback",
    doc_url: "https://www.w3.org/TR/wai-aria-1.2/#separator",
    args: [type: ["separator"], only: ["separator"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "separator",
          aria: ["aria-orientation"],
          data_attributes: ["data-orientation"],
          required: true
        ],
        parts: [label: [element: "span"]]
      ],
      aria_pattern: [pattern: "Separator", keyboard: []],
      state_attributes: ["data-orientation"],
      hooks: []
    ]
  ]
]
