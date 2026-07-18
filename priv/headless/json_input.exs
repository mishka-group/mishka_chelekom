[
  json_input: [
    name: "json_input",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/json_input",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["json_input"], only: ["json_input"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "textarea",
          data_attributes: ["data-invalid"],
          note: "a plain textarea; validate/format JSON on the server (no JS)",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [pattern: "Textbox (multiline)", keyboard: []],
      state_attributes: ["data-invalid"],
      hooks: []
    ]
  ]
]
