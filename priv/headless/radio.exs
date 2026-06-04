[
  radio: [
    name: "radio",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/radio/",
    args: [type: ["radio"], only: ["radio"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        input: [element: "input", note: "native radio input"],
        indicator: [element: "span"],
        label: [element: "span"]
      ]
    ],
    aria_pattern: [pattern: "Radio", keyboard: ["native radio semantics"]],
    state_attributes: ["data-disabled"],
    hooks: []
  ]
]
