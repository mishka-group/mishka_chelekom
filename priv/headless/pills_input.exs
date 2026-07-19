[
  pills_input: [
    name: "pills_input",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/pills_input",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["pills_input"], only: ["pills_input"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-disabled"],
          note: "input-shaped control; clicking it focuses the input via JS.focus (no JS hook)",
          required: true
        ],
        parts: [
          input: [element: "input", note: "the trailing text field (bind to a form field)"]
        ]
      ],
      aria_pattern: [pattern: "Pills input (text field + tokens)", keyboard: ["Enter — add via on_add"]],
      state_attributes: ["data-disabled"],
      hooks: []
    ]
  ]
]
