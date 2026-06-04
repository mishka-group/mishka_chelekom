[
  checkbox_group: [
    name: "checkbox_group",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/",
    args: [type: ["checkbox_group"], only: ["checkbox_group"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    anatomy: [
      root: [element: "div", role: "group", aria: ["aria-labelledby"], required: true],
      parts: [
        label: [element: "span", note: "visible group label wired to aria-labelledby"],
        item: [element: "label", data_attributes: ["data-disabled"]],
        input: [element: "input", note: "native checkbox; submits as name[]"]
      ]
    ],
    aria_pattern: [
      pattern: "Checkbox",
      keyboard: ["Space: toggle the focused checkbox", "Tab: move between checkboxes"]
    ],
    state_attributes: ["data-disabled"]
  ]
]
